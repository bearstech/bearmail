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

    my $b = BearMail::Backend::backend();

    if(exists(%{$self->cfg('admins')}->{$email})
       and %{$self->cfg('admins')}->{$email} eq md5_hex($pass)) {

        $self->session->param('user', $email);
        $self->session->param('level', 'admin');
        my $intent = $self->session->param('intent') || 'domain_list';
        warn "Login successful, redirecting to intent='$intent'";
        return $self->redirect($self->url($intent));

    } elsif(exists(%{$b->get_postmasters()}->{$email})
            and %{$b->get_postmasters()}->{$email} eq md5_hex($pass)) {

        $self->session->param('user', $email);
        $self->session->param('level', 'postmaster');
        my $intent = $self->session->param('intent') || 'domain_list';
        warn "Login successful, redirecting to intent='$intent'";
        return $self->redirect($self->url($intent));
    }

    my $tmpl = $self->load_tmpl('login.html');
    return $tmpl->output;
}

1;
