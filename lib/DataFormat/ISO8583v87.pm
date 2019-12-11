package DataFormat::ISO8583v87;

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
	$self->{'fields'}{'0100'} = {2 => "M", 3 => "M", 4 => "M", 7 => "M", 11 => "M", 12 => "M", 13 => "M", 14 => "M", 18 => "M", 22 => "M", 23 => "C", 25 => "M", 26 => "C", 28 => "M", 32 => "M", 35 => "C", 37 => "M", 40 => "O", 41 => "M", 42 => "M", 43 => "M", 49 => "M", 52 => "C", 53 => "C", 54 => "C", 55 => "C", 56 => "O", 59 => "O", 60 => "C", 62 => "C", 123 => "C", 124 => "C", 128 => "M"};

	$self->{'fields'}{'0110'} = {2 => "M", 3 => "M", 4 => "M", 7 => "C", 11 => "C", 12 => "M", 13 => "C", 14 => "C", 15 => "C", 18 => "M", 22 => "M", 23 => "M", 25 => "M", 28 => "C", 30 => "C", 32 => "M", 33 => "C", 35 => "C", 37 => "M", 38 => "C", 39 => "M", 40 => "C", 41 => "O", 42 => "C", 43 => "C", 49 => "M", 54 => "C", 55 => "C", 59 => "C", 60 => "C", 102 => "O", 103 => "O", 123 => "M", 124 => "C", 128 => "M"}
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
	$self->{'format'}{2}	= ['BCD',	'BCD',	'VAR',	19,	"2	Primary account number (PAN)"];
	$self->{'format'}{3}	= ['BCD',	'BCD',	'FIX',	6,	"3	Processing code"];
	$self->{'format'}{4}	= ['BCD',	'BCD',	'FIX',	12,	"4	Amount, transaction"];
	$self->{'format'}{5}	= ['BCD',	'BCD',	'FIX',	12,	"5	Amount, settlement"];
	$self->{'format'}{6}	= ['BCD',	'BCD',	'FIX',	12,	"6	Amount, cardholder billing"];
	$self->{'format'}{7}	= ['BCD',	'BCD',	'FIX',	10,	"7	Transmission date & time"];
	$self->{'format'}{8}	= ['BCD',	'BCD',	'FIX',	8,	"8	Amount, cardholder billing fee"];
	$self->{'format'}{9}	= ['BCD',	'BCD',	'FIX',	8,	"9	Conversion rate, settlement"];
	$self->{'format'}{10}	= ['BCD',	'BCD',	'FIX',	8,	"10	Conversion rate, cardholder billing"];
	$self->{'format'}{11}	= ['BCD',	'BCD',	'FIX',	6,	"11	System trace audit number (STAN)"];
	$self->{'format'}{12}	= ['BCD',	'BCD',	'FIX',	6,	"12	Local transaction time (hhmmss)"];
	$self->{'format'}{13}	= ['BCD',	'BCD',	'FIX',	4,	"13	Local transaction date (MMDD)"];
	$self->{'format'}{14}	= ['BCD',	'BCD',	'FIX',	4,	"14	Expiration date"];
	$self->{'format'}{15}	= ['BCD',	'BCD',	'FIX',	4,	"15	Settlement date"];
	$self->{'format'}{16}	= ['BCD',	'BCD',	'FIX',	4,	"16	Currency conversion date"];
	$self->{'format'}{17}	= ['BCD',	'BCD',	'FIX',	4,	"17	Capture date"];
	$self->{'format'}{18}	= ['BCD',	'BCD',	'FIX',	4,	"18	Merchant type, or merchant category code"];
	$self->{'format'}{19}	= ['BCD',	'BCD',	'FIX',	3,	"19	Acquiring institution (country code)"];
	$self->{'format'}{20}	= ['BCD',	'BCD',	'FIX',	3,	"20	PAN extended (country code)"];
	$self->{'format'}{21}	= ['BCD',	'BCD',	'FIX',	3,	"21	Forwarding institution (country code)"];
	$self->{'format'}{22}	= ['BCD',	'BCD',	'FIX',	3,	"22	Point of service entry mode"];
	$self->{'format'}{23}	= ['BCD',	'BCD',	'FIX',	3,	"23	Application PAN sequence number"];
	$self->{'format'}{24}	= ['BCD',	'BCD',	'FIX',	3,	"24	Function code (ISO 8583:1993), or network international identifier (NII)"];
	$self->{'format'}{25}	= ['BCD',	'BCD',	'FIX',	2,	"25	Point of service condition code"];
	$self->{'format'}{26}	= ['BCD',	'BCD',	'FIX',	2,	"26	Point of service capture code"];
	$self->{'format'}{27}	= ['BCD',	'BCD',	'FIX',	1,	"27	Authorizing identification response length"];
	$self->{'format'}{28}	= ['BCD',	'XBCD',	'FIX',	8,	"28	Amount, transaction fee"];
	$self->{'format'}{29}	= ['BCD',	'XBCD',	'FIX',	8,	"29	Amount, settlement fee"];
	$self->{'format'}{30}	= ['BCD',	'XBCD',	'FIX',	8,	"30	Amount, transaction processing fee"];
	$self->{'format'}{31}	= ['BCD',	'XBCD',	'FIX',	8,	"31	Amount, settlement processing fee"];
	$self->{'format'}{32}	= ['BCD',	'BCD',	'VAR',	11,	"32	Acquiring institution identification code"];
	$self->{'format'}{33}	= ['BCD',	'BCD',	'VAR',	11,	"33	Forwarding institution identification code"];
	$self->{'format'}{34}	= ['ASC',	'ASC',	'VAR',	28,	"34	Primary account number, extended"];

	$self->{'format'}{35}	= ['ASC',	'ASC',	'VAR',	37,	"35	Track 2 data"];					# what is z?

	$self->{'format'}{36}	= ['BCD',	'BCD',	'VAR',	104,	"36	Track 3 data"];
	$self->{'format'}{37}	= ['ASC',	'ASC',	'FIX',	12,	"37	Retrieval reference number"];
	$self->{'format'}{38}	= ['ASC',	'ASC',	'FIX',	6,	"38	Authorization identification response"];
	$self->{'format'}{39}	= ['ASC',	'ASC',	'FIX',	2,	"39	Response code"];
	$self->{'format'}{40}	= ['ASC',	'ASC',	'FIX',	3,	"40	Service restriction code"];
	$self->{'format'}{41}	= ['ASC',	'ASC',	'FIX',	8,	"41	Card acceptor terminal identification"];
	$self->{'format'}{42}	= ['ASC',	'ASC',	'FIX',	15,	"42	Card acceptor identification code"];
	$self->{'format'}{43}	= ['ASC',	'ASC',	'FIX',	40,	"43	Card acceptor name/location (1–23 street address, –36 city, –38 state, 39–40 country)"];
	$self->{'format'}{44}	= ['ASC',	'ASC',	'VAR',	25,	"44	Additional response data"];
	$self->{'format'}{45}	= ['ASC',	'ASC',	'VAR',	76,	"45	Track 1 data"];
	$self->{'format'}{46}	= ['ASC',	'ASC',	'VAR',	999,	"46	Additional data (ISO)"];
	$self->{'format'}{47}	= ['ASC',	'ASC',	'VAR',	999,	"47	Additional data (national)"];
	$self->{'format'}{48}	= ['ASC',	'ASC',	'VAR',	999,	"48	Additional data (private)"];
	$self->{'format'}{49}	= ['BCD',	'BCD',	'FIX',	3,	"49	Currency code, transaction"];	 		# or ASC
	$self->{'format'}{50}	= ['BCD',	'BCD',	'FIX',	3,	"50	Currency code, settlement"];			# or ASC
	$self->{'format'}{51}	= ['BCD',	'BCD',	'FIX',	3,	"51	Currency code, cardholder billing"];	# or ASC
	$self->{'format'}{52}	= ['BIN',	'BIN',	'FIX',	64,	"52	Personal identification number data"];
	$self->{'format'}{53}	= ['BCD',	'BCD',	'FIX',	16,	"53	Security related control information"];
	$self->{'format'}{54}	= ['ASC',	'ASC',	'VAR',	120,	"54	Additional amounts"];
	$self->{'format'}{55}	= ['ASC',	'ASC',	'VAR',	999,	"55	ICC data – EMV having multiple tags"];
	$self->{'format'}{56}	= ['ASC',	'ASC',	'VAR',	999,	"56	Reserved (ISO)"];
	$self->{'format'}{57}	= ['ASC',	'ASC',	'VAR',	999,	"57	Reserved (national)"];
	$self->{'format'}{58}	= ['ASC',	'ASC',	'VAR',	999,	"58	"];
	$self->{'format'}{59}	= ['ASC',	'ASC',	'VAR',	999,	"59	"];
	$self->{'format'}{60}	= ['ASC',	'ASC',	'VAR',	999,	"60	Reserved (national) (e.g. settlement request: batch number, advice transactions: original transaction amount, batch upload: original MTI plus original RRN plus original STAN, etc.)"];
	$self->{'format'}{61}	= ['ASC',	'ASC',	'VAR',	999,	"61	Reserved (private) (e.g. CVV2/service code   transactions)"];
	$self->{'format'}{62}	= ['ASC',	'ASC',	'VAR',	999,	"62	Reserved (private) (e.g. transactions: invoice number, key exchange transactions: TPK key, etc.)"];
	$self->{'format'}{63}	= ['ASC',	'ASC',	'VAR',	999,	"63	Reserved (private)"];
	$self->{'format'}{64}	= ['BIN',	'BIN',	'FIX',	64,	"64	Message authentication code (MAC)"];
	$self->{'format'}{65}	= ['BIN',	'BIN',	'FIX',	1,	"65	Extended bitmap indicator"];
	$self->{'format'}{66}	= ['BCD',	'BCD',	'FIX',	1,	"66	Settlement code"];
	$self->{'format'}{67}	= ['BCD',	'BCD',	'FIX',	2,	"67	Extended payment code"];
	$self->{'format'}{68}	= ['BCD',	'BCD',	'FIX',	3,	"68	Receiving institution country code"];
	$self->{'format'}{69}	= ['BCD',	'BCD',	'FIX',	3,	"69	Settlement institution country code"];
	$self->{'format'}{70}	= ['BCD',	'BCD',	'FIX',	3,	"70	Network management information code"];
	$self->{'format'}{71}	= ['BCD',	'BCD',	'FIX',	4,	"71	Message number"];
	$self->{'format'}{72}	= ['BCD',	'BCD',	'FIX',	4,	"72	Last message's number"];
	$self->{'format'}{73}	= ['BCD',	'BCD',	'FIX',	6,	"73	Action date (YYMMDD)"];
	$self->{'format'}{74}	= ['BCD',	'BCD',	'FIX',	10,	"74	Number of credits"];
	$self->{'format'}{75}	= ['BCD',	'BCD',	'FIX',	10,	"75	Credits, reversal number"];
	$self->{'format'}{76}	= ['BCD',	'BCD',	'FIX',	10,	"76	Number of debits"];
	$self->{'format'}{77}	= ['BCD',	'BCD',	'FIX',	10,	"77	Debits, reversal number"];
	$self->{'format'}{78}	= ['BCD',	'BCD',	'FIX',	10,	"78	Transfer number"];
	$self->{'format'}{79}	= ['BCD',	'BCD',	'FIX',	10,	"79	Transfer, reversal number"];
	$self->{'format'}{80}	= ['BCD',	'BCD',	'FIX',	10,	"80	Number of inquiries"];
	$self->{'format'}{81}	= ['BCD',	'BCD',	'FIX',	10,	"81	Number of authorizations"];
	$self->{'format'}{82}	= ['BCD',	'BCD',	'FIX',	12,	"82	Credits, processing fee amount"];
	$self->{'format'}{83}	= ['BCD',	'BCD',	'FIX',	12,	"83	Credits, transaction fee amount"];
	$self->{'format'}{84}	= ['BCD',	'BCD',	'FIX',	12,	"84	Debits, processing fee amount"];
	$self->{'format'}{85}	= ['BCD',	'BCD',	'FIX',	12,	"85	Debits, transaction fee amount"];
	$self->{'format'}{86}	= ['BCD',	'BCD',	'FIX',	16,	"86	Total amount of credits"];
	$self->{'format'}{87}	= ['BCD',	'BCD',	'FIX',	16,	"87	Credits, reversal amount"];
	$self->{'format'}{88}	= ['BCD',	'BCD',	'FIX',	16,	"88	Total amount of debits"];
	$self->{'format'}{89}	= ['BCD',	'BCD',	'FIX',	16,	"89	Debits, reversal amount"];
	$self->{'format'}{90}	= ['BCD',	'BCD',	'FIX',	42,	"90	Original data elements"];
	$self->{'format'}{91}	= ['ASC',	'ASC',	'FIX',	1,	"91	File update code"];
	$self->{'format'}{92}	= ['ASC',	'ASC',	'FIX',	2,	"92	File security code"];
	$self->{'format'}{93}	= ['ASC',	'ASC',	'FIX',	5,	"93	Response indicator"];
	$self->{'format'}{94}	= ['ASC',	'ASC',	'FIX',	7,	"94	Service indicator"];
	$self->{'format'}{95}	= ['ASC',	'ASC',	'FIX',	42,	"95	Replacement amounts"];
	$self->{'format'}{96}	= ['BIN',	'BIN',	'FIX',	64,	"96	Message security code"];
	$self->{'format'}{97}	= ['BCD',	'XBCD',	'FIX',	16,	"97	Net settlement amount"];
	$self->{'format'}{98}	= ['ASC',	'ASC',	'FIX',	25,	"98	Payee"];
	$self->{'format'}{99}	= ['BCD',	'BCD',	'VAR',	11,	"99	Settlement institution identification code"];
	$self->{'format'}{100}	= ['BCD',	'BCD',	'VAR',	11,	"100	Receiving institution identification code"];
	$self->{'format'}{101}	= ['ASC',	'ASC',	'VAR',	17,	"101	File name"];
	$self->{'format'}{102}	= ['ASC',	'ASC',	'VAR',	28,	"102	Account identification 1"];
	$self->{'format'}{103}	= ['ASC',	'ASC',	'VAR',	28,	"103	Account identification 2"];
	$self->{'format'}{104}	= ['ASC',	'ASC',	'VAR',	100,	"104	Transaction description"];
	$self->{'format'}{105}	= ['ASC',	'ASC',	'VAR',	999,	"105	Reserved for ISO use"];
	$self->{'format'}{106}	= ['ASC',	'ASC',	'VAR',	999,	"106	"];
	$self->{'format'}{107}	= ['ASC',	'ASC',	'VAR',	999,	"107	"];
	$self->{'format'}{108}	= ['ASC',	'ASC',	'VAR',	999,	"108	"];
	$self->{'format'}{109}	= ['ASC',	'ASC',	'VAR',	999,	"109	"];
	$self->{'format'}{110}	= ['ASC',	'ASC',	'VAR',	999,	"110	"];
	$self->{'format'}{111}	= ['ASC',	'ASC',	'VAR',	999,	"111	"];
	$self->{'format'}{112}	= ['ASC',	'ASC',	'VAR',	999,	"112	Reserved for national use"];
	$self->{'format'}{113}	= ['ASC',	'ASC',	'VAR',	999,	"113	"];
	$self->{'format'}{114}	= ['ASC',	'ASC',	'VAR',	999,	"114	"];
	$self->{'format'}{115}	= ['ASC',	'ASC',	'VAR',	999,	"115	"];
	$self->{'format'}{116}	= ['ASC',	'ASC',	'VAR',	999,	"116	"];
	$self->{'format'}{117}	= ['ASC',	'ASC',	'VAR',	999,	"117	"];
	$self->{'format'}{118}	= ['ASC',	'ASC',	'VAR',	999,	"118	"];
	$self->{'format'}{119}	= ['ASC',	'ASC',	'VAR',	999,	"119	"];
	$self->{'format'}{120}	= ['ASC',	'ASC',	'VAR',	999,	"120	Reserved for private use"];
	$self->{'format'}{121}	= ['ASC',	'ASC',	'VAR',	999,	"121	"];
	$self->{'format'}{122}	= ['ASC',	'ASC',	'VAR',	999,	"122	"];
	$self->{'format'}{123}	= ['ASC',	'ASC',	'VAR',	999,	"123	"];
	$self->{'format'}{124}	= ['ASC',	'ASC',	'VAR',	999,	"124	"];
	$self->{'format'}{125}	= ['ASC',	'ASC',	'VAR',	999,	"125	"];
	$self->{'format'}{126}	= ['ASC',	'ASC',	'VAR',	999,	"126	"];
	$self->{'format'}{127}	= ['ASC',	'ASC',	'VAR',	999,	"127	"];
	$self->{'format'}{128}	= ['BIN',	'BIN',	'FIX',	64,	"128	Message authentication code"];
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

