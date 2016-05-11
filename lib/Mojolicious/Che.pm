package Mojolicious::Che;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.001';

sub che_go {
  my $app = shift;
  my $conf = $app->config;
  
  my $secret = $conf->{'mojo_secret'} || $conf->{'mojo_secrets'} || $conf->{'mojo'}{'secret'} || $conf->{'mojo'}{'secrets'} || [rand];
  $app->secrets($secret);

  $app->mode($conf->{'mojo_mode'} || $conf->{'mojo'}{'mode'} || 'development'); # Файл лога уже не переключишь
  $app->log->level( $conf->{'mojo_log_level'} || $conf->{'mojo'}{'log_level'} || 'debug');
  #~ warn "Mode: ", $app->mode, "; log level: ", $app->log->level;
  
  $app->che_has();
  $app->che_dbh();
  $app->che_sth();
  $app->che_plugins();
  $app->che_hooks();
  $app->che_session();

}

sub che_has { # Хазы из конфига
  my $app = shift;
  my $conf = $app->config;
  my $h = $conf->{'mojo_has'} || $conf->{'mojo'}{'has'};
  map {
    $app->log->debug("Apply has [$_]");
    has $_ => $h->{$_};
  } keys %$h;
}

sub che_plugins {# Плугины из конфига
  my $app = shift;
  my $conf = $app->config;
  my $plugins = $conf->{'mojo_plugins'} || $conf->{'mojo'}{'plugins'}
    || return;
  map {
    $app->plugin(@$_);
    $app->log->debug("Enable plugin [$_[0]]");
  } @$plugins;
}

sub che_dbh {# обрабатывает dbh конфига
  my $app = shift;
  my $conf = $app->config;
  my $c_dbh = $conf->{dbh};
  return unless $c_dbh && ref($c_dbh) eq 'HASH' && keys %$c_dbh;
  has dbh => sub {{};}
    unless $app->can('dbh');
  
  my $dbh = $app->dbh;
  my $sth;
  require DBI;
  
  while (my ($db, $opt) = each %$c_dbh) {
    $dbh->{$db} ||= DBI->connect(@{$opt->{connect}});
    $app->log->debug("Соединился с базой [$opt->{connect}[0]]");
    
    map {
      $dbh->{$db}->do($_);
    } @{$opt->{do}} if $opt->{do};
    
    while (my ($st, $sql) = each %{$opt->{sth}}) {
      $sth ||= do {
        has sth => sub {{};}
          unless $app->can('sth');
        $app->sth;
      };
      $sth->{$db}{$st} = $dbh->{$db}->prepare($sql);# $app->sth->{main}{...}
      $app->log->debug("Подготовился запрос [app->sth->{$db}{$st}]");
    }
  }
  return $dbh, $sth;
  
}

sub che_sth {# обрабатывает sth конфига
  my $app = shift;
  my $conf = $app->config;
  my $c_sth = $conf->{sth};
  return unless $c_sth && ref($c_sth) eq 'HASH' && keys %$c_sth;
  my $dbh = $app->dbh;
  my $sth = $app->sth;
  
  while (my ($db, $h) = each %$c_sth) {
    while (my ($st, $sql) = each %$h) {
      $sth->{$db}{$st} = $dbh->{$db}->prepare($sql);# $app->sth->{main}{...}
      $app->log->debug("Подготовился запрос [app->sth->{$db}{$st}]");
    }
  }
  $sth;
}

  
sub che_hooks {# Хуки из конфига
  my $app = shift;
  my $conf = $app->config;
  my $hooks = $conf->{'mojo_hooks'} || $conf->{'mojo'}{'hooks'}
     || return;
  while (my ($name, $sub) = each %$hooks) {
  #~ map {
    $app->hook($name => $sub);
    $app->log->debug("Applied hook [$name] from config");
  }

}

sub che_session {
  my $app = shift;
  my $conf = $app->config;
  my $session = $conf->{'mojo_session'} || $conf->{'mojo'}{'session'}
    || return;
  $app->sessions->cookie_name($conf->{'cookie_name'});
  
}

sub che_routes {
  my $app = shift;
  my $conf = $app->config;
  my $routes = $conf->{'routes'}
    or return;
  my $app_routes = $app->routes;
  my $apply_route = sub {
    my $r = shift || $app_routes;
    my ($meth, $arg) = @_;
    my $nr;
    if (my $m = $r->can($meth)) {
      $nr = $r->$m($arg) unless ref($arg);
      $nr = $r->$m(@$arg) if ref($arg) eq 'ARRAY';
      $nr = $r->$m(%$arg) if ref($arg) eq 'HASH';
    }  else {
      $app->log->warn("Can't method [$meth] for route",);
    }
    return $nr;
  };
  
  for my $r (@$routes) {
    my $nr = $apply_route->($app_routes, @$r[0,1])
      or next;
    for( my $i = 2; $i < @$r; $i += 2 ) {
      $nr = $apply_route->($nr, @$r[$i, $i+1])
        or next;
    }
  }
}

1;

=pod

=encoding utf8

Доброго всем

=head1 Mojolicious::Che

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 VERSION

0.001

=head1 NAME

Mojolicious::Che - Мой базовый модуль для приложений Mojolicious. Нужен только развернутый конфиг.

=head1 SYNOPSIS

  use Mojo::Base 'Mojolicious::Che';
  
  sub startup {
    my $app = shift;
    $app->plugin(Config =>{file => 'Config.pm'});
    $app->che_go();
  }
  __PACKAGE__->new()->start();


=head1 Config file

  {
  'Проект'=>'Тест-проект',
  # mojo => {
    # mode=>...,
    # log_level => ...,
    # secrets => ...,
    # plugins=> ...,
    # session => ...,
    # hooks => ...,
    # has => ...,
  # },
  mojo_mode=> 'development',
  mojo_log_level => 'debug',
  mojo_plugins=>[ 
      [charset => { charset => 'UTF-8' }, ],
      #~ ['HeaderCondition'],
      #~ ['ParamsArray'],
  ],
  mojo_session => {cookie_name => 'SESS'},
  # Хуки
  mojo_hooks=>{
    #~ before_dispatch => sub {1;},
  },
  # Хазы 
  mojo_has => {
    foo => sub {my $app = shift; return 'bar!';},
  },
  mojo_secrets => ['true 123 my app',],
  
  dbh=>{# will be as has!
    'main' => {
      # DBI->connect(dsn, user, passwd, $attrs)
      connect => ["DBI:Pg:dbname=test;", "postgres", undef, {
        ShowErrorStatement => 1,
        AutoCommit => 1,
        RaiseError => 1,
        PrintError => 1, 
        pg_enable_utf8 => 1,
        #mysql_enable_utf8 => 1,
        #mysql_auto_reconnect=>1,
      }],
      # will do on connect
      do => ['set datestyle to "ISO, DMY";',],
      # prepared sth will be as has $app->sth->{<dbh name>}{<sth name>}
      sth => {
        foo => <<SQL,
  select * 
  from foo
  where
    bar = ?;
  SQL
      },
    }
  },
  # prepared sth will be as has $app->sth->{<dbh name>}{<sth name>}
  sth => {
    main => {
      now => "select now();"
    },
  },
  routes => [
    [get=>'/', to=> {cb=>sub{shift->render(format=>'txt', text=>'Hello!');},}],
  ]
  };


=head1 SEE ALSO

L<Ado>

L<>

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/Mojolicious-Che/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2016 Mikhail Che.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut