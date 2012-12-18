use strict;
use warnings;

use Test::More 0.88;
use lib 't/lib';
use Test::Class::Load ':all';
use Test::Fatal;

# This tests the behaviour of invoking load_class() on a class
# that as already been attempted to load, and failed, without using
# a Module::Runtime based implementation, 
#
# Which will leave %INC in a "broken" state on Perl 5.8, and then the 
# subsequent attempt to load will falsely think its already loaded, 
# and silently no-op, ie:
#
# eval { require Foo } load_class('Foo');
#
# Will keep working on 5.8, even if Foo is broken/missing.
#
# Worse;
# 
# eval { require Foo } if( eval{ require Foo; } ) { }
# 
# This will run the conditional code as if Foo was successfully loaded.
#
# This is presently an *unsolveable problem* on 5.8. 
#
# The best we can do at present:
#
# a) Make all modules use Module::Runtime instead of eval { require Foo },
#    as this will properly detect modules failing to load, and do the right 
#    thing with regard to subsequent reloads. This is the only "Real" option.
#
# b) Use Heuristics to determine "is the module really loaded", and then delete 
#    "false postives" from %INC if we determine that "%INC is wrong". However, there are
#    no heuristics that are known to work for all cases, and heuristics generate false
#    negatives far more often than people hit the false-postive case on 5.8, and there
#    are very bad things that can happen in the false-negative case, so this method
#    ( which was previously implemented ) has been removed.
 
like( exception {
    require Class::Load::SyntaxError;
}, qr/syntax error/ , 'Load without Module::Runtime' );

my $re = qr/syntax error/;
$re = qr/Attempt to reload/ if "$[" < 5.010000;

TODO: {
	local $TODO;
	
	$TODO = "Calling load_class on a broken module after already loading it *without* module::runtime is broken before 5.10.0" if "$]" < 5.010000;

	my $result = exception {
		load_class('Class::Load::SyntaxError');
	};
	ok(defined($result), 'Subsequent Load throws an exception')
	and like($result, $re, 'Subsequent load is a syntax error detected by Module::Runtime' );

}
done_testing;
