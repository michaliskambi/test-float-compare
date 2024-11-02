# Test what does comparing `xxx = 0.1` do in different types

What does

```delphi
  MyVar := 0.1;
  if VarCurrency = 0.1 then
    ...
```

do?

Result is both compiler and system dependent, because:

- Various compilers may treat the 2nd argument in `.. = 0.1`, as a different type. If it's a different type than 1st argument, then conversion is necessary, which will likely change the exact value (considered by `=`) of one side.

    The `=` is true only if both sides are evaluated to the exact same value.

    You can influence this factor by explicitly requesting the 2nd argument type, like `... = Single(0.1)` or `... = Double(0.1)`. See the test code, and how it changes the results. Then at least comparisons with the exact same type (`VarSingle = Single(0.1)`, `VarDouble = Double(0.1)`) will be reliably `true`.

- Also, various types may have different precision, e.g. Real means various things depending on compiler/version. https://docwiki.embarcadero.com/RADStudio/Sydney/en/Simple_Types_(Delphi) Now Real is equivalent to Double in latest Delphi, but it wasn't always like this.

- Variant may also be converted to different things. As you can see below, `VarVariant := 0.1` with Delphi results in Variant of type Currency. With FPC, it results in Variant of type Double.

- In all of this, value `0.1` is not easy to expess for _base-2 floating point types_ (which means `Single`, `Double`, `Extended`, `Real`). `0.1` in base-10 has actually infinite number of digits in base-2, see [here](https://www.wolframalpha.com/input/?i=convert+0.1+to+base+2). So, it's rounded to the nearest representable value. This rounding is different for different types -- `Single` (4 bytes), `Double` (8 bytes), `Extended` and `Real` (various meaning depending on compiler and system) all express `0.1` differently. And none of them gets is precisely right.

All of this is, in short, a reason to use `SameValue` from Math, not `=`.

Don't assume strict equality of floating-point numbers (unless in special controlled situations, e.g. `OneSingle:=0.1; SecondSingle:=0.1;`, then you can be sure `OneSingle = SecondSingle` exactly).

## Results

- [FPC 3.2.2 on Linux x86_64](result_fpc_322_linux-x86_64.txt)
- [FPC 3.2.2 on Win64 x86_64](result_fpc_322_win64-x86_64.txt)
- [Delphi 12 Win32](result_delphi_12_win32.txt)
- [Delphi 12 Win64](result_delphi_12_win64.txt)
