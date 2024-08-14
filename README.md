<pre>
                    ____                      _    ______  _____
   ____ ___  __  __/ __ \___  _________  ____| |  / / __ \/ ___/
  / __ `__ \/ / / / /_/ / _ \/ ___/ __ \/ __ \ | / / /_/ /\__ \ 
 / / / / / / /_/ / _, _/  __/ /__/ /_/ / / / / |/ / ____/___/ / 
/_/ /_/ /_/\__, /_/ |_|\___/\___/\____/_/ /_/|___/_/    /____/  
          /____/                                   by Andalik
</pre>


## Dependências e Pacotes Terceiros Instalados
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

## Atualização dos Pacotes Obtidos via GITHUB
Sempre que for necessário atualizar os pacotes já instalados, basta reexecutar o script de instalação.

## PEP 668
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
