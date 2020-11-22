package fx::Controller::2020::10::25::API;
use Moose;
use namespace::autoclean;
use MY::DB;
use MY::ToolFunc;
use utf8;
use JSON;
use Encode;
use Data::Dumper;
BEGIN {extends 'Catalyst::Controller';}

=head1 NAME

perl_api::Controller::2020::11::09 - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 auto

    获取访问路径 -> 获取配置信息 -> 判断是否符合接口规则 -> 连接数据库 -> 添加相应头
=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    # 分发控制
    $c->req->{ _path } =~ /[\d|\/]*api\//ig;
    $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";     # 设置响应字符集
    if ( ! defined $' ) {
        $c->res->body( $c->encoding->encode( '{"RTN_MSG": "访问接口不存在", "RTN_CODE": "-1"}', $c->_encode_check ) );
        $c->detach();
    }
    my $db_key = $';

    # 数据库连接控制
    my $file = $ENV{PWD}.'/api_conf.json';    # 获取本地配置文件信息
    $c->{ config } = ToolFunc::config_hash( $file );
    my $req_url = $db_key;
    if ( ! $c->{ config }->{ api }->{ $req_url } ) {
        $c->res->body( $c->encoding->encode( '{"RTN_MSG": "访问接口不存在", "RTN_CODE": "-1"}', $c->_encode_check ) );
        $c->detach();
    }
    $c->{ api } = $c->{ config }->{ api }->{ $req_url };
    #  判断请求方法是否符合规则
    my $req_method = $c->req->{ method };
    my $flag = 'false';
    foreach my $method ( @{ $c->{ api }->{ allow_method } } ) {      # 寻找当前方法是否在配置表里面, 优先匹配的放前面
        if ( $method eq $req_method) {
            $flag = 'true';
            last;
        }
    }
    if ( $flag eq 'false' ) {     # 请求方法拦截
        $c->{ RTN_CODE } = "02";
        $c->{ RTN_MSG } = "请求方法不对";
        $c->detach("error");
    }
    my $parameters = $c->req->body_data || $c->req->parameters ; # 匹配application/json 和 application/x-www-form-urlencoded
    # 判断参数完整性 参数长度相等
    my @allow_field = @{ $c->{ api }->{ allow_field } };      #  获取素组重复值，得到入参个数结果
    my %saw;
    @saw{ @allow_field } = ( );
    my @uniq_array = sort keys %saw;
    if ( scalar keys %{ $parameters }  < scalar @uniq_array ) {
        $c->{ RTN_CODE } = "04";
        $c->{ RTN_MSG } = "参数不完整";
        $c->detach("error");
    }
    elsif ( scalar keys %{ $parameters }  > scalar @uniq_array ) {
        $c->{ RTN_CODE } = "04";
        $c->{ RTN_MSG } = "参数过多";
        $c->detach("error");
    }

    #  判断请求字段是否符合规则
    my $illegal_keys = [];   # 非法键
    my $field_str = join(" ", @{ $c->{ api }->{ allow_field } } );            # 空格隔开
    foreach my $req_key ( keys %{ $parameters } ) {      # 允许的字段数组
        if ( not $field_str =~ /$req_key/ ) {            # 没有匹配到
            push @$illegal_keys, $req_key;                # 非法参数
        }
    }
    if ( scalar @$illegal_keys ne 0 ) {
        $c->{ RTN_CODE } = "03";
        $c->{ RTN_MSG } = "入参不合法 @$illegal_keys (注意：大小写敏感)";
        $c->detach("error");
    }

    #  获取数据库配置
    $db_key = $c->{ api }->{ connect_db };
    my $db = $c->{ config }->{ database }->{ $c->{ api }->{ driver } }->{ $db_key };

    #  连接数据库
    my %config = (
        "log_msg" => "访问ip: $c->{ request }->{ address }",     #  学号 请求方式 请求路径作为日志后置信息
    );
    if ( $c->{ api }->{ driver } =~ /oracle/ig ) {
        DB::connect_oracle( $db->{ host }, $db->{ port }, $db->{ db }, $db->{ username }, $db->{ password }, \%config );
    }
    elsif ($c->{ api }->{ driver } =~ /sqlserver/ig ) {
        DB::connect_sqlserver( $db->{ host }, $db->{ port }, $db->{ db }, $db->{ username }, $db->{ password }, \%config );
    }
    else {
        # $syslog->error("$c->{ api }->{ driver }  not a right driver name");
        print( "$c->{ api }->{ driver }  not a right driver name" )
    }
    $c->res->headers->{ "Content-Type" } = "application/json; charset=UTF-8";
    $c->detach("index");        # 跳转数据业务逻辑
}

