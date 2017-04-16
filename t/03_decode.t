#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use Data::Binary::Struct;
use POSIX qw( strftime );

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

my $i = {
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
my $packed = struct_encode( $struct, $i );

# decode binary data using defined struct
my $o = struct_decode( $struct, $packed );

is( $o->{ count }, 2 , 'Simple type' );
is( @{$o->{ codes }}, 5, 'Simple type static array' );
is( $o->{ codes }[2], 3, 'Simple type static array' );
is( $o->{ modes }[2], 'gamma', 'Simple type dynamic array' );
is( $o->{ header }{ id }, 6753, 'Grouping' );
is( $o->{ header }{ _datetime }, '2017-04-15 23:46:18', 'Custom handle' );


	


done_testing;
