# ---= take screenshots of web server =---
printf "$OP$IN$(basename $BASH_SOURCE) gathering:$RST\n"
$HTTPX -l $TARGETS_FILE -ss &>/dev/null
log $cmd
$cmd
unset cmd
let COUNTER++
unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
# epilog
mv output "${WORK_DIR}/screenshots"
COUNTER=1
