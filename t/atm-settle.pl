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

my $date	= shift;
my $time	= shift;
my $refId  	= shift;
my $rrn		= shift;
my $terminalID="21009517";
my $MTI		= "03";

my $tpdu	= "60050A0000";
my $server	= '172.16.170.203';
my $port	= '1523'; #1035

my $f = new Filter();  # BINARY BCD ASCII // # FIXED LVAR
my $p1 = new Packet;
my $p2 = new Packet;
my $p3 = new Packet;

my $p4 = new Packet;
{
	local $@;
	eval {
		my $bitmap1 = new BitSet(64);
		$bitmap1->SetBits(12,31,37,41,64);
		print "bitmap: ",$bitmap1->GetHexStr(),"\n";

		$p1 .= $f->Set('BCD','FIXED',2)->Pack($MTI);					# 0 MTI code
		$p1 .= $f->Set('BINARY','FIXED',8)->Pack($bitmap1->GetHexStr());# 1 BITMAP
		$p1 .= $f->Set('BCD','FIXED',12)->Pack($date.$time);			# 12
		$p1 .= $f->Set('BCD','LVAR',1)->Pack($refId);					# 31
		$p1 .= $f->Set('BCD','FIXED',4)->Pack($rrn);					# 37
		$p1 .= $f->Set('BCD','FIXED',8)->Pack($terminalID);				# 41
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
		my $mac=`echo $data | ./crypt.pl`;
		chomp($mac);
		$p2 .= $f->Set('BINARY','FIXED',5)->Pack($tpdu);		# TPDU
		$p2 .= $p1;
		$p2 .= $f->Set('BINARY','FIXED',4)->Pack($mac);			# 64
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
		$p3 .= $f->Set('BINARY','FIXED',2)->Pack($hexlen);		# len
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
		my $bitmap2 = new BitSet(64);
		$str = $p4->Data();

		($out,$len,$str) = $f->Set('BINARY','FIXED',2)->UnPack($str);		# len
		($out,$len,$str) = $f->Set('BINARY','FIXED',5)->UnPack($str);		# tpdu
		($out,$len,$str) = $f->Set('BCD','FIXED',2)->UnPack($str);			# MTI
		($out,$len,$str) = $f->Set('BINARY','FIXED',8)->UnPack($str);		# bitmap

		$bitmap2->SetHexStr($out);
		my $fields = $bitmap2->GetFields();
		print join(' ',@$fields),"\n";
		my %Fields = map {$_ => 1} @$fields;

		($out,$len,$str) = $f->Set('BCD','FIXED',12)->UnPack($str)	 if (exists($Fields{12}));			# 12 date.time
		($out,$len,$str) = $f->Set('BCD','LVAR',1)->UnPack($str)	 if (exists($Fields{31}));			# 31 refid
		($out,$len,$str) = $f->Set('BCD','FIXED',4)->UnPack($str)	 if (exists($Fields{37}));			# 37 rrn
		($out,$len,$str) = $f->Set('BCD','FIXED',4)->UnPack($str)	 if (exists($Fields{39}));			# 39 code
		($out,$len,$str) = $f->Set('BCD','FIXED',8)->UnPack($str)	 if (exists($Fields{41}));			# 41 terminal Id	
		($out,$len,$str) = $f->Set('BINARY','FIXED',4)->UnPack($str) if (exists($Fields{64}));			# 64 mac
		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}


