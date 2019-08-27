:-[data].
:-[dijkstra].

writes([]):-!,nl.
writes([H|T]):-!,writes(H),writes(T).
writes((A,B)):-!,writes(A),write(',\\n'),writes(B).	% break up conjunctions
writes(:-A):-!,write(':-'),writes(A).
writes(?-A):-!,write('?-'),writes(A).
writes('$empty_list'):-!,write([]).
writes(A):-write(A).	% catch-all

region_color(RegionName, Color):- RegionName = 'uncharted space' -> Color = "#662299".
region_color(RegionName, Color):- RegionName = 'The Ferrengi Empire' -> Color = "#ff2222".
region_color(RegionName, Color):- RegionName = 'The Federation' -> Color = "#fff688".
region_color(RegionName, Color):- RegionName = unknown -> Color = "#cccccc".
region_color(RegionName, Color):-
	not(member(RegionName, ['uncharted space', 'The Ferrengi Empire', 'The Federation', unknown])),
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
	swritef(S, '%w\\\\n%w\\\\n%w%w%w\\\\n(%w)', [Id, Name, Fs, Os, Es, Cs]);
	S = Id.

product_tag(Product, Tag):-
	Product = fuel, Tag = 'F';
	Product = equipment, Tag = 'E';
	Product = organics, Tag = 'O'.

writes_joined([]).
writes_joined([H]):- writef(" %w ", [H]).
writes_joined([H|T]):- writef(" %w", [H]), writes_joined(T).

writes_edge_links(_, []).
writes_edge_links(SectorId, [SingleDest]):- writef("%w -> %w ", [SectorId, SingleDest]).
writes_edge_links(SectorId, Destinations):-
	length(Destinations, L), L > 1,
	writef("%w -> {", [SectorId]), writes_joined(Destinations), writef('} ').

writes_paired_edges(_, []).
writes_paired_edges(SectorId, Destinations):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="2.0" dir="both" arrowhead="diamond" arrowtail="diamond" style="dashed" color="#88bb88" penwidth="2" weight="3" tooltip="trade pair"];\n').

writes_uncharted_edges(_, [], _).
writes_uncharted_edges(SectorId, Destinations, Color):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="0.15" label="" dir="both" arrowhead="odot" arrowtail="none" style="dotted" color="%w" penwidth="1" weight="10" tooltip="uncharted"];\n', [Color]).

writes_space_lane_edges(_, [], _).
writes_space_lane_edges(SectorId, Destinations, Color):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="2.0" label="" dir="both" arrowhead="none" arrowtail="none" style="solid" color="#8888bb" penwidth="3" weight="3" tooltip="space lane"];\n', [Color]).

writes_unidirectional_edges(_, [], _).
writes_unidirectional_edges(SectorId, Destinations, Color):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="5.0" label="" dir="both" arrowhead="curve" arrowtail="icurve" style="dashed" color="%w" penwidth="1" weight="3" tooltip="one way"];\n', [Color]).

writes_unidirectional_lane_edges(_, [], _).
writes_unidirectional_lane_edges(SectorId, Destinations, Color):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="5.0" label="" dir="both" arrowhead="curve" arrowtail="icurve" style="dashed,bold" color="%w" penwidth="3" weight="3" tooltip="one way space lane"];\n', [Color]).


writes_normal_edges(_, [], _).
writes_normal_edges(SectorId, Destinations, Color):-
	writes_edge_links(SectorId, Destinations),
	writef('[len="3.0" label="" dir="both" arrowhead="none" arrowtail="none" style="solid" color="%w" penwidth="1" weight="2" tooltip="bidirectional link"];\n', [Color]).

in_lane_list(Source, Dest, Lanes):- member(Lane, Lanes), on_path(Source, Dest, Lane).

not_member(A, List):- not(member(A, List)).

is_pair_member(A, B, Pairs):-
	not(A = B),
	(
		member(pair_trade(A, B, _, _), Pairs);
		member(pair_trade(B, A, _, _), Pairs)
	).

