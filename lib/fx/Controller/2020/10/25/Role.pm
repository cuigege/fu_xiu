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
    $c->stash({
        template => "20201019/role.html",
        data     => from_json( $data , {allow_nonref=>1}),
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


=head1 dlqx

    独立权限查询结构 仅仅超级管理员可以使用
=cut

sub dlqx : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{ method } eq "POST" ) {
        # 执行权限更新操作 直接update qxdm字段
        # 1 是普通管理员独立权限 2是老师
        my $type = $c->req->parameters->{type};
        my $zgh = $c->req->parameters->{zgh};
        my $sql;
        if ($type eq '1') {
            $sql = "select DLQX from usr_wfw.T_FX_GLY where glydm=$zgh";
        }
        if ($type eq '2') {
            $sql = "select DLQX from usr_wfw.T_FX_LS where zgh=\'$zgh\'";
        }
        my $res = DB::get_json($sql);
        if ($res eq 0) {
            $c->res->status(403);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "查询失败" }' );
        } else {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
            $res = from_json( $res, {allow_nonref=>1} );
            if ( scalar $res eq 0 ) {
                $c->res->body( "{\"RTN_CODE\": \"00\", \"RTN_MSG\": \"查询成功\" , \"DATA\": [] }" );
            }
            else {
                $c->res->body( "{\"RTN_CODE\": \"00\", \"RTN_MSG\": \"查询成功\" , \"DATA\":[ $res->[0]->{DLQX} ]}" );
            }
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}


=head1 dlqx_set

    独立api权限设置 只允许系统管理员调用
=cut
sub dlqx_set : Local {
    my ( $self , $c ) = @_;
    if ( $c->req->{ method } eq "POST" ) {
        # 执行权限更新操作 直接update qxdm字段
        # 1 是普通管理员独立权限 2是老师
        my $type = $c->req->parameters->{type};
        my $zgh = $c->req->parameters->{zgh};
        my $qx_arr = $c->req->parameters->{qx_arr};
        if ( $qx_arr eq '') {
            $qx_arr = "6,9";
        }
        else {
            $qx_arr .= ",6,9";
        }
        my $sql;
        if ($type eq '1') {
            $sql = "update usr_wfw.T_FX_GLY set DLQX=\'$qx_arr\' where glydm=$zgh";
        }
        if ($type eq '2') {
            $sql = "update usr_wfw.T_FX_LS set DLQX= \'$qx_arr\' where zgh=\'$zgh\'";
        }
        my $res = DB::execute( $sql );
        if ($res eq 0) {
            $c->res->status(403);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "操作失败" }' );
        } else {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
            $res = from_json( $res, {allow_nonref=>1} );
                $c->res->body( "{\"RTN_CODE\": \"00\", \"RTN_MSG\": \"操作成\"}" );
            }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
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
