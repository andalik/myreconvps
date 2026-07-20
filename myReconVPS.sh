#!/bin/bash
# myReconVPS.sh - Script para automatizar a instalação de ferramentas
# Renato Andalik

# ULTIMA ATUALIZACAO: 19/07/2026

# Falhas em qualquer parte de um pipe propagam o código de erro (evita que
# falhas fiquem mascaradas). NÃO usamos 'set -e': o fluxo depende de inspecionar
# $? por ferramenta e continuar.
set -o pipefail

# Definição de variáveis globais
declare -A commands
declare -a order
declare -a failed_tools
declare -A skipped_tools
declare -a installed_tools
declare -a menu_cat_of   # categoria de cada índice de "order" (para o menu)
declare -a RC_FILES      # arquivos de rc a atualizar (root e, se houver, usuário do sudo)

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

LOG_FILE="$SCRIPT_DIR/install_log.txt"
RESUME_FILE="$SCRIPT_DIR/.install_state"
SCRIPT_VERSION="1.2607.005"
SECONDS=0
RESUME_INSTALL=false
INSTALLATION_STARTED=false

# Flags de linha de comando (valores padrão)
INSTALL_ALL=false
DRY_RUN=false
ASSUME_YES=false
USE_COLOR=auto
SHOW_HELP=false
INVALID_OPT=false

