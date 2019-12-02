#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use POSIX;
use IO::Socket::INET;
$| = 1;

use Data::Dumper;

use DataPackager::LV;
use DataFormat::ISO8583;
use Tools;
use Packet;
use BitSet;

my $date	= strftime "%y%m%d", localtime time;
my $time	= strftime "%H%M%S", localtime time;

my $server	= '127.0.0.1';
my $port	= '9999'; 

my $f = new DataPackager::LV();  # BINARY BCD ASCII // # FIXED LVAR
my $iso = new DataFormat::ISO8583;

my $p1 = new Packet;
my $p2 = new Packet;
my $p3 = new Packet;
my $p4 = new Packet;


{
	local $@;
	eval {
		my $bitmap1 = new BitSet(64);
		my $fields = [35,64];
		print "iso fields: ", join(',',@$fields),"\n";

		$bitmap1->SetBits(@$fields);
		print "bitmap: ",$bitmap1->GetHexStr(),"\n";

		$p1 .= $f->Set($iso->FieldFormat(1))->Pack("1200");					# MTI code	1
		$p1 .= $f->Set('BIN','FIX',8)->Pack($bitmap1->GetHexStr());	# BITMAP
#		$p1 .= $f->Set($iso->FieldFormat(2))->Pack("1234567812345678");		# 2
#		$p1 .= $f->Set($iso->FieldFormat(3))->Pack("310000");				# 3

#		$p1 .= $f->Set($iso->FieldFormat(4))->Pack("1000");					# 4
#		$p1 .= $f->Set($iso->FieldFormat(7))->Pack("1126170140");		# 7
#		$p1 .= $f->Set($iso->FieldFormat(11))->Pack("005860");				# 11 System Trace Audit Number (STAN)
#		$p1 .= $f->Set($iso->FieldFormat(12))->Pack("170140");		# 12 date time
#		$p1 .= $f->Set($iso->FieldFormat(18))->Pack("0002");					# 18 terminal type
		$p1 .= $f->Set($iso->FieldFormat(35))->Pack("1234567812345678=1234567812345678000");				# 35 track2
#		$p1 .= $f->Set($iso->FieldFormat(37))->Pack("123");					# 37 rrn
#		$p1 .= $f->Set($iso->FieldFormat(41))->Pack("12345678");			# 41 terminal Id
#		$p1 .= $f->Set($iso->FieldFormat(49))->Pack("364");					# 49 currency IRR
#		$p1 .= $f->Set($iso->FieldFormat(52))->Pack("fc881881b4b1947b");	# 52 pinBlock  ./crypt.pl PIN 0123456789ABCDEF 1234 1234567812345678
#		$p1 .= $f->Set($iso->FieldFormat(53))->Pack("1234567812345678");	# 53 Security Related Control Information ->Terminal Serial Number
#		$p1 .= $f->Set($iso->FieldFormat(62))->Pack("010203");				# 62 Application Version
#		$p1 .= $f->Set($iso->FieldFormat(63))->Pack("01");					# 63 Application Name
#		$p1 .= $f->Set($iso->FieldFormat(103))->Pack("");					# 103 Account Identification 2
#		$p1 .= $f->Set($iso->FieldFormat(127))->Pack("FFFFFFFF");			# 127 Write Command

		print $p1->Data(),"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}
}
{
	local $@;
	eval {
		my $data = $p1->Data();
		my $mac=`./crypt.pl "MAC" "0123456789ABCDEF" $data 16`;
#		my $mac=`./crypt.pl "MAC" $macKey $data 8`;
		chomp($mac);
#		$p2 .= $f->Set('BIN','FIX',5)->Pack("60050A0000");					# TPDU
		$p2 .= $p1;
		$p2 .= $f->Set($iso->FieldFormat(64))->Pack($mac);					# 128 Message Authentication Code (MAC)
		print $p2->Data(),"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}
}

=pod
{
	local $@;
	eval {
		my ($out,$len,$str);
		my $bitmap2 = new BitSet(128);
		$str = $p4->Data();

		($out,$len,$str) = $f->Set('BINARY','FIXED',2)->UnPack($str);		# len
		($out,$len,$str) = $f->Set('BINARY','FIXED',5)->UnPack($str);		# tpdu
		($out,$len,$str) = $f->Set('BCD','FIXED',4)->UnPack($str);			# MTI
		($out,$len,$str) = $f->Set('ASCII','FIXED',32)->UnPack($str);		# bitmap

		$bitmap2->SetHexStr($out);
		my $fields = $bitmap2->GetFields();
		print join(' ',@$fields),"\n";

		foreach my $key (@$fields){
			if($key != 1) {
				print "feild: ",$key,"\n";
				($out,$len,$str) = $f->Set($iso->FieldFormat($key))->UnPack($str);
			}
		}
		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}
=cut
