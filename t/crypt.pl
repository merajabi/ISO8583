#!/usr/bin/perl -w

use Data::Dumper;
use Modern::Perl;

#use Digest::EMAC qw(emac hexdigest base64digest);
use Crypt::DES;
#use Crypt::TripleDES::CBC;
#use Digest::CMAC;

my $crypto = "Crypt::DES"; # "Crypt::DES" Crypt::Blowfish
my $blocksize = 8;

my $method =  shift;
my $keyStr = shift;

if ($method eq "MAC"){
	my $str = shift;
	my $outlen = shift;
	my $macBlock = MACBlock($crypto, $keyStr, $blocksize, $str);
	print substr($macBlock,0,$outlen),"\n";
}elsif ($method eq "PIN") {
	my $pin = shift;
	my $pan = shift;
	my $pinBlock = PINBlock($crypto, $keyStr, $pin, $pan );
	print $pinBlock,"\n";
}

sub CBCENCMAC {
	my ($crypto,$blocksize,$key,$text) = @_;

	my $cipher = $crypto->new($key);
	my $iv= pack "H*", "0000000000000000";
	my $mid;
	my $encText;
	for(my $i=0; $i < length($text); $i += $blocksize ) {
		my $temp = substr($text,$i,$blocksize);
		#$mid = $temp; ECB 
		$mid = $iv ^ $temp; # CBC
		#print "temp: ", unpack( "H*", $temp), "\n";
		#print "mid: ",unpack( "H*", $mid), "\n";
		#print "iv: ",unpack( "H*", $iv), "\n";
		$iv = $cipher->encrypt($mid);
		$encText.=$iv;
	}
	return ($iv,$encText);
}

sub ECBENCMAC {
	my ($crypto,$blocksize,$key,$text) = @_;

	my $cipher = $crypto->new($key);
	my $iv= pack "H*", "0000000000000000";
	my $mid;
	my $encText;
	for(my $i=0; $i < length($text); $i += $blocksize ) {
		my $temp = substr($text,$i,$blocksize);
		$mid = $temp; # ECB 
		#$mid = $iv ^ $temp; # CBC
		#print "temp: ", unpack( "H*", $temp), "\n";
		#print "mid: ",unpack( "H*", $mid), "\n";
		#print "iv: ",unpack( "H*", $iv), "\n";
		$iv = $cipher->encrypt($mid);
		$encText.=$iv;
	}
	return ($iv,$encText);
}

sub MACBlock {
	my ($crypto, $keyStr, $blocksize, $str) = @_;

	my $len = length($str);
	my $pad = ( $len % 16 > 0 )? 16 - $len % 16 : 0 ;
	$str .= '30' x ($pad/2);

	my $text = pack "H*", $str;
	my $key = pack "H*", $keyStr;

	my ($mac,$encText) = CBCENCMAC($crypto,$blocksize,$key,$text);

	my ($out) = unpack "H*", $mac;

	return $out;
}

sub PINBlock {
	my ($crypto, $keyStr, $pin, $pan)= @_;

	my $panStr = "0000".substr($pan,3,12);
	my $pinStr = sprintf("%02d",length($pin)).$pin.('F'x(16-2-length($pin)));

	my $pinKey = pack "H*", $keyStr;
	my $panBin = pack "H*", $panStr;
	my $pinBin = pack "H*", $pinStr;

	my $plainPinBlock = $panBin ^ $pinBin;

	my $cipher = $crypto->new($pinKey);
	my $pinBlock = $cipher->encrypt($plainPinBlock);

	my $pinBlockStr = unpack "H*", $pinBlock;
	return $pinBlockStr;
}

sub Encrypt {
	my ($crypto,$keyStr,$decStr) = @_;
	my $key = pack "H*", $keyStr;
	my $dec = pack "H*", $decStr;
	my $cipher = $crypto->new($key);
	my $enc = $cipher->decrypt($dec);
	my ($encStr) = unpack "H*", $enc;
	print $encStr,"\n";
	return $encStr
}

sub Decrypt {
	my ($crypto,$keyStr,$encStr) = @_;
	my $key = pack "H*", $keyStr;
	my $enc = pack "H*", $encStr;
	my $cipher = $crypto->new($key);
	my $dec = $cipher->decrypt($enc);
	my ($decStr) = unpack "H*", $dec;
	print $decStr,"\n";
	return $decStr
}

