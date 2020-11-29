use strict;
use warnings;
use Test::More;


use Catalyst::Test 'fx';
use fx::Controller::2020::10::25::Allow;

ok( request('/2020/10/25/allow')->is_success, 'Request should succeed' );
done_testing();
