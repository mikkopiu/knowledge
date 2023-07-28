# AV

## ffmpeg

### AC-3 re-encode

Re-encode first audio stream to AC-3 while preserving existing audio streams as-is (but put the new one first).

```sh
ffmpeg -i INFILE.mkv \
  -c copy \
  -map 0:v \
  -map 0:s? \
  -map 0:a:0? -c:a:0 ac3 \
  -map 0:a:0? -c:a:1 copy \
  -map 0:a:1? -c:a:2 copy \
  -map 0:a:2? -c:a:3 copy \
  -map 0:a:3? -c:a:4 copy \
  -map 0:a:4? -c:a:5 copy \
  -map 0:a:5? -c:a:6 copy \
  -metadata:s:a:0 title="$(ffprobe -v error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 INFILE.mkv) AC-3"
  OUTFILE.mkv
```

Useful for re-encoding DTS-HD etc. audio streams to AC-3 that is generally supported by streaming devices like the Chromecast.

This also preserves all existing video and text streams (=subtitles). Could be expanded to a silly amount of audio streams (as
they're conditional to their existence), but six is generally enough.

Additionally, this adds "$LANGUAGE AC-3" as the title of the re-encoded first stream, like "English AC-3". This depends on a hard-coded
mapping table of ISO 639-2/B three-letter codes that `ffprobe` outputs. Otherwise, it would keep the title from the original stream.

Alternative PowerShell 7 script for processing a whole directory and outputting in Plex-desired directory format for easy copying:

```powershell
# Ensure output directory exists
$baseOutDir = "out"
New-Item -Path $baseOutDir -ItemType Directory -Force

$languages = @{
    "cze" = "Czech";
    "dan" = "Danish";
    "eng" = "English";
    "fin" = "Finnish";
    "fra" = "French";
    "fre" = "French";
    "ind" = "Indonesian";
    "jpn" = "Japanese";
    "kor" = "Korean";
    "spa" = "Spanish";
    "swe" = "Swedish";
    "zho" = "Chinese";
    # Add more language code to full name mappings as needed
}

# Get the list of video files in the current directory
$files = Get-ChildItem -Path . -Include "*.mkv", "*.mp4", "*.avi", "*.m2ts"

# Run each iteration in parallel
foreach ($inputFile in $files) {
    Start-ThreadJob -ScriptBlock {
        param ($inputFile, $baseOutDir, $languages)

		# Form the output file name with the new extension
		$fullOutDir = Join-Path $baseOutDir $inputFile.BaseName
		$outputFile = Join-Path $fullOutDir $inputFile.Name

		# Run ffprobe to get the language code of the first audio stream and store the output in a variable
		$languageCode = & ffprobe -v error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 $inputFile.FullName

		if ($languageCode -eq $null) {
			$languageName = "Unknown"
			Write-Host "Unknown language in: $inputFile"
		} else {
			# Trim any leading or trailing whitespace from the ffprobe output
			$languageCode = $languageCode.Trim()
			
			# Get the full language name from the hashtable
			$languageName = $languages[$languageCode]
		}

		# Form the new title with the language code and "AC-3"
		$title = "$languageName AC-3"
		
		# Ensure output directory exists
		New-Item -Path $fullOutDir -ItemType Directory -Force

		# Run the ffmpeg command to convert audio with the variables for input and output filenames

		ffmpeg -nostats -loglevel quiet -i $inputFile.FullName -c copy -map 0:v -map 0:s? -map 0:a:0? -c:a:0 ac3 -map 0:a:0? -c:a:1 copy -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -metadata:s:a:0 title=$title $outputFile
    } -ArgumentList $inputFile, $baseOutDir, $languages
}

# Wait for all background jobs to complete
Get-Job | Wait-Job

# Retrieve the output from the background jobs (optional)
Get-Job | Receive-Job

# Remove completed jobs from the job history
Get-Job | Remove-Job
```

<details>
<summary>Or alternatively, the same script modified to process a whole directory recursively and to overwrite all re-encoded files:</summary>

```powershell
$languages = @{
    "cze" = "Czech";
    "dan" = "Danish";
    "eng" = "English";
    "fin" = "Finnish";
    "fra" = "French";
    "fre" = "French";
    "ind" = "Indonesian";
    "jpn" = "Japanese";
    "kor" = "Korean";
    "spa" = "Spanish";
    "swe" = "Swedish";
    "zho" = "Chinese";
    # Add more language code to full name mappings as needed
}

# Get the list of video files in the current working directory
$files = Get-ChildItem -Path . -Include "*.mkv", "*.mp4", "*.avi", "*.m2ts" -Recurse

# Run each iteration in parallel
foreach ($inputFile in $files) {
    Start-ThreadJob -ScriptBlock {
	param ($inputFile, $languages)

		# Use ffprobe to check whether the first audio track actually requires re-encoding
		$audioCodec = & ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $inputFile.FullName

		if ($audioCodec -notlike 'dts*' -and $audioCodec -notlike 'truehd*') {
			Write-Host "First audio track not DTS, skipping. Found: $audioCodec in $inputFile"
			return
		}

		# Form the output file name with the new extension
		$tmpOutFile = Join-Path $inputFile.Directory.FullName ($inputFile.BaseName + ".ac3" + $inputFile.Extension)

		# Run ffprobe to get the language code of the first audio stream and store the output in a variable
		$languageCode = & ffprobe -v error -select_streams a:0 -show_entries stream_tags=language -of default=nw=1:nk=1 $inputFile.FullName

		if ($languageCode -eq $null) {
			$languageName = "Unknown"
			Write-Host "Unknown language in: $inputFile"
		} else {
			# Trim any leading or trailing whitespace from the ffprobe output
			$languageCode = $languageCode.Trim()
			
			# Get the full language name from the hashtable
			$languageName = $languages[$languageCode]
		}

		# Form the new title with the language code and "AC-3"
		$title = "$languageName AC-3"

		# Run the ffmpeg command to convert audio with the variables for input and output filenames
		ffmpeg -nostats -loglevel quiet -i $inputFile.FullName -c copy -map 0:v -map 0:s? -map 0:a:0? -c:a:0 ac3 -map 0:a:0? -c:a:1 copy -map 0:a:1? -c:a:2 copy -map 0:a:2? -c:a:3 copy -map 0:a:3? -c:a:4 copy -map 0:a:4? -c:a:5 copy -map 0:a:5? -c:a:6 copy -metadata:s:a:0 title=$title $tmpOutFile

		# Overwrite existing file once re-encoding is done
		Move-Item -Path $tmpOutFile -Destination $inputFile.FullName -Force

    } -ArgumentList $inputFile, $languages
}

# Wait for all background jobs to complete
Get-Job | Wait-Job

# Retrieve the output from the background jobs (optional)
Get-Job | Receive-Job

# Remove completed jobs from the job history
Get-Job | Remove-Job
```

</details>
