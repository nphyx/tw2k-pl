% utilities for examining data
:- module(data, []).
?-use_module(dijsktra).
?-use_module(dynamics).
:- [util].
?-reexport(dijkstra).

path(From,To,Dist) :- link_from_to(From,To), Dist is 1.
:- export(path/3).

% true if both A and B are mapped, there's a one-way link between them, and returning
% from the destination point of the one way-link takes longer than W warps.
% long_return(-A<SectorId>, -B<SectorId>, -W<int>).
long_return(A,B,W):-
	unidirectional(A,B),
	mapped(A), mapped(B),
	(
		(not(link_from_to(A,B)), go(A,B,L), L > W);
		(not(link_from_to(B,A)), go(B,A,L), L > W)
	).
:- export(long_return/3).

% as long_return/3, with a default T of 10.
% long_return(-A<SectorId>, -B<SectorId>).
long_return(A,B):- long_return(A,B,10).
:- export(long_return/2).

% a sector is a hub if it has more than 5 outbound links.
% highly_connected(-Id).
hub(Id):-
	sector(Id, Links), length(Links, Len), Len > 5.
:- export(hub/1).

% finds whether a sector has a port based on trade and port data.
% has_port(-Id).
has_port(Id):-
	trade(Id, _, _, _, _);
	port(Id, _, _, _, _, _).
:- export(has_port/1).

% gets the class of a port.
% port_class(-Id, +Class).
port_class(Id, Class):- port(Id, _, Class, _, _, _).
:- export(port_class/2).

% checks if the port class is higher than Class.
port_class_gt(Id, Class):- port_class(Id, Cl), not(Cl = unknown), Cl > Class.
:- export(port_class_gt/2).

% finds whether a sector has a planet.
% has_planet(-Id).
has_planet(Id):- planet(Id, _, _, _, _).
:- export(has_planet/1).

% finds whether a sector is empty.
is_empty(Id):-
	not(has_port(Id)),
	not(has_planet(Id)).
:- export(is_empty/1).

% finds the shortest route between two sectors using dijkstra algorithm
% shortest_route(-A<sectorId>, -B<sectorId>, +W<warps>), 
shortest_route(A, B, W):- go(A, B, W).
:- export(shortest_route/3).

% finds price for a product in a sector
% unit_price(+Id<sectorId>, +Product<fuel|organics|equipment>, -Value).
unit_price(Id, Product, Value):- 
	trade(Id, _, Product, Qty, Price),
	Value is Price / Qty.
:- export(unit_price/3).

% thanks StackOverflow
average([], 0).
average([A], A).
average(List, Average):- 
    sum_list(List, Sum),
    length(List, Length),
    Length > 0, 
    Average is Sum / Length.
:- export(average/2).

% average of all sales of Product at port in Id.
% average_sale(+Id, +Product, -Avg).
average_sale(Id, Product, Avg):-
	findall(V, (trade(Id, s, Product, Qty, Price), V is Price / Qty), Vals),
	average(Vals, Avg).
:- export(average_sale/3).

% average of all buys of Product at port in Id.
% average_offer(+Id, +Product, -Avg).
average_offer(Id, Product, Avg):-
	findall(V, (trade(Id, b, Product, Qty, Price), V is Price / Qty), Vals),
	average(Vals, Avg).
:- export(average_offer/3).

% lists all the average sale values for a given product.
% all_average_sales(+Product, -List<(Id, Average)>).
all_average_sales(Product, List):-
	setof(Id, has_trade(Id, Product, s), Set),
	setof((Id, Avg), (member(Id, Set), average_sale(Id, Product, Avg)), List).
:- export(all_average_sales/2).

% finds the best average sale price of a product in any port
% best_average_sale(+Product, -Id, -Price).
lowest_average_sale(Product, Id, Price):-
	all_average_sales(Product, List),
	findall(P, member((_, P), List), Prices),
	min_list(Prices, Price),
	member((Id, Price), List).
:- export(lowest_average_sale/3).

% lists all the average offer values for a given product.
% all_average_offers(+Product, -List<(Id, Average)>).
all_average_offers(Product, List):-
	setof(Id, has_trade(Id, Product, b), Set),
	setof((Id, Avg), (member(Id, Set), average_offer(Id, Product, Avg)), List).
:- export(all_average_offers/2).

% finds the best average offer price of a product in any port
% best_average_offer(+Product, -Id, -Price).
highest_average_offer(Product, Id, Price):-
	all_average_offers(Product, List),
	findall(P, member((_, P), List), Prices),
	max_list(Prices, Price),
	member((Id, Price), List).
