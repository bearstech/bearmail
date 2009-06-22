#!/usr/bin/perl

#
# DSPAM AUTH EXTENTION
# COPYRIGHT (C) 2007 Bearstech : lhaond@bearstech.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2
# of the License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

use CGI::Session;
use Digest::MD5 'md5_hex';

sub check_pwd($$) {
        my $user=shift;
	my $passwd=shift;
        open PASSWD, "< ".$CONFIG{'PASSWD_FILE'};
	while (<PASSWD>) {
		$line = $_;
		$line =~ s/\n|\r//;
		# valid_email_address:md5(pwd):local
		if ($line =~/^([_a-z0-9\.\-]+@[a-z0-9\.]+[a-z0-9\.\-]+\.[a-z0-9]{2,}):([0-9a-f]+):local$/) {
			if ($user eq $1 && md5_hex($passwd) eq $2 ) {
				close PASSWD;
				return 1;
			}
		}
	}
	close PASSWD;
	return 0;
}

sub check_logged_in() {
	my $username=$session->param('username');
	if ($username =~ /^[_a-z0-9\.\-]+@[a-z0-9\.]+[a-z0-9\.\-]+\.[a-z0-9]{2,}/ ) {
		$ENV{'REMOTE_USER'}=$username;	
	} else {
		$ENV{'REMOTE_USER'}='';
		$DATA{'WEB_ROOT'} = $CONFIG{'WEB_ROOT'};
		print "Expires: now\n";
  		print "Pragma: no-cache\n";
  		print "Cache-control: no-cache\n";
  		print "Content-type: text/html\n\n";
		open(FILE, "<$CONFIG{'TEMPLATES'}/nav_login.html");
		while(<FILE>) {
			s/\$CGI\$/$CONFIG{'ME'}/g;
			s/\$([A-Z0-9_]*)\$/$DATA{$1}/g;
			print;
		}
		close(FILE);
		exit(0);
	}
}

# redirect to default index if called directly
if ($ENV{'REQUEST_URI'} =~ /auth.cgi/) {
	print "Expires: now\n";
	print "Pragma: no-cache\n";
	print "Cache-control: no-cache\n";
	print "Location: ./\n\n";
	exit(0);
}

# Initialize Session
$session = new CGI::Session("driver:File", undef, {Directory=>'/tmp'});
$session->expire('+2h');

# send only cookie headers
my $cookie = $session->header();
$cookie =~ /^(Set-Cookie:[^\n]+)/g;
print $1."\n";

if ( $FORM{'action'} eq 'login' ) {
	my $checkpwd = &check_pwd($FORM{'login_user'},$FORM{'login_password'});
	if ($checkpwd==1) {
		$session->param('username',$FORM{'login_user'});
	} else {
		$session->param('username','');
		$DATA{'MESSAGE'}='Unknown user or bad password !';

	}
}

if ( $FORM{'action'} eq 'logout') {
		$session->param('username','');
		$DATA{'MESSAGE'}='';
}

check_logged_in();
