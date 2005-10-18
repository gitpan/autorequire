use strict ;

use Test::More tests => 3 ;
BEGIN { use_ok('autodynaload') } 
BEGIN {$autodynaload::INC[-1]->disable()}

use autodynaload sub {
	my ($this, @args) = @_ ;

	# The last argument is the actual dll name
	autodynaload->is_installed($args[-1]) ;
} ;
BEGIN {$autodynaload::INC[-1]->disable()}


eval "use MIME::Base64 ;" ;
like($@, qr/Can't locate/) ; #'

delete $INC{'MIME/Base64.pm'} ;
$autodynaload::INC[-1]->enable() ;
{
	local $^W ;
	eval "use MIME::Base64 ;" ;
	is(MIME::Base64::encode_base64('A', ''), 'QQ==') ;
}
