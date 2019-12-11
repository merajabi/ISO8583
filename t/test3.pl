#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use DataFormat::ISO8583v03;
use Tools;
use Packet;
#/*
# *  BINARY: FEDCBA9876543210
# *  BCD:	1234567890
# *  ASCII:	zxclkjsdfouewuoaseuidweigu98234-;akslijwad982137
# */

{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $out = $f->Set('BIN','BIN','FIX',64)->Pack("0123456789ABCDEF");
		print $out,"\n";
	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $out = $f->Set('BCD','BCD','FIX',12)->Pack("1000");
		print $out,"\n";
	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $out = $f->Set('ASC','ASC','FIX',12)->Pack("abcd1234wxyz");
		print $out,"\n";
	}; if($@){
		print $@,"\n";
	}
}
{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $out = $f->Set('BCD','BCD','VAR',19)->Pack("1234567812345678");
		print $out,"\n";
	}; if($@){
		print $@,"\n";
	}
}
{
	local $@;
	eval {
		my $f = new DataPackager::LV();
		my $out = $f->Set('BCD','ASC','VAR',28)->Pack("1234567812345678=95");
		print $out,"\n";
	}; if($@){
		print $@,"\n";
	}
}

