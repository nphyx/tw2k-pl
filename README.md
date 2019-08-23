TW2K Prolog DB
==============
A program that reads CSV files of data dumped from TradeWars2002 and generates maps
and reports from it.

Requires
--------
- SWI-Prolog
- Input data (you're on your own - see data_examples)
- Graphviz
- Some Prolog packages, maybe? install them if it complains

Setup
-----
1) Copy data_examples/ to data/:
```sh
$ cp -r data_examples data
```

2) Fill in as much data s you have in the appropriate CSVs.
3) Use how you like (see [Usage](#usage))

About Data
----------
tw2k.pl reads its data from extremely simple CSVs. Check the examples in data_examples/.
- planets.csv - a list of discovered planets and info about them
- ports.csv - a list of discovered ports and their info
- regions.csv - a list of regions and the sectors they contain
- sectors.csv - a list of sectors and their outbound links
- trades.csv - a log of individual trades, used for calculating the profitability of a trade pair or route 

Note that for ports, class 0 and 9 port buys/sells will be ignored for the purposes of trading, but are still useful for mapping.

Usage
-----
```sh
$ swipl -s map_sectors.pl #generates maps/sectors.dot, a graphviz dot file
$ ./map #generates an svg map, and places it in the maps/ directory as sectors.svg
$ ./pairs #generates a list of known trade pairs
```

You can also use it interactively. There are a bunch of useful functions in there
that don't have equivalent shell scripts.
```sh
$ swipl -s tw2k.pl
```

See the source code for documentation.
