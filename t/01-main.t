use strict;
use warnings;
use utf8;

use Test::More tests => 7;
 
use_ok('Mojolicious::Che');
use_ok('Test::Mojo');

my $t = Test::Mojo->new(MyApp->new());
 
$t->get_ok('/')->status_is(200)->content_is('Hello!');
$t->get_ok('/foo')->status_is(404);


package MyApp;

use Mojo::Base 'Mojolicious::Che';

sub startup {
  my $app = shift;
  $app->plugin(Config =>{file => '../Config.pm'});
  $app->che_go();
}
