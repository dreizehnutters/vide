#!/usr/bin/env bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ -f "$SCRIPTPATH/colors.sh" ]; then
    . "$SCRIPTPATH"/colors.sh
else
    printf "'$SCRIPTPATH/colors.sh' could not be located.\n"
    exit 1
fi

# ---= menu =--- TODO
help() {
    printf "\
    usage: $IN$(basename $BASH_SOURCE)${RST} -${BD}d${RST} <path to directory with folder called '${UL}nmap${RST}'>${RST}
                  [-${BD}h${RST}]                       show this message
                  [-${BD}wh${RST}]                      enable ${FBU}Wh${RST}hatweb scans
                  [-${BD}wa${RST}]                      enable ${FBU}Wa${RST}banalyze scans
                  [-${BD}nm${RST}]                      enable ${FBU}nm${RST}ap script scans
                  [-${BD}nu${RST}]                      enable ${FBU}Nu${RST}clei scans
                  [-${BD}ni${RST}]                      enable ${FBU}Ni${RST}kto scans
                  [-${BD}ff${RST}]                      enable ${FBU}ff${RST}uf brute forcing
                  [-${BD}sc${RST}]                      enable ${FBU}sc${RST}reenshotting
                  [-${BD}ka${RST}]                      enable ${FBU}ka${RST}tana crwal
                  [-${BD}by${RST}]                      enable ${FBU}by${RST}pass (40X) scans
                  [-${BD}p${RST} <path to webservers>]  ${FBU}p${RST}ass list of servers to process {<PROTO>://<IP>[:<PORT>]}
                  [-${BD}c${RST} <path to config>]      ${FBU}c${RST}onfig file to pass (default: vide.cfg)\n
                  [--${BD}check${RST}]                  verify configuration file (default: config.sh)\n"

    exit 2
}

# ---= arg parse =---
CMD_LOG="vide.log"
echo -e "[$(date +%d.%m:%H%M)]\t$(basename "$0") $@" >> "$CMD_LOG"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -sc) DO_SCREENSHOTS="true";;
    -wh) DO_WHATWEB="true";;
    -nu) DO_NUCLEI="true";;
    -ni) DO_NIKTO="true";;
    -ff) DO_FFUF="true";;
    -ka) DO_KATANA="true";;
    -wa) DO_WA="true";;
    -by) DO_404="true";;
    -nm) DO_NMAP="true";;
    --all) declare DO_{SCREENSHOTS,WHATWEB,DO_WA,NUCLEI,NIKTO,FFUF,KATANA,NMAP,404}="true";;
    --force) FORCE_EXEC="true";;
    --http) HTTP_ONLY="true";;
    --https) HTTPS_ONLY="true";;
    --check) CHECK_INSTALL="true";;
    -d|--project-dir) PROJECT_DIR="$2"; shift;;
    -p|--opt-webservers-list) OPT_WEBSERVERS_LIST="$2"; shift;;
    -c|--custom-config) USE_CC="true";CUSTOM_CONFIG="$2"; shift;;
    -h|--help) help; exit 0;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
  shift
   if [[ -z $HTTPS_ONLY && -z $HTTP_ONLY ]]; then
      ALL_SERVERS="true"
   fi
done

if [ -n "$CHECK_INSTALL" ]; then
    CHECK=true
    . "$SCRIPTPATH"/colors.sh
    . "$SCRIPTPATH"/config.sh
fi

NUM_FLAGS="$(set | grep -i "DO_" | wc -l)"
[[ -z $PROJECT_DIR ]] && help && exit 2

# ---= config =---
if [ -n "$USE_CC" ]; then
  [[ -f "$CUSTOM_CONFIG" ]] && RUNNING_CONFIG=$CUSTOM_CONFIG
else
  [[ -f "${SCRIPTPATH}/config.sh" ]] && RUNNING_CONFIG="${SCRIPTPATH}/config.sh"
fi

if [[ -n $RUNNING_CONFIG ]]; then
    . "${RUNNING_CONFIG}"
else
    printf "${EP}no config loaded (config.sh not found in current directory)\n";
    exit 1
fi

