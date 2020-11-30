package fx::Controller::2020::10::25::StudentStatus;
use Moose;
use namespace::autoclean;
use utf8;
use Data::Dumper;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::StudentStatus - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash({
        template    =>  "2020/10/25/studentstatus.tt2"
    })
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
