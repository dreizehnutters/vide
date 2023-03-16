# ---= template =---
printf "$OP$IN$(basename $BASH_SOURCE) t e m p l a t e:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET    
    l2 "t e m p l a t e"
    # vvvvvv
    # do stuff here
    # ^^^^^^
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
COUNTER=1
