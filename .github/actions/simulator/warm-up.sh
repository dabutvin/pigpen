#!/bin/bash
#
# Wakes a simulator up in the background while the job gets on with the build.
# Each stage that finishes leaves a file behind in the state directory for the
# waiting step to notice: booted, installed, warm.
#
# Nothing here except the boot itself is allowed to matter. A stage that fails
# only means the job pays for that piece of the cold start itself, later, which
# is exactly where it was paying for it before.

set -uo pipefail

UDID="$1"
STATE="$2"
STUB="$3"
DISPLAY_WARMUP="$4"

BUNDLE_ID="com.pigpen.simwarmup"
START=$SECONDS

log() { printf '[%4ds] %s\n' "$((SECONDS - START))" "$*"; }
reached() { log "reached: $1"; : > "$STATE/$1"; }

APP="$STATE/SimWarmup.app"

# The first app to be installed and launched on a fresh simulator pays for
# installd starting up and for the runtime's shared cache being built, which is
# minutes of the cold start and has nothing to do with which app it is. So a
# stub app pays it here, next to the build, and the real one arrives to a
# simulator that has done all that already. Linking UIKit and SwiftUI without
# using them is deliberate: loading them is the point.
build_stub() {
  [ -d "$STUB" ] || return 1

  local arch sdk
  arch=$(uname -m)
  [ "$arch" = "arm64" ] || arch=x86_64
  sdk=$(xcrun --sdk iphonesimulator --show-sdk-path) || return 1

  mkdir -p "$APP"
  cp "$STUB/Info.plist" "$APP/Info.plist"
  xcrun clang -target "$arch-apple-ios17.0-simulator" -isysroot "$sdk" \
    -framework UIKit -framework SwiftUI \
    -o "$APP/SimWarmup" "$STUB/main.c"
}

# Kicking the boot off first means the stub app is compiled while the device
# comes up rather than after it.
log "booting $UDID"
xcrun simctl boot "$UDID" > /dev/null 2>&1 || true

STUB_BUILT=no
if build_stub; then
  STUB_BUILT=yes
else
  log "could not build the stub app"
fi

if ! xcrun simctl bootstatus "$UDID" -b; then
  log "boot failed"
  : > "$STATE/failed"
  exit 1
fi
reached booted

# Booting is mostly waiting, so it is happy to share the machine with a build.
# The first launch is not: it builds the runtime's shared cache, which wants
# every core there is, and a runner has three. So it holds off until the job has
# nothing left to do but wait for the simulator, which is what the waiting step
# says by leaving `machine-free` behind. Waiting for a job that never gets there
# would be worse than the contention, hence the cap.
WAITED=0
while [ ! -f "$STATE/machine-free" ] && [ "$WAITED" -lt 300 ]; do
  sleep 2
  WAITED=$((WAITED + 2))
done
[ -f "$STATE/machine-free" ] || log "gave up waiting for the build to finish"

if [ "$STUB_BUILT" = "yes" ]; then
  log "installing the stub app"
  xcrun simctl install "$UDID" "$APP" && xcrun simctl launch "$UDID" "$BUNDLE_ID"
  xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null
  xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null
fi
reached installed

# Dressing the simulator and grabbing one frame off it starts the display
# service, which the first screenshot would otherwise wait minutes for.
if [ "$DISPLAY_WARMUP" = "true" ]; then
  log "setting the status bar and exercising the display"
  xcrun simctl status_bar "$UDID" override \
    --time "9:41" \
    --batteryState charged \
    --batteryLevel 100 \
    --wifiBars 3 \
    --cellularBars 4
  xcrun simctl ui "$UDID" appearance dark
  xcrun simctl ui "$UDID" appearance light
  xcrun simctl io "$UDID" screenshot "$STATE/warm-up.png"
fi
reached warm
