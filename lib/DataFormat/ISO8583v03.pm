package DataFormat::ISO8583v03;

use strict;
use warnings;

use parent qw(DataFormat);

use Tools;

sub new {
	my ($class, $args) = @_;
	my $self = $class->SUPER::new;
	$self->InitFormats();
	$self->InitFields();
    return $self;
};

sub InitFields {
	my ($self) = @_;
	$self->{'fields'}{'2100'} = {2 => "M", 3 => "M", 4 => "M", 7 => "M", 11 => "M", 12 => "M", 13 => "M", 14 => "M", 18 => "M", 22 => "M", 23 => "C", 25 => "M", 26 => "C", 28 => "M", 32 => "M", 35 => "C", 37 => "M", 40 => "O", 41 => "M", 42 => "M", 43 => "M", 49 => "M", 52 => "C", 53 => "C", 54 => "C", 55 => "C", 56 => "O", 59 => "O", 60 => "C", 62 => "C", 123 => "C", 124 => "C", 128 => "M"};

	$self->{'fields'}{'2110'} = {2 => "M", 3 => "M", 4 => "M", 7 => "C", 11 => "C", 12 => "M", 13 => "C", 14 => "C", 15 => "C", 18 => "M", 22 => "M", 23 => "M", 25 => "M", 28 => "C", 30 => "C", 32 => "M", 33 => "C", 35 => "C", 37 => "M", 38 => "C", 39 => "M", 40 => "C", 41 => "O", 42 => "C", 43 => "C", 49 => "M", 54 => "C", 55 => "C", 59 => "C", 60 => "C", 102 => "O", 103 => "O", 123 => "M", 124 => "C", 128 => "M"}

}

# DATA: BIN,	FIX,	64 => 64 bits => 64/8 = 8 bytes
# DATA: BCD,	FIX,	6  => 6  digits => 6/2 = 3 bytes (left padded by zero for odd number of digits)
# DATA: ASC,	FIX,	5 => 5 char  => 5 bytes

# LEN: BIN, !!!     we have no variable len Binary in ISO8583

# LEN: BCD,	VAR,	19 => 2 digits len => 2/2 = 1 bytes BCD len
# LEN: ASC, VAR,	25 => 2 digits len => 2 bytes ASCII len

sub InitFormats {
	my ($self) = @_;

	$self->{'format'}{'TPDU'}	= ['BIN',	'BIN',	'FIX',	40,	"TPDU"];
	$self->{'format'}{'MTI'}	= ['BCD',	'BCD',	'FIX',	4,	"Message Type Identifier"];
	$self->{'format'}{'BITMAP'}	= ['BIN',	'BIN',	'FIX',	128,"BITMAP"];

#								LEN		DATA	TYPE	LEN		Comment
	$self->{'format'}{2}	= ['BCD',	'BCD',	'VAR',	19,	"2	Primary Account Number"];
}

1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2009-2017 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the terms of GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

=cut