=head2 index

    Oracle接口
    RTN_CODE
        00：数据库执行SQL出现异常
        01：返回数据, 数据为空也算，SQL执行正常
        02：请求方法不对
        03：入参不合法
        04：参数数量不合法 过多或者过少
=cut

sub index :Path :Args(0) {
    $DB::log_flag = 1;
    my ( $self, $c ) = @_;
    my $sql = $c->{ api }->{ PrepareSQL };
    my $parameters = $c->req->body_data || $c->req->parameters;         # 匹配application/json 和 application/x-www-form-urlencoded
    my $params = "";
    foreach my $key ( @{ $c->{ api }->{ allow_field } } ) {
        if ($parameters->{$key} eq '') {            # 排除空字符
            next;
        }
        $params .= $parameters->{$key}.'&&@@';
    }
    $c->log->info($params);
    my $data;
    if ( $c->{api}->{type} eq 'select' ) {
        if ( $c->{ api }->{ driver } eq "oracle" ) {
            $data = DB::oracle_api_get_json( $sql,  $params );    # oracle api函数
        }
        elsif ( $c->{api}->{driver} eq "sqlserver" ) {
            $data = DB::mssql_api_get_json( $sql,  $params );    # sqlserver api函数
        }
    }
    else {  # 默认select
        $data = DB::api_execute( $sql,  $params );    # sqlserver api函数
    }
    if ( $data eq 0 ) {
        $c->{ status_code } = 500;
        $c->{ RTN_CODE } = "00";
        if (  $c->{api}->{type} eq 'select' ) {
            $c->{ RTN_MSG } = "查询失败";
        }
        else {
            $c->{ RTN_MSG } = "执行失败";
        }
        $c->detach("error");
        return 1;
    }
    $data =~ s/"ROWNUM":"(\d|\w|-)*",?//g;      # 去掉sqlserver ROWNUM
    $data =~ s/"ROWNUM":"\d*",?//g;      # 去掉去掉sqlserver ROWNUM
    $data =~ s/,\}/\}/g;      # 去掉,}
    my $res;
    if ( $c->{api}->{type} eq 'select') {
        $res = "{\"RTN_CODE\": \"01\", \"RTN_MSG\": \"查询成功\", \"DATA\": $data}";
    }
    else {
        $res = "{\"RTN_CODE\": \"01\", \"RTN_MSG\": \"执行成功\"}";
    }
    $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
    $c->res->body( $c->encoding->encode( $res, $c->_encode_check ) );
}

=head1 end

    关闭数据库
=cut

sub end : Private {
    DB::close();
}

=head1 error

    error函数 全局error页面跳转位置，可以定制错误信息
    附带信息写入$c，来进行传输
=cut
sub error : Private {
    my ( $self, $c) = @_;
    $c->{ status_code } ||= 403;
    $c->{ RTN_CODE } ||= 403;
    $c->{ RTN_MSG } ||= "接口调用失败";
    $c->res->status( $c->{ status_code } );
    $c->res->headers->{ "Content-Type" } = "text/plain; charset=UTF-8";
    my $res = "{\"RTN_CODE\": \"$c->{ RTN_CODE }\", \"RTN_MSG\": \"$c->{ RTN_MSG }\" }";
    $c->res->body( $c->encoding->encode( $res, $c->_encode_check ) );
}

=head1 default

    接口默认返回
=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->status(404);
	$c->res->body("api default");
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
