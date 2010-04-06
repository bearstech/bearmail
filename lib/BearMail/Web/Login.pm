package BearMail::Web::Login;

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

# Login webui page - part of bearmail

use strict;
use base 'BearMail::Web';
use Digest::MD5 qw(md5_hex);

sub login : StartRunMode {
    my $self = shift;

    my $q = $self->query;
    my $email = $q->param('email') || '';
    my $pass  = $q->param('password') || '';

    # We can't proceed with login if we don't have both params
    return $self->login_page() if $email eq '' or $pass eq '';

    # FIXME: need to handle simple user login too

    # First check simple domain login
    my $domain_pass = $self->{b}->get_postmasters()->{$email};
    return $self->login_ok($email, 'postmaster')
        if defined $domain_pass and $domain_pass eq md5_hex($pass);

    # Then try master password, but only on amdin|root logins to prevent
    # users discovering domain/master password collisiona by accident
    my $master_pass = $self->cfg('master_password');
    return $self->login_ok($email, 'admin')
        if defined $master_pass and $master_pass eq md5_hex($pass) and
           $email =~ /^(admin(inistrator)?|root)$/i;

    if((defined $domain_pass) or ($email =~ /^(admin(inistrator)?|root)$/i)) {
      return $self->login_page("password");
    } else {
      return $self->login_page("email");
    }
}

sub login_page {
    my $self = shift;
    my $error = shift;

    my $tmpl = $self->load_tmpl('login.html');
    $tmpl->param("error_".$error => 1) if $error;

    return $tmpl->output;
}

sub login_ok {
    my $self = shift;
    my ($user, $level) = @_;

    # Store authentified user in session (privileges should be checked at
    # every operation instead of being stored in s{level}, FIXME)
    $self->session->param('user', $user);
    $self->session->param('level', $level);

    # Redirect to the original page the user intended to go, or some fitting
    # default page depending on user privileges.
    my %default = (
      user       => 'address_edit',
      postmaster => 'address_list',
      admin      => 'domain_list',
    );
    my $intent = $self->session->param('intent') || $default{$level};
    return $self->redirect($self->url($intent));
}

1;
