package fx::Controller::2020::10::25;
use Moose;
use namespace::autoclean;
use MY::DB;
use Log::Mini;
use MY::ToolFunc;
use utf8;
use JSON;
use Data::Dumper;
our $syslog = Log::Mini->new(file => 'syserror.log', synced => 1, level => 'warn');
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::10::25 - Catalyst Controller

 /***
 *
 *
 *                                                    __----~~~~~~~~~~~------___
 *                                   .  .   ~~//====......          __--~ ~~
 *                   -.            \_|//     |||\\  ~~~~~~::::... /~
 *                ___-==_       _-~o~  \/    |||  \\            _/~~-
 *        __---~~~.==~||\=_    -_--~/_-~|-   |\\   \\        _/~
 *    _-~~     .=~    |  \\-_    '-~7  /-   /  ||    \      /
 *  .~       .~       |   \\ -_    /  /-   /   ||      \   /
 * /  ____  /         |     \\ ~-_/  /|- _/   .||       \ /
 * |~~    ~~|--~~~~--_ \     ~==-/   | \~--===~~        .\
 *          '         ~-|      /|    |-~\~~       __--~~
 *                      |-~~-_/ |    |   ~\_   _-~            /\
 *                           /  \     \__   \/~                \__
 *                       _--~ _/ | .-~~____--~-/                  ~~==.
 *                      ((->/~   '.|||' -_|    ~~-/ ,              . _||
 *                                 -_     ~\      ~~---l__i__i__i--~~_/
 *                                 _-~-__   ~)  \--______________--~~
 *                               //.-~~~-~_--~- |-------~~~~~~~~
 *                                      //.-~~~--\
 *                               神兽保佑
 *                              代码无BUG!
 */

=head1 DESCRIPTION

Catalyst Controller.

=head1 auto

   控制逻辑：
    获取配置文件信息丢到$c
    连接数据库 全局连接这一处
    访问登录页面直接跳转
    获取用户session到$c，没有获取到就重定向到登录
    拿到session后到访问角色权限和路径进行对比，有当前路径权限则放行
    如果是接口则和当前路径到接口权限进行对比，有权限则放行
    对比访问权限，没有权限则返回403
    进入业务函数
=cut

sub auto : Private {

    my ( $self, $c ) = @_;
    # 数据库连接控制
    my $file = $ENV{PWD}.'/fxconf.json';    # 获取本地配置文件信息
    $c->{ "self_config" } = ToolFunc::config_hash( $file );

    # 获取用户名
    my $username =  "201721094059" || $c->user->username() || $c->req->cookies->{ sessionid }->{value}->[0];
    # my $username =  "2020" || $c->user->username() || $c->req->cookies->{ sessionid }->{value}->[0];

    $c->{ sessionid } = $username;
    $c->{ username } = $username;

    $c->{ base_url } = "2020/10/25";

    #  获取数据库配置
    my $db = $c->{ self_config }->{ database }->{ default };

    #  连接数据库
    my %config = (
        "log_msg" => "$username $c->{ request }->{ method } $c->{ request }->{ action }",     #  学号 请求方式 请求路径作为日志后置信息
    );
    if ( DB::connect_oracle( $db->{ host }, $db->{ port }, $db->{ db }, $db->{ username }, $db->{ password }, \%config ) eq 0) {
        $c->{ msg } = "数据库连接失败：515"; # 515 数据库连接失败
        $c->{ status_code } = 515;
        $c->detach("error");
    };

    # 获取用户权限写入session
    my $rtn = set_privilege($username, $c);
    # 页面的权限控制
    my $path = $c->req->action;                                 # 获取当前访问路径
    $path =~ /[^$c->{base_url}].*/;
    my $qx = ToolFunc::privilege( $&, $c->{ sessionid } );        #  有权限返回1 没有返回0
    if ( $qx eq '-2' ) {
        $c->{ msg } = "路径表被锁，请稍后再试：412"; # 412 路径表锁
        $c->{ status_code } = 500;
        $c->detach("error");
    }
    if ($qx eq 0 || $qx eq -1) {
        my $code = set_privilege($username, $c); # 二次权限判断重新刷新权限缓存
        if ($code eq 1) {
            $qx = ToolFunc::privilege($&, $c->{ sessionid }); #  有权限返回1 没有返回0
            if ($qx eq 0 || $qx eq -1) {
                $c->{ msg } = "该路径无访问权限，请联系管理员获取权限：411"; # 411 访问路径没有GET权限
                $c->{ status_code } = 403;
                $c->detach("error");
            }
        }    
    }

    # 判断用户有效期 和是否激活 获取用户有效期时间 截止时间 是否启用
    my $sql = "select * from (
                  select ZHMC ZGH, YHXM XM, QYZT, YXQKSSJ, YXQJZSJ
                  from usr_wfw.T_FX_GLY
                  union
                  select ZGH, JSXM XM, QYZT, YXQKSSJ, YXQJZSJ
                  from usr_wfw.T_FX_LS
              ) t where ZGH='$username'";
    my $res = from_json( DB::get_json( $sql ), {allow_nonref=>1} )->[0];
    if ( $res->{QYZT} eq 0 ) {
        $c->{ msg } = "账户被禁用：413"; # 413账户被禁用
        $c->{ status_code } = 403;
        $c->detach("error");
    }
    return 1;
}

