#!/usr/bin/env python3
"""Check one drafted learning against the format before it is stored.

    python3 check_learning.py <file>      (or the text on standard input)

Exit 0 when the learning has every required line, 1 when one is missing or
malformed. Lines past the word budget are reported as warnings.
"""
import re
import sys

REQUIRED = ("learned:", "impact:", "strategy:")
OPTIONAL = ("scope:", "also:")
WORD_BUDGET = 20
TITLE_WORDS = 10


def check(text):
    errors, warnings = [], []
    lines = [line.strip() for line in text.strip().splitlines() if line.strip()]
    if not lines:
        return ["the learning is empty"], []
    title, rest = lines[0], lines[1:]
    if any(title.lower().startswith(prefix) for prefix in REQUIRED + OPTIONAL):
        errors.append("the first line must be the title, an imperative rule")
    if len(title.split()) > TITLE_WORDS:
        warnings.append(f"the title has {len(title.split())} words; the budget is {TITLE_WORDS}")
    seen = {}
    for line in rest:
        prefix = next((p for p in REQUIRED + OPTIONAL if line.lower().startswith(p)), None)
        if prefix is None:
            errors.append(f"a line starts with no known field: {line[:40]}")
            continue
        if prefix in seen and prefix != "also:":
            errors.append(f"{prefix} appears twice")
        seen[prefix] = line[len(prefix):].strip()
        if len(line.split()) - 1 > WORD_BUDGET:
            warnings.append(f"{prefix} has {len(line.split()) - 1} words; the budget is {WORD_BUDGET}")
    for prefix in REQUIRED:
        if not seen.get(prefix):
            errors.append(f"{prefix} is missing")
    impact = seen.get("impact:", "")
    if impact and not re.search(r"confirmed=", impact):
        errors.append("impact: needs confirmed=<what was observed>")
    if impact and not re.search(r"suspected=\S", impact):
        errors.append("impact: needs suspected=<what is not verified, or none>")
    return errors, warnings


def main():
    text = open(sys.argv[1], encoding="utf-8").read() if len(sys.argv) > 1 else sys.stdin.read()
    errors, warnings = check(text)
    for warning in warnings:
        print(f"warning: {warning}")
    for error in errors:
        print(f"error: {error}")
    if not errors:
        print("the learning has every required line")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
