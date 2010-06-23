package BearMail::Backend::Files;

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

use Digest::MD5 qw(md5 md5_hex md5_base64);
use Carp;
use Exporter 'import';
use Fcntl ':flock';
use File::stat ();
@EXPORT_OK = qw(get_accounts new commit apply get_domains get_users get_user set_domain set_address add_domain add_address del_domain del_address get_postmasters get_postmaster_domains); 

# Implement mail-platform configuration via a plain file storage schema.
#
# All informations is stored in a 'mailmap' (default: /etc/bearmail/mailmap)
# which is a simple passwd-style text file, with one entry per line and fields
# separated by semi-colons. An entry is a mail account definition (address,
# password, routing).
#
# FIXME: there is no locking mechanism. Between the time where mailmap is read
# (at object construction time) and written again (via the commit() method,
# nobody should be hable to access (read and write) the mailmap. This should
# be fixed easily since this backend is meant to be used with an 'instant'
# read/modify/write cycle (from web or cli).

# 2009-12-09 vcaron@bearstech.com : this is a simple API over the existing code
# from 'bearmail-update' which has been stashed in the 'Implementation' part
# of this package.


#
### Exported methods
#

sub new() {
  my ($class, %args) = @_;

  croak("Please set mailmap's path in your bearmail.conf configuration file") if not defined $args{'mailmap'};

  my $self = {
    records => {},
    by_domain => {},
    domains => [],
    mailmap => $args{'mailmap'},
    debug => 0 + defined $args{'debug'},
    mtime => 0, #FIXME
    files => {},
    allowed => {
      'addr_normal pw_md5 local'           => 'regular_account',
      'addr_normal pw_none aliases'        => 'alias',
      'addr_normal pw_none pipe'           => 'pipe',
      'addr_catchall pw_none aliases'      => 'catchall',
      'addr_catchall pw_none domain_alias' => 'domain_alias',
    },
  };


  bless $self, $class;

  $self->_read_mailmap();
  return $self;
}

sub commit() {
  my ($self) = @_;
  $self->_sort_mailmap();
  $self->_write_mailmap();
}

sub apply() {
  my ($self) = @_;
  $self->_sort_mailmap();
  $self->_prepare_postfix_conf();
  $self->_prepare_dovecot_conf();
  $self->_write_conf();
}

sub get_domains() {
  my ($self) = @_;
  return @{$self->{domains}};
}

sub get_users() {
  my ($self, $domain) = @_;
  return @{$self->{by_domain}{$domain}};
}

sub get_user() {
  my ($self, $user) = @_;
  return $self->{records}{lc $user};
}

sub set_domain() {
}
sub set_address() {
}

sub add_domain() {
  my ($self, $domain, $postmaster, $password) = @_;

  if(exists($self->{by_domain}->{$domain})) {
    carp "Domain $domain already exist !";
    return 0;
  }

  if($postmaster eq "postmaster@".$domain) {
    $self->add_address($postmaster, $password, "local");
  } else {
    $self->add_address("postmaster@".$domain, '', $postmaster);
  }
}

sub add_address() {
  my ($self, $address, $password, $target) = @_;
  my @types;
  $password = md5_hex($password)
    if((not $password =~ /^[0-9a-f]{32}$/) and ($target eq "local"));

  push @types, $self->_check_field("address", $address);
  push @types, $self->_check_field("password", $password);
  push @types, $self->_check_field("target", $target);

  if(!exists($self->{allowed}{"@types"})) {
    carp "Bad configuration\n";
    return 0;
  } else {
    $self->{records}->{"$address"} = { 
              address => $address,
              password => $password,
              target => $target
    }; 
  }
}

sub del_domain() {
  my ($self, $domain) = @_;
  if(scalar(@{$self->{by_domain}->{$domain}}) le 1) {
    delete($self->{records}->{"postmaster\@$domain"});
  } else {
    carp "There are remaining email addresses for this domain !\n";
    carp "Delete them first !\n";
  }
}

sub del_address() {
  my ($self, $address) = @_;
  delete($self->{records}->{"$address"});
}

sub get_postmasters() {
  my ($self) = @_;
  my %npostmasters;
  foreach(keys(%{$self->{postmasters}})) {
    $npostmasters{$_} = $self->{postmasters}->{$_}->{password};
  }
#my %npostmasters = map { $_ => $postmasters{$_}->{password} } %postmasters;
  return \%npostmasters;
}

sub get_postmaster_domains() {
  my ($self, $user) = @_;
  my @hashed;
  push(@hashed, { name => $_ }) foreach @{$self->{postmasters}->{$user}->{domains}};
  return @hashed;
}



#
### Implementation (non-exported methods)
#


