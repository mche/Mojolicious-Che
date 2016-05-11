use FindBin;
use lib "$FindBin::Bin/lib";
use Mojo::Base 'Mojolicious::Che';
sub startup {
  my $app = shift;
  $app->plugin(Config =>{file => 'Config.pm'});
  $app->che_go();
}

__PACKAGE__->new()->start();