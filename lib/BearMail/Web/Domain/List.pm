#!/usr/bin/perl -wT

package BearMail::Web::Domain::List;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $be = BearMail::Backend::backend();
    my @domains = $be->get_domains();

    my $n = 0;
    foreach (@domains) {
      $_->{stripe} = ($n++ % 2) ? 'odd' : 'even';
      $_->{info}   = '';
    }

    my $tmpl = $self->load_tmpl('domain_list.html');
    $tmpl->param(DOMAINS => \@domains);
    return $tmpl->output;
}

1;
