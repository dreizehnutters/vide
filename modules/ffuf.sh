# ---= directory brute force =---
printf "$OP$IN$(basename $BASH_SOURCE) dir brute force:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 
    $FFUF -X METHOD -u "$PROTO://$IP:$PORT/FUZZ" -w "$METHODS":METHOD,"$WORDLIST":FUZZ -ac -c -e .php -t "$THREADS" -of html -o "$FFUF_DIR/$FILE_NAME.html"
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
