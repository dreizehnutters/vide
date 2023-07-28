#!/usr/bin/env bash

SCRIPTPATH="$(dirname $(realpath "$0"))"

[[ -f "$SCRIPTPATH/colors.sh" ]] && . "$SCRIPTPATH/colors.sh" || { printf "'$SCRIPTPATH/colors.sh' could not be located\n"; exit 1; }

OUT_DIR="$PWD"
CMD_LOG="vide.log"
echo -e "[$(date +%d.%m:%H%M)]\t$(basename "$0") $@" >> "$CMD_LOG"

function display_help() {
    printf "\
${IN}Usage:${RST} $(basename "$BASH_SOURCE") input [mods] [options] [misc]

${IN}Required:${RST}
    input   Specify an input format (e.g., file/path, string or stdin)

${IN}Mods:${RST}
    -sp     Skip probing with ${UL}httpx${RST}
    -sc     Skip crawling with ${UL}katana${RST}

${IN}Options:${RST}
    -es     Enable ${UL}screenshot${RST}
    -ew     Enable ${UL}whatweb${RST} scans
    -ea     Enable ${UL}wanalyze${RST} scans
    -en     Enable ${UL}nmap${RST} script scans
    -eu     Enable ${UL}nuclei${RST} scans
    -ei     Enable ${UL}nikto${RST} scans
    -ef     Enable ${UL}ffuf${RST} brute forcing
    -ej     Enable ${UL}js${RST} crawl
    -eb     Enable ${UL}bypass${RST} scans
    --all   Enable ${UL}all${RST} modules

${IN}Misc:${RST}
    -h|--help                  Show this message
    -c|--config <config.sh>    Config file to pass (default: custom.sh)
    -o|--out-dir <path>        Out-dir to work in (default: $PWD)
    --verify                   Check configuration file (default: config.sh)

${IN}Example:${RST}
    $(basename "$BASH_SOURCE") scope.txt --all
    $(basename "$BASH_SOURCE") ./nmap -en -ew -sc --out-dir audit/XYZ
    echo example.com | $(basename "$BASH_SOURCE") -sp -es --config custom.sh
    $(basename "$BASH_SOURCE") --verify\n"
    exit 1
}

# ---= utils =---
function cleanUp() {
    rm -rf $TMP_DIR
    rm -rf /tmp/katana*
    rm -rf /tmp/httpx*
    rm -rf /tmp/nuclei*
    rm -rf $STDIN_HANDLE
    exit 0  
}

function error() {
    printf "${EP}Error: $1\n\n"
    display_help
    exit 1
}

function handle_input() {
    if [[ -f "$1" ]]; then
        REQUIRED_ARG="$1"
        FILE_EXTENSION="${REQUIRED_ARG##*.}"
    elif [[ -d "$1" ]]; then
        REQUIRED_ARG="$1"
        IS_DIRECTORY="true"
    elif [[ -n "$1" ]]; then
        STDIN_HANDLE="./_vide_input.txt"
        echo "$1" > $STDIN_HANDLE
        REQUIRED_ARG=$STDIN_HANDLE
    else
        REQUIRED_ARG=$STDIN_HANDLE
        while IFS= read -r line; do
            echo "$line" >> "$REQUIRED_ARG"
        done
    fi
}

