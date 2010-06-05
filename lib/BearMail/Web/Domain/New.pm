package BearMail::Web::Domain::New;

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

# Domain creation webui page - part of bearmail

use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;

    my $tmpl = $self->load_tmpl('domain_new.html');
    $tmpl->param(CURRENT_IS_DOMAIN_NEW => 1);
    return $tmpl->output;
}

sub add : RunMode {
    my $self = shift;
    my $q = $self->query();
    my $backend = $self->{b};

    $backend->add_domain($q->param('domain'), 
      "postmaster@".$q->param('domain'), $q->param('password')); #FIXME
    $backend->commit();

    return $self->redirect($self->url('domain_list'));

}

1;
