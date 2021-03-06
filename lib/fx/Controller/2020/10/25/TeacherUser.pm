package fx::Controller::2020::10::25::TeacherUser;
use Moose;
use namespace::autoclean;
use utf8;
use POSIX qw(strftime);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::TeacherUser - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash({
        template => "2020/10/25/teacheruser.tt2",
    });
}

sub useradd : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $jsdm = 2;       # 老师角色
        my $jsxm = $c->req->parameters->{ jsxm };
        my $zgh = $c->req->parameters->{ zgh };
        my $yxqkssj = $c->req->parameters->{ yxqkssj };
        my $yxqjzsj = $c->req->parameters->{ yxqjzsj };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "insert into usr_wfw.T_FX_LS(ZGH, JSDM, JSXM, LRSJ, YXQKSSJ, YXQJZSJ) values (\'$zgh\', \'$jsdm\', \'$jsxm\', \'$datestring\', \'$yxqkssj\', \'$yxqjzsj\')";
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "职工号重复" }' );
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
        my $zgh = $c->req->parameters->{ edit_zgh };       # 教师工号
        my $jsxm = $c->req->parameters->{ jsxm };
        my $yxqkssj = $c->req->parameters->{ edit_yxqkssj };
        my $yxqjzsj = $c->req->parameters->{ edit_yxqjzsj };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "update usr_wfw.T_FX_LS set JSXM=\'$jsxm\', LRSJ=\'$datestring\', YXQKSSJ=\'$yxqkssj\', YXQJZSJ=\'$yxqjzsj\' where zgh=\'$zgh\'";
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
        my $zgh = $c->req->parameters->{ del_zgh };
        my $sql = "delete usr_wfw.T_FX_LS where zgh='$zgh'";
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
        my $sql = "update usr_wfw.T_FX_LS set QYZT='$state' where ZGH='$zgh'";
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
