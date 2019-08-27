:- module(storage, []).
?- use_module(dynamics).
?- use_module(util).
:- use_module(library(csv)).

row_to_list(Row, List):-
	  Row =.. [row|List].

import_planets(DataDir):-
	swritef(Dir, '%w/planets.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(planet), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("::: %w planets", [Len]), 
	maplist(assert, Data).

import_ports(DataDir):-
	swritef(Dir, '%w/ports.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(port), row_arity(6), strip(true)]),
	length(Data, Len),
	writef("::: %w ports ", [Len]), 
	maplist(assert, Data).

import_trades(DataDir):-
	swritef(Dir, '%w/trades.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(trade), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("::: %w trades ", [Len]), 
	maplist(assert, Data).

parse_sector(Row):-
	row_to_list(Row, List),
	[H|T] = List,
	dedupe(T, Deduped),
	assert(sector(H, Deduped)).

import_sectors(DataDir):-
	swritef(Dir, '%w/sectors.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), strip(true), match_arity(false)]),
	length(Data, Len),
	writef("::: %w sectors ", [Len]), 
	maplist(parse_sector, Data).

parse_region(Row):-
	row_to_list(Row, List),
	[H|T] = List,
	dedupe(T, Deduped),
	assert(region(H, Deduped)).

import_regions(DataDir):-
	swritef(Dir, '%w/regions.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), strip(true), match_arity(false)]),
	length(Data, Len),
	writef("::: %w regions ", [Len]), 
	maplist(parse_region, Data).

import_db(DataDir):-
	format('Importing Data  '),
	import_trades(DataDir),
	import_planets(DataDir),
	import_sectors(DataDir),
	import_ports(DataDir),
	import_regions(DataDir),
	writef("::: Done\n").
:- export(import_db/1).

import_db:- import_db('data').
:- export(import_db/0).