=head2 index

	顶级模块index不参与业务逻辑，只做中间件用或者跳转
=cut

=head1 privileges

       权限控制函数 有权限返回1, 无权限返回0
=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	my $res = DB::get_json("select * from usr_wfw.T_FX_GLY where ZHMC='$c->{username}'");
    if ( $res eq 0) {
        $c->{ msg } = "数据调用发生错误: 511";      # 511 主页sql执行错误
        $c->{ status_code } = 500;
        $c->detach( "error" );
        return 1;
	}
    elsif ( $res eq '[]' ) {
        $c->{ msg } = "非法访问，你并无该应用的使用权限：512";      # 512 没有查询到用户信息 非法
        $c->{ status_code } = 403;
        $c->detach( "error");
        return 1;
	}
    else {
        $res = from_json( $res, {allow_nonref=>1})->[0];
        $c->{data} = $res;                                                              # 写入模版
        my $sql = "select * from (
                    select JSQX from usr_wfw.T_FX_JS where JSDM in (select JSDM from usr_wfw.T_FX_GLY where ZHMC = '$c->{ username }')
                    union select DLQX from usr_wfw.T_FX_GLY where ZHMC='$c->{ username }'
                ) where JSQX is not null";             # 获取用户下所有权限路径id
        $res = DB::get_col_list( $sql );
        if (! @$res) {                                 # 权限代码为空，则表示没有任何权限访问
            $c->{ msg } = "菜单无访问权限：410";               # 51 没有查询到用户信息 非法
            $c->{ status_code } = 403;
            $c->detach( "error" );
        }
        my $qxdm = join(',', @$res );
        # 根据权限代码获取链接
        $sql = qq(select t2.CDZWM, t1.ZWM LJZWM, t1.LJ from
                    ( select * from usr_wfw.T_FX_LJ where LJDM in ($qxdm) ) t1,
                    usr_wfw.T_FX_XTCD t2 where t1.SSCDDM=t2.CDDM order by t2.TJPX asc ,t1.TJPX asc
                );
        my $links = from_json( DB::get_json( $sql ), {allow_nonref=>1} );
        # 获取主目录;
        $sql = qq(select CDZWM, TB from (
                    select distinct * from (
                       select t2.CDZWM, t2.TJPX, t2.TB
                       from (select * from usr_wfw.T_FX_LJ where LJDM in ($qxdm)) t1,
                            usr_wfw.T_FX_XTCD t2
                       where t1.SSCDDM = t2.CDDM
                       order by t2.TJPX asc
                   )  order by TJPX
                ));
        my $category = DB::get_row_list( $sql );
        my @result;     # 数据格式 [{"name": "项目管理", "links": [{"name": "项目列表", "link": "/project"}]}]
        foreach my $key ( @$category ) {
            my $iterm;
            $iterm->{ "name" } = $key->[0];
            $iterm->{ "icon" } = $key->[1];
            my @links;
            foreach my $val ( @$links ) {
                my $link;
                if ( $val->{ CDZWM } eq $key->[0] ) {
                    $link->{ name } = $val->{ LJZWM };
                    $link->{ link } = $val->{ LJ };
                    push( @links, $link );
                }
            }
            $iterm->{ "links" } = \@links;
            push( @result, $iterm );
        }
        $c->stash(      #  目录结构树
            tree    =>  \@result
	    );
    }
	$c->stash(
		template    => '2020/10/25/base.tt2',
	);
}


