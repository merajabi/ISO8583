package DataFormat::ISO8583vbpmPOS;

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
	$self->{'fields'}{"01Q"} = { 4 => "M", 12 => "M", 35 => "M", 37 => "M", 41 => "M", 52 => "M", 63 => "M", 64 => "M"};			# Sale
	$self->{'fields'}{"01A"} = {12 => "M", 31 => "M", 37 => "M", 39 => "M", 41 => "M", 44 => "O", 58 => "M", 59 => "M", 64 => "M"};

	$self->{'fields'}{"02Q"} = { 2 => "M", 12 => "M", 25 => "M", 37 => "M", 41 => "M", 64 => "M"};					# Reverse
	$self->{'fields'}{"02A"} = {12 => "M", 37 => "M", 39 => "M", 41 => "M", 64 => "M"};

	$self->{'fields'}{"03Q"} = {12 => "M", 31 => "M", 37 => "M", 41 => "M", 64 => "M"};						# Settle
	$self->{'fields'}{"03Q"} = {12 => "M", 37 => "M", 39 => "M", 41 => "M", 64 => "M"};

	$self->{'fields'}{"04Q"} = {12 => "M", 35 => "M", 37 => "M", 41 => "M", 52 => "M", 63 => "M", 64 => "M"};				# Balance
	$self->{'fields'}{"04A"} = {12 => "M", 30 => "M", 31 => "M", 37 => "M", 39 => "M", 41 => "M", 44 => "M", 54 => "M", 64 => "M"};

	$self->{'fields'}{"38Q"} = {12 => "M", 37 => "M", 40 => "M", 41 => "M", 60 => "M", 62 => "M", 63 => "M", 64 => "M"};			# Init
	$self->{'fields'}{"38A"} = {12 => "M", 24 => "M", 37 => "M", 39 => "M", 40 => "M", 41 => "M", 42 => "M", 43 => "M", 44 => "M", 53 => "M", 59 => "M", 60 => "M", 64 => "M"};

}

sub InitFormats {
	my ($self) = @_;
	$self->{'format'}{'TPDU'}	= ['BIN',	'BIN',	'FIX',	40,	"TPDU"];
	$self->{'format'}{'MTI'}	= ['BCD',	'BCD',	'FIX',	2,	"Message Type Identifier"];
	$self->{'format'}{'BITMAP'}	= ['BIN',	'BIN',	'FIX',	64,	"BITMAP"];

	$self->{'format'}{2}	= ['BCD',	'BCD',	'VAR',	19,	"2	Primary Account Number"];
#	$self->{'format'}{3}	= ['BCD',	'BCD',	'FIX',	6,	"3	Processing  Code "];
	$self->{'format'}{4}	= ['BCD',	'BCD',	'FIX',	12,	"4	Amount, Transaction"];
#	$self->{'format'}{7}	= ['BCD',	'BCD',	'FIX',	14,	"7	Date and Time, Transmission"];
#	$self->{'format'}{11}	= ['BCD',	'BCD',	'FIX',	6,	"11	System Trace Audit Number (STAN)"];
	$self->{'format'}{12}	= ['BCD',	'BCD',	'FIX',	12,	"12	Date And Time, Local Transaction"];

#	$self->{'format'}{15}	= ['BCD',	'BCD',	'FIX',	4,	"15	"];

#	$self->{'format'}{18}	= ['BCD',	'BCD',	'FIX',	2,	"18	Terminal Type"];

#	$self->{'format'}{22}	= ['BCD',	'BCD',	'FIX',	0,	"22	Point of Service Sata Code (Service Status)"];
#	$self->{'format'}{23}	= ['BCD',	'BCD',	'FIX',	0,	"23	Card Sequence Number"];
	$self->{'format'}{24}	= ['BIN',	'BIN',	'FIX',	16,	"24	Function Code (Service Status)"];
	$self->{'format'}{25}	= ['BCD',	'BCD',	'FIX',	4,	"25	Message Reason Code"];

	$self->{'format'}{30}	= ['BCD',	'BCD',	'FIX',	14,	"30	Actual Balance"];
	$self->{'format'}{31}	= ['BCD',	'BCD',	'VAR',	25,	"31	Acquirer Reference Data (Internal Reference ID)"];
#	$self->{'format'}{34}	= ['BCD',	'BCD',	'FIX',	0,	"34	Account Number"];

	$self->{'format'}{35}	= ['ASC',	'ASC',	'VAR',	37,	"35	Track 2 Data"];
	$self->{'format'}{37}	= ['BCD',	'BCD',	'FIX',	4,	"37	Retrieval Reference Number (RRN)"];

	$self->{'format'}{39}	= ['BCD',	'BCD',	'FIX',	4,	"39	Action Code"];
#	$self->{'format'}{40}	= ['BCD',	'BCD',	'VAR',	1,	"40	Additional Data"];

	$self->{'format'}{41}	= ['BCD',	'BCD',	'FIX',	8,	"41	Card Acceptor Terminal Identification(Terminal ID)"];
	$self->{'format'}{42}	= ['ASC',	'ASC',	'FIX',	15,	"42	Card Acceptor Identification Code (Merchant ID)"];
	$self->{'format'}{43}	= ['ASC',	'ASC',	'VAR',	99,	"43	Card Acceptor Name/Location"];
	$self->{'format'}{44}	= ['ASC',	'ASC',	'VAR',	99,	"44	Additional Response Data"];
#	$self->{'format'}{47}	= ['BCD',	'BCD',	'VAR',	1,	"47	Payer ID"];
#	$self->{'format'}{48}	= ['BCD',	'BCD',	'FIX',	0,	"48	Additional Data - Private"];

#	$self->{'format'}{49}	= ['ASC',	'ASC',	'FIX',	3,	"49	Currency Code"];
#	$self->{'format'}{50}	= ['BCD',	'BCD',	'FIX',	0,	"50	Currency Code"];

	$self->{'format'}{52}	= ['BIN',	'BIN',	'FIX',	64,	"52	Personal Identification Number (PIN) Data"];
	$self->{'format'}{53}	= ['ASC',	'ASC',	'VAR',	999,"53	Security Related Control Information ->Terminal Serial Number (PINKEY + MACKEY + DATAKEY + MMK)" ];

	$self->{'format'}{54}	= ['BCD',	'BCD',	'FIX',	14,	"54	Available Balance"];
#	$self->{'format'}{55}	= ['BCD',	'BCD',	'FIX',	0,	"55	Integareted Circuit Card System Related Data"];
	$self->{'format'}{58}	= ['ASC',	'ASC',	'VAR',	999,"58 Additional Data (Send)"];
	$self->{'format'}{59}	= ['ASC',	'ASC',	'VAR',	999,"59	Merchant Statement (Transport data)"];
	$self->{'format'}{60}	= ['ASC',	'ASC',	'VAR',	999,"60	Additional Data "];
#	$self->{'format'}{61}	= ['BCD',	'BCD',	'FIX',	0,	"61	Additional Data"];

	$self->{'format'}{62}	= ['BCD',	'BCD',	'FIX',	10,	"62	Application Version"];
	$self->{'format'}{63}	= ['ASC',	'BIN',	'VAR',	32,	"63	Write Command"];

	$self->{'format'}{64} 	= ['BIN',	'BIN',	'FIX',	32,	"64	Message Authentication Code (MAC)"];
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

