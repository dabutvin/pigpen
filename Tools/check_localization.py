#!/usr/bin/env python3
"""Checks the string catalog against the words the game actually says.

Xcode will tell you a catalog is missing a translation, on a Mac, after a build, in
a pane. This says the same thing on any machine in a second, which is what a pull
request needs — and it says three more things Xcode does not:

  * every key the source asks for is in the catalog, so nothing falls back to
    English because somebody wrote a new line and forgot the catalog;
  * every key in the catalog is still asked for, so a line that was rewritten does
    not leave its translations behind to be kept forever;
  * every translation's format specifiers line up with the key's, so a translator
    cannot turn %lld into %@ and take a screen down with it.

A translation may use *fewer* arguments than the key gives it — a language that
says "his pen" where English says "the croc's pen" is a better translation, not a
broken one — so a dropped argument passes. Anything the key cannot supply fails.

Usage: python3 Tools/check_localization.py [--catalog PATH] [--sources DIR]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

# The languages the game ships in. A catalog with a language not on this list, or
# missing one that is, is a mistake in one place or the other.
LANGUAGES = ["en", "ru"]
SOURCE_LANGUAGE = "en"

# Where a localizable literal can appear. SwiftUI localises a bare literal handed to
# any of these for free, so they are as much a part of the catalog's key set as an
# explicit String(localized:) is.
SWIFTUI_CALLS = [
    r'Text\(',
    r'Label\(',
    r'Button\(',
    r'\.alert\(',
    r'\.accessibilityLabel\(',
    r'\.accessibilityHint\(',
    r'\.accessibilityValue\(',
    r'\.accessibilityAction\(named: ',
]

# A number goes into a format string as %lld and everything else as %@. Nothing here
# reads Swift well enough to know which is which, so the catalog is trusted for the
# specifier and this only checks that the *shape* matches: as many holes, in the same
# order. A specifier of the wrong kind shows up as a key the source never asks for.
HOLE = ""
SPECIFIER = re.compile(r"%(?:\d+\$)?(?:lld|ld|d|@|lf|f)")


def swift_files(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob("*.swift"))


def strip_comments_and_previews(text: str) -> str:
    """Drops what a build would not localise: comments, and the #Preview blocks whose
    made-up level names and captions are scaffolding rather than the game speaking."""
    out = []
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("//"):
            continue
        out.append(line)
    text = "\n".join(out)
    return re.sub(r"#Preview(?:\([^)]*\))?\s*\{", "#Preview {", text)


def previews_removed(text: str) -> str:
    """Everything from the first #Preview to the end of the file. They are always last
    in this codebase, and a brace counter would be the only other way to find them."""
    at = text.find("#Preview")
    return text[:at] if at >= 0 else text


def skip_space(text: str, at: int) -> int:
    """Past any whitespace, because a long literal is written on the line under the call
    that takes it."""
    while at < len(text) and text[at] in " \t\n":
        at += 1
    return at


def read_literal(text: str, at: int) -> tuple[str | None, int]:
    """Reads the Swift string literal starting at `at`, single- or triple-quoted, and
    returns it with its interpolations collapsed to holes."""
    at = skip_space(text, at)
    if at >= len(text):
        return None, at
    if text.startswith('"""', at):
        end = text.find('"""', at + 3)
        if end < 0:
            return None, at
        body = text[at + 3:end]
        # A multiline literal is written indented under its opening quotes; the closing
        # quotes say how far. A backslash at the end of a line joins it to the next.
        closing = text.rfind("\n", 0, end)
        indent = len(text[closing + 1:end])
        lines = [line[indent:] if line[:indent].isspace() else line.lstrip()
                 for line in body.split("\n")]
        joined = "\n".join(lines).strip("\n")
        joined = re.sub(r"\\\n", "", joined)
        return collapse(joined), end + 3

    if text[at] != '"':
        return None, at
    index = at + 1
    depth = 0
    while index < len(text):
        char = text[index]
        if char == "\\" and depth == 0 and text[index + 1:index + 2] == "(":
            depth = 1
            index += 2
            continue
        if depth:
            if char == "(":
                depth += 1
            elif char == ")":
                depth -= 1
            index += 1
            continue
        if char == "\\":
            index += 2
            continue
        if char == '"':
            return collapse(text[at + 1:index]), index + 1
        if char == "\n":
            return None, at
        index += 1
    return None, at


ESCAPES = {"n": "\n", "t": "\t", "r": "\r", "0": "\0", "\\": "\\", '"': '"', "'": "'"}


def collapse(literal: str) -> str:
    """Turns `\\(anything)` into a hole and unescapes the rest, so what comes back is the
    string the runtime will look the catalog up with rather than the source spelling of it."""
    out = []
    index = 0
    while index < len(literal):
        if literal.startswith("\\(", index):
            depth = 1
            index += 2
            while index < len(literal) and depth:
                if literal[index] == "(":
                    depth += 1
                elif literal[index] == ")":
                    depth -= 1
                index += 1
            out.append(HOLE)
            continue
        if literal[index] == "\\" and index + 1 < len(literal):
            out.append(ESCAPES.get(literal[index + 1], literal[index + 1]))
            index += 2
            continue
        out.append(literal[index])
        index += 1
    return "".join(out)


