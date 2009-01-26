#!/usr/bin/perl -wT

package BearMail::Web::Address::List;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('address_list.html');
    return $tmpl->output;
}

1;
