% shared edge writing stuff
?- module(edges, []).
?- use_module('../dynamics').
?- use_module('../data').
?- use_module(helpers).

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
:- export(writes_sector_edges/2).
