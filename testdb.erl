-module(testdb).

%%-export([start/0, stop/0, write/2, read/1, match/1]).
-compile(export_all).

start() ->
    register(dbservice, spawn(?MODULE, init, [])),
    dbservice.

stop() -> call(stop, []).

write(Key, Value) -> call(write, {Key, Value}).

read(Key) -> call(read, Key).

match(Value) -> call(match, Value).

delete(Key) -> call(delete, Key).

%%backend functions

call(Request, Message) ->
    dbservice ! {Request, self(), Message},
    receive
      {reply, Reply} -> Reply;
      {error, Error} -> Error
      after 5000 -> io:format("timeout for waitting reply")
    end.

loop(Db) ->
    receive
      {write, Pid, {Key, Value}} ->
	  NewDb = write_db({Key, Value}, Db),
	  reply(Pid, {reply, ok});
      {read, Pid, Key} ->
	  Value = query_db(Key, Db),
	  reply(Pid, {reply, Value}),
	  NewDb = Db;
      {match, Pid, Value} ->
	  Key = match_db(Value, Db),
	  reply(Pid, {reply, Key}),
	  NewDb = Db;
      {delete, Pid, Key} ->
	  NewDb = delete_db(Key, Db),
	  reply(Pid, {reply,NewDb});
      {stop, Pid, _} ->
	  NewDb = Db,
	  reply(Pid, {reply, {stopped}}),
	  erlang:exit(stopped);
      {_, Pid, _} ->
	  reply(Pid, {error, "unsupported request"}), NewDb = Db;
      _ -> io:format("wrong format of request"), NewDb = Db
    end,
    loop(NewDb).

reply(Pid, Reply) -> Pid ! Reply.

init() -> InitialDb = create_db(), loop(InitialDb).

create_db() -> [].

write_db(Data, Db) ->
    Result = query_db(element(1, Data), Db),
    case Result of
      {ok, {empty}} -> [Data | Db];
      _ -> {ok, {existing}}
    end.

query_db(_, []) -> {ok, {empty}};
query_db(Key, [Head | Tail]) ->
    case element(1, Head) of
      Key -> {ok, Head};
      _ -> query_db(Key, Tail)
    end.

match_db(Value, DB) -> match_db(Value, DB, []).

match_db(_, [], Acc) ->
    case length(Acc) of
      0 -> {ok, {empty}};
      _ -> {ok, Acc}
    end;
match_db(Value, [Head | Tail], Acc) ->
    case element(2, Head) of
      Value -> match_db(Value, Tail, [Head | Acc]);
      _ -> match_db(Value, Tail)
    end.

delete_db(Key, Db) -> delete_db(Key, Db, []).

delete_db(_, [], _) -> {ok, {unfound}};
delete_db(Key, [Head | Tail], NewDb) ->
    case element(1, Head) of
      Key -> NewDb ++ Tail;
      _ -> delete_db(Key, Tail, NewDb ++ [Head])
    end.
