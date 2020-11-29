package fx::Controller::2020::10::25::Allow;
use Moose;
use namespace::autoclean;
use utf8;
use Data::Dumper;
use JSON;



BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25::Allow - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash({
        template    =>  "2020/10/25/studentlist.tt2"
    })
}


=head2 import()

    学生信息导入

=cut

sub import : Local {

    my ( $self, $c ) = @_;

    if ( $c->req->method eq "POST" && $c->req->upload('file') ) {

        # 清空以前数据
        DB::execute("delete from usr_wfw.T_FX_XSZY");

        my %res = ToolFunc::upload_func($c,'usr_wfw.T_FX_XSZY',qw/XH XM ZXXY ZXZYDL ZXZY/);

        $c->log->info(Dumper \%res);

        $c->res->body(to_json(\%res,{allow_nonref=>1}));
        return 1;
    }


    $c->stash({
        template    =>  "2020/10/25/studentimport.tt2"
    })
}



=encoding utf8

=head1 AUTHOR

CuiMay,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
