:- module(universe, []).
?- use_module('../data').
?- use_module('../util').
?- use_module(graph).
?- use_module(nodes).
?- use_module(helpers).

map_universe(FName, WithLabels, ColorMode):- 
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
:-export(map_universe/3).