writes_sector_edges(SectorId, Lanes):-
	uncharted(SectorId) -> true;
	sector(SectorId, Links),
	region_of(SectorId, Region), region_color(Region, Color),

	findall(Uc, (member(Uc, Links), uncharted(Uc)), UcList), % set of uncharted links
	findall(PDest, is_pair(SectorId, PDest), PList), % trade pair links
	findall(LDest, in_lane_list(SectorId, LDest, Lanes), SLList), % set of space lane links
	findall(UDest, unidirectional(SectorId, UDest), UDList), % set of unidirectional links
	findall(ICUni, unidirectional(ICUni, SectorId), ICUniList), % incoming unidirectional links
	intersection(SLList, UDList, UnidirectionalLanes),
	flatten([UnidirectionalLanes, ICUniList, PList], SpecialSLs), % space lanes with special properties
	subtract(SLList, SpecialSLs, NormalSLs), % normal space lanes
	subtract(UDList, UnidirectionalLanes, UDNonLanes), % unidirectional links that aren't lanes
	flatten([UDList, SLList, PList, UcList], Specials), % edges with any special attribute
	subtract(Links, Specials, NormalList), % edges with no special attributes
	subtract(PList, UcList, ChartedPairs), % prevent uncharted trade pairs
	exclude(>(SectorId), NormalList, Normals), % prevent double lines
	exclude(>(SectorId), ChartedPairs, TradePairs), % prevent double lines
	exclude(>(SectorId), NormalSLs, SpaceLanes), % prevent double lines

	dedupe(UDNonLanes, UDSet),

	writes_uncharted_edges(SectorId, UcList, Color),
	writes_unidirectional_lane_edges(SectorId, UnidirectionalLanes, Color),
	writes_unidirectional_edges(SectorId, UDSet, Color),
	writes_space_lane_edges(SectorId, SpaceLanes, Color),
	writes_paired_edges(SectorId, TradePairs),
	writes_normal_edges(SectorId, Normals, Color).

% finds the background color for a sector in normal mode
sector_color(Id, C):-
	(not(mapped(Id)), C = "#111111");
	(pocket(Id), C = "#337777");
	(maybe_pocket(Id), C = "#115555");
	(isolated(Id), C = '#773333');
	(is_pair(Id, _), (
		port_class_gt(Id, 3), C = "#337733";
		C = "#115511"
	));
	(Id = 1, C = '#aa9955');
	(port(Id, _, 0, _, _, _), C = '#556655');
	(port(Id, _, 9, _, _, _), C = '#555566');
	(planet(Id, _, _, _, Owner), not(Owner = unknown), C = '#333377');
	C = '#222222'.

% finds the background color for a sector in regional mode
sector_color_by_region(Id, C):-
	(not(mapped(Id)), C = "#111111");
	region_of(Id, Region), region_bg(Region, C);
	C = '#222222'.

sector_border(Id, C):-
	region_of(Id, Region), region_color(Region, C);
	C = "#aaaaaa".

sector_style(Id, Style):-
	hub(Id), Style = 'filled, bold';
	Style = 'filled'.

writes_uncharted_sector(Id, WithLabel):-
	(WithLabel -> Label = Id; Label = ""),
	writef(
		'%w [shape=plaintext color="#111111" width="0.35" height="0.35" label="%w" tooltip="uncharted sector"];\n',
		[Id, Label]
	).

writes_special_sector(Id, Label, Color, FillColor, Style, Shape):-
	writef(
		'%w [width="1.25" height = "1.25" label="%w" color="%w" fillcolor="%w" style="%w" shape="%w" tooltip="special spaceport"];',
		[Id, Label, Color, FillColor, Style, Shape]
	).

writes_port_sector(Id, Label, Color, FillColor, Style):-
	writef(
		'%w [width="1.25" height = "1.25" label="%w" color="%w" fillcolor="%w" style="%w" shape="Mdiamond" tooltip="spaceport"];',
		[Id, Label, Color, FillColor, Style]
	).

writes_planet_sector(Id, Label, Color, FillColor, Style):-
	writef(
		'%w [width="0.5" height = "0.5" label="%w" color="%w" fillcolor="%w" style="%w" shape="doublecircle" tooltip="planetary sector"];',
		[Id, Label, Color, FillColor, Style]
	).

writes_empty_sector(Id, Label, Color, FillColor, Style):-
	writef(
		'%w [width="0.5" height = "0.5" label="%w" color="%w" fillcolor="%w" style="%w" shape="circle" tooltip="empty sector"];',
		[Id, Label, Color, FillColor, Style]
	).


