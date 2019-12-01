package DataFormat;

use strict;
use warnings;

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

sub FieldFormat {
	my ($self) = @_;
    die $self . " is an abstract class";
}

sub Fields {
	my ($self) = @_;
    die $self . " is an abstract class";
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