=head1 set_privilege

    设置权限缓存到redis 成功返回1 失败返回0
=cut

sub set_privilege {
    my ( $username, $c) = @_;
    my $sql = "select * from (
            select JSQX from usr_wfw.T_FX_JS where JSDM in (select JSDM from usr_wfw.T_FX_GLY where ZHMC = '$username')
            union select DLQX from usr_wfw.T_FX_GLY where ZHMC='$username'
    ) where JSQX is not null";
    my $res = DB::get_col_list( $sql );
    my $qxarr;
    if ( $res eq 0 ) {
        return 0;
    }
    foreach my $val ( @$res ) {
        push(@$qxarr, split( /\s*,\s*/, $val ));
    }
    my $rtn = ToolFunc::set_session_cover_pre($username, to_json( $qxarr, {allow_nonref=>1} ));
    if ( $rtn eq 0 ) {   # session设置失败
        $c->{ msg } = "Redis工作异常: 514";
        $c->{ status_code } = 500;
        $c->detach( "error" );
    }
    return 1;
}

=head1 logout

    注销登录逻辑
=cut

sub logout : Local {
    my ( $self, $c ) = @_;
    my $sessionid = $c->req->cookies->{ sessionid }->{value}->[0];
    # if ( ToolFunc::get_session( $sessionid ) eq 0 ){                    # 不存在则跳转登录
    #     $c->response->redirect(	                                        # url重定向到登录
    #         $c->uri_for( $c->controller( '2020::10::25' )->action_for( 'login' ) )
    #     );
    #     $c->detach();
    #     return 1;
    # }
    my $rtn = ToolFunc::set_session_cover_pre( $sessionid, '{}', 1 );
    if ( $rtn eq 1 ){
        # $c->remove_persisted_user($c);
        $c->delete_session($c->res->cookies->{ fx_session }); # 删除session
        $c->logout();
    }
    elsif ( $rtn eq 0 ) {
        $c->{ msg } = "Redis服务异常: 510";
        $c->{ status_code } = 500;
        $c->detach( "error");
        return 1;
    }
    $c->response->redirect(	                                        # url重定向到登录
            "http://id.scuec.edu.cn/authserver/logout?service=http://210.42.150.134:8000%2F2020%2F10%2F25"
    );
    $c->detach();
}

=head1 default

    默认页面404配置
=cut

sub default : Local {
    my ( $self, $c) = @_;
    $c->response->status( 404 );
	$c->stash(
        template    => '2020/10/25/error-404.tt2',
        title       => "页面不存在"
    );
}

=head1 error

    error函数 全局error页面跳转位置，可以定制错误信息
    附带信息写入$c，来进行传输
=cut
sub error : Private {
    my ( $self, $c) = @_;
    $c->{ status_code } ||= 200;
    $c->{ msg } ||= "一切正常, 正在努力工作";
    $c->response->status( $c->{ status_code } );
	$c->stash(
        template => '2020/10/25/error-500.tt2',
        msg      => $c->{ msg },
        code     => $c->{ status_code },
        title    => $c->{ msg },
    );
}
=cut

=head1 end

    关闭数据库连接 全局关闭这一处
    渲染页面
=cut

sub end : ActionClass('RenderView') {
    my ($self, $c) = @_;
    DB::close();
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
