Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$work = Join-Path $root 'work'
$raw = Join-Path $work 'raw'
$output = Join-Path $root 'output'
$storeOutput = Join-Path $output 'play-store-de'
$sceneOutput = Join-Path $work 'scenes'

New-Item -ItemType Directory -Force -Path $work, $raw, $output, $storeOutput, $sceneOutput | Out-Null

$fontRegular = 'C\:/Windows/Fonts/segoeui.ttf'
$fontBold = 'C\:/Windows/Fonts/seguisb.ttf'
$logo = Join-Path (Split-Path -Parent (Split-Path -Parent $root)) 'assets\images\logo_rainbow.png'

function Assert-File {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Fehlende Eingabedatei: $Path"
  }
}

function Invoke-Ffmpeg {
  param([Parameter(Mandatory)][string[]]$Arguments)

  & ffmpeg @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg ist mit Exitcode $LASTEXITCODE fehlgeschlagen."
  }
}

function Escape-DrawText {
  param([Parameter(Mandatory)][string]$Text)

  return $Text.Replace('\', '\\').Replace(':', '\:').Replace("'", "\'").Replace('%', '\%').Replace(',', '\,')
}

function New-DrawTextFilters {
  param(
    [Parameter(Mandatory)][string]$Text,
    [Parameter(Mandatory)][string]$Font,
    [Parameter(Mandatory)][string]$Color,
    [Parameter(Mandatory)][int]$Size,
    [Parameter(Mandatory)][string]$X,
    [Parameter(Mandatory)][int]$Y,
    [Parameter(Mandatory)][int]$LineSpacing
  )

  $lines = $Text -split "`r?`n"
  $filters = @()
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Length -eq 0) {
      continue
    }
    $line = Escape-DrawText $lines[$i]
    $lineY = $Y + ($i * ($Size + $LineSpacing))
    $filters += "drawtext=fontfile='$Font':text='$line':fontcolor=${Color}:fontsize=${Size}:x=${X}:y=$lineY"
  }
  return $filters -join ','
}

function Format-Number {
  param([Parameter(Mandatory)][double]$Value)

  return $Value.ToString('0.###', [System.Globalization.CultureInfo]::InvariantCulture)
}

function New-PublicCapture {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Destination,
    [Parameter(Mandatory)][string]$Filter
  )

  Assert-File $Source
  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', $Source, '-vf', $Filter,
    '-frames:v', '1', $Destination
  )
}

function New-StoreCard {
  param(
    [Parameter(Mandatory)]$Card,
    [Parameter(Mandatory)][string]$Destination
  )

  Assert-File $Card.Screenshot
  $title = Escape-DrawText $Card.Title
  $subtitle = Escape-DrawText $Card.Subtitle
  $accent = $Card.Accent
  $titleFilters = New-DrawTextFilters -Text $Card.Title -Font $fontBold -Color '0xFAF7FF' -Size 46 -X '(w-text_w)/2' -Y 68 -LineSpacing 8
  $subtitleFilters = New-DrawTextFilters -Text $Card.Subtitle -Font $fontRegular -Color '0xD6CEDF' -Size 28 -X '(w-text_w)/2' -Y 238 -LineSpacing 6
  $filter = @(
    "[0:v]crop=1080:2198:0:75,scale=730:-2,format=rgba[phone]"
    "[1:v]drawbox=x=0:y=0:w=1080:h=300:color=0x211A2D:t=fill,drawbox=x=470:y=38:w=140:h=8:color=${accent}:t=fill,${titleFilters},${subtitleFilters}[base]"
    "[base]drawbox=x=160:y=340:w=760:h=1530:color=black@0.30:t=fill[shadow]"
    "[shadow][phone]overlay=x=(W-w)/2:y=360:format=auto,format=yuv420p[out]"
  ) -join ';'

  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', $Card.Screenshot,
    '-f', 'lavfi', '-i', 'color=c=0x15131F:s=1080x1920:d=1',
    '-filter_complex', $filter,
    '-map', '[out]', '-frames:v', '1', $Destination
  )
}

