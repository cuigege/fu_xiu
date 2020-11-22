use strict;
use warnings;

use fx;

my $app = fx->apply_default_middlewares(fx->psgi_app);
$app;

