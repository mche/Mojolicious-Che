use strict;
use warnings;
use utf8;

use Test::More tests => 21;
 
use_ok('Mojolicious::Che');
use_ok('Test::Mojo');

use Mojo::Base 'Mojolicious::Che';

sub startup {
  my $app = shift;
  $app->plugin(Config =>{file => 'Config.pm'});
  $app->che_go();
}


my $t = Test::Mojo->new;
 
$t->get_ok('/')->status_is(200)->content_is('index page');
$t->get_ok('/authonly')->status_is(200)->content_is('not authenticated');
$t->get_ok('/condition/authonly')->status_is(404);

