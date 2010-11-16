
use strict;
use warnings;

use Test::More tests => 2;
use Test::Fatal;
use Class::Load qw( :all );
use lib 't/lib';

isnt(
  exception {
    load_optional_class('Class::Load::Error::DieIsaSyntax');
  },
  undef,
  'Loading a broken class breaks'
);

isnt(
  exception {
    load_optional_class('Class::Load::Error::DieIsaSyntax');
  },
  undef,
  'Loading a broken class breaks(x2)'
);
