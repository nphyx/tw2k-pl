/*
 * Borrowed from Rossetta Code.
 */
:-dynamic
  rpath/2.      % A reversed path

:-dynamic
  edge/3.       % supplied later
:-dynamic
	path/3.       % supplied by data.pl

% path(From,To,Dist) :- links_from_to(From,To,Dist).

shorterPath([H|Path], Dist) :-           % path < stored path? replace it
  rpath([H|_], D), !, Dist < D,          % match target node [H|_]
  retract(rpath([H|_],_)),
  % writef('%w is closer than %w\n', [[H|Path], [H|T]]),
  assert(rpath([H|Path], Dist)).

shorterPath(Path, Dist) :-           % Otherwise store a new path
  % writef('New path:%w\n', [Path]),
  assert(rpath(Path,Dist)).

traverse(From, Path, Dist) :-          % traverse all reachable nodes
  path(From, T, D),                    % For each neighbor
  not(memberchk(T, Path)),             %  which is unvisited
  shorterPath([T,From|Path], Dist+D),  %  Update shortest path and distance
  traverse(T,[From|Path],Dist+D).      %  Then traverse the neighbor

traverse(From) :-
  retractall(rpath(_,_)),           % Remove solutions
  traverse(From,[],0).              % Traverse from origin
  traverse(_).

go_path(From, To, Path, Distance) :-
  traverse(From),                   % Find all distances
  rpath([To|RPath], Dist)->         % If the target was reached
  reverse([To|RPath], Path),        % Report the path and distance
  Distance is round(Dist).
  % writef('Shortest path is %w with distance %w = %w\n', [Path, Dist, Distance]);
  % writef('There is no route from %w to %w\n', [From, To]).

go(From, To, Distance) :- go_path(From, To, _, Distance).
