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

log "booting $UDID"
if ! xcrun simctl bootstatus "$UDID" -b; then
  log "boot failed"
  : > "$STATE/failed"
  exit 1
fi
reached booted

# The first app to be installed and launched on a fresh simulator pays for
# installd starting up and for the runtime's shared cache being built, which is
# minutes of the cold start and has nothing to do with which app it is. So a
# stub app pays it here, next to the build, and the real one arrives to a
# simulator that has done all that already.
if [ -d "$STUB" ]; then
  ARCH=$(uname -m)
  [ "$ARCH" = "arm64" ] || ARCH=x86_64
  APP="$STATE/SimWarmup.app"

  mkdir -p "$APP"
  cp "$STUB/Info.plist" "$APP/Info.plist"

  if SDK=$(xcrun --sdk iphonesimulator --show-sdk-path) &&
     xcrun clang -target "$ARCH-apple-ios17.0-simulator" -isysroot "$SDK" \
       -framework UIKit -framework SwiftUI \
       -o "$APP/SimWarmup" "$STUB/main.c"; then
    log "installing the stub app"
    xcrun simctl install "$UDID" "$APP" && xcrun simctl launch "$UDID" "$BUNDLE_ID"
    xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null
    xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null
  else
    log "could not build the stub app"
  fi
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
