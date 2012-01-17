#!/usr/bin/perl

package Data::Format::HTML;

use strict;
use warnings;

our $VERSION = '0.5.1';

=head1 NAME

Data::Format::HTML - Format Perl data structures into simple HTML

=head1 SYNOPSIS

 use Data::Format::HTML;
 
 my $f = Data::Format::HTML->new;
 
 my %hash = (simple => 'hash');
 
 # Of course it's very unlikely that you won't deal ever with this
 # kind of structure, but HTML is able to hand it all anyway :)
 my $struct = {
 	foo 				=> 'bar',
 	1 					=> 2,
 	\'hello' 			=> 'goodbye',
 	array_ref			=> [qw/one two three/],
 	nested_hash			=> \%hash,
 	[qw/1 2/]			=> sub { die; },
 	even_more			=> { arr => {
 			1 => [2, 3, 4],
 			this_is_insane => { a => { b => { c => { d => { e => 'z'}}}}}
 		},					
 	},
 };
 
 $struct->{'Data::Format::HTML handles it all'} = $f;
 
 print $f->format( $struct );
 
And that will output the following insane, but possible, for the sake
of showing, HTML:

=begin HTML

<table border="1" class="hashTable">
<tr><th>SCALAR(0x82a2be4)</th><td>goodbye</td></tr>

<tr><th>ARRAY(0x8225570)</th><td><p class="code">CODE(0x8370ac8)</p>
</td></tr>
<tr><th>1</th><td>2</td></tr>
<tr><th>array_ref</th><td><table border="1" class="arrayTable">
<tr><td>one</td></tr>
<tr><td>two</td></tr>
<tr><td>three</td></tr>
</table>
</div>

</td></tr>
<tr><th>nested_hash</th><td><table border="1" class="hashTable">
<tr><th>simple</th><td>hash</td></tr>
</table>

</td></tr>
<tr><th>foo</th><td>bar</td></tr>
<tr><th>Data::Format::HTML handles it all</th><td><p class="scalar">Data::Format::HTML=HASH(0x82255c4)</p>

</td></tr>
<tr><th>even_more</th><td><table border="1" class="hashTable">
<tr><th>arr</th><td><table border="1" class="hashTable">
<tr><th>1</th><td><table border="1" class="arrayTable">
<tr><td>2</td></tr>
<tr><td>3</td></tr>
<tr><td>4</td></tr>
</table>
</div>

</td></tr>

<tr><th>this_is_insane</th><td><table border="1" class="hashTable">
<tr><th>a</th><td><table border="1" class="hashTable">
<tr><th>b</th><td><table border="1" class="hashTable">
<tr><th>c</th><td><table border="1" class="hashTable">
<tr><th>d</th><td><table border="1" class="hashTable">
<tr><th>e</th><td>z</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>

</td></tr>
</table>

</td></tr>

</table>

=end HTML 

In theory you can pass any kind of Perl data structure to C<format>
and you will get its data HTML-formatted.

=head1 TODO

=over

=item *

A LOT. ;)

=item *

Explain how CSS can prettify the tables (specification for everything)

=item *

Get CSS.

=item *

Better support for GLOB, CODE, REF and company.

=item *

Extend this documentation.

=back

=head1 SEE MORE

The author keeps the versioned code at GitHub at: L<http://github.com/damog/data-format-html/tree/master>.

=head1 AUTHOR

David Moreno, E<lt>david@axiombox.comE<gt> - L<http://damog.net/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by David Moreno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

The Do What The Fuck You Want To public license also applies. It's
really up to you.

=cut

use feature "switch";
use Data::Dumper;
use HTML::Entities;

sub new {
	my($self, %opts) = shift;
	
	return bless {
		css => $opts{css} || '',
		var => undef,
		title => undef,
	}, $self;
}

sub format {
	my($self, $var, $title) = @_;

	my $output;

	if(defined $title) {
		$output .= qq{<h2>$title</h2>\n};
	} 

	$output .= $self->_format($var);

}

sub _format {
	my($self, $var) = @_;
			
	given (ref $var) {
		when ('SCALAR')		{ return $self->_format_scalar($var); }
		when ('ARRAY')		{ return $self->_format_array($var); }
		when ('HASH')			{ return $self->_format_hash($var); }
		when ('CODE')			{ return $self->_format_code($var); }
#		when 'REF'			{ return $self->_format_ref($var); }
		when ('')			{ return $self->_format_scalar(\$var); }
		default			 	{ return $self->_format_scalar(\$var); }
	}
}

sub _format_code {
	my($self, $code) = @_;

	qq{<p class="code">}.scalar($code).qq{</p>\n};
}

sub _format_hash {
	my($self, $hash) = @_;
	
	my $o = qq{<table border="1" class="hashTable">\n};
	
	while(my($k, $v) = each %{$hash}) {
		$k = $self->_format($k) if ref $k;
		$v = $self->_format($v) if ref $v;
		$v = '' unless defined $v;
		
		$o .= "<tr><th>$k</th><td>$v</td></tr>\n";
	}
	
	$o .= qq{</table>\n\n};
}

sub _format_array {
	my($self, $arr) = @_;
	
	my $output = qq{<table border="1" class="arrayTable">\n};
	
	foreach my $v (@{$arr}) {
		$v = $self->_format($v) if ref $v;
		$output .= qq{<tr><td>$v</td></tr>\n};
	}
	
	$output .= "</table>\n</div>\n\n";
}

sub _format_scalar {
	my($self, $var) = @_;

	qq{<p class="scalar">${$var}</p>\n\n};
}

1;
