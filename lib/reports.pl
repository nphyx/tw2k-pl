:- [data].

print_route_row(R, Holds):- 
	R = route(A, ProductA, B, ProductB, ProfitUnit, RoundTrip, ProfitPerHopUnit),
	Profit is ProfitUnit * Holds,
	ProfitPerHop is ProfitPerHopUnit * Holds,
	ProfitPerHop >= 0,
	%           PortA         ProductA       PortB          ProductB       Profit           RT             PPH
	format('| ~|~w~5+~t~| - ~|~w~11+~t~| | ~|~w~5+~t~| - ~|~w~11+~t~| | ~|~1f~7+~t~| | ~|~w~5+~t~| | ~|~1f~7+~t~| |\n', [A, ProductA, B, ProductB, Profit, RoundTrip, ProfitPerHop]).

print_route_foot():- writef('=========================================================================\n').

print_route_head(Holds):-
	writef('\nKnown Trade Routes (%w holds)\n', [Holds]),
	print_route_foot(),
	format('| ~|~w~5+~t~| - ~|~w~11+~t~| | ~|~w~5+~t~| - ~|~w~11+~t~| | ~|~w~7+~t~| | ~|~w~5+~t~| | ~|~w~7+~t~| |\n', ['A', 'ProductA', 'B', 'ProductB', 'Profit', 'Hops', 'PerHop']),
	writef('|---------------------+---------------------+---------+-------+---------|\n').

% prints all routes between two ports with paired buys/sells, sorted by profit per hop,
% profit multiplied by Holds.
% print_routes(-Holds).
print_routes(Holds):-
	sorted_trade_routes(Sorted),
	print_route_head(Holds),
	(forall(member(P, Sorted), print_route_row(P, Holds)); true),
	print_route_foot().

% prints all routes between two ports with paired buys/sells, sorted by profit per hop.
% print_routes().
print_routes():- print_routes(1).

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
