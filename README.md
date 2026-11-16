# plopzip

compression where the decompressor is a set of per-character programs. A table of records (equal-length lists of digits) is stored as one small formula per column, in terms of the record's number K, plus a list of the cells the formula gets wrong. Columns that follow a pattern cost almost nothing; the rest fall back to exceptions, so decompressing always gives the table back exactly. Column formulas: const(C), k(A, B) meaning (A*K + B) mod 10.

## Use

```prolog
?- use_module(prolog/plopzip).
?- compress([[1,0],[1,1],[1,2]], Z).            % Z = zip(3, [const(1), k(1, 0)], [])
?- decompress(zip(3, [const(1), k(1, 0)], []), T).
?- size([[1,0],[1,1],[1,2]], S), compress([[1,0],[1,1],[1,2]], Z), zsize(Z, ZS).
```

## Proofs

`proofs/theorems.pl` proves 4 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every table of 1..3 records of width 1 or 2 over digits 0..2.

1. Decompressing gives the table back exactly.
2. A table whose columns follow formulas compresses with no exceptions.
3. Exceptions are only the cells the formulas get wrong, and each is right.
4. compress is a function.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
