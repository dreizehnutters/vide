# ---= check =---
if [ -n "$CHECK" ]; then
	GIT_REL="$(git --git-dir $SCRIPTPATH/.git log --format='%h %ci' -1 2>/dev/null | awk '{ print "#"$1 }')"
	printf "running build ${BD}$GIT_REL${RST}\n"
	SCRIPTPATH="$(
		cd "$(dirname "$0")" >/dev/null 2>&1
		pwd -P
	)"
	printf "checking config: '$SCRIPTPATH/config.sh'\n"
	# ---= path =---
	if [ -n "$HOME" ]; then printf "${OP}${BD}HOME${RST}	is set to '$HOME'\n"; else printf "${EP}${BD}HOME${RST} not exported\n"; fi
	if [ -n "$GO_PATH" ]; then printf "${OP}${BD}GO_PATH${RST}	is set to '$GO_PATH'\n"; else printf "${EP}${BD}GO_PATH${RST} not exported\n"; fi
	printf -- '-%.0s' {1..35}
	printf "\n"
	# ---= bins =---
	if [ -f "$NMAP" ]; then printf "${OP}${BD}nmap${RST}		is installed\n"; else printf "${EP}${BD}nmap${RST}	not found under: $NMAP\n"; fi
	if [ -f "$XMLS" ]; then printf "${OP}${BD}xmlstarlet${RST}		is installed\n"; else printf "${EP}${BD}xmlstarlet${RST}	not found under: $XMLS\n"; fi
	if [ -f "$NIKTO" ]; then printf "${OP}${BD}nikto${RST}		is installed\n"; else printf "${EP}${BD}nikto${RST}	not found under: $NIKTO\n"; fi
	if [ -f "$WW" ]; then printf "${OP}${BD}WhatWeb${RST}		is installed\n"; else printf "${EP}${BD}WhatWeb${RST}	not found under: $WW\n"; fi
	if [ -f "$FFUF" ]; then printf "${OP}${BD}ffuf${RST}		is installed\n"; else printf "${EP}${BD}ffuf${RST}	not found under: $FFUF\n"; fi
	if [ -f "$BYP4" ]; then printf "${OP}${BD}byp4xx${RST}		is installed\n"; else printf "${EP}${BD}byp4xx${RST}	not found under: $BYP4\n"; fi
	if [ -f "$SUBJS" ]; then printf "${OP}${BD}subjs${RST}		is installed\n"; else printf "${EP}${BD}subjs${RST}	not found under: $SUBJS\n"; fi
	if [ -f "$HTTPX" ]; then printf "${OP}${BD}httpx${RST}		is installed\n"; else printf "${EP}${BD}httpx${RST}	not found under: $HTTPX\n"; fi
	if [ -f "$NUCLEI" ]; then printf "${OP}${BD}nuclei${RST}		is installed\n"; else printf "${EP}${BD}nuclei${RST}	not found under: $NUCLEI\n"; fi
	if [ -f "$KATANA" ]; then printf "${OP}${BD}katana${RST}		is installed\n"; else printf "${EP}${BD}katana${RST}	not found under: $KATANA\n"; fi
	if [ -f "$SMBMAP" ]; then printf "${OP}${BD}smbmap${RST}		is installed\n"; else printf "${EP}${BD}smbmap${RST}	not found under: $SMBMAP\n"; fi
	if [ -f "$ENUM4LINUX" ]; then printf "${OP}${BD}enum4linux-ng${RST}	is installed\n"; else printf "${EP}${BD}enum4linux-ng${RST}	not found under: $ENUM4LINUX\n"; fi
	if [ -f "$TESTSSL" ]; then printf "${OP}${BD}testssl.sh${RST}		is installed\n"; else printf "${EP}${BD}testssl.sh${RST}	not found under: $TESTSSL\n"; fi
	rm -rf $WORK_DIR
	exit 0
fi

# ---= template =---
TEMPLATE_DIR="$WORK_DIR/template"
[ -n "$DO_TEMPLATE" ] && mkdir -p "$TEMPLATE_DIR"

# ---= bins =--- #CHANGE ME (ctrl+f)
NMAP=/usr/bin/nmap
XMLS=/usr/bin/xmlstarlet
NIKTO=/usr/bin/nikto
WW=/usr/bin/whatweb
WA=/usr/local/bin/webanalyze
SMBMAP=/usr/bin/smbmap
ENUM4LINUX=/home/kali/tools/enum4linux-ng/enum4linux-ng.py
FFUF=$GO_PATH/bin/ffuf
BYP4=$GO_PATH/bin/byp4xx
SUBJS=$GO_PATH/bin/subjs
HTTPX=$HOME/.pdtm/go/bin/httpx
NUCLEI=$HOME/.pdtm/go/bin/nuclei
KATANA=$HOME/.pdtm/go/bin/katana
TESTSSL=/home/kali/tools/testssl.sh/testssl.sh

