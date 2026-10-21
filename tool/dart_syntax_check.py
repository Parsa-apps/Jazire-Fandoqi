#!/usr/bin/env python3
"""Dart syntax + hygiene gate used when the Flutter SDK is unavailable.

WHY THIS EXISTS
---------------
`flutter analyze` / `dart format` / `flutter test` need a Dart + Flutter SDK.
On a locked-down build machine (or a CI runner without network access to
``storage.googleapis.com``) that SDK simply cannot be installed. This script is
a *fallback*, not a replacement: it parses every Dart file with a real
tree-sitter Dart grammar, so genuine syntax errors (unbalanced braces, broken
argument lists, malformed generics, stray tokens, truncated files) fail the
build instead of shipping.

It deliberately does NOT claim to do what only the analyzer can do:
  * no type checking / no undefined-identifier detection
  * no lints, no formatting verification
When the real SDK is present, run `flutter analyze` and `flutter test` instead.

USAGE
-----
    python3 tool/dart_syntax_check.py                 # check lib/ and test/
    python3 tool/dart_syntax_check.py lib/features    # check a subtree
    python3 tool/dart_syntax_check.py --strict         # hygiene checks too

GRAMMAR SOURCE
--------------
The Dart grammar is not vendored in this repository (it is ~3 MB of generated
C). The script builds it on demand:

    git clone --depth 1 https://github.com/UserNobody14/tree-sitter-dart.git \\
        /tmp/tree-sitter-dart
    export TREE_SITTER_DART_SRC=/tmp/tree-sitter-dart

Requirements: ``gcc`` and ``pip install "tree-sitter>=0.25"``.
If the grammar cannot be obtained the script exits with code 2 and says so —
it never silently "passes" a file it could not actually parse.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CACHE_SO = Path(
    os.environ.get("TREE_SITTER_DART_SO", "/tmp/tree_sitter_dart.so")
)
GRAMMAR_SRC = Path(
    os.environ.get("TREE_SITTER_DART_SRC", "/tmp/tree-sitter-dart")
)

DEFAULT_TARGETS = ("lib", "test")

# Markers that must never survive into a shipped build.
HYGIENE_PATTERNS: tuple[tuple[str, re.Pattern[str]], ...] = (
    ("TODO marker", re.compile(r"\bTODO\b")),
    ("FIXME marker", re.compile(r"\bFIXME\b")),
    ("XXX marker", re.compile(r"\bXXX\b")),
    ("dart:mirrors import", re.compile(r"import\s+['\"]dart:mirrors['\"]")),
)


def _load_grammar():
    """Return a tree_sitter.Parser bound to the Dart grammar."""
    try:
        from ctypes import CDLL, c_void_p

        from tree_sitter import Language, Parser
    except ImportError as exc:  # pragma: no cover - environment problem
        print(f"FATAL: python package 'tree-sitter' missing ({exc}).")
        print('       Install it with: pip install "tree-sitter>=0.25"')
        raise SystemExit(2) from exc

    if not CACHE_SO.exists():
        if not (GRAMMAR_SRC / "src" / "parser.c").exists():
            print("FATAL: Dart grammar source not available.")
            print(f"       Expected: {GRAMMAR_SRC / 'src' / 'parser.c'}")
            print("       Clone it with:")
            print(
                "         git clone --depth 1 "
                "https://github.com/UserNobody14/tree-sitter-dart.git "
                f"{GRAMMAR_SRC}"
            )
            print("       (or point TREE_SITTER_DART_SRC at an existing clone)")
            raise SystemExit(2)
        build_grammar(str(GRAMMAR_SRC), str(CACHE_SO))

    lib = CDLL(str(CACHE_SO))
    entry = lib.tree_sitter_dart
    entry.restype = c_void_p
    return Parser(Language(entry()))


def build_grammar(src: str, out: str) -> None:
    """Compile the tree-sitter Dart grammar into a shared object."""
    cmd = [
        os.environ.get("CC", "gcc"),
        "-fPIC",
        "-shared",
        "-O2",
        "-I",
        os.path.join(src, "src"),
        os.path.join(src, "src", "parser.c"),
        os.path.join(src, "src", "scanner.c"),
        "-o",
        out,
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        print("FATAL: could not compile the Dart grammar:")
        print(proc.stderr)
        raise SystemExit(2)


def _walk(node, out: list, want_error: bool) -> None:
    """Depth-first walk collecting ERROR/MISSING nodes (bounded)."""
    stack = [node]
    while stack and len(out) < 25:
        current = stack.pop()
        kind = current.type
        if want_error and (kind == "ERROR" or kind == "MISSING"):
            out.append(current)
        # `children` is the stable public attribute; fall back to manual walk.
        stack.extend(reversed(list(current.children)))


def check_file(parser, path: Path) -> list[str]:
    """Parse one Dart file. Returns a list of human-readable problems."""
    raw = path.read_bytes()
    tree = parser.parse(raw)
    problems: list[str] = []
    if tree.root_node.has_error:
        bad: list = []
        _walk(tree.root_node, bad, want_error=True)
        for node in bad[:5]:
            start = node.start_point
            line = start[0] + 1
            col = start[1] + 1
            snippet = raw.decode("utf-8", "replace").splitlines()
            text = snippet[start[0]].strip() if start[0] < len(snippet) else ""
            problems.append(
                f"{path.relative_to(REPO_ROOT)}:{line}:{col} "
                f"<{node.type}> {text[:90]}"
            )
        if not problems:
            problems.append(f"{path.relative_to(REPO_ROOT)}: unparsable Dart")
    return problems


def hygiene_file(path: Path) -> list[str]:
    """Report placeholder markers left in shipped source."""
    text = path.read_text(encoding="utf-8", errors="replace")
    problems: list[str] = []
    for label, pattern in HYGIENE_PATTERNS:
        for match in pattern.finditer(text):
            line = text.count("\n", 0, match.start()) + 1
            problems.append(
                f"{path.relative_to(REPO_ROOT)}:{line} {label}"
            )
    return problems


def collect(targets: list[str]) -> list[Path]:
    files: list[Path] = []
    for raw in targets:
        base = (REPO_ROOT / raw).resolve()
        if base.is_file():
            files.append(base)
            continue
        if not base.exists():
            print(f"WARNING: skipped missing path {raw}")
            continue
        files.extend(
            p
            for p in base.rglob("*.dart")
            if ".dart_tool" not in p.parts and "build" not in p.parts
        )
    return sorted(set(files))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "targets",
        nargs="*",
        default=list(DEFAULT_TARGETS),
        help="files or directories to check (default: lib test)",
    )
    ap.add_argument(
        "--strict",
        action="store_true",
        help="also fail on TODO/FIXME/placeholder markers",
    )
    args = ap.parse_args()

    parser = _load_grammar()
    files = collect(args.targets)
    if not files:
        print("FATAL: no Dart files found to check.")
        return 2

    problems: list[str] = []
    for path in files:
        problems.extend(check_file(parser, path))
        if args.strict:
            problems.extend(hygiene_file(path))

    print(f"Parsed {len(files)} Dart file(s) with tree-sitter-dart.")
    if problems:
        print(f"\n{len(problems)} problem(s):")
        for item in problems:
            print(f"  - {item}")
        return 1

    print("OK: every file parses as valid Dart syntax.")
    if not args.strict:
        print("    (run with --strict to also fail on TODO/FIXME markers)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
