# --- 1. Visual e Inicialização ---
fastfetch
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# --- 2. Oh My Posh (Tema TokyoNight) ---
$themePath = "$HOME\.poshthemes\tokyonight.omp.json"
if (Test-Path $themePath) {
    oh-my-posh init pwsh --config $themePath | Invoke-Expression
} else {
    oh-my-posh init pwsh | Invoke-Expression
}

# --- 3. Comportamento do Terminal (PSReadLine) ---
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- 4. Aliases e Funções ---
Set-Alias g git
Set-Alias ll Get-ChildItem
function conf { notepad $PROFILE }
function st { 
    param($name) 
    $file = "$HOME\.poshthemes\$name.omp.json"
    if (Test-Path $file) { 
        oh-my-posh init pwsh --config $file | Invoke-Expression 
    } else { 
        Write-Host "Tema não encontrado." -ForegroundColor Red 
    }
}
