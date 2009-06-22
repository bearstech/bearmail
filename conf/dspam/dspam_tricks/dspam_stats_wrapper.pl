#!/usr/bin/perl -w

#
# This is a wrapper to dspam_stats to retrieve stats only for virtual users
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


use strict;
use vars qw { %CONFIG %DATA %FORM $MAILBOX $CURRENT_USER $USER $TMPFILE};

require "/etc/dspam/webfrontend.conf";

my @users_stats;
open PASSWD, "< ".$CONFIG{'PASSWD_FILE'};
while (<PASSWD>) {
        my $line = $_;
	$line =~ s/\n|\r//;
	# valid_email_address:md5(pwd):local
	if ($line =~/^([_a-z0-9\.\-]+@[a-z0-9\.]+[a-z0-9\.\-]+\.[a-z0-9]{2,}):([0-9a-f]+):local$/) {
		push (@users_stats,$1);
	}
}
close PASSWD;

system $CONFIG{'DSPAM_BIN'}."/dspam_stats ".join(' ',@ARGV).' '.join(' ',@users_stats);