# setup_ui()
# Configura cores e glifos de acordo com o terminal (TTY, NO_COLOR, UTF-8).
# Mantém toda a saída segura quando redirecionada para arquivo/pipe/CI.
setup_ui() {
    local color_on=true
    if [ "$USE_COLOR" = off ] || [ -n "${NO_COLOR:-}" ] || { [ "$USE_COLOR" = auto ] && [ ! -t 1 ]; }; then
        color_on=false
    fi

    if [ "$color_on" = true ]; then
        RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[0;33m"
        BLUE="\033[0;34m"; PURPLE="\033[0;35m"; CYAN="\033[0;36m"
        BOLD="\033[1m"; DIM="\033[2m"; NC="\033[0m"
    else
        RED=""; GREEN=""; YELLOW=""; BLUE=""; PURPLE=""; CYAN=""
        BOLD=""; DIM=""; NC=""
    fi

    # Glifos: usa Unicode quando o locale é UTF-8, senão cai para ASCII.
    if [[ "${LC_ALL:-}${LC_CTYPE:-}${LANG:-}" == *[Uu][Tt][Ff]* ]]; then
        BAR_FILL='█'; BAR_EMPTY='░'
        BOX_H='─'; BOX_V='│'; BOX_TL='┌'; BOX_TR='┐'; BOX_BL='└'; BOX_BR='┘'
        SPIN=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
        ARROW='›'
    else
        BAR_FILL='#'; BAR_EMPTY='-'
        BOX_H='-'; BOX_V='|'; BOX_TL='+'; BOX_TR='+'; BOX_BL='+'; BOX_BR='+'
        SPIN=('|' '/' '-' '\')
        ARROW='>'
    fi
}

# print_help()
# Exibe a ajuda de uso do script.
print_help() {
    echo -e "\n${CYAN}${BOLD}myReconVPS${NC} v${SCRIPT_VERSION}\n"
    echo -e "${CYAN}Uso:${NC} $0 [opções]\n"
    echo -e "${CYAN}Opções:${NC}"
    echo -e "  -h, --help\t\tExibe esta ajuda"
    echo -e "  -a, --all\t\tInstala/atualiza todas as ferramentas sem perguntar"
    echo -e "  -n, --dry-run\t\tSimula a instalação (não executa nada de fato)"
    echo -e "  -y, --yes\t\tResponde 'sim' automaticamente às confirmações"
    echo -e "      --no-color\tDesativa cores na saída\n"
}

# banner()
# Função para exibir o banner
banner() {
    clear 2>/dev/null || true

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

# confirm()
# Pergunta sim/não ao usuário. Respeita a flag -y (ASSUME_YES).
# Retorna 0 para "sim", 1 para "não".
confirm() {
    local prompt=$1 ans
    if [ "$ASSUME_YES" = true ]; then
        return 0
    fi
    read -rp "$prompt" ans
    [[ "$ans" =~ ^[sSyY]$ ]]
}

# add_path()
# Adiciona um ou mais diretórios ao PATH: persiste (idempotente) em todos os
# arquivos de rc de RC_FILES (root e usuário do sudo) e também no PATH da
# sessão atual. Substitui o antigo padrão 'grep -q ... || echo ... >> CONFIG',
# que mascarava falhas retornando 0 mesmo quando a etapa anterior falhava.
add_path() {
    local dir line rc
    for dir in "$@"; do
        line="export PATH=\$PATH:$dir"
        for rc in "${RC_FILES[@]}"; do
            [ -f "$rc" ] || : > "$rc"
            grep -qxF "$line" "$rc" 2>/dev/null || printf '%s\n' "$line" >> "$rc"
        done
        case ":$PATH:" in
            *":$dir:"*) ;;
            *) export PATH="$PATH:$dir" ;;
        esac
    done
}

# repeat_str()
# Repete uma string (inclusive multibyte/UTF-8) N vezes. Usar isto em vez de
# 'tr ' ' "$char"' porque o tr opera por byte e corrompe caracteres multibyte.
repeat_str() {
    local s=$1 n=$2 i out=''
    for ((i = 0; i < n; i++)); do out+="$s"; done
    printf '%s' "$out"
}

# make_bar()
# Constrói uma barra de progresso: <preenchidos> <largura total>.
# Usa loop (não printf com seq) para não imprimir caractere espúrio quando 0.
make_bar() {
    local filled=$1 width=$2 i out=''
    for ((i = 0; i < filled; i++)); do out+="$BAR_FILL"; done
    for ((i = filled; i < width; i++)); do out+="$BAR_EMPTY"; done
    printf '%s' "$out"
}

# check_result()
# Função para verificar se o comando foi executado com sucesso
check_result() {
    local tool=$1
    local exit_code=$2
    local output=$3

    if [ "$exit_code" -ne 0 ]; then
        log "ERRO" "Falha ao instalar $tool: $output" "no_console_output"
        failed_tools+=("$tool")
        return 1
    else
        log "INFO" "$tool instalado com sucesso" "no_console_output"
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
            if [[ ${VERSION_ID:-0} =~ ^[0-9]+$ ]] && [[ $VERSION_ID -lt 9 ]]; then
                log "AVISO" "Versão do Debian não suportada: $VERSION_ID (recomendado >= 9)" "no_console_output"
                echo -e "${YELLOW}[AVISO]${NC} Sua versão do Debian $VERSION_ID não é oficialmente suportada."
                echo -e "${YELLOW}[AVISO]${NC} Recomendado: Debian 9 ou superior."
                if ! confirm "$(echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (s/n): ")"; then
                    log "INFO" "Instalação abortada pelo usuário devido a versão do sistema não suportada"
                    exit 1
                fi
            fi
        elif [[ $ID == "ubuntu" ]]; then
            OS="ubuntu"
            MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
            if [[ ${MAJOR_UBUNTU_VERSION:-0} =~ ^[0-9]+$ ]] && [[ $MAJOR_UBUNTU_VERSION -lt 22 ]]; then
                log "AVISO" "Versão do Ubuntu não suportada: $VERSION_ID (recomendado >= 22.04)" "no_console_output"
                echo -e "${YELLOW}[AVISO]${NC} Sua versão do Ubuntu $VERSION_ID não é oficialmente suportada."
                echo -e "${YELLOW}[AVISO]${NC} Recomendado: Ubuntu 22.04 ou superior."
                if ! confirm "$(echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (s/n): ")"; then
                    log "INFO" "Instalação abortada pelo usuário devido a versão do sistema não suportada"
                    exit 1
                fi
            fi
        else
            log "AVISO" "Distribuição Linux $ID não testada. Baseado em Debian, tentando prosseguir." "no_console_output"
            echo -e "${YELLOW}[AVISO]${NC} Distribuição Linux $ID não foi testada oficialmente."
            echo -e "${YELLOW}[AVISO]${NC} Baseada em Debian, tentando prosseguir."
            if ! confirm "$(echo -e "${YELLOW}[AVISO]${NC} Continuar mesmo assim? (s/n): ")"; then
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
    local available
    available=$(df -P -BG / | awk 'NR==2 {gsub(/G/,"",$4); print $4}')

    if ! [[ "$available" =~ ^[0-9]+$ ]]; then
        log "AVISO" "Não foi possível determinar o espaço em disco disponível" "no_console_output"
        return 0
    fi

    if [ "$available" -lt "$min_space" ]; then
        log "AVISO" "Espaço em disco insuficiente: $available GB. Mínimo recomendado: $min_space GB" "no_console_output"
        echo -e "${YELLOW}[AVISO]${NC} Espaço em disco disponível: $available GB"
        echo -e "${YELLOW}[AVISO]${NC} Espaço mínimo recomendado: $min_space GB"
        if ! confirm "$(echo -e "\n${YELLOW}[AVISO]${NC} Deseja continuar mesmo assim? (s/n): ")"; then
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
            if ! apt-get install -y "$dep" > /dev/null 2>&1; then
                log "ERRO" "Falha ao instalar dependencia: $dep" "no_console_output"
                echo -e "${RED}[ERRO]${NC} Falha ao instalar dependencia: $dep"
                exit 1
            fi
        done
        echo -e "${GREEN}[OK]${NC} Dependencias instaladas com sucesso"
    fi
}

