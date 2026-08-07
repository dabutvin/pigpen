#!/bin/bash
#
# Photographs every screen the app can be launched straight into, in both
# appearances, and writes them to a directory as <order>_<screen>_<appearance>.png.
#
# The work is a queue of independent launches, so it is dealt round however many
# simulators the job readied. One device does what it always did; two halve the
# clock. The order numbers are fixed per screen rather than counted as we go, so
# the file names come out the same whichever device happened to take which screen.

set -euo pipefail

OUT="$1"
BUNDLE_ID="$2"
APP="$3"
shift 3
UDIDS=("$@")

# Each screen: the number its light shot is filed under, the name it is filed
# under, and the launch arguments that open the app on it. `-map`, `-puzzle`,
# `-orchard`, `-sour`, `-boss`, `-tutorial` and `-settings` open the world map, the
# boards, the practice pen and the settings sheet without tapping through the title
# screen. The cut scenes come a shot at a time: each argument stops the clock on one
# shot, so these come out the same on every run rather than wherever a film happened
# to have got to. They are lit by the shot rather than by the phone, so the two
# appearances of each are meant to match.
SCREENS=(
  "1 title"
  "3 tutorial -tutorial"
  "5 map -map"
  "7 puzzle -puzzle"
  "9 orchard -orchard"
  "11 sour -sour"
  "13 boss -boss"
  "15 settings -settings"
  "17 opening_first_light -opening"
  "19 opening_gate -opening-gate"
  "21 opening_pig -opening-pig"
  "23 opening_away -opening-away"
  "25 opening_fence -opening-fence"
  "27 mere_water -mere"
  "29 mere_stag -mere-stag"
  "31 mere_both -mere-both"
  "33 held_penned -held-penned"
  "35 held_stag -held-stag"
  "37 held_meadow -held-meadow"
  "39 held_world -held-world"
  "41 held_beyond -held-beyond"
)

mkdir -p "$OUT"

# How long a screen is given to draw itself before it is photographed. Devices
# sharing a runner are each drawing on a share of it, so they are given longer —
# still far less than the whole queue cost when one device did all of it, and the
# point of the wait is a settled screen rather than a fast one.
SETTLE_LAUNCH=3
SETTLE_APPEARANCE=2
if [ "${#UDIDS[@]}" -gt 1 ]; then
  SETTLE_LAUNCH=4
  SETTLE_APPEARANCE=3
fi

# Each screen is shot in both appearances off a single launch: the views read the
# colour scheme out of the environment, so flipping the simulator under a running
# app re-draws it, and the two shots then show the same board rather than the same
# board twice over from two launches that need not have agreed about it.
capture() {
  local udid="$1" order="$2" screen="$3"
  shift 3

  local light dark
  light=$(printf '%s/%02d_%s_light.png' "$OUT" "$order" "$screen")
  dark=$(printf '%s/%02d_%s_dark.png' "$OUT" "$((order + 1))" "$screen")

  xcrun simctl ui "$udid" appearance light
  # Relaunching through `launch` rather than terminating first saves a round trip
  # to the device on every screen.
  xcrun simctl launch --terminate-running-process "$udid" "$BUNDLE_ID" "$@"
  sleep "$SETTLE_LAUNCH"
  xcrun simctl io "$udid" screenshot "$light"

  xcrun simctl ui "$udid" appearance dark
  sleep "$SETTLE_APPEARANCE"
  xcrun simctl io "$udid" screenshot "$dark"

  echo "Captured: $light, $dark"
}

# One worker per device, taking every Nth screen off the list.
shoot() {
  local slot="$1" udid="$2" i

  echo "Installing on $udid: $APP"
  xcrun simctl install "$udid" "$APP"

  for ((i = slot; i < ${#SCREENS[@]}; i += ${#UDIDS[@]})); do
    # shellcheck disable=SC2086 # the launch arguments are meant to split
    capture "$udid" ${SCREENS[$i]}
  done

  xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true
}

echo "Shooting ${#SCREENS[@]} screens across ${#UDIDS[@]} simulator(s)"

PIDS=()
for slot in "${!UDIDS[@]}"; do
  shoot "$slot" "${UDIDS[$slot]}" &
  PIDS+=("$!")
done

FAILED=0
for pid in "${PIDS[@]}"; do
  wait "$pid" || FAILED=1
done
[ "$FAILED" -eq 0 ] || { echo "ERROR: a simulator failed part way through"; exit 1; }

echo "All screenshots captured:"
ls -la "$OUT"
