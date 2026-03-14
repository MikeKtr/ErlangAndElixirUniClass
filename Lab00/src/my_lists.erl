
-module(my_lists).

-export([contains/2,duplicate/1,sum_floats/1]).

contains([],_Value) -> false;
contains([Value | _Tail], Value) -> true;
contains([_Head | Tail], Value) -> contains(Tail,Value).


duplicate([]) -> [];
duplicate([Value] )-> [Value, Value];
duplicate([Value | Tail]) -> [Value, Value | duplicate(Tail)].

sum_floats(List) -> sum_floats(List,0.0).

sum_floats([],Acc) -> Acc;
sum_floats([Value | Tail],Acc) -> sum_floats(Tail,Acc + Value).