def first_argument(text: str, at: int) -> int:
    """Where the first argument of a call beginning at `at` ends: the top-level comma
    that starts the second one, or the paren that closes the call."""
    depth = 0
    index = at
    while index < len(text):
        char = text[index]
        if char in "([{":
            depth += 1
        elif char in ")]}":
            if depth == 0:
                return index
            depth -= 1
        elif char == "," and depth == 0:
            return index
        elif char == '"':
            _, index = read_literal(text, index)
            continue
        index += 1
    return len(text)


def literals_in(text: str, at: int, end: int) -> list[str]:
    """Every string literal in one argument expression.

    Usually there is one, and it is the whole argument. There is more than one when the
    argument chooses between them — `Text(finished ? "Play" : "Continue")` — and both are
    keys the catalog has to carry, which is the whole reason this does not simply read the
    literal sitting after the bracket.

    A `String(localized:)` nested inside is skipped: its key is found by the pass that
    looks for those, and the default value beside it is not a key at all.
    """
    found = []
    index = at
    while index < end:
        nested = re.compile(r'String\(localized:').match(text, index)
        if nested:
            index = first_argument(text, nested.end())
            while index < end and text[index] != ")":
                index += 1
            index += 1
            continue
        if text[index] == '"':
            literal, after = read_literal(text, index)
            if literal is not None:
                # `worn ? "Worn" : ""` has one phrase in it and one absence of one.
                if literal:
                    found.append(literal)
                index = after
                continue
        index += 1
    return found


def shape(text: str) -> str:
    """A format string with its specifiers reduced to holes, for comparing with a
    literal read out of the source."""
    return SPECIFIER.sub(HOLE, text)


def keys_in_source(root: Path) -> tuple[dict[str, list[str]], set[str]]:
    """Every key the game asks for, mapped to the shapes of the literals behind it.

    A key is what goes in front of the lookup: the symbolic name where
    String(localized:defaultValue:) gives one, and the English text itself everywhere
    else — which is what SwiftUI does with a bare literal, and what Xcode writes into
    the catalog when it extracts one. The symbolic ones come back in their own set,
    because they are the only keys whose English is allowed to read differently from
    the key.
    """
    found: dict[str, list[str]] = {}
    symbolic: set[str] = set()

    def note(key: str, shape_of_value: str) -> None:
        found.setdefault(key, [])
        if shape_of_value not in found[key]:
            found[key].append(shape_of_value)

    explicit = re.compile(r'String\(localized:\s*')
    default = re.compile(r'\s*,\s*defaultValue:\s*')
    swiftui = re.compile("|".join(SWIFTUI_CALLS))

    for path in swift_files(root):
        text = previews_removed(strip_comments_and_previews(path.read_text()))

        for match in explicit.finditer(text):
            literal, after = read_literal(text, match.end())
            if literal is None:
                continue
            following = default.match(text, after)
            if following:
                value, _ = read_literal(text, following.end())
                if value is not None:
                    note(literal, shape(value))
                    symbolic.add(literal)
                    continue
            note(literal, shape(literal))

        for match in swiftui.finditer(text):
            at = skip_space(text, match.end())
            # Text(verbatim:) is a number or a mark, never a phrase.
            if text.startswith("verbatim:", at):
                continue
            for literal in literals_in(text, at, first_argument(text, at)):
                note(literal, shape(literal))

    return found, symbolic


def catalog_strings(catalog: dict) -> dict:
    return catalog.get("strings", {})


def plural_branches(entry: dict, language: str) -> list[tuple[str, str]]:
    """Every branch of every plural this language has for one key, as (category, value)."""
    localization = entry.get("localizations", {}).get(language)
    if not localization:
        return []
    out = []

    def walk(node: dict) -> None:
        for variations in node.get("variations", {}).values():
            for category, branch in variations.items():
                if "stringUnit" in branch:
                    out.append((category, branch["stringUnit"].get("value", "")))
                walk(branch)

    walk(localization)
    for substitution in localization.get("substitutions", {}).values():
        walk(substitution)
    return out


def values_of(entry: dict, language: str) -> list[str]:
    """Every string a language can produce for one key: the plain one, or all the
    branches of a plural, and the same again for each substitution it carries."""
    localization = entry.get("localizations", {}).get(language)
    if not localization:
        return []
    out = []

    def walk(node: dict) -> None:
        if "stringUnit" in node:
            out.append(node["stringUnit"].get("value", ""))
        for variations in node.get("variations", {}).values():
            for branch in variations.values():
                walk(branch)

    walk(localization)
    for substitution in localization.get("substitutions", {}).values():
        walk(substitution)
    return out


def specifiers(text: str) -> list[str]:
    return [m.group(0) for m in SPECIFIER.finditer(text)]


def kind(specifier: str) -> str:
    return re.sub(r"^%(?:\d+\$)?", "", specifier)


