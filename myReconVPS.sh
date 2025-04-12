#!/bin/bash
# myReconVPS.sh - Script para automatizar a instalação de ferramentas
# Renato Andalik

# ULTIMA ATUALIZACAO: 11/04/2025

# Definição de variáveis globais
declare -A commands
declare -a order
declare -a failed_tools
declare -A skipped_tools

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

LOG_FILE="$SCRIPT_DIR/install_log.txt"
RESUME_FILE="$SCRIPT_DIR/.install_state"
SCRIPT_VERSION="1.2025.003"
SECONDS=0
RESUME_INSTALL=false
INSTALLATION_STARTED=false

# Cores para saída no terminal
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# banner()
# Função para exibir o banner
banner() {
    clear

    echo -e "${GREEN}"
    echo -e '                  _____                  __      _______   _____'
    echo -e '                 |  __ \                 \ \    / /  __ \ / ____|'
    echo -e '  _ __ ___  _   _| |__) |___  ___ ___  _ _\ \  / /| |__) | (___'
    echo -e ' | `_ ` _ \| | | |  _  // _ \/ __/ _ \| `_ \ \/ / |  ___/ \___ \'
    echo -e ' | | | | | | |_| | | \ \  __/ (_| (_) | | | \  /  | |     ____) |'
    echo -e ' |_| |_| |_|\__, |_|  \_\___|\___\___/|_| |_|\/   |_|    |_____/'
    echo -e '             __/ |                                    by Andalik'
    echo -e '            |___/'
    echo -e "  ${YELLOW}v${SCRIPT_VERSION}${NC}\n"

    echo -e "${CYAN}Sistema:${NC} $(uname -a)"
    echo -e "${CYAN}Log:${NC} $LOG_FILE\n"
}

