
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
  'плугины'=>[ 
      [charset => { charset => 'UTF-8' }, ],
      #~ ['HeaderCondition'],
      #~ ['ParamsArray'],
  ],
  'сессия'=> {cookie_name => 'ELK'},
  'шифры' => ['true 123 my app',],
  # Хуки
  'хуки'=>{
    #~ before_dispatch => sub {1;},
  },
  # Хазы 
  'хазы' => {
    foo => sub {my $app = shift; return 'bar!';},
  },
  'базы'=>{# will be as has!
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
  'запросы' => {
    main => {
      now => "select now();"
    },
  },
  'спейсы'=>[],
  'маршруты' => [
    [get=>'/', to=> {cb=>sub{shift->render(format=>'txt', text=>'Здорова!');},}],
  ]
};
