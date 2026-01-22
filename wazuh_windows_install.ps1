$WazuhAgentName = "Wazuh Agent"
$InstallerUrl = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.2-1.msi"
$TempPath = $env:TEMP
$InstallerFile = Join-Path $TempPath "wazuh-agent"

$Installed = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*$WazuhAgentName*" }
if ($Installed) {
    $ProductCode = $Installed.IdentifyingNumber
    echo "Desinstalando o agente Wazuh..."
    Start-Process msiexec -ArgumentList "/x `$ProductCode /qn" -Wait
}

echo "Baixando o agente Wazuh..."
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerFile

echo "Instalando o agente Wazuh..."
Start-Process msiexec -ArgumentList "/i `$InstallerFile /q WAZUH_MANAGER='SEU_SERVER_AQUI' WAZUH_AGENT_GROUP='Windows'" -Wait

echo "Iniciando o serviço do agente Wazuh..."
Start-Service WazuhAgent

echo "Instalação concluída com sucesso!"
