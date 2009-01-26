#!/usr/bin/perl -wT

package BearMail::Web::Login;
use strict;
use base 'BearMail::Web';

sub login : StartRunMode {
    my $self = shift;

    my $q = $self->query;
    my $email = $q->param('email') || '';
    my $pass  = $q->param('password') || '';

    if ($email eq 'admin' &&
        $pass eq 'admin')
    {
        $self->session->param('user', 'admin');
        my $intent = $self->session->param('intent') || 'address_list';
warn "Login successful, redirecting to intent='$intent'";
        return $self->redirect($self->url($intent));
    }

    my $tmpl = $self->load_tmpl('login.html');
    return $tmpl->output;
}

1;