function New-PhoneScene {
  param(
    [Parameter(Mandatory)]$Scene,
    [Parameter(Mandatory)][string]$Destination
  )

  Assert-File $Scene.Screenshot
  $duration = Format-Number $Scene.Duration
  $title = Escape-DrawText $Scene.Title
  $body = Escape-DrawText $Scene.Body
  $accent = $Scene.Accent
  $titleFilters = New-DrawTextFilters -Text $Scene.Title -Font $fontBold -Color '0xFAF7FF' -Size 64 -X '780' -Y 285 -LineSpacing 12
  $bodyFilters = New-DrawTextFilters -Text $Scene.Body -Font $fontRegular -Color '0xD6CEDF' -Size 38 -X '780' -Y 500 -LineSpacing 18
  $filter = @(
    "[0:v]crop=1080:2198:0:75,scale=470:-2,format=rgba[phone]"
    "[1:v]drawbox=x=0:y=0:w=1920:h=1080:color=0x15131F:t=fill,drawbox=x=0:y=0:w=24:h=1080:color=${accent}:t=fill,drawbox=x=780:y=245:w=110:h=8:color=${accent}:t=fill,drawtext=fontfile='${fontRegular}':text='AURORA 3.0.21':fontcolor=${accent}:fontsize=24:x=780:y=190,${titleFilters},${bodyFilters}[base]"
    "[base]drawbox=x=145:y=42:w=500:h=995:color=black@0.32:t=fill[shadow]"
    "[shadow][phone]overlay=x=160:y='58+4*sin(2*PI*t/$duration)':shortest=1:format=auto,format=yuv420p[out]"
  ) -join ';'

  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-loop', '1', '-framerate', '30', '-i', $Scene.Screenshot,
    '-f', 'lavfi', '-i', "color=c=0x15131F:s=1920x1080:r=30:d=$duration",
    '-filter_complex', $filter,
    '-map', '[out]', '-t', $duration, '-r', '30',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p',
    '-movflags', '+faststart', $Destination
  )
}

function New-LogoScene {
  param(
    [Parameter(Mandatory)]$Scene,
    [Parameter(Mandatory)][string]$Destination
  )

  Assert-File $logo
  $duration = Format-Number $Scene.Duration
  $title = Escape-DrawText $Scene.Title
  $body = Escape-DrawText $Scene.Body
  $accent = $Scene.Accent

  if ($Scene.Layout -eq 'center') {
    $titleFilters = New-DrawTextFilters -Text $Scene.Title -Font $fontBold -Color '0xFAF7FF' -Size 76 -X '(w-text_w)/2' -Y 555 -LineSpacing 12
    $bodyFilters = New-DrawTextFilters -Text $Scene.Body -Font $fontRegular -Color '0xD6CEDF' -Size 38 -X '(w-text_w)/2' -Y 690 -LineSpacing 16
    $filter = @(
      '[0:v]scale=360:360:force_original_aspect_ratio=decrease,format=rgba[logo]'
      "[1:v]drawbox=x=0:y=0:w=1920:h=1080:color=0x15131F:t=fill,drawbox=x=820:y=510:w=280:h=8:color=${accent}:t=fill,${titleFilters},${bodyFilters}[base]"
      '[base][logo]overlay=x=(W-w)/2:y=105:shortest=1:format=auto,format=yuv420p[out]'
    ) -join ';'
  } else {
    $titleFilters = New-DrawTextFilters -Text $Scene.Title -Font $fontBold -Color '0xFAF7FF' -Size 80 -X '180' -Y 340 -LineSpacing 12
    $bodyFilters = New-DrawTextFilters -Text $Scene.Body -Font $fontRegular -Color '0xD6CEDF' -Size 42 -X '180' -Y 500 -LineSpacing 18
    $filter = @(
      '[0:v]scale=430:430:force_original_aspect_ratio=decrease,format=rgba[logo]'
      "[1:v]drawbox=x=0:y=0:w=1920:h=1080:color=0x15131F:t=fill,drawbox=x=180:y=295:w=160:h=8:color=${accent}:t=fill,${titleFilters},${bodyFilters}[base]"
      "[base][logo]overlay=x=1260:y='300+5*sin(2*PI*t/$duration)':shortest=1:format=auto,format=yuv420p[out]"
    ) -join ';'
  }

  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-loop', '1', '-framerate', '30', '-i', $logo,
    '-f', 'lavfi', '-i', "color=c=0x15131F:s=1920x1080:r=30:d=$duration",
    '-filter_complex', $filter,
    '-map', '[out]', '-t', $duration, '-r', '30',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p',
    '-movflags', '+faststart', $Destination
  )
}

