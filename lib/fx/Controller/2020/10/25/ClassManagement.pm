package fx::Controller::2020::10::25::ClassManagement;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::ClassManagement - Catalyst Controller
 班级管理
=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    # 判断是普通管理员还是超级管理
    my $sql = "select DWDM, t1.ZWMC DWMC, JSDM from usr_wfw.T_FX_GLY t left join usr_wfw.T_FX_XY t1 on t1.XYDM=t.DWDM  where ZHMC = \'$c->{username}\'";
    my $jsdw = from_json( DB::get_json( $sql ), {allow_nonref=>1} )->[0];     # 操作用户信息
    $c->stash({
        template => "2020/10/25/classdivide.tt2",
        jsdw     => $jsdw
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
