{ Test what does comparing "xxx = 0.1" do in different types.
  See README.md in https://github.com/michaliskambi/test-float-compare
  for description. }

{$apptype CONSOLE}
{$ifdef FPC}
  {$mode delphi}
{$endif}
uses SysUtils, Variants;
var
  VarCurrency: Single;
  VarVariant: Variant;
  VarReal: Real;
  VarSingle: Single;
  VarDouble: Double;
begin
  VarCurrency := 0.1;
  Writeln('Currency? ', FloatToStr(VarCurrency), ' ', VarCurrency = 0.1);
  VarVariant := 0.1;
  Writeln('Variant? ', FloatToStr(VarVariant), ' ', VarVariant = 0.1);
  Writeln('  Variant type: ',VarTypeAsText(VarType(VarVariant)));
  VarReal := 0.1;
  Writeln('Real? ', FloatToStr(VarReal), ' ', VarReal = 0.1);
  VarSingle := 0.1;
  Writeln('Single? ', FloatToStr(VarSingle), ' ', VarSingle = 0.1);
  VarDouble := 0.1;
  Writeln('Double? ', FloatToStr(VarDouble), ' ', VarDouble = 0.1);

  Writeln;
  Writeln('Same thing, but force 2nd comparison argument to be Single');
  VarCurrency := 0.1;
  Writeln('Currency? ', FloatToStr(VarCurrency), ' ', VarCurrency = Single(0.1));
  VarVariant := 0.1;
  Writeln('Variant? ', FloatToStr(VarVariant), ' ', VarVariant = Single(0.1));
  Writeln('  Variant type: ',VarTypeAsText(VarType(VarVariant)));
  VarReal := 0.1;
  Writeln('Real? ', FloatToStr(VarReal), ' ', VarReal = Single(0.1));
  VarSingle := 0.1;
  Writeln('Single? ', FloatToStr(VarSingle), ' ', VarSingle = Single(0.1));
  VarDouble := 0.1;
  Writeln('Double? ', FloatToStr(VarDouble), ' ', VarDouble = Single(0.1));

  Writeln;
  Writeln('Same thing, but force 2nd comparison argument to be Double');
  VarCurrency := 0.1;
  Writeln('Currency? ', FloatToStr(VarCurrency), ' ', VarCurrency = Double(0.1));
  VarVariant := 0.1;
  Writeln('Variant? ', FloatToStr(VarVariant), ' ', VarVariant = Double(0.1));
  Writeln('  Variant type: ',VarTypeAsText(VarType(VarVariant)));
  VarReal := 0.1;
  Writeln('Real? ', FloatToStr(VarReal), ' ', VarReal = Double(0.1));
  VarSingle := 0.1;
  Writeln('Single? ', FloatToStr(VarSingle), ' ', VarSingle = Double(0.1));
  VarDouble := 0.1;
  Writeln('Double? ', FloatToStr(VarDouble), ' ', VarDouble = Double(0.1));
end.
