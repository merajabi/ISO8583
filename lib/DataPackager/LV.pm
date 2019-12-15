package DataPackager::LV;

use strict;
use warnings;

use Data::Dumper;

use parent qw(DataPackager);
DataFilter::DataFormat->import;
DataFilter::PackagingType->import;
use Tools;

sub new {
	my ($class, $args) = @_;
	my $self = $class->SUPER::new;
	$self->SetPad($$args{'PadCharBCD'} || '0' ,$$args{'PadAlignBCD'} || "LEFT", $$args{'PadCharASC'} || "\x{20}", $$args{'PadAlignBCD'} || "RIGHT" );
	$self->Set($$args{'lenFormat'} || DataPackager::DataFormat->BCD, $$args{'format'} || DataPackager::DataFormat->BCD, $$args{'type'}   || DataPackager::PackagingType->FIX, $$args{'length'} || 1 );
    return $self;
};

sub SetPad {
	my ($self,$bcdPad,$bcdPadAlign,$ascPad,$ascPadAlign)=@_;
	$self->{'PadCharBCD'} = $bcdPad;
	$self->{'PadAlignBCD'} = $bcdPadAlign;
	$self->{'PadCharASC'} = $ascPad;
	$self->{'PadAlignASC'} = $ascPadAlign;
}

sub Set {
	my ($self,$lenFormat,$format,$type,$length)=@_;
	if($lenFormat eq DataPackager::DataFormat->BIN || $lenFormat eq DataPackager::DataFormat->BCD || $lenFormat eq DataPackager::DataFormat->ASC ){
		$self->{'lenFormat'} = $lenFormat;
	}else{
		die "DataPackager::LV::Set, Input format: ".$lenFormat." not recognized, valid values are (BIN,BCD,ASC)";
	}

	if($format eq DataPackager::DataFormat->BIN || $format eq DataPackager::DataFormat->BCD || $format eq DataPackager::DataFormat->XBCD || $format eq DataPackager::DataFormat->ASC ){
		$self->{'format'} = $format;
	}else{
		die "DataPackager::LV::Set, Input format: ".$format." not recognized, valid values are (BIN,BCD,ASC)";
	}

	if( $type eq DataPackager::PackagingType->FIX || $type eq DataPackager::PackagingType->VAR ){
		$self->{'type'} = $type;
	}else{
		die "DataPackager::LV::Set, Input type: ".$type." not recognized, valid values are (FIX,VAR)";
	}

	if($length>=0){
		$self->{'length'} = $length;
	}else{
		die "DataPackager::LV::Set, Input length: ".$length." must be positive integer";
	}
	return $self;
}

