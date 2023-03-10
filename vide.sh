#!/bin/bash

# ---= colors =---
RST='\033[0m'
BG='\033[47m'
FG='\033[030m'
UL='\e[4m'
BD='\033[1m'
GN='\e[32m'

# ---= menu =---
help() {
    echo -e "usage: $FG$BG$(basename $BASH_SOURCE)${RST} -${BD}d${RST} <path to directory with folder called '${UL}nmap${RST}'>${RST}
       [-${BD}h${RST}]                          show this message
       [-${BD}w${RST}]                          enable ${UL}W${RST}hatWeb scan
       [-${BD}i${RST}]                          enable Nucle${UL}i${RST} scan
       [-${BD}o${RST}]                          enable Nikt${UL}o${RST} scan
       [-${BD}f${RST}]                          enable ${UL}f${RST}fuf brute orcing
       [-${BD}s${RST}]                          enable ${UL}s${RST}creenshotting
       [-${BD}p${RST} <path to webservers.txt>] ${UL}p${RST}ass list of servers to process {<PROTO>://<IP>[:<PORT>]}"
    exit 2
}

parse() {
    PROTO=$(echo "$1" | cut -d ':' -f1)
    TMP_TARGET=$(echo "$1" | cut -d '/' -f3-)
    IP=$(echo "$TMP_TARGET" | cut -d ':' -f1)
    FILE_NAME=$(echo "$TMP_TARGET" | tr ':' '_')
    if [[ $PROTO == "https"* ]]; then
        TMP=$(echo "$1" | cut -d':' -f3-)
        PORT="${TMP:-443}"
        DO_SSL="true"
    else
        TMP=$(echo "$1" | cut -d':' -f3-)
        PORT="${TMP:-80}"
    fi
    REPLY=($PROTO $IP $PORT $FILE_NAME $DO_SSL)
}

# ---= arg parse =---
while getopts 'wd:iofshp:' flag; do
    case "${flag}" in
    w) DO_WHATWEB="true" ;;
    s) DO_SCREENSHOTS="true" ;;
    i) DO_NUCLEI="true" ;;
    o) DO_NIKTO="true" ;;
    f) DO_FFUF="true" ;;
    h) help ;;
    d) PROJECT_DIR="${OPTARG}" ;;
    p) OPT_WEBSERVERS_LIST="${OPTARG}" ;;
    *) help
       exit 1 ;;
    esac
done
[[ -z  $PROJECT_DIR  ]] && help && exit 2

# ---= config =---
# globals
VERSION=1.2
timestamp=$(date +%d.%m_%H%M)
COUNTER=1
THREADS=40
BASE="$PROJECT_DIR"
GO_PATH="$HOME/go"
WORK_DIR="$BASE/vide_$timestamp"
NMAP_PATH="$BASE/nmap"
WS_FILE="$WORK_DIR/webservers.txt"
CANDIDATES_FILE="$NMAP_PATH/host_port.txt"

# nikto
NIKTO_DIR="$WORK_DIR/nikto"

# screenshots
SCREEN_DIR="$WORK_DIR/screens"
SS_TIMEOUT=15
DOM_DELAY=1000

# httpx
HTTPX_DIR="$WORK_DIR/httpx"
HTTPX_LOG="$HTTPX_DIR/scan.log"
RATE_LIMIT=100

# whatweb
WW_DIR="$WORK_DIR/whatweb"
WHATWEB_LEVEL=3

# nuclei
NUCLEI_DIR="$WORK_DIR/nuclei"
NUCLEI_TEMPLATES="$HOME/tools/nuclei-templates" #CHANGE ME

# ffuf
FFUF_DIR="$WORK_DIR/ffuf"
WORDLIST="/opt/goto.wordlist" #CHANGE ME

# bins
CH=/usr/bin/chromium
WW=/usr/bin/whatweb
XMLS=/usr/bin/xmlstarlet
NIKTO=/usr/bin/nikto
HTTPX=$GO_PATH/bin/httpx
NUCLEI=$GO_PATH/bin/nuclei
FFUF=/usr/bin/ffuf

# ---= init =---
mkdir -p "$WORK_DIR" "$HTTPX_DIR"
[ -n "$DO_WHATWEB" ] && mkdir -p "$WW_DIR"
[ -n "$DO_NIKTO" ] && mkdir -p "$NIKTO_DIR"
[ -n "$DO_FFUF" ] && mkdir -p "$FFUF_DIR"
[ -n "$DO_SCREENSHOTS" ] && mkdir -p "$SCREEN_DIR"