function parse() {
    PROTO=$(echo "$1" | cut -d ':' -f1)
    TMP_TARGET=$(echo "$1" | cut -d '/' -f3-)
    IP=$(echo "$TMP_TARGET" | cut -d ':' -f1)
    FILE_NAME=$(echo "$TMP_TARGET" | tr ':' '_' | tr '/' '_')
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

function dissect() {
    DELIM='#'
    IP=$(echo $1 | cut -d  $DELIM -f1)
    PORT=$(echo $1 | cut -d  $DELIM -f2)
    CONF=$(echo $1 | cut -d  $DELIM -f3)
    SVC=$(echo $1 | cut -d  $DELIM -f4-)
    [ -z "$CONF" ] && CONF=0
    [ -z "$SVC" ] && SVC="?"
    REPLY=($IP $PORT $CONF $SVC)
}

function l2() {
    printf "\t$YL[$COUNTER/$CANDIDATES] $RST$BD$1$RST $TARGET\n"
}

function exec_modules() {
    [[ -n "$DO_SCREENSHOTS" ]]  && . $MODULE_PATH/screenshot.sh
    [[ -n "$DO_WHATWEB" ]]      && . $MODULE_PATH/whatweb.sh
    [[ -n "$DO_NUCLEI" ]]       && . $MODULE_PATH/nuclei.sh
    [[ -n "$DO_NIKTO" ]]        && . $MODULE_PATH/nikto.sh
    [[ -n "$DO_FFUF" ]]         && . $MODULE_PATH/ffuf.sh
    [[ -n "$DO_SUBJS" ]]        && . $MODULE_PATH/subjs.sh
    [[ -n "$DO_WA" ]]           && . $MODULE_PATH/webanalyze.sh
    [[ -n "$DO_404" ]]          && . $MODULE_PATH/bypass40X.sh
    [[ -n "$DO_NMAP" ]]         && . $MODULE_PATH/nmap.sh
}

DO_HTTPX="true"
DO_CRAWL="true"
if [[ $# -gt 0 ]]; then
while [[ $# -gt 0 ]]; do
    case "$1" in
        -sp) unset DO_HTTPX ;;
        -sc) unset DO_CRAWL ;;
        -es) DO_SCREENSHOTS="true" ;;
        -ew) DO_WHATWEB="true" ;;
        -ea) DO_WA="true" ;;
        -eu) DO_NUCLEI="true" ;;
        -ef) DO_NIKTO="true" ;;
        -ef) DO_FFUF="true" ;;
        -ej) DO_SUBJS="true" ;;
        -eb) DO_404="true" ;;
        -en) DO_NMAP="true" ;;
        --all) declare DO_{SCREENSHOTS,WHATWEB,DO_WA,NUCLEI,NIKTO,FFUF,SUBJS,NMAP,404}="true";;
        -c|--config)
            USE_CC="true"
            CUSTOM_CONFIG="$2"
            shift
            ;;
        -o|--out-dir)
            OUT_DIR="$2"
            shift
            ;;
        --verify) CHECK_INSTALL="true" ;;
        -h|--help)
            display_help
            exit 0
            ;;
        -*)
            error "Unknown argument: $1"
        ;;
        *)
        if [[ -n "$REQUIRED_ARG" ]]; then
            error "Only one required argument should be provided."
        fi
        OLD="$1"
        handle_input "$1"
        ;;
    esac
    shift
done
else
    if [ -t 0 ]; then
        display_help
    fi
    handle_input "$(cat)"
fi

# ---= config =---
MODULE_PATH="$SCRIPTPATH/modules"
if [ -n "$USE_CC" ]; then
  [[ -f "$CUSTOM_CONFIG" ]] && RUNNING_CONFIG=$CUSTOM_CONFIG
else
  [[ -f "${SCRIPTPATH}/config.sh" ]] && RUNNING_CONFIG="${SCRIPTPATH}/config.sh"
fi
if [[ -n $RUNNING_CONFIG ]]; then
    . "${RUNNING_CONFIG}"
else
    printf "${EP}no config loaded (config.sh not found in current directory)\n"
    exit 1
fi
if [ -n "$CHECK_INSTALL" ]; then
    CHECK=true
    . "$SCRIPTPATH"/colors.sh
    . $RUNNING_CONFIG
fi

