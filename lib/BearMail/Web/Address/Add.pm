package BearMail::Web::Address::Add;

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

# Adress creation webui page - part of bearmail

use strict;
use base 'BearMail::Web';

sub default : StartRunMode {
    my $self = shift;
    my $q = $self->query();
    my $backend = $self->{b};

    $q->param('email') =~ /(.*)@(.*)/;  
    my $domain = $2;

    my $email = $q->param('email');
    my $password = $q->param('password');
    my $target = $q->param('type');
    if($target eq 'alias') {  
      $target = $q->param('aliases');
      $target =~ s/\s//;
    }

    if(grep(/^$domain$/, $backend->get_domains())) {
      $backend->add_address($email, $password, $target) 
        or error($self, "BAD_CONFIGURATION");
      $backend->commit()
        or error($self, "COMMIT");
      return $self->redirect($self->url('address_list?domain='.$domain));
    } else {
      error($self, "DOMAIN_DOESNT_EXIST");
    }
}

sub error {
    my ($self, $error) = @_;
    my $tmpl = $self->load_tmpl('address_new.html');
    $tmpl->param(CURRENT_IS_ADDRESS_NEW => 1);
    $tmpl->param("ERROR_$error" => 1);
    return $tmpl->output;
}

1;
