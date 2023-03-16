# ---= deploy nuclei scans =---
printf "$OP$IN$(basename $BASH_SOURCE) scans:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    l2 "full template scan of $IFACE"
    $NUCLEI -templates "$NUCLEI_TEMPLATES" -u "$TARGET"\
            -ni -irr -stats -timeout 1 -nh -no-stdin -silent\
            -markdown-export "$NUCLEI_DIR"/"$TARGET"
    let COUNTER++
done
# epilog
COUNTER=1
