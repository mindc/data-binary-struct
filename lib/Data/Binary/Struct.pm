package Data::Binary::Struct;

use strict;
use warnings;
use Exporter qw( import );

our $VERSION = '0.1';

sub struct_encode
{
    my ( $struct, $data ) = @_;
    my $packed = '';

    for ( my $j = 0; $j < @$struct; ) {
        my $key = $struct->[ $j++ ];
        my $value = $struct->[ $j++ ];

        if ( $key =~ m/^(\S+)\[(\S+)\]/ ) {
            my $sub_key = $1;
            my $sub_ref = $2;
            my $count = 0;

            if ( $sub_ref =~ m/^(\d+)$/ ) {
                $count = $1;
            } else {
                $count = @{ $data->{ $sub_key } || [] };
                $data->{ $sub_ref } = $count;
            }

            if ( ref $value eq 'ARRAY' ) {
                for ( my $i = 0; $i < $count; $i++ ) {
                    $packed .= struct_encode( $value, $data->{ $sub_key }[ $i ] );
                }
            } else {
                $packed .= pack( "($value)$count", @{ $data->{ $sub_key } } );
            }
        } else {
            if ( ref $value eq 'ARRAY' ) {
                $packed .= struct_encode( $value, $data->{ $key } );
            } elsif ( ref $value eq 'CODE' ) {

            } else {
                $packed .= pack( $value, $data->{ $key } );
            }
        }
    }
    return $packed;
}

sub struct_decode
{
    my ( $struct, $packed, $offset_ref ) = @_;

    my $offset = 0;
    $offset_ref ||= \$offset;

    my $data = {};

    for ( my $j = 0; $j < @$struct; ) {
        my $key = $struct->[ $j++ ];
        my $value = $struct->[ $j++ ];

        if ( $key =~ m/(\S+)\[(\S+)\]/ ) {
            my $sub_key = $1;
            my $count = $2 =~ m/^(\d+)$/ ? $1 : $data->{ $2 };

            if ( ref $value eq 'ARRAY' ) {
                $data->{ $sub_key } = [];
                for ( my $i = 0; $i < $count; $i++ ) {
                    push @{ $data->{ $sub_key } }, struct_decode( $value, $packed, $offset_ref );
                }
            } else {
                my $len = CORE::length pack "($value)$count";
                my $d = substr $packed, $$offset_ref, $len;
                $$offset_ref += $len;
                $data->{ $sub_key } = [ unpack( "($value)$count", $d ) ];
            }

        } else {
            if ( ref $value eq 'ARRAY' ) {
                my $s = struct_decode( $value, $packed, $offset_ref);
                @{ $data->{ $key} }{ keys %$s } = values %$s;
            } elsif ( ref $value eq 'CODE' ) {
                $data->{ $key } = $value->($data);
            } else {
                my $len = CORE::length pack $value;
                my $d = substr $packed, $$offset_ref, $len;
                $$offset_ref += $len;
                my $s = unpack( $value, $d );
                $data->{ $key } = $s;
            }
        }
    }
    return $data;

}

our @EXPORT = qw( struct_encode struct_decode );
our @EXPORT_OK = qw( struct_encode struct_decode );

1;

