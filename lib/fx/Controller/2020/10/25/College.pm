package fx::Controller::2020::10::25::College;
use Moose;
use utf8;
use POSIX qw(strftime);
use namespace::autoclean;


BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::college - Catalyst Controller
学院管理

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        template => '2020/10/25/colleges.tt2'
    );
}

sub collegeadd : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        # "zwmc": zwmc, "xyywm": xyywm, "xydm": xydm, "xylxr": xylxr, "xylxdh": xylxdh
        my $xyywm = $c->req->parameters->{ xyywm };       # 普通管理员
        my $zwmc = $c->req->parameters->{ zwmc };
        my $xydm = $c->req->parameters->{ xydm };
        my $xylxr = $c->req->parameters->{ xylxr };
        my $xylxdh = $c->req->parameters->{ xylxdh };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "insert into usr_wfw.T_FX_XY(xydm, zwmc, ywmc, lxr, lxdh, GXSJ) values (\'$xydm\', \'$zwmc\', \'$xyywm\', \'$xylxr\', \'$xylxdh\', \'$datestring\')";
        $c->log->info( $sql );
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "学院代码重复" }' );
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub collegeedit : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $xyywm = $c->req->parameters->{ xyywm };       # 普通管理员
        my $zwmc = $c->req->parameters->{ zwmc };
        my $xydm = $c->req->parameters->{ xydm };
        my $xylxr = $c->req->parameters->{ xylxr };
        my $xylxdh = $c->req->parameters->{ xylxdh };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $sql = "update usr_wfw.T_FX_XY set zwmc=\'$zwmc\', ywmc=\'$xyywm\', lxr=\'$xylxr\', lxdh=\'$xylxdh\', GXSJ=\'$datestring\' where xydm=\'$xydm\'";
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "tapplication/json; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "用户已经被删除" }' );
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

sub collegedel : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $xydm = $c->req->parameters->{ xydm };
        my $sql = "select count(*) from usr_wfw.T_FX_ZY where xydm='$xydm'";        # 检查是否下属还存在专业
        my $rtn = DB::get_col_list( $sql )->[0];
        if ( $rtn ne 0 ) {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "该学院下面还存在专业,不可删除" }');
            return 1;
        }
        $sql = "delete usr_wfw.T_FX_XY where xydm='$xydm'";
        $rtn = DB::execute($sql);
        if ($rtn ne 0 && $rtn ne -1) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "01", "RTN_MSG": "执行成功" }');
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
            $c->res->body('{"RTN_CODE": "00", "RTN_MSG": "学院不存在，可能已经被删除" }');
        }
    }
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
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