# Read a simple "mailmap" configuration file, where:
#  - empty lines are ignored
#  - lines beginning with a '#' are ignored
#  - all other lines are counted as a 'record'.
#
# A record is ':'-delimited field list, with currently in this order:
#  - a (source) email 'adresss' (*@domain.com for catch-all)
#  - a MD5-hashed 'password' (128bits hexa)
#  - a 'target' (local delivery, aliases, domain alias, program)
#
sub _read_mailmap {
  my ($self) = @_;

#FIXME  return if defined($self->{records}); # Parse mailmap only once
  open(MAILMAP, "<$self->{mailmap}") or croak "$self->{mailmap}: $!";
  flock(MAILMAP, LOCK_NB);
  $self->{mtime} = File::stat::stat($self->{mailmap})->mtime;

  while(<MAILMAP>) {
    chomp;
    next if /^$/ or /^#/;  # Ignore empty lines and comments

    my @fields = split /:/;
    croak "got ".scalar(@fields)." fields, expected 3" if @fields != 3;

    my %rec;
    my @types;
    foreach ('address', 'password', 'target') {
      my $field = shift @fields;
      push @types, $self->_check_field($_, $field);
      $rec{$_} = $field;
    }

    my $type = $self->{allowed}->{"@types"};
    croak "unsupported configuration (@types)" if !defined $type;

    # Users are key'ed by lowercase address (must be unique)
    $self->{records}->{lc $rec{'address'}} = \%rec;
  }

  flock(MAILMAP, LOCK_UN);
  close(MAILMAP);
  $self->_sort_mailmap();
}

sub _write_mailmap {
  my ($self) = @_;

  my $m = File::stat::stat($self->{mailmap})->mtime;
  if($m ne $self->{mtime}) {
    warn "File was modified by a non-locking friendly program since last parsing, won't merge";
    return 0;
  }

  open(MAILMAP, ">$self->{mailmap}") or croak "$self->{mailmap}: $!";
  flock(MAILMAP, LOCK_EX | LOCK_NB)
    or croak "Can't get exclusive lock on $mailmap: $!";

  foreach(keys %{$self->{records}}) {
    print MAILMAP $self->{records}->{$_}->{"address"}, ":", $self->{records}->{$_}->{"password"},
       ":", $self->{records}->{$_}->{"target"}, "\n"
       or croak("Can't write mailmap $self->{mailmap}: $!");
  }

  flock(MAILMAP, LOCK_UN);
  close(MAILMAP);
}

# Field constraints. See https://scratch.bearstech.com/trac/ticket/34
#
sub _check_field {
  my ($self, $key, $val) = @_;

  if ($key eq 'address') {
    my $addr = $val;
    $addr =~ s/^\*@/x@/;  # Allow catch-all
    croak "malformed address: $val" if not $self->_check_address($addr);
    croak "non-unique address: $val" if defined $records{lc $val};

    return $val =~ m/^\*@/ ? 'addr_catchall' : 'addr_normal';
  }
  elsif ($key eq 'password') {
    return 'pw_none' if $val eq '';  # Non-login account
    croak "malformed password hash: $val" if not $val =~ /^[0-9a-f]{32}$/;

    return 'pw_md5';
  }
  elsif ($key eq 'target') {
    return 'local' if $val eq 'local';  # Regular local IMAP account
    return 'pipe'  if $val =~ /^\|/;    # Pipe to a program (path unchecked)
    my $type = ($val =~ s/^\*@/x@/) ?   # Allow domain aliases (a single *@-like address)
      'domain_alias' : 'aliases';
    my @aliases = split(/,/, $val);
    croak "can ony alias one domain at once" if @aliases > 1 && $type eq 'domain_alias';

    foreach (@aliases) {
      croak "malformed address: $_" if not $self->_check_address($_);
    }
    return $type;
  }
}

# Email address basic check. It's a (small) RFC822 subset.
#
sub _check_address {
  my ($self, $address) = @_;
  return $address =~ /^[A-Za-z0-9\-\._]+@[A-Za-z0-9\-\.]+$/;
}

