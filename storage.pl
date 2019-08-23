:- [dynamics].
:- [util].
:- use_module(library(csv)).

row_to_list(Row, List):-
	  Row =.. [row|List].

import_planets:-
	csv_read_file('data/planets.csv', Data, [skip_header('#'), functor(planet), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("Imported %w planets.\n", [Len]), 
	maplist(assert, Data).

import_ports:-
	csv_read_file('data/ports.csv', Data, [skip_header('#'), functor(port), row_arity(6), strip(true)]),
	length(Data, Len),
	writef("Imported %w ports.\n", [Len]), 
	maplist(assert, Data).

import_trades:-
	csv_read_file('data/trades.csv', Data, [skip_header('#'), functor(trade), row_arity(5), strip(true)]),
	length(Data, Len),
	writef("Imported %w trade records.\n", [Len]), 
	maplist(assert, Data).

parse_sector(Row):-
	row_to_list(Row, List),
	[H|T] = List,
	dedupe(T, Deduped),
	assert(sector(H, Deduped)).

import_sectors:-
	csv_read_file('data/sectors.csv', Data, [skip_header('#'), strip(true), match_arity(false)]),
	length(Data, Len),
	writef("Imported %w sector records.\n", [Len]), 
	maplist(parse_sector, Data).

parse_region(Row):-
	row_to_list(Row, List),
	[H|T] = List,
	dedupe(T, Deduped),
	assert(region(H, Deduped)).

import_regions:-
	csv_read_file('data/regions.csv', Data, [skip_header('#'), strip(true), match_arity(false)]),
	length(Data, Len),
	writef("Imported %w region records.\n", [Len]), 
	maplist(parse_region, Data).
