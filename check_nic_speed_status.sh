#!/bin/bash
#Prashanth pullaikodi
#Bash Script to monitor ETH interface
# Reading Only Eth1
NIC=$1
ETHTOOL_REPORT="`sudo /sbin/ethtool $\{NIC:-eth1\} 2>&1`"

LINK_STATUS=`echo "$ETHTOOL_REPORT" | grep Link | cut -d \\  -f 3`

if [ "$LINK_STATUS" = "yes" ]
    then
        LINK_SPEED_RPT=`echo "$ETHTOOL_REPORT" | grep "Speed:"`
        DUPLEX=`echo "$ETHTOOL_REPORT" | grep Duplex | sed 's/^.*Duplex: \\(Full\\|Half\\)/\\1/'`
          if [ -z `echo $LINK_SPEED_RPT | grep -v 100` ]
        then
        # Link is working fine
        echo "LINK OK - carrier ok, with $LINK_SPEED_RPT and $DUPLEX "
        echo $(date ; uname -n) --- Link Ok  $LINK_SPEED_RPT and Mode $DUPLEX on Eth1! >> /var/log/mgwNic_link.log
                exit 0
        else
        # Link works ,But speed is not normal

        echo "LINK WARNING - carrier ok, but link speed is slow - $LINK_SPEED_RPT"
        echo $(date ; uname -n) --- Unexpected link speed $LINK_SPEED_RPT and mode $DUPLEX on Eth1! >> /var/log/mgwNic_link.log
                exit 1
          fi

  elif [ "$LINK_STATUS" = "no" ]
    then
        # Link Down - Critical
        echo "LINK CRITICAL - carrier not detected"
        echo $(date ; uname -n) --- LINK CRITICAL on "Eth1"- carrier not detected ! >> /var/log/mgwNic_link.log
                exit 2

  elif [ -n "`echo $ETHTOOL_REPORT | grep link | grep 'No such device'`" ]
    then
        echo "$ETHTOOL_REPORT" #| grep link
        echo $(date ; uname -n) --- LINK CRITICAL - Interface not found ! >> /var/log/mgwNic_link.log
        # Interface not found
                exit 2
fi
