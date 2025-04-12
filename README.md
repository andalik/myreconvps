<pre>
                    ____                      _    ______  _____
   ____ ___  __  __/ __ \___  _________  ____| |  / / __ \/ ___/
  / __ `__ \/ / / / /_/ / _ \/ ___/ __ \/ __ \ | / / /_/ /\__ \ 
 / / / / / / /_/ / _, _/  __/ /__/ /_/ / / / / |/ / ____/___/ / 
/_/ /_/ /_/\__, /_/ |_|\___/\___/\____/_/ /_/|___/_/    /____/  
          /____/                                   by Andalik
</pre>


### Dependências e Pacotes Terceiros Instalados
Obtidos via repositório oficial no GitHub:<br>

 > ubuntu-update
 > basic-tools
 > snap-refresh
 > go
 > python3
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
 > httpie
 > httprobe
 > httpx
 > jsscanner
 > jsubfinder
 > katana
 > knock
 > linkfinder
 > mariadb-client
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
 > whoxyrm
 > wpscan
 > xurlfind3r
 > assetnote-wordlists
 > seclists
 > resolvers

### Instalação
Se o seu usuário não tem direitos administrativos, digite <b>sudo su</b> e execute o script especificamente como usuário root.<br>
<br>
Ao final da instalação, replique o caminho das ferramentas instaladas existente no arquivo de configuração do usuário root (busque pelas linhas com o caminho das ferramentas no final do arquivo /root/.bashrc ou /root/.zshrc) para o seu usuário (/home/usuario/.bashrc ou /home/usuario/.zshrc).<br>
<br>
Isso serve para que as ferramentas instaladas também sejam acessíveis no terminal do seu usuário através do comando sudo.

### Atualização dos Pacotes Obtidos via GITHUB
Sempre que for necessário atualizar os pacotes já instalados, basta reexecutar o script de instalação.

### PEP 668
Em versões mais recentes do Python aderentes ao PEP 668, podem ocorrer erros no uso do pip:

error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try apt install
    python3-xyz, where xyz is the package you are trying to
    install.

Para que o instalador funcione adequadamente, as seguintes alterações são necessárias:
```
vi ~/.config/pip/pip.conf

[global]
break-system-packages = true 
```

Caso o arquivo de configuração do pip não exista, crie-o manualmente.
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
