#!/usr/bin/perl -w
use strict;
use warnings;
use lib "../lib";

use Data::Dumper;

use DataPackager::LV;
use DataFormat::ISO8583v03;
use Bitmap;
use Tools;
use Packet;

my $str;
{
	local $@;
	eval {
		my $bitmap = new Bitmap(64);
		my $fields = [ 3, 4, 7, 11, 14, 42, 64];
		$bitmap->SetBits(@$fields);
		$str = $bitmap->GetHexStr();
		print "bitmap: " , $str , "\n";

	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {

		my $bitmap = new Bitmap(64);
		$bitmap->SetHexStr($str);
		my $fields = $bitmap->GetBits();
		for (my $i=0 ; $i< @$fields; $i++){
			print "fields: " , $i, ":" , $$fields[$i] , "\n";
		}
	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {
		my $bitmap = new Bitmap(128);
		my $fields = [ 3, 4, 7, 11, 14, 42, 100, 103, 107, 126, 128];
		$bitmap->SetBits(@$fields);
		$str = $bitmap->GetHexStr();
		print "bitmap: " , $str , "\n";

	}; if($@){
		print $@,"\n";
	}
}

{
	local $@;
	eval {

		my $bitmap = new Bitmap(128);
		$bitmap->SetHexStr($str);
		my $fields = $bitmap->GetBits();
		for (my $i=0 ; $i< @$fields; $i++){
			print "fields: " , $i, ":" , $$fields[$i] , "\n";
		}
	}; if($@){
		print $@,"\n";
	}
}

