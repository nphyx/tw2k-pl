% reports
:-module(reports, [print_routes/1, print_routes/2, print_mapped/0, print_unmapped/0, print_boundary/0, print_unknown/0, print_pairs/0, print_trans_routes/1]).
?-use_module('../data').
:- [routes].
:- [trans].
:- [pairs].
:- [sectors].
