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

## Channel context

- Platform: **YouTube, long-form** (16:9). The user is new to editing and wants
  help with everything: cuts, transitions, animations, titles, polish.
- Raw footage is already recorded; edits start from those files.
- **Format:** talking head (user speaking to camera), raw takes about 30 min.
- **Camera:** DJI Osmo Pocket 3. Before editing, run ffprobe to check
  resolution/fps, codec (H.264 vs H.265), and 10-bit. Ask whether it was shot
  in Normal, HLG, or D-Log M: D-Log M looks flat/grey and needs DJI's
  D-Log M→Rec.709 LUT before any other color work. Long takes may be split
  into several files; join them first (concat recipe).
- **Niche:** business, finance, motivation/entrepreneurship.
  - Animated numbers, charts, and key-term text on screen suit this niche well.
  - Finance videos: suggest a short "not financial advice / for education"
    disclaimer on screen or in the description. Keep claims factual.

## Suggested defaults for this niche (until the user overrides)

- Remove silences and flubbed takes (jump cuts); keep breaths natural, ~0.15s padding.
- Punch-in zooms (~110–120%) on key points to hide jump cuts and add emphasis.
- Strong hook in the first 30s; move the best line up front if needed.
- Keyword pop-up text, simple animated charts for numbers, chapter markers.
- Music low under speech (about -25 to -30 dB) with ducking; clean, minimal transitions.

## Style preferences

<!-- e.g. pacing, transitions, music volume, caption font/size/position -->
_None yet — teach me!_

## Workflow / order of operations

Target pipeline (adapted from a reference video the user shared: Christian
Peverelli, "I Fully Automated My Video Editing Using Claude Code"):

1. **Ingest:** join Pocket 3 split files, ffprobe, apply LUT if D-Log M.
2. **Transcribe** with word-level timestamps (Parakeet on NVIDIA GPU; otherwise
   Whisper / whisper.cpp / MLX-Whisper on Mac).
3. **Cut from the transcript:** silences, flubs, repeated takes; pick the hook.
   The reference cut a 2:46 raw hook to 0:31. Aim for that kind of tightness in the opening.
4. **Graphics:** animations written as HTML/CSS/JS and rendered to video
   (reference used HeyGen's Hyperframes; Remotion is an alternative). Use the brand kit.
5. **B-roll:** screenshots of web pages/articles with highlighted lines (via a browser).
6. **Music/SFX:** from the user's library, at the volumes in Style preferences.
7. **Assemble + QC with ffmpeg:** check for black frames, audio sync, and loudness (-14 LUFS for YouTube).
8. **Review loop:** user watches the cut and gives time-coded notes
   ("2:14 SFX too loud"). Fix, then save each generalizable note as a rule here.

## Setup checklist (what the user still needs to provide)

- [ ] Claude desktop app → Claude Code in **local** mode, on the computer with the footage
- [ ] Project folder: `raw/`, `assets/` (logo, fonts, music, sfx, LUT), `exports/`
- [ ] Brand kit: 2–4 hex colors, 1–2 fonts, logo (PNG with transparent background)
- [ ] Music source (Epidemic Sound, paid, or YouTube Audio Library, free)
- [ ] 2–3 reference YouTubers/videos whose editing style to copy
- [ ] Pocket 3 color mode (Normal / HLG / D-Log M) and resolution/fps

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

<!-- one dated line per lesson, newest first -->
- 2026-11-11: Adopted reference pipeline (transcript-driven cuts, HTML animations, ffmpeg QC, time-coded feedback loop).
- 2026-11-11: Talking-head, ~30 min raw, DJI Osmo Pocket 3; niche is business/finance/motivation.
- 2026-11-11: Making long-form YouTube content (16:9); needs full editing help.
