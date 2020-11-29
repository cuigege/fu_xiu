package fx::Controller::2020::11::15;
use Moose;
use namespace::autoclean;
use MY::DB;
use Log::Mini;
use MY::ToolFunc;
use utf8;
use JSON;
use Data::Dumper;
use POSIX qw(strftime);
our $syslog = Log::Mini->new(file => 'syserror.log', synced => 1, level => 'warn');
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::11::15 - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2

=cut

sub auto : Private {

    my ( $self, $c ) = @_;
    # 数据库连接控制
    my $file = $ENV{PWD}.'/fxconf.json';    # 获取本地配置文件信息
    $c->{ "self_config" } = ToolFunc::config_hash( $file );

    #  获取数据库配置
    my $db = $c->{ self_config }->{ database }->{ default };

    my $username = "201821111999";  # 统一身份认证号

    $c->{ username } = $username;

    #  连接数据库
    my %config = (
        "log_msg" => "$username $c->{ request }->{ method } $c->{ request }->{ action }",     #  学号 请求方式 请求路径作为日志后置信息
    );

    if ( DB::connect_oracle( $db->{ host }, $db->{ port }, $db->{ db }, $db->{ username }, $db->{ password }, \%config ) eq 0) {
        $c->{ msg } = "数据库连接失败：515"; # 515 数据库连接失败
        $c->{ status_code } = 515;
        $c->detach("error");
        return 0;
    }

     # 查询学生是否配置个人信息  如主修学院 主修学科门类  主修学科大类  主修专业
    my $sql = "select t.XH,t.KSH,t.XM,t.XBDM,t.MZDM,t.SFZJH,t.DWDM,t.ZYDM,t.RXRQ,t.RXNJ,t.XZNJ,t.ZZMMDM, mz.MC as MZMC, xb.MC as XBMC, xy.ZWMC as XYMC, zy.ZWMC as ZYMC,zzmm.MC as ZZMMMC from usr_zsj.T_BZKS t left join usr_zxbz.T_ZXBZ_MZ mz on t.MZDM=mz.DM left join usr_zxbz.T_ZXBZ_XB xb on t.XBDM=xb.DM left join usr_wfw.T_FX_XY xy on t.DWDM=xy.XYDM left join usr_wfw.T_FX_ZY zy on t.ZYDM=zy.ZYDM left join usr_zxbz.T_ZXBZ_ZZMM zzmm on zzmm.DM=t.ZZMMDM where t.XH=$c->{ username }";
    my $userInfo = DB::get_json($sql);

    if($userInfo eq '[]') {
        # 未查询到学生数据
        $c->{ msg } = "未查询到用户信息"; # 512 未查询到用户信息
        $c->{ status_code } = 512;
        $c->detach("error");
        return 0;
    }

    $c->{ student_userinfo } = from_json($userInfo,{allow_nonref=>1})->[0]; # 学生信息

    # 只允许大二学生报名
    $c->log->info(Dumper $c->{student_userinfo}->{RXNJ});
    my $currentYear = strftime "%Y", localtime;  # 当前辅修年份

    if ( $currentYear - $c->{ student_userinfo }->{ RXNJ } > 1 ) {

        $c->{ msg } = "禁止非大二学生报名";
        $c->{ status_code } = 512;
        $c->detach("error");
        return 0;

    }

    return 1;
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->redirect(	# url重定向跳转到主页
        $c->uri_for( $c->controller( '2020::11::15::main' )->action_for( 'index' ) ), 301
    );
}


=head1 error

    error函数 全局error页面跳转位置，可以定制错误信息
    附带信息写入$c，来进行传输
=cut
sub error : Private {
    my ( $self, $c) = @_;

    $c->{ msg } ||= "一切正常, 正在努力工作";
	$c->stash(
        template => '20201115/msg.html',
        msg      => $c->{ msg },
        code     => $c->{ status_code },
        title    => $c->{ msg },
        status_msg   => $c->{ status_msg },
    );
}


=head1 end

    关闭数据库连接 全局关闭这一处
    渲染页面
=cut

sub end : ActionClass('RenderView') {
    my ($self, $c) = @_;
    # $c->res->cookies->{ sessionid } = { value => $c->{ sessionid } };       # 设置cookies
    DB::close();
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
