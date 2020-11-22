package fx::Controller::2020::10::25::Role;
use Moose;
use namespace::autoclean;
use MY::ToolFunc;
use MY::DB;
use Data::Dumper;
use JSON;
use utf8;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::Role - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $sql = "select t1.*, t2.YHXM from usr_wfw.T_FX_JS t1, usr_wfw.T_FX_GLY t2 where t1.CJYH=t2.ZHMC and t1.JSDM != 0 order by t1.JSDM";
    my $data = DB::get_json( $sql );
    $c->log->info( $data );
    $c->stash({
        template => "20201019/role.html",
        data     => from_json( $data ),
    });
}

=head1 privileges_api

    获取带用户权限状态带路径数据
=cut
sub privileges : Local {
    my ( $self, $c ) = @_;
    my $sql;
    my $res;
    my $jsdm = $c->req->{parameters}->{jsdm};
    if ( $c->req->{ method } eq "POST" ) {  # 执行权限更新操作 直接update qxdm字段
        my $qx_arr = $c->req->{parameters}->{qx_arr};
        $sql = "update usr_wfw.T_FX_JS set JSQX='$qx_arr' where JSDM='$jsdm'";
        $res = DB::execute( $sql );
        if ( $res ne 0 && $res ne -1) {
            $res = '{"RTN_MSG": "01", "RTN_MSG": "操作成功"}';
            $c->response->status( 200 );
        }
        else {
             $res = '{"RTN_MSG": "00", "RTN_MSG": "操作失败"}';
             $c->response->status( 500 );
        }
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( $res );
        return 1;
    }
    $sql = "select t1.CDZWM, t2.ZWM, t2.LJDM, t2.LJ from usr_wfw.T_FX_XTCD t1, usr_wfw.T_FX_LJ t2 where t1.CDDM=t2.SSCDDM order by t2.LJDM, t2.SSCDDM ";
    my $ljs = DB::get_json( $sql );     # 获取所有路径
    $sql = "select jsqx from usr_wfw.T_FX_JS where JSDM='$jsdm'";
    my $qxlj = DB::get_row_list( $sql )->[0];
    $res = qq({"LJ": $ljs, "QXLJ": [@$qxlj]});
    $res =~ s/"ROWNUM":"\d*",?//g;      # 去掉ROWNUM
    $res =~ s/,\}/\}/g;      # 去掉,}
    $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
    $c->res->body( $res );
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
