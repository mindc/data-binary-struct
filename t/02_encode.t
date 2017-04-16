#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 8;
use Data::Binary::Struct;
use POSIX qw( strftime );

is( struct_encode( [ id => 'L' ], { id => 34 } ), pack( 'L', 34 ), 'Simple type' );
is( struct_encode( [ name => 'A16' ], { name => 'hello' } ), pack( 'A16', 'hello' ), 'Simple type' );
is( struct_encode( [ 'flags[3]' => 'A' ], { flags => [ qw( R G B ) ] } ), pack( '(A)3' , qw( R G B ) ), 'Simple type static array' );
is( struct_encode( [ 'count' => 'C', 'flags[count]' => 'A' ], { count => 3, flags => [ qw( R G B ) ] } ), pack( 'C(A)3' , 3, qw( R G B ) ), 'Simple type dynamic array' );
is( struct_encode( [ header => [ id => 'L' ] ], { header => { id => 34 } } ), pack( 'L', 34 ), 'Grouping' );
is( struct_encode( [ 'items[2]' => [ id => 'L', name => 'Z32' ] ], { items => [ { id => 1, name => 'Hello' }, { id => 2, name => 'World' } ] } ), pack('(LZ32)2', 1, 'Hello', 2, 'World' ), 'Complex type static array' );
is( struct_encode( [ 'count' => 'C', 'items[count]' => [ id => 'L', name => 'Z32' ] ], { count => 2, items => [ { id => 1, name => 'Hello' }, { id => 2, name => 'World' } ] } ), pack('C(LZ32)2', 2, 1, 'Hello', 2, 'World' ), 'Complex type dynamic array' );
is( struct_encode( [ 'unix' => 'L', 'datetime' => sub { my $data = shift; strftime("%E %T", localtime( $data->{ unix } ) ) } ], { unix => 1492292778 } ), pack( 'L', 1492292778 ), 'Ignore custom handle in encode' );
