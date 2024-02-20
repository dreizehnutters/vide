# ---= 40X checks =---
printf "$OP$IN$(basename $BASH_SOURCE) 40X scan:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    mkdir -p "$BYP4_DIR/$PROTO"
    l2 ""

    $BYP4 --all $TARGET | tee "$BYP4_DIR/$PROTO/${FILE_NAME}.txt"
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
