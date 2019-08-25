% planet(-SectorId, -PlanetClass, -CitadelLevel, -PlanetName, -PlanetOwner).
:-dynamic planet/5.

% port(-Sector, -Name, -Class, -fuel<buys/sells>, -organics<buys/sells>, -equipment<buys/sells>)
:-dynamic port/6.

% trade(-Sector, -type<buys/sells>, -product<fuel/organics/equipment>, -price, -quantity)
:-dynamic trade/5.

% sector(-Sector, List[-connected_sector, ...]).
:-dynamic sector/2.

% region(-Name, -List[-sector, ...]).
:-dynamic region/2.
