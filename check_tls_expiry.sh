#!/bin/bash
#Nagios Plugin to monitor TLS certificate Expiry.
#Writen By 'Prashanth Pullaikodi' on Jul 2009 !
#Read TLS expiry Date from Certs folder

Tls_EXP_Date=`openssl x509 -text -noout -in servercert.pem |grep "Not After :" | sed 's/Not After : //g'|sed 's/[ \t]*//'`
ExpDate=$(date +%Y%m%d --date="$Tls_EXP_Date")
CDate=`date +%Y%m%d`
Date1=$CDate
Date2=$ExpDate

#give the dates to awk
out1=`echo $Date1 | awk '{year1=substr($1,1,4);month1=substr($1,5,2);day1=substr($1,7,2);secs1=((year1 - 1970)*365.25+(month1*30.5)+day1)*24*60*60;print secs1;}'`
out2=`echo $Date2 | awk '{year2=substr($1,1,4);month2=substr($1,5,2);day2=substr($1,7,2);secs2=((year2 - 1970)*365.25+(month2*30.5)+day2)*24*60*60;print secs2;}'`
DateW=`expr $out2 - 1728000`
DateC=`expr $out2 - 604800`
if [[ ${DateC} -le  ${out1} ]]
then
    echo CRITICAL:TLS Certificate Will Expire on $Tls_EXP_Date!
    echo $(date ; uname -n) --- CRITICAL: TLS Certificate ! Will Expire on $Tls_EXP_Date! >> /var/log/tls_Cert.log

else if [[ ${DateW} -le ${out1} ]]
then
    echo Warning: TLS Certificate Will Expire on $Tls_EXP_Date!
    echo $(date ; uname -n) --- Warning: TLS Certificate ! Will Expire on $Tls_EXP_Date! >> /var/log/tls_Cert.log

else
     echo TLS certificate is ok
    echo $(date ; uname -n) --- TLS certificate is ok! >> /var/log/tls_Cert.log
    sleep 1

fi
fi
