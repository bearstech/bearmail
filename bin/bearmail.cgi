#!/usr/bin/perl -wT -I../lib

use strict;
use CGI::Carp qw/fatalsToBrowser/; 
use CGI::Application::Dispatch;
use Cwd;

my $bearmail = $ENV{'BEARMAIL'} || cwd().'/..';

CGI::Application::Dispatch->dispatch(
    prefix      => 'BearMail::Web',
    default     => 'login',
    args_to_new => {
        TMPL_PATH => "$bearmail/template/",
    },
);
