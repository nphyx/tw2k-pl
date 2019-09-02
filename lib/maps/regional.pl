:- module(regional, []).
?- use_module('../dynamics').
?- use_module('../data').
?- use_module('../util').
?- use_module(graph).
?- use_module(nodes).
?- use_module(helpers).


map_regional(FName, WithLabels, ColorMode):- 
	%all_regions(Regions),
	%claim_sectors(Regions, _, Claims),
	% all_known_sectors(Known),
	all_uncharted_space_sectors(Uncharted),
	all_unknown_region_sectors(Unknowns),
	% subtract(Visited, Known, Remaining),
	all_planets(Planets),
	space_lanes(Lanes),
	tell(FName),
	swritef(Name, 'Map of All Sectors'), 
	writes_graph_header(Name),
	writef('clusterrank="local"'),
	writef('label="Clustered Region Map"'),
	forall((region(RegionName, RegionSectors), is_named_region(RegionName)), (
		% region_claim(RegionName, RegionSectors) = Claim,
		writef('\nsubgraph "cluster_%w" {\n label="%w"\n', [RegionName, RegionName]),
		forall(member(Id, RegionSectors), (writes_region_sector(Id, RegionName, Lanes, WithLabels, ColorMode), !)),
		writef('}\n\n')
	)), !,
	forall(member(UnchId, Uncharted), writes_sector(UnchId, Lanes, WithLabels, ColorMode)),
	forall(member(UnkId, Unknowns), writes_sector(UnkId, Lanes, WithLabels, ColorMode)),
	forall(member(Planet, Planets), writes_planet(Planet, WithLabels)),
	writes(['}']), !,
	told.
:-export(map_regional/3).
