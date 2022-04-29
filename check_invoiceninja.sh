#!/bin/bash
#####################################################################################
# Script/Plugin:   check_invoiceninja.sh                                            #
# Author:          Claudio Kuenzler / Infiniroot LLC                                #
# Official repo:   https://github.com/infiniroot/check_invoiceninja                 #
#                                                                                   #
# License :      GNU General Public Licence (GPL) http://www.gnu.org/               #
# This program is free software; you can redistribute it and/or modify it under     #
# the terms of the GNU General Public License as published by the Free Software     #
# Foundation; either version 3 of the License, or (at your option) any later        #
# version.                                                                          #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY   #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A   #
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.         #
# You should have received a copy of the GNU General Public License along with this #
# program; if not, see <https://www.gnu.org/licenses/>.                             #
#                                                                                   #
# Copyright: 2021 Claudio Kuenzler / Infiniroot LLC                                 #
#                                                                                   #
# History/Changelog                                                                 #
# 2021-04-26 1.0 Public release                                                     #
# 2022-04-29 1.1 Support for Invoice Ninja v5                                       #
#####################################################################################
# (Pre-)Define some fixed variables
pluginversion=1.1
warntime=7
version=5
STATE_OK=0              # define the exit code if status is OK
STATE_WARNING=1         # define the exit code if status is Warning
STATE_CRITICAL=2        # define the exit code if status is Critical
STATE_UNKNOWN=3         # define the exit code if status is Unknown
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH # Set path

# Check for necessary commands
for cmd in mysql [
do
 if ! `which ${cmd} 1>/dev/null`
 then
 echo "UNKNOWN: ${cmd} does not exist, please check if command exists and PATH is correct"
 exit ${STATE_UNKNOWN}
 fi
done
#####################################################################################
# Help
help="check_invoiceninja v${pluginversion} (c) 2021-2022 Infiniroot\n
Usage: $0 [-H MySQLHost ] -u MySQLUser [-p MySQLPassword] -d Database [-w int]\n
\nOptions:\n
\t-H MySQL Host to connect to (defaults to localhost)\n
\t-u MySQL username\n
\t-p MySQL password (supports MySQL environment variables and ~./my.cnf)\n
\t-d Database to connect to (Invoice Ninja database)\n
\t-w Warn when license will expire in N days\n
\t-v Define Invoice Ninja version, either 4 or 5 (defaults to 5)\n
\nMySQL privileges:\n
The license information is stored in the Invoice Ninja database.\n
You therefore need to use a MySQL user which has read access to the relevant table holding the license information.\n
\nExample for Invoice Ninja v4:\n
\tGRANT SELECT ON invoiceninja.companies TO 'monitoring'@'localhost' IDENTIFIED BY 'password';\n
\nExample for Invoice Ninja v5:\n
\tGRANT SELECT ON invoiceninja.accounts TO 'monitoring'@'localhost' IDENTIFIED BY 'password';\n
"

if [ "${1}" = "--help" -o "${#}" = "0" ];
  then echo -e ${help}; exit 1;
fi
#####################################################################################
# Get user-given variables
while getopts "H:u:p:d:w:v:h" Input;
do
  case ${Input} in
  H)      mysqlhost=${OPTARG};;
  u)      mysqluser=${OPTARG};;
  p)      mysqlpass=${OPTARG}; export MYSQL_PWD=${mysqlpass};;
  d)      mysqldb=${OPTARG};;
  w)      warntime=${OPTARG};;
  v)      version=${OPTARG:=5};;
  h)      echo -e ${help}; exit ${STATE_UNKNOWN};;
  *)      echo -e ${help}; exit ${STATE_UNKNOWN};;
  esac
done
#####################################################################################
# Check for input errors
if [ -z ${mysqluser} ]; then echo "INVOICENINJA UNKNOWN - Missing database user"; exit ${STATE_UNKNOWN}; fi
if [ -z ${mysqldb} ]; then echo "INVOICENINJA UNKNOWN - Missing database name"; exit ${STATE_UNKNOWN}; fi
#####################################################################################
if [[ ${version} = 4 ]]; then
  data=$(mysql -h ${mysqlhost:=localhost} -u ${mysqluser} -Bse "SELECT * FROM ${mysqldb}.companies WHERE plan = 'white_label' LIMIT 0,1" 2>&1)
elif [[ ${version} = 5 ]]; then
  data=$(mysql -h ${mysqlhost:=localhost} -u ${mysqluser} -Bse "SELECT * FROM ${mysqldb}.accounts WHERE plan = 'white_label' LIMIT 0,1" 2>&1)
fi

if [[ $(echo "${data}" | grep -ic ERROR) -gt 0 ]]; then 
	echo "INVOICENINJA UNKNOWN - Unable to connect to database using given credentials"
	exit ${STATE_UNKNOWN}
fi

plan=$(echo "$data" | awk '{print $2}')
plan_term=$(echo "$data" | awk '{print $3}')
plan_paid=$(echo "$data" | awk '{print $5}')
plan_expires=$(echo "$data" | awk '{print $6}')

expires=$(date -d "${plan_expires}" +%s)
now=$(date +%s)
left=$(((${expires}-${now})/86400))
daysleft=$(((${expires}-${now})/86400))
unit="days"

if [[ ${left} -eq 0 ]]; then 
	left=$(((${expires}-${now})/3600))
	unit="hours"
fi

if [[ ${now} -gt ${expires} ]]; then
	echo "INVOICENINJA CRITICAL - ${plan} license has expired"
	exit ${STATE_CRITICAL}
elif [[ ${daysleft} -le ${warntime} ]]; then  
	echo "INVOICENINJA WARNING - ${plan} license will expire in $left $unit"
	exit ${STATE_WARNING}
else
	echo "INVOICENINJA OK - ${plan} license will expire in $left $unit"
	exit ${STATE_OK}
fi