function New-Thumbnail {
  param(
    [Parameter(Mandatory)][string]$Screenshot,
    [Parameter(Mandatory)][string]$LineOne,
    [Parameter(Mandatory)][string]$LineTwo,
    [Parameter(Mandatory)][string]$Accent,
    [Parameter(Mandatory)][string]$Destination
  )

  Assert-File $Screenshot
  Assert-File $logo
  $one = Escape-DrawText $LineOne
  $two = Escape-DrawText $LineTwo
  $filter = @(
    '[0:v]crop=1080:2198:0:75,scale=930:-2,format=rgba[phone]'
    '[1:v]scale=410:410:force_original_aspect_ratio=decrease,format=rgba[logo]'
    "[2:v]drawbox=x=0:y=0:w=3840:h=2160:color=0x15131F:t=fill,drawbox=x=0:y=0:w=34:h=2160:color=${Accent}:t=fill,drawbox=x=300:y=745:w=420:h=14:color=${Accent}:t=fill,drawtext=fontfile='${fontRegular}':text='AURORA 3.0.21':fontcolor=${Accent}:fontsize=58:x=300:y=650,drawtext=fontfile='${fontBold}':text='$one':fontcolor=0xFAF7FF:fontsize=150:x=300:y=820,drawtext=fontfile='${fontBold}':text='$two':fontcolor=${Accent}:fontsize=150:x=300:y=1015,drawtext=fontfile='${fontRegular}':text='Private Alltagsbegleitung für Menschen mit DIS':fontcolor=0xD6CEDF:fontsize=54:x=310:y=1285[base]"
    '[base]drawbox=x=2670:y=90:w=1030:h=1980:color=black@0.34:t=fill[shadow]'
    '[shadow][phone]overlay=x=2720:y=120:format=auto[tmp]'
    '[tmp][logo]overlay=x=280:y=170:format=auto,format=yuv420p[out]'
  ) -join ';'

  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', $Screenshot, '-i', $logo,
    '-f', 'lavfi', '-i', 'color=c=0x15131F:s=3840x2160:d=1',
    '-filter_complex', $filter,
    '-map', '[out]', '-frames:v', '1', $Destination
  )
}

$publicMain = Join-Path $work 'main-public.png'
$publicProfiles = Join-Path $work 'profiles-public.png'
$publicCalendar = Join-Path $work 'calendar-public.png'

# Die Debug-Fixture nutzt reale, öffentliche Straßen als Geocoding-Beispiele.
# Im veröffentlichten Material werden diese drei sichtbaren Ortszeilen deshalb
# neutralisiert. Die Oberfläche selbst bleibt unverändert und echt aufgenommen.
New-PublicCapture -Source (Join-Path $work 'main.png') -Destination $publicMain -Filter "drawbox=x=330:y=670:w=420:h=60:color=black:t=fill,drawtext=fontfile='$fontRegular':text='Beispielort':fontcolor=0xE8E5EB:fontsize=34:x=(w-text_w)/2:y=678"
New-PublicCapture -Source (Join-Path $work 'profiles2.png') -Destination $publicProfiles -Filter "drawbox=x=330:y=710:w=420:h=60:color=black:t=fill,drawtext=fontfile='$fontRegular':text='Beispielort':fontcolor=0xE8E5EB:fontsize=34:x=(w-text_w)/2:y=718"
New-PublicCapture -Source (Join-Path $work 'calendar.png') -Destination $publicCalendar -Filter "drawbox=x=288:y=830:w=650:h=60:color=0x28272C:t=fill,drawtext=fontfile='$fontRegular':text='Beispielort':fontcolor=0xB2AA9A:fontsize=34:x=305:y=838"

$captures = @{
  Main = $publicMain
  Profiles = $publicProfiles
  Chat = Join-Path $work 'chat_final.png'
  Calendar = $publicCalendar
  Medications = Join-Path $work 'meds.png'
  Timeline = Join-Path $work 'timeline.png'
  Halt = Join-Path $work 'halt2.png'
  Help = Join-Path $work 'help.png'
  Privacy = Join-Path $work 'what_sends_off.png'
}

$storeCards = @(
  [pscustomobject]@{ Screenshot = $captures.Main; Title = "ORIENTIERUNG,`nWENN ZEIT FEHLT"; Subtitle = 'Heute. Hier. Wer war da?'; Accent = '0x79D5CC' }
  [pscustomobject]@{ Screenshot = $captures.Profiles; Title = 'WER IST GERADE DA?'; Subtitle = 'Jeder Anteil mit eigenem Profil.'; Accent = '0xFFB5C6' }
  [pscustomobject]@{ Screenshot = $captures.Chat; Title = 'GEMEINSAM IN VERBINDUNG'; Subtitle = 'Nachrichten bleiben auf dem Gerät.'; Accent = '0x65D6CB' }
  [pscustomobject]@{ Screenshot = $captures.Calendar; Title = 'TERMINE IM BLICK'; Subtitle = 'Heute sehen, später wiederfinden.'; Accent = '0xA78BFA' }
  [pscustomobject]@{ Screenshot = $captures.Medications; Title = 'ERINNERUNGEN OHNE DRUCK'; Subtitle = 'Medikamente gemeinsam organisieren.'; Accent = '0xD5A3FF' }
  [pscustomobject]@{ Screenshot = $captures.Halt; Title = 'ANKOMMEN. HIER UND JETZT.'; Subtitle = 'Halt führt mit einem Griff weiter.'; Accent = '0x52C5BD' }
  [pscustomobject]@{ Screenshot = $captures.Help; Title = 'HILFE, WENN SIE ZÄHLT'; Subtitle = 'Notruf und Beratung schnell erreichbar.'; Accent = '0xFF5B62' }
  [pscustomobject]@{ Screenshot = $captures.Privacy; Title = 'DU SIEHST, WAS RAUSGEHT'; Subtitle = 'Jede Übertragung im Wortlaut.'; Accent = '0xB9A3F5' }
)