# log()
# Função para registrar mensagens de log
log() {
    local level=$1
    local message=$2
    local silent=$3
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [ -z "$silent" ]; then
        echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
    else
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# check_result()
# Função para verificar se o comando foi executado com sucesso
check_result() {
    local tool=$1
    local exit_code=$2
    local output=$3
    
    if [ $exit_code -ne 0 ]; then
        log "ERRO" "Falha ao instalar $tool: $output"
        failed_tools+=("$tool")
        return 1
    else
        log "INFO" "$tool instalado com sucesso"
        return 0
    fi
}

# check_os()
# Função para verificar compatibilidade com o sistema operacional
check_os() {
    if [[ -e /etc/debian_version ]]; then
        OS="debian"
        source /etc/os-release

        if [[ $ID == "kali" ]]; then
            OS="kali"
            log "INFO" "Kali Linux detectado: $VERSION_ID" "no_console_output"
            echo -e "${GREEN}[INFO]${NC} Kali Linux $VERSION_ID detectado"
            
        elif [[ $ID == "debian" || $ID == "raspbian" ]]; then
            if [[ $VERSION_ID -lt 9 ]]; then
                log "AVISO" "Versão do Debian não suportada: $VERSION_ID (recomendado >= 9)" "no_console_output"
                echo -e "${YELLOW}[AVISO]${NC} Sua versão do Debian $VERSION_ID não é oficialmente suportada."
                echo -e "${YELLOW}[AVISO]${NC} Recomendado: Debian 9 ou superior."
                echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (por sua conta e risco)"
                until [[ $CONTINUE =~ (s|n) ]]; do
                    read -rp "Continuar? [s/n]: " -e CONTINUE
                done
                if [[ $CONTINUE == "n" ]]; then
                    log "INFO" "Instalação abortada pelo usuário devido a versão do sistema não suportada"
                    exit 1
                fi
            fi
        elif [[ $ID == "ubuntu" ]]; then
            OS="ubuntu"
            MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
            if [[ $MAJOR_UBUNTU_VERSION -lt 22 ]]; then
                log "AVISO" "Versão do Ubuntu não suportada: $VERSION_ID (recomendado >= 22.04)" "no_console_output"
                echo -e "${YELLOW}[AVISO]${NC} Sua versão do Ubuntu $VERSION_ID não é oficialmente suportada."
                echo -e "${YELLOW}[AVISO]${NC} Recomendado: Ubuntu 22.04 ou superior."
                echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (por sua conta e risco)"
                until [[ $CONTINUE =~ (s|n) ]]; do
                    read -rp "Continuar? [s/n]: " -e CONTINUE
                done
                if [[ $CONTINUE == "n" ]]; then
                    log "INFO" "Instalação abortada pelo usuário devido a versão do sistema não suportada"
                    exit 1
                fi
            fi
        else
            log "AVISO" "Distribuição Linux $ID não testada. Baseado em Debian, tentando prosseguir." "no_console_output"
            echo -e "${YELLOW}[AVISO]${NC} Distribuição Linux $ID não foi testada oficialmente."
            echo -e "${YELLOW}[AVISO]${NC} Baseada em Debian, tentando prosseguir."
            echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (por sua conta e risco)"
            until [[ $CONTINUE =~ (s|n) ]]; do
                read -rp "Continuar? [s/n]: " -e CONTINUE
            done
            if [[ $CONTINUE == "n" ]]; then
                log "INFO" "Instalação abortada pelo usuário devido a distribuição não suportada"
                exit 1
            fi
        fi
        log "INFO" "Sistema operacional compatível: $ID $VERSION_ID" "no_console_output"
    else
        log "ERRO" "Sistema operacional não suportado. Este script é para distribuições baseadas em Debian." "no_console_output"
        echo -e "${RED}[ERRO]${NC} Sistema operacional não suportado."
        echo -e "${YELLOW}[INFO]${NC} Este script foi projetado para distribuições baseadas em Debian como:"
        echo -e "${YELLOW}[INFO]${NC} - Debian"
        echo -e "${YELLOW}[INFO]${NC} - Ubuntu"
        echo -e "${YELLOW}[INFO]${NC} - Kali Linux"
        echo -e "${YELLOW}[INFO]${NC} - Raspbian"
        exit 1
    fi
}

# check_disk_space()
# Função para verificar espaço em disco
check_disk_space() {
    # min_space é definido no arquivo myReconVPS.tools
    local available=$(df -BG / | awk '{print $4}' | tail -1 | tr -d 'G')
    
    if [ "$available" -lt "$min_space" ]; then
        log "AVISO" "Espaço em disco insuficiente: $available GB. Mínimo recomendado: $min_space GB" "no_console_output"
        echo -e "${YELLOW}[AVISO]${NC} Espaço em disco disponível: $available GB"
        echo -e "${YELLOW}[AVISO]${NC} Espaço mínimo recomendado: $min_space GB"
        echo -n -e "\n${YELLOW}[AVISO]${NC} Deseja continuar mesmo assim? (s/n): "
        read -r choice
        if [[ "$choice" != "s" && "$choice" != "S" ]]; then
            log "INFO" "Instalação abortada pelo usuário devido a espaço em disco insuficiente"
            exit 1
        fi
    fi
}

# check_dependencies()
# Função para verificar dependencias
check_dependencies() {
    local deps=("curl" "wget" "git")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        log "AVISO" "Dependencias faltantes: ${missing_deps[*]}" "no_console_output"
        echo -e "${YELLOW}[AVISO]${NC} As seguintes dependencias estão faltando: ${missing_deps[*]}"
        echo -e "${YELLOW}[AVISO]${NC} Instalando dependencias..."
        apt-get update > /dev/null 2>&1
        for dep in "${missing_deps[@]}"; do
            apt-get install -y "$dep" > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                log "ERRO" "Falha ao instalar dependencia: $dep" "no_console_output"
                echo -e "${RED}[ERRO]${NC} Falha ao instalar dependencia: $dep"
                exit 1
            fi
        done
        echo -e "${GREEN}[OK]${NC} Dependencias instaladas com sucesso"
    fi
}

# save_state()
# Função para salvar o estado atual da instalação
save_state() {
    local progress=$1
    local tools_done="${@:2}"
    
    # Salvar todas as ferramentas selecionadas (ordem atual de instalação)
    # Envolver em aspas para evitar problemas com espaços e caracteres especiais
    local selected_tools=("${order[@]}")
    
    echo "PROGRESS=$progress" > "$RESUME_FILE"
    # Usar arrays para evitar que nomes de ferramentas sejam interpretados como comandos
    echo "TOOLS_DONE=(${tools_done// /' '})" >> "$RESUME_FILE"
    echo "SELECTED_TOOLS=(${selected_tools[@]})" >> "$RESUME_FILE"
    echo "TIMESTAMP=$(date +%s)" >> "$RESUME_FILE"
    
    log "INFO" "Estado da instalação salvo (progresso: $progress, selecionadas: ${#order[@]})"
}

# load_state()
# Função para carregar o estado anterior da instalação
load_state() {
    if [ -f "$RESUME_FILE" ]; then
        # Usar o . (ponto) em vez de source para carregar o arquivo, é mais seguro
        . "$RESUME_FILE"
        
        # Verificar se todas as variáveis necessárias existem e são arrays
        if [ -n "$PROGRESS" ] && [ ${#TOOLS_DONE[@]} -ge 0 ] && [ -n "$TIMESTAMP" ] && [ ${#SELECTED_TOOLS[@]} -gt 0 ]; then
            local current_time=$(date +%s)
            local elapsed=$((current_time - TIMESTAMP))
            local elapsed_formatted=$(printf "%02d:%02d:%02d" $((elapsed/3600)) $(( (elapsed%3600)/60 )) $((elapsed%60)))
            
            # Ferramentas pendentes (usando slicing de array)
            local pending_tools=("${SELECTED_TOOLS[@]:$PROGRESS}")
            
            echo -e "${YELLOW}[AVISO]${NC} Encontrada instalação incompleta iniciada há $elapsed_formatted"
            echo -e "${YELLOW}[AVISO]${NC} Progresso: $PROGRESS de ${#SELECTED_TOOLS[@]} ferramentas"
            echo -e "${YELLOW}[AVISO]${NC} Ferramentas já instaladas: ${TOOLS_DONE[*]}"
            echo -e "${YELLOW}[AVISO]${NC} Ferramentas pendentes: ${pending_tools[*]}"
            echo -n -e "\n${YELLOW}[AVISO]${NC} Deseja continuar de onde parou? (s/n): "
            read -r choice
            if [[ "$choice" == "s" || "$choice" == "S" ]]; then
                # Restaurar a seleção de ferramentas original
                order=("${SELECTED_TOOLS[@]}")
                log "INFO" "Continuando instalação a partir do progresso: $PROGRESS com ${#order[@]} ferramentas selecionadas"
                # Flag para pular a seleção de ferramentas
                RESUME_INSTALL=true
                return 0
            fi
        else
            log "AVISO" "Arquivo de estado encontrado mas inválido ou incompleto. Iniciando nova instalação."
            rm -f "$RESUME_FILE"
        fi
    fi
    log "INFO" "Iniciando nova instalação"
    return 1
}

# select_tools()
# Função para exibir menu de seleção de ferramentas
select_tools() {
    # Se estamos retomando uma instalação, não precisamos selecionar ferramentas novamente
    if [ "$INSTALL_ALL" == "true" ] || [ "$RESUME_INSTALL" == "true" ]; then
        return
    fi
    
    echo -e "\n${CYAN}=== Selecione as ferramentas para instalação ===${NC}"
    echo -e "${CYAN}0. ${NC}Instalar e/ou atualizar todas as ferramentas"
    
    local i=1
    for tool in "${order[@]}"; do
        echo -e "${CYAN}$i. ${NC}$tool"
        i=$((i+1))
    done
    
    echo -e "\n${YELLOW}Digite os números das ferramentas separados por espaço (ex: 1 3 5)${NC}"
    echo -n -e "${YELLOW}ou digite '0' para instalar todas:${NC} "
    read -r choices
    
    if [[ "$choices" == "0" ]]; then
        return
    fi
    
    # Criar uma cópia da ordem original
    local original_order=("${order[@]}")
    order=()
    
    for choice in $choices; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#original_order[@]}" ]; then
            order+=("${original_order[$((choice-1))]}")
        fi
    done
    
    # Verificar se foram selecionadas ferramentas válidas
    if [ ${#order[@]} -eq 0 ]; then
        echo -e "${RED}[ERRO]${NC} Nenhuma ferramenta válida selecionada. Saindo."
        exit 1
    fi
        
    echo -e "\n${GREEN}Selecionadas ${#order[@]} ferramentas para instalação:${NC}"
    for tool in "${order[@]}"; do
        echo -e "${GREEN}- ${NC}$tool"
    done
    
    # Confirmação antes de continuar e criar o arquivo de estado
    echo -n -e "\n${YELLOW}Continuar com a instalação destas ferramentas? (s/n): ${NC}"
    read -r confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo -e "${YELLOW}[AVISO]${NC} Instalação cancelada pelo usuário."
        exit 0
    fi
    
    # Só salvamos o estado após a confirmação do usuário
    # Isso evita criar o arquivo .install_state prematuramente
    save_state 0 ""
}

# show_progress()
# Função para exibir barra de progresso
show_progress() {
    local current=$1
    local total=$2
    local tool_name=$3

    if [ -z "$current" ] || [ -z "$total" ] || [ "$total" -eq 0 ]; then
        return
    fi

    local perc=$(( (current * 100) / total ))
    local filled=$(( (perc * 50) / 100 ))
    local unfilled=$(( 50 - filled ))
    local status=""
    
    # Determina a cor com base no percentual de conclusão
    local color="${BLUE}"
    if [ "$perc" -lt 99 ]; then
        color="${RED}"
    elif [ "$perc" -le 100 ]; then
        color="${GREEN}"
    fi
    
    # Move o cursor uma linha para cima e atualiza a barra de progresso
    echo -ne "\r\e[KProgresso: |${color}$(printf '#%.0s' $(seq 1 $filled))${NC}$(printf ' %.0s' $(seq 1 $unfilled))| ${color}$perc%${NC}\n"
}

# handle_interrupt()
# Função para tratamento de interrupções (CTRL+C)
handle_interrupt() {
    echo -e "\n${YELLOW}[AVISO]${NC} Instalação interrompida pelo usuário"
    
    # Só salvar o estado se já estivermos no processo de instalação
    # (após o menu de seleção de ferramentas)
    if [ "$INSTALLATION_STARTED" == "true" ]; then
        log "AVISO" "Instalação interrompida pelo usuário no progresso: $progress de $total_commands"
        save_state "$progress" "${installed_tools[*]}"
        echo -e "${YELLOW}[AVISO]${NC} Estado da instalação salvo. Execute novamente o script para continuar."
    else
        log "AVISO" "Script interrompido pelo usuário antes do início da instalação"
        echo -e "${YELLOW}[AVISO]${NC} Nenhuma instalação iniciada. Nenhum estado salvo."
        # Garantir que qualquer arquivo de estado parcial seja removido
        rm -f "$RESUME_FILE"
    fi
    exit 130
}


# Corra Forrest, corra...
banner

# Checar privilégios de superusuário
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERRO]${NC} Necessário privilégios de superusuário."
    echo -e "${YELLOW}[DICA]${NC} Execute: sudo $0"
    exit 1
fi

# Inicializar arquivo de log
mkdir -p "$(dirname "$LOG_FILE")"
echo "# Log de instalação iniciado em $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
log "INFO" "Iniciando execução do script myReconVPS.sh v$SCRIPT_VERSION" "no_console_output"

# Identificar tipo de shell
SHELL_TYPE=$(basename "$SHELL")
CONFIG_FILE=$HOME/$(case $SHELL_TYPE in bash) echo '.bashrc' ;; zsh) echo '.zshrc' ;; *) echo '.profile' ;; esac)
log "INFO" "Shell detectado: $SHELL_TYPE, usando arquivo de configuração: $CONFIG_FILE" "no_console_output"

# Carregar configurações de ferramentas
TOOLS_CONF="$SCRIPT_DIR/myReconVPS.tools"
if [ -f "$TOOLS_CONF" ]; then
    log "INFO" "Carregando configurações de ferramentas de $TOOLS_CONF" "no_console_output"
    # Inicializar o array order vazio antes de carregar as configurações
    order=()
    source "$TOOLS_CONF"
else
    log "ERRO" "Arquivo de configuração $TOOLS_CONF não encontrado" "no_console_output"
    echo -e "${RED}[ERRO]${NC} Arquivo de configuração $TOOLS_CONF não encontrado"
    echo -e "Execução interrompida. Saindo..."
    exit 1
fi

# Verificar se temos ferramentas carregadas
if [ ${#order[@]} -eq 0 ]; then
    log "ERRO" "Nenhuma ferramenta foi carregada do arquivo de configuração" "no_console_output"
    echo -e "${RED}[ERRO]${NC} Nenhuma ferramenta foi carregada do arquivo de configuração"
    echo -e "Execução interrompida. Saindo..."
    exit 1
fi

# Checar compatibilidade com o sistema operacional
check_os

# Verificar espaço mínimo em disco
check_disk_space

# Verificar instalação de dependências
check_dependencies

# Opções de linha de comando
while getopts ":ha" opt; do
    case ${opt} in
    h )
        echo -e "\n${CYAN}Uso:${NC} $0 [-h] [-a]\n"
        echo -e "${CYAN}Opções:${NC}"
        echo -e "  -h\tExibe esta ajuda"
        echo -e "  -a\tInstala todas as ferramentas sem perguntar\n"
        exit 0
        ;;
    a )
        INSTALL_ALL=true
        log "INFO" "Modo de instalação automática ativado (todas as ferramentas)"
        ;;
    \? )
        echo -e "${RED}[ERRO]${NC} Opção inválida: -$OPTARG" 1>&2
        echo -e "${YELLOW}[DICA]${NC} Use -h para ajuda\n"
        exit 1
        ;;
    esac
