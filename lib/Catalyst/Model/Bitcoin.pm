package Catalyst::Model::Bitcoin;

use 5.8.0;
use strict;
use warnings;
use Moose;
use Finance::Bitcoin;
use Carp qw( croak ); 

extends 'Catalyst::Model';

our $VERSION = '0.01';

has jsonrpc_uri => (is => 'rw');
has api => (is => 'rw');
has wallet => (is => 'rw');

sub new {
  my $self = shift->next::method(@_);
  my $class = ref($self);
  my ($c, $arg_ref) = @_;

  croak "->config->{uri} must be set for $class\n"
    unless $self->{uri};

  $self->api( Finance::Bitcoin::API->new( endpoint => $self->{uri} ) );
  $self->wallet( Finance::Bitcoin::Wallet->new( $self->api ) );

  return $self;
}


sub find {
  my ($self, $address) = @_;

  my $address_object = Finance::Bitcoin::Address->new(
    $self->api,
    $address,
  );

  return $address_object;
}

sub get_received_by_address {
  my ($self, $address) = @_;

  my $address_object = $self->find($address);

  return $address_object->received();
}


sub send_to_address {
  my ($self, $address, $amount) = @_;

  # This is required to force $amount to be json-coded as real type,
  # not string, in following JSON-RPC request
  $amount += 0;
  
  return $self->wallet->pay($address, $amount);
}


sub get_new_address {
  my $self = shift;

  my $address = $self->wallet->create_address();
  return $address->address;
}


sub get_balance {
  my $self = shift;

  return $self->wallet->balance();
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Catalyst::Model::Bitcoin - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Catalyst::Model::Bitcoin;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Catalyst::Model::Bitcoin, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Pavel Karoukin, E<lt>pavel@yepcorp.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Pavel Karoukin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
