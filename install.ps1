$ErrorActionPreference = "Stop"

Write-Host "=== Whisper Auto Install Tool ==="

# -------------------------------
# 1. Ensure Python 3.11 (fallback 3.10)
# -------------------------------

function Ensure-Python {
    param ([string]$Version)

    try {
        py -$Version --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (Ensure-Python "3.11") {
    $PY = "3.11"
    Write-Host "Python 3.11 detected"
}
elseif (Ensure-Python "3.10") {
    $PY = "3.10"
    Write-Host "Python 3.11 not found, using 3.10"
}
else {
    Write-Host "Python 3.11 not found. Installing..."
    winget install --id Python.Python.3.11 -e --source winget
    $PY = "3.11"
}

# -------------------------------
# 2. Install PyTorch (CUDA 12.1)
# -------------------------------

Write-Host "Installing PyTorch (CUDA 12.1)..."
py -$PY -m pip install --upgrade pip
py -$PY -m pip install torch torchvision torchaudio `
    --index-url https://download.pytorch.org/whl/cu121

# -------------------------------
# 3. Install ffmpeg
# -------------------------------

Write-Host "Installing ffmpeg..."
winget install --id Gyan.FFmpeg -e --source winget

# -------------------------------
# 4. Install Whisper
# -------------------------------

Write-Host "Installing OpenAI Whisper..."
py -$PY -m pip install -U openai-whisper

# -------------------------------
# 5. Installer completion notifier
# -------------------------------
Write-Host "=== Setup Complete ==="
Write-Host "Python, PyTorch, ffmpeg, and Whisper are installed."
Write-Host "You can now run Whisper manually."

# -------------------------------
# 6. Prompt to run Whisper
# -------------------------------
Write-Host ""
$run = Read-Host "Do you want to run Whisper now? (y/n)"

if ($run -ne "y") {
    Write-Host "Setup complete. Exiting."
    exit 0
}

# -------------------------------
# 7. Whisper Run Options
# -------------------------------

Write-Host ""
Write-Host "Select processing device:"
Write-Host "1) Auto (CUDA if available)"
Write-Host "2) CPU only"
Write-Host "3) Cancel"

$choice = Read-Host "Enter choice"

switch ($choice) {
    "1" { $DEVICE = "auto" }
    "2" { $DEVICE = "cpu" }
    default {
        Write-Host "Cancelled."
        exit 0
    }
}

# -------------------------------
# 7. Whisper Model Options
# -------------------------------

Write-Host ""
Write-Host "Select Whisper model:"
Write-Host "1) tiny    (fastest, lowest accuracy)"
Write-Host "2) base    (fast, decent)"
Write-Host "3) small   (balanced)"
Write-Host "4) medium  (accurate, slower)"
Write-Host "5) large   (most accurate, slowest)"
Write-Host "6) Cancel"

$modelChoice = Read-Host "Enter choice"

switch ($modelChoice) {
    "1" { $MODEL = "tiny" }
    "2" { $MODEL = "base" }
    "3" { $MODEL = "small" }
    "4" { $MODEL = "medium" }
    "5" { $MODEL = "large" }
    default {
        Write-Host "Cancelled."
        exit 0
    }
}

# -------------------------------
# 8. Whisper Output Format Options
# ------------------------------
Write-Host ""
Write-Host "Select output format:"
Write-Host "1) txt  (plain text)"
Write-Host "2) srt  (timed subtitles)"
Write-Host "3) vtt  (web subtitles)"
Write-Host "4) json (full metadata)"
Write-Host "5) tsv  (timestamps)"
Write-Host "6) all  (everything)"
Write-Host "7) Cancel"

$formatChoice = Read-Host "Enter choice"

switch ($formatChoice) {
    "1" { $FORMAT = "txt" }
    "2" { $FORMAT = "srt" }
    "3" { $FORMAT = "vtt" }
    "4" { $FORMAT = "json" }
    "5" { $FORMAT = "tsv" }
    "6" { $FORMAT = "all" }
    default {
        Write-Host "Cancelled."
        exit 0
    }
}

$outputDir = Join-Path $PWD "generated"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# -------------------------------
# 9. Prompt for audio file path
# -------------------------------

Write-Host ""
$audio = Read-Host "Enter path to audio file"

if (-not (Test-Path $audio)) {
    Write-Host "File not found."
    exit 1
}

# -------------------------------
# 10. Run Whisper
# ------------------------------
Write-Host ""
Write-Host "Running Whisper..."

if ($DEVICE -eq "cpu") {
    py -3.11 -m whisper "$audio" `
  --model $MODEL `
  --device cpu `
  --output_dir "$outputDir" `
  --output_format $FORMAT
}
else {
    py -3.11 -m whisper "$audio" `
  --model $MODEL `
  --output_dir "$outputDir" `
  --output_format $FORMAT
}
# -------------------------------
# 11. Rename output to generated.<format>
# -------------------------------
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($audio)
$src = Join-Path $outputDir "$baseName.$FORMAT"
$dst = Join-Path $outputDir "generated.$FORMAT"

if (Test-Path $src) {
    Move-Item -Force $src $dst
    Write-Host "Saved: $dst"
} else {
    Write-Host "Expected output not found: $src"
}
