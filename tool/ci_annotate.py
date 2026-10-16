#!/usr/bin/env python3
"""Publish a CI log's failure detail as chunked GitHub check annotations.

The raw Actions log backend is not always reachable from our tooling while
`repos/<owner>/<repo>/check-runs/<id>/annotations` is, so the interesting slice
of a failing check is re-emitted as `::error::` workflow commands. GitHub caps
the number of annotations a step may create, hence the chunking plus a compact
summary annotation first.

Usage: ci_annotate.py "<title>" <log-file>
"""
import re
import sys

ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
PROGRESS = re.compile(r"^\d{2}:\d{2} \+\d+")
INDEX_LINE = re.compile(r"(\[E\]\s*$|timed out|Some tests failed|Test failed\.)")
DETAIL_MARKER = re.compile(
    r"(EXCEPTION CAUGHT BY (?:FLUTTER TEST FRAMEWORK|RENDERING LIBRARY|WIDGETS LIBRARY)"
    r"|^Error:|^.*error •"
    r"|PathNotFoundException"
    r"|Deletion failed)"
)
MAX_ANNOTATIONS = 6
CHUNK = 7000
TAIL_CHARS = 6000


def escape(text):
    return text.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")


def emit(title, body):
    print(f"::error title={title}::{escape(body)}", flush=True)


def read_clean(path):
    raw = open(path, encoding="utf-8", errors="replace").read()
    return ANSI.sub("", raw)


def detail_blocks(lines):
    """Each failure block plus a few following lines (Expected/Actual/stack)."""
    blocks = []
    i, n = 0, len(lines)
    while i < n:
        if DETAIL_MARKER.search(lines[i]):
            block = [lines[i]]
            j = i + 1
            while j < n and len(block) < 34:
                nxt = lines[j]
                if DETAIL_MARKER.search(nxt) or (PROGRESS.match(nxt) and "[E]" not in nxt):
                    break
                block.append(nxt)
                j += 1
            blocks.append("\n".join(block))
            i = j
        else:
            i += 1
    return blocks


def main():
    title, path = sys.argv[1], sys.argv[2]
    raw = read_clean(path)
    lines = raw.splitlines()

    # 1) Index of every failing test — the part we must never lose.
    index_lines = [ln for ln in lines if INDEX_LINE.search(ln)]
    emit(
        f"{title} — failing index",
        f"{len(lines)} log lines, {len(index_lines)} failure markers\n\n"
        + ("\n".join(index_lines) or "(none)"),
    )

    # 2) The unique failing test names (whole-suite runs), so the complete list
    # survives even when the chunked detail is long.
    marker = "--- failing test names ---"
    if marker in lines:
        names = lines[lines.index(marker) + 1:]
        names = [ln for ln in names if ln.strip()]
        if names:
            emit(f"{title} — failing names ({len(names)})", "\n".join(names))

    # 2.5) Failure detail blocks (exception + Expected/Actual + stack), so a
    # red run is diagnosable from annotations alone, without raw logs.
    roots = []
    seen = set()
    for block in detail_blocks(lines):
        head = "\n".join(block.splitlines()[:10])
        if "Multiple exceptions (" in head:
            continue
        key = re.sub(r"\b\d+\b", "#", head)
        if key not in seen:
            seen.add(key)
            roots.append(block)
    if roots:
        summary = "\n\n".join("\n".join(block.splitlines()[:10]) for block in roots)
        emit(f"{title} — root causes ({len(roots)})", summary[:CHUNK])
    for number, block in enumerate(roots[:3], start=1):
        emit(f"{title} — detail [{number}]", block[:CHUNK])

    # 3) The whole log, head first (the expanded reporter prints each failure's
    # exception *before* the progress line that reports it) and the tail last
    # (that is where a hang stops). If the log is longer than the annotation
    # budget, the head and the tail win over the middle.
    # The end of the log is the most valuable part when something hangs, so it
    # gets its own annotation; the remaining budget is spent on the head.
    emit(f"{title} — tail", raw[-TAIL_CHARS:])

    chunks = [raw[i:i + CHUNK] for i in range(0, len(raw), CHUNK)] or [""]
    skipped = 0
    if len(chunks) > 2:
        skipped = len(chunks) - 2
        chunks = chunks[:2]
    for number, chunk in enumerate(chunks, start=1):
        emit(f"{title} — log [{number}/{len(chunks)}]" + (f" (+{skipped} more)" if skipped and number == 1 else ""), chunk)


if __name__ == "__main__":
    main()
