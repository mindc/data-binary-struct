#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
use Data::Binary::Struct;

ok( defined &main::struct_decode, 'Exported struct_decode' );
ok( defined &main::struct_encode, 'Exported struct_encode' );

