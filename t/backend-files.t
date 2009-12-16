#!/usr/bin/env perl

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

use Test::More tests => 9;

use lib '../lib';
use BearMail::Backend::Files;
use FreezeThaw qw(cmpStr);

my $mailmap = '../conf/mailmap';

my $b = BearMail::Backend::Files->new( debug => 0, mailmap => $mailmap );

ok( defined $b, 'new() returned something' );
ok( $b->isa('BearMail::Backend::Files'), 'and it\'s the right class' );
is( $b->get_domains(), 2, 'correct number of domains');
is( $b->get_users('company.com'), 5, 'correct number of company.com domain users');
is( $b->get_users('other.com'), 1, 'correct number of other.com domain users');
is( ${$b->get_user('fortune@company.com')}{'target'}, '|/bin/fortune', 'correct target of fortune@company.com user' );
is( ${$b->get_user('bob@company.com')}{'password'}, '9a8ad92c50cae39aa2c5604fd0ab6d8c', 'correct bob@company.com password' );
is( cmpStr($b->get_postmasters(), { 'bob@company.com' => '9a8ad92c50cae39aa2c5604fd0ab6d8c' }), 0,  'correct postmasters list' );
is( cmpStr($b->get_postmaster_domains('bob@company.com'), { name => 'company.com' }), 0, 'correct controlled domains for bob@company.com' );
