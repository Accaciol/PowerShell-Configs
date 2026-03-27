<#
.SYNOPSIS
    Perfil do PowerShell 7 - Edição Desenvolvedor / QA Sênior
    Configurações de UI, Predição, Robot Framework e Git.
#>

# --- 1. Global: Fix de Encoding e Performance ---
$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PYTHONIOENCODING = "UTF-8"
$ErrorActionPreference = "Continue"

# --- 2. Visual: Oh My Posh & Terminal-Icons ---
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

$themePath = Join-Path $HOME ".poshthemes\tokyonight.omp.json"
if (Test-Path $themePath) {
    oh-my-posh init pwsh --config $themePath | Invoke-Expression
} else {
    oh-my-posh init pwsh | Invoke-Expression
}

# --- 3. Inteligência de Terminal (PSReadLine) ---
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCaseSensitive:$false

# Atalhos de Teclado
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardWord # Aceita sugestão

# --- 4. Funções de QA (Robot Framework & BrowserLibrary) ---

# Roda Robot limpando logs e artefatos do browser
function rrun {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )
    $outputDir = "results"
    
    Write-Host "[-] Limpando artefatos anteriores..." -ForegroundColor Yellow
    if (Test-Path $outputDir) { Remove-Item "$outputDir\*" -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path "browser") { Remove-Item "browser\*" -Recurse -Force -ErrorAction SilentlyContinue }

    Write-Host "[+] Executando Robot Framework..." -ForegroundColor Cyan
    robot --outputdir $outputDir $args
}

# Abre o último log gerado
function rlog {
    $log = "results/log.html"
    if (Test-Path $log) { Start-Process $log } else { Write-Host "Log nao encontrado." -ForegroundColor Red }
}

# --- 5. Funções de Sistema e Corretor ---

# Fix do 'thefuck' para Windows/PS7
function fuck {
    $env:PYTHONIOENCODING = "utf-8"
    if (Get-Command thefuck -ErrorAction SilentlyContinue) {
        $last_command = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()[-1].CommandLine
        if ($last_command) {
            # O thefuck precisa do alias registrado na sessão
            iex $(thefuck --alias)
        }
    } else {
        Write-Host "thefuck nao instalado. Use: pip install thefuck" -ForegroundColor Red
    }
}

# Troca de tema do Oh My Posh de forma dinâmica
function st { 
    param($name) 
    $file = Get-ChildItem -Path "$HOME\.poshthemes" -Filter "*$name*" | Select-Object -First 1
    if ($file) { 
        oh-my-posh init pwsh --config $file.FullName | Invoke-Expression 
        $env:POSH_THEME = $file.FullName
        Write-Host "Tema '$($file.BaseName)' aplicado!" -ForegroundColor Cyan
    } else { 
        Write-Host "Tema '$name' nao encontrado." -ForegroundColor Red 
    }
}

# --- 6. Aliases (Quick Actions) ---
Set-Alias g git
Set-Alias gs "git status"
Set-Alias rr rrun
Set-Alias rl rlog
Set-Alias c clear
Set-Alias ll Get-ChildItem
function conf { notepad $PROFILE }
function code. { code . }
function top { Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 }

Write-Host "`n[!] Ambiente pronto para Automacao, Lucas." -ForegroundColor Magenta
