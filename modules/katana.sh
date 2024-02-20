# ---= katana scans =---
printf "$OP$IN$(basename $BASH_SOURCE) scan:$RST\n"
for TARGET in $(grep -v "#" "$TARGETS_FILE" | sort -V); do
    parse $TARGET
    l2 "js crawl of:"

    $KATANA -u "$TARGET" -hl -nos -jc -silent -aff -kf all,robotstxt,sitemapxml -p 50 \
         | $SUBJS \
         | sort -u > "$KATANA_DIR/$FILE_NAME.txt"

    unset {PROTO,IP,PORT,FILE_NAME,DO_SSL}
    log $cmd
    $cmd
    unset cmd
    let COUNTER++
done
# epilog
COUNTER=1
