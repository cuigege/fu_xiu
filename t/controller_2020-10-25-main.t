use strict;
use warnings;
use Test::More;


use Catalyst::Test 'fx';
use fx::Controller::2020::10::25::main;

ok( request('/2020/10/25/main')->is_success, 'Request should succeed' );
done_testing();
