:- [dynamics].
:- [util].
:- [dijkstra].

path(From,To,Dist) :- link_from_to(From,To), Dist is 1.

% true if both A and B are mapped, there's a one-way link between them, and returning
% from the destination point of the one way-link takes longer than T hops.
% long_return(-A<SectorId>, -B<SectorId>, -T<int>).
long_return(A,B,T):-
	unidirectional(A,B),
	mapped(A), mapped(B),
	(
		(not(link_from_to(A,B)), go(A,B,L), L > T);
		(not(link_from_to(B,A)), go(B,A,L), L > T)
	).

% as long_return/3, with a default T of 10.
% long_return(-A<SectorId>, -B<SectorId>).
long_return(A,B):- long_return(A,B,10).

% a sector is a hub if it has more than 5 outbound links.
% highly_connected(-Id).
hub(Id):-
	sector(Id, Links), length(Links, Len), Len > 5.

% finds whether a sector has a port based on trade and port data.
% has_port(-Id).
has_port(Id):-
	trade(Id, _, _, _, _);
	port(Id, _, _, _, _, _).

% gets the class of a port.
% port_class(-Id, +Class).
port_class(Id, Class):- port(Id, _, Class, _, _, _).

% checks if the port class is higher than Class.
port_class_gt(Id, Class):- port_class(Id, Cl), not(Cl = unknown), Cl > Class.

% finds whether a sector has a planet.
% has_planet(-Id).
has_planet(Id):- planet(Id, _, _, _, _).

% finds whether a sector is empty.
is_empty(Id):-
	not(has_port(Id)),
	not(has_planet(Id)).

% finds the shortest route between two sectors using dijkstra algorithm
% shortest_route(-A<sectorId>, -B<sectorId>, +H<hops>), 
shortest_route(A, B, H):- go(A, B, H).

% finds price for a product in a sector
% unit_price(-Id<sectorId>, -Product<fuel|organics|equipment>, +Value).
unit_price(Id, Product, Value):- 
	trade(Id, _, Product, Price, Qty),
	Value is Price / Qty.

% finds sale price for a product in a sector, if the sector's port sells the product
% sells_price(-Id<sectorId>, -Product<fuel|organics|equipment>, +Value).
sells_price(Id, Product, Value):-
	trade(Id, s, Product, Price, Qty),
	Value is Price / Qty.

% finds buy price for a product in a sector, if the sector's port buys the product
% buys_price(-Id<sectorId>, -Product<fuel|organics|equipment>, +Value).
buys_price(Id, Product, Value):-
	trade(Id, b, Product, Price, Qty),
	Value is Price / Qty.

% finds the cheapest sale price for a given product from trade records
% cheapest_sale(-Product, +Answer<sale(Id, Price)>).
cheapest_sale(Product, Answer):- 
	port_sells(Id, Product),
	findall(Unit, sells_price(Id, Product, Unit), UnitPrices),
	list_min(UnitPrices, Min),
	Answer = sale(Id, Min).

% finds the best offer price for a given product from trade records
% highest_offer(-Product, +Answer<offer(Id, Price)>).
highest_offer(Product, Answer):-
	port_buys(Id, Product),
	findall(Unit, buys_price(Id, Product, Unit), UnitPrices),
	list_max(UnitPrices, Max),
	Answer = offer(Id, Max).

% finds all sales for a given product from trade records, sorted by price
% all_sales(-Product, +List<sale(Id, Price)>).
all_sales(Product, Sorted):-
	findall(sale(Id, Unit), sells_price(Id, Product, Unit), Pairs),
	sort(2, @<, Pairs, Sorted).

% finds all offers for a given product from trade records, sorted by price
% all_offers(-Product, +List<sale(Id, Price)>).
all_offers(Product, Sorted):-
	findall(offer(Id, Unit), buys_price(Id, Product, Unit), Pairs),
	sort(2, @<, Pairs, Sorted).

% answers whether a port buys a product
% port_buys(-Id, -Product<fuel|organics|equipment>).
port_buys(Id, Product):-
	(Product = fuel, port(Id, _, _, b, _, _));
	(Product = organics, port(Id, _, _, _, b, _));
	(Product = equipment, port(Id, _, _, _, _, b)).

% answers whether a port sells a product
% port_sells(-Id, -Product<fuel|organics|equipment>).
port_sells(Id, Product):-
	(Product = fuel, port(Id, _, _, s, _, _));
	(Product = organics, port(Id, _, _, _, s, _));
	(Product = equipment, port(Id, _, _, _, _, s)).

% finds trade pairs - adjacent ports with bidirectional links that have matching
% buys/sells
% trade_pair(+Pair<pair_trade(SectorIdA, SectorIdb, ProductA, ProductB)>).
trade_pair(Pair):-
	bidirectional(A, B),
	port_buys(A, ProductA),
	port_sells(A, ProductB),
	port_sells(B, ProductA),
	port_buys(B, ProductB),
	Pair = pair_trade(A, B, ProductA, ProductB).

