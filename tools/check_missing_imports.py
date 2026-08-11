#!/usr/bin/env python3
"""Static scan for missing imports / undefined project symbols in lib/ and test/.

Collects all top-level symbols declared in the project's own .dart files,
then checks that every file referencing such a symbol imports the file that
declares it (directly or via export). Mirrors the class of errors that broke
CI ("The method 'X' isn't defined for the class 'Y'").
"""
import os
import re
import sys
from collections import defaultdict

ROOTS = ["lib", "test"]
PKG = "jazireh_fandoghi"

decl_re = re.compile(
    r"^\s*(?:abstract\s+|sealed\s+|base\s+|final\s+|interface\s+)?"
    r"(?:class|mixin|enum|extension)\s+([A-Za-z_$][\w$]*)"
)
typedef_re = re.compile(r"^\s*typedef\s+([A-Za-z_$][\w$]*)")
toplevel_fn_re = re.compile(
    r"^\s*(?:Future(?:<[^>]*>)?|void|int|double|num|bool|String|dynamic|Object\??|"
    r"List<[^>]*>|Map<[^>]*>|Set<[^>]*>|Stream<[^>]*>|Widget|ThemeData|[A-Z][\w$]*(?:<[^>]*>)?\??)"
    r"\s+([A-Za-z_$][\w$]*)\s*(?:\([^;]*\)\s*(?:async\s*\*?\s*)?\{)"
)
toplevel_var_re = re.compile(
    r"^\s*(?:final|const|var|late\s+final)\s+(?:[\w$<>?,\s]+\s+)?([A-Za-z_$][\w$]*)\s*[=;,]"
)
toplevel_getter_re = re.compile(
    r"^\s*(?:static\s+)?[\w$<>?,\s]+\s+get\s+([A-Za-z_$][\w$]*)"
)
import_re = re.compile(
    r"""^\s*import\s+['"]([^'"]+)['"](?:\s+as\s+([\w$]+))?(?:\s+(show|hide)\s+([\w$,\s]+))?\s*;"""
)
export_re = re.compile(r"""^\s*export\s+['"]([^'"]+)['"](?:\s+(show|hide)\s+([\w$,\s]+))?\s*;""")
ident_re = re.compile(r"[A-Za-z_$][\w$]*")

# Common SDK / material framework names that may collide with project names
# and would produce false positives if a project file happened to define them.
FRAMEWORK_NAMES = {
    "Image", "Path", "Route", "Size", "Offset", "Rect", "Radius", "Border",
    "BorderRadius", "Alignment", "Duration", "Curve", "Curves", "Colors",
    "Icons", "Widget", "Element", "State", "Key", "Future", "Stream",
    "Color", "Point", "Rectangle", "Matrix", "Text", "Span", "Style",
    "springSimulation", "max", "min", "Random",
}


def collect_files():
    files = {}
    for root in ROOTS:
        if not os.path.isdir(root):
            continue
        for dirpath, _dirs, names in os.walk(root):
            for name in names:
                if name.endswith(".dart"):
                    path = os.path.join(dirpath, name)
                    files[path] = open(path, encoding="utf-8").read()
    return files


def strip_noise(source: str) -> str:
    """Remove comments and string literals so identifiers inside them don't count."""
    out = []
    i, n = 0, len(source)
    while i < n:
        if source.startswith("//", i):
            j = source.find("\n", i)
            i = n if j < 0 else j
        elif source.startswith("/*", i):
            j = source.find("*/", i + 2)
            i = n if j < 0 else j + 2
        elif source.startswith("'''", i) or source.startswith('"""', i):
            q = source[i:i + 3]
            j = source.find(q, i + 3)
            i = n if j < 0 else j + 3
            out.append(" '' ")
        elif source[i] in "'\"":
            q = source[i]
            j = i + 1
            while j < n:
                if source[j] == "\\":
                    j += 2
                    continue
                if source[j] == q:
                    break
                if source.startswith("$", j):  # interpolation -> keep code tokens inside
                    out.append("\n")
                j += 1
            i = min(j + 1, n)
            out.append(" '' ")
        else:
            out.append(source[i])
            i += 1
    return "".join(out)


