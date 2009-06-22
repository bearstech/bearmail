#!/bin/bash
#

## CONFIG ME IF NEEDED

VMAIL_USER="vmail"
VMAIL_DIR="/var/spool/imap"
VMAIL_GUID="500"

POSTFIX_CONF_DIR="/etc/postfix"
POSTFIX_INIT="/etc/init.d/postfix"

DOVECOT_CONF_DIR="/etc/dovecot"
DOVECOT_LIB_DIR="/usr/lib/dovecot"
DOVECOT_INIT="/etc/init.d/dovecot"

CLAMAV_USER="clamav"
CLAMAV_CONF_FILE="/etc/clamav/clamd.conf"
CLAMAV_SOCKET="/var/run/clamav/clamd.ctl"
CLAMAV_INIT="/etc/init.d/clamav-daemon"

CLAMSMTPD_CONF_FILE="/etc/clamsmtpd.conf"
CLAMSMTPD_USER="clamsmtp"
CLAMSMTPD_GROUP="clamsmtp"
CLAMSMTPD_INIT="/etc/init.d/clamsmtp"

DSPAM_CONF_DIR="/etc/dspam"
DSPAM_USER="dspam"
DSPAM_INIT="/etc/init.d/dspam"

BEARMAIL_SRC_DIR="/usr/share/bearmail/"
BEARMAIL_OLDCONF="/etc/bearmail/old_conf"
BEARMAIL_BIN_DIR="/usr/sbin/"


## End of config. Do not edit
#
BEARMAIL_DIR="/etc/bearmail"
BEARMAIL_CONF="/etc/bearmail/conf"

HOSTNAME=`hostname --fqdn`
NAME=`basename $0`


## Start the script
#
# The install shouldn't start unless the system is correctly configured.
# If not, then stop it.

## Bases checks :
#

# check if we are root
if [ "$(whoami &2>/dev/null)" != "root" ] && \
   [ "$(id -un &2>/dev/null)" != "root" ] ; then
  echo "Error : You must be root to run this script."
  exit 1
fi
# see if which is installed
if [ -z "$(which which 2>/dev/null)" ] ; then
  echo "Error : which not found."
  exit 1
fi
# see if hostname gives info
if [ -z "$HOSTNAME" ] ; then
  echo "Error : Your hostname wasn't found."
  exit 1
fi

# if the user for virtual domains exists then check if it's correctly configured
if [ "`grep "^$VMAIL_USER:" /etc/passwd`" ] || \
   [ "`grep ":$VMAIL_GUID:" /etc/group`"  ] || \
   [ "`grep "^$VMAIL_USER:" /etc/group`"  ] || \
   [ -d "$VMAIL_USER" ] || \
   [ "`grep ":$VMAIL_DIR:" /etc/passwd`" ] ; then
  if [ ! "`grep "$VMAIL_USER:x:$VMAIL_GUID:$VMAIL_GUID::$VMAIL_DIR:/bin/false"\
                /etc/passwd`" ] && \
     [ ! "`grep "$VMAIL_USER:x:$VMAIL_GUID:" /etc/group`" ] ; then
    echo "Error: $VMAIL_GUID uid/gid or $VMAIL_USER user or $VMAIL_DIR \
directory seems to ."
    echo "Please change VMAIL_GUID / VMAIL_USER / VMAIL_DIR value in \
$NAME script installation."
    exit 1
  fi
fi

## check if SSL is present
if [ -z "$(which openssl)" ] ; then
  echo "Error, openssl is not installed or in a wrong PATH. See TFM."
  exit 1
fi

# postfix is correctly configured ?
if [ ! -f $POSTFIX_CONF_DIR/main.cf ] || \
   [ ! -f $POSTFIX_CONF_DIR/master.cf ] || \
   [ -z "$(which postfix)" ]  ; then
  echo "Error, postfix is not installed or in a wrong PATH. See TFM."
  exit 1
fi

## Dovecot is correctly configured ?
if [ ! -f $DOVECOT_CONF_DIR/dovecot.conf ] || \
   [ -z "$(which dovecot)" ]  ; then
  echo "Error, dovecot is not installed or in a wrong PATH. See TFM."
  exit 1
fi

## Clamav is correctly configured ?
if [ ! -f $CLAMAV_CONF_FILE ] || \
   [ ! "$(grep "^$CLAMAV_USER:" /etc/passwd)" ] ; then
  echo "Error, $CLAMAV_CONF_FILE does not exist. Or clamav user doesn't exist.
Take a look at TFM."
  exit 1
fi
if [ -f $CLAMAV_CONF_FILE ] ; then
  if [ ! "$(grep "^LocalSocket.*$CLAMAV_SOCKET" \
                 $CLAMAV_CONF_FILE)" ] && \
     [ ! "$(grep -i "^ScanMail.*true" $CLAMAV_CONF_FILE)" ] && \
     [ ! "$(grep -i "^User.*$CLAMAV_USER" $CLAMAV_CONF_FILE)" ] && \
     [ ! "$(grep -i "$CLAMSMTPD_GROUP.*$CLAMAV_USER" /etc/group)" ] ; then
    echo "Clamav need to be reconfigured, see TFM."
    exit 1
  fi
