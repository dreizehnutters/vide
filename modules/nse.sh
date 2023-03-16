# adapted from leebaird/discover/main/nse.sh

DELAY=0
OUT_PATH="$NMAP_DIR/$IP_$PORT"

if [[ "$PORT" = 13 ]]; then
     sudo $NMAP $IP -Pn -n --open -p13 --script-timeout 20s \
     --script=daytime -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 21 ]]; then
     sudo $NMAP $IP -Pn -n --open -p21 --script-timeout 20s \
     --script=banner,ftp-anon,ftp-bounce,ftp-proftpd-backdoor,ftp-syst,ftp-vsftpd-backdoor,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 22 ]]; then
     sudo $NMAP $IP -Pn -n --open -p22 --script-timeout 20s \
     --script=rsa-vuln-roca,sshv1,ssh2-enum-algos -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 23 ]]; then
     sudo $NMAP $IP -Pn -n --open -p23 --script-timeout 20s \
     --script=banner,cics-info,cics-enum,cics-user-enum,telnet-encryption,telnet-ntlm-info,tn3270-screen,tso-enum -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 25 || "$PORT" = 465 || "$PORT" = 587 ]]; then
     sudo $NMAP $IP -Pn -n --open -p25,465,587 --script-timeout 20s \
     --script=banner,smtp-commands,smtp-ntlm-info,smtp-open-relay,smtp-strangeport,smtp-enum-users,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg --script-args smtp-enum-users.methods={EXPN,RCPT,VRFY} -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 37 ]]; then
     sudo $NMAP $IP -Pn -n --open -p37 --script-timeout 20s \
     --script=rfc868-time -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 53 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p53 --script-timeout 20s \
     --script=dns-blacklist,dns-cache-snoop,dns-nsec-enum,dns-nsid,dns-random-srcport,dns-random-txid,dns-recursion,dns-service-discovery,dns-update,dns-zeustracker,dns-zone-transfer -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 67 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p67 --script-timeout 20s \
     --script=dhcp-discover -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 70 ]]; then
     sudo $NMAP $IP -Pn -n --open -p70 --script-timeout 20s \
     --script=gopher-ls -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 79 ]]; then
     sudo $NMAP $IP -Pn -n --open -p79 --script-timeout 20s \
     --script=finger -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 102 ]]; then
     sudo $NMAP $IP -Pn -n --open -p102 --script-timeout 20s \
     --script=s7-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 110 ]]; then
     sudo $NMAP $IP -Pn -n --open -p110 --script-timeout 20s \
     --script=banner,pop3-capabilities,pop3-ntlm-info,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 111 ]]; then
     sudo $NMAP $IP -Pn -n --open -p111 --script-timeout 20s \
     --script=nfs-ls,nfs-showmount,nfs-statfs,rpcinfo -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 119  || "$PORT" = 433  || "$PORT" = 563 ]]; then
     sudo $NMAP $IP -Pn -n --open -p119,433,563 --script-timeout 20s \
     --script=nntp-ntlm-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 123 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p123 --script-timeout 20s \
     --script=ntp-info,ntp-monlist -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 137 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p137 --script-timeout 20s \
     --script=nbstat -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 139 ]]; then
     sudo $NMAP $IP -Pn -n --open -p139 --script-timeout 20s \
     --script=smb-vuln-cve-2017-7494,smb-vuln-ms10-061,smb-vuln-ms17-010 -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 143 ]]; then
     sudo $NMAP $IP -Pn -n --open -p143 --script-timeout 20s \
     --script=imap-capabilities,imap-ntlm-info,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 161 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p161 --script-timeout 20s \
     --script=snmp-hh3c-logins,snmp-info,snmp-interfaces,snmp-netstat,snmp-processes,snmp-sysdescr,snmp-win32-services,snmp-win32-shares,snmp-win32-software,snmp-win32-users -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 389 ]]; then
     sudo $NMAP $IP -Pn -n --open -p389 --script-timeout 20s \
     --script=ldap-rootdse,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 445 ]]; then
     sudo $NMAP $IP -Pn -n --open -p445 --script-timeout 20s \
     --script=smb-double-pulsar-backdoor,smb-enum-domains,smb-enum-groups,smb-enum-processes,smb-enum-services,smb-enum-sessions,smb-enum-shares,smb-enum-users,smb-mbenum,smb-os-discovery,smb-protocols,smb-security-mode,smb-server-stats,smb-system-info,smb2-capabilities,smb2-security-mode,smb2-time,msrpc-enum,stuxnet-detect -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 500 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p500 --script-timeout 20s \
     --script=ike-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 502 ]]; then
     # --script-args modbus-discover.aggressive=true 
     sudo $NMAP $IP -Pn -n -sU --open -p500 --script-timeout 20s \
     --script=modbus-discover -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 523 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p523 --script-timeout 20s \
     --script=db2-das-info,db2-discover -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 524 ]]; then
     sudo $NMAP $IP -Pn -n --open -p524 --script-timeout 20s \
     --script=ncp-enum-users,ncp-serverinfo -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 548 ]]; then
     sudo $NMAP $IP -Pn -n --open -p548 --script-timeout 20s \
     --script=afp-ls,afp-path-vuln,afp-serverinfo,afp-showmount -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 554 ]]; then
     sudo $NMAP $IP -Pn -n --open -p554 --script-timeout 20s \
     --script=rtsp-methods -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 623 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p623 --script-timeout 20s \
     --script=ipmi-version,ipmi-cipher-zero -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 631 ]]; then
     sudo $NMAP $IP -Pn -n --open -p631 --script-timeout 20s \
     --script=cups-info,cups-queue-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 636 ]]; then
     sudo $NMAP $IP -Pn -n --open -p636 --script-timeout 20s \
     --script=ldap-rootdse,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 873 ]]; then
     sudo $NMAP $IP -Pn -n --open -p873 --script-timeout 20s \
     --script=rsync-list-modules -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 993 ]]; then
     sudo $NMAP $IP -Pn -n --open -p993 --script-timeout 20s \
     --script=banner,imap-capabilities,imap-ntlm-info,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 995 ]]; then
     sudo $NMAP $IP -Pn -n --open -p995 --script-timeout 20s \
     --script=banner,pop3-capabilities,pop3-ntlm-info,ssl-cert,ssl-cert-intaddr,ssl-ccs-injection,ssl-date,ssl-dh-params,ssl-enum-ciphers,ssl-heartbleed,ssl-known-key,ssl-poodle,sslv2,sslv2-drown,tls-nextprotoneg -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1050 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1050 --script-timeout 20s \
     --script=giop-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1080 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1080 --script-timeout 20s \
     --script=socks-auth-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1099 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1099 --script-timeout 20s \
     --script=rmi-dumpregistry,rmi-vuln-classloader -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1344 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1344 --script-timeout 20s \
     --script=icap-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1352 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1352 --script-timeout 20s \
     --script=domino-enum-users -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1433 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1433 --script-timeout 20s \
     --script=ms-sql-config,ms-sql-dac,ms-sql-dump-hashes,ms-sql-empty-password,ms-sql-info,ms-sql-ntlm-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1434 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p1434 --script-timeout 20s \
     --script=ms-sql-dac -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1521 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1521 --script-timeout 20s \
     --script=oracle-tns-version,oracle-sid-brute --script oracle-enum-users --script-args oracle-enum-users.sid=ORCL,userdb=orausers.txt -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1604 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p1604 --script-timeout 20s \
     --script=citrix-enum-apps,citrix-enum-servers -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1723 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1723 --script-timeout 20s \
     --script=pptp-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1883 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1883 --script-timeout 20s \
     --script=mqtt-subscribe -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1911 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1911 --script-timeout 20s \
     --script=fox-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 1962 ]]; then
     sudo $NMAP $IP -Pn -n --open -p1962 --script-timeout 20s \
     --script=pcworx-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2049 ]]; then
     sudo $NMAP $IP -Pn -n --open -p2049 --script-timeout 20s \
     --script=nfs-ls,nfs-showmount,nfs-statfs -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2202 ]]; then
     sudo $NMAP $IP -Pn -n --open -p2202 --script-timeout 20s \
     --script=acarsd-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2302 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p2302 --script-timeout 20s \
     --script=freelancer-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2375 ]]; then
     sudo $NMAP $IP -Pn -n --open -p2375 --script-timeout 20s \
     --script=docker-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2628 ]]; then
     sudo $NMAP $IP -Pn -n --open -p2628 --script-timeout 20s \
     --script=dict-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 2947 ]]; then
     sudo $NMAP $IP -Pn -n --open -p2947 --script-timeout 20s \
     --script=gpsd-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3031 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3031 --script-timeout 20s \
     --script=eppc-enum-processes -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3260 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3260 --script-timeout 20s \
     --script=iscsi-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3306 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3306 --script-timeout 20s \
     --script=mysql-databases,mysql-empty-password,mysql-info,mysql-users,mysql-variables -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3310 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3310 --script-timeout 20s \
     --script=clamav-exec -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3389 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3389 --script-timeout 20s \
     --script=rdp-vuln-ms12-020,rdp-enum-encryption,rdp-ntlm-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3478 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p3478 --script-timeout 20s \
     --script=stun-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3632 ]]; then
     sudo $NMAP $IP -Pn -n --open -p3632 --script-timeout 20s \
     --script=distcc-cve2004-2687 --script-args="distcc-exec.cmd='id'" -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 3671 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p3671 --script-timeout 20s \
     --script=knx-gateway-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 4369 ]]; then
     sudo $NMAP $IP -Pn -n --open -p4369 --script-timeout 20s \
     --script=epmd-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5019 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5019 --script-timeout 20s \
     --script=versant-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5060 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5060 --script-timeout 20s \
     --script=sip-enum-users,sip-methods -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5353 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p5353 --script-timeout 20s \
     --script=dns-service-discovery -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5666 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5666 --script-timeout 20s \
     --script=nrpe-enum -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5672 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5672 --script-timeout 20s \
     --script=amqp-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5683 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p5683 --script-timeout 20s \
     --script=coap-resources -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5850 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5850 --script-timeout 20s \
     --script=openlookup-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5900 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5900 --script-timeout 20s \
     --script=realvnc-auth-bypass,vnc-info,vnc-title -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 5984 ]]; then
     sudo $NMAP $IP -Pn -n --open -p5984 --script-timeout 20s \
     --script=couchdb-databases,couchdb-stats -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 6000  || "$PORT" = 6001  || "$PORT" = 6002  || "$PORT" = 6003  || "$PORT" = 6004  || "$PORT" = 6005 ]]; then
     sudo $NMAP $IP -Pn -n --open -p6000-6005 --script-timeout 20s \
     --script=x11-access -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 6379 ]]; then
     sudo $NMAP $IP -Pn -n --open -p6379 --script-timeout 20s \
     --script=redis-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 6481 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p6481 --script-timeout 20s \
     --script=servicetags -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 6666 ]]; then
     sudo $NMAP $IP -Pn -n --open -p6666 --script-timeout 20s \
     --script=voldemort-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 7210 ]]; then
     sudo $NMAP $IP -Pn -n --open -p7210 --script-timeout 20s \
     --script=maxdb-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 7634 ]]; then
     sudo $NMAP $IP -Pn -n --open -p7634 --script-timeout 20s \
     --script=hddtemp-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8000 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8000 --script-timeout 20s \
     --script=qconn-exec --script-args=qconn-exec.timeout=60,qconn-exec.bytes=1024,qconn-exec.cmd="uname -a" -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8009 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8009 --script-timeout 20s \
     --script=ajp-methods,ajp-request -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8081 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8081 --script-timeout 20s \
     --script=mcafee-epo-agent -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8091 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8091 --script-timeout 20s \
     --script=membase-http-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8140 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8140 --script-timeout 20s \
     --script=puppet-naivesigning -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 8332 || "$PORT" = 8333 ]]; then
     sudo $NMAP $IP -Pn -n --open -p8332,8333 --script-timeout 20s \
     --script=bitcoin-getaddr,bitcoin-info,bitcoinrpc-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 9100 ]]; then
     sudo $NMAP $IP -Pn -n --open -p9100 --script-timeout 20s \
     --script=lexmark-config -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 9160 ]]; then
     sudo $NMAP $IP -Pn -n --open -p9160 --script-timeout 20s \
     --script=cassandra-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 9600 ]]; then
     sudo $NMAP $IP -Pn -n --open -p9600 --script-timeout 20s \
     --script=omron-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 9999 ]]; then
     sudo $NMAP $IP -Pn -n --open -p9999 --script-timeout 20s \
     --script=jdwp-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 10000 ]]; then
     sudo $NMAP $IP -Pn -n --open -p10000 --script-timeout 20s \
     --script=ndmp-fs-info,ndmp-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi


