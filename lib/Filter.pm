
package Filter::DataFormat;
use constant {
	BINARY	=> 'BINARY',
	BCD		=> 'BCD',
	ASCII	=> 'ASCII',
};

package Filter::PackagingType;
use constant {
	FIXED	=> 'FIXED',
	LVAR	=> 'LVAR',
};

package Filter;
use strict;
use warnings;
use Tools;

sub new {
	my ($class, $args) = @_;
	my $self = {};
    bless $self, $class;
	$self->Set($$args{'format'} || Filter::DataFormat->BINARY, $$args{'type'}   || Filter::PackagingType->FIXED, $$args{'length'} || 1 );
    return $self;
};

sub Set {
	my ($self,$format,$type,$length)=@_;
	if($format eq Filter::DataFormat->BINARY || $format eq Filter::DataFormat->BCD || $format eq Filter::DataFormat->ASCII ){
		$self->{'format'} = $format;
	}else{
		die "Filter::Set, Input format: ".$format." not recognized, valid values are (BINARY,BCD,ASCII)";
	}

	if( $type eq Filter::PackagingType->FIXED || $type eq Filter::PackagingType->LVAR ){
		$self->{'type'} = $type;
	}else{
		die "Filter::Set, Input type: ".$type." not recognized, valid values are (FIXED,LVAR)";
	}

	if($length>=0){
		$self->{'length'} = $length;
	}else{
		die "Filter::Set, Input length: ".$length." must be positive integer";
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
	print "Filter::Pack in:$in \n";

	if($self->{'type'} eq Filter::PackagingType->FIXED){
		if($self->{'format'} eq Filter::DataFormat->BINARY){
			if(length($in)==$self->{'length'}*2){ # && in.size()%2==0
				$out = $in;
			}else{
				die "Filter::Pack, FIXED sized BINARY input len must be 2 times of Filter len";
			}
		}
		elsif($self->{'format'} eq Filter::DataFormat->BCD) {
			if(length($in)<=$self->{'length'}){
				$out = PaddedFixedLenString($in,$self->{'length'}+$self->{'length'}%2);
			}else{
				die "Filter::Pack, FIXED sized BCD input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq Filter::DataFormat->ASCII) {
			if(length($in) == $self->{'length'}){
				$out = HexString($in);
			}else{
				die "Filter::Pack, FIXED sized ASCII input len must be equal to Filter len";
			}
		}else{
			die "Filter::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}
	elsif ($self->{'type'} eq Filter::PackagingType->LVAR){
		my $temp;
		if($self->{'format'} eq Filter::DataFormat->BINARY){
			if(length($in)%2==0){
				$temp = $in;
			}
			my $ss = toString(length($temp)/2);
			if(length($ss)<=$self->{'length'}){
				$out = HexString(PaddedFixedLenString($ss,$self->{'length'})).$temp;
			}else{
				die "Filter::Pack, LVAR sized BINARY input len must be less than or equal to Filter len";
			}
		}
		elsif($self->{'format'} eq Filter::DataFormat->BCD) {
			$temp = PaddedFixedLenString($in,length($in)+length($in)%2);
			my $ss = toString(length($in));
			if(length($ss)<=2*$self->{'length'}){
				$out = PaddedFixedLenString($ss,2*$self->{'length'}).$temp;
			}else{
				die "Filter::Pack, LVAR sized BCD input len must be less than or equal to 2 times Filter len";
			}
		}
		elsif($self->{'format'} eq Filter::DataFormat->ASCII) {
			$temp = HexString($in);
			my $ss = toString(length($in));
			if(length($ss)<=$self->{'length'}){
				$out = HexString(PaddedFixedLenString($ss,$self->{'length'})).$temp;
			}else{
				die "Filter::Pack, LVAR sized ASCII input len must be less than or equal to Filter len";
			}
		}else{
			die "Filter::Pack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}else{
		die "Filter::Pack, Input type: ".$self->{'type'}." not recognized, valid values are (FIXED,LVAR)";
	}
	print "Filter::Pack out:$out \n";

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
	print "Filter::UnPack in:$in \n";

	if( $self->{'type'} eq Filter::PackagingType->FIXED){
		if( $self->{'format'} eq Filter::DataFormat->BINARY){
			$out = substr($in,0,$self->{'length'}*2);
			$len=$self->{'length'};
		}
		elsif( $self->{'format'} eq Filter::DataFormat->BCD) {
			$out = substr($in,$self->{'length'}%2,$self->{'length'});
			$len=($self->{'length'}+$self->{'length'}%2)/2;
		}
		elsif( $self->{'format'} eq Filter::DataFormat->ASCII) {
			$out = HexToAscii(substr($in,0,$self->{'length'}*2));
			$len=$self->{'length'};
		}else{
			die "Filter::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}
	}
	elsif ( $self->{'type'} eq Filter::PackagingType->LVAR){
		my $lenStr = substr($in,0,$self->{'length'}*2);
		#lenStr.erase(0, std::min(lenStr.find_first_not_of('0'), lenStr.size()-1));

		if( $self->{'format'} eq Filter::DataFormat->BINARY){
			$len=HexToAscii($lenStr)*1;
			$out = substr($in,2*$self->{'length'},2*$len);
		}
		elsif( $self->{'format'} eq Filter::DataFormat->BCD) {
			$len=$lenStr*1;
			$out = substr($in,2*$self->{'length'}+$len%2,$len);
			$len=($len+$len%2)/2;
		}
		elsif( $self->{'format'} eq Filter::DataFormat->ASCII) {
			$len = HexToAscii($lenStr)*1;
			$out = HexToAscii(substr($in,2*$self->{'length'},2*$len));
		}else{
			die "Filter::UnPack, Input format: ".$self->{'format'}." not recognized, valid values are (BINARY,BCD,ASCII)";
		}

		$len+=$self->{'length'};
	}else{
		die "Filter::UnPack, Input type: ".$self->{'type'}." not recognized, valid values are (FIXED,LVAR)";
	}

	print "Filter::UnPack out:$out len:$len\n";

	return ($out,$len,substr($in,2*$len));
}

1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2009-2017 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the same terms as Perl itself.

=cut

