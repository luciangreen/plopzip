% plopzip: compression where the decompressor is a set of per-character programs. A table of
% records (equal-length lists of digits) is stored as one small formula per column, in terms of
% the record's number K, plus a list of the cells the formula gets wrong. Columns that follow a
% pattern cost almost nothing; the rest fall back to exceptions, so decompressing always gives
% the table back exactly.
% Column formulas: const(C), k(A, B) meaning (A*K + B) mod 10.
%?- compress([[1,0],[1,1],[1,2]], Z).            % Z = zip(3, [const(1), k(1, 0)], [])
%?- decompress(zip(3, [const(1), k(1, 0)], []), T).
%?- size([[1,0],[1,1],[1,2]], S), compress([[1,0],[1,1],[1,2]], Z), zsize(Z, ZS).
:- module(plopzip, [col_value/3, compress/2, decompress/2, size/2, zsize/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

col_value(const(C), _, C).
col_value(k(A, B), K, V) :- V is (A * K + B) mod 10.

% best formula for a column: the one with the fewest wrong cells (simplest first on ties)
candidate(const(C)) :- between(0, 9, C).
candidate(k(A, B)) :- between(1, 9, A), between(0, 9, B).
wrong(F, Col, Ws) :- findall(K-V, ( nth0(K, Col, V), \+ col_value(F, K, V) ), Ws).
best(Col, F, Ws) :- findall(N-(G-W), ( candidate(G), wrong(G, Col, W), length(W, N) ), L), keysort(L, [_-(F-Ws)|_]).

columns(T, Cols) :- T = [R|_], length(R, W), ( W =:= 0 -> Cols = [] ; Top is W - 1, numlist(0, Top, Is), maplist([I, Col]>>maplist([Rec, X]>>nth0(I, Rec, X), T, Col), Is, Cols) ).

% compress(+Table, -zip(Rows, Formulas, Exceptions)); exceptions are cell(Row, Column, Value).
compress([], zip(0, [], [])) :- !.
compress(T, zip(N, Fs, Ex)) :- length(T, N), columns(T, Cols), length(Cols, W), ( W =:= 0 -> Is = [] ; Top is W - 1, numlist(0, Top, Is) ),
    maplist([Col, F, Ws]>>best(Col, F, Ws), Cols, Fs, Wss),
    findall(cell(K, I, V), ( nth0(I, Wss, Ws), member(K-V, Ws) ), Ex0), msort(Ex0, Ex), length(Is, W).

decompress(zip(N, Fs, Ex), T) :- ( N =:= 0 -> T = [] ; Top is N - 1, numlist(0, Top, Ks),
    maplist([K, Rec]>>( length(Fs, W), ( W =:= 0 -> Rec = [] ; Wt is W - 1, numlist(0, Wt, Is), maplist([I, V]>>( memberchk(cell(K, I, V0), Ex) -> V = V0 ; nth0(I, Fs, F), col_value(F, K, V) ), Is, Rec) ) ), Ks, T) ).

size(T, S) :- foldl([R, A, B]>>( length(R, L), B is A + L ), T, 0, S).
zsize(zip(_, Fs, Ex), S) :- length(Fs, A), length(Ex, B), S is 1 + A + 2 * B.