# configure_pip()
# Habilita break-system-packages para contornar o PEP 668 (Debian 12+/Kali),
# senão todo 'pip3 install' falha com "externally-managed-environment".
configure_pip() {
    local rc pip_dir pip_conf
    for rc in "${RC_FILES[@]}"; do
        pip_dir="$(dirname "$rc")/.config/pip"
        pip_conf="$pip_dir/pip.conf"
        [ -f "$pip_conf" ] && grep -q 'break-system-packages' "$pip_conf" 2>/dev/null && continue
        mkdir -p "$pip_dir"
        printf '[global]\nbreak-system-packages = true\n' >> "$pip_conf"
        log "INFO" "pip configurado para PEP 668 em $pip_conf" "no_console_output"
    done
}

# save_state()
# Função para salvar o estado atual da instalação.
# Serializa arrays com %q para que a leitura via 'source' seja segura.
save_state() {
    local progress=$1
    shift
    local tools_done=("$@")

    {
        printf 'PROGRESS=%q\n' "$progress"
        printf 'TIMESTAMP=%q\n' "$(date +%s)"
        printf 'STATE_VERSION=%q\n' "$SCRIPT_VERSION"
        printf 'TOOLS_DONE=('
        ((${#tools_done[@]})) && printf '%q ' "${tools_done[@]}"
        printf ')\n'
        printf 'SELECTED_TOOLS=('
        ((${#order[@]})) && printf '%q ' "${order[@]}"
        printf ')\n'
    } > "$RESUME_FILE"

    log "INFO" "Estado da instalação salvo (progresso: $progress, selecionadas: ${#order[@]})"
}

# load_state()
# Função para carregar o estado anterior da instalação
load_state() {
    if [ -f "$RESUME_FILE" ]; then
        # Usar o . (ponto) em vez de source para carregar o arquivo, é mais seguro
        . "$RESUME_FILE"

        # Validar que as variáveis essenciais existem e são coerentes
        if [[ "${PROGRESS:-}" =~ ^[0-9]+$ ]] && [ -n "${TIMESTAMP:-}" ] && [ "${#SELECTED_TOOLS[@]}" -gt 0 ]; then
            local current_time=$(date +%s)
            local elapsed=$((current_time - TIMESTAMP))
            local elapsed_formatted=$(printf "%02d:%02d:%02d" $((elapsed/3600)) $(( (elapsed%3600)/60 )) $((elapsed%60)))

            # Ferramentas pendentes (usando slicing de array)
            local pending_tools=("${SELECTED_TOOLS[@]:$PROGRESS}")

            echo -e "${YELLOW}[AVISO]${NC} Encontrada instalação incompleta iniciada há $elapsed_formatted"
            echo -e "${YELLOW}[AVISO]${NC} Progresso: $PROGRESS de ${#SELECTED_TOOLS[@]} ferramentas"
            echo -e "${YELLOW}[AVISO]${NC} Ferramentas já instaladas: ${TOOLS_DONE[*]}"
            echo -e "${YELLOW}[AVISO]${NC} Ferramentas pendentes: ${pending_tools[*]}"
            if confirm "$(echo -e "\n${YELLOW}[AVISO]${NC} Deseja continuar de onde parou? (s/n): ")"; then
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

# build_menu_groups()
# Lê o arquivo de ferramentas e mapeia cada índice de "order" à sua categoria,
# usando os marcadores '# CATEGORY: <nome>'. Usado apenas para exibir o menu.
build_menu_groups() {
    local cur="Outros" line idx=0
    while IFS= read -r line; do
        if [[ "$line" =~ ^#[[:space:]]*CATEGORY:[[:space:]]*(.+)$ ]]; then
            cur="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^order\+=\(\"([^\"]+)\"\) ]]; then
            menu_cat_of[$idx]="$cur"
            idx=$((idx+1))
        fi
    done < "$TOOLS_CONF"
}

# print_menu()
# Exibe as ferramentas agrupadas por categoria, em colunas alinhadas.
# A numeração é a posição global em "order" (compatível com a seleção).
print_menu() {
    local cols=3 i cur="" col=0
    for i in "${!order[@]}"; do
        local cat="${menu_cat_of[$i]:-Outros}"
        if [ "$cat" != "$cur" ]; then
            [ -n "$cur" ] && [ $col -ne 0 ] && printf '\n'
            cur="$cat"; col=0
            printf "\n${PURPLE}${BOLD}${ARROW} %s${NC}\n" "$cur"
        fi
        printf "  ${CYAN}%3d.${NC} %-20s" $((i+1)) "${order[$i]}"
        col=$((col+1))
        if [ $col -eq $cols ]; then printf '\n'; col=0; fi
    done
    [ $col -ne 0 ] && printf '\n'
}

# select_tools()
# Função para exibir menu de seleção de ferramentas
select_tools() {
    # Se estamos retomando uma instalação, não precisamos selecionar ferramentas novamente
    if [ "$INSTALL_ALL" == "true" ] || [ "$RESUME_INSTALL" == "true" ]; then
        return
    fi

    echo -e "\n${CYAN}${BOLD}=== Selecione as ferramentas para instalação ===${NC}"
    print_menu
    echo -e "\n${DIM}Legenda: 0 ou 'a' = todas · ex: 1 3 5 · 'q' = sair${NC}"
    echo -n -e "${YELLOW}Digite os números (separados por espaço):${NC} "
    read -r choices

    if [[ "$choices" == "q" || "$choices" == "Q" ]]; then
        echo -e "${YELLOW}[AVISO]${NC} Seleção cancelada pelo usuário."
        exit 0
    fi

    if [[ "$choices" == "0" || "$choices" == "a" || "$choices" == "A" ]]; then
        return
    fi

    # Criar uma cópia da ordem original
    local original_order=("${order[@]}")
    local seen=""
    order=()

    for choice in $choices; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -le "${#original_order[@]}" ]; then
            # De-duplicar índices repetidos (ex: "1 1 3")
            if [[ " $seen " != *" $choice "* ]]; then
                order+=("${original_order[$((choice-1))]}")
                seen+=" $choice"
            fi
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
    if ! confirm "$(echo -e "\n${YELLOW}Continuar com a instalação destas ferramentas? (s/n): ${NC}")"; then
        echo -e "${YELLOW}[AVISO]${NC} Instalação cancelada pelo usuário."
        exit 0
    fi

    # Só salvamos o estado após a confirmação do usuário
    # Isso evita criar o arquivo .install_state prematuramente
    save_state 0
}

# run_with_spinner()
# Executa um comando em background exibindo um spinner (apenas em TTY),
# e captura saída, código de saída e duração.
# Resultado em: LAST_OUTPUT, LAST_DURATION (e o código de retorno da função).
run_with_spinner() {
    local label=$1 cmd=$2 tmp t0=$SECONDS pid rc f=0
    tmp=$(mktemp)

    ( eval "$cmd" ) > "$tmp" 2>&1 &
    pid=$!

    if [ -t 1 ]; then
        while kill -0 "$pid" 2>/dev/null; do
            printf "\r\e[K${CYAN}%s${NC} Instalando ${BOLD}%s${NC}..." "${SPIN[f % ${#SPIN[@]}]}" "$label"
            f=$((f+1))
            sleep 0.1
        done
        printf "\r\e[K"
    fi

    wait "$pid"; rc=$?
    LAST_OUTPUT=$(<"$tmp")
    rm -f "$tmp"
    LAST_DURATION=$((SECONDS - t0))
    return $rc
}

# status_line()
# Exibe o status de uma ferramenta, alinhado com "dotted leaders" e timing.
# Uso: status_line OK|ERR|SKIP <tool> <segundos>
status_line() {
    local tag=$1 tool=$2 secs=$3 color leaders pad
    case $tag in
        OK)  color=$GREEN ;;
        ERR) color=$RED ;;
        *)   color=$YELLOW ;;
    esac
    pad=$((38 - ${#tool}))
    [ $pad -lt 1 ] && pad=1
    leaders=$(printf '%*s' "$pad" '' | tr ' ' '.')
    printf "${color}[%-4s]${NC} %s ${DIM}%s${NC} ${DIM}%ds${NC}\n" "$tag" "$tool" "$leaders" "$secs"
}

# show_progress()
# Função para exibir barra de progresso
show_progress() {
    local current=$1
    local total=$2

    if [ -z "$current" ] || [ -z "$total" ] || [ "$total" -eq 0 ]; then
        return
    fi

    local width=40
    local perc=$(( (current * 100) / total ))
    local filled=$(( (perc * width) / 100 ))

    local color="${RED}"
    [ "$perc" -ge 100 ] && color="${GREEN}"

    # Segmento preenchido (colorido) + segmento vazio, somando exatamente 'width'
    printf "${DIM}[%d/%d]${NC} |${color}%s${NC}%s| ${color}%3d%%${NC}\n" \
        "$current" "$total" "$(make_bar "$filled" "$filled")" "$(make_bar 0 $((width - filled)))" "$perc"
}

# draw_box()
# Desenha uma caixa com título e linhas de conteúdo (box-drawing).
# Uso: draw_box "Título" "linha 1" "linha 2" ...
draw_box() {
    local title=$1; shift
    local width=48 line fill
    # Cabeçalho
    fill=$((width - ${#title} - 3))
    [ $fill -lt 0 ] && fill=0
    printf "${CYAN}%s%s %s %s%s${NC}\n" "$BOX_TL" "$BOX_H" "$title" \
        "$(repeat_str "$BOX_H" "$fill")" "$BOX_TR"
    # Conteúdo (largura visível calculada sem contar códigos ANSI)
    for line in "$@"; do
        local visible; visible=$(echo -e "$line" | sed -E 's/\x1b\[[0-9;]*m//g')
        local padlen=$((width - ${#visible} - 1))
        [ $padlen -lt 0 ] && padlen=0
        printf "${CYAN}%s${NC} %b%*s${CYAN}%s${NC}\n" "$BOX_V" "$line" "$padlen" '' "$BOX_V"
    done
    # Rodapé
    printf "${CYAN}%s%s%s${NC}\n" "$BOX_BL" "$(repeat_str "$BOX_H" "$width")" "$BOX_BR"
}

# handle_interrupt()
# Função para tratamento de interrupções (CTRL+C)
handle_interrupt() {
    echo -e "\n${YELLOW}[AVISO]${NC} Instalação interrompida pelo usuário"

    # Só salvar o estado se já estivermos no processo de instalação
    # (após o menu de seleção de ferramentas)
    if [ "$INSTALLATION_STARTED" == "true" ]; then
        log "AVISO" "Instalação interrompida pelo usuário no progresso: $progress de $total_commands"
        save_state "$progress" "${installed_tools[@]}"
        echo -e "${YELLOW}[AVISO]${NC} Estado da instalação salvo. Execute novamente o script para continuar."
    else
        log "AVISO" "Script interrompido pelo usuário antes do início da instalação"
        echo -e "${YELLOW}[AVISO]${NC} Nenhuma instalação iniciada. Nenhum estado salvo."
        # Garantir que qualquer arquivo de estado parcial seja removido
        rm -f "$RESUME_FILE"
    fi
    exit 130
}


# ============================================================================
# Corra Forrest, corra...
# ============================================================================

# Processar opções de linha de comando ANTES de qualquer verificação/banner,
# para que "-h" funcione sem root e sem rodar as checagens de sistema.
while getopts ":hany-:" opt; do
    case "$opt" in
    h) SHOW_HELP=true ;;
    a) INSTALL_ALL=true ;;
    n) DRY_RUN=true ;;
    y) ASSUME_YES=true ;;
    -)
        case "$OPTARG" in
        help)     SHOW_HELP=true ;;
        all)      INSTALL_ALL=true ;;
        dry-run)  DRY_RUN=true ;;
        yes)      ASSUME_YES=true ;;
        no-color) USE_COLOR=off ;;
        *)        echo "Opção inválida: --$OPTARG" 1>&2; INVALID_OPT=true ;;
        esac ;;
    \?) echo "Opção inválida: -$OPTARG" 1>&2; INVALID_OPT=true ;;
    esac
done
shift $((OPTIND - 1))

# Configurar cores/glifos (depende de USE_COLOR já ter sido processado)
setup_ui

if [ "$INVALID_OPT" = true ]; then
    echo -e "${YELLOW}[DICA]${NC} Use -h para ajuda\n"
    exit 1
fi

if [ "$SHOW_HELP" = true ]; then
    print_help
    exit 0
fi

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
[ "$DRY_RUN" = true ] && log "INFO" "Modo dry-run ativado (nenhuma alteração será feita)"

# Determinar arquivos de configuração de shell do ROOT e do usuário do sudo.
# Fixar HOME=/root para que '~' e '~/go/bin' sejam consistentes durante o build.
rc_for_shell() { case "$1" in bash) echo .bashrc ;; zsh) echo .zshrc ;; *) echo .profile ;; esac; }

