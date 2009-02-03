#!/usr/bin/perl -wT

package BearMail::Web::Domain::List;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('domain_list.html');
    return $tmpl->output;
}

1;