# ---= config =---
VERSION=2.2
timestamp=$(date +%d.%m_%H%M%s)
COUNTER=1
THREADS=40
SCAN_HEADER="github.com/dreizehnutters/vide"
[[ -n $OUT_DIR ]] && PROJECT_DIR=$OUT_DIR || echo OUT_DIR=$PROJECT_DIR
WORK_DIR="$PROJECT_DIR/vide_$timestamp"
CMD_LOG="$WORK_DIR/vide.log"
TMP_DIR="$WORK_DIR/tmp"
mkdir -p $WORK_DIR
mkdir -p $TMP_DIR
WS_FILE="$WORK_DIR/vide_targets.txt"
TARGETS_FILE=$WS_FILE
HTTPS_SERVERS="$WORK_DIR/https_servers.txt"
HTTP_SERVERS="$WORK_DIR/http_servers.txt"
CANDIDATES_FILE="$WORK_DIR/host_port.txt"
NMAP_PARSE="$TMP_DIR/vide_parsed.txt"
printf "${QP}working dir -> '${IL}$WORK_DIR${RST}'\n"

# ---= webanalyze =---
CRAWL_DEPTH=0
WA_JSON="$HOME/tools/technologies.json" #CHANGE ME
WA_DIR="$WORK_DIR/webanalyze"
[ -n "$DO_WA" ] && mkdir -p "$WA_DIR"

# ---= 40X =---
BYP4_DIR="$WORK_DIR/bypass40X"
[ -n "$DO_404" ] && mkdir -p "$BYP4_DIR"

# ---= nmap =---
NMAP_DIR="$WORK_DIR/nmap_scripts"
[ -n "$DO_NMAP" ] && mkdir -p "$NMAP_DIR"

# ---= nikto =---
NIKTO_TUNING="-Tuning x567"
NIKTO_DIR="$WORK_DIR/nikto"
[ -n "$DO_NIKTO" ] && mkdir -p "$NIKTO_DIR"

# ---= screenshots =---
SS_TIMEOUT=50
[ -n "$DO_SCREENSHOTS" ]

# ---= httpX =---
RATE_LIMIT=100
HTTPX_DIR="$WORK_DIR/httpx"
HTTPX_LOG="$HTTPX_DIR/scan.log"
[ -n "$DO_HTTPX" ] && mkdir -p "$HTTPX_DIR"

# ---= whatweb =---
WHATWEB_LEVEL=3
CUSTOM_HEADER="TMP:"
WW_DIR="$WORK_DIR/whatweb"
[ -n "$DO_WHATWEB" ] && mkdir -p "$WW_DIR"

# ---= nuclei =---
NUCLEI_DIR="$WORK_DIR/nuclei"
NUCLEI_TEMPLATES="$HOME/tools/nuclei-templates" #CHANGE ME

# ---= ffuf =---
FFUF_DIR="$WORK_DIR/ffuf"
WORDLIST="$SCRIPTPATH/misc/vide.list"     #CHANGE ME
VWORDLIST="$SCRIPTPATH/misc/virtual.list" #CHANGE ME
METHODS=$TMP_DIR/methods.txt
EXTENSIONS=".php,.html,.aspx,.asp,.cgi,.jsp"
FFUF_OUTFORMAT="json"
echo -e "GET\nPOST" >$METHODS
[[ -n "$DO_FFUF" || -n "$DO_VIRTUAL" ]] && mkdir -p "$FFUF_DIR"

# ---= SUBJS =---
SUBJS_DIR="$WORK_DIR/subjs"
[ -n "$DO_SUBJS" ] && mkdir -p "$SUBJS_DIR"

# ---= TESTSSL =---
TESTSSL_DIR="$WORK_DIR/TESTSSL"
TESTSSL_TMP="$WORK_DIR/TESTSSL_TMP"
TESTSSL_ERRORS="$WORK_DIR/error_on_testssl_scan.txt"
touch $TESTSSL_ERRORS
TESTSSL_CONFIG="--openssl-timeout 10 -E -p -h -S -P -U --hints --warnings off --mapping no-openssl --logfile $TESTSSL_TMP -oJ $TESTSSL_TMP"
[ -n "$DO_TESTSSL" ] && mkdir -p "$TESTSSL_DIR"
mkdir -p "$TESTSSL_DIR"
