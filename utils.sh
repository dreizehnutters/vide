trap ctrl_c INT
function ctrl_c() {
    printf "${EP}skipping current module\n"
}

function log() {
    echo -e "[$(date +%d.%m:%H%M)]\t$@" >>"$CMD_LOG"
}

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
    -ev     Enable ${UL}virtual host${RST} header fuzzing
    -ej     Enable ${UL}js${RST} crawl
    -eb     Enable ${UL}bypass${RST} scans
    -el     Enable ${UL}testssl.sh${RST} scans
    -eh     Enable ${UL}ssh-audit${RST} scans
    --all   Enable ${UL}all${RST} modules

${IN}Misc:${RST}
    -h|--help                  Show this message
    -c|--config  <config.sh>   Config file to pass (default: custom.sh)
    -o|--out-dir <path>        Out-dir to work in (default: $PWD)
    --verify                   Check configuration file (default: config.sh)

${IN}Example:${RST}
    ${IL}# skip crawl, skip probing, do virtual host header scan${RST}
    vide.sh scope.txt -sp -sc -ev
    ${IL}# skip crawl, do nuclei, do whatweb on nmap output directory${RST}
    vide.sh nmap -sc -en -ew
    ${IL}# with config skip probing, do screenshot on stdin (default to HTTP)${RST}
    echo example.com | vide.sh -sp -es --config custom.sh
    ${IL}# ssl scan on target${RST}
    vide.sh '10.0.13.37:8443' -el
    ${IL}# verify current config.sh${RST}
    vide.sh --verify\n"
}

function cleanUp() {
    rm -rf $TMP_DIR
    rm -rf /tmp/katana*
    rm -rf /tmp/httpx*
    rm -rf /tmp/nuclei*
    rm -rf $STDIN_HANDLE
}

function error() {
    printf "${EP}Error: $1\n\n"
    display_help
    exit 1
}

function print_banner() {
    VS=${BD}${GN}${VERSION}${RST}
    printf "\
        _______________
    $BD==c(___(o(______(_()$RST
              \=\\
               )=\\    ┌───────────────────────────$IN~vide~$RST──┐
              //|\\\\\   │ attack surface enumeration        │
             //|| \\\\\  │ version: $VS                      │
            // ||. \\\\\ └──────────────────$IL@dreizehnutters$RST──┘
          .//  ||   \\\\\ .
          //  .      \\\\\ \n\n"
    unset VS
}

function handle_input() {
    unset STDIN_FLAG
    if [[ -f "$1" ]]; then
        REQUIRED_ARG="$1"
        FILE_EXTENSION="${REQUIRED_ARG##*.}"
    elif [[ -d "$1" ]]; then
        REQUIRED_ARG="$1"
        IS_DIRECTORY="true"
    elif [[ -n "$1" ]]; then
        STDIN_HANDLE="./_vide_input.txt"
        echo "$1" >$STDIN_HANDLE
        REQUIRED_ARG=$STDIN_HANDLE
    else
        REQUIRED_ARG=$STDIN_HANDLE
        while IFS= read -r line; do
            echo "$line" >>"$REQUIRED_ARG"
        done
    fi
}

function parse() {
    unset DO_SSL
    PROTO="http"
    PORT=0
    IP=$(echo "$1" | cut -d '/' -f3- | cut -d ':' -f1)
    if [[ "$1" == *':'* ]]; then
        if [[ "$1" == *'://'* ]]; then
            PROTO=$(echo "$1" | cut -d ':' -f1)
            TMP=$(echo "$1" | cut -d':' -f3-)
            PORT="${TMP:-80}"
        else
            printf "${QP}no protocol handler found defaulting to $PROTO\n"
            PORT=$(echo "$1" | cut -d ':' -f2)
        fi
        [[ $PROTO == "https"* ]] && DO_SSL="true"
    else
        printf "${QP}no protocol handler found defaulting to $PROTO\n"
    fi
    FILE_NAME=$PROTO"_"$IP"_"$PORT
    REPLY=($PROTO $IP $PORT $FILE_NAME $DO_SSL)
}

function dissect() {
    if [[ "$1" == *'#'* ]]; then
        DELIM='#'
        IP=$(echo $1 | cut -d $DELIM -f1)
        PORT=$(echo $1 | cut -d $DELIM -f2)
        CONF=$(echo $1 | cut -d $DELIM -f3)
        SVC=$(echo $1 | cut -d $DELIM -f4-)
        [ -z "$CONF" ] && CONF=0
        [ -z "$SVC" ] && SVC="?"
        REPLY=($IP $PORT $CONF $SVC)
    else
        CONF=10
        parse $1
        SVC="???"
        REPLY=($IP $PORT $CONF $SVC)
    fi
}

function l2() {
    printf "\t$YL[$COUNTER/$NUM_WS] $RST$BD$1$RST $TARGET\n"
}

function exec_modules() {
    [[ $NUM_WS -eq 0 ]] && {
        printf "${EP}no servers to work on\n"
        exit 0
    }
    printf "${OP}working on $LI$NUM_WS$RST targets$RST\n"
    NUM_FLAGS="$(set | grep -i "DO_" | tr ' ' '\n' | grep true | wc -l)"
    [[ -n "$DO_SCREENSHOTS" ]] && . $MODULE_PATH/screenshot.sh
    [[ -n "$DO_WHATWEB" ]] && . $MODULE_PATH/whatweb.sh
    [[ -n "$DO_WA" ]] && . $MODULE_PATH/webanalyze.sh
    [[ -n "$DO_NUCLEI" ]] && . $MODULE_PATH/nuclei.sh
    [[ -n "$DO_NIKTO" ]] && . $MODULE_PATH/nikto.sh
    [[ -n "$DO_FFUF" ]] && . $MODULE_PATH/ffuf.sh
    [[ -n "$DO_VIRTUAL" ]] && . $MODULE_PATH/virtual.sh
    [[ -n "$DO_SUBJS" ]] && . $MODULE_PATH/subjs.sh
    [[ -n "$DO_404" ]] && . $MODULE_PATH/bypass40X.sh
    [[ -n "$DO_NMAP" ]] && . $MODULE_PATH/nmap.sh
    [[ -n "$DO_TESTSSL" ]] && . $MODULE_PATH/ssl.sh
    [[ -n "$DO_SSHAUDIT" ]] && . $MODULE_PATH/ssh.sh
    printf "${MP}enjoy$RST\n"
}

function run_modules() {
    sort -u -o $TARGETS_FILE{,}
    [[ -n $TARGETS_FILE ]] && NUM_WS=$(wc -l "$TARGETS_FILE" | cut -d' ' -f1) || {
        TARGETS_FILE=$CANDIDATES_FILE
        NUM_WS=$(wc -l "$TARGETS_FILE" | cut -d' ' -f1)
    }
    exec_modules
}
