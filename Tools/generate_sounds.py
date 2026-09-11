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

Writes one file per sound into Pigpen/Resources/Sounds/. Commit the WAVs — the build reads
them, not the script. Only the standard library is needed.
"""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "Pigpen/Resources/Sounds"

RATE = 44_100
TAU = 2 * math.pi

# Note names, for the jingles. Concert pitch, equal temperament, nothing fancy.
NOTES = {
    "B3": 246.94, "C4": 261.63, "E4": 329.63, "G4": 392.00,
    "C5": 523.25, "E5": 659.25, "G5": 783.99, "A5": 880.00,
    "C6": 1046.50, "D6": 1174.66, "E6": 1318.51, "G6": 1567.98,
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


def write(name: str, track: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    path = OUTPUT / f"{name}.wav"
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in track
        )
        out.writeframes(frames)
    print(f"{path.relative_to(ROOT)}  {len(track) / RATE:.2f}s")


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


def pen_held() -> list[float]:
    """The gate shut on a pen that holds: four notes climbing to the octave."""
    return normalised(
        layered(
            (bell("C5", 0.35, 0.12), 0.0),
            (bell("E5", 0.35, 0.12), 0.11),
            (bell("G5", 0.35, 0.12), 0.22),
            (bell("C6", 0.75, 0.28), 0.33),
        ),
        0.8,
    )


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
    "press": press,
    "hop": hop,
    "pen-held": pen_held,
    "pig-away": pig_away,
    "fanfare": fanfare,
}


def main() -> None:
    for name, make in SOUNDS.items():
        write(name, make())


if __name__ == "__main__":
    main()
