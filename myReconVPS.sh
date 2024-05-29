#!/bin/bash
declare -A commands
declare -a order

SECONDS=0

# INSTRUCOES
# Adicione comandos para instalacao de ferramentas no formato:
#  commands["toolname1"]="command1 | command2 | ..."
#  order=("toolname1" "toolname2" ...)

# Tratamento de variaveis e caracteres especiais
#  Aspas duplas sao utilizadas para delimitar o comando completo, portanto,
#  na sua construcao de comando, utilize APENAS aspas simples.
#  Em variaveis, utilize o caractere de escape.
#  Por exemplo, $LATEST_VERSION fica \$LATEST_VERSION

# Variaveis disponiveis para uso nos comandos:
#  CONFIG_FILE 
#  | aponta para o arquivo de configuracao de sessao utilizado pelo shell
#  | (.profile, .bashrc ou .zshrc) 

# ULTIMA ATUALIZACAO: 27/05/2024

# ========== INICIO DA AREA EDITAVEL ===========

# Mandatorios
commands["ubuntu-update"]="apt-get update && apt-get -y upgrade"

commands["basic-tools"]="apt-get -y install snapd git curl wget unzip gzip ftp telnet tcpdump net-tools ca-certificates"

commands["snap-refresh"]="snap refresh"

commands["go"]="LATEST_VERSION=\`curl -s https://go.dev/dl/ | grep filename | grep download | grep 'go[0-9\.]\+\.linux-amd64\.tar\.gz' | head -n 1 | awk -F '/dl/' '{print \$2}' | awk -F '\"' '{print \$1}'\` && wget https://go.dev/dl/\$LATEST_VERSION && rm -rf /usr/local/go && tar -C /usr/local -xzf \$LATEST_VERSION && rm -f \$LATEST_VERSION && grep -q 'export PATH=\$PATH:/usr/local/go/bin' \$CONFIG_FILE || echo 'export PATH=\$PATH:/usr/local/go/bin' >> \$CONFIG_FILE && source \$CONFIG_FILE"

commands["python3"]="apt-get -y install python3-pip"

# Programas Variados
commands["airixss"]="go install github.com/ferreiraklet/airixss@latest && mkdir /opt/airixss ; mv -f ~/go/bin/airixss /opt/airixss/ && grep -q 'export PATH=\$PATH:/opt/airixss' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/airixss' >> \$CONFIG_FILE"

commands["amass"]="apt-get -y install g++-x86-64-linux-gnu libc6-dev-amd64-cross ; go install -v github.com/owasp-amass/amass/v4/...@master && mkdir /opt/amass ; mv -f ~/go/bin/amass /opt/amass/ && grep -q 'export PATH=\$PATH:/opt/amass' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/amass' >> \$CONFIG_FILE"

commands["anew"]="go install github.com/tomnomnom/anew@latest && mkdir /opt/anew ; mv -f ~/go/bin/anew /opt/anew/ && grep -q 'export PATH=\$PATH:/opt/anew' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/anew' >> \$CONFIG_FILE"

commands["archivefuzz"]="git clone https://github.com/devanshbatham/ArchiveFuzz && cd ArchiveFuzz && pip3 install -r requirements.txt && cd .. && cp -rf ArchiveFuzz/ /opt/archivefuzz && rm -rf ArchiveFuzz && grep -q 'export PATH=\$PATH:/opt/archivefuzz' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/archivefuzz' >> \$CONFIG_FILE"

commands["arjun"]="pip3 install arjun"

commands["assetfinder"]="go install github.com/tomnomnom/assetfinder@latest && mkdir /opt/assetfinder ; mv -f ~/go/bin/assetfinder /opt/assetfinder/ && grep -q 'export PATH=\$PATH:/opt/assetfinder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/assetfinder' >> \$CONFIG_FILE"

commands["cdncheck"]="go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest && mkdir /opt/cdncheck ; mv -f ~/go/bin/cdncheck /opt/cdncheck/ && grep -q 'export PATH=\$PATH:/opt/cdncheck' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/cdncheck' >> \$CONFIG_FILE"

commands["cf-check"]="go install github.com/dwisiswant0/cf-check@latest && mkdir /opt/cf-check ; mv -f ~/go/bin/cf-check /opt/cf-check/ && grep -q 'export PATH=\$PATH:/opt/cf-check' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/cf-check' >> \$CONFIG_FILE"

commands["chaos"]="go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest && mkdir /opt/chaos ; mv -f ~/go/bin/chaos /opt/chaos/ && grep -q 'export PATH=\$PATH:/opt/chaos' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/chaos' >> \$CONFIG_FILE"