fi

## Clamsmtpd is correctly configured ?
if [ ! -f $CLAMSMTPD_CONF_FILE ] || \
   [ ! "$(grep "^$CLAMSMTPD_USER:" /etc/passwd)" ] || \
   [ ! "$(grep "^$CLAMSMTPD_GROUP:" /etc/group)" ] ; then
  echo "Error, clamsmtpd is not installed or in a wrong PATH. See TFM."
  exit 1
fi

## Dspam is correctly configured ?
#
if [ ! -f $DSPAM_CONF_DIR/dspam.conf ] || \
   [ -z "$(which dspam)" ] ||
   [ ! "$(grep "^$DSPAM_USER:" /etc/passwd;)" ] ; then
  echo "Error, dspam is not (correctly) installed or in a wrong PATH. See TFM."
  exit 1
fi

## every basic configuration seem correct, let's create things
#
if [ ! -d "$BEARMAIL_CONF" ] ; then
  mkdir -p $BEARMAIL_CONF
fi


## install section


## Create a user for mail's virtual domains
#
if [ ! "`grep "$VMAIL_USER:x:$VMAIL_GUID:$VMAIL_GUID::$VMAIL_DIR:/bin/false" \
       /etc/passwd`" ] && \
   [ ! "`grep "$VMAIL_USER:x:$VMAIL_GUID:" /etc/group`" ] ; then
  adduser --system --home $VMAIL_DIR --shell /bin/false \
          --disabled-login --uid $VMAIL_GUID --group \
          --disabled-password $VMAIL_USER  > /dev/null 2>&1
  chown -R $VMAIL_GUID:$VMAIL_GUID $VMAIL_DIR
  chmod -R 770 $VMAIL_DIR
fi


## Choose the default main domain of the mail server
#
if [ -e "$BEARMAIL_CONF/bearmail.conf" ] ; then
  # if a previous bearmail installation already defines it, then use it
  MY_V_FQDN=`grep "^MY_V_FQDN=" $BEARMAIL_CONF/bearmail.conf | \
             sed -e "s/MY_V_FQDN=\"//;s/\"//"`
#  echo "The actual default virtual mail domain is \"$MY_V_FQDN\""
#  while : ; do
#    echo -n "Do you want to change it ? [y/n] "
#    read CONFIRM
#    case $CONFIRM in
#      y|Y|yes|YES)
#        MY_V_FQDN=""
#        break ;;
#      n|N|no|NO)
#        break ;;
#      *)
#    esac
#  done
fi
if [ -z "$MY_V_FQDN" ] || [ ! -e "$BEARMAIL_CONF/bearmail.conf" ] ; then
  echo -e "What will be the principal virtual domain name for your mail server ?
(Don't forget, use a valide domain name and do not say $HOSTNAME)"
  while : ; do
    echo -n "[$MY_V_FQDN]: "
    read MY_V_FQDN
    DOMAIN_NAME="1"
    if [ "$(echo "$MY_V_FQDN" | perl -pe 's/[a-z0-9\-\.]//gi')" ] || \
       [ -z "$MY_V_FQDN" ] ; then
      echo -e "Please try again, wrong domain syntax."
      DOMAIN_NAME="0"
    fi
    if [ "$(echo "$MY_V_FQDN" | tr '[:upper:]' '[:lower:]')" = \
         "$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')" ] ; then
      echo -e "Please try again, DON'T say $HOSTNAME"
      DOMAIN_NAME="0"
    fi
    if [ "$DOMAIN_NAME" -eq "1" ] ; then
      echo -n "You said \"$MY_V_FQDN\", do you confirm? [y/n] "
      read CONFIRM
      case $CONFIRM in
          y|Y|yes|YES)
            break ;;
          n|N|no|NO)
            DOMAIN_NAME="0"
            ;;
          *)
      esac
    fi
  done
fi
echo "Your default virtual mail domain name is \"$MY_V_FQDN\""
echo "If you want to change it in the futur, RTFM."


## Select language
#
if [ -e "$BEARMAIL_CONF/bearmail.conf" ] ; then
  MY_LANGUAGE=`grep "^MY_LANGUAGE=" $BEARMAIL_CONF/bearmail.conf | \
             sed -e "s/MY_LANGUAGE=\"//;s/\".*//"`
fi
if [ -z "$MY_LANGUAGE" ] ; then
  while : ; do
    echo -n "What will be the default language for your mail server ? [fr/en] "
    read MY_LANGUAGE
    case $MY_LANGUAGE in
      en|EN)
        echo "Sorry but english is not supported actually, please try \"fr\""
        ;;
      fr|FR)
        break ;;
      *)
    esac
  done
