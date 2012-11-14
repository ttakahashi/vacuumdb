#!/bin/sh
data=`date +%Y%m%d`
LOGDIR=/var/log/
TMPFILE=/var/log/vacuumdb_tmp.log
ERRORFILE=/var/log/vacuumdb_error_${data}.log
VACUUMDB=/usr/local/pgsql/bin/vacuumdb
USER=postgres
MAILTO=
MAILFROM=
${VACUUMDB} --username=${USER} --analyze --all --quiet 2>> ${ERRORFILE}
if [ -s ${ERRORFILE} ]; then
  {
    echo "From: PostgreSQL Server `hostname` <${MAILFROM}>"
    echo "To: <${MAILTO}>"
    echo "Subject: FAILED vacuumdb"
    echo ""
    echo "Something is wrong while executing vacuumdb --analyze"
    echo ""
    echo "DATE:"
    /bin/date +"%Y %D %T"
    echo "" >> ${TMPFILE}
    echo "HOSTNAME:"
    /bin/hostname
    echo ""
    echo "DATAIL:"
    /bin/cat ${ERRORFILE}
  } > ${TMPFILE}
  /bin/cat ${TMPFILE} | /usr/sbin/sendmail -i ${MAILTO}
  /bin/rm -f ${TMPFILE}
else
  /bin/rm -f ${ERRORFILE}
fi
#一ヶ月前のエラーログがあればtgzでまとめて圧縮して元ファイルは削除
/bin/tar -czf ${LOGDIR}vacuumdb_error_`/bin/date +%Y%m --date "1 month ago"`.tgz ${LOGDIR}vacuumdb_error_`/bin/date +%Y%m --date "1 month ago"`*.log 2> /dev/null
/bin/rm -f ${LOGDIR}vacuumdb_error_`/bin/date +%Y%m --date "1 month ago"`*.log 2> /dev/null