commands["dalfox"]="go install github.com/hahwul/dalfox/v2@latest && mkdir /opt/dalfox ; mv -f ~/go/bin/dalfox /opt/dalfox/ && grep -q 'export PATH=\$PATH:/opt/dalfox' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dalfox' >> \$CONFIG_FILE"

commands["dirsearch"]="git clone https://github.com/maurosoria/dirsearch.git --depth 1 && cd dirsearch && pip3 install -r requirements.txt && cd .. && cp -rf dirsearch/ /opt/ && rm -rf dirsearch && grep -q 'export PATH=\$PATH:/opt/dirsearch' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dirsearch' >> \$CONFIG_FILE"

commands["dnsdumpster"]="git clone https://github.com/nmmapper/dnsdumpster.git && cd dnsdumpster && pip3 install -r requirements.txt && cd .. && cp -rf dnsdumpster/ /opt/ && rm -rf dnsdumpster && grep -q 'export PATH=\$PATH:/opt/dnsdumpster' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dnsdumpster' >> \$CONFIG_FILE"

commands["dnsexpire"]="git clone https://github.com/gwen001/dnsexpire && cp -rf dnsexpire/ /opt/ && rm -rf dnsexpire && grep -q 'export PATH=\$PATH:/opt/dnsexpire' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dnsexpire' >> \$CONFIG_FILE"

commands["dnsgen"]="python3 -m pip install dnsgen"

commands["dnspy"]="git clone https://github.com/gwen001/dnspy && cd dnspy && pip3 install -r requirements.txt && cd .. && cp -rf dnspy/ /opt/ && rm -rf dnspy && grep -q 'export PATH=\$PATH:/opt/dnspy' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dnspy' >> \$CONFIG_FILE"

commands["dnsvalidator"]="git clone https://github.com/vortexau/dnsvalidator.git && cd dnsvalidator && python3 setup.py install && cd .. && cp -rf dnsvalidator/ /opt/ && rm -rf dnsvalidator && grep -q 'export PATH=\$PATH:/opt/dnsvalidator' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dnsvalidator' >> \$CONFIG_FILE"