fi
echo "Your default language will be \"$MY_LANGUAGE\""


## SSL configuration
#
if [ ! -s /etc/ssl/certs/bearmail.pem ] ; then
  mkdir -p /etc/ssl/certs/
  echo "Configuration for SSL (auto-signed certificate for 3 years, RTFM) :"
  openssl req -new -x509 -nodes -out /etc/ssl/certs/bearmail.pem -keyout \
          /etc/ssl/certs/bearmail.pem -days 1095
  chmod 600 /etc/ssl/certs/bearmail.pem
  mkdir -p /etc/ssl/private/
  cp /etc/ssl/certs/bearmail.pem /etc/ssl/private/
fi
#echo "Keys for SSL .. done"


## Postfix configuration
#
# move old conf of postfix to bearmail extraconf and use bearmail postfix conf
if [ -d $BEARMAIL_OLDCONF/postfix ] ; then # bearmail was allready installed
  cp $POSTFIX_CONF_DIR/main.cf \
     $BEARMAIL_OLDCONF/postfix/main.cf_-_last_bearmail_install.backup
  rm $POSTFIX_CONF_DIR/main.cf
  cp $POSTFIX_CONF_DIR/master.cf \
     $BEARMAIL_OLDCONF/postfix/master.cf_-_last_bearmail_install.backup
  rm $POSTFIX_CONF_DIR/master.cf
fi
if [ ! -d $BEARMAIL_OLDCONF/postfix ] ; then # new bearmail installation
  mkdir -p $BEARMAIL_OLDCONF/postfix
  mv $POSTFIX_CONF_DIR/main.cf $BEARMAIL_OLDCONF/postfix/main.cf_original
  mv $POSTFIX_CONF_DIR/master.cf $BEARMAIL_OLDCONF/postfix/master.cf_original
fi
mkdir -p $BEARMAIL_CONF/postfix
cp $BEARMAIL_SRC_DIR/etc/postfix-main.cf $BEARMAIL_CONF/postfix/main.cf
ln -s  $BEARMAIL_CONF/postfix/main.cf $POSTFIX_CONF_DIR/main.cf
cp $BEARMAIL_SRC_DIR/etc/postfix-master.cf $BEARMAIL_CONF/postfix/master.cf
ln -s $BEARMAIL_CONF/postfix/master.cf $POSTFIX_CONF_DIR/master.cf
# replace dovecot configuration (depending of distro)
sed -e "s:/usr/lib/dovecot/:$DOVECOT_LIB_DIR/:g" -i $BEARMAIL_CONF/postfix/main.cf
sed -e "s:/usr/lib/dovecot/:$DOVECOT_LIB_DIR/:g" -i $BEARMAIL_CONF/postfix/master.cf
# define clamsmtpd user
sed -e "s:  flags= user=clamsmtp argv=:  flags= user=$CLAMSMTPD_USER argv=:g" \
    -i $BEARMAIL_CONF/postfix/master.cf
# define hostname for main domain
sed -e "s:bearmail.tld:$HOSTNAME:g" -i $BEARMAIL_CONF/postfix/main.cf
if [ ! -f "$BEARMAIL_OLDCONF/mailname" ] ; then
  cp /etc/mailname $BEARMAIL_OLDCONF/mailname_original
fi
echo "$HOSTNAME" > /etc/mailname
# create helo check / dspam incomming / client check
if [ ! -f "$POSTFIX_CONF_DIR/bearmail-dspam_incoming" ] ; then
  # only non hosted mails are checked by dspam
  echo "/./     FILTER dspam:unix:/var/spool/postfix/var/run/dspam.sock" > \
       $BEARMAIL_CONF/postfix/bearmail-dspam_incoming
  ln -s $BEARMAIL_CONF/postfix/bearmail-dspam_incoming \
       $POSTFIX_CONF_DIR/bearmail-dspam_incoming
fi
if [ ! -f "$POSTFIX_CONF_DIR/bearmail-client_access" ] ; then
  cat > $BEARMAIL_CONF/postfix/bearmail-client_access << EOF
# Whitelist specific client IP or domains with "OK" target here
#1.2.3.4     OK

# Blacklist baad clients (IP, domain, wildcard) with "REJECT <reason>" here
#5.6.7.8     REJECT Your server is blocked, see http://my.mailserver.com/policy
EOF
  ln -s $BEARMAIL_CONF/postfix/bearmail-client_access \
        $POSTFIX_CONF_DIR/bearmail-client_access
  postmap $POSTFIX_CONF_DIR/bearmail-client_access
fi
if [ ! -f "$POSTFIX_CONF_DIR/bearmail-helo_access" ] ; then
  cat > $BEARMAIL_CONF/postfix/bearmail-helo_access << EOF
# Whitelist specific HELOs with "OK" target here
#my.computer.home	OK

# Whitelist known people with BAD relays

