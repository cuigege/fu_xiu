package fx::Controller::2020::10::25::MinorMajormanage;
use Moose;
use namespace::autoclean;
use utf8;
use JSON;
use POSIX qw(strftime);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::MinorMajormanage - Catalyst Controller

=head1 DESCRIPTION

    辅修专业管理 在专业的基础上设置每年的辅修专业

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    # 判断是普通管理员还是超级管理
    my $sql = "select DWDM, t1.ZWMC DWMC, JSDM from usr_wfw.T_FX_GLY t left join usr_wfw.T_FX_XY t1 on t1.XYDM=t.DWDM  where ZHMC = \'$c->{username}\'";
    my $jsdw = from_json( DB::get_json( $sql ) )->[0];     # 操作用户信息
    $c->stash(
       template => '20201019/minormajormanage.html',
       jsdw     => $jsdw
    );
}

=head1 minormajorset

    设置辅修接口
=cut

sub minormajorset : Local {
    my ($self, $c) = @_;
    $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
    if ( $c->req->{"method"} eq "POST" ) {
        my $zydm = $c->req->parameters->{ zydm };
        my $status = $c->req->parameters->{ status };
        my $rtn;
        my $sql;
        my $year = strftime "%Y", localtime;
        if ( ! defined $zydm ) {
            $c->response->status(400);
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "无专业代码" }' );
        }
        if ( $status eq 0 ) {     # 取消辅修设置 同时删除该专业的今年辅修方案 和培养计划
            $sql = "delete from usr_wfw.T_FX_PYFA where zydm=\'$zydm\' and fxnj=\'$year\'";
            $rtn = DB::execute( $sql );
            $sql = "delete from usr_wfw.T_FX_ZSJH where zydm=\'$zydm\' and fxnf=\'$year\'";
            $rtn = DB::execute( $sql );
            $sql = "delete from usr_wfw.T_FX_FXZY where zydm=\'$zydm\' and fxnf=\'$year\'";
            $rtn = DB::execute( $sql );
            if ( $rtn ne 0 && $rtn ne -1 ) {
                $c->res->status(200);
                $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
            }
            else {
                $c->response->status(400);
                $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "执行错误" }');
            }
            return;
        }
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        $sql = "select * from usr_wfw.T_FX_ZY where ZYDM = '$zydm'";
        my $res = DB::get_json( $sql );
        $res = from_json($res)->[0];
        $sql = "insert into usr_wfw.T_FX_FXZY(ZWMC, YWMC, ZYDM, XYDM, XKMLDM, ZYDLDM, SZSJ, FXNF) values (\'$res->{ZWMC}\', \'$res->{YWMC}\', \'$res->{ZYDM}\', \'$res->{XYDM}\', \'$res->{XKMLDM}\',\'$res->{ZYDLDM}\', \'$datestring\', \'$year\')";
        $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "该专业已为辅修专业" }' );
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
