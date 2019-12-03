#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use Tools;
use Packet;
use Bitmap;

my $f = new DataPackager::LV();  # BIN BCD ASC # FIX VAR

my $p1 = new Packet;
my $p2 = new Packet;

{
	local $@;
	eval {
		{
			my $bitmap = new Bitmap(64);
			my $fields = [ 3, 4, 7, 11, 14, 42, 64];
			$bitmap->SetBits(@$fields);
			print "bitmap: ",$bitmap->GetHexStr(),"\n";

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("0100");				# MTI code
			$p1 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($bitmap->GetHexStr());# BITMAP

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 6)->Pack("003000");				# 3 Processing Code
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 12)->Pack("100");				# 4 Transaction Amount
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 10)->Pack("1203204821");		# 7 Transmission Date & Time
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 6)->Pack("5860");				# 11 Systems Trace Audit Number (STAN)
			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack("2108");				# 14 Expiration Date
			$p1 .= $f->Set('ASC', 'ASC', 'FIX', 15)->Pack("1234567890");		# 42 Card Acceptor Identification Code

			print "ISO Message without MAC: ", $p1->Data(),"\n";
		}
		{
			my $data = $p1->Data();
			my $mac=`./crypt.pl "MAC" "0123456789ABCDEF" $data 16`;
			chomp($mac);

			# ISO8583 messaging has no routing information, so is sometimes used with a TPDU header. 
			#$p2 .= $f->Set('BIN', 'BIN', 'FIX', 40)->Pack("FEDCBA9876");		# TPDU	uncomment this line if your implimentation need TPDU header
																				
			$p2 .= $p1;
			$p2 .= $f->Set('BIN', 'BIN', 'FIX', 64)->Pack($mac);				# 64 or 128 Message Authentication Code (MAC)

			print "ISO Message: ", $p2->Data(), "\n";
		}
	}; if($@){
		print $@,"\n";
		exit;
	}
}

{
	local $@;
	eval {
		my ($out,$len,$str);
		my $bitmap = new Bitmap(64);
		$str = $p2->Data();

		#($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 40)->UnPack($str);		# TPDU	uncomment this line if your implimentation need TPDU header
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# MTI
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# bitmap

		$bitmap->SetHexStr($out);
		my $fields = $bitmap->GetBits();
		print "bitmap fields: ",join(' ',@$fields),"\n";

		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 6)->UnPack($str);		# 3 Processing Code
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 12)->UnPack($str);		# 4 Transaction Amount
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 10)->UnPack($str);		# 7 Transmission Date & Time
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 6)->UnPack($str);		# 11 Systems Trace Audit Number (STAN)
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# 14 Expiration Date
		($out,$len,$str) = $f->Set('ASC', 'ASC', 'FIX', 15)->UnPack($str);		# 42 Card Acceptor Identification Code
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 64)->UnPack($str);		# 64 or 128 Message Authentication Code (MAC)

		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}

