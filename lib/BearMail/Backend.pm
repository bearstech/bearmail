package BearMail::Backend;

use BearMail::Backend::Files;

# Should be selected by some config file
sub backend {
  return new BearMail::Backend::Files;
}

1;
