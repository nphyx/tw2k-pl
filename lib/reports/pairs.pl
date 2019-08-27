% trade pairs report
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