# Blacklist awful HELOs with "REJECT <reason>" here
#my.mailserver.com      REJECT Bad HELO, see http://my.mailserver.com/policy
localhost.localdomain   REJECT You are not me!
$MY_V_FQDN		REJECT You are not me!
$HOSTNAME		REJECT You are not me!
127.0.0.1		REJECT You are not me!
EOF
  ln -s $BEARMAIL_CONF/postfix/bearmail-helo_access \
        $POSTFIX_CONF_DIR/bearmail-helo_access
  postmap $POSTFIX_CONF_DIR/bearmail-helo_access
fi
# create rep for chrooted socket
mkdir -p /var/spool/postfix/var/run
chmod 770 /var/spool/postfix/var/run
chgrp $DSPAM_USER /var/spool/postfix/var/run
# define spam/ham/virus account with the default virtual domain
if [ -f $POSTFIX_CONF_DIR/bearmail-transport ] ; then # old bearmail conf
  if [ -z "$(grep "^spam@$MY_V_FQDN dspam-retrain:spam" \
                  $POSTFIX_CONF_DIR/bearmail-transport)" ] ; then
    echo "spam@$MY_V_FQDN virus-sender:" >> \
         $POSTFIX_CONF_DIR/bearmail-transport
    postmap $POSTFIX_CONF_DIR/bearmail-transport
  fi
  if [ -z "$(grep "^ham@$MY_V_FQDN dspam-retrain:innocent" \
                  $POSTFIX_CONF_DIR/bearmail-transport)" ] ; then
    echo "ham@$MY_V_FQDN dspam-retrain:innocent" >> \
         $POSTFIX_CONF_DIR/bearmail-transport
    postmap $POSTFIX_CONF_DIR/bearmail-transport
  fi
  if [ -z "$(grep "^virus@$MY_V_FQDN virus-sender:" \
           $POSTFIX_CONF_DIR/bearmail-transport)" ] ; then
    echo "virus@$MY_V_FQDN virus-sender:" >> \
         $POSTFIX_CONF_DIR/bearmail-transport
    postmap $POSTFIX_CONF_DIR/bearmail-transport
  fi
fi
if [ ! -f $POSTFIX_CONF_DIR/bearmail-transport ] ; then # new bearmail's conf
  cat > $BEARMAIL_CONF/postfix/bearmail-transport << EOF
## do not edit spam/ham/virus
spam@$MY_V_FQDN dspam-retrain:spam
ham@$MY_V_FQDN dspam-retrain:innocent
virus@$MY_V_FQDN virus-sender:
EOF
  ln -s $BEARMAIL_CONF/postfix/bearmail-transport \
        $POSTFIX_CONF_DIR/bearmail-transport
  postmap $POSTFIX_CONF_DIR/bearmail-transport
fi
# dspam used only for non hosted mails
#echo "/./ FILTER dspam:unix:/var/spool/postfix/var/run/dspam.sock" > \
#      /etc/postfix/bearmail-dspam_incoming
#echo "Conf for postfix .. done"


## Dovecot configuration
#
# move old conf of dovecot to bearmail oldconf dir and use bearmail dovecot conf
if [ -d $BEARMAIL_OLDCONF/dovecot ] ; then # old bearmail configuration
  cp $DOVECOT_CONF_DIR/dovecot.conf \
     $BEARMAIL_OLDCONF/dovecot/dovecot.conf_-_last_bearmail_install.backup
  rm $DOVECOT_CONF_DIR/dovecot.conf
fi
if [ ! -d $BEARMAIL_OLDCONF/dovecot ] ; then # new bearmail conf
  mkdir -p $BEARMAIL_OLDCONF/dovecot
  mv $DOVECOT_CONF_DIR/dovecot.conf \
     $BEARMAIL_OLDCONF/dovecot/dovecot.conf_original
fi
mkdir -p $BEARMAIL_CONF/dovecot
cp $BEARMAIL_SRC_DIR/etc/dovecot.conf $BEARMAIL_CONF/dovecot/dovecot.conf
ln -s $BEARMAIL_CONF/dovecot/dovecot.conf $DOVECOT_CONF_DIR/dovecot.conf
sed -e "s:bearmail.tld:$MY_V_FQDN:g" -i $BEARMAIL_CONF/dovecot/dovecot.conf
# find version of dovecot (if > v1.0.1) for sieve plugin
if [ "$(dovecot --version | awk -F . '{print $1$2}')" -le "10" ] ; then
  sed -e \
      "s:bearmail_sieve_global_path.*:global_script_path = $VMAIL_DIR/sieve/global.conf:g" \
      -i $BEARMAIL_CONF/dovecot/dovecot.conf
fi
if [ "$(dovecot --version | awk -F . '{print $1$2}')" -gt "10" ] ; then
  sed -e \
      "s:bearmail_sieve_global_path.*:sieve_global_path = $VMAIL_DIR/sieve/global.conf:g" \
      -i $BEARMAIL_CONF/dovecot/dovecot.conf
