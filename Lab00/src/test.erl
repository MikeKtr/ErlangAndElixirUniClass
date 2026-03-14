-module(test).

-export([getData/0,calculate_min_max/2,number_of_readings/2,calculate_mean/2]).



getData() ->
  [

    {"Krk_1", {50.0614, 19.9383}, {{2026, 3, 12}, {12, 0, 0}}, [{"PM10", 45.5}, {"PM2.5", 28.1}, {"Temperatura", 12.0}]},
    {"Krk_1", {50.0614, 19.9383}, {{2026, 3, 13}, {12, 0, 0}}, [{"PM10", 60.2}, {"PM2.5", 35.0}, {"Temperatura", 10.5}]},
    {"Krk_1", {50.0614, 19.9383}, {{2026, 3, 14}, {12, 0, 0}}, [{"PM10", 30.0}, {"PM2.5", 15.5}, {"Temperatura", 14.2}]},

    {"Waw_1", {52.2297, 21.0122}, {{2026, 3, 12}, {12, 0, 0}}, [{"PM10", 55.0}, {"PM2.5", 30.5}, {"Temperatura", 11.0}, {"Cisnienie", 1012}]},
    {"Waw_1", {52.2297, 21.0122}, {{2026, 3, 13}, {12, 0, 0}}, [{"PM10", 40.5}, {"PM2.5", 22.0}, {"Temperatura",  9.5}, {"Cisnienie", 1015}]},
    {"Waw_1", {52.2297, 21.0122}, {{2026, 3, 14}, {12, 0, 0}}, [{"PM10", 25.0}, {"PM2.5", 12.0}, {"Temperatura", 13.0}, {"Cisnienie", 1020}]},

    {"Gda_1", {54.3520, 18.6466}, {{2026, 3, 12}, {12, 0, 0}}, [{"Temperatura",  8.5}, {"Cisnienie", 1010}, {"Wilgotnosc", 80}]},
    {"Gda_1", {54.3520, 18.6466}, {{2026, 3, 13}, {12, 0, 0}}, [{"Temperatura",  7.0}, {"Cisnienie", 1008}, {"Wilgotnosc", 85}]},
    {"Gda_1", {54.3520, 18.6466}, {{2026, 3, 14}, {12, 0, 0}}, [{"Temperatura", 10.5}, {"Cisnienie", 1012}, {"Wilgotnosc", 75}]}
  ].



number_of_readings(Readings,Date) -> number_of_readings(Readings,Date,0).

number_of_readings([],_Date,Acc) -> Acc;
number_of_readings([{_,_,{{Date},{_,_,_}},_} | Tail],Date,Acc) -> number_of_readings(Tail,Date,Acc + 1);
number_of_readings([_Reading | Tail],Date,Acc) -> number_of_readings(Tail,Date,Acc).


getFirstType([Reading | Tail],Type) ->
  {_ , _ , _ , List } = Reading,
  case proplists:get_value(Type,List) of
    undefined -> getFirstType(Tail,Type);
    Wartosc -> Wartosc
  end.

calculate_min_max(Readings,Type) ->
  StartValue = getFirstType(Readings,Type),
  calculate_min_max(Readings,Type,StartValue,StartValue).

calculate_min_max([],_Type,Min,Max) -> {Min,Max};

calculate_min_max([Reading | Tail],Type,Min,Max) ->
  {_ , _ , _ , List } = Reading,
  case proplists:get_value(Type,List) of
    undefined -> calculate_min_max(Tail,Type,Min,Max);
    Wartosc -> calculate_min_max(Tail,Type,min(Wartosc,Min),max(Wartosc,Max))
  end.


calculate_mean(Readings,Type) ->
  calculate_mean(Readings,Type,0,0).

calculate_mean([], _Type, _Sum, 0) ->
  {blad, brak_danych};

calculate_mean([],Type,Sum,Amount) -> Sum/Amount;


calculate_mean([Reading | Tail],Type,Sum,Amount) ->
  {_,_,_,List} = Reading,
  case proplists:get_value(Type,List) of
    undefined -> calculate_mean(Tail,Type,Sum,Amount);
    Value -> calculate_mean(Tail,Type,Sum + Value ,Amount + 1)
  end.
