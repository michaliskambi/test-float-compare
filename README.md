# Test what does comparing `xxx = 0.1` do in different types

What does this do? Is the condition true or false?

```delphi
MyVar := 0.1;
if VarCurrency = 0.1 then
  ...
```

See the example source code `test_float_compare.dpr` for the full exact code.

## Results

- [FPC 3.2.2 on Linux x86_64](result_fpc_322_linux-x86_64.txt)
- [FPC 3.2.2 on Win64 x86_64](result_fpc_322_win64-x86_64.txt)
- [Delphi 12 Win32](result_delphi_12_win32.txt)
- [Delphi 12 Win64](result_delphi_12_win64.txt)

As you can see, result is both compiler and system dependent.

## Why?

### Comparison needs conversion

- The comparison `=` is true only if both sides are evaluated to the exact same value, exact same bits in memory.

    So the logic of `A = B` starts by converting one/both `A` and `B` to some "common" type, and then comparing them. What is this "common" type? The logic to determine this is compiler and platform-dependent (as these tests show).

    And conversions may change the value -- it certainly does for different floating-point types.

- In other words: Effectively, various compilers may treat the 2nd argument in `.. = 0.1`, as a different type. If it's a different type than 1st argument, then conversion is necessary, which will likely change the exact value (considered by `=`) of one side.

- You can influence (counter) this uncertainty by explicitly requesting the 2nd argument type, like `... = Single(0.1)` or `... = Double(0.1)`. See the test code, and how it changes the results. Then at least comparisons with the exact same type (`VarSingle = Single(0.1)`, `VarDouble = Double(0.1)`) will be reliably `true`.

### Some types have compiler/platform-dependent meaning

- Various types may have different precision, e.g. `Real` means various things depending on compiler/version. https://docwiki.embarcadero.com/RADStudio/Sydney/en/Simple_Types_(Delphi) . Now `Real` is equivalent to `Double` in latest Delphi, but it wasn't always like this.

- Interpretation of `Extended` is different between compilers and platforms. It's sometimes 8, sometimes 10, sometimes 16-byte value. See [Castle Game Engine coding conventions about Extended, Single, Double](https://castle-engine.io/coding_conventions#no_extended).

- Variant may also be converted to different things. As the test in this repo shows, `VarVariant := 0.1` with Delphi results in Variant of type Currency. With FPC, it results in Variant of type Double.

### Floating-point numbers are not precise and 0.1 is not easy

- In all of this, value `0.1` is not easy to expess for _base-2 floating point types_ (which means `Single`, `Double`, `Extended`, `Real`). `0.1` in base-10 has actually infinite number of digits in base-2, see [here](https://www.wolframalpha.com/input/?i=convert+0.1+to+base+2). So, it's rounded to the nearest representable value. This rounding is different for different types -- `Single` (4 bytes), `Double` (8 bytes), `Extended` and `Real` (various meaning depending on compiler and system) all express `0.1` differently. And none of them gets is precisely right.

### Overview: how can we encode non-integer numbers in computers?

There are generally 2 ways:

1. Fixed-point types, like `Currency`, allocate fixed precision to the fractional part.

    `Currency` is just "value times `10000`, stored as integer".

    This is great when you want to express e.g. `0.01` precisely, and generally do precise calculations with money, hence the name `Currency`.

    But numbers smaller than 1/10000 have no chance -- there is no way to express them.

2. Floating-point types, like `Single`, `Double`, `Extended`, `Real`, store separate mantissa and exponent, i.e. the number and the power of the base (like 10 or 2).

    Wikipedia https://en.wikipedia.org/wiki/Floating-point_arithmetic describes it as _"something * 10^exponent"_, but it's a bit misleading because in computers everything is power of 2, so `Single` and `Double` are actually expressed as _"something * 2^exponent"_. As a result, very small numbers can be expressed, and very large numbers too -- the range is much much larger than `Currency`, but also the precision is not "uniform".

    E.g. you cannot express `0.1` exactly (because the fractional part for `0.1` in base-2 is infinite, see https://www.wolframalpha.com/input/?i=convert+0.1+to+base+2 . So both `Single` and `Double` express `0.1` differently, and none of the versions is exact.

The above 2 solutions are practical when you need fast calculations, and you can tolerate some limitations and (in case of floating-point) imprecision. Of course there are also solutions when you really need precision, and more flexibility than `Currency`, and can tolerate slower calculations. There are arbitrary-precision arithmetic libraries. See https://gmplib.org/ ,
https://www.mpfr.org/ , https://speleotrove.com/decimal/decnumber.html (not Pascal-specific) or http://rvelthuis.de/programs/bigintegers.html , https://github.com/Xor-el/DelphiBigNumberXLib (Pascal-specific).

### As a developer, any summary "what to do"?

All of this is, in short, a reason to use `SameValue` from Math, not `=`.

Don't assume strict equality of floating-point numbers (unless in special controlled situations, e.g. `OneSingle:=0.1; SecondSingle:=0.1;`, then you can be sure `OneSingle = SecondSingle` exactly).

