# AV

## ffmpeg

### AC-3 re-encode

Re-encode first audio stream to AC-3 while preserving existing audio streams as-is (but put the new one first).

```sh
ffmpeg -i infile.mkv \
  -c copy \
  -map 0:v \
  -map 0:s \
  -map 0:a:0? -c:a:0 ac3 \
  -map 0:a:0? -c:a:1 copy \
  -map 0:a:1? -c:a:2 copy \
  -map 0:a:2? -c:a:3 copy \
  -map 0:a:3? -c:a:4 copy \
  -map 0:a:4? -c:a:5 copy \
  -map 0:a:5? -c:a:6 copy \
  outfile.mkv
```

Useful for re-encoding DTS-HD etc. audio streams to AC-3 that is generally supported by streaming devices like the Chromecast.
This also preserves all existing video and text streams (=subtitles). Could be expanded to a silly amount of audio streams (as
they're conditional to their existence), but six is generally enough.
