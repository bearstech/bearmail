# Copyright (C) 2011 Bearstech - http://bearstech.com/
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

package BearMail::Config;

=pod

=head1 NAME

BearMail::Config - Simple bearmail.cfg config file handler


=head1 SYNOPSIS

    use BearMail::Config;
    
    my $conf = BearMail::Config->new();
    $conf->load('test.cfg') or die;
    my $tmpl_path = $conf->param('template_path') || '/usr/share/template';


=head1 DESCRIPTION

C<BearMail::Config> ... FIXME


=head1 CONFIGURATION FILE SYNTAX

The format is based on C<Config::Tiny> parser and is a INI-like one. Right now
it only uses "root-level" parameter and thus no sections : it is a simple list
of "key = value" pairs.

The parameters, their values and meanings are self-documented in the template
configuration provided with the BearMail distribution. Meanwhile this module
tries to check and warn the user for every parameter or value which don't
match the documentation.


=head1 METHODS

=head2 new

The constructor C<new> creates and returns an empty C<BearMail::Config> object.
You have to call its C<load> method next.

=head2 load $filename

Reads a config file. When an error occurs, this method carps and return a
zero (false) value.

If C<load> succeeds, you can use the C<param> method to access the parameter
values.

=head2 param $key

Return the parsed value for the $key parameter, C<undef> if not defined.

=head1 SUPPORT

Bugs should be reported via the Trac tool at

L<http://forge.bearstech.com/trac/newticket>

=head1 AUTHORS

=head1 SEE ALSO

L<Config::Tiny>, L<BearMail>

=head1 COPYRIGHT

Copyright (C) 2010 Bearstech - http://bearstech.com/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut


use strict;
use Config::Tiny;


sub new {
    my $class = shift @_;
    my $self  = {};

    bless $self, $class;
}

sub load {
    my ($filename) = @_;
    $filename = '/etc/bearmail/bearmail.cfg' if not defined $filename;

    carp "BearMail::Config::load() not implemented";
    return 0;
}

sub param {
    my ($name) = @_;

    carp "BearMail::Config::param() not implemented";
    return undef;
}

# I don't think we need a save(). The global configuration file is
# for the adminsys and deployment needs.
# 
# Tunable for postmasters should implemented in something like BearMail::Settings
# backed by a database.
