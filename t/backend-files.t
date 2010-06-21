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
use File::Basename;

my $mailmap = dirname($0).'/../doc/examples/mailmap';

my $b = BearMail::Backend::Files->new( debug => 0, mailmap => $mailmap );

my $postmasters = {
          'postmaster@psychemusic.com' => 'ec54e458d83dbbddbf03170895df79bd',
          'postmaster@computeit.net' => '469bb8061b76aa02d311696a2f719714',
          'postmaster@freshnewz.com' => '1ae8a6e65b3b6c8e7bb5aa69783c7af9',
          'postmaster@freeyoursoft.org' => '1557458102a622baecbf0be2d0feb250',
          'postmaster@flyingbirds.fr' => '4b58eaf79f4203d3ad89d0a140310d3f',
          'postmaster@figueres.name' => 'c1297b00533db5bbc687eab9fd7900b6',
          'postmaster@bestbeers.be' => 'af3365411ed9d9b57a758c01e2419b9a'
};

ok( defined $b, 'new() returned something' );
ok( $b->isa('BearMail::Backend::Files'), 'and it\'s the right class' );
is( $b->get_domains(), 7, 'correct number of domains');
is( $b->get_users('flyingbirds.fr'), 11, 'correct number of flyingbirds.fr domain users');
is( $b->get_users('psychemusic.com'), 5, 'correct number of psychemusic.com domain users');
is( ${$b->get_user('fortunes@freshnewz.com')}{'target'}, '|/bin/fortune', 'correct target of fortunes@freshnewz.com user' );
is( ${$b->get_user('clara.fourcade@flyingbirds.fr')}{'password'}, '4b7318bdb1725959d3d8bba5b0ffae79', 'correct clara.fourcade@flyingbirds.fr password' );
is( cmpStr($b->get_postmasters(), $postmasters), 0,  'correct postmasters list' );
is( cmpStr($b->get_postmaster_domains('postmaster@bestbeers.be'), { name => 'bestbeers.be' }), 0, 'correct controlled domains for postmaster@bestbeers.be' );
