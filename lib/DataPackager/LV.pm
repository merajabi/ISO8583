package DataPackager::LV;

use strict;
use warnings;

use parent qw(DataPackager);
DataFilter::DataFormat->import;
DataFilter::PackagingType->import;
use Tools;

sub new {
	my ($class, $args) = @_;
	my $self = $class->SUPER::new;
	$self->Set($$args{'format'} || DataPackager::DataFormat->BIN, $$args{'type'}   || DataPackager::PackagingType->FIX, $$args{'length'} || 1 );
    return $self;
};

sub Set {
	my ($self,$format,$type,$length)=@_;
	if($format eq DataPackager::DataFormat->BIN || $format eq DataPackager::DataFormat->BCD || $format eq DataPackager::DataFormat->ASC ){
		$self->{'format'} = $format;
	}else{
		die "DataPackager::LV::Set, Input format: ".$format." not recognized, valid values are (BINARY,BCD,ASCII)";
	}

	if( $type eq DataPackager::PackagingType->FIX || $type eq DataPackager::PackagingType->VAR ){
		$self->{'type'} = $type;
	}else{
		die "DataPackager::LV::Set, Input type: ".$type." not recognized, valid values are (FIXED,LVAR)";
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
	print "DataPackager::LV::Pack in:$in \n";

	if($self->{'type'} eq DataPackager::PackagingType->FIX){
		if($self->{'format'} eq DataPackager::DataFormat->BIN){
			if(length($in)==$self->{'length'}*2){ # && in.size()%2==0
				$out = $in;
			}else{
				die "DataPackager::LV::Pack, FIXED sized BINARY input len must be 2 times of Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->BCD) {
			if(length($in)<=$self->{'length'}){
				$out = PaddedFixedLenString($in,$self->{'length'}+$self->{'length'}%2);
			}else{
				die "DataPackager::LV::Pack, FIXED sized BCD input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->ASC) {
			if(length($in) == $self->{'length'}){
				$out = HexString($in);
			}else{
				die "DataPackager::LV::Pack, FIXED sized ASCII input len must be equal to Filter len";
			}
		}else{
			die "DataPackager::LV::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}
	elsif ($self->{'type'} eq DataPackager::PackagingType->VAR){
		my $temp;
		if($self->{'format'} eq DataPackager::DataFormat->BIN){
			if(length($in)%2==0){
				$temp = $in;
			}
			my $ss = toString(length($temp)/2);
			if(length($ss)<=$self->{'length'}){
				$out = HexString(PaddedFixedLenString($ss,$self->{'length'})).$temp;
			}else{
				die "DataPackager::LV::Pack, LVAR sized BINARY input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->BCD) {
			$temp = PaddedFixedLenString($in,length($in)+length($in)%2);
			my $ss = toString(length($in));
			if(length($ss)<=2*$self->{'length'}){
				$out = PaddedFixedLenString($ss,2*$self->{'length'}).$temp;
			}else{
				die "DataPackager::LV::Pack, LVAR sized BCD input len must be less than or equal to 2 times Filter len";
			}
		}
		elsif($self->{'format'} eq DataPackager::DataFormat->ASC) {
			$temp = HexString($in);
			my $ss = toString(length($in));
			if(length($ss)<=$self->{'length'}){
				$out = HexString(PaddedFixedLenString($ss,$self->{'length'})).$temp;
			}else{
				die "DataPackager::LV::Pack, LVAR sized ASCII input len must be less than or equal to Filter len";
			}
		}else{
			die "DataPackager::LV::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}else{
		die "DataPackager::LV::Pack, Input type: ".$self->{'type'}." not recognized, valid values are (FIXED,LVAR)";
	}
	print "DataPackager::LV::Pack out:$out \n";

	return $out;
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
	print "DataPackager::LV::UnPack in:$in \n";

	if( $self->{'type'} eq DataPackager::PackagingType->FIX){
		if( $self->{'format'} eq DataPackager::DataFormat->BIN){
			$out = substr($in,0,$self->{'length'}*2);
			$len=$self->{'length'};
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->BCD) {
			$out = substr($in,$self->{'length'}%2,$self->{'length'});
			$len=($self->{'length'}+$self->{'length'}%2)/2;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->ASC) {
			$out = HexToAscii(substr($in,0,$self->{'length'}*2));
			$len=$self->{'length'};
		}else{
			die "DataPackager::LV::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}
	elsif ( $self->{'type'} eq DataPackager::PackagingType->VAR){
		my $lenStr = substr($in,0,$self->{'length'}*2);
		#lenStr.erase(0, std::min(lenStr.find_first_not_of('0'), lenStr.size()-1));

		if( $self->{'format'} eq DataPackager::DataFormat->BIN){
			$len=HexToAscii($lenStr)*1;
			$out = substr($in,2*$self->{'length'},2*$len);
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->BCD) {
			$len=$lenStr*1;
			$out = substr($in,2*$self->{'length'}+$len%2,$len);
			$len=($len+$len%2)/2;
		}
		elsif( $self->{'format'} eq DataPackager::DataFormat->ASC) {
			$len = HexToAscii($lenStr)*1;
			$out = HexToAscii(substr($in,2*$self->{'length'},2*$len));
		}else{
			die "DataPackager::LV::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}

		$len+=$self->{'length'};
	}else{
		die "DataPackager::LV::UnPack, Input type: ".$self->{'type'}." not recognized, valid values are (FIXED,LVAR)";
	}

	print "DataPackager::LV::UnPack out:$out len:$len\n";

	return ($out,$len,substr($in,2*$len));
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

