$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

if (-not $env:OPENAI_API_KEY) {
    Write-Host "OPENAI_API_KEY is not set in this PowerShell."
    Write-Host 'Set it first, then run again:'
    Write-Host '$env:OPENAI_API_KEY="sk-..."'
    exit 1
}

python -m pip show openai | Out-Null
if ($LASTEXITCODE -ne 0) {
    python -m pip install --user openai
}

python tools\generate_character_voices.py @args

$count = (Get-ChildItem -Path DeepChess\Resources\Voices -Filter *.mp3 -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "Generated mp3 count: $count"