for ($i = 0; $i -lt $storeCards.Count; $i++) {
  $name = 'phone-{0:D2}.png' -f ($i + 1)
  New-StoreCard -Card $storeCards[$i] -Destination (Join-Path $storeOutput $name)
}

$scenes = @(
  [pscustomobject]@{ Kind = 'logo'; Duration = 6.0; Title = 'WENN ZEIT FEHLT'; Body = 'sollte Orientierung nah sein.'; Accent = '0xFFB5C6'; Layout = 'side' }
  [pscustomobject]@{ Kind = 'logo'; Duration = 9.1; Title = 'AURORA'; Body = "Ein privater Ort für Menschen mit DIS`nzum Ankommen, Abstimmen und Erinnern."; Accent = '0x79D5CC'; Layout = 'side' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 11.0; Screenshot = $captures.Main; Title = 'AUF EINEN BLICK'; Body = "Welcher Tag ist heute?`nWo bin ich? Wer war zuletzt da?`nWas steht als Nächstes an?"; Accent = '0x79D5CC' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 4.2; Screenshot = $captures.Profiles; Title = 'EIGENE PROFILE'; Body = "Wer ist gerade da?`nWer war zuletzt da?"; Accent = '0xFFB5C6' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 8.2; Screenshot = $captures.Chat; Title = 'GEMEINSAMER CHAT'; Body = "Nachrichten, Bilder und Gedanken`nbleiben auf deinem Gerät."; Accent = '0x65D6CB' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 4.4; Screenshot = $captures.Calendar; Title = 'TERMINE IM BLICK'; Body = "Der gemeinsame Alltag`nauf einen Blick."; Accent = '0xA78BFA' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 4.9; Screenshot = $captures.Medications; Title = 'ERINNERUNGEN OHNE DRUCK'; Body = "Medikamente gemeinsam`norganisieren."; Accent = '0xD5A3FF' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 7.9; Screenshot = $captures.Timeline; Title = 'DU ENTSCHEIDEST'; Body = "Die Zeitkarte zeichnet nur auf,`nwenn du sie einschaltest.`nLokal. Jederzeit löschbar."; Accent = '0xB9A3F5' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 3.9; Screenshot = $captures.Halt; Title = 'HALT'; Body = "Ankommen.`nHier und Jetzt."; Accent = '0x52C5BD' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 3.2; Screenshot = $captures.Help; Title = 'HILFE, WENN SIE ZÄHLT'; Body = "Notruf und Beratung`nschnell erreichbar."; Accent = '0xFF5B62' }
  [pscustomobject]@{ Kind = 'phone'; Duration = 13.4; Screenshot = $captures.Privacy; Title = 'DEINE DATEN BLEIBEN HIER'; Body = "Kein Konto. Keine Cloud.`nStandort erreicht uns nie.`nDu siehst jede Übertragung."; Accent = '0xB9A3F5' }
  [pscustomobject]@{ Kind = 'logo'; Duration = 14.8; Title = 'AURORA 3.0.21'; Body = "Für mehr Orientierung und gemeinsame Absprachen.`n`nJetzt für Android im Google Play Store."; Accent = '0x79D5CC'; Layout = 'center' }
)

$sceneFiles = @()
for ($i = 0; $i -lt $scenes.Count; $i++) {
  $sceneFile = Join-Path $sceneOutput ('scene-{0:D2}.mp4' -f $i)
  if ($scenes[$i].Kind -eq 'logo') {
    New-LogoScene -Scene $scenes[$i] -Destination $sceneFile
  } else {
    New-PhoneScene -Scene $scenes[$i] -Destination $sceneFile
  }
  $sceneFiles += $sceneFile
}

