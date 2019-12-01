package Packet;
use strict;
use warnings;

use overload
	'=' => \&Set,
	'.' => \&Add;

sub new {
	my ($class, %args) = @_;
	my $self={};
	$self->{'buffer'}="";
    bless $self, $class;
    return $self;
};

sub Data {
	my ($self)=@_;
	return $self->{'buffer'};
}

sub Set {
	my ($self,$data)=@_;
	if(ref($data) eq __PACKAGE__ ){
		$self->{'buffer'} = $data->Data();
	} else {
		$self->{'buffer'} = $data;
	}
	return $self;
}

sub Add {
	my ($self,$data)=@_;
	my $newObject = $self; 
	if(ref($data) eq __PACKAGE__ ){
		$newObject->{'buffer'} = $self->{'buffer'} . $data->Data();
	} else {
		$newObject->{'buffer'} = $self->{'buffer'} . $data;
	}
	return $newObject;
}

sub AddData {
	my ($self,$data)=@_;
	$self->{'buffer'} .= $data;
}

sub SetData {
	my ($self,$data,$index)=@_;
	if( $index < length($self->{'buffer'}) ){
		substr $self->{'buffer'}, $index, 1, $data;
	}
}

#Packet & operator << (const std::string &str);
#Packet & operator >> (std::string &str);
#Packet & operator << (const Filter &f);
#Packet & operator >> (const Filter &f);


1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2009-2017 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the terms of GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

=cut

