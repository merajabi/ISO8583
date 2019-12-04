package DataFormat::ISO8583v93;

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
	$self->{'condition'}={M=>"Mandatory"}
	$self->{'fields'}{0100} = [];
}

# DATA: BIN,	FIX,	64 => 64 bits => 64/8 = 8 bytes
# DATA: BCD,	FIX,	6  => 6  digits => 6/2 = 3 bytes (left padded by zero for odd number of digits)
# DATA: ASC,	FIX,	5 => 5 char  => 5 bytes

# LEN: BIN, !!!     we have no variable len Binary in ISO8583

# LEN: BCD,	VAR,	19 => 2 digits len => 2/2 = 1 bytes BCD len
# LEN: ASC, VAR,	25 => 2 digits len => 2 bytes ASCII len

sub InitFormats {
	my ($self) = @_;
#								LEN		DATA	TYPE	LEN		Comment
}

sub FieldFormat {
	my ($self,$fieldNumber) = @_;
	if (exists $self->{'format'}{$fieldNumber} ) {
		return @{$self->{'format'}{$fieldNumber}};
	}else{
		die "ISO8583::FieldFormat, No such field: ".$fieldNumber;
	}
}

sub Fields {
	my ($self,$mit,$process) = @_;
	if (exists $self->{'fields'}{$mit.$process} ) {
		return $self->{'fields'}{$mit.$process};
	}else{
		die "ISO8583::Fields, No such MIT & Process code: $mit $process";
	}
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

