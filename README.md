TW2K Prolog DB
==============
A program that reads CSV files of data dumped from TradeWars2002.  It generates reports about
good trade pairs, trade routes, and does all kinds of other nifty logical reasoning stuff.

- [example trade pair report](example_output/report_pairs.md)
- [example trade route report](example_output/report_routes.md)
- [example trans-warp trade report](example_output/report_transroutes.md)

It also makes fancy maps, like these:

#### A local map of Sol and surrounding sectors within 3 warps
<img style="display:inline;" src="https://raw.githubusercontent.com/nphyx/tw2k-pl/master/example_output/example_map.svg?sanitize=true" width="40%" height="auto">

#### A map of the whole known universe with labels hidden (taken from a dataset of ~300 sectors)
<img style="display:inline;" src="https://raw.githubusercontent.com/nphyx/tw2k-pl/master/example_output/example_secret_map.svg?sanitize=true" width="40%" height="auto">

See [Map Legend](#map-legend)

Table of Contents
-----------------
1) [Requirements](#requirements) :- prerequisites for use
2) [Installation & Setup](#installation-setup) :- installing & initial setup
3) [Usage](#usage) :- how to use
4) [Map Legend](#map-legend) :- how to read the maps
5) [About Data](#about-data) :- explanation of data files
6) [Importing Data](#importing-data) :- how to use the log parser
7) [Known Issues & ToDos](#known-issues-todos) :- stuff that is broken or not done yet
8) [Contributing](#contributing) :- want to help?
9) [License](#license) :- WTFPL 2.0

Requirements
------------
- SWI-Prolog
- Graphviz
- ansi2txt utility for log parsing (often found in a package called kbtin)
- awk, sort, uniq, and other standard *nix utils for log parsing (you are on something *nixy, aren't you?)
- Input data (you're on your own - see [Importing Data](#importing-data))
- Some Prolog packages, maybe? install them if it complains (`pack_install(<missing package>)` while in swipl) 

Installation & Setup
-----
1) Clone
```
git clone git@github.com/nphyx/tw2k-pl.git
```

2) Copy example_data/ to data/:
```sh
$ cp -r example_data data
```

3) Fill in as much data s you have in the CSVs - see [About Data](#about-data) and [Importing Data](#importing-data)
4) Make the executable
```
$ make
```
5) Use how you like (see [Usage](#usage))

If you don't build an executable, you can run as a script with `swipl -s tw2k.pl -g main [options]`

Usage
-----
See [help output](example_output/help.md) for full help text.

```sh
tw2k --help   [topic]
tw2k --map    <mode>  [options]
tw2k --report <mode>  [options]

for more info see:
--help options
--help maps
--help graphs
--help reports
```

You can also use it interactively. There are a bunch of useful functions in there
that don't have equivalent shell scripts.
```sh
$ tw2k --interactive
```

Examples:
```prolog
?- import_db. % you'll want to do this to load up your data first
?- port_sells(Id, fuel). % find ports selling fuel
?- best_average_sale(equipment, Id, Price). % find the best place to buy equipment
?- best_average_offer(organics, Id, Price). % find the best place to sell organics
?- go_path(1, 999, Path, Warps). % use dijkstra to calculate shortest path between sectors 1 and 2
?- halt.
```

See the source code for documentation.

Map Legend
----------

#### Shapes:

- octagon: sector with a class 0 or class 9 port
- diamond: sector with a port
- double-lined circle: sector with a planet
- circle: sector with no planets or ports (not necessarily completely empty, don't blind trans-warp to these)
- small circle: in local maps, a sector that is mapped but beyond the warp limit
- tiny, solid-colored circle: planet
- no border: an unmapped, but known, sector

#### Lines:

- blue, solid, bold: major space lane (connects class 9 / class 0 ports)
- dashed, bold, diamond heads: link between trade pairs
- dashed: a one-way link (semi-circles point in the link direction)
- solid: a normal bi-directional link
- solid, tapered: points from a planet to its home sector
- dotted: links to a known but unexplored sector

#### Border colors:
- yellow: Federation Space
- red: Ferrengi Empire
- dark purple: unexplored space
- others: chosen randomly according to region name

#### Background colors (normal mode):

- yellow: Sol system
- light gray: Stargate Alpha 1
- green: member of a trade pair
- red: dead-end (a sector with only one inbound link)
- teal: transit sector (a sector with no bi-directional links)


Background colors in region mode are chosen randomly by region name.

About Data
----------
tw2k.pl reads its data from extremely simple CSVs. Check the examples in `data_examples`.

- planets.csv - a list of discovered planets and info about them
- ports.csv - a list of discovered ports and their info
- regions.csv - a list of regions and the sectors they contain
- sectors.csv - a list of sectors and their outbound links
- trades.csv - a log of individual trades, used for calculating the profitability of a trade pair or route 

Note that for ports, class 0 and 9 port buys/sells will be ignored for the purposes of trading, but are still useful for mapping.

Importing Data
--------------
There's a very early, very janky build of a log parser at `parse_log`. Run at your own risk. It expects to find your logs at `~/bbs.log`,
and will handle stripping ansi codes.

If you're using SyncTerm to connect to your BBS, you should be able to begin logging by setting Log Level to 'debug', then start logging with `Alt+C`, only tested with "RAW" mode, best to use that. If you're using some other ansi terminal I can't help you, just put your logs at `~/bbs.log` and hopefully something works.

It (usually) knows how to parse:

- Ports, Sector warp links, planets, and region names from sector display (`D` in a sector), also from HoloScans (`S`, `H`, if you have a HoloScanner)
- Sector warp links from computer reports (`C`, `I`, `<sector id>`)
- Trade reports of each buy and sell you logged by product and sector id

It cannot parse:

- Planet class and ownership from planet scans (yet)
- Any other stuff that might be useful

The parser will put output in `tmp_data`, so as not to stomp on your existing data. You can merge or copy it manually if you're happy with it.

Protip:
```sh
$ tw2k --data-dir=tmp_data [other options] to use it
```

```prolog
?- import_db('tmp_data') % use in interactive mode
```

Beatings will continue until parser improves.

Known Issues & TODOs
--------------------
- Routing and space lanes don't always perfectly match what the game comes up with. It probably uses a different algorithm. Without more information I can't fix this, but it's accurate most of the time.
- Bad data can result in some of the render modes crashing while building very large maps. I've made some effort to sanitize before building the chart, but am still finding some problems - in particular keep an eye out for duplicate sectors.csv and planets.csv entries. If you get a crash while using `tw2k --map global` during the image rendering phase, that is the cause.
- Despite the refactor, the .dot files are still pretty heavy - eventually need to group nodes and edges into subgraphs (this may also improve map clustering)
- Map rendering takes a very long time on large maps. Nothing I can do about this. If you want a fast render you can change `splines=splines` to `splines=polyline` or `splines=false` in your `maps/sectors.dot` file and manually render, e.g. `sfdp -o maps/sectors.svg maps/sectors.dot`, but it'll draw your lines over your nodes, which is yewgly.
- More reports on the CLI would be nice (there's lots of hidden functionality in interactive mode that doesn't have corresponding CLI options)
- there is no GUI. #wontfix

Contributing
---------------
I am pretty crappy at both prolog and awk, which drive this whole thing (project was mainly an excuse to spend some time with both).
Pull requests are welcome if you know a better way to do anything in here, or if you'd like to contribute something cool - new reports,
map modes, etc. Just please test them against some data first.

P.S. Does anybody play TradeWars anymore? Haha! I'm on bbs.lunduke.com as 'Nphyx'.

License
-------
WTFPL 2.0
