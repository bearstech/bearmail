#!/bin/bash

# Copyright (C) 2009 Bearstech - http://bearstech.com/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# bearmail-uninstall - part of bearmail


#
# idée de base, si pas debian alors --with-dspam=/etc/dspam --with-machin=
#
# dans la partie aide --help:
#    echo "Do you have installed postfix with prce / dovecot with pop3s-ipams / dspam <= 3.6.x / clamsmtpd / mailx ? (y/n)"

## CONFIG ME IF NEEDED
## penser à virer
# - /etc/bearmail/extraconf/my_fqdn
# - /etc/dovecot/sieve/global.conf
# - logrotate
# newaliases
# certificats ssl
# syslog.conf
# 


VMAIL_USER="vmail"
VMAIL_DIR="/var/spool/imap"
VMAIL_GUID="500"


## END OF CONF : DO NOT CHANGE
#

BEARMAIL_DIR="/etc/bearmail"
BEARMAIL_OLDCONF="/etc/bearmail/old_conf"
DSPAM_DIR="/etc/dspam"
CLAMSMTPD_CONF="/etc/clamsmtpd.conf"
DOVECOT_DIR="/etc/dovecot"
POSTFIX_DIR="/etc/postfix"
CLAMAV_DIR="/etc/clamav"
CLAMSMTPD="/etc/clamsmtpd.conf"

MY_V_FQDN=`grep "^MY_V_FQDN" $BEARMAIL_DIR/conf/bearmail.con`

NAME=`basename $0`

# run this script from root
if [ `id| awk '{print $1}'|sed -e 's/uid=//' -e 's/(.*//'` -ne 0 ] ; then
  echo "Error : You need to be root for installing $NAME script."
  exit 1
fi


### Global configuration

if [ -f $BEARMAIL_CONF/bearmail.conf ] ; then
  rm $BEARMAIL_CONF/bearmail.conf
fi


## Postfix configuration
#
if [ -d $BEARMAIL_OLDCONF/postfix/ ] && [ -f $POSTFIX_DIR/main.cf ] && \
   [ -f $POSTFIX_DIR/master.cf ] ; then
  rm $POSTFIX_DIR/{main.cf,master.cf,bearmail-*}
  mv $BEARMAIL_OLDCONF/postfix/main.cf_original $POSTFIX_DIR/main.cf
  mv $BEARMAIL_OLDCONF/postfix/master.cf_original $POSTFIX_DIR/master.cf
  rm -rf $BEARMAIL_OLDCONF/postfix
fi
# mailname
if [ -f "$BEARMAIL_OLDCONF/mailname_original" ] ; then
  rm /etc/mailname
  mv $BEARMAIL_OLDCONF/mailname_original /etc/mailname
fi


## Dovecot configuration
#
if [ -d $BEARMAIL_OLDCONF/dovecot ] && [ -f $DOVECOT_DIR/dovecot.conf ] ; then
   rm $DOVECOT_DIR/dovecot.conf
   mv $BEARMAIL_OLDCONF/dovecot/dovecot.conf_original $DOVECOT_DIR/dovecot.conf
   rm -rf $BEARMAIL_OLDCONF/dovecot $VMAIL_DIR/sieve $DOVECOT_DIR/bearmail-passwd
fi 


## Clamsmtpd configuration
#
if [ -d $BEARMAIL_OLDCONF/clamsmtpd ] ; then
  mv $BEARMAIL_OLDCONF/clamsmtpd/clamsmtpd.conf_original $CLAMSMTPD_CONF
  rm -rf $BEARMAIL_OLDCONF/clamsmtpd
fi
echo "Conf for clamsmtpd .. done"


## Dspam configuration
#
if [ -d $BEARMAIL_OLDCONF/dspam ] ; then
  if [ -f $DSPAM_DIR/dspam.conf ] ; then
    mv $BEARMAIL_OLDCONF/dspam/dspam.conf_original $DSPAM_DIR/dspam.conf
  fi
  if [ -f /etc/default/dspam ] ; then
    sed -e "s:START=yes:START=no:g" -i /etc/default/dspam
  fi
  if [ -f $DSPAM_DIR/default.prefs ] ; then
   mv $BEARMAIL_OLDCONF/dspam/default.prefs_original $DSPAM_DIR/default.prefs
  fi
  if [ -e "$(grep "postmaster@$MY_V_FQDN" $DSPAM_DIR/admins)" ] ; then
    sed -e "s/postmaster@$MY_V_FQDN//g"
  fi
  rm -rf $BEARMAIL_OLDCONF/dspam
fi


## deleting postmaster , mailmap and aliases
#
if  [ -f $BEARMAIL_DIR/mailmap ] ; then
  rm $BEARMAIL_DIR/mailmap
fi
if [ -e "$(grep "# configured for bearmail" /etc/aliases)" ] ; then
  sed -e "s/.*# configured for bearmail.*//" /etc/aliases
  newaliases
fi

## Log conf
#
if [ -d $BEARMAIL_OLDCONF/syslog ] ; then
  mv $BEARMAIL_OLDCONF/syslog/syslog.conf_-_original /etc/syslog.conf
  rm $BEARMAIL_OLDCONF/syslog -rf
  /etc/init.d/sysklogd stop
  /etc/init.d/sysklogd start
fi

## cron
if [ -f /etc/cron.d/bearmail ] ; then
  rm /etc/cron.d/bearmail
fi

## end :
rm -rf /etc/bearmail
