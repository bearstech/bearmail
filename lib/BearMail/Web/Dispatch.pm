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

package BearMail::Web::Dispatch;
use base 'CGI::Application::Dispatch';
use Config::Auto;
use strict;
use warnings;
use CGI::Carp qw/fatalsToBrowser/; 
no warnings 'redefine';

sub dispatch_args {
  my $bearmail_conf = $ENV{'BEARMAIL_CONF'};
  $bearmail_conf ||= "/etc/bearmail/bearmail.conf";

  my $config = Config::Auto::parse("$bearmail_conf");

  return {
    prefix      => 'BearMail::Web',
    default => 'login',
    args_to_new => {
        TMPL_PATH => $config->{'bearmail_tmpl_path'},
        PARAMS    => {
            cfg_file => "$bearmail_conf",
        }
    },
    #debug => 1,
    table       => [
            ':app'     => {},
            ':app/:rm' => {},
        ],
  };
}
1;
