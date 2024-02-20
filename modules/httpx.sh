# ---= scan for web servers among all found ips/ports =---
$HTTPX -l "$CANDIDATES_FILE" -nf -H "$SCAN_HEADER" \
                            -x ALL -ldp -nfs -server -probe -title -sc -cl -websocket \
                            -stats -threads "$THREADS" -rate-limit "$RATE_LIMIT" -o "$HTTPX_LOG"
log $cmd
$cmd
unset cmd
grep -v "31mFAILED.*0m" "$HTTPX_LOG" | grep . | cut -d' ' -f1 | sort -u -V > "$WS_FILE"

grep "https" $WS_FILE > $HTTPS_SERVERS
grep -v "https" $WS_FILE  > $HTTP_SERVERS

TARGETS_FILE=$WS_FILE

$HTTPX -l $TARGETS_FILE -bp 10

if [[ -n $HTTP_ONLY ]]; then
    TARGETS_FILE=$HTTP_SERVERS
fi

if [[ -n $HTTPS_ONLY ]]; then
    TARGETS_FILE=$HTTPS_SERVERS
fi
