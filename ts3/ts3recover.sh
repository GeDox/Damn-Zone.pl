#! /usr/bin/env bash
# init
function pause(){
   read -p "$*"
}
/usr/bin/clear
echo "This script replaces the serveradmin password to reenable access
to your server. Use this script at your own risk.

Feel free to improve or extend this script. Share your modifications
on teamspeak forums (http://forum.teamspeak.com). Thank you.

Press any key to continue or ctrl+c to cancel..."
pause

echo "Current serveradmin and crypted password:"

sqlite3 ts3server.sqlitedb <<SQL_1
.header ON
SELECT client_login_name, client_login_password 
  FROM clients 
  WHERE client_id='1';
SQL_1

sqlite3 ts3server.sqlitedb <<SQL_2
UPDATE clients
  SET client_login_password = "r5oBZ3Z8s8IqjiEJ/k3o9dkSUgU=" 
  WHERE client_id = "1";
SQL_2

echo "updated entry:"

sqlite3 ts3server.sqlitedb <<SQL_3
SELECT client_login_name, client_login_password
  FROM clients
  WHERE client_id='1';
SQL_3

echo "
Server Query Admin Acccount replaced

 Password: ykN+zfqD

 NOTE:  This password has been copied from another database and is
        not safe. Update it directly after logging into your query
        console. Use the clientsetserverquerylogin command.
        You can enter help clientsetserverquerylogin for details.

"
