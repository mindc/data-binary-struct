#!/usr/bin/perl

use strict;
use warnings;
use lib qw( ../lib/ );
use Data::Binary::Struct;
use POSIX qw( strftime );
use Data::Dumper;

$Data::Dumper::Indent = 1;

# defined struct
my $struct = [
	header => [ # grouping
		id => 'L',
		name => 'Z33',
		unix_timestamp => 'L',
		_datetime => sub { # custom handle to process decoded data
			my $data = shift;
			strftime("%F %T", localtime( $data->{ unix_timestamp } ) );
		}
	],

	# dynamic array
	count => 'C',
	'items[count]' => [
		id => 'L',
		title => 'Z16',
		body => 'Z256'
	],


	# dynamic array with simple types
	modes_count => 'C',
	'modes[modes_count]' => 'Z10',

	
	# static array
	'keys[2]' => [ key => 'C' ], 

	# static array with simple types
	'codes[5]' => 'C'

];

# test data

my $input = { 
	header => {
		id => 6753,
		name => 'Perl',
		unix_timestamp => 1492292778,
	},
	modes_count => 3,
	modes => [ 'alpha', 'beta', 'gamma' ],
	codes => [ 1, 2, 3, 5, 8 ],
	count => 2,
	items => [
		{ id => 12, title => 'test1', body => 'Some Long Text Some Long Text' },
		{ id => 13, title => 'test2', body => '' },
	],
	keys => [ 
		{ key => 22 }, 
		{ key => 33 } 
	]
};

# encode data to binary using defined struct
my $packed = struct_encode( $struct, $input );

# decode binary data using defined struct
my $output = struct_decode( $struct, $packed );

# check result
print Dumper $output;