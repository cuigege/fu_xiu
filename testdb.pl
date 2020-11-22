#!/usr/bin/perl

use MY::DB;
use strict;
use warnings;
use Perl::Critic;
use Data::Dumper;
use utf8;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");

print(DB::connect_oracle("192.168.120.31", "1521", "xscs", "usr_zsj", "Shuang00"));
# my $res = DB::get_row_list("SELECT rownum , t.* from (select xm from T_BZKS t where ROWNUM < 5 ORDER BY xm desc) t");
# # my $res = DB::get_list("select distinct * from (
# #                            select t2.CDZWM
# #                            from (select * from usr_wfw.T_FX_LJ where LJDM in (1,2,3,4,10)) t1,
# #                                 usr_wfw.T_FX_XTCD t2
# #                            where t1.SSCDDM = t2.CDDM
# #                            order by t2.TJPX asc, t1.TJPX asc
# #                        )
# # ");
# # my $res = DB::auth("select * from usr_wfw.T_FX_GLY where ZHMC=? and DLMM=?", "201721094059", "admin");
# # my @res = DB::execute("insert into usr_wfw.T_FX_LS(SFRZH, XM, BM, CJSJ, GXSJ) values ('1', '好点', '是的', 'abc', '1')");
# # my $res = DB::execute("truncate table usr_wfw.T_FX_LS");
# print Dumper $res;
# if ( $res eq -1 ){
#     print($DB::err_msg);
# } else {
#     print $res;
# }
DB::close();
