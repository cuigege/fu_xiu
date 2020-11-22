package fx::Controller::2020::10::25::AdminUser;
use Moose;
use namespace::autoclean;
use JSON;
use MY::DB;
use POSIX qw(strftime);
use utf8;
use Data::Dumper;

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
        template => "20201019/adminuser.html",
    });
}

sub useradd : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $jsdm = 1;       # 普通管理员
        my $yhxm = $c->req->parameters->{ yhxm };
        my $zgh = $c->req->parameters->{ zgh };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "insert into usr_wfw.T_FX_GLY(GLYDM, JSDM, YHXM, ZHMC, ZCSJ) values (usr_wfw.T_FX_GLY_GLYDM.nextval, \'$jsdm\', \'$yhxm\', \'$zgh\', \'$datestring\')";
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
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "update usr_wfw.T_FX_GLY set YHXM=\'$yhxm\', ZHMC=\'$zgh\', ZCSJ=\'$datestring\' where glydm=\'$glydm\'";
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


=encoding utf8

=head1 AUTHOR

LH'MAC

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
