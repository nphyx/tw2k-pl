% reports
?- use_module(library(list_util)).
:- [data].

print_route_row(R, Holds):- 
	route(A, ProductA, B, ProductB, ProfitUnit, RoundTrip, ProfitPerWarpUnit, Turns, ProfitPerTurnUnit) = R,
	Profit is ProfitUnit * Holds,
	ProfitPerTurn is ProfitPerTurnUnit * Holds,
	ProfitPerWarp is ProfitPerWarpUnit * Holds,
	format(
		'| ~|~w~3+~t~| - ~|~w~9+~t~| | ~|~w~3+~t~| - ~|~w~9+~t~| | ~|~1f~6+~t~| | ~|~w~3+~t~| | ~|~1f~6+~t~| | ~|~w~3+~t~| | ~|~1f~6+~t~| |\n',
		[A, ProductA, B, ProductB, Profit, RoundTrip, ProfitPerWarp, Turns, ProfitPerTurn]
	).

print_route_foot():- writef('============================================================================\n').

print_route_head(Holds):-
	writef('\nKnown Trade Routes (%w holds)\n', [Holds]),
	print_route_foot(),
	format(
		'| ~|~w~3+~t~| - ~|~w~9+~t~| | ~|~w~3+~t~| - ~|~w~9+~t~| | ~|~w~6+~t~| | ~|~w~3+~t~| | ~|~w~6+~t~| | ~|~w~3+~t~| | ~|~w~6+~t~| |\n',
		['A', 'ProductA', 'B', 'ProductB', 'Profit', 'Wrp', 'PerWrp', 'Trn', 'PerTrn']
	),
	writef('|-----------------|-----------------|--------|-----|--------|-----|--------|\n').

% prints all routes between two ports with paired buys/sells, sorted by profit per turn,
% profit multiplied by Holds.
% print_routes(+Holds, +TPW).
print_routes(Holds, TPW):-
	trade_routes_sorted(TPW, Sorted),
	print_route_head(Holds),
	forall(member(P, Sorted), print_route_row(P, Holds)),
	print_route_foot().

print_routes(Holds):- print_routes(Holds, 2).

% prints all routes between two ports with paired buys/sells, sorted by profit per warp.
% print_routes().
print_routes():- print_routes(1).

print_trans_foot():- writef('=======================================================================\n').

print_trans_head(Holds):-
	writef('\nTrans-Warp Routes (%w holds)\n', [Holds]),
	print_trans_foot(),
	format(
		'| ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~w~7+~t~| | ~|~w~7+~t~| | ~|~w~5+~t~| |\n',
		['A', 'ProductA', 'B', 'ProductB', 'Profit', 'PerTurn', 'Fuel']
	),
	writef('|--------------------+--------------------+---------+---------+-------+\n').

print_trans_row(R):- 
	troute(A, ProductA, B, ProductB, Profit, ProfitPerTurn, Fuel) = R,
	format(
		'| ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~1f~7+~t~| | ~|~1f~7+~t~| | ~|~w~5+~t~| |\n',
		[A, ProductA, B, ProductB, Profit, ProfitPerTurn, Fuel]
	).

% prints trade routes using transwarp jumps, computed by number of holds.
% print_trans_routes(+Holds).
print_trans_routes(Holds):-
	trans_routes_sorted(Holds, Sorted),
	print_trans_head(Holds),
	forall(member(P, Sorted), print_trans_row(P)),
	print_trans_foot().

pair_row_fmt(F):- F = '| ~|~w~5+~t~| | ~|~w~5+~t~| | ~|~w~11+~t~| | ~|~w~11+~t~| |\n'.

print_pairs_row(R):- 
	R = pair_trade(A, B, ProductA, ProductB),
	pair_row_fmt(F),
	format(F, [A, B, ProductA, ProductB]).

print_pairs_head():-
	pair_row_fmt(F),
	writef('\nKnown Trade Pairs\n'),
	print_pairs_foot(),
	format(F, ['A', 'B', 'ProductA', 'ProductB']),
	writef('|-------|-------|-------------|-------------|\n').

print_pairs_foot():-
	writef('=============================================\n').

% prints all trade pairs, which are adjacent sectors with ports that have matching
% buy/sells.
% print_pairs().
print_pairs():-
	trade_pairs(Pairs),
	print_pairs_head(),
	forall(member(P, Pairs), print_pairs_row(P)),
	print_pairs_foot().

pad_list([], []).
pad_list(List, Size, Padding, Out):-
	length(List, Len),
	Len >= Size -> Out = List;
	flatten([List, [Padding]], Next), pad_list(Next, Size, Padding, Out).

print_sector_row([]).
print_sector_row([H|T]):-
	format('~| ~w~6+~t ~||', [H]),
	print_sector_row(T).

print_sector_separator(0):- writef('\n').
print_sector_separator(N):-
	N > 0,
	writef('-------|'),
	Next is N - 1,
	print_sector_separator(Next).

print_sector_rows([]).
print_sector_rows(List):-
	writef('|'),
	take(9, List, Head),
	pad_list(Head, 9, ' ', Padded),
	print_sector_row(Padded),
	writef('\n'),
	drop(9, List, Tail),
	print_sector_rows(Tail).

print_mapped():-
	mapped_sectors(List),
	length(List, Len),
	writef('\nMapped Sectors (%w)\n', [Len]),
	writef('|'),
	print_sector_separator(9),
	print_sector_rows(List),
	writef('|'),
	print_sector_separator(9).

print_unmapped():-
	unmapped_sectors(List),
	length(List, Len),
	writef('\nUnmapped Sectors (%w)\n', [Len]),
	Len > 0,
	writef('|'),
	print_sector_separator(9),
	print_sector_rows(List),
	writef('|'),
	print_sector_separator(9).

% print sectors which are known to link to existing sectors, but unmapped
% print_boundary().
print_boundary():-
	mapped_sectors(Mapped),
	all_known_sectors(Known),
	subtract(Known, Mapped, Borders),
	length(Borders, Len),
	writef('\nBoundary Sectors (%w)\n', [Len]),
	Len > 0,
	writes('|'),
	print_sector_separator(9),
	print_sector_rows(Borders),
	writes('|'),
	print_sector_separator(9).

% print sectors which are completely unknown
% print_boundary().
print_unknown():-
	all_known_sectors(Known),
	all_sectors(All),
	subtract(All, Known, List),
	length(List, Len),
	writef('\nUnknown Sectors (%w)\n', [Len]),
	Len > 0,
	writes('|'),
	print_sector_separator(9),
	print_sector_rows(List),
	writes('|'),
	print_sector_separator(9).
