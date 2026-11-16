:- module(cases, [title/1, case/3]).
:- use_module('../prolog/plopzip').
:- use_module(engine).
title('plopzip').
table_g(T) :- rnd_int(1, 8, N), rnd_int(1, 4, W), length(Fs, W), maplist([F]>>( rnd_int(0, 9, C), rnd_int(1, 9, A), rnd_int(0, 9, B), rnd_pick([const(C), k(A, B)], F) ), Fs),
    decompress(zip(N, Fs, []), T0), maplist([R0, R]>>maplist([X0, X]>>( rnd_chance(10) -> rnd_int(0, 9, X) ; X = X0 ), R0, R), T0, T).
case(compress, [T], compress) :- table_g(T).
case(sizes, [T], sizes) :- table_g(T).
case(decompress, [Z], decompress) :- table_g(T), compress(T, Z).
sizes(T, raw(S)-zipped(Z)) :- size(T, S), compress(T, C), zsize(C, Z).
