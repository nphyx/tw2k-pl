% TW2K: a utility program for TradeWars 2002
?- use_module(library(optparse)).
:- [lib/dynamics].
:- [lib/util].
:- [lib/storage].
:- [lib/data].
:- [lib/reports].
:- [lib/mapping].

main:-
	(
		OptSpec = [
			[
				opt(help), type(boolean),
				shortflags([h]), longflags(['help']),
				help('print help')
			],
			[
				opt(graph), type(atom),
				shortflags([g]), longflags(['graph']),
				help(['generate a sector graph and build a dot from it',
					'- see Map and Graph modes'
				])
			],
			[
				opt(map), type(atom),
				shortflags([m]), longflags(['map']),
				help(['generate a graph and build an svg map from it',
					'- imples --graph',
					'- requires graphviz installed on your system',
					'- see Map and Graph modes'
				])
			],
			[
				opt(output), type(atom), default('maps/sectors.dot'),
				shortflags([o]), longflags(['output']),
				help(['set output graphviz dot file (used with --graph and --map)'])
			],
			[
				opt(image), type(atom), default('maps/sectors.svg'),
				shortflags([i]), longflags(['image']),
				help(['set output image file (used with --graph and --map)'])
			],
			[
				opt(colors), type(atom), default('normal'),
				shortflags(['C']), longflags(['colors']),
				help(['color mode for maps and graphs, <normal|regions>'])
			],
			[
				opt(labels), type(boolean), default(true),
				shortflags(['l']), longflags(['labels']),
				help(['label sectors'])
			],
			[
				opt(hops), type(integer), default(3),
				shortflags(['H']), longflags(['hops']),
				help(['hop limit for local maps'])
			],
			[
				opt(origin), type(integer), default(1),
				shortflags(['O']), longflags(['origin']),
				help(['origin for local maps'])
			],
			[
				opt(gvcmd), type(atom), default('sfdp'),
				shortflags(['R']), longflags(['renderer']),
				help(['graphviz image renderer to use',
					'- used with --map',
					'- best options are neato, fdp, and sfdp; try your luck with the others'
				])
			],
			[
				opt(report), type(atom),
				shortflags(['r']), longflags(['report']),
				help(['print a report, modes:',
					'  pairs:  print pairs of adjacent ports with matching trades',
					'  routes: print all trade routes - ports with matching trades at any distance',
					'          sorted by profit-per-hop per unit (see holds)'
				])
			],
			[
				opt(holds), type(integer), default(1),
				shortflags([]), longflags(['holds']),
				help(['when used with reporting, multiply per-unit value by number of holds'])
			],
			[
				opt(data_dir), type(atom), default('data'),
				shortflags([d]), longflags(['data-dir']),
				help(['set the directory to load data from'])
			]
		],
		opt_arguments(OptSpec, Args, _),
		(
			( % map mode
				member(data_dir(Data), Args),
				(member(map(Map), Args), not(var(Map))),
				member(labels(Labels), Args),
				member(colors(Colors), Args),
				member(output(O), Args),
				member(image(I), Args),
				member(gvcmd(GvCmd), Args),
				format('Generating map at ~w, graph at ~w, mode: ~w~n', [I, O, Map]),
				swritef(Cmd, '%w -Tsvg -o %w %w', [GvCmd, I, O]),
				import_db(Data),
				writef('Generating graph...\n'),
				(
					(
						Map = normal, map_sectors(O, Labels, Colors);
						(
							Map = local,
							member(hops(Hops), Args),
							member(origin(Origin), Args),
							map_local(O, Origin, Hops, Labels, Colors)
						)
					),
					writef('Generating image...\n'), shell(Cmd), halt
				)
			);
			( % graph mode
				member(data_dir(Data), Args),
				(member(graph(Graph), Args), not(var(Graph))),
				member(labels(Labels), Args),
				member(colors(Colors), Args),
				(member(output(O), Args); O = 'data/sectors.dot'),
				format('Generating graph at ~w, mode: ~w\n', [O, Graph]),
				import_db(Data),
				writef('Generating graph...\n'),
				(
					(
						Graph = normal, map_sectors(O, Labels, Colors);
						(
							Graph = local,
							member(hops(Hops), Args),
							member(origin(Origin), Args),
							map_local(O, Origin, Hops, Labels, Colors)
						)
					)
				),
				halt
			);
			( % report mode
				member(report(Report), Args),
				not(var(Report)),
				once((
					(
						member(data_dir(Data), Args),
						(Report = pairs; Report = routes),
						(member(holds(Holds), Args); Holds = 1),
						import_db(Data),
						format('~nGenerating ~w report:~n', [Report]),
						(
							Report = pairs, print_pairs();
							Report = routes, print_routes(1)
						),
						halt
					);
					format('Unsupported report type ~w, try --help~n', [Report]),
					halt
				))
			);
			(
				member(help(_), Args),
				opt_help(OptSpec, HelpText),
				format('TW2K - A TradeWars 2002 utility~n'),
				format('~nUsage:~n'),
				format('tw2k [options]~n'),
				format('~nExamples:~n'),
				format('tw2k --map normal -R neato #render a map of sectors using neato~n'),
				format('tw2k --report pairs #print a report of known trade pairs~n'),
				format('~nOptions:~n'),
				format('~w\n', [HelpText]),
				format('Map and Graph Modes:~n~w~n~w~n~w~n', [
					'  normal: a graph with color-coded points of interest',
					'  local:  only render sectors within a number of hops of an origin sector (see --hops, --origin)',
					'  secret: a graph with all the labels hidden, for showing off without sharing'
				]),
				halt
			)
		)
	); % end branch where OptSpec and opt_arguments is true
	(
		format('see --help for usage.\n'),
		halt
	).
