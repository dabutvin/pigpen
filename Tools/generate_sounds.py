#!/usr/bin/env python3
"""Make every noise the game makes, and write each one out as a WAV the app can play.

Nothing in the game is recorded. Every sound is a few oscillators and an envelope, the way
the icon is a few shapes and the wordmark a few numbers, so a sound can be tuned by editing a
figure here and running the script again rather than by finding somebody with a microphone
and a fence. The Swift side — `Sound` in `Pigpen/Views/Sounds.swift` — names each one and
plays the file named after it, and `SoundsTests` checks that every case has a file to play.

The instruments are deliberately plain. A knock is a sine wave dropping in pitch under a
short burst of noise; a jingle is a run of triangle waves each with its own decay; a wilt is
a soft sawtooth sliding downwards with a wobble on it. The whole point is that they sit
under a game played on a train, and that nothing here sounds like it is trying to.

Usage:
    python3 Tools/generate_sounds.py

Writes one file per sound into Pigpen/Resources/Sounds/, and the music — a sixteen-bar
waltz that loops without a seam — into Pigpen/Resources/Music/. Commit the WAVs — the build
reads them, not the script. Only the standard library is needed.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "Pigpen/Resources/Sounds"
MUSIC = ROOT / "Pigpen/Resources/Music/meadow-waltz.wav"

RATE = 44_100
TAU = 2 * math.pi

# Note names, for the jingles. Concert pitch, equal temperament, nothing fancy.
NOTES = {
    "C3": 130.81, "D3": 146.83, "E3": 164.81, "F3": 174.61, "G3": 196.00, "A3": 220.00,
    "B3": 246.94, "C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23, "G4": 392.00,
    "A4": 440.00, "B4": 493.88,
    "C5": 523.25, "D5": 587.33, "E5": 659.25, "F5": 698.46, "G5": 783.99, "A5": 880.00,
    "B5": 987.77,
    "C6": 1046.50, "D6": 1174.66, "E6": 1318.51, "G6": 1567.98, "C7": 2093.00,
}


# MARK: - Instruments

def samples(seconds: float) -> int:
    return int(round(seconds * RATE))


def silence(seconds: float) -> list[float]:
    return [0.0] * samples(seconds)


def wave_at(shape: str, phase: float) -> float:
    """One sample of one of the four shapes, at a phase in radians."""
    x = math.sin(phase)
    if shape == "sine":
        return x
    if shape == "triangle":
        return (2 / math.pi) * math.asin(x)
    if shape == "soft-square":
        # A square with its corners knocked off, so it reads as a hum rather than a buzz.
        return math.tanh(3 * x)
    if shape == "soft-saw":
        # The first six harmonics of a sawtooth and no more, which keeps it warm.
        return sum(math.sin(k * phase) / k for k in range(1, 7)) * 0.6
    raise ValueError(shape)


def tone(
    freq: float,
    seconds: float,
    shape: str = "sine",
    glide_to: float | None = None,
    vibrato: tuple[float, float] = (0.0, 0.0),
) -> list[float]:
    """A steady note, or one that slides from `freq` to `glide_to` over its length.

    `vibrato` is (depth as a share of the pitch, rate in hertz).
    """
    depth, rate = vibrato
    count = samples(seconds)
    out = []
    phase = 0.0
    for i in range(count):
        t = i / RATE
        u = i / max(count - 1, 1)
        f = freq if glide_to is None else freq * (glide_to / freq) ** u
        if depth:
            f *= 1 + depth * math.sin(TAU * rate * t)
        phase += TAU * f / RATE
        out.append(wave_at(shape, phase))
    return out


def noise(seconds: float, seed: int, lowpass: float = 0.0) -> list[float]:
    """White noise, or with `lowpass` in (0, 1) the same run through a one-pole filter — the
    higher the figure, the duller the hiss. Seeded, so the file comes out the same every run."""
    rng = random.Random(seed)
    out = []
    last = 0.0
    for _ in range(samples(seconds)):
        raw = rng.uniform(-1.0, 1.0)
        last = lowpass * last + (1 - lowpass) * raw
        out.append(last)
    return out


def shaped(
    track: list[float],
    attack: float = 0.004,
    decay: float = 0.1,
    floor: float = 0.0,
    release: float = 0.015,
) -> list[float]:
    """Puts an envelope on a track: a straight ramp up over `attack`, an exponential fall
    towards `floor` with a time constant of `decay`, and a straight fade to nothing over the
    last `release` seconds so that nothing ends with a click."""
    count = len(track)
    out = []
    for i, sample in enumerate(track):
        t = i / RATE
        if t < attack:
            level = t / attack
        else:
            level = floor + (1 - floor) * math.exp(-(t - attack) / decay)
        remaining = (count - 1 - i) / RATE
        if remaining < release:
            level *= remaining / release
        out.append(sample * level)
    return out


def gain(track: list[float], amount: float) -> list[float]:
    return [s * amount for s in track]


def layered(*parts: tuple[list[float], float]) -> list[float]:
    """Mixes tracks, each placed at an offset in seconds."""
    length = max(samples(at) + len(track) for track, at in parts)
    out = [0.0] * length
    for track, at in parts:
        start = samples(at)
        for i, s in enumerate(track):
            out[start + i] += s
    return out


def normalised(track: list[float], peak: float) -> list[float]:
    loudest = max(abs(s) for s in track) or 1.0
    return [s * peak / loudest for s in track]


def halved(track: list[float]) -> list[float]:
    """The same track at half the sample rate, each pair of samples averaged. The music is
    written this way: it is a minute long, nothing in it goes above what half the rate can
    carry, and a file half the size is a repository half as heavy."""
    return [(track[i] + track[i + 1]) / 2 for i in range(0, len(track) - 1, 2)]


def write(path: Path, track: list[float], rate: int = RATE) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in track
        )
        out.writeframes(frames)
    print(f"{path.relative_to(ROOT)}  {len(track) / rate:.2f}s")


# MARK: - The sounds

def fence_in() -> list[float]:
    """A post going into the ground: a low knock with the wood in it."""
    knock = shaped(tone(190, 0.14, glide_to=140), attack=0.002, decay=0.035)
    ring = shaped(tone(380, 0.08, glide_to=300), attack=0.002, decay=0.018)
    thock = shaped(noise(0.025, seed=1, lowpass=0.85), attack=0.001, decay=0.006)
    return normalised(layered((knock, 0), (gain(ring, 0.3), 0), (gain(thock, 0.7), 0)), 0.85)


def fence_out() -> list[float]:
    """A piece pulled back up: the same knock turned over, quicker and rising."""
    pop = shaped(tone(420, 0.09, glide_to=680), attack=0.002, decay=0.028)
    tick = shaped(noise(0.012, seed=2, lowpass=0.6), attack=0.001, decay=0.004)
    return normalised(layered((pop, 0), (gain(tick, 0.4), 0)), 0.6)


def refusal() -> list[float]:
    """The field saying no: two low hums a beat apart, the second the same as the first,
    which is the sound of a rack being shaken rather than a buzzer going off."""
    def hum() -> list[float]:
        low = tone(118, 0.11, shape="soft-square")
        beat = tone(123, 0.11, shape="soft-square")
        return shaped(layered((low, 0), (gain(beat, 0.7), 0)), attack=0.005, decay=0.045)

    return normalised(layered((hum(), 0), (hum(), 0.13)), 0.7)


def callout() -> list[float]:
    """A word floating off a tile: one bright blip, up and away."""
    blip = shaped(tone(NOTES["A5"], 0.18, shape="triangle", glide_to=NOTES["D6"]),
                  attack=0.004, decay=0.06)
    under = shaped(tone(NOTES["A5"] / 2, 0.18, glide_to=NOTES["D6"] / 2),
                   attack=0.004, decay=0.05)
    return normalised(layered((blip, 0), (gain(under, 0.35), 0)), 0.6)


def press() -> list[float]:
    """A button taking a press: a tick and nothing more."""
    tick = shaped(tone(1000, 0.05, glide_to=700), attack=0.001, decay=0.012)
    edge = shaped(noise(0.008, seed=3, lowpass=0.5), attack=0.0005, decay=0.003)
    return normalised(layered((tick, 0), (gain(edge, 0.5), 0)), 0.5)


def hop() -> list[float]:
    """An animal landing after a hop on its lap of honour: a small, soft boing."""
    boing = shaped(tone(320, 0.1, shape="triangle", glide_to=170), attack=0.003, decay=0.035)
    return normalised(boing, 0.45)


def bell(note: str, seconds: float, decay: float) -> list[float]:
    """The jingles' instrument: a triangle with a quieter sine an octave up, which rings
    like something small and metal without any of the edge."""
    body = shaped(tone(NOTES[note], seconds, shape="triangle"), attack=0.004, decay=decay)
    shine = shaped(tone(NOTES[note] * 2, seconds), attack=0.004, decay=decay * 0.6)
    return layered((body, 0), (gain(shine, 0.3), 0))


def bonus() -> list[float]:
    """An apple tapped: two quick bright dings, the second a third up, the sound of five
    points being good news."""
    return normalised(
        layered(
            (bell("E6", 0.16, 0.05), 0.0),
            (bell("G6", 0.24, 0.08), 0.08),
        ),
        0.6,
    )


def penalty() -> list[float]:
    """A skull tapped: one low bonk sliding downwards, the sound of five points being bad
    news. The same soft sawtooth as the pig getting away, so the ear files it with that."""
    bonk = shaped(tone(NOTES["G3"], 0.22, shape="soft-saw", glide_to=NOTES["E3"]),
                  attack=0.006, decay=0.07, release=0.03)
    return normalised(bonk, 0.6)


# The four verdicts on a pen that holds are the same climb cut at different heights: the
# further the pen got, the further the notes go. A player hears how well they did before
# the card says it, and the best pen there is gets a run right up through the rainbow.

def held_one_star() -> list[float]:
    """Held, and no more than held: two notes, a third apart."""
    return normalised(
        layered(
            (bell("C5", 0.35, 0.12), 0.0),
            (bell("E5", 0.6, 0.22), 0.12),
        ),
        0.75,
    )


def held_two_stars() -> list[float]:
    """A good pen: the triad, three notes up."""
    return normalised(
        layered(
            (bell("C5", 0.35, 0.12), 0.0),
            (bell("E5", 0.35, 0.12), 0.11),
            (bell("G5", 0.65, 0.25), 0.22),
        ),
        0.8,
    )


def held_three_stars() -> list[float]:
    """The level's third star: four notes climbing to the octave."""
    return normalised(
        layered(
            (bell("C5", 0.35, 0.12), 0.0),
            (bell("E5", 0.35, 0.12), 0.11),
            (bell("G5", 0.35, 0.12), 0.22),
            (bell("C6", 0.75, 0.28), 0.33),
        ),
        0.8,
    )


