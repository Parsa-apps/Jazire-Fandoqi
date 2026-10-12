#!/usr/bin/env python3
"""Publish a test log's failure detail as chunked GitHub check annotations.

Temporary diagnostic helper: the raw Actions log backend is not reachable from
our tooling, while `check-runs/<id>/annotations` is, so the interesting slice of
the log is re-emitted as `::error::` workflow commands (GitHub caps annotations
per step, hence the chunking).
"""
import re
import sys

ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
PROGRESS = re.compile(r"^\d{2}:\d{2} \+\d+")
MAX_CHUNKS = 8
CHUNK = 3800


def failure_blocks(lines):
    blocks = []
    i, n = 0, len(lines)
    while i < n:
        line = lines[i]
        is_marker = (
            "EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK" in line
            or line.rstrip().endswith("[E]")
        )
        if is_marker:
            block = [line]
            j = i + 1
            while j < n and len(block) < 40:
                nxt = lines[j]
                if PROGRESS.match(nxt) and "[E]" not in nxt:
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
    raw = ANSI.sub("", open(path, encoding="utf-8", errors="replace").read())
    lines = raw.splitlines()

    parts = failure_blocks(lines)
    tail = "\n".join(lines[-25:])
    body = "\n\n".join(parts) if parts else raw
    body = body + "\n\n--- tail ---\n" + tail

    chunks = [body[i:i + CHUNK] for i in range(0, len(body), CHUNK)] or [""]
    total = len(chunks)
    for index, chunk in enumerate(chunks[:MAX_CHUNKS], start=1):
        escaped = chunk.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
        print(f"::error title={title} [{index}/{total}]::{escaped}", flush=True)


if __name__ == "__main__":
    main()