% finds all trade pairs (@see trade_pair).
% trade_pairs(+Pairs<List<pair_trade>>).
trade_pairs(Pairs):-
	findall(P, trade_pair(P), Ps),
	dedupe(Ps, Pairs).

% finds trade routes - non-adjacent ports with matching buys/sells (SLOW)
% trade_route(+Pair<pair_route>).
trade_route(Pair):-
	sells_price(A, ProductA, UnitA1),
	buys_price(B, ProductA, UnitB1),
	sells_price(B, ProductB, UnitA2),
	buys_price(A, ProductB, UnitB2),
	Profit is (UnitB1 - UnitA1) + (UnitB2 - UnitA2),
	shortest_route(A, B, L),
	RoundTrip is L * 2,
	ProfitPerHop is Profit / RoundTrip,
	Pair = pair_route(A, ProductA, B, ProductB, Profit, RoundTrip, ProfitPerHop).

% finds all trade routes (@see trade_route), (VERY SLOW)
% trade_routes(+Pairs<List<pair_route>>).
trade_routes(Pairs):-
	findall(Pair, trade_route(Pair), Pairs).

% find major space lanes (routes between class 0 / class 9 ports).
% space_lane(+Lane).
space_lane(Lane):-
	(port_class(A, 0); port_class(A, 9)),
	(port_class(B, 0); port_class(B, 9)),
	go_path(A, B, Lane, _).

% list of all space lanes
% space_lanes(+Lanes).
space_lanes(Lanes):-
	findall(Lane, space_lane(Lane), Lanes).

% true if a connection between two points is adjacent in a path.
% on_path(-A, -B, -Path).
on_path(A, B, Path):- adjacent(A, B, Path); adjacent(B, A, Path).

% true if a connection between two points is adjacent on any of a list of paths.
% on_any_path(+A, +B, -Path).
on_any_path(A, B, Paths):-
	once((member(Path, Paths), on_path(A, B, Path))).

% finds trade routes and sorts by ProfitPerHop, descending.
% sorted_trade_routes(-Sorted<List<pair_route>>).
sorted_trade_routes(Sorted):-
	trade_routes(Pairs),
	sort(7, @>, Pairs, Sorted).

connected(A, B):- edge(A, B, _); edge(B, A, _).
has_connect(A):- connected(A, _).

% true if a sector with Id has a sector map entry
% mapped(+SectorId).
mapped(Id):- sector(Id, _).

% true if a sector with Id does not have a sector map entry
% mapped(+SectorId).
uncharted(Id):- not(mapped(Id)).

% List of all sectors within Hops distance from Id.
% within_hops(+Id, +Hops, -List<SectorId>).
within_hops(_, 0, []).
within_hops(Id, 1, List):- sector(Id, List).
within_hops(Id, Hops, List):-
	Hops > 1,
	NextHops is Hops - 1,
	sector(Id, Links),
	findall(Within, (member(LinkId, Links), within_hops(LinkId, NextHops, Within)), Withins),
	flatten([Links,Withins], Flat),
	setof(L, member(L, Flat), List).

% true if a sector has a port with at least one recorded trade.
% has_trade(+Id).
has_trade(Id):- trade(Id, _, _, _, _).

% true if sectors A and B are adjacent and link to each other.
% bidirectional(+A<SectorId>, +B<SectorId>).
bidirectional(A, B):-
	sector(A, LA), member(B, LA);
	sector(B, LB), member(B, LB).

% true if A has an outbound link to B.
% link_from_to(+A, +B).
link_from_to(A, B):-
	sector(A, LA),
	member(B, LA).

% true if sectors A and B are adjacent but only one links to the other.
% bidirectional(-A<SectorId>, -B<SectorId>).
unidirectional(A, B):-
	mapped(A), mapped(B), link_from_to(A, B), not(link_from_to(B, A)).
	%(link_from_to(B, A), not(link_from_to(A, B))).

% true if the sector is mapped and has only one inbound link, and all outbound links
% connect to mapped sectors (so it counts as isolated if outbounds are escape paths).
% isolated(-SectorId).
isolated(SectorId):- 
	mapped(SectorId),
	findall(L, (sector(_, L), member(SectorId, L)), Links),
	(length(Links, 1); length(Links, 0)),
	(sector(SectorId, Outbound), forall(member(Id, Outbound), mapped(Id))).

% a sector is a pocket if it is connected only by unidirectional links in both directions,
% and all its links are mapped.
% pocket(-SectorId).
pocket(SectorId):-
	sector(SectorId, Links),
	forall(member(Id, Links), (mapped(Id), unidirectional(SectorId, Id))).

% a sector might be a pocket if it is mapped and all its confirmed links are
% unidirectional; warrants further investigation.
% maybe_pocket(-SectorId).
maybe_pocket(SectorId):-
	sector(SectorId, Links),
	forall((member(Id, Links), mapped(Id)), unidirectional(SectorId, Id)).

% finds the region of a sector Id, if it exists.
% region_of(-SectorId, +Region).
region_of(SectorId, Region):-
	region(Region, Sectors),
	member(SectorId, Sectors);
	Region = unknown.
