#!/usr/bin/env python3
"""Sorts each world's trail by what its fields ask, and re-declares the floors.

A world is not nine maps, it is nine questions in an order, and the order is what each field
asks: the gap between the best pen its budget holds and the pen a player gets by squaring the
map off. That number is measured rather than chosen, so when the measure moves the order has
to move with it — otherwise a player is handed a field gentler than the one they have just
beaten.

Two stops are not sorted. The last is the boss, which is where a world adds its own rule and
is measured against the other worlds' bosses rather than against its own fields. The one
before it is the world's widest board, which leaves a wide gap because it is broad rather
than because it is hard, and every world's prose says so. Everything before those climbs.

It rewrites the `nodes:` list in each world file, keeping the trail's drawn positions in
place — a node's `across` and `up` are where the signpost stands on the hillside, not which
level is on it — and rewrites the floors `DifficultyTests` declares to the measured minima.

    Tools/sort_trails.py            # say what would move
    Tools/sort_trails.py --write    # move it
"""

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from levels_index import levels  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DIFFICULTY = ROOT / "PigpenTests/DifficultyTests.swift"

# Each world, the file its trail is written in, and what `DifficultyTests` calls its floor.
TRAILS = [
    ("Mudlark Meadow", "WorldMap.swift", "mudlarkMeadow"),
    ("Thornwood Thicket", "Woodland.swift", "thornwoodThicket"),
    ("Emberpeak", "Emberpeak.swift", "emberpeak"),
    ("Cogsworth City", "Cogsworth.swift", "cogsworthCity"),
    ("Starfall Reaches", "Starfall.swift", "starfallReaches"),
    ("Gloamdeep Caverns", "Gloamdeep.swift", "gloamdeepCaverns"),
    ("Lantern Carnival", "Carnival.swift", "lanternCarnival"),
    ("Sunbaked Dunes", "Dunes.swift", "sunbakedDunes"),
    ("Tidepool Cove", "Tidepool.swift", "tidepoolCove"),
    ("Frostwhisker Tundra", "Frostwhisker.swift", "frostwhiskerTundra"),
    ("Mirebog Fen", "Mirebog.swift", "mirebogFen"),
    ("Cloudspire Heights", "Cloudspire.swift", "cloudspireHeights"),
]
# The meadow sorts only the stretch with nothing lying on the ground. Its last three change
# what is on the ground rather than what the wall has to do, and are ordered by what they
# scatter — apples, then skulls to build around as well, then a second animal.
SORTED_UPTO = {"Mudlark Meadow": 6}
# Everywhere else, the seven that climb; the widest board and the boss stay where they are.
CLIMB = 7
# The thicket is the one world that never claimed a climb — it is ordered by what it scatters
# rather than by what it asks, and no test holds it to a rising trail — so it is left alone.
UNSORTED = {"Thornwood Thicket"}

NODE = re.compile(r"WorldNode\(level: \.(?P<swift>\w+),(?P<rest>[^)]*)\)")


def demands():
    squared = dict(
        (swift, int(value))
        for swift, value in re.findall(
            r"Baseline\(level: \.(\w+), squaredOff: (\d+)", DIFFICULTY.read_text()
        )
    )
    found = {}
    for level in levels():
        if level["swift"] in squared:
            top = level["maximumScore"]
            found[level["swift"]] = (top - squared[level["swift"]]) * 100 // top
    return found


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Actually move them")
    options = parser.parse_args()

    asks = demands()
    byswift = {level["swift"]: level for level in levels()}
    floors = {}

    for name, source, world in TRAILS:
        path = ROOT / "Pigpen/Models" / source
        text = path.read_text()
        head, marker, tail = text.rpartition("nodes: [")
        chunk, close, rest = tail.partition("\n        ]")
        nodes = list(NODE.finditer(chunk))

        upto = 0 if name in UNSORTED else SORTED_UPTO.get(name, CLIMB)
        climbing = [node.group("swift") for node in nodes[:upto]]
        # Stable, so two fields that ask the same keep the order they were authored in and a
        # world already in order is left exactly as it stands.
        order = sorted(climbing, key=lambda swift: asks[swift])

        print(f"\n=== {name}")
        for spot, (was, now) in enumerate(zip(climbing, order), start=1):
            mark = "" if was == now else f"   <- was {byswift[was]['id']}"
            print(f"  {spot}. {byswift[now]['id']:22} {asks[now]:3}%{mark}")
        for node in nodes[upto:]:
            swift = node.group("swift")
            print(f"  {nodes.index(node) + 1}. {byswift[swift]['id']:22} {asks[swift]:3}%   (stays)")

        # The floor is the least any of the world's ordinary fields asks — the boss is held to
        # the other worlds' bosses instead.
        ordinary = [
            node.group("swift") for node in nodes if "starToll" not in node.group("rest")
        ]
        floors[world] = min(asks[swift] for swift in ordinary)

        if options.write:
            # Rebuilt in one pass, so a swap cannot eat its own replacement.
            pieces, spot = [], 0
            for index, node in enumerate(nodes):
                swift = order[index] if index < upto else node.group("swift")
                pieces.append(chunk[spot:node.start()])
                pieces.append(f"WorldNode(level: .{swift},{node.group('rest')})")
                spot = node.end()
            pieces.append(chunk[spot:])
            path.write_text(head + marker + "".join(pieces) + close + rest)

    print("\n=== floors")
    for name, _, world in TRAILS:
        print(f"  {name:20} {floors[world]}")
    ladder = [floors[world] for _, _, world in TRAILS]
    for index in range(1, len(ladder)):
        if ladder[index] <= ladder[index - 1]:
            print(f"  !! {TRAILS[index][0]} floors at {ladder[index]}, "
                  f"no higher than {TRAILS[index - 1][0]} at {ladder[index - 1]}")

    if options.write:
        text = DIFFICULTY.read_text()
        for _, _, world in TRAILS:
            text = re.sub(
                rf"Floor\(world: \.{world}, least: \d+\)",
                f"Floor(world: .{world}, least: {floors[world]})",
                text,
            )
        DIFFICULTY.write_text(text)
        print("\ntrails sorted and floors re-declared")


if __name__ == "__main__":
    main()