def held_best_pen() -> list[float]:
    """The best pen the map allows — the rainbow: the climb carried on up through a second
    octave, and the top note left ringing with the chord under it."""
    steps = ["C5", "E5", "G5", "C6", "E6", "G6", "C7"]
    climb = [(bell(note, 0.3, 0.1), i * 0.085) for i, note in enumerate(steps)]
    top_at = (len(steps) - 1) * 0.085
    ring = [
        (bell("C7", 1.0, 0.4), top_at),
        (gain(bell("C6", 1.0, 0.45), 0.5), top_at),
        (gain(bell("E6", 1.0, 0.45), 0.4), top_at),
        (gain(bell("G6", 1.0, 0.45), 0.4), top_at),
    ]
    return normalised(layered(*climb, *ring), 0.85)


def pig_away() -> list[float]:
    """The gate opened on a gap: two notes stepping down, the second wilting as it goes."""
    first = shaped(tone(NOTES["E4"], 0.3, shape="soft-saw", vibrato=(0.012, 6)),
                   attack=0.02, decay=0.5, floor=0.6, release=0.03)
    second = shaped(tone(NOTES["C4"], 0.5, shape="soft-saw", glide_to=NOTES["B3"], vibrato=(0.02, 5.5)),
                    attack=0.02, decay=0.25, floor=0.0, release=0.06)
    return normalised(layered((first, 0), (second, 0.3)), 0.7)


