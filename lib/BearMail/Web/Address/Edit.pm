#!/usr/bin/perl -wT

package BearMail::Web::Address::Edit;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $q = $self->query();
    my $address = $q->param('address');

    my $be = BearMail::Backend::backend();
    my $user = $be->get_user($address);

    my $type = '';
    if    ($user->{'target'} eq 'local') { $type = 'regular'; }
    elsif ($user->{'target'} =~ /^\|/)   { $type = 'holiday'; }
    elsif ($user->{'target'} =~ /@/)     { $type = 'alias';   }
    else                                 { $type = '?'; }

    my $tmpl = $self->load_tmpl('address_edit.html');
    $tmpl->param(
      ADDRESS      => $address,
      ALIASES      => ($type eq 'alias') ? $user->{'target'} : '',
      TYPE_REGULAR => ($type eq 'regular'),
      TYPE_ALIAS   => ($type eq 'alias'),
      TYPE_HOLIDAY => ($type eq 'holiday'),
    );
    return $tmpl->output;
}

sub radio {
}

1;
