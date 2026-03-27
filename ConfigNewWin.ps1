# Script de Otimização de Registro para Estabilidade AMD
# Requer privilégios de Administrador

$ErrorActionPreference = "Stop"

write-host "--- Iniciando Aplicacão de Fixes para GPU AMD ---" -ForegroundColor Cyan

# Fix 1: Desabilitar MPO (Multi-Plane Overlay)
$dwmPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
$overlayName = "OverlayTestMode"
$overlayValue = 5

if (-not (Test-Path $dwmPath)) {
    New-Item -Path $dwmPath -Force | Out-Null
}

write-host "[+] Aplicando Fix 1: Desabilitando MPO..." -NoNewline
Set-ItemProperty -Path $dwmPath -Name $overlayName -Value $overlayValue -Type DWord
write-host " [OK]" -ForegroundColor Green

# Fix 2: Aumentar TDR Delay (Timeout da GPU)
$gfxPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$tdrName = "TdrDelay"
$tdrValue = 8

write-host "[+] Aplicando Fix 2: Aumentando TDR Delay para ${tdrValue}s..." -NoNewline
Set-ItemProperty -Path $gfxPath -Name $tdrName -Value $tdrValue -Type DWord
write-host " [OK]" -ForegroundColor Green

# Fix 3: Limpeza de Shader Cache (Via Sistema de Arquivos)
# Nota: Isso limpa o cache de arquivos, similar ao que o Adrenalin faz.
$shaderPath = "$env:LOCALAPPDATA\AMD\DxCache"

write-host "[!] Tentando limpar Shader Cache em $shaderPath..."
if (Test-Path $shaderPath) {
    try {
        Remove-Item -Path "$shaderPath\*" -Recurse -Force -ErrorAction SilentlyContinue
        write-host " [OK] Cache limpo (arquivos em uso foram ignorados)." -ForegroundColor Green
    } catch {
        write-host " [!] Aviso: Alguns arquivos de cache nao puderam ser removidos pois estao em uso." -ForegroundColor Yellow
    }
}

write-host "--- Processo Concluido. Reinicie o computador para aplicar as alteracoes. ---" -ForegroundColor Cyan
