#!/bin/bash
# Records the app playing one of its reels on a booted simulator.
#
#   Tools/roll_reel.sh DIR UDID BUNDLE_ID ARGUMENT MARK SECONDS [LAUNCH ARGUMENTS...]
#
# Apple takes an app preview only as a recording of the app, and the spot is made the same
# way for the same reason: what it shows is what the app does. So this is the camera. It
# starts the simulator's recorder before the launch, since the recorder can take seconds
# to get going; launches the app on ARGUMENT — `-preview` or `-spot`, the reel to play —
# with any further launch arguments after it, such as the language to play in; waits
# SECONDS, which is the reel's pre-roll and its film and some slack; stops the recorder;
# and leaves DIR/raw.mov, DIR/recorder.log and DIR/app.log behind.
#
# It prints one number: how many seconds into the recording the film proper starts. The
# recorder says "Recording started" the moment its first frame is taken, and a reel prints
# its MARK the moment its film starts; both are stamped on this Mac's clock, and the cut
# is the gap between them. (Not measured back from the stop: the recorder only writes a
# frame when the screen changes, so a still ending leaves the file shorter than the wait.)
set -euo pipefail

dir=$1 udid=$2 bundle=$3 argument=$4 mark=$5 seconds=$6
shift 6

mkdir -p "$dir"
xcrun simctl terminate "$udid" "$bundle" 2>/dev/null || true
# Every line the recorder says, stamped with the time it said it.
xcrun simctl io "$udid" recordVideo --codec=h264 --force "$dir/raw.mov" \
  > >(python3 -u -c 'import sys, time
for line in sys.stdin: print(time.time(), line, end="", flush=True)' > "$dir/recorder.log") 2>&1 &
recorder=$!
sleep 3
# The launch prints the app's process id — "com.pigpen.app: 6192" — to standard output,
# and standard output is where this script's one number goes, so that line is sent to
# standard error with the rest of the chatter. (The app's own output goes to app.log.)
xcrun simctl launch --stdout="$dir/app.log" "$udid" "$bundle" "$@" "$argument" >&2
sleep "$seconds"
kill -INT "$recorder"
wait "$recorder" || true
xcrun simctl terminate "$udid" "$bundle" 2>/dev/null || true

started=$(awk -v mark="$mark" '$1 == mark { print $2; exit }' "$dir/app.log" || true)
if [ -z "$started" ]; then
  echo "ERROR: the reel never said when its film started" >&2
  cat "$dir/app.log" >&2 || true
  exit 1
fi
recording=$(awk '/Recording started/ { print $1; exit }' "$dir/recorder.log" || true)
if [ -z "$recording" ]; then
  echo "ERROR: the recorder never said it had started" >&2
  cat "$dir/recorder.log" >&2 || true
  exit 1
fi
python3 -c "print(round($started - $recording, 3))"
