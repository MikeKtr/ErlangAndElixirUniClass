-module(lab02).

-export([less_than/2,grt_eq_than/2,qs/1,random_elems/3,compare_speeds/3,random_arrays/1,sort_lists/1,qs_proc/2]).

random_elems(N,Min,Max) -> [rand:uniform((Max+1)-Min) + Min - 1  || _X <- lists:seq(1,N)].


less_than(List,Arg) -> [X || X <- List, X < Arg].

grt_eq_than(List,Arg) -> [ X || X <- List, X >= Arg].

qs([]) -> [];
qs([Pivot|Tail]) -> qs(less_than(Tail,Pivot)) ++ [Pivot] ++ qs(grt_eq_than(Tail,Pivot)).

compare_speeds(List,Fun1,Fun2) ->
  {Time1,_} = timer:tc(Fun1,[List]),
  {Time2,_} = timer:tc(Fun2,[List]),
  io:format("Czas wykonania Fun1: ~w ~nCzas wykonanie Fun2: ~w ~nRóżnica pomiędzy pierwszą a drugą: ~w ~n",[Time1,Time2,Time1-Time2]).


%%lists:foldl(fun({_,Value},{Count,Sum}) -> {Count+1,Sum+Value} end, {0,0},[{"pm10",rand:uniform(123)} || _<-lists:seq(1,10)]).

random_arrays(N) ->
  [random_elems(N,1,10000) || _X <- lists:seq(1,N)].

sort_lists(Lists) ->
  [qs(X) || X <- Lists].

qs_proc(List,dest) ->
  dest ! qs(List).

sort_lists_proc(Lists) ->
  [spawn(lab02,qs_proc,[X,self()]) || X <- Lists].