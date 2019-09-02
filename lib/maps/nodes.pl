% node writing stuff
:-module(nodes, []).
?- use_module('../data').
?- use_module(helpers).
?- use_module(edges).

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
:-export(writes_sector/4).

writes_planet(Planet, WithLabel):-
	planet(SectorId, Class, _, Name, _) = Planet,
	planet_color(Class, Color),
	(WithLabel, swritef(Label, "%w\\\\n(%w)", [Name, Class]); Label = ""),
	swritef(P, '"%w" [shape=circle fontsize=4 fixedsize=true width="0.25" height="0.25" margin="0,0" fillcolor="%w" color="%w" fontcolor="#eeeeee" label="%w", tooltip="planet"];\n', [Name, Color, Color, Label]),
	swritef(Edge, '"%w" -> "%w" [style=tapered dir=forward arrowhead=none arrowtail=none len="0.1" weight="10000" penwidth=4 color="%w", tooltip="planet link"];\n', [Name, SectorId, Color]),
	writes([P, Edge]).
:- export(writes_planet/2).

writes_region_sector(Id, RegionName, Lanes, WithLabel, ColorMode):-
	in_region(Id, RegionName) -> (
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
		writes("\n")
	),
	writes_sector_edges(Id, Lanes),
	writes("\n\n"); true, !.
:- export(writes_region_sector/5).
