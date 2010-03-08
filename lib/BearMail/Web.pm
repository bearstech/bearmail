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

package BearMail::Web;
use strict;
use base 'CGI::Application';
use CGI::Application::Plugin::AutoRunmode;
use CGI::Application::Plugin::Session;
use CGI::Application::Plugin::Redirect;
use CGI::Application::Plugin::ConfigAuto qw/cfg_file cfg/;
use CGI::Application::Plugin::DebugScreen;  # DebugScreen is done when $ENV{CGI_APP_DEBUG} is set
use BearMail::Backend;
use Data::Dumper;



sub setup {
    my $self = shift;

    # CGI.pm sets a default ISO-8859-1 charset in the Content-Type header.
    # We prefer omitting it and let browsers honor the <meta> in page <header>'s.
    $self->query->charset('');

    # Give some interesting characteristics to our HTML::Template's
    $self->add_callback('load_tmpl', \&_my_load_tmpl);

    # Instanciate the backend
    $self->{b} = BearMail::Backend::backend($self->cfg('backend'));
}

sub cgiapp_init {
    my $self = shift;

    $self->session_config (
      COOKIE_PARAMS => { -name => 'bearmail', -expires => '+8days' },
      SEND_COOKIE         => 1,
    );
    CGI::Session->name('bearmail');
}

sub cgiapp_prerun {
    my $self = shift;

    my $rm   = $self->get_current_runmode;
    my $user = $self->session->param('user');

    if ((not $rm  =~ /login|reminder/) and (not defined $user)) {
      $self->session->param('intent', $ENV{PATH_INFO}."/".$rm); #FIXME: should be something like path/runmode?args i guess. or should we drop the runmode ?
      return $self->redirect($self->url('login'));
    }
}

sub url {
    my ($self, $path) = @_;

    my $url = $self->query->url(-absolute => 1).'/'.($path || '');
    $url =~ s:/+:/:g;
    return $url;
}

sub _my_load_tmpl {
    my ($self, $ht_params, $tmpl_params, $tmpl_file) = @_;

    $ht_params ||= {};

    # Fix template links (generate proper absolute hrefs).
    # The convention is to use href="#/module_name/mode/..." in templates.
    $ht_params->{'filter'} = sub { ${$_[0]} =~ s:"#/(.+?)":'"'.$self->url($1).'"':eg };

    # As a safe default, escape all parameters. If we have to push something
    # which is rather URL, JS or none, we'll handle it as an exception.
    $ht_params->{'default_escape'} = 'HTML';
}

1;