ROOT_HOME=$(getent passwd root | cut -d: -f6); ROOT_HOME=${ROOT_HOME:-/root}
ROOT_SHELL=$(basename "$(getent passwd root | cut -d: -f7)")
export HOME="$ROOT_HOME"
CONFIG_FILE="$ROOT_HOME/$(rc_for_shell "$ROOT_SHELL")"
export CONFIG_FILE
RC_FILES=("$CONFIG_FILE")

if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    USER_SHELL=$(basename "$(getent passwd "$SUDO_USER" | cut -d: -f7)")
    if [ -n "$USER_HOME" ]; then
        RC_FILES+=("$USER_HOME/$(rc_for_shell "$USER_SHELL")")
    fi
fi
log "INFO" "Arquivos de configuração de shell: ${RC_FILES[*]}" "no_console_output"

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

# Mapear categorias para o menu
build_menu_groups

# Checar compatibilidade com o sistema operacional
check_os

# Verificar espaço mínimo em disco
check_disk_space

# Verificar instalação de dependências
check_dependencies

# Configurar pip para o PEP 668 (Debian 12+/Kali)
configure_pip

# Capturar interrupções
trap handle_interrupt SIGINT SIGTERM

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

# Garantir que o Go (instalado em /usr/local/go/bin) e os binários de 'go install'
# (~/go/bin) estejam no PATH do próprio processo, para que os comandos das
# ferramentas seguintes encontrem o 'go'. (O 'source' dentro de um subshell não
# propagava o PATH ao processo pai.)
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

