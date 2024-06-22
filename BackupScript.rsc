{
:log info "Starting Backup Script...";


:log info "Creating local variable";

:local emailaddress emailaddress@exemple.ru;
:local mailpass exemple_mailpass;
:local mailserver smtp.exemple_mailserver.ru;
:local mailport exemple_mailport;

:local ftpaddress exemple_ftpaddress;
:local ftpuser exemple_ftpuser;
:local ftppassword exemple_ftppassword;
:local ftpdir "/exemple_ftpdir/";

:local sysname [/system identity get name];
:local sysver [/system package get system version];
:local sn [/system routerboard get serial-number];

:local backupfile ("$sysname-$sysver-$sn-backup-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . ".backup");
:local exportfile ("$sysname-$sysver-$sn-backup-" . [:pick [/system clock get date] 7 11] . [:pick [/system clock get date] 0 3] . [:pick [/system clock get date] 4 6] . ".rsc");

:delay 2;


:log info "Flushing DNS cache...";
/ip dns cache flush;
:delay 2;


:log info "Deleting last Backups...";
:foreach i in=[/file find] do={:if ([:typeof [:find [/file get $i name] "$sysname-$sysver-$sn-backup-"]]!="nil") do={/file remove $i}};
:delay 2;


:log info "Creating new Full Backup file $backupfile";
/system backup save name=$backupfile;
:delay 5;


:log info "Creating new Script Backup file $exportfile";
/export verbose file=$exportfile;
:delay 5;


:log info "Sending Backup files via $emailaddress...";
:foreach i in={"$backupfile"; "$exportfile"} do={
/tool e-mail send from=$emailaddress to=$emailaddress server=$mailserver port=$mailport user=$emailaddress password=$mailpass start-tls=yes file=$i subject=("$sysname Full Backup $i (" . [/system clock get date] . ")") body=("$sysname Full Backup $i \nRouterOS version: $sysver \n " . [/system clock get time] . " " . [/system clock get date]);
:delay 5;
}


:log info "Sending Backup files via ftp $ftpaddress";
:foreach i in={"$backupfile"; "$exportfile"} do={
:local ftptarget ("/$ftpdir/$i");
/tool fetch address=$ftpaddress src-path=$i user=$ftpuser mode=ftp password=$ftppassword dst-path=$ftptarget upload=yes
:delay 10;
}


:log info "All System Backups sent successfully.\nBackuping completed.";
}
