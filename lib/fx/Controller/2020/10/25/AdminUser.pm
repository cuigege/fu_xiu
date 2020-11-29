package fx::Controller::2020::10::25::AdminUser;
use Moose;
use namespace::autoclean;
use JSON;
use MY::DB;
use POSIX qw(strftime);
use utf8;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::user - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash({
        template => "2020/10/25/adminuser.tt2",
    });
}

sub useradd : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $jsdm = 1;       # 普通管理员
        my $yhxm = $c->req->parameters->{ yhxm };
        my $zgh = $c->req->parameters->{ zgh };
        my $yxqkssj = $c->req->parameters->{ yxqkssj };
        my $yxqjzsj = $c->req->parameters->{ yxqjzsj };
        my $dwdm = $c->req->parameters->{ dw };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "insert into usr_wfw.T_FX_GLY(GLYDM, JSDM, YHXM, ZHMC, ZCSJ, YXQKSSJ, YXQJZSJ, DWDM) values (usr_wfw.T_FX_GLY_GLYDM.nextval, \'$jsdm\', \'$yhxm\', \'$zgh\', \'$datestring\', \'$yxqkssj\', \'$yxqjzsj\', \'$dwdm\')";
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "用户名或者职工号重复" }' );
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub useredit : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $glydm = $c->req->parameters->{ edit_glydm };       # 普通管理员
        my $yhxm = $c->req->parameters->{ edit_yhxm };
        my $zgh = $c->req->parameters->{ edit_zgh };
        my $yxqkssj = $c->req->parameters->{ edit_yxqkssj };
        my $yxqjzsj = $c->req->parameters->{ edit_yxqjzsj };
        my $dwdm = $c->req->parameters->{ edit_dw };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "update usr_wfw.T_FX_GLY set YHXM=\'$yhxm\', ZHMC=\'$zgh\', ZCSJ=\'$datestring\', YXQKSSJ=\'$yxqkssj\', YXQJZSJ=\'$yxqjzsj\', DWDM=\'$dwdm\' where glydm=\'$glydm\'";
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

sub userdel : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $GLYDM = $c->req->parameters->{ glydm };
        my $sql = "delete usr_wfw.T_FX_GLY where GLYDM='$GLYDM'";
        my $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "用户名不存在，可能已经被删除" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

=head1 status

    启用禁用设置
=cut

sub status : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $zgh = $c->req->parameters->{ zgh };
        my $state = $c->req->parameters->{ state };
        if ( $state eq 'true' ) {
            $state = 1;
        }
        else {
            $state = 0;
        }
        my $sql = "update usr_wfw.T_FX_GLY set QYZT='$state' where ZHMC='$zgh'";
        my $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "用户名不存在，可能已经被删除" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
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