def resolve_path(importer: str, uri: str, all_files):
    if uri.startswith("package:"):
        rest = uri[len("package:"):]
        if rest.startswith(PKG + "/"):
            candidate = os.path.normpath(os.path.join("lib", rest[len(PKG) + 1:]))
            return candidate if candidate in all_files else None
        return None  # external package
    if ":" in uri:  # dart:core etc.
        return None
    candidate = os.path.normpath(os.path.join(os.path.dirname(importer), uri))
    return candidate if candidate in all_files else None


def parse_combinators(kind, names_str):
    names = {n.strip() for n in names_str.split(",") if n.strip()}
    return kind, names


def main():
    files = collect_files()

    # 1) declared symbols per file
    declared = {}
    for path, src in files.items():
        clean = strip_noise(src)
        syms = set()
        for line in clean.splitlines():
            for rx in (decl_re, typedef_re, toplevel_fn_re, toplevel_var_re, toplevel_getter_re):
                m = rx.match(line)
                if m:
                    syms.add(m.group(1))
        # drop private (can't be imported anyway)
        declared[path] = {s for s in syms if not s.startswith("_")}

    # symbol -> declaring files
    symbol_where = defaultdict(list)
    for path, syms in declared.items():
        for s in syms:
            symbol_where[s].append(path)

    # 2) exports graph (transitive provide) — resolve exports
    exports = {p: [] for p in files}
    for path, src in files.items():
        for line in src.splitlines():
            m = export_re.match(line)
            if m:
                target = resolve_path(path, m.group(1), files)
                if target:
                    comb = parse_combinators(m.group(2), m.group(3)) if m.group(2) else None
                    exports[path].append((target, comb))

    provides_cache = {}

    def provides(path, seen=None):
        if path in provides_cache:
            return provides_cache[path]
        if seen is None:
            seen = set()
        if path in seen:
            return set()
        seen.add(path)
        result = set(declared.get(path, ()))
        result |= {"main"} if path.endswith("main.dart") else set()
        for target, comb in exports.get(path, []):
            subs = provides(target, seen)
            if comb:
                kind, names = comb
                subs = (subs & names) if kind == "show" else (subs - names)
            result |= subs
        provides_cache[path] = result
        return result

    for p in files:
        provides(p)

    problems = 0
    # 3) per-file usage check
    for path, src in files.items():
        imported_from = set()
        prefixes = set()
        for line in src.splitlines():
            m = import_re.match(line)
            if m:
                uri, prefix = m.group(1), m.group(2)
                if uri.startswith("dart:"):
                    continue
                target = resolve_path(path, uri, files)
                if prefix:
                    prefixes.add(prefix)
                if target:
                    prov = provides(target)
                    comb = parse_combinators(m.group(3), m.group(4)) if m.group(3) else None
                    if comb:
                        kind, names = comb
                        prov = (prov & names) if kind == "show" else (prov - names)
                    imported_from |= prov

        visible = imported_from | declared[path] | {"main"}
        clean = strip_noise(src)
        # drop import/export/part lines from scanning
        body = "\n".join(
            ln for ln in clean.splitlines()
            if not import_re.match(ln) and not export_re.match(ln)
            and not ln.strip().startswith("part ")
            and not ln.strip().startswith("part of ")
            and not re.match(r"^\s*(library)\b", ln)
        )
        flagged = {}
        for m in ident_re.finditer(body):
            name = m.group(0)
            start = m.start()
            if start > 0 and body[start - 1] == ".":  # member access / prefixed
                continue
            if name in visible or name in FRAMEWORK_NAMES:
                continue
            if not name[0].isupper():
                continue
            if name not in symbol_where:
                continue  # not a project symbol; can't tell (SDK/package)
            line_no = body[:start].count("\n") + 1
            flagged.setdefault(name, []).append((line_no, symbol_where[name]))

        for name, occ in sorted(flagged.items()):
            usable = [d for d in {d for _, ds in occ for d in ds}]
            lines = ", ".join(str(l) for l, _ in occ[:6])
            print(f"{path}:{lines}: '{name}' is NOT visible (defined in {', '.join(usable)}) "
                  f"-> missing import")
            problems += 1

    print(f"\nchecked {len(files)} files, {problems} missing-import problem(s)")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
