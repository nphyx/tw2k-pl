% trans-warp routes report

print_trans_foot():- writef('=======================================================================\n').

print_trans_head(Holds):-
	writef('\nTrans-Warp Routes (%w holds)\n', [Holds]),
	print_trans_foot(),
	format(
		'| ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~w~4+~t~| - ~|~w~11+~t~| | ~|~w~7+~t~| | ~|~w~7+~t~| | ~|~w~5+~t~| |\n',
		['A', 'ProductA', 'B', 'ProductB', 'Profit', 'PerTurn', 'Fuel']
	),
	writef('|--------------------|--------------------|---------|---------|-------|\n').

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

