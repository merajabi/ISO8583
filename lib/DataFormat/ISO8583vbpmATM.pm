package DataFormat::ISO8583vbpmATM;

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
	$self->{'fields'}{110033} = {1 => "M", 2=>"M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 34=>"O", 35=>"M", 37=>"M", 41=>"M", 48=>"M", 53=>"M", 61=>"O", 62=>"O", 63=>"O", 103=>"O", 127=>"O", 128=>"M"};
	$self->{'fields'}{111033} = {1 => "M", 2=>"M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 44=>"M", 62=>"O", 63=>"O", 100=>"O", 103=>"O", 126=>"O", 127=>"O", 128=>"M"};

	$self->{'fields'}{110089} = { 1=>"M", 2=>"M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 35=>"M", 37=>"M", 41=>"M", 53=>"M", 60=>"M", 62=>"O", 63=>"O", 127=>"O", 128=>"M"};
	$self->{'fields'}{111089} = { 1=>"M", 2=>"M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 62=>"O", 63=>"O", 100=>"O", 127=>"O", 128=>"M"};

	$self->{'fields'}{120040} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 31 =>"M", 34 =>"M", 35=>"M", 37=>"M", 41=>"M", 47 =>"M", 49=>"M", 52=>"M", 53=>"M", 62=>"O", 63=>"O", 103=>"C", 126 =>"M", 127=>"O", 128=>"M"};
	$self->{'fields'}{121040} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 30=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 49=>"M", 54=>"M", 62=>"O", 63=>"O", 100=>"O", 103=>"C", 127=>"O", 128=>"M"};

	$self->{'fields'}{120031} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 35=>"M", 37=>"M", 41=>"M", 49=>"M", 52=>"M", 53=>"M", 62=>"O", 63=>"O", 103=>"C", 127=>"O", 128=>"M"};
	$self->{'fields'}{121031} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 30=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 49=>"M", 54=>"M", 62=>"O", 63=>"O", 100=>"O", 103=>"C", 127=>"O", 128=>"M"};

	$self->{'fields'}{120001} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 35=>"M", 37=>"M", 41=>"M", 49=>"M", 52=>"M", 53=>"M", 62=>"O", 63=>"O", 103=>"C", 127=>"O", 128=>"M"};
	$self->{'fields'}{121001} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 30=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 49=>"M", 54=>"M", 62=>"O", 63=>"O", 100=>"O", 103=>"C", 127=>"O", 128=>"M"};

	$self->{'fields'}{1500} = {1 => "M", 2=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 31=>"M", 37=>"M", 41=>"M", 48=>"M", 53=>"M", 62=>"O", 63=>"O", 103=>"C", 127=>"O", 128=>"M"};
	$self->{'fields'}{1510} = {1 => "M", 2=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 62=>"O", 63=>"O", 100=>"O", 103=>"C", 127=>"O", 128=>"M"};

	$self->{'fields'}{1420} = {1 => "M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 25=>"M", 31=>"M", 37=>"M", 41=>"M", 49=>"M", 53=>"M", 62=>"O", 63=>"O", 95=>"C", 103=>"C", 127=>"O", 128=>"M"};
	$self->{'fields'}{1430} = {1 =>	"M", 2=>"M", 3=>"M", 4=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 25=>"M", 37=>"M", 39=>"M", 41=>"M",  62=>"O", 63=>"O", 100=>"O", 103=>"C", 127=>"O", 128=>"M"};

	$self->{'fields'}{180000} = {1 => "M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 37=>"M", 41=>"M", 52=>"M", 53=>"M", 58=>"O", 62=>"O", 63=>"O", 125=>"M", 127=>"O", 128=>"M" };
	$self->{'fields'}{181000} = {1 => "M", 3=>"M", 7=>"M", 11=>"M", 12=>"M", 18=>"M", 24=>"M", 31=>"M", 37=>"M", 39=>"M", 41=>"M", 42=>"M", 43=>"M", 44=>"C", 60=>"C", 62=>"O", 63=>"O", 96=>"M", 100=>"M", 104=>"M", 127=>"O", 128=>"M"};
}


sub InitFormats {
	my ($self) = @_;
#									LEN		DATA	TYPE	LEN		Comment
	$self->{'format'}{'TPDU'}	= ['BIN',	'BIN',	'FIX',	40,	"TPDU"];
	$self->{'format'}{'MTI'}	= ['ASC',	'ASC',	'FIX',	32,	"Message Type Identifier"];
	$self->{'format'}{'BITMAP'}	= ['ASC',	'ASC',	'FIX',	32,	"BITMAP"];

	$self->{'format'}{2}	= ['BCD',	'BCD',	'VAR',	19,	"2	Primary Account Number"];
	$self->{'format'}{3}	= ['BCD',	'BCD',	'FIX',	6,	"3	Processing  Code "];
	$self->{'format'}{4}	= ['BCD',	'BCD',	'FIX',	12,	"4	Amount, Transaction"];
	$self->{'format'}{7}	= ['BCD',	'BCD',	'FIX',	14,	"7	Date and Time, Transmission"];
	$self->{'format'}{11}	= ['BCD',	'BCD',	'FIX',	6,	"11	System Trace Audit Number (STAN)"];
	$self->{'format'}{12}	= ['BCD',	'BCD',	'FIX',	12,	"12	Date And Time, Local Transaction"];

	$self->{'format'}{15}	= ['BCD',	'BCD',	'FIX',	4,	"15	"];

	$self->{'format'}{18}	= ['BCD',	'BCD',	'FIX',	2,	"18	Terminal Type"];

	$self->{'format'}{22}	= ['BCD',	'BCD',	'FIX',	0,	"22	Point of Service Sata Code (Service Status)"];
	$self->{'format'}{23}	= ['BCD',	'BCD',	'FIX',	0,	"23	Card Sequence Number"];
	$self->{'format'}{24}	= ['ASC',	'ASC',	'FIX',	32,	"24	Function Code (Service Status)"];
	$self->{'format'}{25}	= ['BCD',	'BCD',	'FIX',	4,	"25	Message Reason Code"];

	$self->{'format'}{30}	= ['BCD',	'BCD',	'FIX',	14,	"30	Actual Balance"];
	$self->{'format'}{31}	= ['BCD',	'BCD',	'VAR',	25,	"31	Acquirer Reference Data (Internal Reference ID)"];
	$self->{'format'}{34}	= ['BCD',	'BCD',	'VAR',	19,	"34	Account Number"];

	$self->{'format'}{35}	= ['ASC',	'ASC',	'VAR',	37,	"35	Track 2 Data"];
	$self->{'format'}{37}	= ['BCD',	'BCD',	'FIX',	12,	"37	Retrieval Reference Number (RRN)"];

	$self->{'format'}{39}	= ['ASC',	'ASC',	'FIX',	3,	"39	Action Code"];
	$self->{'format'}{40}	= ['BCD',	'BCD',	'FIX',	0,	"40	Additional Data"];

	$self->{'format'}{41}	= ['BCD',	'BCD',	'FIX',	8,	"41	Card Acceptor Terminal Identification(Terminal ID)"];
	$self->{'format'}{42}	= ['ASC',	'ASC',	'FIX',	15,	"42	Card Acceptor Identification Code (Merchant ID)"];
	$self->{'format'}{43}	= ['ASC',	'ASC',	'VAR',	99,	"43	Card Acceptor Name/Location"];
	$self->{'format'}{44}	= ['ASC',	'ASC',	'VAR',	999,"44	Additional Response Data "];
	$self->{'format'}{47}	= ['BCD',	'BCD',	'VAR',	99,	"47	Payer ID"];
	$self->{'format'}{48}	= ['BCD',	'BCD',	'VAR',	99,	"48	Additional Data - Private"];

	$self->{'format'}{49}	= ['ASC',	'ASC',	'FIX',	3,	"49	Currency Code"];
	$self->{'format'}{50}	= ['BCD',	'BCD',	'FIX',	0,	"50	Currency Code"];

	$self->{'format'}{52}	= ['ASC',	'ASC',	'FIX',	16,	"52	Personal Identification Number (PIN) Data"];
	$self->{'format'}{53}	= ['ASC',	'ASC',	'VAR',	25,	"53	Security Related Control Information ->Terminal Serial Number"];

	$self->{'format'}{54}	= ['BCD',	'BCD',	'FIX',	14,	"54	Available Balance"];
	$self->{'format'}{55}	= ['BCD',	'BCD',	'FIX',	0,	"55	Integareted Circuit Card System Related Data"];
	$self->{'format'}{59}	= ['BCD',	'BCD',	'FIX',	0,	"59	Merchant Statement (Transport data)"];
	$self->{'format'}{60}	= ['ASC',	'ASC',	'VAR',	999,"60	Additional Data "];
	$self->{'format'}{61}	= ['BCD',	'BCD',	'FIX',	0,	"61	Additional Data"];

	$self->{'format'}{62}	= ['BCD',	'BCD',	'FIX',	6,	"62	Application Version"];
	$self->{'format'}{63}	= ['BCD',	'BCD',	'FIX',	2,	"63	Application Name"];
	$self->{'format'}{74}	= ['BCD',	'BCD',	'FIX',	0,	"74	"];
	$self->{'format'}{86}	= ['BCD',	'BCD',	'FIX',	0,	"86	"];
	$self->{'format'}{95}	= ['BCD',	'BCD',	'FIX',	12,	"95	Replacement Amounts"];
	$self->{'format'}{96}	= ['ASC',	'ASC',	'VAR',	999,"96	Key Management (PINKey + MACKey + PIC Key + Data Key)"];

	$self->{'format'}{100} = ['ASC',	'ASC',	'VAR',	999,"100	Write Command Additional Data"];
	$self->{'format'}{102} = ['BCD',	'BCD',	'FIX',	0,	"102	Account Identification 1 : Account Number (14)"];

	$self->{'format'}{103} = ['ASC',	'ASC',	'VAR',	28,	"103	Account Identification 2"];

	$self->{'format'}{104} = ['ASC',	'ASC',	'VAR',	99,	"104	Terminal Name (32)[Transaction description]"];
	$self->{'format'}{119} = ['BCD',	'BCD',	'FIX',	0,	"119	PIN Code"];
	$self->{'format'}{120} = ['BCD',	'BCD',	'FIX',	0,	"120	Credit Serial Number"];
	$self->{'format'}{121} = ['BCD',	'BCD',	'FIX',	0,	"121	Help Desk Number"];
	$self->{'format'}{122} = ['BCD',	'BCD',	'FIX',	0,	"122	Activation Code"];
	$self->{'format'}{123} = ['BCD',	'BCD',	'FIX',	0,	"123	Merchant Tel Number (25)"];
	$self->{'format'}{124} = ['BCD',	'BCD',	'FIX',	0,	"124	Support Tel Number(25)"];
	$self->{'format'}{125} = ['BCD',	'BCD',	'FIX',	8,	"125	User ID "];
	$self->{'format'}{126} = ['ASC',	'ASC',	'FIX',	1,	"126	Payer ID Status"];

	$self->{'format'}{127} = ['ASC',	'ASC',	'FIX',	8,	"127	Write Command"];
	$self->{'format'}{128} = ['ASC',	'ASC',	'FIX',	16,	"128	Message Authentication Code (MAC)"];
}

1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2009-2017 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut

