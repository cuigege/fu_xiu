package fx::Controller::2020::10::25::MinorEnrollmentManage;
use Moose;
use namespace::autoclean;
use utf8;
use POSIX qw{strftime};
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::MinorEnrollmentManage - Catalyst Controller
辅修招生报名管理
=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash({
        template    => "20201019/minorenrollstudentlist.html",
    });
}

=head1 review

    审核接口 1为通过 -1 为拒绝 0 为报名
=cut

sub review : Local {
    my ( $self, $c ) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $sfrzh = $c->req->parameters->{ sfrzh };  # 学号
        my $shzt = $c->req->parameters->{ shzt };   # 审核状态
        my $shyj = $c->req->parameters->{ shyj } || '无';   # 审核意见
        my $username = $c->{username};      # 审核人
        my $year = strftime("%Y", localtime);
        my $sql = "update usr_wfw.T_FX_BM set shzt=\'$shzt\', shyj=\'$shyj\', shr=\'$username\' where sfrzh=\'$sfrzh\' and fxnf=\'$year\'";
        $c->log->info($sql);
        my $rtn = DB::execute( $sql );
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
    else {
        $c->res->status(403);
        $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8;";
        $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "调用方法不合法" }' );
    }
}

=head1 passed

    审核通过列表
=cut

sub reviewpassed : Local {
    my ( $self, $c ) = @_;
    $c->stash({
        template    => "20201019/minorenrollstudentlist_passed.html",
    });
}

=head1 reject

    审核被拒列表
=cut

sub reviewreject : Local {
    my ( $self, $c ) = @_;
    $c->stash({
        template    => "20201019/minorenrollstudentlist_reject.html",
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
