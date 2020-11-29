package fx::View::HTML5;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        fx->path_to( 'root', 'src' ),
        fx->path_to( 'root', 'lib' )
    ],
	ENCODING => 'UTF-8',
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.html',
    TIMER        => 0,
    render_die   => 1,
});

=head1 NAME

fx::View::html - Catalyst TT Twitter Bootstrap View

=head1 SYNOPSIS

See L<fx>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

LH'MAC

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

