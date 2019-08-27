% various sector list reports
?- use_module(library(list_util)).

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
