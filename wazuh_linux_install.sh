#!/bin/bash

detect_os() {
    if [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ] || [ -f /etc/fedora-release ]; then
        echo "rhel"
    elif [ -f /etc/openSUSE-release ]; then
        echo "suse"
    else
        echo "Desconhecido"
        exit 1
    fi
}

install_wazuh_agent() {
    OS=$(detect_os)
    if [ "$OS" = "debian" ]; then
        wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.2-1_amd64.deb
        WAZUH_MANAGER='SEU_SERVER_AQUI' WAZUH_AGENT_GROUP='Linux' dpkg -i ./wazuh-agent_4.14.2-1_amd64.deb
    elif [ "$OS" = "rhel" ] || [ "$OS" = "suse" ]; then
        curl -o wazuh-agent-4.14.2-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.14.2-1.x86_64.rpm
        WAZUH_MANAGER='SEU_SERVER_AQUI' WAZUH_AGENT_GROUP='Linux' rpm -ihv wazuh-agent-4.14.2-1.x86_64.rpm
    else
        echo "Sistema não suportado"
        exit 1
    fi
    systemctl enable wazuh-agent
    systemctl start wazuh-agent
    echo "Instalação concluída com sucesso!"
}

uninstall_wazuh_agent() {
    OS=$(detect_os)
    if [ "$OS" = "debian" ]; then
        dpkg -l | grep -q wazuh-agent && dpkg -r --force-dep-check wazuh-agent
    elif [ "$OS" = "rhel" ] || [ "$OS" = "suse" ]; then
        rpm -q wazuh-agent && rpm -e wazuh-agent
    fi
    rm -rf /var/ossec/ /var/lib/wazuh/ /etc/wazuh/
    echo "Desinstalação concluída com sucesso!"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root. Use sudo ou logged como root."
    exit 1
fi

if dpkg -l | grep -q wazuh-agent || rpm -q wazuh-agent >/dev/null 2>&1 || zypper info wazuh-agent >/dev/null 2>&1; then
    echo "O agente Wazuh já está instalado. Realizando a desinstalação..."
    uninstall_wazuh_agent
fi

install_wazuh_agent
