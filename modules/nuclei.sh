# ---= deploy nuclei scans =---
printf "$OP$IN$(basename $BASH_SOURCE) scans:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    l2 "full template scan of${IFACE}"
    cmd="$NUCLEI -templates "$NUCLEI_TEMPLATES" -u "$TARGET"\
            -ni -irr -stats -timeout 1 -nh -no-stdin"
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
done
# epilog
COUNTER=1
