# ---= webanalysze =---
printf "$OP$IN$(basename $BASH_SOURCE):$RST\n"
l2 "webanalyze scans"
$WA -hosts "$TARGETS_FILE" -crawl $CRAWL_DEPTH -redirect -silent -apps $WA_JSON -output csv | tee "$WA_DIR/overview.csv"