for tool in "${order[@]}"; do
    echo -e "\n${DIM}$(repeat_str "$BOX_H" 50)${NC}"

    # Verificar se a ferramenta já foi instalada em uma execução anterior
    if [[ " ${installed_tools[*]} " =~ " $tool " ]]; then
        log "INFO" "Pulando $tool... Instalação previamente detectada" "no_console_output"
        status_line SKIP "$tool" 0
        continue
    fi

    cmd="${commands[$tool]}"
    log "INFO" "Instalando $tool" "no_console_output"

    # Executar (ou simular, em dry-run) o comando de instalação
    if [ "$DRY_RUN" = true ]; then
        sleep 0.1
        output="[dry-run] $cmd"
        exit_code=0
        duration=0
    else
        run_with_spinner "$tool" "$cmd"
        exit_code=$?
        output="$LAST_OUTPUT"
        duration="$LAST_DURATION"
    fi

    # Após instalar o Go, reafirmar o PATH do processo (defensivo)
    if [ "$tool" = "go" ] && [ "$exit_code" -eq 0 ]; then
        export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
    fi

    # Verificar resultado da instalação
    if ! check_result "$tool" "$exit_code" "$output"; then
        status_line ERR "$tool" "$duration"
        log "ERRO" "Detalhes do erro: $output" "no_console_output"
        echo -e "${YELLOW}[DICA]${NC} Verifique o log para mais detalhes: $LOG_FILE"
        if ! confirm "$(echo -e "\n${YELLOW}[AVISO]${NC} Deseja continuar com as próximas ferramentas? (s/n): ")"; then
            log "INFO" "Instalação interrompida pelo usuário após falha em: $tool"
            save_state "$progress" "${installed_tools[@]}"
            exit 1
        fi
        # Adiciona à lista de ferramentas puladas
        skipped_tools["$tool"]="Falha de instalação"
    else
        # Adiciona à lista de ferramentas instaladas com sucesso
        installed_tools+=("$tool")
        # Grava o progresso atual para possível retomada
        save_state "$progress" "${installed_tools[@]}"
        status_line OK "$tool" "$duration"
    fi

    progress=$((progress + 1))
    show_progress $progress $total_commands
