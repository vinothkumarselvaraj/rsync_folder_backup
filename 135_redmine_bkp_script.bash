#!/bin/bash
#Bash script For coping redmine folder to gerrit server
# Author: Vinoth Kumar Selvaraj
# E-Mail: vinothkumar.s@cloudenablers.com

now=$(date +%Y_%m_%d_%H_%M_%S)
mkdir /Redmine_archive/Redmine_backup_$now

cp -rp /redmine_rsync_bkp/* /Redmine_archive/Redmine_backup_$now
tar -cf /Redmine_archive/Redmine_backup_$now.tar /Redmine_archive/Redmine_backup_$now
rm -rf /Redmine_archive/Redmine_backup_$now
ls -t /Redmine_archive | sed -e '1,7d' | xargs -d '\n' rm

rsync -auHxv --log-file=/var/log/rsync/redmine_rsync_bkp.log root@192.168.1.120:/opt/redmine-3.1.1-0/apps/redmine/htdocs/files/*  /redmine_rsync_bkp/
if [ $? -eq 0 ]
then
        subject="Redmine_Rsync_backup_completed"
        from="cloudlab@cloudenablers.com"
        recipients="vinothkumar.s@cloudenablers.com,benyraja.j@cloudenablers.com,kalaivani.v@cloudenablers.com"
        truncate -s0 /var/log/rsync/redmine_rsync_bkp_report.txt
        echo -e "Rsync Backup for Redmine folders is completed at `date`\n\nBackup_Hostname:`hostname -f`\nIP_Detail:`hostname -I` \n\n\nNew DATA Pulled:\n" > /var/log/rsync/redmine_rsync_bkp_report.txt
        tail -n2 /var/log/rsync/redmine_rsync_bkp.log >> /var/log/rsync/redmine_rsync_bkp_report.txt
        mail -s $subject -a "from:$from"  "$recipients" < /var/log/rsync/redmine_rsync_bkp_report.txt
else
        subject="IMPORTANT:Redmine_Rsync_backup_FAILED"
        from="cloudlab@cloudenablers.com"
        recipients="vinothkumar.s@cloudenablers.com,benyraja.j@cloudenablers.com,kalaivani.v@cloudenablers.com"
        truncate -s0 /var/log/rsync/redmine_rsync_bkp_report.txt
        tail -n10 /var/log/rsync/redmine_rsync_bkp.log >> /var/log/rsync/redmine_rsync_bkp_report.txt
        mail -s $subject -a "from:$from"  "$recipients" < /var/log/rsync/redmine_rsync_bkp.log

fi