def fanfare() -> list[float]:
    """A world held, or the whole game bought: the climb again, faster, and then the chord
    it was climbing to, held with a sparkle on top."""
    climb = [
        (bell("C5", 0.3, 0.1), 0.0),
        (bell("E5", 0.3, 0.1), 0.09),
        (bell("G5", 0.3, 0.1), 0.18),
        (bell("C6", 0.3, 0.1), 0.27),
    ]
    chord_at = 0.4
    chord = [
        (bell("C5", 1.1, 0.4), chord_at),
        (bell("E5", 1.1, 0.4), chord_at),
        (bell("G5", 1.1, 0.4), chord_at),
        (bell("C6", 1.1, 0.45), chord_at),
        (gain(bell("E6", 0.5, 0.15), 0.5), chord_at + 0.18),
        (gain(bell("G6", 0.6, 0.2), 0.5), chord_at + 0.36),
    ]
    return normalised(layered(*climb, *chord), 0.85)


SOUNDS = {
    "fence-in": fence_in,
    "fence-out": fence_out,
    "refusal": refusal,
    "callout": callout,
    "bonus": bonus,
    "penalty": penalty,
    "press": press,
    "hop": hop,
    "held-one-star": held_one_star,
    "held-two-stars": held_two_stars,
    "held-three-stars": held_three_stars,
    "held-best-pen": held_best_pen,
    "pig-away": pig_away,
    "fanfare": fanfare,
}


