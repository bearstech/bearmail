#!/usr/bin/perl -wT

# Address listing webui page - part of bearmail
# # # Copyright (C) 2009 Bearstech - http://bearstech.com/
# # #
# # # This program is free software: you can redistribute it and/or modify
# # # it under the terms of the GNU General Public License as published by
# # # the Free Software Foundation, either version 3 of the License, or
# # # (at your option) any later version.
# # #
# # # This program is distributed in the hope that it will be useful,
# # # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # # GNU General Public License for more details.
# # #
# # # You should have received a copy of the GNU General Public License
# # # along with this program.  If not, see <http://www.gnu.org/licenses/>.
# #
#

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
    $tmpl->param(DOMAIN => $domain);
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
