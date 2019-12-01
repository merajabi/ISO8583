{
	package DataPackager::DataFormat;
	use constant {
		BIN	=> 'BIN',
		BCD	=> 'BCD',
		ASC	=> 'ASC',
	};
}
{
	package DataPackager::PackagingType;
	use constant {
		FIX	=> 'FIX',
		VAR	=> 'VAR',
	};
}

package DataPackager;

use strict;
use warnings;

sub new {
	my ($class, $args) = @_;
    die __PACKAGE __ . " is an abstract class" if $class eq __PACKAGE__;
	my $self = {};
	$self->{'format'} = "" ;
	$self->{'type'}   = "";
    bless $self, $class;
    return $self;
};

sub Set {
	my ($self) = @_;
    die $self . " is an abstract class";
}

sub Pack {
	my ($self) = @_;
    die $self . " is an abstract class";
}

sub UnPack {
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


