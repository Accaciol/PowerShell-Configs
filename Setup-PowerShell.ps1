<#
.SYNOPSIS
    Script de configuração completa do PowerShell 7 para Desenvolvedores (TJRJ).
    Instala: Oh My Posh, Fastfetch, Terminal-Icons e Temas Oficiais.
#>

Write-Host "--- Iniciando Configuração do Ambiente PowerShell 7 ---" -ForegroundColor Cyan

# 1. Elevação de privilégio e Política de Execução
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Instalação de Binários via Winget
Write-Host "[1/5] Instalando Oh My Posh e Fastfetch..." -ForegroundColor Yellow
winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
winget install fastfetch --accept-package-agreements

# 3. Instalação de Módulos do PowerShell
Write-Host "[2/5] Instalando Módulo Terminal-Icons..." -ForegroundColor Yellow
if (!(Get-Module -ListAvailable Terminal-Icons)) {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -AllowClobber
}

# 4. Infraestrutura de Temas
Write-Host "[3/5] Configurando pasta de temas e baixando biblioteca oficial..." -ForegroundColor Yellow
$themeDir = "$HOME\.poshthemes"
if (!(Test-Path $themeDir)) { New-Item -Path $themeDir -ItemType Directory -Force }

$themeUrl = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip"
$zipPath = Join-Path $themeDir "themes.zip"

Invoke-WebRequest -Uri $themeUrl -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $themeDir -Force
Remove-Item $zipPath

# 5. Configuração do Perfil ($PROFILE)
Write-Host "[4/5] Escrevendo configurações no arquivo de Perfil..." -ForegroundColor Yellow
$profileContent = @"
# --- Visual e Inicialização ---
fastfetch
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# --- Prompt (Oh My Posh) ---
# Usando TokyoNight como padrão, mas você pode trocar usando a função 'st'
`$themePath = "`$HOME\.poshthemes\tokyonight.omp.json"
if (Test-Path `$themePath) {
    oh-my-posh init pwsh --config `$themePath | Invoke-Expression
} else {
    oh-my-posh init pwsh | Invoke-Expression
}

# --- Inteligência de Terminal (PSReadLine) ---
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Aliases e Funções Úteis ---
Set-Alias g git
Set-Alias ll Get-ChildItem
function conf { notepad `$PROFILE }
function st { 
    param(`$name) 
    `$file = "`$HOME\.poshthemes\`$name.omp.json"
    if (Test-Path `$file) { 
        oh-my-posh init pwsh --config `$file | Invoke-Expression 
        `$env:POSH_THEME = `$file
    } else { 
        Write-Host "Tema não encontrado em `$HOME\.poshthemes" -ForegroundColor Red 
    }
}
"@

# Garante que a pasta do Profile existe antes de criar o arquivo
$profileDir = Split-Path -Path $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force }

Set-Content -Path $PROFILE -Value $profileContent -Encoding utf8

# 6. Finalização e Instrução de Fonte
Write-Host "[5/5] Instalação Concluída!" -ForegroundColor Green
Write-Host "`nIMPORTANTE:" -ForegroundColor Magentax
Write-Host "1. Execute 'oh-my-posh font install' e escolha uma Nerd Font (ex: CascadiaCode NF)." -ForegroundColor White
Write-Host "2. No Windows Terminal (Ctrl+,), altere a fonte do perfil para a que você instalou." -ForegroundColor White
Write-Host "3. Digite '. `$PROFILE' para carregar as alterações agora." -ForegroundColor White
