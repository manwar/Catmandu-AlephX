use strict;
use warnings;
use Test::More;

my $pkg;
BEGIN {
    $pkg = 'Catmandu::AlephX::Op::Present';
    use_ok $pkg;
}

require_ok $pkg;

done_testing 2;