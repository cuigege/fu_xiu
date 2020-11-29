package fx::Controller::2020::10::25::EnrollmentPlanManage;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::EnrollmentPlanManage - Catalyst Controller
招生计划管理
=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash({
        template    => "2020/10/25/admissionsplanmanage.tt2",
    });
}



=encoding utf8

=head1 AUTHOR

LH'MAC

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
