package BearMail::Backend;

=pod

=head1 NAME

BearMail::Backend - Bearmail core class


=head1 SYNOPSIS

    use BearMail::Backend;
    use BearMail::Account;

    my $bb = BearMail::Backend->new();

    $bb->su('admin') || $bb->login('vcaron@bearstech.com', 'paaassw0rd');
    printf "Using '%s' account credentials\n", $bb->user();

    my $domain  = $bb->get_domain('bearstech.com');
    my @domains = $bb->get_domains(filter => '*bear*', range => [0, 9]);

    my $account = $bb->get_account
    my @account = $bb->get_accounts(filter => '*@bearstech.com', range => [30, 39]);

    my $account = new BearMail::Account(
        address => 'test@bearstech.com',
        target  => BearMail::Target->alias('vcaron@bearstech.com')
    );
    $bb->create_account($account);

    $account->password('n3w_paaass');
    $bb->update_account($account);
 
    $bb->delete_account('test@bearstech.com');
    $bb->delete_accounts(filter => 'vcaron@*');

    # $bb->log()
    # $bb->get_log(filter => , date_range => ?, limit => 100)


=head1 DESCRIPTION

C<BearMail::Backend> is at the core of the Bearmail infrastructure. It connects
to whatever 'backend' implements your email services and let you query and 
configure it.

For instance C<BearMail::Backend::FlatFiles> can configure a Postfix+Dovecot setup
with only the help of the filesystem. It works and scales very well up to
a few thousands accounts, and is adminsys friendly (you can version control
everything, trivially analyze, backup and fix things, etc.)

For large scale and stable behaviour wrt. massive end users hitting the web
interface, you might prefer the C<BearMail::Backend::SQL> interface.

TODO: point to a POD describing how to setup a Postfix+Dovecot setup (depends
on backend). Mention that the job is done via packaging in Debian.

=head2 Basic model

C<BearMail::Backend> is based on a simple model: it assumes that the whole
configuration of your email platform is a list of C<BearMail::Account>.

A C<BearMail::Account> in turn is a simple entry which ties a given email
adress to a specific C<BearMail::Target>. The target describes how email
received at the given address is handled : it can be stored in a mail
spool, re-sent to a list of other email addresses, handled by a third
party application (filter, vacation notifier), etc.

A C<BearMail::Account> can also optionnally carray data such as authentication
information (password).

Note that although the C<BearMail::Domain> module exists, domains cannot
be manipulated but only queried. You don't create a domain, you create a
C<BearMail::Account> with a new domain.

=head2 Security model

The backend must endorse a given identity which is of C<BearMail::Account>
type. Then every access to data is checked again this current identity
(see C<su>, C<login> and C<user>).

There are three level of autorization (roles) with specific capabilities:

=item * I<Admin> let you query and modify any information. This is a special
account whose identity is kept outside of regular accounts; for instance
as of now its password is stored in the main configuration file and can
only be modified by a sysadmin with proper server access. This is the only
role which may create accounts within new domains.

=item * I<Postmaster> let you query and modify whole domains (add, modify and
remove accounts within existing domains). A postmaster has a postmaster@domain
address or is an alias target of one or more postmaster@domain addresses. Eg.
if postmaster@foo.net and postmaster@bar.org have both an alias target of
chief@quux.com, then chief@quux.com is postmaster for the @foo.net and
@bar.org domains.

=item * I<User> is the lowest level. A user may query and modify (but not
create or delete) its own account. Such a end user may thus modify her
password, change her aliases, (un)configure an answering machine, etc.


=head1 METHODS

=head2 new

The constructor C<new> connects to an existing backend. It will first search
for a global configuration file (see C<BearMail::Config>) and use its
content to select a type of backend and optionnally configure it.

    my $bb = BearMail::Backend->new(
        config  => BearMail::Config->new->load('mymail.cfg'),
        backend => BearMail::Backend::FlatFiles->new
    );

Optionnal parameters are :

=item * config

C<BearMail::Backend> will create a C<BearMail::Config> object with no specific
parameters. If you want to provide a different configuration (eg. load the
configuration from a different file than the one hardwired in
C<BearMail::Config>), you may provide your own config object here.

=item * backend

Normally C<BearMail::Backend> will select and configure a backend using the
'backend' configuration parameter. If you have no configuration or want
to explicitly pass the backend, provide a C<BearMail::Backend> here.

=back

If the backend initialization failed for some reason, it will carp and
this constructor will return C<undef>.

Next step is to C<su> or C<login> to setup an autorization context.

=head2 su $address

Endorse some identity without authentication. The three levels of autorization
are specified via $address as (see 'Security Model' below):

=item I<Admin>: use the 'admin' string
=item I<Postmaster>: use an email adress whose LHS (left hand side) is postmaster@
=item I<User>: use any email adress whose LHS is I<not> postmaster@

Except for the 'admin' role, email addresses will be looked up to retrieve the
corresponding C<BearMail::Account>. If the look up fails, C<su> fails and
returns undef.

It is I<not> possible to call C<su> multiple time to switch identities, it
will fail and return undef (although any currently endorsed identity is
preserved).

Otherwise C<su> returns a C<BearMail::Account>.

Authentications is I<not> checked. Use C<login> for this.


=head2 login $address, $password

Endorse some identity with authentication check via the current
backend. C<login> works exactly like C<su>, except that it will
check authentication information.

Thus for C<login> to succeed, the corresponding account must exist and
the proper authentication verified. For the special 'admin' account,
the I<master_password> from the global I<bearmail.cfg> configuration file
is used.

Currently only (plain) password authentication is supported (although the
backend might choose to store it hashed, for instance MD5 hashing is the
default for the 'files' backend).

=head2 user

Retrieve current endorsed identity as a C<BearMail::Account> object.

This method returns undef if no C<su> or C<login> call where issued or
succeeded.


=head1 SUPPORT

Bugs should be reported via the Trac tool at

L<http://forge.bearstech.com/trac/newticket>

=head1 AUTHORS

=head1 SEE ALSO

L<BearMail>

=head1 COPYRIGHT

Copyright (C) 2009,2010 Bearstech - http://bearstech.com/

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut


use Carp;


sub new {
    my $class = shift;
    my (%args) = @_;

    my $cfg = $args{config}  || BearMail::Config->new->load();
    my $be  = $args{backend} || _get_backend($cfg);

    bless { cfg => $cfg, be => $be }, $class;
}

sub _get_backend {
    my $cfg = shift;

    my $be_name = $cfg->{_}->{backend};
    if ($be_name eq 'flatfiles') {
        require BearMail::Backend::FlatFiles;
        return  BearMail::Backend::FlatFiles->new($cfg->{"flatfiles"});
    }
    carp "Unknown backend '$be_name' (missing BearMail::Backend::$be_name module ?)";
}

1;
