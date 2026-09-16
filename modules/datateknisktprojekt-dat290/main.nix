{ ... }:
{
  perSystem = { self', ... }: {
    devShells.datateknisktprojekt-dat290 = self'.devShells.moppen-eda482;
    devShells.datateknisktprojekt = self'.devShells.datateknisktprojekt-dat290;
  };
}

