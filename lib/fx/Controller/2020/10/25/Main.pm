package fx::Controller::2020::10::25::Main;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use MY::DB;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::main - Catalyst Controller
主页框架

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

	获取主菜单链接信息，及其对应权限进行渲染主菜单，生成有效访问列表
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	my $res = DB::get_json("SELECT rownum , t.* from (select xm from T_BZKS t where ROWNUM < 5 ORDER BY xm desc) t");
	if ( $res eq 0) {
		print $DB::err_msg;
	} else {
		# print Dumper ($res);
	}
	$c->stash(
		template => '20201019/base.html',
	);
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