$xfadeOffsets = @(5.6, 14.3, 24.9, 28.7, 36.5, 40.5, 45.0, 52.5, 56.0, 58.8, 71.8)
$xfadeParts = @()
$lastLabel = '0:v'
for ($i = 1; $i -lt $sceneFiles.Count; $i++) {
  $nextLabel = if ($i -eq ($sceneFiles.Count - 1)) { 'vout' } else { "v$i" }
  $offset = Format-Number $xfadeOffsets[$i - 1]
  $xfadeParts += "[$lastLabel][${i}:v]xfade=transition=fade:duration=0.4:offset=$offset[$nextLabel]"
  $lastLabel = $nextLabel
}

$videoSilent = Join-Path $work 'video-silent.mp4'
$videoArgs = @('-hide_banner', '-loglevel', 'error', '-y')
foreach ($sceneFile in $sceneFiles) {
  $videoArgs += @('-i', $sceneFile)
}
$videoArgs += @(
  '-filter_complex', ($xfadeParts -join ';'),
  '-map', '[vout]', '-t', '86.6', '-r', '30',
  '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p',
  '-movflags', '+faststart', $videoSilent
)
Invoke-Ffmpeg $videoArgs

$narration = Join-Path $work 'narration.mp3'
$subtitleSource = Join-Path $work 'narration.vtt'
if (-not (Test-Path -LiteralPath $narration) -or -not (Test-Path -LiteralPath $subtitleSource)) {
  & python -m edge_tts --voice de-DE-KatjaNeural --rate=-6% --pitch=-2Hz --file (Join-Path $root 'narration-de.txt') --write-media $narration --write-subtitles $subtitleSource
  if ($LASTEXITCODE -ne 0) {
    throw 'Die Sprachspur konnte nicht erzeugt werden.'
  }
}

$ambient = Join-Path $work 'ambient.wav'
Invoke-Ffmpeg @(
  '-hide_banner', '-loglevel', 'error', '-y',
  '-f', 'lavfi', '-i', 'sine=frequency=110:sample_rate=48000:duration=86.6',
  '-f', 'lavfi', '-i', 'sine=frequency=164.81:sample_rate=48000:duration=86.6',
  '-f', 'lavfi', '-i', 'sine=frequency=261.63:sample_rate=48000:duration=86.6',
  '-filter_complex', '[0:a]volume=0.018,tremolo=f=0.12:d=0.18[a0];[1:a]volume=0.014,tremolo=f=0.10:d=0.15[a1];[2:a]volume=0.007,tremolo=f=0.15:d=0.12[a2];[a0][a1][a2]amix=inputs=3:normalize=0,lowpass=f=900,aecho=0.8:0.7:700|1400:0.13|0.07,afade=t=in:st=0:d=3,afade=t=out:st=82:d=4[aout]',
  '-map', '[aout]', '-c:a', 'pcm_s16le', $ambient
)

$finalVideo = Join-Path $output 'aurora-3.0.21-youtube-de.mp4'
Invoke-Ffmpeg @(
  '-hide_banner', '-loglevel', 'error', '-y',
  '-i', $videoSilent, '-i', $narration, '-i', $ambient,
  '-filter_complex', '[1:a]loudnorm=I=-16:TP=-1.5:LRA=9[voice];[2:a]volume=1[bed];[voice][bed]amix=inputs=2:duration=longest:normalize=0,alimiter=limit=0.95[aout]',
  '-map', '0:v:0', '-map', '[aout]', '-t', '86.6',
  '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k', '-ar', '48000',
  '-movflags', '+faststart', $finalVideo
)

Copy-Item -LiteralPath $subtitleSource -Destination (Join-Path $output 'aurora-3.0.21-de.srt') -Force

New-Thumbnail -Screenshot $captures.Main -LineOne 'ORIENTIERUNG.' -LineTwo 'PRIVAT.' -Accent '0x79D5CC' -Destination (Join-Path $output 'thumbnail-a-orientierung-privat.png')
New-Thumbnail -Screenshot $captures.Privacy -LineOne 'DEINE DATEN' -LineTwo 'BLEIBEN HIER.' -Accent '0xB9A3F5' -Destination (Join-Path $output 'thumbnail-b-daten-bleiben-hier.png')
New-Thumbnail -Screenshot $captures.Profiles -LineOne 'WENN ZEIT' -LineTwo 'FEHLT.' -Accent '0xFFB5C6' -Destination (Join-Path $output 'thumbnail-c-wenn-zeit-fehlt.png')

Write-Output "Fertig: $finalVideo"
Write-Output "Store-Grafiken: $storeOutput"
Write-Output "Thumbnails: $output"
