% local map module
:-module(local, []).
?-use_module('../data').
?-use_module('../util').
?- use_module(graph).
?- use_module(nodes).

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

:-export(map_local/5).