fi
mkdir -p $VMAIL_DIR/sieve
touch $VMAIL_DIR/sieve/global.conf
chown -R $VMAIL_USER: $VMAIL_DIR/sieve
#echo "Conf for dovecot .. done"


## Clamsmtpd configuration
#
if [ -d $BEARMAIL_OLDCONF/clamsmtpd ] ; then
  cp $CLAMSMTPD_CONF_FILE \
     $BEARMAIL_OLDCONF/clamsmtpd/clamsmtpd.conf_-_last_bearmail_install.backup
  rm $CLAMSMTPD_CONF_FILE
fi
if [ ! -d $BEARMAIL_OLDCONF/clamsmtpd ] ; then
  mkdir -p $BEARMAIL_OLDCONF/clamsmtpd
  mv $CLAMSMTPD_CONF_FILE $BEARMAIL_OLDCONF/clamsmtpd/clamsmtpd.conf_original
fi
mkdir -p $BEARMAIL_CONF/clamsmtpd
cp $BEARMAIL_SRC_DIR/etc/clamsmtpd.conf $BEARMAIL_CONF/clamsmtpd/clamsmtpd.conf
ln -s $BEARMAIL_CONF/clamsmtpd/clamsmtpd.conf $CLAMSMTPD_CONF_FILE
sed -e "s%^ClamAddress.*%ClamAddress: $CLAMAV_SOCKET%" -i \
       $BEARMAIL_CONF/clamsmtpd/clamsmtpd.conf
sed -e "s%User.*%User: $CLAMSMTPD_USER%g" -i \
       $BEARMAIL_CONF/clamsmtpd/clamsmtpd.conf
#echo "Conf for clamsmtpd .. done"


## Dspam configuration
#
if [ -f /etc/default/dspam ] ; then
  sed -e "s:^START=no:START=yes:g" -i /etc/default/dspam
fi
if [ -d $BEARMAIL_OLDCONF/dspam ] ; then
  cp $DSPAM_CONF_DIR/dspam.conf \
     $BEARMAIL_OLDCONF/dspam/dspam.conf_-_last_bearmail_install.backup
  rm $DSPAM_CONF_DIR/dspam.conf
  cp $DSPAM_CONF_DIR/default.prefs \
     $BEARMAIL_OLDCONF/dspam/default.prefs_-_last_bearmail_install.backup
  rm $DSPAM_CONF_DIR/default.prefs
fi
if [ ! -d $BEARMAIL_OLDCONF/dspam ] ; then
  mkdir -p $BEARMAIL_OLDCONF/dspam
  mv $DSPAM_CONF_DIR/dspam.conf $BEARMAIL_OLDCONF/dspam/dspam.conf_original
  mv $DSPAM_CONF_DIR/default.prefs \
     $BEARMAIL_OLDCONF/dspam/default.prefs_original
#  echo "groupname:classification:*globaluser" > /var/spool/dspam/group
#  mkdir -p /var/spool/dspam/data/local/globaluser/globaluser.sig
#  cp  -R $BEARMAIL_SRC_DIR/extraconf/dspam/dspam_var/dspam /var/spool/dspam/
#  chown -R dspam:dspam /var/spool/dspam/
fi
mkdir -p $BEARMAIL_CONF/dspam
cp $BEARMAIL_SRC_DIR/etc/dspam/dspam.conf $BEARMAIL_CONF/dspam/dspam.conf
ln -s $BEARMAIL_CONF/dspam/dspam.conf $DSPAM_CONF_DIR/dspam.conf
cp $BEARMAIL_SRC_DIR/etc/dspam/default.prefs $BEARMAIL_CONF/dspam/default.prefs
ln -s $BEARMAIL_CONF/dspam/default.prefs $DSPAM_CONF_DIR/default.prefs
#if [ ! -e "$(grep "postmaster@" $DSPAM_DIR/admins)" ] ; then
#  echo "postmaster@$MY_V_FQDN" >> $DSPAM_DIR/admins
#fi
#echo "Conf for Dspam .. done"


## adding accounts
# create mailmap
if  [ ! -e $BEARMAIL_DIR/mailmap ] ; then
  # make a random password for postmaster/spam/ham/virus
  MY_PASSWD=`perl -e '@c=("A".."Z","a".."z",0..9);\
                      print join("",@c[map{rand @c}(1..8)])'`
  MY_PLAIN_MD5=`echo -n "$MY_PASSWD" | md5sum|sed -e "s/  -$//"`
  cat > $BEARMAIL_DIR/mailmap << EOF
## /etc/bearmail/mailmap - Sample mail account configuration
#
## regular_account
#bob@company.com:9a8ad92c50cae39aa2c5604fd0ab6d8c:local
#
## alias
#info@company.com::bob@company.com,alice@people.net
#
## external_program (regular)
#fortune@company.com::|/bin/fortune
#
## catchall
#*@company.com::info@company.com,alice@helpdesk.net
#
## domain_alias
#*@company2.com::*@spam.com
#

