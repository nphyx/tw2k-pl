:- module(dynamics, [planet/5, planet/10, port/6, trade/5, sector/2, region/2, pair_trade/4, pair_route/4]).
% planet(-SectorId, -PlanetId, -PlanetClass, -PlanetName, -PlanetOwner, -PlanetCreator, -CitadelLevel, -RLevel, -Fighters, -QCannonLevel).
:-dynamic planet/10.

% map planet/10 to planet/5 (old format, laziness)
% planet(-SectorId, -PlanetClass, -PlanetLevel, -PlanetName, -PlanetOwner).
planet(A, B, C, D, E) :- planet(A, _, B, D, E, _, C, _, _, _).

% port(-Sector, -Name, -Class, -fuel<buys/sells>, -organics<buys/sells>, -equipment<buys/sells>)
:-dynamic port/6.

% trade(-Sector, -Mode<buys/sells>, -Product<fuel/organics/equipment>, -Quantity, -Price)
:-dynamic trade/5.

% sector(-Sector, List[Sector, ...]).
:-dynamic sector/2.

% region(-Name, -List[Sector, ...]).
:-dynamic region/2.

% a region and a list of all the sectors it's claimed for its local cluster
% region_claim(-Name, -List[Sector, ...]).
:- dynamic(region_claim/2).

% pair_trade(-SectorA, -SectorB, -ProductA, -ProductB).
:-dynamic pair_trade/4.

% pair_route(-SectorA, -SectorB, -ProductA, -ProductB).
:-dynamic pair_route/4.

