package fx::Controller::Root;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use utf8;
BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');
=encoding utf-8

=head1 NAME

fx::Controller::Root - Root Controller for fx

=head1 DESCRIPTION

[enter your description here]

=head1 auto

	CAS认证
=cut
sub auto :Private {
	my ( $self, $c ) = @_;
	# unless ($c->user_exists || $c->authenticate) {
	# 	$c->res->status(401);
	# 	$c->res->body('Access Denied');
	# 	return 0;
	# }
}
=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	$c->response->body("hello root");
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->status(404);
	$c->stash(
			template => '2020/10/25/error-404.tt2',
	);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

LH

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
