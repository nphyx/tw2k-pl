% TW2K: a utility program for TradeWars 2002
?- use_module(library(optparse)).
:- [lib/dynamics].
:- [lib/util].
:- [lib/storage].
:- [lib/data].
:- [lib/reports].
:- [lib/mapping].

main:-
	OptSpec = [
		[
			opt(help), type(atom),
			shortflags([h]), longflags(['help']),
			help('print help')
		],
		[
			opt(interactive), type(boolean),
			shortflags([]), longflags(['interactive']),
			help('start in interactive mode with --data-dir loaded')
		],
		[
			opt(graph), type(atom),
			shortflags([g]), longflags(['graph']),
			help(['generate a sector graph and build a dot file (see --help graphs)'])
		],
		[
			opt(map), type(atom),
			shortflags([m]), longflags(['map']),
			help(['generate an svg map (see --help maps) (imples --graph)'])
		],
		[
			opt(output), type(atom),
			shortflags([o]), longflags(['output']),
			help(['set output graphviz dot file (used with --graph and --map)'])
		],
		[
			opt(image), type(atom),
			shortflags([i]), longflags(['image']),
			help(['set output image file (used with --graph and --map)'])
		],
		[
			opt(colors), type(atom), default('normal'),
			shortflags(['C']), longflags(['colors']),
			help(['color mode for maps and graphs (see --help maps)'])
		],
		[
			opt(labels), type(boolean), default(true),
			shortflags(['l']), longflags(['labels']),
			help(['label sectors'])
		],
		[
			opt(warps), type(integer), default(3),
			shortflags(['W']), longflags(['warps']),
			help(['warp limit for local maps'])
		],
		[
			opt(origin), type(integer), default(1),
			shortflags(['O']), longflags(['origin']),
			help(['origin for local maps'])
		],
		[
			opt(gvcmd), type(atom), default('sfdp'),
			shortflags(['R']), longflags(['renderer']),
			help(['graphviz image renderer to use (see --help maps)'])
		],
		[
			opt(report), type(atom),
			shortflags(['r']), longflags(['report']),
			help(['print a report, modes (see --help reports)'])
		],
		[
			opt(holds), type(integer), default(1),
			shortflags([]), longflags(['holds']),
			help(['when used with reporting, multiply per-unit value by number of holds'])
		],
		[
			opt(tpw), type(integer), default(2),
			shortflags(['t']), longflags(['tpw']),
			help(['turns per warp for route calculations'])
		],
		[
			opt(data_dir), type(atom), default('data'),
			shortflags([d]), longflags(['data-dir']),
			help(['set the directory to load data from'])
		],
		[
			opt(map_dir), type(atom), default('maps'),
			shortflags([]), longflags(['map-dir']),
			help(['directory where maps should be saved'])
		]
	],
	format('-=-=-= TW2K - A TradeWars 2002 Utility =-=-=-~n'),
	opt_arguments(OptSpec, Args, _),
	member(interactive(Interactive), Args), 
	member(help(Help), Args), 
	(
		( % map mode
			member(data_dir(Data), Args),
			(member(map(Map), Args), not(var(Map))),
			member(labels(Labels), Args),
			member(colors(Colors), Args),
			member(gvcmd(GvCmd), Args),
			member(map_dir(MapDir), Args),
			(
				(
					Map = local -> (
						import_db(Data),
						member(warps(Warps), Args),
						member(origin(Origin), Args),
						(
							member(output(Of), Args), not(var(Of));
							swritef(Of, '%w_%w.dot', [Origin, Warps])
						),
						(
							member(image(If), Args), not(var(If));
							swritef(If, '%w_%w.svg', [Origin, Warps])
						),
						swritef(Og, '%w/%w', [MapDir, Of]), atom_string(O, Og),
						swritef(Ig, '%w/%w', [MapDir, If]), atom_string(I, Ig),
						swritef(Cmd, 'dot -Tsvg -K%w -o %w %w', [GvCmd, I, O]),
						writef('\n-=-=-= Generating Local Graph ::: %w =-=-=-\n', [O]),
						map_local(O, Origin, Warps, Labels, Colors),
						writef('Done.\n\n-=-=-=  Generating Local Map  ::: %w =-=-=-\n', [I]),
						shell(Cmd),
						writef('Done.\n\n'),
						halt
					);
					Map = global -> (
						import_db(Data),
						(
							member(output(Of), Args), not(var(Of));
							Of = 'sectors.dot'
						),
						(
							member(image(If), Args), not(var(If));
							If = 'sectors.svg'
						),
						swritef(Og, '%w/%w', [MapDir, Of]), atom_string(O, Og),
						swritef(Ig, '%w/%w', [MapDir, If]), atom_string(I, Ig),
						swritef(Cmd, 'dot -Tsvg -K%w -o %w %w', [GvCmd, I, O]),
						writef('\n-=-=-= Generating Universe Graph ::: %w =-=-=-\n', [O]),
						map_sectors(O, Labels, Colors),
						writef('Done.\n\n-=-=-=  Generating Universe Map  ::: %w =-=-=-\n', [I]),
						shell(Cmd),
						writef('Done.\n\n'),
						halt
					);
					(
						writef('unsupported map type %w\n', [Map]), halt
					)
				)
			)
		);
		( % graph mode
			member(data_dir(Data), Args),
			(member(graph(Graph), Args), not(var(Graph))),
			member(labels(Labels), Args),
			member(colors(Colors), Args),
			member(map_dir(MapDir), Args),
			(
				(
					Graph = local -> (
						import_db(Data),
						member(warps(Warps), Args),
						member(origin(Origin), Args),
						(
							member(output(Of), Args), not(var(Of));
							swritef(Of, '%w_%w.dot', [Origin, Warps])
						),
						swritef(Og, '%w/%w', [MapDir, Of]), atom_string(O, Og),
						writef('\n-=-=-= Generating Local Graph ::: %w =-=-=-\n', [O]),
						map_local(O, Origin, Warps, Labels, Colors),
						halt
					);
					Graph = global -> (
						import_db(Data),
						(
							member(output(Of), Args), not(var(Of));
							Of = 'sectors.dot'
						),
						swritef(Og, '%w/%w', [MapDir, Of]), atom_string(O, Og),
						writef('\n-=-=-= Generating Universe Graph ::: %w =-=-=-\n', [O]),
						Graph = global, map_sectors(O, Labels, Colors),
						halt
					);
					(
						writef('unsupported graph type %w\n', [Graph]), halt
					)
				)
			)
		);
		( % report mode
			(member(report(Report), Args), not(var(Report))),
			(
				Supported = [pairs, routes, mapped, unmapped, boundary],
				member(Report, Supported), (
					member(data_dir(Data), Args),
					import_db(Data),
					format('~nGenerating ~w report:~n', [Report]),
					(
						Report = routes -> (
							(member(holds(Holds), Args); Holds = 1),
							(member(tpw(TPW), Args); TPW = 2),
							print_routes(Holds, TPW), halt
						);
						Report = pairs -> print_pairs(), halt;
						Report = mapped -> print_mapped(), halt;
						Report = unmapped -> print_unmapped(), halt;
						Report = boundary -> print_boundary(), halt
					)
				);
				format('Unsupported report type ~w, try --help~n', [Report]), halt
			)
		); % end reports
		( % help requested
			not(var(Help)),
			format('~nUsage:~n'),
			format('tw2k --help   [topic]~n'),
			format('tw2k --map    <mode>  [options]~n'),
			format('tw2k --report <mode>  [options]~n'),
			(
				Help = options -> (
					opt_help(OptSpec, HelpText),
					format('~nOptions:~n'),
					writes(HelpText),
					format('~n~nExamples:~n'),
					format('tw2k --map global -R neato #render a map of sectors using neato~n'),
					format('tw2k --report pairs #print a report of known trade pairs~n'),
					halt
				);
				(Help = maps; Help = map; Help = graph; Help = graph) -> (
					writes([
						'\n\n',
						'                      -=-=-=-= Map and Graph Modes =-=-=-=-                     \n',
						'+------------------------------------------------------------------------------+\n',
						'| global  : render a map of every sector in the database                       |\n',
						'|         : default output is maps/sectors.dot, maps/sectors.svg               |\n',
						'| example : to create a map of sector 1 (Sol system) and surroundings within 3 |\n',
						'|         : warps:                                                             |\n',
						'|         : tw2k --map local -O 1 -H 3                                         |\n',
						'|------------------------------------------------------------------------------|\n',
						'| local   : only render sectors within a number of warps of an origin sector   |\n',
						'|         : default output is maps/<origin>_<warps>.dot,                       |\n',
						'|         :                   maps/<origin>_<warps>.svg                        |\n',
						'| example : to create a map of sector 1 and surroundings within 3 warps:       |\n',
						'|         : tw2k --map local -O 1 -H 3                                         |\n',
						'| options : --origin   <int>       origin sector ID to start with (default 1)  |\n',
						'|         : --warps     <int>      max warps from origin (default 3)           |\n',
						'+------------------------------------------------------------------------------+\n',
						'\n',
						'                -=-=-=-= Options for all Maps & Graphs =-=-=-=-                 \n',
						'+------------------------------------------------------------------------------+\n',
						'| options : --renderer <renderer>   graphviz layout renderer to use            |\n',
						'|         :                         recommended: sfdp, fdp, neato              |\n',
						'|         :                         others     : dot, circo, twopi             |\n',
						'|         : --labels   <true|false> show or hide labels (default true)         |\n',
						'|         : --colors   <color mode> which color coding method to use:          |\n',
						'|         :                         normal     : color points of interest      |\n',
						'|         :                         region     : color by region               |\n',
						'+------------------------------------------------------------------------------+\n'
					]),
					halt
				);
				Help = reports -> (
					writes([
						'\n\n',
						'                         -=-=-=-= Report Modes =-=-=-=-                         \n',
						'+------------------------------------------------------------------------------+\n',
						'| mapped   : list all mapped sectors                                           |\n',
						'|------------------------------------------------------------------------------|\n',
						'| unmapped : list all mapped sectors                                           |\n',
						'|------------------------------------------------------------------------------|\n',
						'| boundary : list all sectors adjacent to a mapped sector, but themselves      |\n',
						'|          : unmapped                                                          |\n',
						'|------------------------------------------------------------------------------|\n',
						'| boundary : list all completely unknown sectors                               |\n',
						'|------------------------------------------------------------------------------|\n',
						'| pairs    : print a list of known trade pairs - adjacent ports with matched   |\n', 
						'|          : trades                                                            |\n',
						'| note     : built from list of ports stored in ports.csv, requires at least 2 |\n', 
						'|          : matching entries                                                  |\n',
						'|------------------------------------------------------------------------------|\n',
						'| routes   : print a list of trade routes - ports at any distance that have    |\n',
						'|          : matching buys and sells, sorted by profit per turn per unit sold. |\n',
						'| note     : built from list of ports in ports.csv and recorded trades in      |\n',
						'|          : trades.csv requires at least 2 matching trades and logs of        |\n',
						'|          : corresponding ports                                               |\n',
						'|          :                                                                   |\n',
						'| options  : --holds <number>  calculates total profit for full holds.         |\n',
						'| options  : --tpw   <number>  turns per warp (default 2)                      |\n',
						'+------------------------------------------------------------------------------+\n'
					]),
					halt
				);
				writes([
					'\nfor more info see:\n',
					'--help options\n',
					'--help maps\n',
					'--help graphs\n',
					'--help reports\n'
				])
			),
			halt
		); % end help
		( % interactive mode requested
			not(var(Interactive)),
			member(data_dir(Data), Args),
			writes(['Starting interactive mode...\n']),
			swritef(Cmd, 'swipl -f tw2k.pl -g "import_db(%w)"', [Data]),
			shell(Cmd)
		);
		(
			var(Interactive), var(Help),
			format('see --help for usage.\n'),
			halt
		)
). % end branch where OptSpec and opt_arguments is true
