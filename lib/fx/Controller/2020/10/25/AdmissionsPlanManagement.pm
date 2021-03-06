package fx::Controller::2020::10::25::AdmissionsPlanManagement;
use Moose;
use namespace::autoclean;
use utf8;
use JSON;
use POSIX qw{strftime};

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::AdmissionsPlanManagement - Catalyst Controller
招生计划管理 GPA， 成绩等门槛设置
=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

     招生计划列表
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    # 判断是普通管理员还是超级管理
    my $sql = "select DWDM, t1.ZWMC DWMC, JSDM from usr_wfw.T_FX_GLY t left join usr_wfw.T_FX_XY t1 on t1.XYDM=t.DWDM  where ZHMC = \'$c->{username}\'";
    my $jsdw = from_json( DB::get_json( $sql ), {allow_nonref=>} )->[0];     # 操作用户信息
    $c->stash({
        template => "2020/10/25/admissionsplanmanage.tt2",
        jsdw    => $jsdw
    });
}

=head1 planedit

    招生计划修改
=cut
sub planedit : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{method} eq "POST" ) {
        my $zydm = $c->req->parameters->{zydm};
        my $zsrs = $c->req->parameters->{zsrs};
        my $year = strftime "%Y", localtime;
        my $sql = "select count(*) count from usr_wfw.T_FX_ZSJH where zydm=\'$zydm\' and FXNF=\'$year\'";
        my $rtn = DB::get_row_list( $sql )->[0]->[0];
        if ( $rtn eq 0 ) {      # 没有则新增
            $sql = "insert into usr_wfw.T_FX_ZSJH ( zydm, zsrs, fxnf ) values (\'$zydm\', \'$zsrs\', \'$year\')";
        }
        else {      # 有就更新
            $sql = "update usr_wfw.T_FX_ZSJH set zsrs=\'$zsrs\' where zydm=\'$zydm\' and fxnf=\'$year\'";
        }
        $c->log->info($sql);
        $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "执行失败" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}


=head1 timesettings

    报名计划时间设置
=cut

sub timesettings : Local {
    my ( $self, $c ) = @_;
    my $year = strftime "%Y", localtime;
    my $sql = "select count(*) from usr_wfw.T_FX_ZSJH_SJ where FXNJ='$year'";
    my $flag = 0;
    if ( DB::get_row_list($sql)->[0]->[0] eq 0 ) {
        $flag = 1;      # 没有设置过就进入就进行时间设置
    }
    if ( $c->req->{method} eq "POST" ) {
        my $bmkssj = $c->req->parameters->{bmkssj};
        my $bmsjjz = $c->req->parameters->{bmsjjz};
        my $yjdks = $c->req->parameters->{yjdks};
        my $yjdjz = $c->req->parameters->{yjdjz};
        my $ejdks = $c->req->parameters->{ejdks};
        my $ejdjz = $c->req->parameters->{ejdjz};
        my $cjlrks = $c->req->parameters->{cjlrks};
        my $cjlrjz = $c->req->parameters->{cjlrjz};
        my $cjgxks = $c->req->parameters->{cjgxks};
        my $cjgxjz = $c->req->parameters->{cjgxjz};
        if ( $bmkssj ne '' && $bmsjjz ne '' ) {
                              # 提交报名数据 有到话更改 没有到话插入
            if ( $flag eq 1 ) { # 插入
                $sql = "insert into usr_wfw.T_FX_ZSJH_SJ(FXNJ, BMKSSJ, BMJZSJ, YJDJFKSSJ, YJDJFJZSJ, EJDJFKSSJ, EJDJFJZSJ, CJLRKSSJ, CJLRJZSJ, CJBGKSSJ, CJBGJZSJ) values(\'$year\', \'$bmkssj\',\'$bmsjjz\', \'$yjdks\', \'$yjdjz\', \'$ejdks\', \'$ejdjz\', \'$cjlrks\', \'$cjlrjz\', \'$cjgxks\', \'$cjgxjz\')";
            }
            else { # 更改
                $sql = "update usr_wfw.T_FX_ZSJH_SJ set BMKSSJ=\'$bmkssj\',BMJZSJ=\'$bmsjjz\', YJDJFKSSJ=\'$yjdks\', YJDJFJZSJ=\'$yjdjz\', EJDJFKSSJ=\'$ejdks\', EJDJFJZSJ=\'$ejdjz\', CJLRKSSJ=\'$cjlrks\', CJLRJZSJ=\'$cjlrjz\', CJBGKSSJ=\'$cjgxks\', CJBGJZSJ=\'$cjgxjz\' where FXNJ='$year'";
            }
            $c->log->info($sql);
            my $rtn = DB::execute($sql);
            if ($rtn ne 0 && $rtn ne -1) {
                $c->res->status(200);
                $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
                $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
            }
            else {
                $c->response->status(400);
                $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
                $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "执行失败" }');
            }
        }
        else {
                $c->response->status(403);
                $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
                $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "参数不满足基本要求" }');
        }
    }
    else {
        $c->stash({
            template    => "2020/10/25/admissionsplantime.tt2",
            flag       => $flag,
            year       => $year,
        });
    }
}

sub timeedit : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{method} eq "POST" ) {
        my $bmkssj = $c->req->parameters->{bmkssj};
        my $bmsjjz = $c->req->parameters->{bmsjjz};
        my $yjdks = $c->req->parameters->{yjdks};
        my $yjdjz = $c->req->parameters->{yjdjz};
        my $ejdks = $c->req->parameters->{ejdks};
        my $ejdjz = $c->req->parameters->{ejdjz};
        my $cjlrks = $c->req->parameters->{cjlrks};
        my $cjlrjz = $c->req->parameters->{cjlrjz};
        my $cjbgks = $c->req->parameters->{cjbgks};
        my $cjbgjz = $c->req->parameters->{cjbgjz};
        my $year = $c->req->parameters->{year};
        my $sql = "update usr_wfw.T_FX_ZSJH_SJ set BMKSSJ=\'$bmkssj\',BMJZSJ=\'$bmsjjz\', YJDJFKSSJ=\'$yjdks\', YJDJFJZSJ=\'$yjdjz\', EJDJFKSSJ=\'$ejdks\', EJDJFJZSJ=\'$ejdjz\', CJLRKSSJ=\'$cjlrks\', CJLRJZSJ=\'$cjlrjz\', CJBGKSSJ=\'$cjbgks\', CJBGJZSJ=\'$cjbgjz\' where FXNJ='$year'";
        my $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "执行失败" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub qualify : Local {
    my ( $self, $c ) = @_;
    $c->res->body("<h1 style='text-align:center;color:red'>该功能还在开发中, 请耐心等待</h1>");
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
