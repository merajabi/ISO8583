#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use Tools;
use Packet;
use Bitmap;
use DataPackager::LV;
use DataFormat::ISO8583v87;

my $f = new DataPackager::LV();  # BIN BCD ASC # FIX VAR
my $iso = new DataFormat::ISO8583v87();
my $p1 = new Packet;
my $p2 = new Packet;

my $dataHash={};
my $mti;
my $tpdu;
my $bitlen;
my $macKey;
{
	local $@;
	eval {
		{

			while(my $line = <STDIN>) {
				chomp($line);
				$line =~ s/^\s+//;
				next if( ! length $line or $line =~ m/^#/);
				if($line =~ m/^(\d+)\s*:\s*(.+)/){
					$$dataHash{$1} = $2;
				}elsif ($line =~ m/^(MTI|TPDU)\s*:\s*(.+)/i){
					$$dataHash{uc $1} = $2;
				}else{
					die "Invalid input format: $line\n"
				}
			}
			die "No MTI code provided" if( ! exists $$dataHash{"MTI"});
			$mti = $$dataHash{"MTI"};
			delete $$dataHash{"MTI"};
			
			if(exists $$dataHash{"TPDU"}){
				$tpdu = $$dataHash{"TPDU"}; 
				delete $$dataHash{"TPDU"};
			}

			if(exists $$dataHash{"64"}){
				$bitlen = 64;
				$macKey = $$dataHash{"64"};
			}elsif(exists $$dataHash{"128"}){
				$bitlen = 128;
				$macKey = $$dataHash{"128"};
			}else{
				die "Message authentication code 64 or 128 not exists.\n";
			}


			my $bitmap = new Bitmap($bitlen);
			$bitmap->SetBits(keys %$dataHash);
			print "bitmap fields: ",join(' ',@{$bitmap->GetBits()}),"\n";
			print "bitmap: ",$bitmap->GetHexStr(),"\n";

			my $fieldList = [ sort { $a <=> $b } @{$iso->GetBits($mti)} ];
			my $fieldType = $iso->GetFields($mti);

			$p1 .= $f->Set('BCD', 'BCD', 'FIX', 4)->Pack($mti);				# MTI code
			$p1 .= $f->Set('BIN', 'BIN', 'FIX', $bitlen)->Pack($bitmap->GetHexStr());# BITMAP

			foreach my $key (@$fieldList) {
				next if ($key == 64 or $key == 128 );
				print "key: $key\n";
				die "Mandatory field $key must be present in message" if( $$fieldType{$key} eq "M" and ! exists($$dataHash{$key}) );
				$p1 .= $f->Set($iso->FieldFormat($key))->Pack($$dataHash{$key}) if ( exists($$dataHash{$key}) );
			}
			print "ISO Message without MAC: ", $p1->Data(),"\n";
		}
		{
			my $data = $p1->Data();
			my $mac=`./crypt.pl "MAC" $macKey $data 16`;				# assume the MAC Key is = 0123456789ABCDEF
			chomp($mac);

			# ISO8583 messaging has no routing information, so is sometimes used with a TPDU header. 
			$p2 .= $f->Set('BIN', 'BIN', 'FIX', 40)->Pack($$dataHash{"TPDU"}) if ( exists($$dataHash{"TPDU"}) );		# TPDU	uncomment this line if your implimentation need TPDU header
																				
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
		my $bitmap = new Bitmap($bitlen);
		$str = $p2->Data();

		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', 40)->UnPack($str) if ( exists($$dataHash{"TPDU"}) );		# TPDU	uncomment this line if your implimentation need TPDU header
		($out,$len,$str) = $f->Set('BCD', 'BCD', 'FIX', 4)->UnPack($str);		# MTI
		($out,$len,$str) = $f->Set('BIN', 'BIN', 'FIX', $bitlen)->UnPack($str);		# bitmap

		$bitmap->SetHexStr($out);
		my $fieldList = $bitmap->GetBits();
		print "bitmap fields: ",join(' ',@$fieldList),"\n";

		foreach my $key (@$fieldList) {
			($out,$len,$str) = $f->Set($iso->FieldFormat($key))->UnPack($str);
		}

		print $str,"\n";
	}; if($@){
		print $@,"\n";
		exit;
	}	
}

