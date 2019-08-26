TW2K Prolog DB
==============
A program that reads CSV files of data dumped from TradeWars2002.  It generates reports about
good trade pairs, trade routes, and does all kinds of other nifty logical reasoning stuff.

It also makes fancy maps, like these:

<img style="display:inline;" src="https://raw.githubusercontent.com/nphyx/tw2k-pl/master/example_maps/example_map.svg?sanitize=true" width="40%" height="auto">
<img style="display:inline;" src="https://raw.githubusercontent.com/nphyx/tw2k-pl/master/example_maps/example_secret_map.svg?sanitize=true" width="40%" height="auto">

(second one has all its sector info hidden so I don't give up too much of my own intel)

Maybe sometime I'll put a legend in there, but hopefully you can figure it out in the meanwhile. The lines and nodes have hover tooltips, which are viewable when opened
in a browser (but not in most image preview programs).

Requires
--------
- SWI-Prolog
- Graphviz
- ansi2txt utility for log parsing (often found in a package called kbtin)
- awk, sort, uniq, and other standard *nix utils for log parsing (you are on something *nixy, aren't you?)
- Input data (you're on your own - see [Importing Data](#importing-data))
- Some Prolog packages, maybe? install them if it complains (`pack_install(<missing package>)` while in swipl) 

Setup
-----
1) Copy example_data/ to data/:
```sh
$ cp -r example_data data
```

2) Fill in as much data s you have in the appropriate CSVs - see [About Data](#about-data).
3) Optionally, build the executable:
```
$ ./build.sh
```
4) Use how you like (see [Usage](#usage))

If you don't build an executable, you can run as a script with `swipl -s tw2k.pl -g main [options]`

About Data
----------
tw2k.pl reads its data from extremely simple CSVs. Check the examples in data_examples/.
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

If you're using SyncTerm to connect to your BBS, you should be able to begin logging by setting Log Level to 'debug', then start logging with `Alt+C`,
only tested with "RAW" mode, best to use that. If you're using some other ansi terminal I can't help you, just put your logs at `~/bbs.log` and hopefully something works.

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

Usage
-----
```sh
tw2k [options]

Examples:
tw2k --map global -R neato #render a map of sectors using neato
tw2k --report pairs #print a report of known trade pairs

Options:
--help      -h  boolean=_              print help
--graph     -g  atom=_                 generate a sector graph and build a dot from it
                                         - see Map and Graph modes
--map       -m  atom=_                 generate a graph and build an svg map from it
                                         - imples --graph
                                         - requires graphviz installed on your system
                                         - see Map and Graph modes
--output    -o  atom=maps/sectors.dot  set output graphviz dot file (used with --graph and --map)
--image     -i  atom=maps/sectors.svg  set output image file (used with --graph and --map)
--colors    -C  atom=normal            color mode for maps and graphs, <normal|regions>
--labels    -l  boolean=true           label sectors
--hops      -H  integer=3              hop limit for local maps
--origin    -O  integer=1              origin for local maps
--renderer  -R  atom=sfdp              graphviz image renderer to use
                                         - used with --map
                                         - best options are neato, fdp, and sfdp; try your luck with the others
--report    -r  atom=_                 print a report, modes:
                                           pairs:  print pairs of adjacent ports with matching trades
                                           routes: print all trade routes - ports with matching trades at any distance
                                                   sorted by profit-per-hop per unit (see holds)
--holds         integer=1              when used with reporting, multiply per-unit value by number of holds
--data-dir  -d  atom=data              set the directory to load data from

Map and Graph Modes:
  global: a map of the universe with color-coded points of interest
  local:  only render sectors within a number of hops of an origin sector (see --hops, --origin)
```

You can also use it interactively. There are a bunch of useful functions in there
that don't have equivalent shell scripts.
```sh
$ swipl -s tw2k.pl
```

Examples:
```prolog
?- import_db. % you'll want to do this to load up your data first
?- port_sells(Id, fuel). % find ports selling fuel
?- best_average_sale(equipment, Id, Price). % find the best place to buy equipment
?- best_average_offer(organics, Id, Price). % find the best place to sell organics
?- go_path(1, 999, Path, Hops). % use dijkstra to calculate shortest path between sectors 1 and 2
?- halt.
```

See the source code for documentation.

Known Issues & TODOs
--------------------
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
