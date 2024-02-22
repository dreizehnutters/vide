# ---= directory brute force =---
printf "$OP$IN$(basename $BASH_SOURCE) host header brute force:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2
    [[ "$PORT" -gt 0 ]] && scope="$IP:$PORT" || scope="$TARGET"
    echo "" | $FFUF -u "$PROTO://$scope" -H "Host: FUZZ.$scope" -w "$VWORDLIST" -mc all -c -t "$THREADS" -of $FFUF_OUTFORMAT -o "$FFUF_DIR/$FILE_NAME.$FFUF_VOUTFORMAT"
    log $cmd
    $cmd
    unset cmd
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
