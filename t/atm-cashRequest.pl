#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use POSIX;
use IO::Socket::INET;
$| = 1;

use Data::Dumper;

use Filter;
use Tools;
use Packet;
use BitSet;
use ISO8583;

my $pan		= "6104337809607011";
my $amount	= shift || "100000";
my $date	= strftime "%y%m%d", localtime time;
my $time	= strftime "%H%M%S", localtime time;
my $track2	= "6104337809607011=18041008475842437356";
my $rrn		= shift || "5821";
my $terminalID="10014794";
my $terminalSN="K002T992770A";
my $payerId	= shift || "108";
my $pinBlock= "ede8264805678b73";
my $command = "FF";

my $appVer  = "013400";
my $appName = "23";

my $tpdu	= "00BA000000";
my $MTI		= "1200";
my $process = "010000";

my $server	= '172.16.170.203';
my $port	= '1035'; #1035 1523

my $f = new Filter();  # BINARY BCD ASCII // # FIXED LVAR
my $p1 = new Packet;
my $p2 = new Packet;
my $p3 = new Packet;

my $p4 = new Packet;
my $iso = new ISO8583;

{
	local $@;
	eval {
		my $bitmap1 = new BitSet(128);
		$bitmap1->SetBits(1,2,3,4,7,11,12,18,35,37,41,49,52,53,62,63,103,127,128);
		print "bitmap: ",$bitmap1->GetHexStr(),"\n";# f2304000288098060000000002000003

		$p1 .= $f->Set('BCD','FIXED',4)->Pack($MTI);					# MTI code	1
		$p1 .= $f->Set('ASCII','FIXED',32)->Pack($bitmap1->GetHexStr());# BITMAP
		$p1 .= $f->Set('BCD','LVAR',1)->Pack($pan);						# 2
		$p1 .= $f->Set('BCD','FIXED',6)->Pack($process);				# 3

		$p1 .= $f->Set('BCD','FIXED',12)->Pack($amount);				# 4
		$p1 .= $f->Set('BCD','FIXED',14)->Pack("13980902171032");		# 7
		$p1 .= $f->Set('BCD','FIXED',6)->Pack("005860");				# 11 System Trace Audit Number (STAN)
		$p1 .= $f->Set('BCD','FIXED',12)->Pack("980902171032");			# 12 date time
		$p1 .= $f->Set('BCD','FIXED',2)->Pack("02");					# 18 terminal type
		$p1 .= $f->Set('ASCII','LVAR',2)->Pack($track2);				# 35 track2
		$p1 .= $f->Set('BCD','FIXED',12)->Pack($rrn);					# 37 rrn
		$p1 .= $f->Set('BCD','FIXED',8)->Pack($terminalID);				# 41 terminal Id
		$p1 .= $f->Set('ASCII','FIXED',3)->Pack("IRR");					# 49 currency
		$p1 .= $f->Set('ASCII','FIXED',16)->Pack($pinBlock);			# 52 pinBlock
		$p1 .= $f->Set('ASCII','LVAR',2)->Pack($terminalSN);			# 53 Security Related Control Information ->Terminal Serial Number
		$p1 .= $f->Set('BCD','FIXED',6)->Pack($appVer);					# 62 Application Version
		$p1 .= $f->Set('BCD','FIXED',2)->Pack($appName);				# 63 Application Name
		$p1 .= $f->Set('ASCII','LVAR',2)->Pack("");						# 103 Account Identification 2
		$p1 .= $f->Set('ASCII','FIXED',8)->Pack("FFFFFFFF");			# 127 Write Command

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
#		my $mac=`echo $data | ./crypt.pl`;
#		chomp($mac);
		my $mac = "837df12027e250ab";
		$p2 .= $f->Set('BINARY','FIXED',5)->Pack($tpdu);		# TPDU
		$p2 .= $p1;
		$p2 .= $f->Set('ASCII','FIXED',16)->Pack($mac);			# 128 Message Authentication Code (MAC)
		print $p2->Data(),"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}
}
{
	local $@;
	eval {
		my $hexlen = sprintf( "%04x",length($p2->Data())/2 );
		$p3 .= $f->Set('BINARY','FIXED',2)->Pack($hexlen);
		$p3 .= $p2;
		print $p3->Data(),"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}
}

{
	my $socket = new IO::Socket::INET (
			PeerHost => $server,
			PeerPort => $port,
			Proto => 'tcp'
		);
	die "Cannot create a socket $! \n" unless $socket;

	my $hexreq = pack "H*", $p3->Data();
	print $socket->send($hexreq)," bytes send\n";

	my $hexres;
	$socket->recv($hexres,1024);
	$socket->close(); 

	my ($list) = unpack "H*", $hexres;
	chomp($list);
	print "res: ", $list,"\n";

	$p4 .= $list;
}

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
		my %Fields = map {$_ => 1} @$fields;

		($out,$len,$str) = $f->Set('BCD','LVAR',1)->UnPack($str)	 if (exists($Fields{2}));			# 2
		($out,$len,$str) = $f->Set('BCD','FIXED',6)->UnPack($str)	 if (exists($Fields{3}));			# 3
		($out,$len,$str) = $f->Set('BCD','FIXED',14)->UnPack($str)	 if (exists($Fields{7}));			# 7
		($out,$len,$str) = $f->Set('BCD','FIXED',6)->UnPack($str)	 if (exists($Fields{11}));			# 11
		($out,$len,$str) = $f->Set('BCD','FIXED',12)->UnPack($str)	 if (exists($Fields{12}));			# 12 date.time
		($out,$len,$str) = $f->Set('BCD','FIXED',2)->UnPack($str)	 if (exists($Fields{18}));			# 18 terminal type
		($out,$len,$str) = $f->Set('BCD','FIXED',12)->UnPack($str)	 if (exists($Fields{37}));			# 37 rrn
		($out,$len,$str) = $f->Set('ASCII','FIXED',3)->UnPack($str)	 if (exists($Fields{39}));			# 39 code
		($out,$len,$str) = $f->Set('BCD','FIXED',8)->UnPack($str)	 if (exists($Fields{41}));			# 41 terminal Id

		($out,$len,$str) = $f->Set('ASCII','LVAR',3)->UnPack($str)	 if (exists($Fields{100}));			# 100 Write Command Additional Data
		($out,$len,$str) = $f->Set('ASCII','LVAR',2)->UnPack($str)	 if (exists($Fields{103}));			# 103 Account Identification 2

		($out,$len,$str) = $f->Set('ASCII','FIXED',8)->UnPack($str)	 if (exists($Fields{127}));			# 127 Write Command
		($out,$len,$str) = $f->Set('ASCII','FIXED',16)->UnPack($str) if (exists($Fields{128}));			# 128 Message Authentication Code (MAC)

		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}
=pod
#00ba00BA0000001200463233303430303032383830393830363030303030303030303230303030303316610433780960701101000000000010000013980623161732005860980623161732023337363130343333373830393630373031313d3138303431303038343735383432343337333536000000005821100147944952526564653832363438303536373862373331324b3030325439393237373041013400233030464646464646464638333764663132303237653235306162

# req:  
BA 00BA0000001200463233303430303032383830393830363030303030303030303230303030303316610433780960701101000000000010000013980623161732005860980623161732023337363130343333373830393630373031313D3138303431303038343735383432343337333536000000005821100147944952526564653832363438303536373862373331324B3030325439393237373041013400233030464646464646464638333764663132303237653235306162
00BA0000001200463233303430303032383830393830363030303030303030303230303030303316610433780960701101000000000010000013980623161732005860980623161732023337363130343333373830393630373031313d3138303431303038343735383432343337333536000000005821100147944952526564653832363438303536373862373331324b3030325439393237373041013400233030464646464646464638333764663132303237653235306162
# res: 
#
B5 00BA0000001210463233303430303630413830383430363030303030303030313230303030303316610433780960701101000000000010000020190914161734005860980623161732022B00000123456711011401749261000000005821303030100147944952522B000001234567000015123033371607021E03000000000B1A001E050000000000003D04214600022A300000000000136202023030303032303030303039313365363762643437333939646237
=cut


