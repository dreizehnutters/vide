#!/usr/bin/env bash

# TODO
# add 404bypass

SCRIPTPATH="$(dirname $(realpath "$0"))"
[[ -f "$SCRIPTPATH/colors.sh" ]] && . "$SCRIPTPATH/colors.sh" || { printf "'$SCRIPTPATH/colors.sh' could not be located\n"; exit 1; }

# ---= load functions =---
source $SCRIPTPATH/utils.sh

# --= argument parser =--
OUT_DIR="$PWD/vide_runs"
DO_HTTPX="true"
DO_CRAWL="true"
STDIN_FLAG="true"
if [[ $# -gt 0 ]]; then
while [[ $# -gt 0 ]]; do
    case "$1" in
        -sp) unset DO_HTTPX ;;
        -sc) unset DO_CRAWL ;;
        -es) DO_SCREENSHOTS="true" ;;
        -ew) DO_WHATWEB="true" ;;
        -ea) DO_WA="true" ;;
        -eu) DO_NUCLEI="true" ;;
        -ei) DO_NIKTO="true" ;;
        -ef) DO_FFUF="true" ;;
        -ev) DO_VIRTUAL="true" ;;
        -ej) DO_SUBJS="true" ;;
        -eb) DO_404="true" ;;
        -en) DO_NMAP="true";unset {DO_CRAWL,DO_HTTPX} ;;
        --all) declare DO_{SCREENSHOTS,WHATWEB,WA,NUCLEI,NIKTO,FFUF,SUBJS,NMAP,404}="true";;
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
        display_help; exit 1
    fi
    handle_input "$(cat)"
fi

# ---= load config =---
MODULE_PATH="$SCRIPTPATH/modules"
if [ -n "$USE_CC" ]; then
  [[ -f "$CUSTOM_CONFIG" ]] && RUNNING_CONFIG=$CUSTOM_CONFIG
else
  [[ -f "${SCRIPTPATH}/config.sh" ]] && RUNNING_CONFIG="${SCRIPTPATH}/config.sh"
fi
if [[ -n $RUNNING_CONFIG ]]; then
    . "${RUNNING_CONFIG}"
else
    printf "${EP}no config loaded ('config.sh' not found in '$(echo $SCRIPTPATH)/')\n"
    exit 1
fi
if [ -n "$CHECK_INSTALL" ]; then
    CHECK=true
    . "$SCRIPTPATH"/colors.sh
    . $RUNNING_CONFIG
fi

# ---= main =----
if $SHOW_BANNER; then
    print_banner
fi
if [[ "$IS_DIRECTORY" == "true" ]]; then
    nmap_data="$TMP_DIR/parsed.txt"
    [[ "$(find $REQUIRED_ARG/*.xml -type f 2>/dev/null | wc -l)" == "0" ]] && { printf "${EP} no '.xml' data found in '$REQUIRED_ARG'"; exit 1; }
    printf "${OP}grepping open ports per host from '$REQUIRED_ARG/*.xml'$RST\n"
    $XMLS sel -t -m '//port/state[@state="open"]/parent::port' \
                -v 'ancestor::host/hostnames/hostname[@type="PTR"]/@name | ancestor::host/address[@addrtype="ipv4"]/@addr' \
                -o '#' -v './@portid' -o '#' -v './service/@conf' -o '#' -v './service/@name' \
                -n "$REQUIRED_ARG"/*.xml | grep '#' | sort -u -V > "$nmap_data"
    [[ $? -gt 0 ]] && error "config seems broken"
    sort -t'#' -k3rn $nmap_data | awk -F'#' '!a[$1,$2,$4]++' | sort -V > _tmp
    mv _tmp $nmap_data
    rm -rf $CANDIDATES_FILE
    for target in $(cat $nmap_data); do
        dissect $target
        echo "$IP:$PORT" >> $CANDIDATES_FILE
        unset {IP,PORT,CONF,SVC}
    done
    sort -u -o $CANDIDATES_FILE $CANDIDATES_FILE
    REQUIRED_ARG=$CANDIDATES_FILE
fi

CANDIDATES_FILE=$REQUIRED_ARG
CANDIDATES=$(wc -l "$CANDIDATES_FILE" 2>/dev/null | cut -d' ' -f1)
[[ "$CANDIDATES" == "0" ]] && { printf "${EP}no targets found\n"; exit 1; }
if [[ -n "$DO_HTTPX" ]] ; then
    . $MODULE_PATH/httpx.sh
    CANDIDATES_FILE="$TARGETS_FILE"
    NUM_WS=$(wc -l "$TARGETS_FILE" | cut -d' ' -f1)
    [[ "$NUM_WS" == "0" ]] && { printf "${EP}no target found\n"; exit 1; }
fi

for target in `cat $CANDIDATES_FILE 2>/dev/null`; do
    rm -f $TMP_DIR/"tmp" 2>/dev/null
    if [[ -n "$DO_CRAWL" ]] ; then
        FILE_NAME=$(echo "$target" | tr ':' '_' | tr '/' '_')
        mkdir -p "$WORK_DIR/crawl"
        $KATANA -u "$target" -o $WORK_DIR/crawl/${FILE_NAME}_all_routes.txt -fr 'mailto:|\/static\/|\?|\*' -ef css,txt,md,png,jpeg,jpg,gif -jc -kf -s breadth-first -iqp -do
        touch $TMP_DIR/"tmp"
        while read -r line; do
            echo "$line" | awk -F'/' 'BEGIN{OFS=FS} {NF=4; print}' | sed '/\.[a-zA-Z]*$/d' >> $TMP_DIR/"tmp"
        done < $WORK_DIR/crawl/${FILE_NAME}_all_routes.txt
        sort -u -V $TMP_DIR/"tmp" > $WORK_DIR/crawl/${FILE_NAME}_d0_routes.txt
        TARGETS_FILE="$WORK_DIR/crawl/${FILE_NAME}_d0_routes.txt"
    else
        echo $target >> $TARGETS_FILE
    fi
done

if ! [[ -f "$TARGETS_FILE" ]]; then
    printf "${EP}sanity check failed\n"; exit 1;
fi

if [[ -n "$DO_CRAWL" ]]; then
    touch "$WORK_DIR/crawl/merged.txt"
    for file in "$WORK_DIR/crawl/"*_d0_routes.txt; do
        cat "$file" >> "$WORK_DIR/crawl/merged.txt"
    done
    TARGETS_FILE="$WORK_DIR/crawl/merged.txt"
fi

run_modules
cleanUp
exit 0
hope you find some nice bugs (:
