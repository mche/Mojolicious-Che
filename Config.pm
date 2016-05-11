
=pod

=encoding utf8

Доброго всем

=head1 Mojolicious::Che

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Config.pm - Пример конфига для Mojolicious::Che приложения


=cut


{
  'Проект'=>'Тест-проект',
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
      connect => ["DBI:Pg:dbname=test;", "guest", undef, {
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
      # prepared sth will get $app->sth->{<dbh name>}{<sth name>}
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
  # prepared sth will get $app->sth->{<dbh name>}{<sth name>}
  sth => {
    main => {
      now => "select now();"
    },
  },
	routes => [
    [get=>'/', to=> {cb=>sub{shift->render(format=>'txt', text=>'Hello!');},}],
  ]
};
