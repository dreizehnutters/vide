# ---= directory brute force =---
printf "$OP$IN$(basename $BASH_SOURCE) dir brute force:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2
    [[ "$PORT" -gt 0 ]] && scope="$IP:$PORT" || scope="$TARGET"
    echo ""| $FFUF -X METHOD -u "$PROTO://$scope/FUZZ" -w "$METHODS":METHOD,"$WORDLIST":FUZZ -ac -c -e $EXTENSIONS -t "$THREADS" -of $FFUF_OUTFORMAT -o "$FFUF_DIR/$FILE_NAME.$FFUF_OUTFORMAT"
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
