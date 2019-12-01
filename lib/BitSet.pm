package BitSet;

use strict;
use warnings;

#use overload
#	'[]' => \&SetBit;

sub new {
	my ($class, $bits) = @_;
	my $self = {};
	$self->{'bits'} = int($bits/8);
	for(my $i=0;$i< $self->{'bits'};$i++){
		$self->{'bitmap'}[$i] = 0;
	}
    bless $self, $class;
    return $self;
};

sub SetBits {
	my ($self,@fields) = @_;
	for(my $i=0; $i < @fields; $i++){
		my $index = int(($fields[$i]-1) / 8);
		my $pos = ($fields[$i]-1) % 8;
		my $val = 128 >> $pos;
		$self->{'bitmap'}[$index] |= $val;
		#print 
	}
}

sub GetHexStr {
	my ($self) = @_;
	my $str;
	for(my $i=0;$i< $self->{'bits'};$i++){
		$str .= sprintf ("%02X",$self->{'bitmap'}[$i]);
	}
	return $str;
}

sub SetHexStr{
	my ($self,$hexStr) = @_;
	for(my $i=0; $i < length($hexStr); $i+=2){
		$self->{'bitmap'}[int($i/2)] = hex(substr($hexStr,$i,2));
	}
}

sub GetFields {
	my ($self) = @_;
	my $fields = [];
	for(my $i=0; $i < $self->{'bits'}; $i++){
		my $x = $self->{'bitmap'}[$i];
		for(my $j=0; $j < 8; $j++){
			if($x & 1){
				#print $i," ",$j," ",(8-$j)+$i*8,"\n";
				push @$fields,(8-$j)+$i*8;
			}
			$x = $x >>1;
		}
	}
	$fields = [ sort { $a <=> $b } @$fields ];
	return $fields;
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

