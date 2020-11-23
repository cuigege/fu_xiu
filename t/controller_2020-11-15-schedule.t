use strict;
use warnings;
use Test::More;


use Catalyst::Test 'fx';
use fx::Controller::2020::11::15::schedule;

ok( request('/2020/11/15/schedule')->is_success, 'Request should succeed' );
done_testing();