def stray_percents(text: str) -> list[str]:
    """Every % in a format string that is not the start of a specifier and not written
    out as %%.

    A localised string with arguments in it is handed to the formatter, and a loose %
    there is read as the beginning of a conversion: "%lld% complete" is not five per cent
    complete, it is a specifier nobody passed an argument for. English shows it first,
    but it is the kind of thing a translator adds long after anybody is looking.
    """
    loose = []
    at = 0
    while at < len(text):
        if text[at] != "%":
            at += 1
            continue
        if text.startswith("%%", at):
            at += 2
            continue
        match = SPECIFIER.match(text, at)
        if match:
            at = match.end()
            continue
        loose.append(text[at:at + 12])
        at += 1
    return loose


def check(catalog_path: Path, sources: Path) -> list[str]:
    problems: list[str] = []
    catalog = json.loads(catalog_path.read_text())

    if catalog.get("sourceLanguage") != SOURCE_LANGUAGE:
        problems.append(f"catalog source language is {catalog.get('sourceLanguage')!r}, "
                        f"expected {SOURCE_LANGUAGE!r}")

    asked, symbolic = keys_in_source(sources)

    # A key is matched by its shape rather than letter for letter, because the source
    # writes `\(stars)` where the catalog writes `%lld`. Two catalog keys that differ
    # only in the kind of specifier would land on the same shape, which is worth saying
    # out loud: one of them is a key nothing will ever look up.
    entries: dict[str, tuple[str, dict]] = {}
    for key, entry in catalog_strings(catalog).items():
        shaped = shape(key)
        if shaped in entries:
            problems.append(f"{key!r} and {entries[shaped][0]!r} are the same key "
                            f"but for their specifiers")
            continue
        entries[shaped] = (key, entry)

    for shaped in sorted(set(asked) - set(entries)):
        problems.append(f"missing from the catalog: {readable(shaped)!r}")
    for shaped in sorted(set(entries) - set(asked)):
        problems.append(f"in the catalog and asked for nowhere: {entries[shaped][0]!r}")

    for shaped in sorted(set(asked) & set(entries)):
        key, entry = entries[shaped]
        english = values_of(entry, SOURCE_LANGUAGE)
        if not english:
            problems.append(f"{key!r}: no English in the catalog")
            continue

        # The English in the catalog is what the source says. It is allowed to use fewer
        # arguments than the source hands it — the caption under a figure says "best pens"
        # and lets the figure above it do the counting — but never more, and never a whole
        # different sentence, which would mean the source had been rewritten around it.
        shapes = set(asked[shaped])
        holes = max(value.count(HOLE) for value in shapes)
        if len(specifiers(english[0])) > holes:
            problems.append(f"{key!r}: English reads {english[0]!r}, which asks for more "
                            f"than the source hands it")
        elif shaped not in symbolic and not any(shape(value) in shapes for value in english):
            problems.append(f"{key!r}: English reads {english[0]!r}, which is not what "
                            f"the source says")

        # What the key can hand over is what the English format asks for — which for a
        # symbolic key is written in the English value rather than in the key itself.
        # `xcstringstool` refuses a plural whose branches do not print the number they
        # count — a caption that says "best pens" under a figure that says 3 has to be two
        # strings chosen in code, not one string with two endings. It refuses it at build
        # time, on a Mac, after everything else has compiled; this says it here.
        for language in LANGUAGES:
            for category, value in plural_branches(entry, language):
                if not specifiers(value):
                    problems.append(
                        f"{key!r}: the {language} plural's {category!r} reads {value!r}, "
                        f"which never says the number it counts"
                    )
                    break

        allowed = {kind(s) for s in specifiers(english[0])}
        if allowed:
            for loose in stray_percents(key):
                problems.append(f"{key!r}: the key has a loose percent at {loose!r}")
                break
        for language in LANGUAGES:
            translations = values_of(entry, language)
            if not translations:
                problems.append(f"{key!r}: no {language}")
                continue
            for value in translations:
                wrong = [s for s in specifiers(value) if kind(s) not in allowed]
                if wrong:
                    problems.append(
                        f"{key!r}: {language} uses {wrong[0]}, which the key cannot supply"
                    )
                    break
                if allowed and stray_percents(value):
                    problems.append(
                        f"{key!r}: {language} has a loose percent at "
                        f"{stray_percents(value)[0]!r}"
                    )
                    break

    return problems


def readable(shaped: str) -> str:
    """A shape with its holes drawn, for an error a person has to read."""
    return shaped.replace(HOLE, "{}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path,
                        default=Path("Pigpen/Resources/Localizable.xcstrings"))
    parser.add_argument("--sources", type=Path, default=Path("Pigpen"))
    args = parser.parse_args()

    problems = check(args.catalog, args.sources)
    if problems:
        print(f"{len(problems)} problem(s) with {args.catalog}:", file=sys.stderr)
        for problem in problems:
            print(f"  {problem}", file=sys.stderr)
        return 1

    catalog = json.loads(args.catalog.read_text())
    print(f"{len(catalog_strings(catalog))} strings, "
          f"{len(LANGUAGES) - 1} languages besides English, all present.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
