#!/usr/bin/env python3
"""Parse `flutter test --machine` (JSON) output and emit one GitHub Actions
error annotation per failed test, so the full failure text stays readable
even when raw Actions logs are unavailable.

For `testWidgets` failures, package:test often reports only
"Test failed. See exception logs above." in the error event — the real
exception text arrives via `print` events, so those are included too.

Temporary diagnostic helper for the v7 test triage.
"""

import json
import sys

MAX_ANNOTATIONS = 10
MAX_MESSAGE_CHARS = 6000
MAX_STACK_LINES = 25
MAX_PRINT_CHARS = 3500


def _escape(message: str) -> str:
    return message.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else 'machine_output.jsonl'
    events = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line.startswith('{'):
                continue
            try:
                events.append(json.loads(line))
            except json.JSONDecodeError:
                continue

    names = {}
    for event in events:
        if event.get('type') == 'testStart':
            test = event.get('test') or {}
            names[test.get('id')] = test.get('name') or 'unnamed test'

    errors = {}   # testID -> [(error, stack), ...]
    prints = {}   # testID -> [message, ...]
    for event in events:
        kind = event.get('type')
        if kind == 'error':
            test_id = event.get('testID')
            if test_id is None:
                continue
            errors.setdefault(test_id, []).append(
                (str(event.get('error') or '(no error message)'),
                 str(event.get('stackTrace') or ''))
            )
        elif kind == 'print':
            test_id = event.get('testID')
            if test_id is None:
                continue
            prints.setdefault(test_id, []).append(str(event.get('message') or ''))

    if not errors:
        print('::error title=No parsed failures::The machine log contained no error events.')
        return 0

    emitted = 0
    for test_id, error_list in errors.items():
        if emitted >= MAX_ANNOTATIONS:
            print(f'::error title=Annotation cap reached::{len(errors) - emitted} more failed tests not annotated')
            break
        name = names.get(test_id, f'test {test_id}')
        parts = []
        for error, stack in error_list:
            parts.append(error)
            stack_lines = [line for line in stack.splitlines() if line.strip()]
            if stack_lines:
                parts.append('\n'.join(stack_lines[:MAX_STACK_LINES]))
        printed = '\n'.join(prints.get(test_id, []))
        if printed.strip():
            parts.append('---- printed output ----\n' + printed[:MAX_PRINT_CHARS])
        message = ('\n\n----\n\n'.join(parts))[:MAX_MESSAGE_CHARS]
        title = name if len(name) <= 200 else name[:197] + '...'
        print(f'::error title={_escape(title)}::{_escape(message)}')
        emitted += 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
