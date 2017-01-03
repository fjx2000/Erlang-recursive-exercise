-module(recursion).
-compile(export_all).
-compile([debug_info]).

%%% Exercise 1, 编写一个函数sum/1，给定一个正数N, 返回值是1到N的整数和.

%% recursion
sum(1)->
    1;
sum(N)->
    N+sum(N-1).

%% tail recursion
sum_tail(N)->
    sum_acc(N,0).
	
sum_acc(0, Acc)->
     Acc;
sum_acc(N, Acc)->
     sum_acc(N-1, Acc+N).
	 
%%% Exercise 2, 编写一个函数sum/2，给定两个正整数M,N, 如果N小于等于M，返回N到M的整数和，否则进程异常终止.

%% recursion
sum(N, M) when N < M ->
	          sum(N+1,M) + N;
sum(N,N)->
    N;
sum(_N,_M)->
    erlang:error({error, "arg1 is bigger than arg2"}).
   
%% recursion_tail
sum_tail(N,M) when N < M ->
                  sum_acc(N, M, 0);
sum_tail(N,N)->
    N;
sum_tail(_,_)->
  erlang:error({error, "arg1 is bigger than arg2"}).
  
sum_acc(N,M,Acc) when N < M->
                   sum_acc(N+1, M, N+Acc);
sum_acc(N, N, Acc)->
     N+Acc.

%%% Exercise 3, 编写一个返回格式为 	 [1,2，3....N]的列表的函数，比如create_list(4) 返回[1,2，3，4]
%%recursion				  
create_list(N) ->   create_list(1, N).
create_list(M,M) ->  [M];
create_list(M,N) -> [M | create_list(M+1, N)].

%%recursion_tail
create_list_acc(N) ->   create_list_acc(1, N, []).
create_list_acc(M,M,Acc) ->  [M|Acc];
create_list_acc(M,N,Acc) -> create_list_acc(M, N-1, [N|Acc]).

%%% Exercise 4, 编写一个返回格式为 	 [N,N-1....1]的列表的函数，比如reverse_create_list(4) 返回[4,3，2，1]

%%recursion
reverse_create_list(N)-> reverse_create_list(N,1).
reverse_create_list(M,M) ->  [M];
reverse_create_list(N,M) -> [N | reverse_create_list(N-1, M)].
 
%%recursion_tail
reverse_create_list_acc(N) ->   reverse_create_list_acc(N, 1, []).
reverse_create_list_acc(N,N,Acc) ->  [N|Acc];
reverse_create_list_acc(N,M,Acc) -> reverse_create_list_acc(N, M+1, [M|Acc]).

%%% Exercise 4, 编写一个打印出1到N的整数的函数

%%recursion
print_integer(N) when N > 1->
    print_integer(N-1),
	io:format("Number: ~p~n", [N]);
print_integer(1)->
    io:format("Number: ~p~n", [1]).
	
%%recursion_tail
print_integer_acc(N)->
     print_integer_acc(1, N).
print_integer_acc(M, N) when N > M->
    io:format("Number: ~p~n", [M]),
	print_integer_acc(M+1, N);
	
print_integer_acc(N, N)->
    io:format("Number: ~p~n", [N]).

%%% Exercise 5, 编写一个打印出1到N的偶数的函数

%%recursion
print_even(N) when N >= 2->
    case N rem 2 of
        1->print_even(N-1);
	    0->print_even(N-1),
		   io:format("Number: ~p~n", [N])
		   
	end;

print_even(_)->
    ok.

%%recursion_tail
print_even_acc(N)->
    print_even_acc(2,N).
	
print_even_acc(N,N)->
    case N rem 2 of
        1->ok;
	    0->io:format("Number: ~p~n", [N])
    end;
print_even_acc(M, N) when N >= 2->
    case M rem 2 of
        1->print_even_acc(M+1,N);
	    0->io:format("Number: ~p~n", [M]),
		   print_even_acc(M+1,N)
	end.

	
%%%Exercise 6, 编写一个用列表做成的数据库,可以查询，写入，删除. 写入的数据是tuple with tag,tag作为key.

%%recursion
create_db()->
    [].
write_db(Data, Db)->
    Result = query_db(element(1,Data), Db),
	case Result of
	    {ok, {empty}}->
		    [Data | Db];
         _ ->
		     {ok, {existing}}
	end.
	
query_db(_, [])->
    {ok, {empty}};	
query_db(Key, [Head|Tail])->
    case element(1, Head) of
	     Key ->
		     {ok, Head};
	      _->
	         query_db(Key, Tail)
	end.

delete_db(Key,Db)->
    delete_db(Key, Db, []).
	
delete_db(_, [],_)->
     {ok, {unfound}};
delete_db(Key, [Head|Tail], NewDb)->
    case element(1, Head) of
	    Key->
		     lists:append(NewDb, Tail);
	    _->
		     delete_db(Key, Tail,  lists:append(NewDb, [Head]))
     end.			 
    
                        

%%%Exercise 7, 编写一个函数，给定一个整数和一个整数列表，并且返回所有小于或者等于该整数的整数.						

