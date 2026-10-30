Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$work = Join-Path $root 'work'
$output = Join-Path $root 'output\play-store-en'
$fontRegular = 'C\:/Windows/Fonts/segoeui.ttf'
$fontBold = 'C\:/Windows/Fonts/seguisb.ttf'

New-Item -ItemType Directory -Force -Path $output | Out-Null

function Assert-File {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Missing input file: $Path"
  }
}

function Invoke-Ffmpeg {
  param([Parameter(Mandatory)][string[]]$Arguments)

  & ffmpeg @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "ffmpeg failed with exit code $LASTEXITCODE."
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

function New-StoreCard {
  param(
    [Parameter(Mandatory)]$Card,
    [Parameter(Mandatory)][string]$Destination
  )

  Assert-File $Card.Screenshot
  $titleFilters = New-DrawTextFilters -Text $Card.Title -Font $fontBold -Color '0xFAF7FF' -Size 46 -X '(w-text_w)/2' -Y 68 -LineSpacing 8
  $subtitleFilters = New-DrawTextFilters -Text $Card.Subtitle -Font $fontRegular -Color '0xD6CEDF' -Size 28 -X '(w-text_w)/2' -Y 238 -LineSpacing 6
  $accent = $Card.Accent
  $filter = @(
    '[0:v]crop=1080:2198:0:75,scale=730:-2,format=rgba[phone]'
    "[1:v]drawbox=x=0:y=0:w=1080:h=300:color=0x211A2D:t=fill,drawbox=x=470:y=38:w=140:h=8:color=${accent}:t=fill,${titleFilters},${subtitleFilters}[base]"
    '[base]drawbox=x=160:y=340:w=760:h=1530:color=black@0.30:t=fill[shadow]'
    '[shadow][phone]overlay=x=(W-w)/2:y=360:format=auto,format=yuv420p[out]'
  ) -join ';'

  Invoke-Ffmpeg @(
    '-hide_banner', '-loglevel', 'error', '-y',
    '-i', $Card.Screenshot,
    '-f', 'lavfi', '-i', 'color=c=0x15131F:s=1080x1920:d=1',
    '-filter_complex', $filter,
    '-map', '[out]', '-frames:v', '1', $Destination
  )
}

$cards = @(
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_main.png'; Title = "ORIENTATION,`nWHEN TIME IS MISSING"; Subtitle = 'Today. Here. Who was here?'; Accent = '0x79D5CC' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_profiles.png'; Title = "WHO IS HERE`nRIGHT NOW?"; Subtitle = 'A separate profile for every alter.'; Accent = '0xFFB5C6' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_chat.png'; Title = 'STAY CONNECTED'; Subtitle = 'Messages stay on your device.'; Accent = '0x65D6CB' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_calendar.png'; Title = "APPOINTMENTS`nIN VIEW"; Subtitle = 'See today. Find it again later.'; Accent = '0xA78BFA' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_meds.png'; Title = "REMINDERS`nWITHOUT PRESSURE"; Subtitle = 'Manage medication together.'; Accent = '0xD5A3FF' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_grounding.png'; Title = "GROUNDING.`nHERE AND NOW."; Subtitle = 'Five calm steps, always close.'; Accent = '0x52C5BD' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_help.png'; Title = 'HELP WHEN IT MATTERS'; Subtitle = 'Emergency and crisis support in reach.'; Accent = '0xFF5B62' }
  [pscustomobject]@{ Screenshot = Join-Path $work 'en_privacy.png'; Title = 'YOU SEE WHAT LEAVES'; Subtitle = 'Every transmission, word for word.'; Accent = '0xB9A3F5' }
)

for ($i = 0; $i -lt $cards.Count; $i++) {
  $name = 'phone-{0:D2}.png' -f ($i + 1)
  New-StoreCard -Card $cards[$i] -Destination (Join-Path $output $name)
}

Write-Output "English Play Store graphics: $output"