## $MY_V_FQDN
postmaster@$MY_V_FQDN:$MY_PLAIN_MD5:local
spam@$MY_V_FQDN:$MY_PLAIN_MD5:local
ham@$MY_V_FQDN:$MY_PLAIN_MD5:local
virus@$MY_V_FQDN:$MY_PLAIN_MD5:local
EOF
#  echo "Adding $MY_V_FQDN domain .. done"
  echo "######################################################################"
  echo "# Your password for postmaster@$MY_V_FQDN"
  echo "#   (or spam/ham/virus@$MY_V_FQDN)"
  echo "#    is : $MY_PASSWD"
  echo "# Do never delete them. You still can change the password if needed."
  echo "# postmaster@$MY_V_FQDN is now the official account of root"
  echo "######################################################################"
  $BEARMAIL_BIN_DIR/bearmail-update
fi
# cleaning /etc/aliases
if [ ! -e "$(grep "postmaster@$MY_V_FQDN" /etc/aliases)" ] ; then
  cp /etc/aliases $BEARMAIL_OLDCONF/etc_aliases
  sed -e "s/^root:/#root:/g" -i /etc/aliases
  echo "root: postmaster@$MY_V_FQDN" >> \
       /etc/aliases
  newaliases
#  echo "/etc/aliases configured."
fi

## Log conf : logging mails in /var/log/mail/mail.log
#
if [ ! -f /etc/syslog.conf ] || \
   [ -z "$(grep "^mail.\*" /etc/syslog.conf)" ] ; then
     echo "Warning : /etc/syslog.conf is missing from your system or it misses \
rules to log mails informations.
Please, see TFM for more informations."
fi
if [ ! -d $BEARMAIL_OLDCONF/syslog ] && [ -f /etc/syslog.conf ] ; then
  mkdir -p $BEARMAIL_OLDCONF/syslog
  cp /etc/syslog.conf $BEARMAIL_OLDCONF/syslog/syslog.conf_-_original
  if [ -z "$(grep "/var/log/mail/mail.log" /etc/syslog.conf)" ] && \
     [ ! -z "$(grep "^mail.\*" /etc/syslog.conf)" ] ; then
       sed -e "s:^mail.\*.*:mail.\*\t\t\t\t/var/log/mail/mail.log:" \
           -i /etc/syslog.conf
       sed -e "s/^mail.info/#mail.info/" -i /etc/syslog.conf
       sed -e "s/^mail.warn/#mail.warn/" -i /etc/syslog.conf
       sed -e "s/^mail.err/#mail.err/" -i /etc/syslog.conf
       sed -e "s/^daemon.\*;mail.\*/#daemon.\*;mail.\*/" -i /etc/syslog.conf
       sed -e "s/^\tnews.err;/#\tnews.err;/" -i /etc/syslog.conf
       sed -e "s/^\t\*.=debug;\*.=info;/#\t\*.=debug;\*.=info;/" \
           -i /etc/syslog.conf
       sed -e "s/^\t\*.=notice;\*.=warn/#\t\*.=notice;\*.=warn/" \
           -i /etc/syslog.conf
       mkdir -p /var/log/mail
       if [ -e /var/log/mail.err ] ; then
         mv /var/log/mail.err /var/log/mail/
       fi
       if [ -e  /var/log/mail.info ] ; then
         mv /var/log/mail.info /var/log/mail/
       fi
       if [ -e /var/log/mail.log ] ; then
         mv /var/log/mail.log /var/log/mail/
       fi
       if [ -e /var/log/mail.warn ] ; then
         mv /var/log/mail.warn /var/log/mail/
       fi
       if [ -d /etc/logrotate.d/ ] ; then
          cat > /etc/logrotate.d/bearmail << EOF
/var/log/mail/mail.log {
	daily
	rotate 60
	compress
	delaycompress
	missingok
	notifempty
	create 640 root adm
}
EOF
       fi
       /etc/init.d/sysklogd stop  > /dev/null 2>&1
       /etc/init.d/sysklogd start  > /dev/null 2>&1
  fi
fi
#echo "Conf for syslog .. done"


## Creating cron conf
#
if [ ! -f /etc/cron.d/bearmail ] ; then
  cat > /etc/cron.d/bearmail << EOF
### Regular cron jobs for the bearmail package
## - clean & backup dictonary every month
## - make a fast check for dictionary's validity (every 3h)
## - clean viruses files that have more than 30 days (every 5 days)
#

# Read config file if it is present.
if [ -r /etc/bearmail/conf/bearmail.conf ]; then
	. /etc/bearmail/conf/bearmail.conf
fi

if [ "\$START_BEARMAIL" != "yes" ]; then
      exit 0
fi


