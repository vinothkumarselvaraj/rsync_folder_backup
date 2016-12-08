#!/bin/bash
#Bash script For coping gerrit folder to redmine server
# Author: Vinoth Kumar Selvaraj
# E-Mail: vinothkumar.s@cloudenablers.com


now=$(date +%Y_%m_%d_%H_%M_%S)
mkdir /Gerrit_archive/Gerrit_backup_$now

cp -rp /Gerrit_rsync_bkp/* /Gerrit_archive/Gerrit_backup_$now
tar -cf /Gerrit_archive/Gerrit_backup_$now.tar /Gerrit_archive/Gerrit_backup_$now
rm -rf /Gerrit_archive/Gerrit_backup_$now
ls -t /Gerrit_archive | sed -e '1,7d' | xargs -d '\n' rm

rsync -auHxv  root@192.168.1.135:/home/ubuntu/gerrit/review_site/*  /Gerrit_rsync_bkp/
if [ $? -eq 0 ]
then
        subject="Gerrit_Rsync_backup_completed"
        from="cloudlab@cloudenablers.com"
        recipients="vinothkumar.s@cloudenablers.com,benyraja.j@cloudenablers.com,sushmitha.g@cloudenablers.com"
        mail="Rsync Backup for Gerrit folders is completed at `date` Backup_Hostname:`hostname -f` IP_Detail:`hostname -I` `date`"
        echo $mail | mail -s $subject -a "from:$from"  "$recipients"
fi
