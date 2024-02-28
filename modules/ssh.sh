# ---= template =---
printf "$OP$IN$(basename $BASH_SOURCE):$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 "ssh scan"
    # vvvvvv
    $SSHAUDIT -v -p $PORT $IP | tee "$SSHAUDIT_DIR/${IP}_${PORT}.txt"
    $SSHAUDIT -jj -p $PORT $IP >"$SSHAUDIT_DIR/${IP}_${PORT}.json"
    # ^^^^^^
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
