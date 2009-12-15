#!/usr/bin/perl -wT -I../lib

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

# bearmail.cgi - part of bearmail

use strict;
use CGI::Carp qw/fatalsToBrowser/; 
use CGI::Application::Dispatch;
use Cwd;

my $bearmail = $ENV{'BEARMAIL'} || cwd().'/..';

CGI::Application::Dispatch->dispatch(
    prefix      => 'BearMail::Web',
    default     => 'login',
    args_to_new => {
        TMPL_PATH => "$bearmail/template/",
    },
);
