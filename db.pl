/**
Project: FLP kostra grafu
Author: Adam Rybanský
Login" xryban00
*/


/** functions for some basic list operations */


not_member(X, List) :- \+member(X,List).

list_equal(X, Y) :- subtract(X, Y, []), subtract(Y, X, []).

list_member(X,[X|_]).
list_member(X,[_|TAIL]) :- list_member(X,TAIL).
list_append(A,T,T) :- list_member(A,T),!.
list_append(A,T,[A|T]).

list_create(A,[A]).
list_create(A,B,[A,B]).






/** functions that print output in correct format */

process_line([H]) :-
  nth0(0,H,X),
  nth0(1,H,Y),
  write(X),
  write('-'),
  write(Y),
  write(' '),
  nl.

process_line([H|T]) :-
  nth0(0,H,X),
  nth0(1,H,Y),
  write(X),
  write('-'),
  write(Y),
  write(' '),
  process_line(T).

process_output([]).
process_output([H]) :- process_line(H).
process_output([H|T]) :-
  process_line(H),
  process_output(T).
  
  
  
  
  
  
  
/** functions for the algorithm */

is_directly_connected(X,Y, Edges) :-      % function to out if there is and edge between the vertices X and Y
   list_create(X,Bracket1),
   list_create(Y,Bracket2),
   list_create(Bracket1,Bracket2,Item1),
   member(Item1,Edges); 
   list_create(X,Bracket1),
   list_create(Y,Bracket2),
   list_create(Bracket2,Bracket1,Item2),
   member(Item2,Edges).

create_skelet(Vertices,Edges,[], Skelet, Retval) :-       % initial call of create_skelet(), chooses an random Vertice and marks it as Visited.
  member(X, Vertices),  
  create_skelet(Vertices,Edges,[X], Skelet, Retval).
  
create_skelet(Vertices,_, Visited, Skelet, Retval) :-     % final call of create_skelet(), returns the created Skelet, if all Vertices are Visited
  list_equal(Vertices, Visited),
  sort(Skelet,Sorted_skelet),                         
  list_create(Sorted_skelet,TempRetval),
  nth0(0,TempRetval,Retval),
  !.
  
create_skelet(Vertices,Edges, Visited, Skelet, Retval) :-  % main call of create_skelet(), finds a Vertice that is not yet Visited but is conected to a Vertice from the Visited list.
  member(X,Vertices),                                      % Then, add an Edge between the new Vertice and the Visited Vertice to the Skelet, and call this function again. 
  not_member(X,Visited),
  member(Y,Visited), 
  is_directly_connected(X,Y,Edges),
  list_append(X,Visited, Visited_after), 
  Unsorted_edge = [X,Y],
  sort(Unsorted_edge,Sorted_edge),
  list_append(Sorted_edge,Skelet,NewSkelet),
  create_skelet(Vertices,Edges,Visited_after, NewSkelet, Retval).
  
launch(Vertices,Edges, Output) :- 
  findall(Retval,create_skelet(Vertices,Edges,[],[], Retval), Skelets),
  sort(Skelets,Output).                     
                
                
                
                
                
                              
                              
/** function that initializes list of verices */

init_vertices([H], Vertices, Retval) :-
  nth0(0,H,TempX),
  nth0(1,H,TempY),
  nth0(0,TempX,X),
  nth0(0,TempY,Y),
  list_append(Y, Vertices, Vertices_after1), 
  list_append(X, Vertices_after1, Vertices_after2),
  sort(Vertices_after2,Retval).

init_vertices([H|T], Vertices, Retval) :-
  nth0(0,H,TempX),
  nth0(1,H,TempY),
  nth0(0,TempX,X),
  nth0(0,TempY,Y),
  list_append(Y, Vertices, Vertices_after1), 
  list_append(X, Vertices_after1, Vertices_after2),
  init_vertices(T,Vertices_after2,Retval).
  
  
  
  
 /** functions that process, parse and store input. Based on the input2.pl file from document server */ 
  

read_line(Input, L, C) :-
	get_char(Input, C),
	(isEOFEOL(C), L = [], !;
		read_line(Input, LL,_),% atom_codes(C,[Cd]),write(),nl
		[C|LL] = L).


isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Input, Ls) :-
	read_line(Input, L, C),
	( C == end_of_file, Ls = [] ;
	  read_lines(Input, LLs), Ls = [L|LLs]
	).


split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1


split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).




/** the program */

start :-
current_prolog_flag(argv, [File | _]),            % get the list of edges from input file
    open(File, read, Input_stream),
    read_lines(Input_stream, LL),
    close(Input_stream),
    split_lines(LL,Split),
    sort(Split,Edges),
    init_vertices(Edges,[], Vertices),            % create the list of vertices
    launch(Vertices, Edges, Output),              % run the algorithm
    process_output(Output),                       % print the output
		halt.