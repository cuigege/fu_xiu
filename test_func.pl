#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use MY::ToolFunc;

# my $file = $ENV{PWD}."/fxconf.json";
# my $config = ToolFunc::config_hash($file);
# print( Dumper ( $config ) );

ToolFunc::set_session("username", "{\"data\": \"你好\", \"code\": \"01\"}");
print(Dumper(ToolFunc::get_session("username")));