# ---= webanalysze =---
printf "$OP$IN$(basename $BASH_SOURCE):$RST\n"
l2 "webanalyze scans"
$WA -hosts "$TARGETS_FILE" -crawl $CRAWL_DEPTH -redirect -silent -apps $WA_JSON -output csv | tee "$WA_DIR/overview.csv"
#epilog
NEW_TARGETS=$(cat "$WA_DIR/overview.csv" | tail -n+2 |cut -d ',' -f1 | sort -u | tr ' ' '\n')
    echo "----"
    cat $TARGETS_FILE
echo $NEW_TARGETS >> $TARGETS_FILE
sed '/^[[:space:]]*$/d' $TARGETS_FILE
sort -u -o $TARGETS_FILE $TARGETS_FILE