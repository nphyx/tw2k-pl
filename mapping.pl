:-[data].
:-[dijkstra].

writes([]):-!,nl.
writes([H|T]):-!,writes(H),writes(T).
writes((A,B)):-!,writes(A),write(',\\n'),writes(B).	% break up conjunctions
writes(:-A):-!,write(':-'),writes(A).
writes(?-A):-!,write('?-'),writes(A).
writes('$empty_list'):-!,write([]).
writes(A):-write(A).	% catch-all

buy_sell(T, S):-
	T = b, S = 'B';
	T = s, S = 'S'.

class_label(C, S):-
	C = unknown, S = '?';
	S = C.

sector_label(Id, S):-
	port(Id, Name, Class, F, O, E),
	buy_sell(F, Fs),
	buy_sell(O, Os),
	buy_sell(E, Es),
	class_label(Class, Cs),
	swritef(S, '%w\n%w\n%w%w%w\n(%w)', [Id, Name, Fs, Os, Es, Cs]);
	S = Id.

product_tag(Product, Tag):-
	Product = fuel, Tag = 'F';
	Product = equipment, Tag = 'E';
	Product = organics, Tag = 'O'.

is_pair_member(A, B, Pairs):-
	member(pair_trade(A, B, _, _), Pairs);
	member(pair_trade(B, A, _, _), Pairs).

line_type(P, Pairs, L):-
	P = (A, B),
	(
		is_pair_member(A, B, Pairs), Len = "0.5";
		not(mapped(A)), Len = "0.25";
		not(mapped(B)), Len = "0.25";
		Len = "1.0"
	),
	(
		is_pair_member(A, B, Pairs), Color = "#88bb88";
		(long_return(A,B)), Color = "#bb8888";
		(long_return(A,B)), Head = "#bb8888";
		Color = "#bbbbbb"
	),
	(
		is_pair_member(A, B, Pairs), Head = "diamond";
		not(mapped(B)), Head = "odot";
		not(mapped(A)), Head = "none";
		(unidirectional(A, B), link_from_to(A, B)), Head = "curve";
		(unidirectional(A, B), link_from_to(B, A)), Head = "icurve";
		Head = "none"
	),
	(
		is_pair_member(A, B, Pairs), Tail = "diamond";
		not(mapped(A)), Tail = "odot";
		not(mapped(B)), Tail = "none";
		(unidirectional(A, B), link_from_to(A, B)), Tail = "icurve";
		(unidirectional(A, B), link_from_to(B, A)), Tail = "curve";
		Tail = "none"
	),
	(
		member(pair_trade(A, B, Pa, Pb), Pairs),
		product_tag(Pa, Ta),
		product_tag(Pb, Tb),
		swritef(Label, "%w : %w", [Ta, Tb]);
		member(pair_trade(B, A, Pa, Pb), Pairs),
		product_tag(Pa, Ta),
		product_tag(Pb, Tb),
		swritef(Label, "%w : %w", [Ta, Tb]);
		Label = ''
	),
	(
		not(mapped(A)), Style = "dotted";
		not(mapped(B)), Style = "dotted";
		unidirectional(A, B), Style = "dashed";
		is_pair_member(A, B, Pairs), Style = "bold";
		Style = "solid"
	),
	(
		swritef(L,
			'[len="%w" label="%w" dir="both" arrowhead="%w" arrowtail="%w" style="%w" color="%w"]',
			[Len, Label, Head, Tail, Style, Color]
		)
	).

writes_edge(E, Pairs):-
	line_type(E, Pairs, L),
	E = (A,B),
	writes(['"', A, '" -> "', B, '"', L, ';']).

sector_color(Id, Pairs, C):-
	(not(mapped(Id)), C = "#111111");
	(pocket(Id), C = "#337777");
	(maybe_pocket(Id), C = "#115555");
	(isolated(Id), C = '#773333');
	(is_pair_member(Id, _, Pairs), (
		port_class_gt(Id, 3), C = "#337733";
		C = "#115511"
	));
	(Id = 1, C = '#aa9955');
	(port(Id, _, 0, _, _, _), C = '#556655');
	(port(Id, _, 9, _, _, _), C = '#555566');
	(Id < 11, C = '#441144');
	(planet(Id, _, _, _, Owner), not(Owner = unknown), C = '#333377');
	C = '#222222'.

sector_shape(Id, S):-
	(Id = 1, S = 'tripleoctagon');
	(port(Id, _, 0, _, _, _), S = 'doubleoctagon');
	(port(Id, _, 9, _, _, _), S = 'octagon');
	(has_port(Id), planet(Id, _, _, _, Owner), not(Owner = unknown), S = 'invhouse');
	(planet(Id, _, _, _, Owner), not(Owner = unknown), S = 'house');
	(has_port(Id), S = 'Mdiamond');
	(not(mapped(Id)), S = 'plaintext');
	S = 'circle'.

font(Id, F):-
	(not(mapped(Id)), F = 'Fira Sans Bold');
	(is_empty(Id), F = 'Fira Sans Bold');
	F = 'Fira Sans'.

font_size(Id, S):-
	not(mapped(Id)), S = '8';
	is_empty(Id), S = '10';
	S = '12'.

sector_style(Id, Style):-
	hub(Id), Style = 'filled, bold';
	Style = 'filled'.

writes_style(Id, Pairs, WithLabel):-
	sector_color(Id, Pairs, Color),
	(WithLabel, sector_label(Id, Label); Label = "(secret)"),
	sector_shape(Id, Shape),
	sector_style(Id, Style),
	font(Id, Font),
	font_size(Id, Size),
	swritef(S,
		'%w [shape="%w" label="%w" fillcolor="%w" fontname="%w" fontsize="%w" style="%w"]',
		[Id, Shape, Label, Color, Font, Size, Style]),
	writes(S).

map_sectors_main(WithLabel):- 
	findall((A,B), connected(A, B), Edges),
	sort(Edges, SortEdge),
	dedupe(SortEdge, Deduped),
	findall((A), has_connect(A), Connected),
	trade_pairs(Pairs),
	sort(Connected, SortConn),
	tell('maps/sectors.dot'),
	writes(['digraph {']),
	writes(['graph [overlap=false splines=true bgcolor="#111111" pack=200 packmode="node"]']),
	writes(['node [shape=circle fontcolor="#ffffff" fontsize=10 style=filled
	color="#eeeeee" margin="-0.5,-0.5" regular=true];']),
	writes(['edge [color="#bbbbbb" fontsize=10 fontname="Fira Sans Bold" fontcolor="#88ee88"];']),
	forall(member(Id, SortConn), writes_style(Id, Pairs, WithLabel)),
	forall(member(E, Deduped), writes_edge(E, Pairs)),
	writes(['}']),
	told.

map_sectors:- map_sectors_main(true).

map_sectors_hidden:- map_sectors_main(false).
