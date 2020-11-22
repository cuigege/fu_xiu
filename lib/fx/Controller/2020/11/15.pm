package fx::Controller::2020::11::15;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::11::15 - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2

=cut

sub auto : Private {

    my ( $self, $c ) = @_;


}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched fx::Controller::2020::11::15 in 2020::11::15.');
}



=encoding utf8

=head1 AUTHOR

CuiMay,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
