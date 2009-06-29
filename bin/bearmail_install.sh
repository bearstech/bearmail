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
# define hostname for main domain
sed -e "s:bearmail.tld:$HOSTNAME:g" -i $BEARMAIL_CONF/postfix/main.cf
if [ ! -f "$BEARMAIL_OLDCONF/mailname" ] ; then
  cp /etc/mailname $BEARMAIL_OLDCONF/mailname_original
fi
echo "$HOSTNAME" > /etc/mailname
# create helo check / client check
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


## adding accounts
# create mailmap
if  [ ! -e $BEARMAIL_DIR/mailmap ] ; then
  # make a random password for postmaster
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
EOF
#  echo "Adding $MY_V_FQDN domain .. done"
  echo "######################################################################"
  echo "# Your password for postmaster@$MY_V_FQDN"
  echo "#    is : $MY_PASSWD"
  echo "# Do never delete this acocunt.
  echo "# You still can change the password if needed."
  echo "######################################################################"
  $BEARMAIL_BIN_DIR/bearmail-update
fi


## Setting $VAR to bearmail.conf
#
cat > $BEARMAIL_CONF/bearmail.conf << EOF
## Configuration for bearmail
#

############# DO NOT EDIT UNDER THIS LINE #################
VMAIL_USER=$VMAIL_USER
VMAIL_DIR="$VMAIL_DIR"
VMAIL_GUID="$VMAIL_GUID"
POSTFIX_CONF_DIR="$POSTFIX_CONF_DIR"
POSTFIX_INIT="$POSTFIX_INIT"
DOVECOT_CONF_DIR="$DOVECOT_CONF_DIR"
DOVECOT_LIB_DIR="$DOVECOT_LIB_DIR"
DOVECOT_INIT="$DOVECOT_INIT"
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
