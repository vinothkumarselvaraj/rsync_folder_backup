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

rsync -auHxv --log-file=/var/log/rsync/gerrit_rsync_bkp.log  root@192.168.1.135:/home/ubuntu/gerrit/review_site/*  /Gerrit_rsync_bkp/
if [ $? -eq 0 ]
then
        subject="Gerrit_Rsync_backup_completed"
        from="cloudlab@cloudenablers.com"
        recipients="vinothkumar.s@cloudenablers.com,benyraja.j@cloudenablers.com,sushmitha.g@cloudenablers.com"
        truncate -s0 /var/log/rsync/gerrit_rsync_bkp_report.txt
        echo -e "Rsync Backup for Gerrit folders is completed at `date`\n\nBackup_Hostname:`hostname -f`\nIP_Detail:`hostname -I` \n\n\nNew DATA Pulled:\n" > /var/log/rsync/gerrit_rsync_bkp_report.txt
        tail -n2 /var/log/rsync/gerrit_rsync_bkp.log >> /var/log/rsync/gerrit_rsync_bkp_report.txt
        mail -s $subject -a "from:$from"  "$recipients" < /var/log/rsync/gerrit_rsync_bkp_report.txt
else
        subject="IMPORTANT:Gerrit_Rsync_backup_FAILED"
        from="cloudlab@cloudenablers.com"
        recipients="vinothkumar.s@cloudenablers.com,benyraja.j@cloudenablers.com,kalaivani.v@cloudenablers.com"
        truncate -s0 /var/log/rsync/gerrit_rsync_bkp_report.txt
        tail -n10 /var/log/rsync/gerrit_rsync_bkp.log >> /var/log/rsync/gerrit_rsync_bkp_report.txt
        mail -s $subject -a "from:$from"  "$recipients" < /var/log/rsync/gerrit_rsync_bkp_report.txt
fi
