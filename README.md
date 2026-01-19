# Whisper Auto Install Tool

A **Windows installer script** that prepares your system to run
[OpenAI Whisper](https://github.com/openai/whisper).

This tool **only installs prerequisites**.  
It does NOT run Whisper for you.

---

## What this installs

- **Python 3.11** (falls back to 3.10 if needed)
- **PyTorch + CUDA 12.1**
- **ffmpeg**
- **openai-whisper**

Safe to re-run. Already-installed components are skipped.

---

## Requirements

- Windows 10 / 11
- `winget` available
- NVIDIA GPU recommended (CUDA 12.1)
  - CPU-only Whisper still works, just slower

---

## How to run

Open **PowerShell** in the repo folder and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```
## Licensing

This project is licensed under the MIT License.

You are free to use, modify, distribute, and sublicense this software, including for commercial purposes, provided that the original copyright notice and license are included.
