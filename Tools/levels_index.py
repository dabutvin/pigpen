#!/usr/bin/env python3
"""Reads every authored level out of the Swift sources.

`PuzzleLevel` and each world file spell their levels out as calls to an `authored`-style
helper — a budget, three scores, a question and an ASCII map — and several tools want to
walk the whole shipped set rather than one map pasted in by hand: re-searching every board
after a rule change, checking a star threshold, sweeping for maps a change has broken.

Each level comes back as a dict of the arguments as written, with `rule` already worked out
from the question, so it can be handed straight to `level_search.search`.
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCES = [
    ROOT / "Pigpen/Models/PuzzleLevel.swift",
    ROOT / "Pigpen/Models/Woodland.swift",
    ROOT / "Pigpen/Models/Emberpeak.swift",
    ROOT / "Pigpen/Models/Cogsworth.swift",
    ROOT / "Pigpen/Models/Starfall.swift",
    ROOT / "Pigpen/Models/Gloamdeep.swift",
    ROOT / "Pigpen/Models/Carnival.swift",
    ROOT / "Pigpen/Models/Dunes.swift",
]

# The questions that name a rule of their own. Every other question is an ordinary board,
# which the search calls `herd` whether there is a second animal on it or not.
BOSSLY = ("apart", "exclude", "together", "even", "roost", "ring", "berth", "herd")

CALL = re.compile(
    r"static let (?P<name>\w+) = \w+\(\n(?P<body>.*?)\n    \)\n",
    re.DOTALL,
)
FIELD = re.compile(r'^\s*(\w+): (.*?),?$', re.MULTILINE)


def levels():
    """Every authored level in the game, in the order the sources write them down."""
    found = []
    for source in SOURCES:
        text = source.read_text()
        for call in CALL.finditer(text):
            body = call.group("body")
            head, _, tail = body.partition('map: """\n')
            if not tail:
                continue
            level = {"swift": call.group("name"), "source": source.name}
            for field in FIELD.finditer(head):
                name, written = field.group(1), field.group(2).strip().rstrip(",")
                if written.startswith('"'):
                    level[name] = written.strip('"')
                elif written.startswith("."):
                    level[name] = written[1:]
                else:
                    level[name] = int(written)
            rows = [line.strip() for line in tail.split("\n") if line.strip() not in ('"""', "")]
            level["map"] = "\n".join(rows)
            question = level.get("question")
            level["rule"] = question if question in BOSSLY else "herd"
            found.append(level)
    return found


if __name__ == "__main__":
    for level in levels():
        print(f"{level['source']:18} {level['id']:22} budget={level['fenceBudget']:3} "
              f"max={level['maximumScore']:3} rule={level['rule']}")
