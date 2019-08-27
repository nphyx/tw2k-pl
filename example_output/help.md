# Help Output from TW2K
```sh
-=-=-= TW2K - A TradeWars 2002 Utility =-=-=-

Usage:
tw2k --help   [topic]
tw2k --map    <mode>  [options]
tw2k --report <mode>  [options]

for more info see:
--help options
--help maps
--help graphs
--help reports


Options:
--help         -h  atom=_        print help
--interactive      boolean=_     start in interactive mode with --data-dir
                                   loaded
--graph        -g  atom=_        generate a sector graph and build a dot file (see --help graphs)
--map          -m  atom=_        generate an svg map (see --help maps) (imples --graph)
--output       -o  atom=_        set output graphviz dot file (used with --graph and --map)
--image        -i  atom=_        set output image file (used with --graph and --map)
--colors       -C  atom=normal   color mode for maps and graphs (see --help maps)
--labels       -l  boolean=true  label sectors
--warps        -W  integer=3     warp limit for local maps
--origin       -O  integer=1     origin for local maps
--renderer     -R  atom=sfdp     graphviz image renderer to use (see --help maps)
--report       -r  atom=_        print a report, modes (see --help reports)
--holds            integer=1     when used with reporting, multiply per-unit value by number of holds
--tpw          -t  integer=2     turns per warp for route calculations
--data-dir     -d  atom=data     set the directory to load data from
--map-dir          atom=maps     directory where maps should be saved


Examples:
tw2k --map global -R neato #render a map of sectors using neato
tw2k --report pairs #print a report of known trade pairs


                      -=-=-=-= Map and Graph Modes =-=-=-=-                     
+------------------------------------------------------------------------------+
| global  : render a map of every sector in the database                       |
|         : default output is maps/sectors.dot, maps/sectors.svg               |
| example : to create a map of sector 1 (Sol system) and surroundings within 3 |
|         : warps:                                                             |
|         : tw2k --map local -O 1 -H 3                                         |
|------------------------------------------------------------------------------|
| local   : only render sectors within a number of warps of an origin sector   |
|         : default output is maps/<origin>_<warps>.dot,                       |
|         :                   maps/<origin>_<warps>.svg                        |
| example : to create a map of sector 1 and surroundings within 3 warps:       |
|         : tw2k --map local -O 1 -H 3                                         |
| options : --origin   <int>       origin sector ID to start with (default 1)  |
|         : --warps     <int>      max warps from origin (default 3)           |
+------------------------------------------------------------------------------+

                -=-=-=-= Options for all Maps & Graphs =-=-=-=-                 
+------------------------------------------------------------------------------+
| options : --renderer <renderer>   graphviz layout renderer to use            |
|         :                         recommended: sfdp, fdp, neato              |
|         :                         others     : dot, circo, twopi             |
|         : --labels   <true|false> show or hide labels (default true)         |
|         : --colors   <color mode> which color coding method to use:          |
|         :                         normal     : color points of interest      |
|         :                         region     : color by region               |
+------------------------------------------------------------------------------+



                         -=-=-=-= Report Modes =-=-=-=-                         
+------------------------------------------------------------------------------+
| mapped   : list all mapped sectors                                           |
|------------------------------------------------------------------------------|
| unmapped : list all mapped sectors                                           |
|------------------------------------------------------------------------------|
| boundary : list all sectors adjacent to a mapped sector, but themselves      |
|          : unmapped                                                          |
|------------------------------------------------------------------------------|
| boundary : list all completely unknown sectors                               |
|------------------------------------------------------------------------------|
| pairs    : print a list of known trade pairs - adjacent ports with matched   |
|          : trades                                                            |
| note     : built from list of ports stored in ports.csv, requires at least 2 |
|          : matching entries                                                  |
|------------------------------------------------------------------------------|
| routes   : print a list of trade routes - ports at any distance that have    |
|          : matching buys and sells, sorted by profit per turn per unit sold. |
| note     : built from list of ports in ports.csv and recorded trades in      |
|          : trades.csv requires at least 2 matching trades and logs of        |
|          : corresponding ports                                               |
| options  : --holds <number>  calculates total profit for full holds.         |
| options  : --tpw   <number>  turns per warp (default 2)                      |
|------------------------------------------------------------------------------|
| routes   : print a list of trans-warp trades, with built in profit           |
|          : adjustment based on average fuel cost and number of reserved      |
|          : holds.                                                            |
| notes    : you should always specify your ship's holds with this report if   |
|          : you want useful results.                                          |
| options  : --holds <number>  calculates total profit for full holds.         |
+------------------------------------------------------------------------------+

```
