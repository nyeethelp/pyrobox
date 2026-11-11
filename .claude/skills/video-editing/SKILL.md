---
name: video-editing
description: The user's own video-editing playbook — their preferred style, workflow, and ffmpeg recipes, taught to Claude over time. Use whenever the user asks to edit, cut, trim, caption, color, export, or otherwise process a video or audio file, or when they say "teach you", "new lesson", or "remember this for editing".
---

# Video Editing Playbook

This file is how the user trains Claude to edit videos their way. Claude has
no memory between chats, so **everything learned lives here**. Follow it
before falling back on general defaults.

## How training works

- When the user teaches something ("always do X", "I prefer Y", "that was
  wrong, do Z instead"), add it to the right section below **in the same
  turn**, then commit it, so the next session knows it too.
- Write each lesson as a short, concrete rule. Put a working command in
  **Recipes** when one exists.
- If a new lesson contradicts an old one, replace the old one; don't keep both.
- Before editing a video, re-read this whole file.

## Tools available

- `ffmpeg` / `ffprobe` (installed in the cloud container).
- Always run `ffprobe -hide_banner <file>` first to check resolution, fps,
  codecs, and duration.
- Never overwrite the source file; write outputs to a new file name.

## Style preferences

<!-- e.g. aspect ratio, pacing, transitions, music volume, caption font/size/position -->
_None yet — teach me!_

## Workflow / order of operations

<!-- e.g. 1. trim silences  2. color  3. captions  4. music  5. export -->
_None yet._

## Export settings

<!-- e.g. platform targets (YouTube, TikTok, Reels), codec, bitrate, resolution -->
_None yet._ Until taught, default to: H.264 (`libx264 -crf 20 -preset medium`),
AAC 192k audio, `-movflags +faststart`, keep source resolution and fps.

## Recipes

Starter commands (replace or extend as the user teaches better ones):

```bash
# Trim without re-encoding (fast; cuts land on keyframes)
ffmpeg -ss 00:00:05 -to 00:00:30 -i in.mp4 -c copy out.mp4

# Frame-accurate trim (re-encodes)
ffmpeg -i in.mp4 -ss 00:00:05 -to 00:00:30 -c:v libx264 -crf 20 -c:a aac out.mp4

# Concatenate clips with identical formats
printf "file '%s'\n" clip1.mp4 clip2.mp4 > list.txt
ffmpeg -f concat -safe 0 -i list.txt -c copy out.mp4

# Vertical 9:16 crop from 16:9 (centered)
ffmpeg -i in.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy out.mp4

# Burn in subtitles
ffmpeg -i in.mp4 -vf "subtitles=subs.srt" -c:a copy out.mp4

# Background music at 20% volume under the original audio
ffmpeg -i in.mp4 -i music.mp3 -filter_complex "[1:a]volume=0.2[m];[0:a][m]amix=inputs=2:duration=first" -c:v copy out.mp4
```

## Mistakes to avoid

<!-- things the user corrected — so they don't happen again -->
_None yet._

## Lesson log

<!-- one dated line per lesson, newest first, e.g.
- 2026-11-11: Prefers jump cuts over crossfades for talking-head videos.
-->
