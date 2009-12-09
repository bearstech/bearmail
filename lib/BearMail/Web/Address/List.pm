#!/usr/bin/perl -wT

package BearMail::Web::Address::List;
use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $q = $self->query();
    my $domain = $q->param('domain');

    my $be = BearMail::Backend::backend();
    my @users = $be->get_users($domain);

    my $n = 0;
    my @addresses;
    push(@addresses, {
      stripe        => ($n++ % 2) ? 'odd' : 'even',
      address       => $_->{address},
      address_local => $_->{address_local},
      info          => address_info($_),
    }) foreach(@users);

    my $tmpl = $self->load_tmpl('address_list.html');
    $tmpl->param(ADDRESSES => \@addresses);
    return $tmpl->output;
}


sub address_info {
  my ($a) = @_;

  if ($a->{'target'} eq 'local') {
    return '';
  }

  if ($a->{'target'} ne '') {
    my @targets = split(/,/, $a->{'target'});
    my $target = $targets[0].(@targets > 1 ? ', [...]' : '');
    return "→ $target";
  }

  return '?';
}

1;
