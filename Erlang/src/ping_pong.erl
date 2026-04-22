-module(ping_pong).

-export([start/0, stop/0, play/1, ping/1,pong/0]).

start() ->
  register(ping, spawn(ping_pong,ping,[0])),
  register(pong, spawn(ping_pong,pong,[])).


stop() ->
  exit(whereis(ping),kill),
  exit(whereis(pong),kill).

play(N) ->
  ping ! N.

ping(S) ->
  receive
    0 ->
      io:format("Koniec Gry suma : ~p ~n",[S]),
      ping(S);
    N ->
      timer:sleep(200),
      io:format("Ping ~p dotychczasowa suma : ~p ~n",[N,S + N]),
      pong ! N - 1,
      ping(S + N)
  after 20000 ->
    io:format("Koniec Ping ~n"),
    exit(idle_timeout)
  end.

pong() ->
  receive
    0 ->
      io:format("Koniec Gry ~n");
    N ->
      timer:sleep(200),
      io:format("Pong ~p ~n",[N]),
      ping ! N - 1,
      pong()
  after 20000 ->
    io:format("Koniec Pong ~n"),
    exit(idle_timeout)
  end.


