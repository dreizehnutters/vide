# ---= directory brute force =---
printf "$OP$IN$(basename $BASH_SOURCE) dir brute force:$RST\n"
echo $TARGETS_FILE
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 ""
    $FFUF -u "$PROTO://$IP:$PORT/FUZZ" -w "$WORDLIST" -mc all -ac -c -t "$THREADS" -of html -o "$FFUF_DIR/$FILE_NAME.html"
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
