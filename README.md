<pre>
                    ____                      _    ______  _____
   ____ ___  __  __/ __ \___  _________  ____| |  / / __ \/ ___/
  / __ `__ \/ / / / /_/ / _ \/ ___/ __ \/ __ \ | / / /_/ /\__ \ 
 / / / / / / /_/ / _, _/  __/ /__/ /_/ / / / / |/ / ____/___/ / 
/_/ /_/ /_/\__, /_/ |_|\___/\___/\____/_/ /_/|___/_/    /____/  
          /____/                                   by Andalik
</pre>

**myReconVPS** automatiza a instalação e a atualização de um arsenal de ferramentas de reconhecimento e pentest em VPS baseadas em Debian, deixando tudo pronto no `PATH` com um único comando.

`v1.2607.006` · by Andalik

### Requisitos
- Distribuição baseada em Debian: **Debian 9+**, **Ubuntu 22.04+**, **Kali Linux** ou **Raspbian**
- Privilégios de **root** (execute com `sudo`)
- Cerca de **5 GB** de espaço livre em disco (ajustável via `min_space` em `myReconVPS.tools`)
- `curl`, `wget` e `git` (instalados automaticamente se estiverem ausentes)

### Recursos
- Interface **TUI** colorida: menu de seleção categorizado, spinner por ferramenta, barra de progresso e resumo final em caixa (com fallback ASCII quando não há suporte a Unicode/cor)
- Instala **todas** as ferramentas ou apenas as **selecionadas** (menu interativo ou `-a`)
- **Retomada automática**: se a instalação for interrompida (Ctrl+C), continua de onde parou na próxima execução
- Configura o **`PATH` automaticamente** no rc do root e do usuário do `sudo` (idempotente)
- **Contorna o PEP 668** automaticamente (Debian 12+/Kali)
- Modo **simulação** (`--dry-run`) e log detalhado em `install_log.txt`

### Ferramentas Instaladas
Lista derivada de `myReconVPS.tools` (fonte da verdade):

**Mandatórios**
 > ubuntu-update
 > basic-tools
 > go
 > python3

**Programas de Reconhecimento**
 > airixss
 > amass
 > anew
 > archivefuzz
 > arjun
 > assetfinder
 > cdncheck
 > cent
 > cf-check
 > chaos
 > dalfox
 > dirsearch
 > dnsdumpster
 > dnsexpire
 > dnsgen
 > dnspy
 > dnsvalidator
 > dnsx
 > exif
 > exploitdb
 > ffuf
 > findomain
 > freq
 > gau
 > gauplus
 > geospy
 > getjs
 > gf
 > gitdorker
 > github-search
 > github-subdomains
 > github-endpoints
 > gittools
 > gobuster
 > goop
 > gospider
 > gowitness
 > gxss
 > hakcheckurl
 > haklistgen
 > hakrawler
 > hakrevdns
 > haktldextract
 > haktrails
 > httprobe
 > httpx
 > jsscanner
 > jsubfinder
 > katana
 > knock
 > linkfinder
 > mariadb-client
 > masscan
 > massdns
 > meg
 > metabigor
 > mildew
 > naabu
 > netdiscover
 > nikto
 > nilo
 > nmap
 > notify
 > nuclei
 > oneforall
 > paramspider
 > photon
 > prips
 > puredns
 > qsreplace
 > quaithe
 > rayder
 > revwhoix
 > sdlookup
 > searchsploit
 > secretfinder
 > sherlock
 > shuffledns
 > spiderfoot
 > sqlmap
 > subfinder
 > subjs
 > sudomy
 > sublist3r
 > testssl
 > theharvester
 > trufflehog
 > uncover
 > unfurl
 > uro
 > wafw00f
 > waybackurls
 > wfuzz
 > whoxyrm
 > wpscan
 > xs-leaks
 > xurlfind3r

**Dicionários e Wordlists**
 > assetnote-wordlists
 > seclists
 > resolvers

### Instalação
Execute o script como root, via `sudo ./myReconVPS.sh` ou entrando como root com <b>sudo su</b>.<br>
<br>
O `PATH` das ferramentas é configurado <b>automaticamente</b>: o script grava as linhas de `export PATH` tanto no rc do root (`/root/.bashrc` ou `.zshrc`) quanto no rc do usuário que invocou o `sudo` (`SUDO_USER`), de forma idempotente. Não é mais necessário copiar manualmente essas linhas.<br>
<br>
Ao final, atualize a sessão atual do shell com `source ~/.bashrc` (ou `.zshrc`) para que os novos caminhos fiquem disponíveis imediatamente.

#### Opções de linha de comando
```
-h, --help       Exibe a ajuda
-a, --all        Instala/atualiza todas as ferramentas sem perguntar
-n, --dry-run    Simula a instalação (não executa nada de fato)
-y, --yes        Responde 'sim' automaticamente às confirmações
    --no-color   Desativa cores na saída
```

### Atualização dos Pacotes Obtidos via GITHUB
Sempre que for necessário atualizar os pacotes já instalados, basta reexecutar o script de instalação.

### PEP 668
Em versões mais recentes do Python aderentes ao PEP 668, podem ocorrer erros no uso do pip:

error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.

O script agora <b>configura isso automaticamente</b>: cria `~/.config/pip/pip.conf` (para o root e para o usuário do `sudo`) com `break-system-packages = true`, de forma idempotente. Nenhuma ação manual é necessária.

Caso queira configurar manualmente em outro ambiente:
```
mkdir -p ~/.config/pip
echo -e "[global]\nbreak-system-packages=true" > ~/.config/pip/pip.conf
```

### Uso dos Templates da Comunidade Nuclei
Após a instalação das ferramentas, baixe os templates da comunidade para o Nuclei no seu diretório de usuário:
```
cd ~
cent init
cent -p cent-nuclei-templates
```

Por fim, para rodar o Nuclei com os novos templates, faça:
```
nuclei -u https://example.com -t ./cent-nuclei-templates -tags cve
nuclei -l urls.txt -t ./cent-nuclei-templates -tags cve
```
