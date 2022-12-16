# etcd automated backup 

This is a cronjob that runs nightly on the master nodes via a debug pod, it creates a backup   
of etcd locally on the masters in `/home/core/assets/backup/` via the script that ships with etcd/openshift:  
`/usr/local/bin/cluster-backup.sh`.  

[Based on](https://docs.openshift.com/container-platform/4.9/backup_and_restore/control_plane_backup_and_restore/backing-up-etcd.html)   
[Automation inspiration](https://github.com/lgchiaretto/openshift4-backup-automation)    
[Restore Procedure](https://docs.openshift.com/container-platform/4.9/backup_and_restore/control_plane_backup_and_restore/disaster_recovery/scenario-2-restoring-cluster-state.html)  