:- export(highest_average_offer/3).

% finds sale price for a product in a sector, if the sector's port sells the product
% sells_price(-Id<sectorId>, -Product<fuel|organics|equipment>, +Value).
sells_price(Id, Product, Value):-
	trade(Id, s, Product, Qty, Price),
	Value is Price / Qty.
:- export(sells_price/3).

% finds buy price for a product in a sector, if the sector's port buys the product
% buys_price(-Id<sectorId>, -Product<fuel|organics|equipment>, +Value).
buys_price(Id, Product, Value):-
	trade(Id, b, Product, Qty, Price),
	Value is Price / Qty.
:- export(buys_price/3).

% finds the cheapest sale price for a given product from trade records
% lowest_sale(-Product, +Answer<sale(Id, Price)>).
lowest_sale(Product, Answer):- 
	port_sells(Id, Product),
	findall(Unit, sells_price(Id, Product, Unit), UnitPrices),
	list_min(UnitPrices, Min),
	Answer = sale(Id, Min).
:- export(lowest_sale/2).

% finds the best offer price for a given product from trade records
% highest_offer(-Product, +Answer<offer(Id, Price)>).
highest_offer(Product, Answer):-
	port_buys(Id, Product),
	findall(Unit, buys_price(Id, Product, Unit), UnitPrices),
	list_max(UnitPrices, Max),
	Answer = offer(Id, Max).
:- export(highest_offer/2).

% finds all sales for a given product from trade records, sorted by price
% all_sales(-Product, +List<sale(Id, Price)>).
all_sales(Product, Sorted):-
	findall(sale(Id, Unit), sells_price(Id, Product, Unit), Pairs),
	sort(2, @<, Pairs, Sorted).
:- export(all_sales/2).

% finds all offers for a given product from trade records, sorted by price
% all_offers(-Product, +List<sale(Id, Price)>).
all_offers(Product, Sorted):-
	findall(offer(Id, Unit), buys_price(Id, Product, Unit), Pairs),
	sort(2, @<, Pairs, Sorted).
:- export(all_offers/2).

% answers whether a port buys a product
% port_buys(-Id, -Product<fuel|organics|equipment>).
port_buys(Id, Product):-
	(Product = fuel, port(Id, _, _, b, _, _));
	(Product = organics, port(Id, _, _, _, b, _));
	(Product = equipment, port(Id, _, _, _, _, b)).
:- export(port_buys/2).

% answers whether a port sells a product
% port_sells(-Id, -Product<fuel|organics|equipment>).
port_sells(Id, Product):-
	(Product = fuel, port(Id, _, _, s, _, _));
	(Product = organics, port(Id, _, _, _, s, _));
	(Product = equipment, port(Id, _, _, _, _, s)).
:- export(port_sells/2).

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
:- export(trade_pair/1).

% finds all trade pairs (@see trade_pair).
% trade_pairs(+Pairs<List<pair_trade>>).
trade_pairs(Pairs):-
	findall(P, trade_pair(P), Ps),
	dedupe(Ps, Pairs).
:- export(trade_pairs/1).

is_pair(A, B):-
	bidirectional(A, B),
	port_buys(A, ProductA),
	port_sells(A, ProductB),
	port_sells(B, ProductA),
	port_buys(B, ProductB).
:- export(is_pair/2).

% there should not be both buy & sell records for the same product, this
% indicates bad data
trade_sanity(Id, Product):-
	not(has_trade(Id, Product));
	not((has_trade(Id, Product, s), has_trade(Id, Product, b))).

trade_route(A, B, ProductA, ProductB):-
	has_trade(A, ProductA, s),
	has_trade(B, ProductA, b),
	has_trade(A, ProductB, b),
	has_trade(B, ProductB, s),
	not(A = B),
	not(ProductA = ProductB).
:- export(trade_route/4).

% finds trade routes - non-adjacent ports with matching buys/sells, and computes
% profitability by turns per warp.
% trade_route(+TPW, Routes<route>).
trade_routes(TPW, Routes):- 
	setof((A, B, ProductA, ProductB), trade_route(A, B, ProductA, ProductB), Todo),
	trade_routes2(TPW, Todo, Routes).
:- export(trade_routes/2).

