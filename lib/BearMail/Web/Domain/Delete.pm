#!/usr/bin/perl -wT

package BearMail::Web::Domain::Delete;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('domain_delete.html');
    return $tmpl->output;
}

1;
