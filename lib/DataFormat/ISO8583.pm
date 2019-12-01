package DataFormat::ISO8583;

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
	$self->{'fields'}{310000}{Q} = [1,2,3,4,7,11,12,18,35,37,41,49,52,53,62,63,103,127,128];
	$self->{'fields'}{310000}{A} = [1,2,3,4,7,11,12,18,30,31,37,39,41,54,62,63,100,103,127,128];
}

sub InitFormats {
	my ($self) = @_;

	$self->{'format'}{1}	= ['BCD',	'FIXED',	4,	"1	Message Type Identifier"];
	$self->{'format'}{2}	= ['BCD',	'LVAR',		1,	"2	Primary Account Number"];
	$self->{'format'}{3}	= ['BCD',	'FIXED',	6,	"3	Processing  Code "];
	$self->{'format'}{4}	= ['BCD',	'FIXED',	12,	"4	Amount, Transaction"];
	$self->{'format'}{7}	= ['BCD',	'FIXED',	14,	"7	Date and Time, Transmission"];
	$self->{'format'}{11}	= ['BCD',	'FIXED',	6,	"11	System Trace Audit Number (STAN)"];
	$self->{'format'}{12}	= ['BCD',	'FIXED',	12,	"12	Date And Time, Local Transaction"];

	$self->{'format'}{15}	= ['BCD',	'FIXED',	4,	"15	"];

	$self->{'format'}{18}	= ['BCD',	'FIXED',	2,	"18	Terminal Type"];

	$self->{'format'}{22}	= ['BCD',	'FIXED',	0,	"22	Point of Service Sata Code (Service Status)"];
	$self->{'format'}{23}	= ['BCD',	'FIXED',	0,	"23	Card Sequence Number"];
	$self->{'format'}{24}	= ['BCD',	'FIXED',	0,	"24	Function Code (Service Status)"];
	$self->{'format'}{25}	= ['BCD',	'FIXED',	0,	"25	Message Reason Code"];

	$self->{'format'}{30}	= ['BCD',	'FIXED',	14,	"30	Actual Balance"];
	$self->{'format'}{31}	= ['BCD',	'LVAR',		1,	"31	Acquirer Reference Data (Internal Reference ID)"];
	$self->{'format'}{34}	= ['BCD',	'FIXED',	0,	"34	Account Number"];

	$self->{'format'}{35}	= ['ASCII',	'LVAR',		2,	"35	Track 2 Data"];
	$self->{'format'}{37}	= ['BCD',	'FIXED',	12,	"37	Retrieval Reference Number (RRN)"];

	$self->{'format'}{39}	= ['ASCII',	'FIXED',	3,	"39	Action Code"];
	$self->{'format'}{40}	= ['BCD',	'FIXED',	0,	"40	Additional Data"];

	$self->{'format'}{41}	= ['BCD',	'FIXED',	8,	"41	Card Acceptor Terminal Identification(Terminal ID)"];
	$self->{'format'}{42}	= ['BCD',	'FIXED',	0,	"42	Card Acceptor Identification Code (Merchant ID)"];
	$self->{'format'}{43}	= ['BCD',	'FIXED',	0,	"43	Card Acceptor Name/Location"];
	$self->{'format'}{44}	= ['BCD',	'FIXED',	0,	"44	Additional Response Data "];
	$self->{'format'}{47}	= ['BCD',	'FIXED',	0,	"47	Payer ID"];
	$self->{'format'}{48}	= ['BCD',	'FIXED',	0,	"48	Additional Data - Private"];

	$self->{'format'}{49}	= ['ASCII',	'FIXED',	3,	"49	Currency Code"];
	$self->{'format'}{50}	= ['BCD',	'FIXED',	0,	"50	Currency Code"];

	$self->{'format'}{52}	= ['ASCII',	'FIXED',	16,	"52	Personal Identification Number (PIN) Data"];
	$self->{'format'}{53}	= ['ASCII',	'LVAR',		2,	"53	Security Related Control Information ->Terminal Serial Number"];

	$self->{'format'}{54}	= ['BCD',	'FIXED',	14,	"54	Available Balance"];
	$self->{'format'}{55}	= ['BCD',	'FIXED',	0,	"55	Integareted Circuit Card System Related Data"];
	$self->{'format'}{59}	= ['BCD',	'FIXED',	0,	"59	Merchant Statement (Transport data)"];
	$self->{'format'}{60}	= ['BCD',	'FIXED',	0,	"60	Additional Data "];
	$self->{'format'}{61}	= ['BCD',	'FIXED',	0,	"61	Additional Data"];

	$self->{'format'}{62}	= ['BCD',	'FIXED',	6,	"62	Application Version"];
	$self->{'format'}{63}	= ['BCD',	'FIXED',	2,	"63	Application Name"];
	$self->{'format'}{74}	= ['BCD',	'FIXED',	0,	"74	"];
	$self->{'format'}{86}	= ['BCD',	'FIXED',	0,	"86	"];
	$self->{'format'}{95}	= ['BCD',	'FIXED',	0,	"95	Replacement Amounts"];
	$self->{'format'}{96}	= ['BCD',	'FIXED',	0,	"96	Key Management (PINKey + MACKey + PIC Key + Data Key)"];

	$self->{'format'}{100} = ['ASCII',	'LVAR',		3,	"100	Write Command Additional Data"];
	$self->{'format'}{102} = ['BCD',	'FIXED',	0,	"102	Account Identification 1 : Account Number (14)"];

	$self->{'format'}{103} = ['ASCII',	'LVAR',		2,	"103	Account Identification 2"];

	$self->{'format'}{104} = ['BCD',	'FIXED',	0,	"104	Terminal Name (32)[Transaction description]"];
	$self->{'format'}{119} = ['BCD',	'FIXED',	0,	"119	PIN Code"];
	$self->{'format'}{120} = ['BCD',	'FIXED',	0,	"120	Credit Serial Number"];
	$self->{'format'}{121} = ['BCD',	'FIXED',	0,	"121	Help Desk Number"];
	$self->{'format'}{122} = ['BCD',	'FIXED',	0,	"122	Activation Code"];
	$self->{'format'}{123} = ['BCD',	'FIXED',	0,	"123	Merchant Tel Number (25)"];
	$self->{'format'}{124} = ['BCD',	'FIXED',	0,	"124	Support Tel Number(25)"];
	$self->{'format'}{125} = ['BCD',	'FIXED',	0,	"125	User ID "];
	$self->{'format'}{126} = ['BCD',	'FIXED',	0,	"126	Payer ID Status"];

	$self->{'format'}{127} = ['ASCII',	'FIXED',	8,	"127	Write Command"];
	$self->{'format'}{128} = ['ASCII',	'FIXED',	16,	"128	Message Authentication Code (MAC)"];
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
	my ($self,$process) = @_;
	if (exists $self->{'fields'}{$process} ) {
		return $self->{'fields'}{$process};
	}else{
		die "ISO8583::Fields, No such process code: ".$process;
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

