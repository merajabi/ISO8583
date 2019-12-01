#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use DataFormat::ISO8583;
use Tools;
use Packet;
#/*
# *  BINARY: FEDCBA9876543210
# *  BCD:	1234567890
# *  ASCII:	zxclkjsdfouewuoaseuidweigu98234-;akslijwad982137
# */

# FIXED LVAR

{
	local $@;
	eval {
		my $f = new DataPackager::LV({'format'=>'BIN','type'=>'FIX','length'=>3});
		my $packed;
		$packed = $f->Pack("CBA987");
		print $packed,"\n";
		my ($unpacked,$len) = $f->UnPack($packed);
		print $unpacked," ",$len,"\n";
	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $p = new Packet;
		#$p->AddData($f->Set('BINARY','LVAR',2)->Pack("CBA987"));
		$p .= $f->Set('BIN','VAR',2)->Pack("CBA987");
		print $p->Data(),"\n";
	}; if($@){
		print $@,"\n";
	}
}

