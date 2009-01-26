#!/usr/bin/perl -wT

package BearMail::Web::Reminder;
use strict;
use base 'BearMail::Web';

sub reminder : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('reminder.html');
    return $tmpl->output;
}

1;