commands["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest && mkdir /opt/dnsx ; mv -f ~/go/bin/dnsx /opt/dnsx/ && grep -q 'export PATH=\$PATH:/opt/dnsx' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/dnsx' >> \$CONFIG_FILE"

commands["exif"]="apt-get -y install libimage-exiftool-perl"

commands["exploitdb"]="git clone https://gitlab.com/exploit-database/exploitdb.git && mkdir /opt/exploitdb ; cp -rf exploitdb/ /opt/ && rm -rf exploitdb && grep -q 'export PATH=\$PATH:/opt/exploitdb' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/exploitdb' >> \$CONFIG_FILE"

commands["ffuf"]="git clone https://github.com/ffuf/ffuf && cd ffuf && go get && go build && cd .. && mkdir /opt/ffuf ; cp -rf ffuf/ /opt/ && rm -rf ffuf && grep -q 'export PATH=\$PATH:/opt/ffuf' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/ffuf' >> \$CONFIG_FILE"

commands["findomain"]="curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip && unzip findomain-linux.zip && chmod +x findomain && mkdir /opt/findomain ; mv -f findomain /opt/findomain/ && rm -f findomain-linux.zip && grep -q 'export PATH=\$PATH:/opt/findomain' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/findomain' >> \$CONFIG_FILE"

commands["freq"]="go install github.com/takshal/freq@latest && mkdir /opt/freq ; mv -f ~/go/bin/freq /opt/freq/ && grep -q 'export PATH=\$PATH:/opt/freq' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/freq' >> \$CONFIG_FILE"

commands["gau"]="go install github.com/lc/gau/v2/cmd/gau@latest && mkdir /opt/gau ; mv -f ~/go/bin/gau /opt/gau/ && grep -q 'export PATH=\$PATH:/opt/gau' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gau' >> \$CONFIG_FILE"

commands["gauplus"]="go install github.com/bp0lr/gauplus@latest && mkdir /opt/gauplus ; mv -f ~/go/bin/gauplus /opt/gauplus/ && grep -q 'export PATH=\$PATH:/opt/gauplus' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gauplus' >> \$CONFIG_FILE"

commands["geospy"]="pip3 install geospyer"

commands["getjs"]="go install github.com/003random/getJS@latest && mkdir /opt/getjs ; mv -f ~/go/bin/getJS /opt/getjs/getjs && grep -q 'export PATH=\$PATH:/opt/getjs' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/getjs' >> \$CONFIG_FILE"

commands["gf"]="go install github.com/tomnomnom/gf@latest && mkdir /opt/gf ; mv -f ~/go/bin/gf /opt/gf/ && grep -q 'export PATH=\$PATH:/opt/gf' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gf' >> \$CONFIG_FILE"

commands["gitdorker"]="git clone https://github.com/obheda12/GitDorker.git && cd GitDorker && pip3 install -r requirements.txt && cd .. && cp -rf GitDorker/ /opt/gitdorker && rm -rf GitDorker && grep -q 'export PATH=\$PATH:/opt/gitdorker' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gitdorker' >> \$CONFIG_FILE"

commands["github-search"]="git clone https://github.com/gwen001/github-search && cd github-search && pip3 install -r requirements.txt && cd .. && cp -rf github-search/ /opt/ && rm -rf github-search && grep -q 'export PATH=\$PATH:/opt/github-search' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/github-search' >> \$CONFIG_FILE"

commands["github-subdomains"]="go install github.com/gwen001/github-subdomains@latest && mkdir /opt/github-subdomains ; mv -f ~/go/bin/github-subdomains /opt/github-subdomains/ && grep -q 'export PATH=\$PATH:/opt/github-subdomains' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/github-subdomains' >> \$CONFIG_FILE"

commands["github-endpoints"]="go install github.com/gwen001/github-endpoints@latest && mkdir /opt/github-endpoints ; mv -f ~/go/bin/github-endpoints /opt/github-endpoints/ && grep -q 'export PATH=\$PATH:/opt/github-endpoints' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/github-endpoints' >> \$CONFIG_FILE"

commands["gittools"]="git clone https://github.com/internetwache/GitTools.git && cd GitTools/Finder && pip3 install -r requirements.txt && cd ../.. && cp -rf GitTools/ /opt/gittools && rm -rf GitTools && grep -q 'export PATH=\$PATH:/opt/gittools' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gittools' >> \$CONFIG_FILE"

commands["gobuster"]="go install github.com/OJ/gobuster/v3@latest && mkdir /opt/gobuster ; mv -f ~/go/bin/gobuster /opt/gobuster/ && grep -q 'export PATH=\$PATH:/opt/gobuster' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gobuster' >> \$CONFIG_FILE"

commands["goop"]="go install github.com/deletescape/goop@latest && mkdir /opt/goop ; mv -f ~/go/bin/goop /opt/goop/ && grep -q 'export PATH=\$PATH:/opt/goop' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/goop' >> \$CONFIG_FILE"

commands["gospider"]="GO111MODULE=on go install github.com/jaeles-project/gospider@latest && mkdir /opt/gospider ; mv -f ~/go/bin/gospider /opt/gospider && grep -q 'export PATH=\$PATH:/opt/gospider' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gospider' >> \$CONFIG_FILE"

commands["gowitness"]="go install github.com/sensepost/gowitness@latest && mkdir /opt/gowitness ; mv -f ~/go/bin/gowitness /opt/gowitness/ && grep -q 'export PATH=\$PATH:/opt/gowitness' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gowitness' >> \$CONFIG_FILE"

commands["gxss"]="go install github.com/KathanP19/Gxss@latest && mkdir /opt/gxss ; mv -f ~/go/bin/Gxss /opt/gxss/gxss && grep -q 'export PATH=\$PATH:/opt/gxss' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/gxss' >> \$CONFIG_FILE"

commands["hakcheckurl"]="go install github.com/hakluke/hakcheckurl@latest && mkdir /opt/hakcheckurl ; mv -f ~/go/bin/hakcheckurl /opt/hakcheckurl/ && grep -q 'export PATH=\$PATH:/opt/hakcheckurl' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/hakcheckurl' >> \$CONFIG_FILE"

commands["haklistgen"]="go install github.com/hakluke/haklistgen@latest && mkdir /opt/haklistgen ; mv -f ~/go/bin/haklistgen /opt/haklistgen/ && grep -q 'export PATH=\$PATH:/opt/haklistgen' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/haklistgen' >> \$CONFIG_FILE"

commands["hakrawler"]="go install github.com/hakluke/hakrawler@latest && mkdir /opt/hakrawler ; mv -f ~/go/bin/hakrawler /opt/hakrawler/ && grep -q 'export PATH=\$PATH:/opt/hakrawler' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/hakrawler' >> \$CONFIG_FILE"

commands["hakrevdns"]="go install github.com/hakluke/hakrevdns@latest && mkdir /opt/hakrevdns ; mv -f ~/go/bin/hakrevdns /opt/hakrevdns/ && grep -q 'export PATH=\$PATH:/opt/hakrevdns' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/hakrevdns' >> \$CONFIG_FILE"

commands["haktldextract"]="go install github.com/hakluke/haktldextract@latest && mkdir /opt/haktldextract ; mv -f ~/go/bin/haktldextract /opt/haktldextract/ && grep -q 'export PATH=\$PATH:/opt/haktldextract' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/haktldextract' >> \$CONFIG_FILE"

commands["haktrails"]="go install -v github.com/hakluke/haktrails@latest && mkdir /opt/haktrails ; mv -f ~/go/bin/haktrails /opt/haktrails/ && grep -q 'export PATH=\$PATH:/opt/haktrails' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/haktrails' >> \$CONFIG_FILE"

commands["httpie"]="snap install httpie"

commands["httprobe"]="go install github.com/tomnomnom/httprobe@latest && mkdir /opt/httprobe ; mv -f ~/go/bin/httprobe /opt/httprobe/ && grep -q 'export PATH=\$PATH:/opt/httprobe' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/httprobe' >> \$CONFIG_FILE"

commands["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && mkdir /opt/httpx ; mv -f ~/go/bin/httpx /opt/httpx/ && grep -q 'export PATH=\$PATH:/opt/httpx' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/httpx' >> \$CONFIG_FILE"

commands["jsscanner"]="git clone https://github.com/0x240x23elu/JSScanner.git && cd JSScanner && pip3 install -r requirements.txt && cd .. && cp -rf JSScanner/ /opt/jsscanner && rm -rf JSScanner && grep -q 'export PATH=\$PATH:/opt/jsscanner' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/jsscanner' >> \$CONFIG_FILE"

commands["jsubfinder"]="go install github.com/ThreatUnkown/jsubfinder@latest && wget https://raw.githubusercontent.com/ThreatUnkown/jsubfinder/master/.jsf_signatures.yaml && mkdir /opt/jsubfinder ; mv -f ~/go/bin/jsubfinder /opt/jsubfinder/ && mv -f .jsf_signatures.yaml /opt/jsubfinder/ && grep -q 'export PATH=\$PATH:/opt/jsubfinder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/jsubfinder' >> \$CONFIG_FILE"

commands["katana"]="go install github.com/projectdiscovery/katana/cmd/katana@latest && mkdir /opt/katana ; mv -f ~/go/bin/katana /opt/katana/ && grep -q 'export PATH=\$PATH:/opt/katana' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/katana' >> \$CONFIG_FILE"

commands["knock"]="git clone https://github.com/guelfoweb/knock.git && cd knock && pip3 install -r requirements.txt && cd .. && cp -rf knock/ /opt/ && rm -rf knock && grep -q 'export PATH=\$PATH:/opt/knock' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/knock' >> \$CONFIG_FILE"

commands["linkfinder"]="git clone https://github.com/GerbenJavado/LinkFinder.git && cd LinkFinder && python3 setup.py install && pip3 install -r requirements.txt && cd .. && cp -rf LinkFinder/ /opt/linkfinder && rm -rf LinkFinder && grep -q 'export PATH=\$PATH:/opt/linkfinder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/linkfinder' >> \$CONFIG_FILE"

commands["mariadb-client"]="apt-get -y install mariadb-client"

commands["meg"]="go install github.com/tomnomnom/meg@latest && mkdir /opt/meg ; mv -f ~/go/bin/meg /opt/meg/ && grep -q 'export PATH=\$PATH:/opt/meg' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/meg' >> \$CONFIG_FILE"

commands["metabigor"]="git clone https://github.com/j3ssie/metabigor.git && cd metabigor && go install && cd .. && rm -rf metabigor && mkdir /opt/metabigor ; mv -f ~/go/bin/metabigor /opt/metabigor/ && grep -q 'export PATH=\$PATH:/opt/metabigor' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/metabigor' >> \$CONFIG_FILE"

commands["mildew"]="go install github.com/daehee/mildew/cmd/mildew@latest && mkdir /opt/mildew ; mv -f ~/go/bin/mildew /opt/mildew/ && grep -q 'export PATH=\$PATH:/opt/mildew' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/mildew' >> \$CONFIG_FILE"

commands["naabu"]="apt-get -y install libpcap-dev ; go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest && mkdir /opt/naabu ; mv -f ~/go/bin/naabu /opt/naabu/ && grep -q 'export PATH=\$PATH:/opt/naabu' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/naabu' >> \$CONFIG_FILE"

commands["netdiscover"]="apt-get -y install netdiscover"

commands["nikto"]="git clone https://github.com/sullo/nikto.git && cp -rf nikto/ /opt/ && rm -rf nikto && grep -q 'export PATH=\$PATH:/opt/nikto' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/nikto' >> \$CONFIG_FILE"

commands["nilo"]="go install github.com/ferreiraklet/nilo@latest && mkdir /opt/nilo ; mv -f ~/go/bin/nilo /opt/nilo/ && grep -q 'export PATH=\$PATH:/opt/nilo' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/nilo' >> \$CONFIG_FILE"

commands["nmap"]="apt-get -y install build-essential libssl-dev automake libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev liblua5.3-dev libbpfcc-dev libpcap-dev libcfg-dev libssh2-1-dev libpcre3-dev libcairo2-dev pkg-config python3-dev python3-venv make gcc && pip3 install build && git clone https://github.com/nmap/nmap.git && cd nmap && make uninstall ; rm -f /usr/local/bin/zenmap ; rm -f /usr/local/share/zenmap ; python_dir=\$(ls /usr/local/lib | grep 'python' | sort -r | head -n 1) ; sudo rm -rf /usr/local/lib/\$python_dir/dist-packages/zenmap* ; ./configure && make && make install && cd .. && rm -rf nmap"

commands["notify"]="go install -v github.com/projectdiscovery/notify/cmd/notify@latest && mkdir /opt/notify ; mv -f ~/go/bin/notify /opt/notify/ && grep -q 'export PATH=\$PATH:/opt/notify' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/notify' >> \$CONFIG_FILE"

commands["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && mkdir /opt/nuclei ; mv -f ~/go/bin/nuclei /opt/nuclei/ && grep -q 'export PATH=\$PATH:/opt/nuclei' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/nuclei' >> \$CONFIG_FILE"

commands["oneforall"]="git clone https://github.com/shmilylty/OneForAll.git && cd OneForAll && python3 -m pip install -U pip setuptools wheel && pip3 install -r requirements.txt && cd .. && mkdir /opt/oneforall ; cp -rf OneForAll/* /opt/oneforall/ && rm -rf OneForAll && grep -q 'export PATH=\$PATH:/opt/oneforall/oneforall' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/oneforall/oneforall' >> \$CONFIG_FILE"

commands["paramspider"]="git clone https://github.com/devanshbatham/paramspider && cd paramspider && pip3 install . && cd .. && cp -rf paramspider/ /opt/ && rm -rf paramspider && grep -q 'export PATH=\$PATH:/opt/paramspider' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/paramspider' >> \$CONFIG_FILE"

commands["photon"]="git clone https://github.com/s0md3v/Photon.git && cd Photon && pip3 install -r requirements.txt && cd .. && mkdir /opt/photon ; cp -rf Photon/* /opt/photon/ && rm -rf Photon && grep -q 'export PATH=\$PATH:/opt/photon' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/photon' >> \$CONFIG_FILE"

commands["prips"]="apt-get -y install prips"

commands["puredns"]="git clone https://github.com/blechschmidt/massdns.git && cd massdns && make && make install && cd .. && rm -rf massdns && go install github.com/d3mondev/puredns/v2@latest && mkdir /opt/puredns ; mv -f ~/go/bin/puredns /opt/puredns/ && grep -q 'export PATH=\$PATH:/opt/puredns' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/puredns' >> \$CONFIG_FILE"

commands["qsreplace"]="go install github.com/tomnomnom/qsreplace@latest && mkdir /opt/qsreplace ; mv -f ~/go/bin/qsreplace /opt/qsreplace/ && grep -q 'export PATH=\$PATH:/opt/qsreplace' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/qsreplace' >> \$CONFIG_FILE"

commands["quaithe"]="pip3 install alive_progress && git clone https://github.com/devanshbatham/Quaithe && cd Quaithe && chmod +x setup.sh && ./setup.sh && cd .. && mkdir /opt/quaithe ; cp -rf Quaithe/* /opt/quaithe/ && rm -rf Quaithe && grep -q 'export PATH=\$PATH:/opt/quaithe' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/quaithe' >> \$CONFIG_FILE"

commands["rayder"]="go install github.com/devanshbatham/rayder@latest && mkdir /opt/rayder ; mv -f ~/go/bin/rayder /opt/rayder/ && grep -q 'export PATH=\$PATH:/opt/rayder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/rayder' >> \$CONFIG_FILE"

commands["revwhoix"]="git clone https://github.com/Sybil-Scan/revwhoix && cd revwhoix && pip3 install . && cd .. && cp -rf revwhoix/ /opt/ && rm -rf revwhoix && grep -q 'export PATH=\$PATH:/opt/revwhoix' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/revwhoix' >> \$CONFIG_FILE"

commands["sdlookup"]="go install github.com/j3ssie/sdlookup@latest && mkdir /opt/sdlookup ; mv -f ~/go/bin/sdlookup /opt/sdlookup/ && grep -q 'export PATH=\$PATH:/opt/sdlookup' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/sdlookup' >> \$CONFIG_FILE"

commands["searchsploit"]="apt-get update && apt-get -y install snapd && snap install searchsploit"

commands["secretfinder"]="git clone https://github.com/m4ll0k/SecretFinder.git secretfinder && cd secretfinder && pip3 install -r requirements.txt && cd .. && cp -rf secretfinder/ /opt/ && rm -rf secretfinder && grep -q 'export PATH=\$PATH:/opt/secretfinder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/secretfinder' >> \$CONFIG_FILE"

commands["sherlock"]="pip3 install sherlock-project"

commands["shuffledns"]="go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest && mkdir /opt/shuffledns ; mv -f ~/go/bin/shuffledns /opt/shuffledns/ && grep -q 'export PATH=\$PATH:/opt/shuffledns' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/shuffledns' >> \$CONFIG_FILE"

commands["spiderfoot"]="git clone https://github.com/smicallef/spiderfoot.git && cd spiderfoot && pip3 install -r requirements.txt && cd .. && cp -rf spiderfoot/ /opt/ && rm -rf spiderfoot && grep -q 'export PATH=\$PATH:/opt/spiderfoot' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/spiderfoot' >> \$CONFIG_FILE"

commands["sqlmap"]="git clone https://github.com/sqlmapproject/sqlmap.git --depth 1 && cp -rf sqlmap/ /opt/ && rm -rf sqlmap && grep -q 'export PATH=\$PATH:/opt/sqlmap' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/sqlmap' >> \$CONFIG_FILE"

commands["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && mkdir /opt/subfinder ; mv -f ~/go/bin/subfinder /opt/subfinder/ && grep -q 'export PATH=\$PATH:/opt/subfinder' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/subfinder' >> \$CONFIG_FILE"

commands["subjs"]="go install -v github.com/lc/subjs@latest && mkdir /opt/subjs ; mv -f ~/go/bin/subjs /opt/subjs/ && grep -q 'export PATH=\$PATH:/opt/subjs' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/subjs' >> \$CONFIG_FILE"

commands["sudomy"]="apt-get -y install jq nmap phantomjs npm chromium parallel ; npm i -g wappalyzer wscat ; git clone --recursive https://github.com/screetsec/Sudomy.git && cd Sudomy && pip3 install -r requirements.txt && cd .. && mkdir /opt/sudomy ; cp -rf Sudomy/* /opt/sudomy/ && rm -rf Sudomy && grep -q 'export PATH=\$PATH:/opt/sudomy' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/sudomy' >> \$CONFIG_FILE"

commands["sublist3r"]="git clone https://github.com/aboul3la/Sublist3r.git && cd Sublist3r && pip3 install -r requirements.txt && cd .. && mkdir /opt/sublist3r ; cp -rf Sublist3r/* /opt/sublist3r/ && rm -rf Sublist3r && grep -q 'export PATH=\$PATH:/opt/Sublist3r' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/Sublist3r' >> \$CONFIG_FILE"

commands["testssl"]="snap install testssl"

commands["theharvester"]="git clone https://github.com/laramies/theHarvester && cd theHarvester && python3 -m pip install -r requirements/base.txt && cd .. && mkdir /opt/theharvester ; cp -rf theHarvester/* /opt/theharvester/ && rm -rf theHarvester && grep -q 'export PATH=\$PATH:/opt/theharvester' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/theharvester' >> \$CONFIG_FILE"

commands["trufflehog"]="git clone https://github.com/trufflesecurity/trufflehog.git && cd trufflehog && go install && cd .. && rm -rf trufflehog && mkdir /opt/trufflehog ; mv -f ~/go/bin/trufflehog /opt/trufflehog/ && grep -q 'export PATH=\$PATH:/opt/trufflehog' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/trufflehog' >> \$CONFIG_FILE"

commands["uncover"]="go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest && mkdir /opt/uncover ; mv -f ~/go/bin/uncover /opt/uncover/ && grep -q 'export PATH=\$PATH:/opt/uncover' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/uncover' >> \$CONFIG_FILE"

commands["unfurl"]="go install github.com/tomnomnom/unfurl@latest && mkdir /opt/unfurl ; mv -f ~/go/bin/unfurl /opt/unfurl/ && grep -q 'export PATH=\$PATH:/opt/unfurl' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/unfurl' >> \$CONFIG_FILE"

commands["uro"]="pip3 install uro"

commands["wafw00f"]="git clone https://github.com/EnableSecurity/wafw00f.git && cd wafw00f && python3 setup.py install && cd .. && cp -rf wafw00f/ /opt/ && rm -rf wafw00f && grep -q 'export PATH=\$PATH:/opt/wafw00f/bin' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/wafw00f/bin' >> \$CONFIG_FILE"

commands["waybackurls"]="go install github.com/tomnomnom/waybackurls@latest && mkdir /opt/waybackurls ; mv -f ~/go/bin/waybackurls /opt/waybackurls/ && grep -q 'export PATH=\$PATH:/opt/waybackurls' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/waybackurls' >> \$CONFIG_FILE"

commands["wfuzz"]="pip3 install wfuzz"

commands["whoxyrm"]="go install github.com/milindpurswani/whoxyrm@latest && mkdir /opt/whoxyrm ; mv -f ~/go/bin/whoxyrm /opt/whoxyrm/ && grep -q 'export PATH=\$PATH:/opt/whoxyrm' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/whoxyrm' >> \$CONFIG_FILE"

commands["wpscan"]="apt-get update && apt-get -y install ruby && apt-get -y install build-essential libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev libgmp-dev zlib1g-dev && gem install wpscan"

commands["xurlfind3r"]="go install -v github.com/hueristiq/xurlfind3r/cmd/xurlfind3r@latest && mkdir /opt/xurlfind3r ; mv -f ~/go/bin/xurlfind3r /opt/xurlfind3r/ && grep -q 'export PATH=\$PATH:/opt/xurlfind3r' \$CONFIG_FILE || echo 'export PATH=\$PATH:/opt/xurlfind3r' >> \$CONFIG_FILE"

# Dicionarios e Similiares
commands["assetnote-wordlists"]="wget -r --no-parent -R 'index.html*' -e robots=off https://wordlists-cdn.assetnote.io/data/ -nH && mkdir -p /opt/wordlists/assetnote ; cp -rf data/* /opt/wordlists/assetnote/ && rm -rf data"

commands["seclists"]="git clone https://github.com/danielmiessler/SecLists.git && mkdir -p /opt/wordlists/seclists ; cp -rf SecLists/* /opt/wordlists/seclists/ && rm -rf SecLists"

commands["resolvers"]="wget https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt && wget https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-trusted.txt && mv -f resolvers*.txt /opt/"


# Selecao e Ordem de Instalacao
order=("ubuntu-update" "basic-tools" "snap-refresh" "go" "python3" "airixss" "amass" "anew" "archivefuzz" "arjun" "assetfinder" "cdncheck" "cf-check" "chaos" "dalfox" "dirsearch" "dnsdumpster" "dnsexpire" "dnsgen" "dnspy" "dnsvalidator" "dnsx" "exif" "exploitdb" "ffuf" "findomain" "freq" "gau" "gauplus" "geospy" "getjs" "gf" "gitdorker" "github-subdomains" "github-endpoints" "gittools" "gobuster" "goop" "gospider" "gowitness" "gxss" "hakcheckurl" "haklistgen" "hakrawler" "hakrevdns" "haktldextract" "haktrails" "httpie" "httprobe" "httpx" "jsscanner" "jsubfinder" "katana" "knock" "linkfinder" "mariadb-client" "meg" "metabigor" "mildew" "naabu" "netdiscover" "nikto" "nilo" "nmap" "notify" "nuclei" "oneforall" "paramspider" "photon" "prips" "puredns" "qsreplace" "quaithe" "rayder" "revwhoix" "sdlookup" "searchsploit" "secretfinder" "sherlock" "shuffledns" "spiderfoot" "sqlmap" "subfinder" "subjs" "sudomy" "sublist3r" "testssl" "theharvester" "trufflehog" "uncover" "unfurl" "uro" "wafw00f" "waybackurls" "wfuzz" "whoxyrm" "wpscan" "xurlfind3r" "assetnote-wordlists" "seclists" "resolvers")

# ============ FIM DA AREA EDITAVEL ============

banner() {
    text=(
            ''
            '\033[0;32m                  _____                  __      _______   _____'
            '\033[0;32m                 |  __ \                 \ \    / /  __ \ / ____|'
            '\033[0;32m  _ __ ___  _   _| |__) |___  ___ ___  _ _\ \  / /| |__) | (___'
            '\033[0;32m | `_ ` _ \| | | |  _  // _ \/ __/ _ \| `_ \ \/ / |  ___/ \___ \'
            '\033[0;32m | | | | | | |_| | | \ \  __/ (_| (_) | | | \  /  | |     ____) |'
            '\033[0;32m |_| |_| |_|\__, |_|  \_\___|\___\___/|_| |_|\/   |_|    |_____/'
            '\033[0;32m             __/ |                                       v1.0.2'
            '\033[0;32m            |___/                                    \033[0;33mby Andalik'
            ''
            ''
            '\033[0mProgresso: |#                                                  | 0%'
    )

    clear
    for line in "${text[@]}"; do
        echo -e "$line"
    done
    sleep 3

    for i in {1..11}; do
        # Remove a primeira linha do texto
        text=("${text[@]:1}")
        clear
        for line in "${text[@]}"; do
            echo -e "$line"
        done
        sleep 0.15
    done
}

check_os() {
    if [[ -e /etc/debian_version ]]; then
        OS="debian"
        source /etc/os-release

        if [[ $ID == "debian" || $ID == "raspbian" ]]; then
            if [[ $VERSION_ID -lt 9 ]]; then
                echo "~Z| ~O Your version of Debian is not supported."
                echo ""
                echo "However, if you're using Debian >= 9 or unstable/testing then you can continue, at your own risk."
                echo ""
                until [[ $CONTINUE =~ (y|n) ]]; do
                    read -rp "Continue? [y/n]: " -e CONTINUE
                done
                if [[ $CONTINUE == "n" ]]; then
                    exit 1
                fi
            fi
        elif [[ $ID == "ubuntu" ]]; then
            OS="ubuntu"
            MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
            if [[ $MAJOR_UBUNTU_VERSION -lt 20 ]]; then
                echo "~Z| ~O Your version of Ubuntu is not supported."
                echo ""
                echo "However, if you're using Ubuntu >= 20.04 or unstable/testing then you can continue, at your own risk."
                echo ""
                until [[ $CONTINUE =~ (y|n) ]]; do
                    read -rp "Continue? [y/n]: " -e CONTINUE
                done
                if [[ $CONTINUE == "n" ]]; then
                    exit 1
                fi
            fi
	fi
    else
        echo "~_~[~Q Looks like you aren't running this installer on a Debian or Ubuntu Linux system."
        exit 1
    fi
}

colored_echo() {
    case $1 in
        "red")
            echo -e "\e[31m$2\e[0m"
            ;;
        "green")
            echo -e "\e[32m$2\e[0m"
            ;;
        "yellow")
            echo -e "\e[33m$2\e[0m"
            ;;
        "blue")
            echo -e "\e[34m$2\e[0m"
            ;;
    esac
}

