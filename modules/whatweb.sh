# ---= scan server tech/headers =---
printf "$OP$IN$(basename $BASH_SOURCE) tech scans:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 "WhatWeb scan of"
    mkdir -p "$WW_DIR/$FILE_NAME"
    $WW --aggression=$WHATWEB_LEVEL "$TARGET" \
        -U="$SCAN_HEADER" --header="$CUSTOM_HEADER" \
        --log-verbose="$WW_DIR/$FILE_NAME/deep.log" \
        --log-brief="$WW_DIR/$FILE_NAME/brief.log" \
        --max-threads="$THREADS"
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
for x in brief deep; do find "$WW_DIR" -type f -name "${x}.log" -exec cat {} + >>"$WW_DIR/${x}_all.log"; done
COUNTER=1