1 1 1 * * root $BEARMAIL_BIN_DIR/bearmail-dspam_cleaner --clean
* */3 * * * root $BEARMAIL_BIN_DIR/bearmail-dspam_cleaner --fast-check
* * */5 * * root su clamsmtp -s /bin/bash -c "find /var/spool/clamsmtp/ -type f -name 'virus.*' -and -mtime +$MY_VIRUS_TIME -exec rm {} \;"
EOF
fi


## Setting $VAR to bearmail.conf
#
cat > $BEARMAIL_CONF/bearmail.conf << EOF
## Configuration for bearmail
#

# Default language. Used by bearmail-virus_notify
MY_LANGUAGE="$MY_LANGUAGE"

# How many days viruses are kept ? Used by cron and bearmail-virus_notify
MY_VIRUS_TIME="30"

# Activate the cron ? yes/no
START_BEARMAIL="no"

############# DO NOT EDIT UNDER THIS LINE #################
VMAIL_USER=$VMAIL_USER
VMAIL_DIR="$VMAIL_DIR"
VMAIL_GUID="$VMAIL_GUID"
POSTFIX_CONF_DIR="$POSTFIX_CONF_DIR"
POSTFIX_INIT="$POSTFIX_INIT"
DOVECOT_CONF_DIR="$DOVECOT_CONF_DIR"
DOVECOT_LIB_DIR="$DOVECOT_LIB_DIR"
DOVECOT_INIT="$DOVECOT_INIT"
CLAMAV_USER="$CLAMAV_USER"
CLAMAV_CONF_FILE="$CLAMAV_CONF_FILE"
CLAMAV_SOCKET="$CLAMAV_SOCKET"
CLAMAV_INIT="$CLAMAV_INIT"
CLAMSMTPD_CONF_FILE="$CLAMSMTPD_CONF_FILE"
CLAMSMTPD_USER="$CLAMSMTPD_USER"
CLAMSMTPD_GROUP="$CLAMSMTPD_GROUP"
CLAMSMTPD_INIT="$CLAMSMTPD_INIT"
DSPAM_CONF_DIR="$DSPAM_CONF_DIR"
DSPAM_USER="$DSPAM_USER"
DSPAM_INIT="$DSPAM_INIT"
BEARMAIL_SRC_DIR="$BEARMAIL_SRC_DIR"
BEARMAIL_OLDCONF="$BEARMAIL_OLDCONF"
BEARMAIL_BIN_DIR="$BEARMAIL_BIN_DIR"
BEARMAIL_DIR="$BEARMAIL_DIR"
BEARMAIL_CONF="$BEARMAIL_CONF"
MY_V_FQDN="$MY_V_FQDN"
EOF

chmod 755 $BEARMAIL_CONF/bearmail.conf


## That's it.
#
bearmail-update
echo -e "\nBearMail system is installed !"
echo "See the documentation for more information."
#echo -e "Run \"/etc/init.d/bearmail start\" if configurations files are OK.\n"
#echo "Please put in your domain(s) zone(s) the following configuration :"
#echo "; Sender Policy Framework configuration :"
#echo -e "YOUR.DOMAIN.TLD.		IN	TXT	\"v=spf1 ip4:YOUR.IPV4.BEARMAIL.SERVER ~all\"\n"
#echo "; DomainKey / DKIM configuration :"
#echo "_domainkey.YOUR.DOMAIN.TLD.	IN	TXT	\"t=y; o=~;\""
#echo -e "postfix.key._domainkey.YOUR.DOMAIN.TLD.   IN      TXT     \"k=rsa; p=$(grep -v " KEY" /etc/ssl/certs/postfix.key |sed -e :a -e '/$/N; s/\n//; ta');\"\n"
#echo "In apache vhost conf :"
#echo "    Alias /antispam /var/www/bearmail/antispam/dspam"
#echo "    SuexecUserGroup dspam dspam"
#echo "    <Directory /var/www/bearmail/antispam/dspam>"
#echo "       Addhandler cgi-script .cgi"
#echo "       Options +ExecCGI -Indexes"
#echo "       DirectoryIndex dspam.cgi"
#echo "       AllowOverride None"
#echo "    </Directory>"



##############################################################################
###                   le futur, que nous réserve-t'il ?                    ###
##############################################################################

## DK / DKIM key configuration
#
#if [ ! -s /etc/ssl/certs/postfix.key ] ; then
#  echo "Configuration for DomainKeys (auto-signed certificate for 1 year) :"
#  cd /etc/ssl/private/
#  openssl genrsa -out postfix_private.key 1024
#  mkdir -p /etc/bearmail/keys
#  cp postfix_private.key /etc/bearmail/keys/postfix.key
#  chown dkim-filter:dk-filter /etc/bearmail/keys/postfix.key
#  chmod 550 /etc/bearmail/keys/postfix.key
#  cd /etc/ssl/certs/
#  openssl rsa -in ../private/postfix_private.key -pubout -out postfix.key
#  #echo "Your private DomainKey have been put in /etc/ssl/private/postfix_private.key and in /etc/bearmail/keys/postfix.key"
#  #echo "Your public DomainKey have been put in /etc/ssl/certs/postfix.key"
#fi
#echo "Keys for DK/DKIM .. done"

