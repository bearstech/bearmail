package BearMail::Web::Address::Edit;

# Copyright (C) 2009 Bearstech - http://bearstech.com/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Address edition webui page - part of bearmail

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