if [[ "$PORT" = 10809 ]]; then
     sudo $NMAP $IP -Pn -n --open -p10809 --script-timeout 20s \
     --script=nbd-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi


if [[ "$PORT" = 11211 ]]; then
     sudo $NMAP $IP -Pn -n --open -p11211 --script-timeout 20s \
     --script=memcached-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 12000 ]]; then
     sudo $NMAP $IP -Pn -n --open -p12000 --script-timeout 20s \
     --script=cccam-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 12345 ]]; then
     sudo $NMAP $IP -Pn -n --open -p12345 --script-timeout 20s \
     --script=netbus-auth-bypass,netbus-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 17185 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p17185 --script-timeout 20s \
     --script=wdb-version -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 19150 ]]; then
     sudo $NMAP $IP -Pn -n --open -p19150 --script-timeout 20s \
     --script=gkrellm-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 27017 ]]; then
     sudo $NMAP $IP -Pn -n --open -p27017 --script-timeout 20s \
     --script=mongodb-databases,mongodb-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 31337 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p31337 --script-timeout 20s \
     --script=backorifice-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 35871 ]]; then
     sudo $NMAP $IP -Pn -n --open -p35871 --script-timeout 20s \
     --script=flume-master-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 44818 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p44818 --script-timeout 20s \
     --script=enip-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 47808 ]]; then
     sudo $NMAP $IP -Pn -n -sU --open -p47808 --script-timeout 20s \
     --script=bacnet-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 49152 ]]; then
     sudo $NMAP $IP -Pn -n --open -p49152 --script-timeout 20s \
     --script=supermicro-ipmi-conf -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 50000 ]]; then
     sudo $NMAP $IP -Pn -n --open -p50000 --script-timeout 20s \
     --script=drda-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 50030  || "$PORT" = 50060  || "$PORT" = 50070  || "$PORT" = 50075  || "$PORT" = 50090 ]]; then
     sudo $NMAP $IP -Pn -n --open -p50030,50060,50070,50075,50090 --script-timeout 20s \
     --script=hadoop-datanode-info,hadoop-jobtracker-info,hadoop-namenode-info,hadoop-secondary-namenode-info,hadoop-tasktracker-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

if [[ "$PORT" = 60010 || "$PORT" = 60030 ]]; then
     sudo $NMAP $IP -Pn -n --open -p60010,60030 --script-timeout 20s \
     --script=hbase-master-info,hbase-region-info -g $PORT \
     --scan-delay $DELAY -oA $OUT_PATH
fi

echo -e "\t${QP}no rule for port: $BD$PORT$RST"