%%recursion
filter(Integer_list, Filter)->
    filter(Integer_list, Filter, []).
	
filter([], _, Filter_list)->
    Filter_list;	
	
filter([Head|Tail], Filter, Filter_list)  when Head =< Filter  ->
                                              filter(Tail, Filter, lists:append(Filter_list, [Head]));
filter([_|Tail], Filter, Filter_list)->
     filter(Tail, Filter, Filter_list).
    
%%recursion without using BIF
filter1(Integer_list, Filter)->
    filter1(Integer_list, Filter, []).
	
filter1([], _, Filter_list)->
    reverse_acc(Filter_list);	
	
filter1([Head|Tail], Filter, Filter_list)  when Head =< Filter  ->
                                              filter1(Tail, Filter, [Head|Filter_list]);
filter1([_|Tail], Filter, Filter_list)->
     filter1(Tail, Filter, Filter_list).   
   
%%%Exercise 8, 编写一个函数，给定一个列表，颠倒其中元素的顺序进行排列    

%%recursion
reverse([])->
     [];
reverse([Head|Tail])->
    lists:append(reverse(Tail), [Head]). 

%%recursion_tail (without using BIF)
reverse_acc(List)->
    reverse_acc(List, []).

reverse_acc([], Acc)->
    Acc;	
reverse_acc([Head|Tail], Acc)->
    reverse_acc(Tail, [Head | Acc]).
	
%%%Exercise 9, 编写一个函数，给定一个列表的列表，将它们连接起来.

%%recursion
concat([[Head|Tail1]|Tail2])->
    [Head | concat([Tail1|Tail2])];
concat([[]|Tail])->
    concat(Tail);
concat([])->
    [].	

%%recursion_tail
concat_acc(List)->
    concat_acc(List, []).
	
concat_acc([[Head|Tail1]|Tail2], Acc)->
    concat_acc([Tail1|Tail2], [Head|Acc]);
concat_acc([[]|Tail], Acc)->
    concat_acc(Tail, Acc);	
concat_acc([], Acc)->
    reverse(Acc).		
	
%%%Exercise 10, 编写一个函数，给定一个嵌套列表的列表，返回一个拉平的列表  

%%recursion
%% Lift nested lists to the front of the list.
flatten([[H|T1]|T2]) -> flatten([H,T1|T2]);
flatten([[]|T]) -> flatten(T);
flatten([E|T]) -> [E|flatten(T)];
flatten([]) -> [].	

%%%Exercise 11, 编写一个函数，对列表实现快速排序
%%recursion

filter_left(List, Filter)->
    filter_left(List, Filter, []).
	
filter_left([], _, Filter_list)->
    Filter_list;	
	
filter_left([Head|Tail], Filter, Filter_list)  when Head =< Filter  ->
                                              filter_left(Tail, Filter, lists:append(Filter_list, [Head]));
filter_left([_|Tail], Filter, Filter_list)->
     filter_left(Tail, Filter, Filter_list).
	 
filter_right(List, Filter)->
    filter_right(List, Filter, []).
	
filter_right([], _, Filter_list)->
    Filter_list;	
	
filter_right([Head|Tail], Filter, Filter_list)  when Head > Filter  ->
                                              filter_right(Tail, Filter, lists:append(Filter_list, [Head]));
filter_right([_|Tail], Filter, Filter_list)->
     filter_right(Tail, Filter, Filter_list).	 

quick_sort([])->
    [];
quick_sort([Head|[]])->
    [Head];	 
quick_sort([Head|Tail])->
    quick_sort(filter_left(Tail, Head))++[Head]++quick_sort(filter_right(Tail,Head)).

%%%Exercise 11, 编写一个函数，对列表实现合并排序

merge(List1, List2)->
    merge(List1, List2, []).

merge([], List2, Acc)->
    reverse(Acc) ++ List2;
merge(List1, [], Acc)->
    reverse(Acc) ++ List1;	
merge([Head1|Tail1], [Head2|Tail2], Acc)->
    if  Head1 < Head2 ->merge(Tail1, [Head2|Tail2], [Head1|Acc]);
	    true          ->merge([Head1|Tail1], Tail2, [Head2|Acc])                 
    end.
	     
length_of_list(List)->
    length_of_list(List, 0).
    
length_of_list([], Length)->
    Length;
length_of_list([_|Tail], Length)->
    length_of_list(Tail, Length+1).

half_list(List, Direction)->
    Half = length_of_list(List) div 2,
    half_list(List, Direction, [], Half).

half_list([],_, _, _)->
    [];	
half_list([Head|Tail], Direction, LeftList, Half)->
    if Half > 0 ->
	       half_list(Tail, Direction, [Head|LeftList], Half-1);
       true      ->
	       case Direction of
		       left->
			       reverse(LeftList);
			   right->
			       [Head|Tail]
		    end
     end.				   

merge_sort([])->
    [];
merge_sort([Head|[]])->
    [Head];
merge_sort(List)->
    merge(merge_sort(half_list(List, left)), merge_sort(half_list(List, right))).
