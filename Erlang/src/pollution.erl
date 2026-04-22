-module(pollution).
-author("micha").

%% API
-export([create_monitor/0, add_station/3, add_value/5, remove_value/4, get_one_value/4, get_station_min/3, get_daily_mean/3,get_norms/0,get_air_quality_index/3]).

-type location() :: {float(),float()}.
-type indexMonitor() :: map().
-type monitor() :: map().
-type pollutionMonitor() :: {monitor(),indexMonitor()}.
-type date_time() :: {{integer(),integer(),integer()},{integer(),integer(),integer()}}.
-type station() :: string() | location().

-spec create_monitor() -> pollutionMonitor().
create_monitor() ->
  {#{},#{}}.


-spec add_station(string(),location(),pollutionMonitor()) -> pollutionMonitor() | {error,string()}.
add_station(Name, Location, {Monitor,IndexMonitor}) ->
  MapExists = maps:is_key(Name, IndexMonitor),
  IndexExists = maps:is_key(Location, IndexMonitor),

  case MapExists orelse IndexExists of
    true ->
      {error,"Wpis już istnieje"};
    false ->
      NewMonitor = Monitor#{{Name, Location} => []},

      NewIndex = IndexMonitor#{
        Name => {Name, Location},
        Location => {Name, Location}
      },

      {NewMonitor, NewIndex}
  end.

-spec add_value(station(),date_time(),string(),integer(),pollutionMonitor()) -> pollutionMonitor() | {error,string()}.
add_value(Station,Date,MesType,Value,{Monitor,IndexMonitor}) ->
  NameExists = maps:is_key(Station,IndexMonitor),

  case NameExists of
    true ->
      {Name,Location} = maps:get(Station,IndexMonitor),
      OldList = maps:get({Name,Location},Monitor,[]),
      Found = lists:any(fun({D, M, _V}) -> D == Date andalso M == MesType end, OldList),
      case Found of
        true ->
          {error,"Wartość już istnieje dla tej daty dla tego typu"};
        false ->
          NewList = [{Date,MesType,Value} | OldList],
          NewMonitor = Monitor#{{Name,Location} := NewList},
          {NewMonitor,IndexMonitor}
      end;
    false ->
      {error,"Nie znaleziono wpisu"}
  end.

-spec remove_value(station(),date_time(),string(),pollutionMonitor()) -> pollutionMonitor() | {error,string()}.
remove_value(Station,Date,MesType,{Monitor,IndexMonitor}) ->
  NameExists = maps:is_key(Station,IndexMonitor),
  case NameExists of
    true ->
      {Name,Location} = maps:get(Station,IndexMonitor),
      OldList = maps:get({Name,Location},Monitor,[]),
      Found = lists:any(fun({D, M, _V}) -> D == Date andalso M == MesType end, OldList),
      case Found of
        true ->
          NewList = [{D,M,V} || {D,M,V} <- OldList, MesType =/= M orelse Date =/= D],
          NewMonitor = Monitor#{{Name,Location} := NewList},
          {NewMonitor,IndexMonitor};
        false ->
          {error,"Podana wartość nie istnieje"}
      end;
    false ->
      {error,"Nie znaleziono wpisu"}
  end.

-spec get_one_value(station(),date_time(),string(),pollutionMonitor()) -> integer() | float() .
get_one_value(Station,Date,MesType,{Monitor,IndexMonitor}) ->
  NameExists = maps:is_key(Station,IndexMonitor),
  case NameExists of
    true ->
      {Name,Location} = maps:get(Station,IndexMonitor),
      List = maps:get({Name,Location},Monitor),
      Entries = [{D,M,V} || {D,M,V} <- List , D == Date, M == MesType],
      case Entries of
        [] ->
          {error, "Nie znaleziono wpisu"};
        [{_,_,Value} | _] ->
          Value
      end;
    false ->
      {error,"Nie znaleziono wpisu"}
  end.

-spec get_station_min(station(),string(),pollutionMonitor()) -> float().
get_station_min(Station,MesType,{Monitor,IndexMonitor}) ->
  NameExists = maps:is_key(Station,IndexMonitor),
  case NameExists of
    true ->
      {Name,Location} = maps:get(Station,IndexMonitor),
      List = maps:get({Name,Location},Monitor),
      Entries = [V || {_,M,V} <- List , M == MesType],
      case Entries of
        [] ->
          {error,"Brak wpisów"};
        Data ->
          lists:min(Data)
      end;
    false ->
      {error,"Nie znaleziono wpisu"}
  end.

-spec get_daily_mean(string(),date_time(),pollutionMonitor()) -> float().
get_daily_mean(MesType,Date,{Monitor,_IndexMonitor}) ->
  Values = maps:values(Monitor),
  SelectedValues = [V || R <- Values, {{DateO, _Time}, M, V} <- R , DateO == Date, M == MesType],
  case SelectedValues of
    [] ->
      {error,"Brak wartości dla tych parametrów"};
    _ ->
      {MesSum,MesCnt} = lists:foldl(fun(X,{Sum,Cnt}) -> {Sum+X,Cnt+1} end,{0,0},SelectedValues),
      MesSum/MesCnt
  end.

get_norms() -> #{
    "PM10" => 50,
    "PM2_5" => 20,
    "NO2" => 200,
    "SO2" => 125,
    "BAP" => 1,
    "BENZEN" => 5,
    "O3" => 120
  }.


get_air_quality_index(Station,{Date,{Hour,_,_}},{Monitor,IndexMonitor})->
  NameExists = maps:is_key(Station,IndexMonitor),
  case NameExists of
    true ->
        Entries = [V/maps:get(M,get_norms()) || {{DateO, {H, _M, _S}},M,V} <- maps:get(maps:get(Station,IndexMonitor),Monitor),Date  == DateO,H == Hour,maps:is_key(M,get_norms())],
        case Entries of
          [] ->
            {error,"Brak wpisów o takich parametrach"};
          _ ->
            lists:max(Entries)
        end;
    false ->
        {error,{"Brak wpisów o takich parametrach"}}
  end.
