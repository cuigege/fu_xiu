package fx::Controller::2020::11::15::register;
use Moose;
use namespace::autoclean;
use MY::DB;
use MY::ToolFunc;
use utf8;
use JSON;
use Data::Dumper;
use POSIX qw(strftime);
use Date::Parse;
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

fx::Controller::2020::11::15::register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub auto : Private {

    my ($self,$c)=@_;

    # 查询学生的专业信息
    my $zyInfo = from_json(DB::get_json("select * from usr_wfw.T_FX_XSZY where XH=$c->{student_userinfo}->{XH}"),{allow_nonref=>1})->[0];

    my $zxzy = "未知";
    my $zxzydl = "未知";
    # 判断学生是否有专业大类或专业
    if ( defined $zyInfo ) {
        if ( $zyInfo->{ ZXZY } ) {
            $zxzy = $zyInfo->{ ZXZY };
        }
        if ( $zyInfo->{ ZXZYDL } ) {
            $zxzydl = $zyInfo->{ ZXZYDL };
        }
    }

    $c->{ student_userinfo }->{ ZXZY } = $zxzy;
    $c->{ student_userinfo }->{ ZXZYDL } = $zxzydl;

    return 1;
}



=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $currentYear = strftime "%Y", localtime;  # 当前辅修年份

    # 获取ajax提交数据
    if ( $c->request-> method eq 'POST') {
        # 报名信息存储

        my $params = $c->req->body_parameters;
        my $res = '{"code":0,"msg":"提交失败"}';
        my $studentInfo = $c->{ student_userinfo };
        my $addTime = strftime "%Y-%m-%d %H:%M:%S", localtime;
        $c->log->info(Dumper $studentInfo);

        # 提取辅修专业大类名称和学科名称
        my $fxzydlInfo = from_json(DB::get_json("select * from usr_wfw.T_FX_ZYDL where ZYDLDM=\'$params->{ FXZYDLDM }\'"),{allow_nonref=>1})->[0];
        my $fxzyxkInfo = from_json(DB::get_json("select * from usr_wfw.T_FX_XKML where XKDM=\'$params->{FXZYXKDM}\'"),{allow_nonref=>1})->[0];
        # 查询报名表是否有信息
        my $bmInfo = DB::get_json("select * from usr_wfw.T_FX_BM where SFRZH=$c->{ username }");
        if($bmInfo eq '[]'){
            # 组装 SQL
            my $data = "\'$studentInfo->{XM}\',\'$studentInfo->{XH}\',\'$studentInfo->{XBMC}\',\'$studentInfo->{KSH}\',\'$studentInfo->{SFZJH}\',\'$studentInfo->{MZMC}\',\'$params->{MOBILE}\',\'$addTime\',\'$studentInfo->{ZZMMMC}\',";
            $data .= "\'$currentYear\',\'$studentInfo->{DWDM}\',\'$studentInfo->{XYMC}\',\'$studentInfo->{XZNJ}\',\'$studentInfo->{RXRQ}\',\'$studentInfo->{ZYDM}\',\'$studentInfo->{ZXZY}\',";
            $data .= "\'$params->{FXXYDM}\',\'$params->{FXXYMC}\',\'$params->{FXZYDM}\',\'$params->{FXZYMC}\',\'$params->{FXZYDLDM}\',\'$fxzydlInfo->{ZYDLMC}\',\'$params->{FXZYXKDM}\',\'$fxzyxkInfo->{XKMC}\'";
            my $sql = "insert into usr_wfw.T_FX_BM(XM,SFRZH,XBMC,KSH,SFZH,MZ,LXFS,TJSJ,ZZMM,FXNF,ZXXYDM,ZXXYMC,ZXNJ,ZXRXRQ,ZXZYDM,ZXZYMC,FXXYDM,FXXYMC,FXZYDM,FXZYMC,FXZYDLDM,FXZYDLMC,FXZYXKDM,FXZYXKMC) values($data)";

            my $r = DB::execute($sql);
            if( $r ne 0 ){
                $res = '{"code":1,"msg":"提交成功"}';
            }
        }else{
            $res = '{"code":0,"msg":"已经报名"}';
        }

        $c->res->body( $res );
        return 1;
    }

    # 查询报名表是否有信息
    my $bmInfo = DB::get_json("select * from usr_wfw.T_FX_BM where SFRZH=$c->{ username } and FXNF=$currentYear");

    $c->stash->{ bminfo } = 'false';
    $c->stash->{ fxzy_list } = '[]';
    if( $bmInfo ne '[]' ){
        $c->stash->{ bminfo } = from_json($bmInfo,{allow_nonref=>1})->[0];
        $c->stash->{template} = '20201115/register.html';
    }
    else {

        # 查询报名起止时间

        my $zsjhDate = from_json(DB::get_json("select * from usr_wfw.T_FX_ZSJH_SJ where FXNJ=$currentYear"),{allow_nonref=>1})->[0];

        my $zxzydl = $c->{ student_userinfo }->{ ZXZYDL };

        # 查询当前专业大类代码
        my $zydlInfo = from_json(DB::get_json("select * from usr_wfw.T_FX_ZYDL where ZYDLMC like \'%$zxzydl%\'"),{allow_nonref=>1})->[0];

        # 查询辅修专业 剔除当前学生的专业大类所属的专业
        my $fxzyList = DB::get_json("select * from usr_wfw.T_FX_FXZY where ZYDLDM not in (\'$zydlInfo->{ZYDLDM}\')");

        $c->stash->{ fxzy_list } = $fxzyList;

        # 判断当前时间是否在计划内
        my $bmkssj = str2time($zsjhDate->{ BMKSSJ });
        my $bmjzsj = str2time($zsjhDate->{ BMJZSJ });
        if( $bmkssj < time() && time() < $bmjzsj  ) {
            $c->stash->{template} = '20201115/register.html';
        }
        elsif ( $bmkssj > time() ) {
            $c->{ msg } = "报名时间未开始<br>开始时间:".$zsjhDate->{ BMKSSJ }."<br>结束时间:".$zsjhDate->{ BMJZSJ }; # 512 未查询到用户信息
            $c->{ status_code } = 100;
            $c->{ status_msg } = 'waiting';
            $c->detach('2020::11::15',"error");
            return 0;
        }
        elsif( $bmjzsj < time() ) {
            $c->{ msg } = "报名时间已结束<br>开始时间:".$zsjhDate->{ BMKSSJ }."<br>结束时间:".$zsjhDate->{ BMJZSJ }; # 512 未查询到用户信息
            $c->{ status_code } = 100;
            $c->{ status_msg } = 'waiting';
            $c->detach('2020::11::15',"error");
        }
    }

    return 1;
}


=encoding utf8

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
