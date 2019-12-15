#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use POSIX;
use IO::Socket::INET;
$| = 1;

use Data::Dumper;
use DataPackager::LV;
#use Tools;
use Packet;

if ( @ARGV < 1 ){
	print "usage:\n perl client.pl action [IP [PORT]]\n";
	exit;
}
my $action	= shift;
my $server	= shift || '127.0.0.1';	
my $port	= shift || '9999';


my $typeHash = {
					'01' => ['BIN','BIN','FIX',16],	# LEN
					'0c' => ['BIN','BIN','FIX',8],	# Command // c0: init, c1: balance, c2: cardinfo, c3: activate c4: cashwithdraw c5: cardquary c6: fundtransfer
					'0f' => ['BIN','BIN','FIX',16],	# CRC

					'd0' => ['BCD','ASC','VAR',99],	# port
					'd1' => ['BCD','BCD','VAR',99],	# PAN
					'd2' => ['BCD','ASC','VAR',99],	# Track2
					'd3' => ['BCD','ASC','VAR',99],	# terminal sn
					'd4' => ['BCD','BCD','VAR',99],	# terminal id
					'd5' => ['BCD','BCD','VAR',99],	# Transaction Reference ID
					'd6' => ['BCD','BCD','VAR',99],	# amount
					'd7' => ['BCD','BCD','VAR',99],	# datetime
					'd8' => ['BCD','ASC','VAR',999],# additional data
					'd9' => ['BCD','BCD','VAR',99],	# Action Code

				};

local $@;
eval {

	my $socket = new IO::Socket::INET (
			PeerHost => $server,
			PeerPort => $port,
			Proto => 'tcp'
		);
	die "Cannot create a socket $! \n" unless $socket;

	my ($dataHash);
	my $request = GenerateMessage($typeHash, $dataHash);

	my $hexreq = pack "H*", $request;
	print "# ",$socket->send($hexreq)," bytes send\n";

	my $hexres;
	$socket->recv($hexres,1024);
	$socket->close(); 
	die "No Message recieved \n" if(length($hexres) <= 0 );

	my ($response) = unpack "H*", $hexres;
	chomp($response);
	print "# ","res: ", $response,"\n";

	ProcessMessage($typeHash, $response);
}; if($@){
	print $@,"\n";
	exit;
}	

sub ProcessMessage {
	my ($typeHash, $requestStr) = @_;
	my $f = new DataPackager::LV();
	my ($out,$len,$str);
	my ($tag,$val);
	my $dataHash = {};

	$str = $requestStr;

	($out,$len,$str) = $f->Set(@{$$typeHash{'01'}})->UnPack($str);
	while(length($str) > 4){
		($tag,$len,$str) = $f->Set(@{$$typeHash{'0c'}})->UnPack($str);
		($val,$len,$str) = $f->Set(@{$$typeHash{$tag}})->UnPack($str);
		$$dataHash{$tag} = $val;
	}
	($out,$len,$str) = $f->Set(@{$$typeHash{'0f'}})->UnPack($str);
	return 	$dataHash;
}

sub GenerateMessage {
	my ($typeHash,$dataHash) = @_;
	my $f = new DataPackager::LV();
	my $p1 = new Packet;
	my $p2 = new Packet;

	if( $action eq "c0" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c0");		# init 
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d0");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d0'}})->Pack("COM0");		# port
	}
	elsif( $action eq "c1" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c1");		# balance
	}
	elsif( $action eq "c2" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c2");		# cardinfo
	}
	elsif( $action eq "c3" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c3");		# activate
	}
	elsif( $action eq "c4" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c4");		# cashwithdraw

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d6");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'d6'}})->Pack("10000");		# amount
	}
	elsif( $action eq "c5" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c5");		# cardquary

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d1");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'d1'}})->Pack("6104337809607011");		# pan
	}
	elsif( $action eq "c6" )
	{
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c6");		# fundtransfer

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d1");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'d1'}})->Pack("6104337809607011");		# pan

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d6");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'d6'}})->Pack("10000");		# amount
	}else {
		die "NO Such action: $action\n";
	}
	{
		my $crc = "E5CC";
		$p1 .= $f->Set(@{$$typeHash{'0f'}})->Pack($crc);		# Core command 

		my $hexlen = sprintf( "%04x",length($p1->Data())/2 );
		$p2 .= $f->Set(@{$$typeHash{'01'}})->Pack($hexlen);
		$p2 .= $p1;
		print $p2->Data(),"\n";
	}
	return $p2->Data();
}


