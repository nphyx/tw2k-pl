:- [dynamics].
:- [util].
:- use_module(library(csv)).

row_to_list(Row, List):-
	  Row =.. [row|List].

import_planets(DataDir):-
	swritef(Dir, '%w/planets.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(planet), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("Imported %w planets.\n", [Len]), 
	maplist(assert, Data).

import_ports(DataDir):-
	swritef(Dir, '%w/ports.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(port), row_arity(6), strip(true)]),
	length(Data, Len),
	writef("Imported %w ports.\n", [Len]), 
	maplist(assert, Data).

import_trades(DataDir):-
	swritef(Dir, '%w/trades.csv', [DataDir]),
	csv_read_file(Dir, Data, [skip_header('#'), functor(trade), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("Imported %w trade records.\n", [Len]), 
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
	writef("Imported %w sector records.\n", [Len]), 
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
	writef("Imported %w region records.\n", [Len]), 
	maplist(parse_region, Data).

import_db(DataDir):-
	format('Importing data from ./~w:~n', [DataDir]),
	import_trades(DataDir),
	import_planets(DataDir),
	import_sectors(DataDir),
	import_ports(DataDir),
	import_regions(DataDir).

import_db:- import_db('data').

