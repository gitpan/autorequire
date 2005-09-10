# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl autorequire.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7 ;

use autorequire sub {
	my $filename = shift ;
	if ($filename eq 'ar_test_scalar.pm'){
		return "package ar_test_scalar ;\nsub a{1} 1 ;" ;
	}
	elsif ($filename eq 'ar_test_ref.pm'){
		my $code = "package ar_test_ref ;\nsub a{1} 1 ;" ;
		return \$code ;
	}
	elsif ($filename eq 'ar_test_handle.pm'){
		return \*DATA ;
	}

	return undef ;
} ;
BEGIN { ok(1) } ;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use ar_test_scalar ;
BEGIN { ok(ar_test_scalar::a()) }
use ar_test_ref ;
BEGIN { ok(ar_test_ref::a()) }
require ar_test_handle ;
ok(ar_test_handle::a()) ;
ok(<ar_test_handle::DATA>, 'test1') ;
ok(<ar_test_handle::DATA>, 'test2') ;
ok(ar_test_scalar::a()) ;


__END__
package ar_test_handle ;
sub a{1} 1 ;
__DATA__
test1
test2
