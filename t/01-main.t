use strict;
use warnings;
use utf8;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new(MyApp->new(config=>'Config.pm'));
 
$t->get_ok('/')->status_is(200)->content_is('Здорова!');
$t->get_ok('/foo')->status_is(404);

done_testing;

package MyApp;

use Mojo::Base 'Mojolicious::Che';