trade_routes2(_, [], []).
trade_routes2(TPW, [H|T], Answer):-
	(A, B, ProductA, ProductB) = H,
	average_sale(A, ProductA, UnitA1),
	average_offer(B, ProductA, UnitB1),
	average_sale(B, ProductB, UnitA2),
	average_offer(A, ProductB, UnitB2),
	Profit is (UnitA1 - UnitB1) + (UnitA2 - UnitB2),
	shortest_route(A, B, L),
	RoundTrip is L * 2,
	ProfitPerWarp is Profit / RoundTrip,
	Turns is (RoundTrip * TPW) + 2,
	ProfitPerTurn is Profit / Turns,
	Pair = route(A, ProductA, B, ProductB, Profit, RoundTrip, ProfitPerWarp, Turns, ProfitPerTurn),
	trade_routes2(TPW, T, Partial),
	append(Partial, [Pair], Answer).

% finds trade routes and sorts by ProfitPerWarp, descending.
% trade_routes_sorted(+TPW, -Sorted<List<route>>).
trade_routes_sorted(TPW, Sorted):-
	trade_routes(TPW, Routes), !,
	sort(9, @>, Routes, Sorted).
:- export(trade_routes_sorted/2).

% finds trade routes - non-adjacent ports with matching buys/sells, and computes
% profitability by turns per warp.
% trade_route(+Holds, Routes<route>).
trans_routes(Holds, Routes):- 
	all_average_sales(fuel, AllSales),
	setof((A, B, ProductA, ProductB), (port_sells(B, fuel), trade_route(A, B, ProductA, ProductB)), Todo),
	findall(Price, member((_, Price), AllSales), AllPrices),
	average(AllPrices, FuelPrice),
	trans_routes2(FuelPrice, Holds, Todo, Routes).
:- export(trans_routes/2).

trans_routes2(_, _, [], []).
trans_routes2(FuelPrice, Holds, [H|T], Answer):-
	(A, B, ProductA, ProductB) = H,
	average_sale(A, ProductA, UnitA1),
	average_offer(B, ProductA, UnitB1),
	average_sale(B, ProductB, UnitA2),
	average_offer(A, ProductB, UnitB2),
	shortest_route(A, B, L),
	RoundTrip is L * 2,
	FuelCost is RoundTrip * 3,
	NetHolds is Holds - FuelCost,
	Profit is ((UnitA1 - UnitB1) * NetHolds) + ((UnitA2 - UnitB2) * (NetHolds / 2)) - (FuelCost * FuelPrice),
	ProfitPerTurn is Profit / 4,
	Pair = troute(A, ProductA, B, ProductB, Profit, ProfitPerTurn, FuelCost),
	trans_routes2(FuelPrice, Holds, T, Partial),
	append(Partial, [Pair], Answer).

% finds trade routes and sorts by ProfitPerWarp, descending.
% trade_routes_sorted(+TPW, -Sorted<List<route>>).
trans_routes_sorted(Holds, Sorted):-
	trans_routes(Holds, Routes), !,
	sort(6, @>, Routes, Sorted).
:- export(trans_routes_sorted/2).

% find major space lanes (routes between class 0 / class 9 ports).
% space_lane(-Lane).
space_lane(Lane):-
	(port_class(A, 0); port_class(A, 9)),
	(port_class(B, 0); port_class(B, 9)),
	go_path(A, B, Lane, _).
:- export(space_lane/1).

% list of all space lanes
% space_lanes(-Lanes).
space_lanes(Lanes):-
	findall(Lane, space_lane(Lane), Lanes).
:- export(space_lanes/1).

% true if a connection between two points is adjacent in a path.
% on_path(+A, +B, -Path).
on_path(A, B, Path):- adjacent(A, B, Path); adjacent(B, A, Path).
:- export(on_path/3).

% true if a connection between two points is adjacent on any of a list of paths.
% on_any_path(+A, +B, -Path).
on_any_path(A, B, Paths):-
	once((member(Path, Paths), on_path(A, B, Path))).
:- export(on_any_path/3).

connected(A, B):- edge(A, B, _); edge(B, A, _).
:- export(connected/2).
has_connect(A):- connected(A, _).
:- export(has_connect/1).

% true if a sector with Id has a sector map entry
% mapped(+SectorId).
mapped(Id):- sector(Id, _).
:- export(mapped/1).

% true if a sector with Id does not have a sector map entry
% mapped(+SectorId).
uncharted(Id):- not(mapped(Id)).
:- export(uncharted/1).

