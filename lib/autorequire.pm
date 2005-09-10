package autorequire ;

use 5.008 ;
use strict ;
use warnings ;

our $VERSION = '0.01' ;

my $LAST = 0 ;
my @SUBS = () ;


# Start the entire thing
push @INC, new autorequire() ;


sub import {
	my $class = shift ;
	my $sub = shift ;

	# print STDERR "autorequire: sub is $sub\n" ;
	unshift @SUBS, $sub ;
}


sub new {
	my $class = shift ;

	my $this = {} ;
	$this->{id} = ++$LAST ;

	return bless($this, $class) ;
}


sub autorequire::INC {
	my ($this, $filename) = @_ ;

	if ($INC[-1] eq $this){
		my $ret = undef ;
		foreach my $s (@SUBS){
			# print STDERR "autorequire: trying caller $c\n" ;
			my $module = $filename ;
			$module =~ s/\.pm$// ;
			$module =~ s/\//::/ ;
			$ret = $s->($filename, $module) ;
			if (defined($ret)){
				if (! is_handle($ret)){
					my $data = $ret ;
					$ret = undef ;
					open($ret, '<', (ref($data) ? $data : \$data)) or
						croak("Can't open in-memory filehandle: $!") ;
				}
				# print STDERR "autorequire: $ret\n" ;
				last ;
			}		
		}

		return $ret ;
	}
	elsif ($this->{id} == $LAST) {
		# Someone pushed in after us and we are the first one to notice...
		# print STDERR "autorequire: pushing another instance on \@INC\n" ;
		push @INC, new autorequire() ;
		return undef ;
	}
	else {
		# We are in the middle somewhere...
		# print STDERR "autorequire: obsolete object ($this->{id} < $LAST)\n" ;
		return undef  ;
	}
}


# From File::Copy
sub is_handle {
	my $h = shift ;

	return (ref($h)
		? (ref($h) eq 'GLOB'
			|| UNIVERSAL::isa($h, 'GLOB')
				|| UNIVERSAL::isa($h, 'IO::Handle'))
		: (ref(\$h) eq 'GLOB')) ;
}



1 ;
__END__
=head1 NAME

autorequire - Generate module code on demand

=head1 SYNOPSIS

  use autorequire sub {
    my ($filename) = @_ ;
    if ($filename eq 'Useless.pm'){
      return "package Useless ;\n1 ;"
    }
    return undef ;
  } ;

=head1 DESCRIPTION

C<autorequire> allows you to automatically generate code for modules that are missing from your installation. It does so by placing a hook at the end of the @INC array and forwarding requests to missing modules to the subroutine provided. C<autorequire> guarantees that the hook registered will always be the last entry in @INC.

The subroutine must return the code for the module in the form of a filehandle, a scalar reference or a scalar. A return value of undef will pass control to the subroutine provided to the previous C<autorequire> usage or will croak if C<autorequire> was not previously used.

=head1 SEE ALSO

L<require>, L<open>.

=head1 AUTHOR

Patrick LeBoutillier, E<lt>patl@lcpan.org<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Patrick LeBoutillier

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
