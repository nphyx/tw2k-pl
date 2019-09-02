:- module(graph, [writes_graph_header/1]).

writes_graph_header(Name):-
	writes(['digraph "', Name, '" {']),
	writes(['graph [overlap=false fontname="Fira Sans" splines=true bgcolor="#111111" pack=20 packmode="node"];']),
	writes(['node [shape=circle fontname="Fira Sans" fontcolor="#eeeeee" fillcolor="#111111" fontsize=10 style=filled width=0.35 height=0.35 color="#eeeeee" regular=true fixedsize=true];']),
	writes(['edge [color="#bbbbbb" fontname="Fira Sans" fontsize=10 fontcolor="#88ee88"];\n']).