# Conf generators will have a prettier output if they sord records
# by domains, then by local part. Fill in @domains also.
#
sub _sort_mailmap {
  my ($self) = @_;

  #FIXME ok ?
  # Reset data structures before sorting (to be able to re-sort on modifications)
  $self->{by_domain} = ();
  $self->{domains} = [];

  foreach(keys %{$self->{records}}) {
    /^([^@]+)@([^@]+)$/;
    my ($local, $domain) = ($1, $2);

    $self->{by_domain}->{$domain} = [] if !defined $self->{by_domain}->{$domain};
    $self->{records}->{$_}->{'address_local'} = $local;
    push @{$self->{by_domain}->{$domain}}, $self->{records}->{$_};
  }

  foreach my $dom (keys %{$self->{by_domain}}) {
    @{$self->{by_domain}->{$dom}} = sort { $a->{'address'} cmp $b->{'address'} } @{$self->{by_domain}->{$dom}};
    foreach(@{$self->{by_domain}->{$dom}}) {
      next if ($_->{address_local} ne 'postmaster');
      if($_->{password}) {
        if(exists($self->{postmasters}->{$_->{address}})) {
          push(@{$self->{postmasters}->{$_->{address}}->{domains}}, $dom);
        } else {
          $self->{postmasters}->{$_->{address}} = { password => $_->{password}, domains => [ $dom ] };
        }
      } else {
        foreach(split(',', $_->{target})) {
          if(exists($self->{records}->{$_})) {
            next unless defined($self->{records}->{$_}->{password}); # FIXME: keep ? Security purpose: don't keep postmasters without passwords
            if(exists($self->{postmasters}->{$_})) {
              push(@{$self->{postmasters}->{$_}->{domains}}, $dom);
            } else {
              $self->{postmasters}->{$_} = { password => $self->{records}->{$_}->{password}, domains => [ $dom ] };
            }
          }
        }
      }
    }
  }
  @{$self->{domains}} = sort keys %{$self->{by_domain}};
}

# Postfix conf files, expected settings in main.cf:
#   virtual_mailbox_domains   = hash:/etc/bearmail/postfix/virtual_domains
#   virtual_mailbox_mailboxes = hash:/etc/bearmail/postfix/virtual_mailboxes
#   virtual_alias_maps        = hash:/etc/bearmail/postfix/virtual_aliases
#   alias_maps                = hash:/etc/aliases,
#                               hash:/etc/bearmail/postfix/virtual_pipes
sub _prepare_postfix_conf {
  my ($self) = @_;
  my $virtual_domains   = join("\n", map { "$_ dummy" } @{$self->{domains}});
  my $virtual_mailboxes = '';
  my $virtual_aliases   = '';
  my $virtual_pipes     = '';

  foreach my $d (@{$self->{domains}}) {
    my $comment = $virtual_mailboxes eq '' ? "" : "\n";
    $comment .= "# $d\n#\n";
    $virtual_mailboxes .= $comment;
    $virtual_aliases   .= $comment;

    foreach (@{$self->{by_domain}->{$d}}) {
      my $address = $_->{'address'};
      my $target  = $_->{'target'};
      $address =~ s/^\*//;    # Fix catch-all syntax
      $target  =~ s/\*@/@/g;  # Fix domain aliasing syntax

      if ($target eq 'local') {
        $virtual_mailboxes .= "$address $d/$_->{'address_local'}/Maildir/\n";
        $virtual_aliases   .= "$address $address\n";
      }
      elsif ($target =~ /^\|/) {
        my $alias = "$_->{'address_local'}-$d-pipe";
        $virtual_aliases .= "$address $alias\n";
        $virtual_pipes   .= "$alias $target\n";
      }
      else {
        $virtual_aliases .= "$address $target\n";
      }
    }
  }

  $self->{files}->{'/etc/bearmail/postfix/virtual_domains'}   = $virtual_domains;
  $self->{files}->{'/etc/bearmail/postfix/virtual_mailboxes'} = $virtual_mailboxes;
  $self->{files}->{'/etc/bearmail/postfix/virtual_aliases'}   = $virtual_aliases;
  $self->{files}->{'/etc/bearmail/postfix/virtual_pipes'}     = $virtual_pipes;
}

# Dovecot auth files, expected settings in dovecot.cf:
#   passdb passwd-file {
#     args = /etc/dovecot/passwd
#   }
#   userdb passwd-file {
#     args = /etc/dovecot/passwd
#   }
#
sub _prepare_dovecot_conf {
  my ($self) = @_;
  my $passwd = '';

  foreach my $d (@{$self->{domains}}) {

    foreach (@{$self->{by_domain}->{$d}}) {
      my $password = $_->{'password'};
      next if $password eq '';

      my $address  = $_->{'address'};
      my $local    = $_->{'address_local'};
      $passwd .= "$address:{PLAIN-MD5}$password:bearmail:bearmail::/var/spool/bearmail/$d/${local}::\n";
    }
  }
  $self->{files}->{"/etc/bearmail/dovecot/passwd"} = $passwd;
}

sub _write_conf {
  my ($self) = @_;
  my $header = "# Generated by BearMail::Backend::Files.\n# Please edit $mailmap instead of this file.\n\n";

  foreach (sort keys %{$self->{files}}) {
    if (!$debug) {
      open(CONF, ">$_") or croak "$_: $!";
      select CONF;
    } else {
      print "--\n-- $_\n--\n";
    }

    print $header.$self->{files}->{$_}."\n";

    if (!$debug) {
      close(CONF);
      `postmap $_` if m:/etc/bearmail/postfix/:;
    }
  }
  select STDOUT;
}

1;
