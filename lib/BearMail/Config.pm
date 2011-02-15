package BearMail::Config;

=pod

=head1 NAME

BearMail::Config - Simple bearmail.cfg config file handler


=head1 SYNOPSIS

    use BearMail::Config;
    
    my $conf = BearMail::Config->new();
    $conf->read('test.cfg') or die;
    my $tmpl_path = $conf->{_}->{template_path} || '/usr/share/template';


=head1 DESCRIPTION

C<BearMail::Config> ... FIXME

This is a subclass of C<Config::Tiny>, it has (at least) the same API.


=head1 CONFIGURATION FILE SYNTAX

The format is based on C<Config::Tiny> parser and is a INI-like one.

The parameters, their values and meanings are self-documented in the template
configuration provided with the BearMail distribution. Meanwhile this module
tries to check and warn the user for every parameter or value which don't
match the documentation.


=head1 METHODS

=head2 new (params...)

The constructor C<new> creates and returns an empty C<BearMail::Config> object.
You must call its C<read> method next or explictly define a few root parameters
with a hashref:

    my $conf = BearMail::Config->new(
        backend => 'file',
        'template_path' => '/tmp'
    );

=head2 read $filename

Reads a config file. When an error occurs, this method carps and return a
zero (false) value.

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
use Carp;
use Config::Tiny;
use base qw(Config::Tiny);


sub new {
    my $class = shift @_;
    my $self  = $class->SUPER::new();

    bless $self, $class;
}

sub read {
    my ($filename) = @_;
    $filename = '/etc/bearmail/bearmail.cfg' if not defined $filename;

    carp "BearMail::Config::load() not implemented";
    # return $self->SUPER::read($filename);
}

# I don't think we need a write(). The global configuration file is
# for the adminsys and deployment needs.
# 
# Tunable for postmasters should be implemented in something like
# BearMail::Settings backed by a database.

1;
