use strict;
use warnings;
use Test::More;


use Catalyst::Test 'fx';
use fx::Controller::2020::10:25::API;

ok( request('/2020/10:25/api')->is_success, 'Request should succeed' );
done_testing();
