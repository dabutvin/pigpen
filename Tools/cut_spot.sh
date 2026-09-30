#!/bin/bash
# Cuts the spot: the 3D pig, the board, the 3D pig again, and the sound under all three.
#
#   Tools/cut_spot.sh DIR INTO
#
# DIR holds what Tools/roll_reel.sh left of the app playing `-spot`: raw.mov, and app.log
# with the reel's start mark, its length and every noise it made. INTO is how far into
# raw.mov the reel's film starts, which roll_reel.sh printed. This renders the pig's two
# films into DIR/pig with Tools/spot/render.mjs and writes DIR/spot.mp4.
#
# The spot is under ten seconds in three parts, and only the middle is the app:
#
#   open   The 3D pig trots along behind a fence, finds the one gap in it, gives the camera
#          a look, and bolts out through the gap past the lens.
#   board  The app: Windfall Orchard with its wall half built, the east side laid piece by
#          piece, the pen let go into and held — the lap of honour, the confetti, three
#          stars — played on a fixed clock by SpotReel.swift.
#   end    The pig again, up on her hind legs against the fence, and the name planting
#          itself over her.
#
# The cut is 1080 by 1920 for a feed, the phone's own picture stood in the middle of a
# blurred copy of itself where a phone's screen is narrower than nine by sixteen. The
# simulator records no sound, so the soundtrack is built here: the pig films say which of
# the game's noises they want and when, the reel printed one SPOT_REEL_SOUND line per
# noise the game made — naming the file and the second of the film it was asked for — and
# every one is laid in at its moment, offset by the film before it, over the game's own
# tune at about a third of their level, which is how the app itself mixes them. A noise
# from before the board's film started has a negative time and is left out.
set -euo pipefail

dir=$1 into=$2
cd "$(dirname "$0")/.."

node Tools/spot/render.mjs --out "$dir/pig"

# The three lengths, and so where each part starts in the whole.
read -r open board end <<< "$(python3 - "$dir" <<'PY'
import json, sys
dir = sys.argv[1]
films = json.load(open(f"{dir}/pig/beats.json"))["films"]
board = next(float(line.split()[2]) for line in open(f"{dir}/app.log") if line.startswith("SPOT_REEL_START "))
print(films["open"]["length"], board, films["end"]["length"])
PY
)"
total=$(python3 -c "print(round($open + $board + $end, 3))")
echo "open ${open}s, board ${board}s, end ${end}s: ${total}s in all"

inputs=(
  -framerate 30 -i "$dir/pig/open/frame_%04d.png"
  -ss "$into" -i "$dir/raw.mov"
  -framerate 30 -i "$dir/pig/end/frame_%04d.png"
  -i Pigpen/Resources/Music/meadow-waltz.wav
)
voice="aresample=44100,aformat=sample_fmts=fltp:channel_layouts=stereo"
fade=$(python3 -c "print(round($total - 1, 3))")
filter="[3:a]${voice},volume=0.35,afade=t=out:st=${fade}:d=1[music]"
mix="[music]" count=1 next=4
# Every noise in the whole spot, as "file seconds": the pig films' from the beat sheet,
# the board's from what the reel printed, each offset to its part.
while read -r name at; do
  if [ ! -f "Pigpen/Resources/Sounds/$name.wav" ]; then
    echo "WARNING: a sound was asked for that there is no file for: $name"; continue
  fi
  ms=$(python3 -c "print(round($at * 1000))")
  inputs+=(-i "Pigpen/Resources/Sounds/$name.wav")
  filter+=";[$next:a]${voice},adelay=${ms}|${ms}[noise$next]"
  mix+="[noise$next]"
  count=$((count + 1)); next=$((next + 1))
done < <(python3 - "$dir" "$open" "$board" <<'PY'
import json, sys
dir, open_, board = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
films = json.load(open(f"{dir}/pig/beats.json"))["films"]
for name, at in films["open"]["sounds"]:
    print(name, round(at, 3))
for line in open(f"{dir}/app.log"):
    parts = line.split()
    if len(parts) == 3 and parts[0] == "SPOT_REEL_SOUND" and float(parts[2]) >= 0:
        print(parts[1], round(open_ + float(parts[2]), 3))
for name, at in films["end"]["sounds"]:
    print(name, round(open_ + board + at, 3))
PY
)
echo "$((count - 1)) noises under the spot"
filter+=";${mix}amix=inputs=${count}:normalize=0[audio]"
filter+=";[0:v]fps=30,setsar=1,format=yuv420p[pigopen]"
filter+=";[1:v]split=2[back][front]"
filter+=";[back]scale=1080:1920:flags=lanczos,boxblur=luma_radius=30:luma_power=2,setsar=1[blur]"
filter+=";[front]scale=-2:1920:flags=lanczos,setsar=1[phone]"
# A steady 30 fps, and the last frame held if the still ending left the recording short.
filter+=";[blur][phone]overlay=(W-w)/2:(H-h)/2,fps=30,tpad=stop_mode=clone:stop_duration=${board},trim=duration=${board},setpts=PTS-STARTPTS,format=yuv420p[boardcut]"
filter+=";[2:v]fps=30,setsar=1,format=yuv420p[pigend]"
# And 30 fps out of the join as well as into it: the encoder guesses otherwise.
filter+=";[pigopen][boardcut][pigend]concat=n=3:v=1:a=0,fps=30[video]"

ffmpeg -hide_banner -loglevel error -y \
  "${inputs[@]}" \
  -filter_complex "$filter" \
  -map "[video]" -map "[audio]" -t "$total" -r 30 \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p \
  -b:v 10M -maxrate 12M -bufsize 20M \
  -c:a aac -b:a 256k -ar 44100 -ac 2 \
  -movflags +faststart \
  "$dir/spot.mp4"
# The frames are a few hundred megabytes nobody needs once the film is cut.
rm -rf "$dir/pig/open" "$dir/pig/end"
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height,avg_frame_rate \
  -of compact "$dir/spot.mp4"