show_progress() {
    local current=$1
    local total=$2

    if [ -z "$current" ] || [ -z "$total" ] || [ "$total" -eq 0 ]; then
        return
    fi

    local perc=$(( (current * 100) / total ))
    local filled=$(( (perc * 50) / 100 ))
    local unfilled=$(( 50 - filled ))

    # Move o cursor uma linha para cima e atualiza a barra de progresso
    echo -ne "\r\e[1A\e[KProgresso: |$(printf '#%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $unfilled))| $perc% "
}


# Corra Forrest, corra...

# checar permissao de superusuario 
if [ "$EUID" -ne 0 ]; then
    colored_echo "ERRO: Necessario privilegios de superusuario."
    colored_echo "      Utilize sudo $0"
    exit 1
fi

# checar sistema operacional
check_os

# exibir banner
banner

# Inicialmente exibe a barra de progresso em 0%
show_progress 0 ${#order[@]}
echo # Cria uma linha vazia após a barra de progresso
total_commands=${#order[@]}
progress=0

# Identificar tipo de shell
CONFIG_FILE=$HOME/$(case $SHELL_TYPE in bash) echo '.bashrc' ;; zsh) echo '.zshrc' ;; *) echo '.profile' ;; esac)

# Executar comandos de instalação na ordem definida
start_time=$(date +%s)

for tool in "${order[@]}"; do
    cmd="${commands[$tool]}"
    
    show_progress $progress $total_commands
    colored_echo "blue" " Instalando $tool. \033[5mAguarde..."
    eval "$cmd" > /dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        colored_echo "red" "\n[ERRO] Falha no comando $tool"
        exit 1
    fi

    progress=$((progress + 1))
done

end_time=$(date +%s)
execution_time=$((end_time - start_time))
execution_time_formatted=$(printf "%02d:%02d:%02d" $((execution_time/3600)) $(( (execution_time%3600)/60 )) $((execution_time%60)))

echo -ne "\r\e[1A\e[KProgresso: |################################################## | 100%"
colored_echo "green" " Instalacao concluida!"

echo -e "\n[Lista de Ferramentas]"
for tool in "${order[@]}"; do
    colored_echo "blue" " > $tool"
done
colored_echo "blue" "\n${#order[@]} ferramentas instaladas ou atualizadas em $execution_time_formatted."

colored_echo "red" "\nAtualize a sessao atual do shell com o comando:"
colored_echo "red" " source $CONFIG_FILE"

colored_echo "yellow" "\nHack the Planet!"