writes_sector(Id, Lanes, WithLabel, ColorMode):-
	uncharted(Id) -> writes_uncharted_sector(Id, WithLabel);
	(
		ColorMode = normal, sector_color(Id, FillColor);
		ColorMode = regions, sector_color_by_region(Id, FillColor);
		Color = "#111111"
	),
	(WithLabel -> sector_label(Id, Label); Label = ""),
	(sector_border(Id, Color); Color = "#aaaaaa"),
	(sector_style(Id, Style); Style = "filled"),
	(
		Id = 1, writes_special_sector(Id, Label, Color, FillColor, Style, 'tripleoctagon');
		port_class(Id, 9) -> writes_special_sector(Id, Label, Color, FillColor, Style, 'doubleoctagon');
		port_class(Id, 0) -> writes_special_sector(Id, Label, Color, FillColor, Style, 'octagon');
		has_port(Id) -> writes_port_sector(Id, Label, Color, FillColor, Style);
		has_planet(Id) -> writes_planet_sector(Id, Label, Color, FillColor, Style);
		is_empty(Id) -> writes_empty_sector(Id, Label, Color, FillColor, Style)
	),
	writes("\n"),
	writes_sector_edges(Id, Lanes),
	writes("\n\n").

planet_color(Class, Color):-
	Class = 'M', Color="#558f6f"; % garden
	Class = 'K', Color="#888055"; % desert
	Class = 'O', Color="#555577"; % oceanic
	Class = 'L', Color="#6f6860"; % mountainous
	Class = 'C', Color="#5f5f8a"; % glacial
	Class = 'H', Color="#6f5555"; % volcanic
	Class = 'U', Color="#507f7f"; % gaseous
	Color = "#111111".

writes_planet(Planet, WithLabel):-
	planet(SectorId, Class, _, Name, _) = Planet,
	planet_color(Class, Color),
	(WithLabel, swritef(Label, "%w\\\\n(%w)", [Name, Class]); Label = ""),
	swritef(P, '"%w" [shape=circle fontsize=4 fixedsize=true width="0.25" height="0.25" margin="0,0" fillcolor="%w" color="%w" fontcolor="#eeeeee" label="%w", tooltip="planet"];\n', [Name, Color, Color, Label]),
	swritef(Edge, '"%w" -> "%w" [style=tapered dir=forward arrowhead=none arrowtail=none len="0.1" weight="10000" penwidth=4 color="%w", tooltip="planet link"];\n', [Name, SectorId, Color]),
	writes([P, Edge]).

writes_graph_header(Name):-
	writes(['digraph "', Name, '" {']),
	writes(['graph [overlap=false fontname="Fira Sans" splines=true bgcolor="#111111" pack=20 packmode="node"];']),
	writes(['node [shape=circle fontname="Fira Sans" fontcolor="#eeeeee" fillcolor="#111111" fontsize=10 style=filled width=0.35 height=0.35 color="#eeeeee" regular=true fixedsize=true];']),
	writes(['edge [color="#bbbbbb" fontname="Fira Sans" fontsize=10 fontcolor="#88ee88"];\n']).

map_sectors(FName, WithLabels, ColorMode):- 
	all_known_sectors(SectorList),
	all_planets(Planets),
	space_lanes(Lanes),
	tell(FName),
	swritef(Name, 'Map of All Sectors'), 
	writes_graph_header(Name),
	forall(member(Id, SectorList), writes_sector(Id, Lanes, WithLabels, ColorMode)),
	forall(member(Planet, Planets), writes_planet(Planet, WithLabels)),
	writes(['}']),
	told.

map_sectors(Fname, WithLabels):- map_sectors(Fname, WithLabels, normal).

map_sectors(FName):- map_sectors(FName, true, normal).

map_sectors_hidden(FName):- map_sectors(FName, false, regions).

map_local(FName, Origin, Warps, WithLabels, ColorMode):- 
	writef("Limiting to origin %w within warps %w\n", [Origin, Warps]),
	within_warps(Origin, Warps, SectorList),
	space_lanes(Lanes),
	tell(FName),
	swritef(Name, 'Local Map for Sector %w', [Origin]), 
	writes_graph_header(Name),
	forall(member(Id, SectorList), writes_sector(Id, Lanes, WithLabels, ColorMode)),
	planets_in_sector_list(SectorList, Planets),
	forall(member(Planet, Planets), writes_planet(Planet, WithLabels)),
	writes(['}']),
	told.
