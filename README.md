# Test what does comparing `xxx = 0.1` do in different types

## The question and summary

The question that started all this:

"_What does this do? Does the condition below (`if`) evaluate to `true` or `false`?_"

```delphi
MyVar := 0.1;
if MyVar = 0.1 then
  Writeln('Yes, MyVar equals 0.1')
else
  Writeln('No, MyVar does not equal 0.1');
```

See the example source code [test_float_compare.dpr](test_float_compare.dpr) for the full Pascal code that compiles with both FPC and Delphi.

As you can see, I did not clarify the type of `MyVar` in the question above. Is it `Single`, `Double`, `Extended`, `Real`, `Currency` (this one is not actually a floating-point type), `Variant`? And what compiler do you use to test this -- [FPC](https://www.freepascal.org/) or [Delphi](https://www.embarcadero.com/products/delphi), in what version? And on what operating system and processor (which I commonly refer to as "platform")?

As the test in [test_float_compare.dpr (Pascal source code)](test_float_compare.dpr) shows, and as I explain below in this file, all above (`MyVar` type, compiler, platform) are critical to determine the answer.

If the explanation below is too complicated for you, and you want a quick (simplifying) summary, here goes: **Opeations on floating-point numbers are not precise, and this means that the comparison using `=` is not reliable for them. Instad of `=`, almost always use `SameValue` from `Math` unit to compare them, like `if SameValue(MyVar, 0.1) then ...`.**

## Results

Compile and run the test program [test_float_compare.dpr](test_float_compare.dpr) and observe the results.

Or open the files below with ready results from my tests. (You can open each result in a separate tab and jump between them (_Ctrl+Tab_ in most browsers) to visually compare.)

- [FPC 3.2.2 on Linux x86_64](result_fpc_322_linux-x86_64.txt)
- [FPC 3.2.2 on Win64 x86_64](result_fpc_322_win64-x86_64.txt)
- [Delphi 12 Win32](result_delphi_12_win32.txt)
- [Delphi 12 Win64](result_delphi_12_win64.txt)

As you can see, result is both compiler and system dependent. And the Pascal type used (`Single`, `Double` etc.) changes it too.

## Why?

### Comparison needs conversion

- The comparison `=` is true only if both sides are evaluated to the exact same value, exact same bits in memory.

    So the logic of `A = B` starts by converting one/both `A` and `B` to some "common" type, and then comparing them. What is this "common" type? The logic to determine this is compiler and platform-dependent (as these tests show).

    And conversions may change the value. Converting between different floating-point types definitely may change the value, e.g. cutting off digits that didn't "fit" in the target representation.

- In other words: Effectively, various compilers may treat the 2nd argument in `.. = 0.1`, as a different type. If it's a different type than 1st argument, then conversion is necessary, which will likely change the exact value (considered by `=`) of one side.

- The above observation leads also to one way to make the comparison more reliable:

    You can make the comparison reliable by explicitly making sure that both sides are of the same type. Comparisons using `=` with the exact same type (on both sides of the equation) are reliable, since there are no more conversions. E.g.

    ```delphi
    var
      MyVar: Single;
    begin
      MyVar := 0.1;
      if MyVar = Single(0.1) then
        Writeln('Yes, MyVar equals 0.1') // this is guaranteed
      else
        Writeln('No, MyVar does not equal 0.1');
    end;
    ```


### Some types have compiler/platform-dependent meaning

- Various types may have different precision, e.g. `Real` means various things depending on compiler/version. https://docwiki.embarcadero.com/RADStudio/Sydney/en/Simple_Types_(Delphi) . Now `Real` is equivalent to `Double` in latest Delphi, but it wasn't always like this.

- Interpretation of `Extended` is different between compilers and platforms. It's sometimes 8, sometimes 10, sometimes 16-byte value. See [Castle Game Engine coding conventions about Extended, Single, Double](https://castle-engine.io/coding_conventions#no_extended).

- Variant may also be converted to different things. As the test in this repo shows, doing `VarVariant := 0.1`...

    - with Delphi it results in `Variant` value that is internally stored using the ` Currency` type.

    - with FPC, the `Variant` value is stored using the `Double` type.

    Neither compiler is _"wrong"_ here, compilers have a freedom in what type to choose for `VarVariant := 0.1`, and the logic of it may depend on any number of factors (what is performant? on this platform? what can hold the resulting value? (e.g. `Currency` cannot hold too small values without just turning them into zero, but it's OK for `0.1`)).

### Floating-point numbers are not precise and 0.1 is not easy

- Value `0.1` is impossible to expess precisely for _base-2 floating point types_ (which means `Single`, `Double`, `Extended`, `Real`).

    `0.1` in base-10 has actually infinite number of digits in base-2, see [here](https://www.wolframalpha.com/input/?i=convert+0.1+to+base+2): `0.00011001100110011...`.

    So, it's rounded to the nearest representable value. This rounding is different for different types -- `Single` (4 bytes), `Double` (8 bytes), `Extended` and `Real` (various meaning depending on compiler and system) all express `0.1` differently. And none of them gets is precisely right.

### Overview: how can we encode non-integer numbers in computers?

There are generally 2 ways:

1. Fixed-point types, like `Currency`, allocate fixed precision (fixed amount of digits in base-2) to the fractional part.

    `Currency` is just "value times `10000`, stored as an integer".

    This is great when you want to express e.g. `0.01` precisely, and generally do precise calculations with money, hence the name `Currency`.

    But numbers smaller than 1/10000 have no chance -- there is no way to express them.

2. Floating-point types, like `Single`, `Double`, `Extended`, `Real`, store separate mantissa and exponent, i.e. the number and the power of the base (like 10 or 2).

    [Wikipedia page about floating-point arithmetic](https://en.wikipedia.org/wiki/Floating-point_arithmetic) explains the details. Note that Wikipedia page shows early an example expressig the number as _"something * 10^exponent"_, but in computers everything is base-2, so `Single` and `Double` are actually expressed as _"something * 2^exponent"_. As a result, very small numbers can be expressed, and very large numbers too -- the range is much much larger than `Currency`, but also the precision is not "uniform".

    E.g. you cannot express `0.1` exactly (because the fractional part for `0.1` in base-2 is infinite, see https://www.wolframalpha.com/input/?i=convert+0.1+to+base+2 . So both `Single` and `Double` express `0.1` differently, and none of the versions is exact.

    _The above 2 solutions are practical when you need fast calculations, and you can tolerate some limitations and (in case of floating-point) imprecision._

3. There are also solutions when you really need precision, and more flexibility than `Currency`, and can tolerate slower calculations. Most importantly, There are _arbitrary-precision arithmetic libraries_. See e.g.:

    - not Pascal-specific:
        - https://gmplib.org/
        - https://www.mpfr.org/
        - https://speleotrove.com/decimal/decnumber.html
    - Pascal-specific:
        - http://rvelthuis.de/programs/bigintegers.html
        - https://github.com/Xor-el/DelphiBigNumberXLib

### Any summary "what to do" for developers?

All of this, in short, is a reason to use `SameValue` from Math, not `=`.

Don't assume strict equality (`=`) of floating-point numbers that went through some calculations and/or conversions.

The exceptional moments when `=` for floating-point numbers is reliable are implied by the above explanations. E.g.:

- If you have both variables of the same type (like `Single`), and you explicitly assigned to them the same constant, then they are reliably equal. Like

    ```delphi
    var
      OneSingle, SecondSingle: Single;
    begin
      OneSingle := 0.1;
      SecondSingle := 0.1;
      if OneSingle = SecondSingle then
        Writeln('Yes, OneSingle equals SecondSingle') // this is guaranteed
      else
        Writeln('No, OneSingle does not equal SecondSingle');
    end;
    ```

- The example with `MyVar = Single(0.1)` from above is also reliable, and actually equivalent to above.

- Using `Currency` is also precise (for calculations and comparisons using `=`) but only if you stay within the range of `Currency` (i.e. never go below 1/10000).

    The `Currency` is not a floating-point type, it's fixed-point. We discussed it above as it is another way to express non-integer numbers in computers, so it's worth noting how it compares.

## Credits

This lengthy explanation was written by [Michalis Kamburelis](https://michalis.xyz/).

Feel free to spread around ([permissive modified BSD (3-clause)](LICENSE)).