done

end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_formatted=$(printf "%02d:%02d:%02d" $((execution_time/3600)) $(( (execution_time%3600)/60 )) $((execution_time%60)))

echo -e "\n${DIM}$(repeat_str "$BOX_H" 50)${NC}\n"

show_progress $total_commands $total_commands
echo -e "\n${GREEN}${BOLD}Instalação concluída!${NC}\n"
log "INFO" "Processo de instalação finalizado em $execution_time_formatted"

# Exibir resumo das instalações (em caixa)
draw_box "RESUMO DA INSTALACAO" \
    "${CYAN}Tempo total:${NC}      $execution_time_formatted" \
    "${CYAN}Solicitadas:${NC}      $total_commands" \
    "${CYAN}Instaladas:${NC}       ${#installed_tools[@]}" \
    "${CYAN}Com falha:${NC}        ${#failed_tools[@]}" \
    "${CYAN}Puladas:${NC}          ${#skipped_tools[@]}"

if [ ${#failed_tools[@]} -gt 0 ]; then
    echo -e "\n${RED}${BOLD}[FERRAMENTAS COM FALHA]${NC}"
    for tool in "${failed_tools[@]}"; do
        echo -e "${RED}- ${NC}$tool"
    done
fi

if [ ${#skipped_tools[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}${BOLD}[FERRAMENTAS PULADAS]${NC}"
    for tool in "${!skipped_tools[@]}"; do
        echo -e "${YELLOW}- ${NC}$tool: ${skipped_tools[$tool]}"
    done
fi

echo -e "\n${GREEN}${BOLD}[FERRAMENTAS INSTALADAS]${NC}"
for tool in "${installed_tools[@]}"; do
    echo -e "${GREEN}- ${NC}$tool"
done

# Remover arquivo de estado se a instalação for concluída com sucesso
if [ $progress -eq $total_commands ]; then
    log "INFO" "Instalação concluída com sucesso. Removendo arquivo de estado." "no_console_output"
    rm -f "$RESUME_FILE"
fi

echo -e "\n${YELLOW}Atualize a sessão atual do shell com o comando:${NC}"
echo -e " ${YELLOW}source $CONFIG_FILE${NC}"

log "INFO" "Execução do script finalizada com sucesso" "no_console_output"
echo -e "\n${GREEN}${BOLD}Hack the Planet!${NC}"
