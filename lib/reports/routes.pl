% trade routes report
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

