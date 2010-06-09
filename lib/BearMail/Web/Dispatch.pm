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

# BearMail mod_perl dispatcher - part of bearmail
#
# This module has no run_mode (:RunMode attribute) on purpose.

package BearMail::Web::Dispatch;
use base 'CGI::Application::Dispatch';
use strict;
use warnings;
#no warnings 'redefine';

sub dispatch_args {
  my $conf = $ENV{BEARMAIL_CONF} || '/etc/bearmail/bearmail.conf';

  return {
    prefix      => 'BearMail::Web',
    default     => 'login',
    args_to_new => {
        PARAMS      => { cfg_file => $conf }
    },
    table       => [
            ':app'     => {},
            ':app/:rm' => {},
        ],
  };
}
1;