done

# Capturar interrupções
trap handle_interrupt SIGINT SIGTERM

# Array para armazenar ferramentas instaladas com sucesso
declare -a installed_tools

# Verificar se deve retomar uma instalação anterior
progress=0
if [ -f "$RESUME_FILE" ] && load_state; then
    # Se retornar 0, há uma instalação a ser retomada
    progress=$PROGRESS
    # Reconstituir a lista de ferramentas já instaladas
    for tool in "${TOOLS_DONE[@]}"; do
        installed_tools+=("$tool")
    done
fi

# Permitir seleção de ferramentas se não estiver em modo automático
select_tools

# Calcular número total de comandos
total_commands=${#order[@]}
log "INFO" "Total de ferramentas para instalação: $total_commands"

# Verificar se existem ferramentas selecionadas (pode acontecer em casos de erro)
if [ ${#order[@]} -eq 0 ]; then
    log "ERRO" "Lista de ferramentas vazia após seleção. Possível erro de processamento."
    echo -e "\n${RED}[ERRO]${NC} Nenhuma ferramenta na lista de instalação. Saindo."
    rm -f "$RESUME_FILE"
    exit 1
fi

# Executar comandos de instalação na ordem definida
start_time=$(date +%s)
log "INFO" "Iniciando processo de instalação das ferramentas"

# Marcar que a instalação foi iniciada (usado para gerenciar interrupções)
INSTALLATION_STARTED=true

for tool in "${order[@]}"; do
    echo -e "\n---\n"

    # Verificar se a ferramenta já foi instalada em uma execução anterior
    if [[ " ${installed_tools[*]} " =~ " $tool " ]]; then
        log "INFO" "Pulando $tool... Instalação previamente detectada" "no_console_output"
        echo -e "${YELLOW}[AVISO]${NC} Pulando $tool... Instalação previamente detectada"
        continue
    fi
    
    cmd="${commands[$tool]}"
    
    show_progress $progress $total_commands "$tool"
    log "INFO" "Instalando $tool" "no_console_output"
    echo -e "\n${CYAN}[INFO]${NC} Instalando $tool. ${YELLOW}Aguarde...${NC}"
    
    # Capturar saída do comando para log e análise de erro
    output=$(eval "$cmd" 2>&1)
    exit_code=$?
    
    # Verificar resultado da instalação
    if ! check_result "$tool" "$exit_code" "$output"; then
        log "ERRO" "Detalhes do erro: $output"
        echo -e "${RED}[ERRO]${NC} Falha ao instalar $tool"
        echo -e "${YELLOW}[DICA]${NC} Verifique o log para mais detalhes: $LOG_FILE"
        echo -n -e "\n${YELLOW}[AVISO]${NC} Deseja continuar com as próximas ferramentas? (s/n): "
        read -r choice
        if [[ "$choice" != "s" && "$choice" != "S" ]]; then
            log "INFO" "Instalação interrompida pelo usuário após falha em: $tool"
            save_state "$progress" "${installed_tools[*]}"
            exit 1
        fi
        # Adiciona à lista de ferramentas puladas
        skipped_tools["$tool"]="Falha de instalação"
    else
        # Adiciona à lista de ferramentas instaladas com sucesso
        installed_tools+=("$tool")
        # Grava o progresso atual para possível retomada
        save_state "$progress" "${installed_tools[*]}"
        echo -e "${GREEN}[OK]${NC} $tool instalado com sucesso"

        # Recarrega o arquivo de configuração para tornar a ferramenta disponível imediatamente
        if [ -f "$CONFIG_FILE" ]; then
            source "$CONFIG_FILE" 2>/dev/null || true
        fi
    fi

    progress=$((progress + 1))
done

end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_formatted=$(printf "%02d:%02d:%02d" $((execution_time/3600)) $(( (execution_time%3600)/60 )) $((execution_time%60)))

echo -e "\n---\n"

show_progress $total_commands $total_commands
echo -e "\n${GREEN}Instalação concluída!${NC}"
log "INFO" "Processo de instalação finalizado em $execution_time_formatted"

# Exibir resumo das instalações
echo -e "\n${CYAN}[RESUMO DA INSTALAÇÃO]${NC}"
echo -e "${CYAN}Tempo total:${NC} $execution_time_formatted"
echo -e "${CYAN}Ferramentas solicitadas:${NC} $total_commands"
echo -e "${CYAN}Ferramentas instaladas:${NC} ${#installed_tools[@]}"

if [ ${#failed_tools[@]} -gt 0 ]; then
    echo -e "\n${RED}[FERRAMENTAS COM FALHA]${NC}"
    for tool in "${failed_tools[@]}"; do
        echo -e "${RED}- ${NC}$tool"
    done
fi

if [ ${#skipped_tools[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}[FERRAMENTAS PULADAS]${NC}"
    for tool in "${!skipped_tools[@]}"; do
        echo -e "${YELLOW}- ${NC}$tool: ${skipped_tools[$tool]}"
    done
fi

echo -e "\n${GREEN}[FERRAMENTAS INSTALADAS]${NC}"
for tool in "${installed_tools[@]}"; do
    echo -e "${GREEN}- ${NC}$tool"
done

# Remover arquivo de estado se a instalação for concluída com sucesso
if [ $progress -eq $total_commands ]; then
    log "INFO" "Instalação concluída com sucesso. Removendo arquivo de estado." "no_console_output"
    rm -f "$RESUME_FILE"
fi

log "INFO" "Execução do script finalizada com sucesso" "no_console_output"
echo -e "\n${GREEN}Hack the Planet!${NC}"
