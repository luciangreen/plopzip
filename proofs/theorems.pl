% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/plopzip').

% Domain: every table of 1..3 records of width 1 or 2 over digits 0..2.
table(T) :- between(1, 3, N), member(W, [1, 2]), length(T, N), maplist([R]>>( length(R, W), maplist([X]>>between(0, 2, X), R) ), T).

% 1. Decompressing gives the table back exactly.
theorem(round_trip) :- forall(table(T), ( compress(T, Z), decompress(Z, T2), T2 == T )).

% 2. A table whose columns follow formulas compresses with no exceptions.
theorem(patterned_tables_have_no_exceptions) :- forall(( member(N, [2, 5, 9]), member(Fs, [[const(4)], [k(1, 0), const(7)], [k(3, 2), k(1, 9)]]) ),
    ( decompress(zip(N, Fs, []), T), compress(T, zip(N, _, Ex)), Ex == [] )).

% 3. Exceptions are only the cells the formulas get wrong, and each is right.
theorem(exceptions_are_minimal_and_right) :- forall(( table(T), compress(T, zip(_, Fs, Ex)), member(cell(K, I, V), Ex) ), ( nth0(K, T, R), nth0(I, R, V), nth0(I, Fs, F), \+ col_value(F, K, V) )).

% 4. compress is a function.
theorem(compress_is_a_function) :- forall(table(T), findall(Z, compress(T, Z), [_])).
