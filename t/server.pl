#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use POSIX;
use IO::Socket::INET;
$| = 1;

use Data::Dumper;
use DataPackager::LV;
use Packet;

my $server	= shift || '127.0.0.1';	
my $port	= shift || '9999';

my $typeHash = {
					'01' => ['BIN','BIN','FIX',16],	# LEN
					'0c' => ['BIN','BIN','FIX',8],	# Command // c0: init,  c1: balance
					'0f' => ['BIN','BIN','FIX',16],	# CRC

					'd0' => ['BCD','ASC','VAR',99],	# port
					'd1' => ['BCD','BCD','VAR',99],	# PAN
					'd2' => ['BCD','ASC','VAR',99],	# Track2
					'd3' => ['BCD','ASC','VAR',99],	# terminal sn
					'd4' => ['BCD','BCD','VAR',99],	# terminal id
					'd5' => ['BCD','BCD','VAR',99],	# Internal Reference ID
					'd6' => ['BCD','BCD','VAR',99],	# amount
					'd7' => ['BCD','BCD','VAR',99],	# datetime
					'd8' => ['BCD','ASC','VAR',999],# additional data
					'd9' => ['BCD','BCD','VAR',99],	# Action Code
				};

local $@;
eval {

	# creating a listening socket
	my $socket = new IO::Socket::INET (
		LocalHost => $server ,
		LocalPort => $port,
		Proto => 'tcp',
		Listen => 5,
		Reuse => 1
	);
	die "Cannot create a socket $! \n" unless $socket;

	print "server waiting for client connection on port $port\n";

	while(1) {
		local $@;
		eval {
			# waiting for a new client connection
			my $client_socket = $socket->accept();

			# get information about a newly connected client
			my $client_address = $client_socket->peerhost();
			my $client_port = $client_socket->peerport();
			print "connection from $client_address:$client_port\n";

			my $request;
			$client_socket->recv($request,1024);
			my ($requestStr) = unpack "H*", $request;
			print "recv: ",length($request)," bytes\n";
			print "$requestStr\n";

			my $dataHash = ProcessMessage($typeHash,$requestStr);
			my $responseStr = GenerateMessage($typeHash,$dataHash);

			my $response = pack "H*", $responseStr;
			print "send: ",$client_socket->send($response)," bytes\n";
			print "$responseStr\n";

			$client_socket->close(); 
		}; if($@){
			print $@,"\n";
		}	

	}
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

	if($$dataHash{'0c'} eq "c0" ){ # init
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c0");		# init 

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d3");		# terminal sn
		$p1 .= $f->Set(@{$$typeHash{'d3'}})->Pack("3G569514");		

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d4");		# terminal Id
		$p1 .= $f->Set(@{$$typeHash{'d4'}})->Pack("21008251");		

	}elsif ($$dataHash{'0c'} eq "c1") { # balance
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c1");		# balance

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d2");				# tag
		$p1 .= $f->Set(@{$$typeHash{'d2'}})->Pack("6104337809607011=18041008475842437356");	# track2

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d5");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d5'}})->Pack("011406414292");	# refId

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d6");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d6'}})->Pack("200000");	# amount
		
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d7");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d7'}})->Pack("13980918170248");	# datetime

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d9");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d9'}})->Pack("000");	# Action Code

	}elsif ($$dataHash{'0c'} eq "c2") { # cardinfo
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c2");		# cardinfo

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d2");				# tag
		$p1 .= $f->Set(@{$$typeHash{'d2'}})->Pack("6104337809607011=18041008475842437356");	# track2

	}elsif ($$dataHash{'0c'} eq "c3") { # activate
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c3");		# activate

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d5");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d5'}})->Pack("011406414292");	# refId

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d7");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d7'}})->Pack("13980918170248");	# datetime

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d9");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d9'}})->Pack("000");	# Action Code

	}elsif ($$dataHash{'0c'} eq "c4") { # cashwithdraw
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c4");		# cashwithdraw

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d2");				# tag
		$p1 .= $f->Set(@{$$typeHash{'d2'}})->Pack("6104337809607011=18041008475842437356");	# track2

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d5");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d5'}})->Pack("011406414292");	# refId

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d6");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d6'}})->Pack("190000");	# amount

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d7");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d7'}})->Pack("13980918170248");	# datetime

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d9");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d9'}})->Pack("000");	# Action Code
	
	}elsif ($$dataHash{'0c'} eq "c5") { # cardquary
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c5");		# cardquary

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d5");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d5'}})->Pack("011406414292");	# refId

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d7");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d7'}})->Pack("13980918170248");	# datetime

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d8");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d8'}})->Pack("Raha Rajabi");	# additional data

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d9");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d9'}})->Pack("000");	# Action Code

	}elsif ($$dataHash{'0c'} eq "c6") { # fundtransfer
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("0c");		# tag  
		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("c6");		# fundtransfer

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d2");				# tag
		$p1 .= $f->Set(@{$$typeHash{'d2'}})->Pack("6104337809607011=18041008475842437356");	# track2

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d5");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d5'}})->Pack("011406414292");	# refId

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d6");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d6'}})->Pack("190000");	# amount

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d7");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d7'}})->Pack("13980918170248");	# datetime

		$p1 .= $f->Set(@{$$typeHash{'0c'}})->Pack("d9");		# tag
		$p1 .= $f->Set(@{$$typeHash{'d9'}})->Pack("000");	# Action Code
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

