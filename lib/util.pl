:- module(util, [pair_route/4, pair_trade/4]).
?-use_module(dynamics).

contains(Pair, List):-
	(A,B) = Pair,
	member((B,A), List);
	member(Pair, List).

contains(pair_trade(A,B, _, _), List):-
	member(pair_trade(B,A, _, _), List);
	member(pair_trade(A,B, _, _), List).

contains(pair_route(A, B, _, _), List):-
	member(pair_route(B, A, _, _), List);
	member(pair_route(A, B, _, _), List).

contains(A, List):- member(A, List).
:- export(contains/2).

% removes duplicates from lists, checking with matching contains terms
% Thanks, StackOverflow!
% dedupe(-In, +Out).
dedupe([],[]).
dedupe([H|T],[H|Out]):-
	not(contains(H,T)),
	dedupe(T,Out).
dedupe([H|T],Out):-
	contains(H,T),
	dedupe(T,Out).
:- export(dedupe/2).

num_num_min(X, Y, Min) :- Min is min(X, Y).
list_min([L|Ls], Min) :- foldl(num_num_min, Ls, L, Min).
:- export(list_min/2).

num_num_max(X, Y, Max) :- Max is max(X, Y).
list_max([L|Ls], Max) :- foldl(num_num_max, Ls, L, Max).
:- export(list_max/2).

edge(A, B, L):- 
	sector(A, Adj), member(B, Adj), L is 1;
	sector(B, Adj), member(A, Adj), L is 1.
:- export(edge/3).

% True if two items are adjacent in a list.
% thanks again, StackOverflow!
% adjacent(-A, -B, -List).
adjacent(A, B, [A,B|_]).
adjacent(A, B, [_|Tail]) :-
    adjacent(A, B, Tail).
:- export(adjacent/3).

% borrowed from ... somewhere? sorry
writes([]):-!,nl.
writes([H|T]):-!,writes(H),writes(T).
writes((A,B)):-!,writes(A),write(',\\n'),writes(B).	% break up conjunctions
writes(:-A):-!,write(':-'),writes(A).
writes(?-A):-!,write('?-'),writes(A).
writes('$empty_list'):-!,write([]).
writes(A):-write(A).	% catch-all
:- export(writes/1).
