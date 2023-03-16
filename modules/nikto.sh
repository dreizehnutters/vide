# ---= deploy nikto scans =---
printf "$OP$IN$(basename $BASH_SOURCE) scans:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    l2 "nikto scan"
    parse $TARGET
    if [ -n "$DO_SSL" ]; then
        SSL_FLAG="-ssl"
    else
        SSL_FLAG="-nossl"
    echo "n" | $NIKTO -host "$TARGET" $NIKTO_TUNING -no404 "$SSL_FLAG" -Format htm -output "$NIKTO_DIR/$FILE_NAME.html"
    fi
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