if $SHOW_BANNER; then
VS=${BD}${GN}${VERSION}${RST}
printf "\
      _______________
  $BD==c(___(o(______(_()$RST
          \=\\
           )=\\    ┌─────────────────────────$IN~vide~$RST────┐
          //|\\\\\   │ high-level web server enumeration │
         //|| \\\\\  │ version: $VS                      │
        // ||. \\\\\ └─────────────────@dreizehnutters───┘
      .//  ||   \\\\\ .
      //  .      \\\\\ \n\n"
unset VS
fi

# ---= main =----
if [[ "$IS_DIRECTORY" == "true" ]]; then
    nmap_data="$TMP_DIR/parsed.txt"
    [[ "$(find $REQUIRED_ARG/*.xml -type f 2>/dev/null | wc -l)" == "0" ]] && { printf "${EP} no .xml data found in $REQUIRED_ARG"; exit 1; }
    printf "${OP}grepping open ports per host from $REQUIRED_ARG/*.xml$RST\n"
    $XMLS sel -t -m '//port/state[@state="open"]/parent::port' \
                -v 'ancestor::host/address[not(@addrtype="mac")][1]/@addr' \
                -o '#' -v './@portid' -o '#' -v './service/@conf' -o '#' -v './service/@name' \
                -n "$REQUIRED_ARG"/*.xml 2>/dev/null | sort -u -V > "$nmap_data"
    [[ $? -gt 0 ]] && error "config seems broken"
    sort -t'#' -k3rn $nmap_data | awk -F'#' '!a[$1,$2,$4]++' | sort -V > _tmp
    mv _tmp $nmap_data
    rm -rf $CANDIDATES_FILE
    for target in $(cat $nmap_data); do
        dissect $target
        echo "$IP:$PORT" >> $CANDIDATES_FILE
        unset {IP,PORT,CONF,SVC}
    done
    REQUIRED_ARG=$CANDIDATES_FILE
fi

CANDIDATES_FILE=$REQUIRED_ARG
CANDIDATES=$(wc -l "$CANDIDATES_FILE" 2>/dev/null | cut -d' ' -f1)
[[ "$CANDIDATES" == "0" ]] && { printf "${EP}no open ports found\n"; exit 1; } || printf "${OP}working on $LI$CANDIDATES$RST targets$RST\n"
if [[ -n "$DO_HTTPX" ]] ; then
    . $MODULE_PATH/httpx.sh
    CANDIDATES_FILE="$TARGETS_FILE"
    NUM_WS=$(wc -l "$TARGETS_FILE" | cut -d' ' -f1)
    [[ "$NUM_WS" == "0" ]] && { printf "${EP}no target found\n"; exit 1;  }
fi

for target in `cat $CANDIDATES_FILE 2>/dev/null`; do
    if [[ -n "$DO_CRAWL" ]] ; then
        FILE_NAME=$(echo "$target" | tr ':' '_' | tr '/' '_')
        mkdir -p "$WORK_DIR/crawl"
        $KATANA -u "$target" -o $WORK_DIR/crawl/${FILE_NAME}_all_routes.txt -fr 'mailto:|\/static\/|\?|\*' -ef css,txt,md,png,jpeg,jpg,gif -jc -kf -s breadth-first -iqp -do
        touch $TMP_DIR/"tmp"
        while read -r line; do
            echo "$line" | awk -F'/' 'BEGIN{OFS=FS} {NF=4; print}' | sed '/\.[a-zA-Z]*$/d' >> $TMP_DIR/"tmp"
        done < $WORK_DIR/crawl/${FILE_NAME}_all_routes.txt
        sort -u -V $TMP_DIR/"tmp" > $WORK_DIR/crawl/${FILE_NAME}_d0_routes.txt
        TARGETS_FILE=$WORK_DIR/crawl/${FILE_NAME}_d0_routes.txt
    fi
done

[[ -n $TARGETS_FILE ]] && NUM_WS=$(wc -l "$TARGETS_FILE" | cut -d' ' -f1) || TARGETS_FILE=$CANDIDATES_FILE
exec_modules
NUM_FLAGS="$(set | grep -i "DO_" | tr ' ' '\n' | grep true | wc -l)"
[[ "$NUM_FLAGS" -gt 1 ]] && printf "${MP}enjoy$RST\n" || { printf "${QP}no modules are active\n"; exit 1;  }
cleanUp
hope you find some nice bugs (: