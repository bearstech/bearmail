#!/usr/bin/perl -wT

package BearMail::Web::Address::New;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('address_new.html');
    return $tmpl->output;
}

1;
