% Helper predicates for maps
?-module(helpers, []).
?-use_module('../data').
?-use_module('../util').
?-use_module('../dynamics').

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
:- export(region_color/2).

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
:- export(region_bg/2).

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
:- export(sector_label/2).

product_tag(Product, Tag):-
	Product = fuel, Tag = 'F';
	Product = equipment, Tag = 'E';
	Product = organics, Tag = 'O'.

% finds the background color for a sector in normal mode
sector_color(Id, C):-
	(not(mapped(Id)), C = "#111111");
	(isolated(Id), C = '#773333');
	(tunnel(Id), C = "#227788");
	(pocket(Id), C = "#228877");
	(maybe_pocket(Id), C = "#115555");
	(is_pair(Id, _), (
		port_class_gt(Id, 3), C = "#337733";
		C = "#115511"
	));
	(Id = 1, C = '#aa9955');
	(port(Id, _, 0, _, _, _), C = '#556655');
	(port(Id, _, 9, _, _, _), C = '#555566');
	(planet(Id, _, _, _, Owner), not(Owner = unknown), C = '#333377');
	C = '#222222'.
:- export(sector_color/2).

% finds the background color for a sector in regional mode
sector_color_by_region(Id, C):-
	(not(mapped(Id)), C = "#111111");
	region_of(Id, Region), region_bg(Region, C);
	C = '#222222'.
:- export(sector_color_by_region/2).

sector_border(Id, C):-
	region_of(Id, Region), region_color(Region, C);
	C = "#aaaaaa".
:- export(sector_border/2).

sector_style(Id, Style):-
	hub(Id), Style = 'filled, bold';
	Style = 'filled'.
:- export(sector_style/2).

planet_color(Class, Color):-
	(Class = 'M'; Class = 'm'), Color="#558f6f"; % garden
	(Class = 'K'; Class = 'k'), Color="#888055"; % desert
	(Class = 'O'; Class = 'o'), Color="#555577"; % oceanic
	(Class = 'L'; Class = 'l'), Color="#6f6860"; % mountainous
	(Class = 'C'; Class = 'c'), Color="#5f5f8a"; % glacial
	(Class = 'H'; Class = 'h'), Color="#6f5555"; % volcanic
	(Class = 'U'; Class = 'u'), Color="#507f7f"; % gaseous
	Color = "#111111".
:- export(planet_color/2).
