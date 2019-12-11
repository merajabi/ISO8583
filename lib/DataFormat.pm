package DataFormat;

use strict;
use warnings;

use Data::Dumper;

sub new {
	my ($class, $args) = @_;
    die __PACKAGE __ . " is an abstract class" if $class eq __PACKAGE__;
	my $self = {};
	$self->{'format'} = {};
	$self->{'fields'} = {};
    bless $self, $class;
    return $self;
};

sub InitFields {
	my ($self) = @_;
    die $self . " is an abstract class";
}

sub InitFormats {
	my ($self) = @_;
    die $self . " is an abstract class";
}

sub GetFieldFormat {
	my ($self,$fieldNumber) = @_;
	if (exists $self->{'format'}{$fieldNumber} ) {
		return @{$self->{'format'}{$fieldNumber}};
	}else{
		die __PACKAGE__." line: ".__LINE__.", No such field: $fieldNumber\n";
	}
}
sub GetFields {
	my ($self,$mit) = @_;
	if (exists $self->{'fields'}{$mit} ) {
		return $self->{'fields'}{$mit};
	}elsif(exists $self->{'fields'}{substr($mit,0,4)}){
		return $self->{'fields'}{substr($mit,0,4)};
	}else{
		die __PACKAGE__." line: ".__LINE__.", No such MIT & Process code: $mit\n";
	}
}

1;

__END__
=head1 AUTHOR

Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 COPYRIGHT (c)

Copyright 2019-2020 by Mehdi(Raha) Rajabi C<raha.emailbox@gmail.com>

=head1 LICENSE

This module is released under the terms of GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007

=cut


