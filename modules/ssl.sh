# ---= template =---
printf "$OP$IN$(basename $BASH_SOURCE):$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 "testssl.sh scan"
    mkdir -p $TESTSSL_TMP
    $TESTSSL $TESTSSL_CONFIG $IP:$PORT
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
    if [ "$(grep -c "Scan interrupted" "$TESTSSL_TMP"/*".json")" -eq 1 ]; then
        echo "$IP:$PORT" >>$TESTSSL_ERRORS
    elif [ "null" != "$(cat "$TESTSSL_TMP"/*".json" | jq -r '.scanResult[].severity')" ]; then
        echo "$IP:$PORT" >>$TESTSSL_ERRORS
    fi
    find $TESTSSL_TMP -type f -exec cp '{}' $TESTSSL_DIR \;
    rm -rf $TESTSSL_TMP
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
if [ $(cat $TESTSSL_ERRORS | wc -l) -ne 0 ]; then
    printf "${EP}some errors while scanning targets were encountered ($TESTSSL_ERRORS).\n"
    cat $TESTSSL_ERRORS
fi
