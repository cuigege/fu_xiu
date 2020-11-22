package fx::Controller::2020::10::25::MinorTrainingProgram;
use Moose;
use namespace::autoclean;
use utf8;
use POSIX qw{strftime};

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::TrainingProgram - Catalyst Controller
辅修培养方案管理
=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        template => '20201019/minortrainingprogram.html'
    );
}

=head1 trainprogramedit

    培养方案编辑, 有就修改 没有就新增
=cut

sub trainprogramedit : Local {
    my ($self, $c) = @_;
    if ( $c->req->{"method"} eq "POST" ) {
        my $username = $c->{ username };
        my $zydm = $c->req->parameters->{ zydm };
        my $pyfa = $c->req->parameters->{ pyfa };
        my $xfyq = $c->req->parameters->{ xfyq };
        my $jyyq = $c->req->parameters->{ jyyq };
        my $datestring = strftime "%Y-%m-%d %H:%M", localtime;
        my $year = strftime "%Y", localtime;
        my $sql = "select count(*)  from usr_wfw.T_FX_PYFA where substr(xgsj, 0, 4) = \'$year\' and zydm=\'$zydm\'";
        if ( DB::get_row_list( $sql )->[0]->[0] eq 0) {
            $sql = "insert into usr_wfw.T_FX_PYFA(ZYDM, XGSJ, TJR, PYFA, XFYQ, JYYQ, FXNJ) values (\'$zydm\', \'$datestring\', \'$username\', \'$pyfa\', \'$xfyq\', \'$jyyq\', '$year')"
        }
        else {
            $sql = "update usr_wfw.T_FX_PYFA set  pyfa=\'$pyfa\', xfyq=\'$xfyq\', jyyq=\'$jyyq\',tjr=\'$username\', xgsj=\'$datestring\' where zydm=\'$zydm\'";
        }
        my $rtn = DB::execute( $sql );
        if ( $rtn ne 0 && $rtn ne -1 ) {
            $c->res->status(200);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "01", "RTN_MSG": "执行成功" }' );
        }
        else {
            $c->response->status(400);
            $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
            $c->res->body( '{"RTN_CODE": "00", "RTN_MSG": "操作失败, 不能修改非今年的培养方案" }' );
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