# MARK: - The music

# A waltz for the meadow: sixteen bars in C, a music box over an oom-pah-pah, that comes
# round to its own beginning so the phone can loop it without a seam. The tune is two
# eight-bar phrases, the first left hanging on the five chord and the second brought home.
WALTZ_BPM = 96
WALTZ_BEAT = 60 / WALTZ_BPM
WALTZ_BARS = 16

# One bar to a line: the chord under it, and the tune over it as (note, beats) pairs that
# add up to three. A None is a beat of rest.
WALTZ = [
    ("C", [("C5", 2), ("D5", 1)]),
    ("C", [("E5", 2), ("G5", 1)]),
    ("F", [("A5", 2), ("F5", 1)]),
    ("G", [("G5", 3)]),
    ("C", [("E5", 2), ("D5", 1)]),
    ("Am", [("C5", 2), ("E5", 1)]),
    ("Dm", [("D5", 1), ("E5", 1), ("F5", 1)]),
    ("G", [("G5", 2), (None, 1)]),
    ("C", [("C5", 2), ("D5", 1)]),
    ("Em", [("E5", 2), ("G5", 1)]),
    ("F", [("A5", 2), ("F5", 1)]),
    ("C", [("E5", 3)]),
    ("Am", [("A5", 2), ("G5", 1)]),
    ("Dm", [("F5", 1), ("E5", 1), ("D5", 1)]),
    ("G", [("D5", 2), ("B4", 1)]),
    ("C", [("C5", 3)]),
]

# Each chord as the bass note that goes under it and the three notes the pah-pah plays.
CHORDS = {
    "C": ("C3", ["C4", "E4", "G4"]),
    "F": ("F3", ["F4", "A4", "C5"]),
    "G": ("G3", ["G4", "B4", "D5"]),
    "Am": ("A3", ["A4", "C5", "E5"]),
    "Dm": ("D3", ["D4", "F4", "A4"]),
    "Em": ("E3", ["E4", "G4", "B4"]),
}


def music_box(note: str, seconds: float) -> list[float]:
    """The tune's instrument: the bell again, softer and longer, with a touch of the
    twelfth in it the way a plucked tine has."""
    body = shaped(tone(NOTES[note], seconds, shape="triangle"), attack=0.003, decay=0.28)
    shine = shaped(tone(NOTES[note] * 2, seconds), attack=0.003, decay=0.15)
    tine = shaped(tone(NOTES[note] * 3, seconds), attack=0.003, decay=0.08)
    return layered((body, 0), (gain(shine, 0.25), 0), (gain(tine, 0.08), 0))


def meadow_waltz() -> list[float]:
    """The whole loop, rendered into a buffer exactly as long as the sixteen bars, with
    every note's tail wrapped round to the start — which is what makes the seam silent."""
    length = samples(WALTZ_BARS * 3 * WALTZ_BEAT)
    out = [0.0] * length

    def put(track: list[float], at: float, level: float) -> None:
        start = samples(at)
        for i, s in enumerate(track):
            out[(start + i) % length] += s * level

    for bar, (chord, tune) in enumerate(WALTZ):
        bar_at = bar * 3 * WALTZ_BEAT
        bass, triad = CHORDS[chord]

        # Oom: the root on the first beat, on a sine that sits under everything.
        put(shaped(tone(NOTES[bass], 0.9, shape="sine"), attack=0.01, decay=0.35), bar_at, 0.42)
        # Pah, pah: the triad on the second and third, quietly.
        for beat in (1, 2):
            for note in triad:
                put(
                    shaped(tone(NOTES[note], 0.45, shape="triangle"), attack=0.01, decay=0.16),
                    bar_at + beat * WALTZ_BEAT,
                    0.09,
                )

        # The tune.
        beat_at = bar_at
        for note, beats in tune:
            if note is not None:
                put(music_box(note, beats * WALTZ_BEAT + 0.4), beat_at, 0.5)
            beat_at += beats * WALTZ_BEAT

    return normalised(out, 0.6)


def main() -> None:
    for name, make in SOUNDS.items():
        write(OUTPUT / f"{name}.wav", make())
    write(MUSIC, halved(meadow_waltz()), rate=RATE // 2)


if __name__ == "__main__":
    main()