MODULE_PATH="$SCRIPTPATH/modules"

# ---= utils =---
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

dissect() {
    DELIM='#'
    IP=$(echo $1 | cut -d  $DELIM -f1)
    PORT=$(echo $1 | cut -d  $DELIM -f2)
    CONF=$(echo $1 | cut -d  $DELIM -f3)
    SVC=$(echo $1 | cut -d  $DELIM -f4-)
    [ -z "$CONF" ] && CONF=0
    [ -z "$SVC" ] && SVC="?"
    REPLY=($IP $PORT $CONF $SVC)
}

l2() {
    printf "\t$YL[$COUNTER/$NUM_WS] $RST$BD$1$RST $TARGET\n"
}

# ---= main =----
if $SHOW_BANNER; then
VS=${BD}${GN}${VERSION}${RST}
printf "        _______________                                     \n"
printf "    $BD==c(___(o(______(_()$RST                             \n"
printf "            \=\\                                            \n"
printf "             )=\\    ┌─────────────────────────~vide~────┐  \n"
printf "            //|\\\\\   │ high-level web server enumeration │\n"
printf "           //|| \\\\\  │ version: $VS                      │\n"
printf "          // ||. \\\\\ └───────────────────────────────────┘\n"
printf "        .//  ||   \\\\\ .                                   \n"
printf "        //  .      \\\\\                                    \n\n"
unset VS
fi

# ---= parse the xml output from nmap =---
if [ -z "$OPT_WEBSERVERS_LIST" ]; then
    [ ! -d "$NMAP_PATH" ] && printf "$QP Directory '$NMAP_PATH' does not exit.\nBe sure path contains folder called $BD'nmap'$RST with $BD.xml$RST data.\n" && exit 2
    printf "$OP${IN}grepping open ports per host from $NMAP_PATH/*.xml$RST\n"
    $XMLS sel -t -m '//port/state[@state="open"]/parent::port' \
                -v 'ancestor::host/address[not(@addrtype="mac")][1]/@addr' \
                -o '#' -v './@portid' -o '#' -v './service/@conf' -o '#' -v './service/@name' \
                -n "$NMAP_PATH"/*.xml | sort -u -V > "$NMAP_PARSE"

    rm -rf $CANDIDATES_FILE
    sort -t'#' -k3rn $NMAP_PARSE | awk -F'#' '!a[$1,$2,$4]++' > "tmp"
    mv "tmp" $NMAP_PARSE
    for f in $(cat $NMAP_PARSE); do
        dissect $f
        echo "$IP:$PORT" >> $CANDIDATES_FILE
        unset {IP,PORT,CONF,SVC}
    done
else
    CANDIDATES_FILE=$OPT_WEBSERVERS_LIST
fi
CANDIDATES=$(wc -l "$CANDIDATES_FILE" | cut -d' ' -f1)
if [ "$CANDIDATES" == "0" ]; then
    printf "${EP}no open ports found.\n"
    exit 1
fi

# ---= modules =---
if [[ -z "$DO_NMAP" || $NUM_FLAGS -gt 1 ]]; then
. $MODULE_PATH/httpx.sh
fi

if [ -n "$DO_SCREENSHOTS" ]; then
. $MODULE_PATH/screenshot.sh
fi

if [ -n "$DO_WHATWEB" ]; then
. $MODULE_PATH/whatweb.sh
fi

if [ -n "$DO_NUCLEI" ]; then
. $MODULE_PATH/nuclei.sh
fi

if [ -n "$DO_NIKTO" ]; then
. $MODULE_PATH/nikto.sh
fi

if [ -n "$DO_FFUF" ]; then
. $MODULE_PATH/ffuf.sh
fi

if [ -n "$DO_KATANA" ]; then
. $MODULE_PATH/katana.sh
fi

if [ -n "$DO_WA" ]; then
. $MODULE_PATH/webanalyze.sh
fi

if [ -n "$DO_404" ]; then
. $MODULE_PATH/bypass40X.sh
fi

if [ -n "$DO_NMAP" ]; then
. $MODULE_PATH/nmap.sh
fi

printf "$OP${IN}DONE$RST\n"
exit 0
