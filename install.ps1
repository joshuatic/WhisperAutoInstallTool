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