% List of all sectors within Warps distance from Id.
% within_warps(+Id, +Warps, -List<SectorId>).
within_warps(_, 0, []).
within_warps(Id, 1, List):- sector(Id, List).
within_warps(Id, Warps, List):-
	Warps > 1,
	NextWarps is Warps - 1,
	sector(Id, Links),
	findall(Within, (member(LinkId, Links), within_warps(LinkId, NextWarps, Within)), Withins),
	flatten([Links,Withins], Flat),
	setof(L, member(L, Flat), List).
:- export(within_warps/3).

% true if a sector has a port with at least one recorded trade.
% has_trade(+Id).
has_trade(Id):- trade(Id, _, _, _, _).
:- export(has_trade/1).

% true if a sector has a port with at least one recorded trade for product.
% has_trade(+Id, +Product).
has_trade(Id, Product):- trade(Id, _, Product, _, _).
:- export(has_trade/2).

% true if a sector has a port with at least one recorded trade of Type for product.
% has_trade(+Id, +Product, +BorS<b/s>).
has_trade(Id, Product, BorS):- trade(Id, BorS, Product, _, _).
:- export(has_trade/3).

% true if sectors A and B are adjacent and link to each other.
% bidirectional(+A<SectorId>, +B<SectorId>).
bidirectional(A, B):-
	sector(A, LA), member(B, LA);
	sector(B, LB), member(B, LB).
:- export(bidirectional/2).

% true if A has an outbound link to B.
% link_from_to(+A, +B).
link_from_to(A, B):-
	sector(A, LA),
	member(B, LA).
:- export(link_from_to/2).

% true if sectors A and B are adjacent but only one links to the other.
% bidirectional(-A<SectorId>, -B<SectorId>).
unidirectional(A, B):-
	mapped(A), mapped(B), link_from_to(A, B), not(link_from_to(B, A)).
:- export(unidirectional/2).

% true if the sector is mapped and has only one inbound link, and all outbound links
% connect to mapped sectors (so it counts as isolated if outbounds are escape paths).
% isolated(-SectorId).
isolated(SectorId):- 
	mapped(SectorId),
	findall(L, (sector(_, L), member(SectorId, L)), Links),
	(length(Links, 1); length(Links, 0)),
	(sector(SectorId, Outbound), forall(member(Id, Outbound), mapped(Id))).
:- export(isolated/1).

% a sector is a tunnel if it only has two links.
% tunnel(-SectorId).
tunnel(SectorId):-
	sector(SectorId, [_|[_]]).
:- export(tunnel/1).

% a sector is a pocket if it is connected only by unidirectional links in both directions,
% and all its links are mapped.
% pocket(-SectorId).
pocket(SectorId):-
	sector(SectorId, Links),
	forall(member(Id, Links), (mapped(Id), unidirectional(SectorId, Id))).
:- export(pocket/1).

% a sector might be a pocket if it is mapped and all its confirmed links are
% unidirectional; warrants further investigation.
% maybe_pocket(-SectorId).
maybe_pocket(SectorId):-
	sector(SectorId, Links),
	forall((member(Id, Links), mapped(Id)), unidirectional(SectorId, Id)).
:- export(maybe_pocket/1).

% finds the region of a sector Id, if it exists.
% region_of(-SectorId, +Region).
region_of(SectorId, Region):-
	region(Region, Sectors),
	member(SectorId, Sectors);
	Region = unknown.
:- export(region_of/2).

known_sector(Id):- 
	sector(Id, _);
	sector(_, List), member(Id, List).
:- export(known_sector/1).

all_known_sectors(List):-
	setof(Id, known_sector(Id), List).
:- export(all_known_sectors/1).

mapped_sectors(List):-
	setof(Id, mapped(Id), List).
:- export(mapped_sectors/1).

all_sectors(List):- numlist(1, 999, List). 
:- export(all_sectors/1).

unmapped_sectors(List):-
	mapped_sectors(Mapped),
	all_sectors(All),
	subtract(All, Mapped, List).
:- export(unmapped_sectors/1).

all_planets(Planets):-
	findall(planet(SectorId, Class, Level, Name, Owner), planet(SectorId, Class, Level, Name, Owner), Planets).
:- export(all_planets/1).

planets_in_sector_list(SectorList, Planets):-
	(setof(planet(SectorId, Class, Level, Name, Owner), (member(SectorId, SectorList), planet(SectorId, Class, Level, Name, Owner)), Planets); Planets = []).
:- export(planets_in_sector_list/2).

