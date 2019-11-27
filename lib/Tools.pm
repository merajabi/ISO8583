package Tools;

use strict;
use warnings;
use Exporter;

our @ISA= qw( Exporter );

# these are exported by default.
our @EXPORT = qw( toString HexToStr StrToHex PaddedFixedLenString HexString HexToAscii AsciiToHex );

sub toString {
	my ($val)=@_;
	my $str;
	$str= sprintf("%.0lf",$val);
	return $str;
}
sub HexToStr {
	my ($in)=@_;
	my ($str) = unpack "H*", $in;
	return $str;
}

sub StrToHex {
	my ($in)=@_;
	my $hex = pack "H*", $in;
	return $hex;
}

sub HexToAscii {
	return StrToHex(@_);
}
sub AsciiToHex {
	return HexToStr(@_);
}
sub HexString {
	return HexToStr(@_);
}

sub PaddedFixedLenString {
	my ($val,$len,$ch)=@_;
	$ch  ||= '0';
#	$len ||= 0;
	my $str=($ch x ($len-length($val))).$val;
	return $str;
}

1;

