# ---= take screenshots of web server =---
printf "$OP$IN$(basename $BASH_SOURCE) gathering:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    l2 "taking screenshots of"
    parse $TARGET
    mkdir -p "$SCREEN_DIR/$PROTO"
    # cd "$SCREEN_DIR/$PROTO"
    echo "$TARGET/" | $GVV screen --timeout $SS_TIMEOUT -L -R -o "$SCREEN_DIR/$PROTO" &>/dev/null
    let COUNTER++
    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
done
# epilog
for P in http https; do
    find "$SCREEN_DIR/$P/screenshots/" -maxdepth 1 -type f -print0 2>/dev/null | xargs -0 mv -t "$SCREEN_DIR/$P" 2>/dev/null
    rm -rf {"$SCREEN_DIR/$P/screenshots/","$SCREEN_DIR/$P/contents","$SCREEN_DIR/$P/screenshot-summary.txt"}
done
COUNTER=1
