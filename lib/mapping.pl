:-[data].
:-[dijkstra].

writes([]):-!,nl.
writes([H|T]):-!,writes(H),writes(T).
writes((A,B)):-!,writes(A),write(',\\n'),writes(B).	% break up conjunctions
writes(:-A):-!,write(':-'),writes(A).
writes(?-A):-!,write('?-'),writes(A).
writes('$empty_list'):-!,write([]).
writes(A):-write(A).	% catch-all

region_color(RegionName, Color):-
	RegionName = 'uncharted space', Color = "#662299";
	RegionName = 'The Ferrengi Empire', Color = "#ff2222";
	RegionName = 'The Federation', Color = "#fff688";
	findall(Region, region(Region, _), Regions),
	nth1(Index, Regions, RegionName),
	(
		0 is Index mod 8, Color = "#ffcccc";
		1 is Index mod 8, Color = "#ccffcc";
		2 is Index mod 8, Color = "#ccccff";
		3 is Index mod 8, Color = "#ffffcc";
		4 is Index mod 8, Color = "#ccffff";
		5 is Index mod 8, Color = "#ffccff";
		6 is Index mod 8, Color = "#cccccc";
		7 is Index mod 8, Color = "#ffffff"
	).

region_bg(RegionName, Color):-
	RegionName = 'uncharted space', Color = "#181026";
	RegionName = 'The Ferrengi Empire', Color = "#661111";
	RegionName = 'The Federation', Color = "#443e11";
	findall(Region, region(Region, _), Regions),
	nth1(Index, Regions, RegionName),
	(
		0 is Index mod 8, Color = "#331111";
		1 is Index mod 8, Color = "#113311";
		2 is Index mod 8, Color = "#111133";
		3 is Index mod 8, Color = "#333311";
		4 is Index mod 8, Color = "#113333";
		5 is Index mod 8, Color = "#331133";
		6 is Index mod 8, Color = "#111111";
		7 is Index mod 8, Color = "#333333"
	).

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

line_type(P, Pairs, Lanes, L):-
	P = (A, B),
	TradePair = is_pair_member(A, B, Pairs),
	SpaceLane = on_any_path(A, B, Lanes),
	UnchartedA = not(mapped(A)),
	UnchartedB = not(mapped(B)),
	Unidirectional = unidirectional(A, B),
	SameRegion = (region_of(A, Region), region_of(B, Region), not(Region = unknown), not(Region = 'uncharted space')),
	Nearby = (abs((A - B)) < 10),
	( % preferred line lengths, inches
		(UnchartedA; UnchartedB), Len = "0.25";
		SameRegion, Len = "0.5";
		(SpaceLane; TradePair), Len = "5.0";
		Unidirectional, Len = "30.0";
		Nearby, Len = "3.0";
		Len = "10.0"
	),
	( % weight, how strongly we want to emphasize length preference
		SameRegion, Weight = "100";
		(UnchartedA; UnchartedB), Weight = "9"; % cluster uncharted sectors very near
		SpaceLane, Weight = "3";
		TradePair, Weight = "2";
		Unidirectional, Weight = "3";
	  Nearby, Weight = "4"; % tend to cluster sectors with similar numbers together
		Weight = "2"
	),
	(
		TradePair, Color = "#88bb88";
		SpaceLane, Color = "#8888bb";
		(long_return(A,B)), Color = "#bb8888";
		(long_return(A,B)), Head = "#bb8888";
		region_of(A, Region), region_color(Region, Color);
		Color = "#aaaaaa"
	),
	(
		TradePair, Head = "diamond";
		UnchartedB, Head = "odot";
		UnchartedA, Head = "none";
		(Unidirectional, link_from_to(A, B)), Head = "curve";
		(Unidirectional, link_from_to(B, A)), Head = "icurve";
		Head = "none"
	),
	(
		TradePair, Tail = "diamond";
		UnchartedA, Tail = "odot";
		UnchartedB, Tail = "none";
		(Unidirectional, link_from_to(A, B)), Tail = "icurve";
		(Unidirectional, link_from_to(B, A)), Tail = "curve";
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
		(UnchartedA; UnchartedB), Style = "dotted";
		Unidirectional, Style = "dashed";
		Style = "solid"
	),
	(
		SpaceLane, Pen = "3";
		TradePair, Pen = "2";
		Pen = "1"
	),
	(
		swritef(L,
			'[len="%w" label="%w" dir="both" arrowhead="%w" arrowtail="%w" style="%w" color="%w" penwidth="%w" weight="%w"]',
			[Len, Label, Head, Tail, Style, Color, Pen, Weight]
		)
	).

writes_edge(E, Pairs, Lanes):-
	line_type(E, Pairs, Lanes, L),
	E = (A,B),
	writes(['"', A, '" -> "', B, '"', L, ';\n']).

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
	(planet(Id, _, _, _, Owner), not(Owner = unknown), C = '#333377');
	C = '#222222'.

sector_color_by_region(Id, C):-
	(not(mapped(Id)), C = "#111111");
	region_of(Id, Region), region_bg(Region, C);
	C = '#222222'.

sector_border(Id, C):-
	region_of(Id, Region),
	region_color(Region, C);
	C = "#aaaaaa".

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

writes_style(Id, Pairs, WithLabel, ColorMode):-
	(
		ColorMode = normal, sector_color(Id, Pairs, Color);
		ColorMode = regions, sector_color_by_region(Id, Color)
	),
	(WithLabel, sector_label(Id, Label); Label = "(secret)"),
	sector_shape(Id, Shape),
	sector_style(Id, Style),
	sector_border(Id, Border),
	font(Id, Font),
	font_size(Id, Size),
	swritef(S,
		'%w [shape="%w" label="%w" fillcolor="%w" fontname="%w" fontsize="%w" style="%w" color="%w"]\n',
		[Id, Shape, Label, Color, Font, Size, Style, Border]),
	writes(S).

map_sectors(FName, WithLabels, ColorMode):- 
	findall((A,B), connected(A, B), Edges),
	sort(Edges, SortEdge),
	dedupe(SortEdge, Deduped),
	findall((A), has_connect(A), Connected),
	trade_pairs(Pairs),
	space_lanes(Lanes),
	sort(Connected, SortConn),
	tell(FName),
	writes(['digraph {']),
	writes(['graph [overlap=false fontname="Fira Sans Bold" splines=true bgcolor="#111111" pack=200 packmode="node"]']),
	writes(['node [shape=circle fontname="Fira Sans Bold" fontcolor="#ffffff" fontsize=10 style=filled
	color="#eeeeee" margin="-0.5,-0.5" regular=true];']),
	writes(['edge [color="#bbbbbb" fontsize=10 fontname="Fira Sans Bold" fontcolor="#88ee88"];']),
	forall(member(Id, SortConn), writes_style(Id, Pairs, WithLabels, ColorMode)),
	forall(member(E, Deduped), writes_edge(E, Pairs, Lanes)),
	writes(['}']),
	told.

map_sectors(Fname, WithLabels):- map_sectors(Fname, WithLabels, normal).

map_sectors(FName):- map_sectors(FName, true, normal).

map_sectors_hidden(FName):- map_sectors(FName, false, regions).
