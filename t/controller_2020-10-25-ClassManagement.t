use strict;
use warnings;
use Test::More;


use Catalyst::Test 'fx';
use fx::Controller::2020::10::25::ClassManagement;

ok( request('/2020/10/25/classmanagement')->is_success, 'Request should succeed' );
done_testing();