#/*
# *  BINARY: FEDCBA9876543210
# *  BCD:	1234567890
# *  ASCII:	zxclkjsdfouewuoaseuidweigu98234-;akslijwad982137
# */
sub Pack {
	my ($self,$in)=@_;
	my $out;
	print "# ","DataPackager::LV::Pack in:$in \n";

	if($self->{'type'} eq DataPackager::PackagingType->FIX){
		if($self->{'format'} eq DataPackager::DataFormat->BIN){
			if(length($in)%2 != 0){
				die "DataPackager::LV::Pack, LVAR sized BINARY input len must be even";
			}

			if(4*length($in)==$self->{'length'}){ # length($in)/2==$self->{'length'}/8
				$out = $in;
			}else{
				die "DataPackager::LV::Pack, FIXED sized BINARY input len must be 4 times of Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->BCD) {
			if(length($in)<=$self->{'length'}){
				$out = PaddedFixedLenString($in,$self->{'length'}+$self->{'length'}%2, $self->{'PadCharBCD'}, $self->{'PadAlignBCD'});
			}else{
				die "DataPackager::LV::Pack, FIXED sized BCD input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->XBCD) {
			if(length($in)<=$self->{'length'}){
				$out = (($in>=0)?'C':'D').PaddedFixedLenString($in,$self->{'length'}+$self->{'length'}%2-1, $self->{'PadCharBCD'}, $self->{'PadAlignBCD'});
			}else{
				die "DataPackager::LV::Pack, FIXED sized BCD input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->ASC) {
			if(length($in) <= $self->{'length'}){
				$out = HexString(PaddedFixedLenString($in,$self->{'length'}, $self->{'PadCharASC'}, $self->{'PadAlignASC'}));
			}else{
				die "DataPackager::LV::Pack, FIXED sized ASCII input len must be equal to Filter len";
			}
		}else{
			die "DataPackager::LV::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BIN,BCD,ASC)";
		}
	}
	elsif ($self->{'type'} eq DataPackager::PackagingType->VAR){
		if($self->{'format'} eq DataPackager::DataFormat->BIN){
			if(length($in)%2 != 0){
				die "DataPackager::LV::Pack, LVAR sized BINARY input len must be even";
			}

			if(4*length($in)<=$self->{'length'}){
				my $lenStr = $self->PackLen(length($in)/2);
				$out = $lenStr.$in;
			}else{
				die "DataPackager::LV::Pack, LVAR sized BINARY input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->BCD) {
			if(length($in)<=$self->{'length'}){
				my $lenStr = $self->PackLen(length($in));
				$out = $lenStr. PaddedFixedLenString($in,length($in)+length($in)%2, $self->{'PadCharBCD'}, $self->{'PadAlignBCD'});
			}else{
				die "DataPackager::LV::Pack, LVAR sized BCD input len must be less than or equal to Filter len";
			}
		}
=pod
		elsif($self->{'format'} eq DataPackager::DataFormat->XBCD) {
			if(length($in)<=$self->{'length'}){
				my $lenStr = $self->PackLen(length($in));
				$out = $lenStr. PaddedFixedLenString($in,length($in)+length($in)%2);
			}else{
				die "DataPackager::LV::Pack, LVAR sized BCD input len must be less than or equal to Filter len";
			}
		}
=cut
		elsif($self->{'format'} eq DataPackager::DataFormat->ASC) {
			if(length($in)<=$self->{'length'}){
				my $lenStr = $self->PackLen(length($in));
				$out = $lenStr. HexString($in);
			}else{
				die "DataPackager::LV::Pack, LVAR sized ASCII input len must be less than or equal to Filter len";
			}
		}else{
			die "DataPackager::LV::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BIN,BCD,ASC)";
		}
	}else{
		die "DataPackager::LV::Pack, Input type: ".$self->{'type'}." not recognized, valid values are (FIX,VAR)";
	}
	print "# ","DataPackager::LV::Pack len:".length($out)." out:$out \n";

	return $out;
}

sub PackLen {
	my ($self,$len)=@_;
	print "# ","DataPackager::LV::PackLen len:$len \n";
	my $out;

	if($self->{'lenFormat'} eq DataPackager::DataFormat->BIN){
		$out = HexString(PaddedFixedLenString($len,$self->{'length'}/8));
	}
	elsif($self->{'lenFormat'} eq DataPackager::DataFormat->BCD) {
		$out = PaddedFixedLenString( $len,length( toString($self->{'length'}) ) + length( toString($self->{'length'}) )%2 );
	}
	elsif($self->{'lenFormat'} eq DataPackager::DataFormat->ASC) {
		$out = HexString(PaddedFixedLenString( $len,length(toString($self->{'length'})) ));
	}
	else{
		die "DataPackager::LV::PackLen, Input format: ".$self->{'lenFormat'}." not recognized, valid values are (BINARY,BCD,ASCII)";
	}

	print "# ","DataPackager::LV::PackLen out:$out \n";
	return $out;
}

sub UnPackLen {
	my ($self,$in)=@_;
#	print "# ","DataPackager::LV::PackLen len:$len \n";
	my $len;
	my $out;

	if($self->{'lenFormat'} eq DataPackager::DataFormat->BIN){
		#$out = HexString(substr($in,$self->{'length'}/8));
	}
	elsif($self->{'lenFormat'} eq DataPackager::DataFormat->BCD) {
		$len = length(toString($self->{'length'})) + length( toString($self->{'length'}) )%2;
		$out = substr( $in, 0, $len );
	}
	elsif($self->{'lenFormat'} eq DataPackager::DataFormat->ASC) {
		$len = 2*length(toString($self->{'length'}));
		$out = HexToAscii( substr( $in, 0, $len ) );
	}
	else{
		die "DataPackager::LV::UnPackLen, Input format: ".$self->{'lenFormat'}." not recognized, valid values are (BINARY,BCD,ASCII)";
	}

	print "# ","DataPackager::LV::UnPackLen out:$len \n";
	return ($out,$len,substr($in,$len));
}

#/*
# *  BINARY: FEDCBA9876543210
# *  BCD:	1234567890
# *  ASCII:	zxclkjsdfouewuoaseuidweigu98234-;akslijwad982137
# */
#std::pair<std::string,int> 

sub UnPack{
	my ($self,$in)=@_;
	my $out;
	my $len=0;
	print "# ","DataPackager::LV::UnPack in:$in \n";

	if( $self->{'type'} eq DataPackager::PackagingType->FIX){
		if( $self->{'format'} eq DataPackager::DataFormat->BIN){
			$out = substr($in,0,$self->{'length'}/4);
			$len=$self->{'length'}/4;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->BCD) {
			$out = substr($in,0,$self->{'length'}+$self->{'length'}%2);
			if($self->{'PadAlignBCD'} eq "LEFT"){
				#$out =~ s/^$self->{'PadCharBCD'}*//;
			}else{
				#$out =~ s/$self->{'PadCharBCD'}*$//;
			}
			$len=$self->{'length'}+$self->{'length'}%2;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->XBCD) {
			$out = substr($in,1,$self->{'length'}-1);
			if($self->{'PadAlignBCD'} eq "LEFT"){
				$out =~ s/^$self->{'PadCharBCD'}*//;
			}else{
				$out =~ s/$self->{'PadCharBCD'}*$//;
			}
			$len=$self->{'length'}+$self->{'length'}%2;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->ASC) {
			$out = HexToAscii(substr($in,0,$self->{'length'}*2));
			if($self->{'PadAlignASC'} eq "LEFT"){
				$out =~ s/^$self->{'PadCharASC'}*//;
			}else{
				$out =~ s/$self->{'PadCharASC'}*$//;
			}
			$len=$self->{'length'}*2;
		}else{
			die "DataPackager::LV::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}
	elsif ( $self->{'type'} eq DataPackager::PackagingType->VAR){
		my ($lenData,$lenLen) = $self->UnPackLen($in);

		if( $self->{'format'} eq DataPackager::DataFormat->BIN){
			$lenData*=2;
			$out = substr($in,$lenLen,$lenData);
			$len=$lenData+$lenLen;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->BCD) {
			$lenData+=$lenData%2;
			$out = substr($in,$lenLen,$lenData);
			if($self->{'PadAlignBCD'} eq "LEFT"){
				#$out =~ s/^$self->{'PadCharBCD'}*//;
			}else{
				#$out =~ s/$self->{'PadCharBCD'}*$//;
			}

			$len = $lenLen + $lenData;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->ASC) {
			$out = HexToAscii(substr($in,$lenLen,2*$lenData));
			$len = $lenLen + 2*$lenData;
		}else{
			die "DataPackager::LV::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}else{
		die "DataPackager::LV::UnPack, Input type: ".$self->{'type'}." not recognized, valid values are (FIXED,LVAR)";
	}

	print "# ","DataPackager::LV::UnPack len: $len len(out):".length($out)." out:$out\n";

	return ($out,$len,substr($in,$len));
}

1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2009-2017 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the terms of GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

=cut