# ---= main =----
if $SHOW_BANNER; then
echo -e "        _______________
    ==c(___(o(______(_()
            \=\\
             )=\\
            //|\\\\\  ~vide~
           //|| \\\\\  high-level web server enumeration
          // ||. \\\\\ version: ${BD}${GN}${VERSION}${RST}
        .//  ||   \\\\\ .
        //  .      \\\\\ "
fi

# ---= nmap parsing =---
if [ -z "$OPT_WEBSERVERS_LIST" ]; then
    [ ! -d "$NMAP_PATH" ] && echo "Directory '$NMAP_PATH' does not exit. Be sure path contains folder called 'nmap' with .xml data." && exit 2
    echo -e "$FG$BG[*] grepping open ports per host from $NMAP_PATH/*.xml"
    $XMLS sel -t -m '//port/state[@state="open"]/parent::port' \
                -v 'ancestor::host/address[@addrtype="ipv4"]/@addr' \
                -o : -v './@portid' -n "$NMAP_PATH"/*.xml | sort -u -V > "$CANDIDATES_FILE"
else
    CANDIDATES_FILE=$OPT_WEBSERVERS_LIST
fi

CANDIDATES=$(wc -l "$CANDIDATES_FILE" | cut -d' ' -f1)

if [ "$CANDIDATES" == "0" ]; then
        echo "$FG$BG[!] no web servers found$RST"
        exit 1
fi

# ---= scan for web servers among all found ports =---
echo -e "$FG$BG[*] identifying web servers from $CANDIDATES candidates$RST"
$HTTPX -l "$CANDIDATES_FILE" -exclude-cdn -ec -nf -H "$0" \
                           -x ALL -ldp -ec -nfs -server -probe -title -sc -cl \
                           -tech-detect -threads "$THREADS" -rate-limit "$RATE_LIMIT" -o "$HTTPX_LOG"
grep -v "31mFAILED.*0m" "$HTTPX_LOG" | grep . | cut -d' ' -f1 | sort -u -V > "$WS_FILE"
NUM_WS=$(wc -l "$WS_FILE" | cut -d' ' -f1)
if [ "$NUM_WS" == "0" ]; then
    echo "[!] no web servers found"
    exit 1
fi
echo -e "$FG$BG[*] found $NUM_WS web servers"

# ---= take screenshots of web server =---
if [ -n "$DO_SCREENSHOTS" ]; then
echo -e "$FG$BG[*] screenshotting each server:$RST"
for TARGET in $(grep -v "#" "$WS_FILE" | sort -V); do
    echo -e "\t$FG$BG[$COUNTER/$NUM_WS] taking screenshots of: $TARGET$RST"
    parse $TARGET
    mkdir -p "$SCREEN_DIR/$PROTO"
    timeout $SS_TIMEOUT $CH --no-sandbox \
                            --headless \
                            --ignore-certificate-errors \
                            --password-store=basic \
                            --run-all-compositor-stages-before-draw \
                            --virtual-time-budget="$DOM_DELAY" \
                            --print-to-pdf="$SCREEN_DIR/$PROTO/$FILE_NAME.pdf" "$PROTO://$TMP_TARGET/" 2>/dev/null
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
COUNTER=1
fi

# ---= scan server tech/headers =---
if [ -n "$DO_WHATWEB" ]; then
echo -e "$FG$BG[*] WhatWeb tech scans:$RST"
for TARGET in $(grep -v "#" "$WS_FILE" | sort -V); do
    parse $TARGET
    echo -e "\t$FG$BG[$COUNTER/$NUM_WS] WhatWeb scan of: $TARGET$RST"
    mkdir -p "$WW_DIR/$FILE_NAME"
    $WW --aggression=$WHATWEB_LEVEL "$TARGET" --log-verbose="$WW_DIR/$FILE_NAME/deep.log" --log-brief="$WW_DIR/$FILE_NAME/brief.log" --max-threads="$THREADS"
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
for x in brief deep; do find "$WW_DIR" -type f -name "${x}.log" -exec cat {} >>"$WW_DIR/${x}_all.log" +;done
COUNTER=1
fi

# ---= deploy nuclei scans =---
if [ -n "$DO_NUCLEI" ]; then
echo -e "$FG$BG[*] nuclei scans:$RST"
for TARGET in $(grep -v "#" "$WS_FILE" | sort -V); do
    echo -e "\t$FG$BG[$COUNTER/$NUM_WS] full template scan of: $TARGET$RST"
    $NUCLEI -ud "$NUCLEI_TEMPLATES" -u "$TARGET" -ni -i "$IFACE" -irr -stats -timeout 5 -markdown-export "$NUCLEI_DIR"/"$TARGET"
    let COUNTER++
done
COUNTER=1
fi

# ---= deploy nikto scans =---
if [ -n "$DO_NIKTO" ]; then
echo -e "$FG$BG[*] nikto scans:$RST"
touch "${TMP_file:=tmp_file.txt}"
for TARGET in $(grep -v "#" "$WS_FILE" | sort -V); do
    parse $TARGET
    if grep -Fxq "$IP:$PORT" $TMP_file; then
        continue
    else
        if [ -n "$DO_SSL" ]; then
            SSL_FLAG="-ssl"
        else
            SSL_FLAG="-nossl"
        fi
        echo "n" | $NIKTO -no404 -host "$PROTO://$IP:$PORT" -Tuning x567 "$SSL_FLAG" -Format htm -output "$NIKTO_DIR/$FILE_NAME.html"
        echo "$IP:$PORT" >> $TMP_file
    fi
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
rm -f $TMP_file
fi

# ---= directory brute force =---
if [ -n "$DO_FFUF" ]; then
echo -e "$FG$BG[*] FFUF dir brute force:$RST"
touch "${TMP_file:=tmp_file.txt}"
for TARGET in $(grep -v "#" "$WS_FILE" | sort -V); do
    parse $TARGET
    if grep -Fxq "$IP:$PORT" $TMP_file; then
        continue
    else
        $FFUF -u "$PROTO://$IP:$PORT/FUZZ" -w "$WORDLIST" -mc all -ac -c -t "$THREADS" -of html -o "$FFUF_DIR/$FILE_NAME.html"
        echo "$IP:$PORT" >> $TMP_file
    fi
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}

done
rm -f $TMP_file
fi

echo -e "$FG$BG[*] DONE"
exit 0
