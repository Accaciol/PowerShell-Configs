fastfetch

# --- 1. Módulos e Histórico ---
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# --- 2. Oh My Posh (Pasta Local Estável) ---
$myThemesDir = "$HOME\.poshthemes"
$themeName = "tokyonight.omp.json" 
$themePath = Join-Path $myThemesDir $themeName

if (Test-Path $themePath) {
    oh-my-posh init pwsh --config $themePath | Invoke-Expression
} else {
    # Caso o tema não exista, inicia o básico
    oh-my-posh init pwsh | Invoke-Expression
}

# --- 3. Função para Trocar de Tema ---
function Set-PoshTheme {
    param([string]$name)
    $themesDir = "$HOME\.poshthemes"
    if ($name -notlike "*.omp.json") { $name = "$name.omp.json" }
    $file = Join-Path $themesDir $name
    
    if (Test-Path $file) {
        oh-my-posh init pwsh --config $file | Invoke-Expression
        Write-Host "Tema alterado para: $name" -ForegroundColor Cyan
    } else {
        Write-Host "Tema '$name' não encontrado em $themesDir" -ForegroundColor Red
    }
}

# --- 4. Aliases ---
Set-Alias st Set-PoshTheme
Set-Alias setTheme Set-PoshTheme
Set-Alias g git
Set-Alias ll Get-ChildItem
function conf { notepad $PROFILE }


# Melhora a predição e adiciona o menu interativo
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Facilita a navegação no histórico com as setas para cima/baixo
# (Filtra o histórico pelo que você já digitou)
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward