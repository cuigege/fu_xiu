package fx::Controller::2020::10::25::Major;
use Moose;
use namespace::autoclean;
use utf8;
use JSON;
use POSIX qw(strftime);
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::major - Catalyst Controller
专业管理
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
    my $jsdw = from_json( DB::get_json( $sql ) )->[0];     # 操作用户信息
    $c->stash(
        template => "20201019/major.html",
        jsdw     => $jsdw
    );
}


sub majoradd : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $zydm = $c->req->parameters->{ zydm };       # 普通管理员
        my $zwmc = $c->req->parameters->{ zymc };
        my $ywmc = $c->req->parameters->{ zyywm };
        my $xydm = $c->req->parameters->{ xydm };
        my $xkmldm = $c->req->parameters->{ xkmldm };
        my $zydldm = $c->req->parameters->{ zydldm };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "insert into usr_wfw.T_FX_ZY(zydm, zwmc, ywmc, xydm, xkmldm, zydldm, GXSJ) values (\'$zydm\', \'$zwmc\', \'$ywmc\', \'$xydm\', \'$xkmldm\',\'$zydldm\', \'$datestring\')";
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "学院已经存在" }' );
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub majoredit : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $zydm = $c->req->parameters->{ zydm };       # 普通管理员
        my $zwmc = $c->req->parameters->{ zymc };
        my $ywmc = $c->req->parameters->{ zyywm };
        my $xydm = $c->req->parameters->{ xydm };
        my $xkmldm = $c->req->parameters->{ xkmldm };
        my $zydldm = $c->req->parameters->{ zydldm };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "update usr_wfw.T_FX_ZY set zwmc=\'$zwmc\', ywmc=\'$ywmc\', xydm=\'$xydm\', xkmldm=\'$xkmldm\', zydldm=\'$zydldm\',GXSJ=\'$datestring\' where zydm=\'$zydm\'";
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "用户已经被删除" }' );
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub majordel : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $zydm = $c->req->parameters->{ zydm };
        my $sql = "delete usr_wfw.T_FX_ZY where zydm='$zydm'";
        $c->log->info($sql);
        my $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "学院不存在，可能已经被删除" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

=head1 bigcategory

    专业大类
=cut

sub bigcategory : Local {
    my ( $self, $c ) = @_;
    $c->stash({
        template    =>  "20201019/bigcategory.html"
    })
}

=head1 subjectcategory

    学科门类
=cut

sub subjectcategory : Local {
    my ( $self, $c ) = @_;
    $c->stash({
        template    =>  "20201019/subjectcategory.html"
    })
}


=cut

=encoding utf8

=head1 AUTHOR

LH'MAC

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