## DKIM
#
#if [ ! -d $BEARMAIL_OLDCONF/dkim ] ; then
#  mkdir -p $BEARMAIL_OLDCONF/dkim
#  mkdir -p $BEARMAIL_DIR/keys
#  cp /etc/default/dkim-filter $BEARMAIL_OLDCONF/dkim/dkim-filter_original
#  cp $BEARMAIL_DIR/extraconf/dkim-filter /etc/default/dkim-filter
#  cp /etc/dkim-filter.conf $BEARMAIL_OLDCONF/dkim/dkim-filter.conf_original
#  cp $BEARMAIL_DIR/extraconf/dkim-filter.conf /etc/dkim-filter.conf
#  echo "*:$MY_V_FQDN:/etc/bearmail/keys/postfix.key" > /etc/bearmail/keys/dkim-keylist
#else
#  cp /etc/default/dkim-filter $BEARMAIL_OLDCONF/dkim/dkim-filter_-_last_bearmail_install.backup
#  cp $BEARMAIL_DIR/extraconf/dkim-filter /etc/default/dkim-filter
#  cp /etc/dkim-filter.conf $BEARMAIL_OLDCONF/dkim/dkim-filter.conf_-_last_bearmail_install.backup
#  #echo "An old bearmail DKIM configuration have been found. Backuped files are dkim-filter_-_last_bearmail_install.backup and dkim-filter.conf_-_last_bearmail_install.backup in $BEARMAIL_OLDCONF/dkim"
#fi
#echo "Conf for DKIM .. done"

## DK
#
#if [ ! -d $BEARMAIL_OLDCONF/dk ] ; then
#  mkdir -p $BEARMAIL_OLDCONF/dk
#  cp /etc/default/dk-filter $BEARMAIL_OLDCONF/dk/dk-filter_original
#  cp $BEARMAIL_DIR/extraconf/dk-filter /etc/default/dk-filter
#  mkdir -p /var/spool/postfix/var/run/
#  chown dspam:dspam /var/spool/postfix/var/run/
#else
#  cp /etc/default/dk-filter $BEARMAIL_OLDCONF/dk/dk-filter_-_last_bearmail_install.backup
#  cp $BEARMAIL_DIR/extraconf/dk-filter /etc/default/dk-filter
#  echo "An old bearmail DK configuration have been found. Backuped file is $BEARMAIL_OLDCONF/dk/dk-filter_-_last_bearmail_install.backup"
#fi
#echo "Conf for DK .. done"

## Dspam webfrontend
#
#if [ -d $BEARMAIL_OLDCONF/dspam-web ] ; then
#  mv $DSPAM_CONF_DIR/dspam_tricks $BEARMAIL_OLDCONF/dspam-web
#fi
#if [ ! -d $BEARMAIL_OLDCONF/dspam-web ] ; then
#  mkdir -p $BEARMAIL_OLDCONF/dspam-web
#fi
#cp -a $BEARMAIL_SRC_DIR/etc/dspam/dspam_tricks $DSPAM_CONF_DIR/
#chown -R dspam: $DSPAM_CONF_DIR/dspam_tricks
#  chmod -R u+x /etc/dspam/dspam_tricks
#  ln -s /etc/dspam/dspam_tricks/dspam_stats_wrapper.pl /etc/dspam/dspam_stats_wrapper.pl
#  mv /etc/dspam/webfrontend.conf $BEARMAIL_OLDCONF/dspam-web/webfrontend.conf_original
#  cp $BEARMAIL_DIR/extraconf/dspam/webfrontend.conf /etc/dspam/
#  mkdir -p /var/www/bearmail/antispam
#  cp -a $BEARMAIL_DIR/extraconf/dspam/webfrontend/dspam /var/www/bearmail/antispam/
#  cp -a $BEARMAIL_DIR/extraconf/dspam/webfrontend/dspam-templates /var/www/bearmail/antispam/
#  chmod -R 755 /var/www/bearmail
#  chown -R dspam:dspam /var/www/bearmail
#  a2enmod suexec
#fi
#echo "Conf for Dspam WebFrontend .. done"

## Rondcube
#
#if [ ! -d $BEARMAIL_OLDCONF/roundcube ] ; then
#  mkdir -p $BEARMAIL_OLDCONF/roundcube
#  mv /etc/roundcube/main.inc.php $BEARMAIL_OLDCONF/roundcube/main.inc.php_original
#  cp $BEARMAIL_DIR/extraconf/roundcube_main.inc.php /etc/roundcube/main.inc.php
#fi
#echo "Conf for RoundCube .. done"


