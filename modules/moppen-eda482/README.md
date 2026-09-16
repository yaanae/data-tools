# Konfigurationer för Moppen (EDA482)
Maskinorenterad Programmering (EDA482) använder sig att alldeles underbar programvara,
delar utvecklad/distibuterad av GBGMV, och delar som VSCode plugin.

Här gillar vi inte VSCode, så det blir att reverse-engineera alltihop. Detta är ett
sådant försök.

## Att utveckla med dessa verktyg
Kör `nix develop github:yaanae/data-tools#moppen` för att komma igång.

Det första du vill göra är att köra `mdx07-init` vilket är ett litet `bash`-skript
som initialiserar ditt projekt med en template. Gör detta i en tom mapp.

Sedan kan du öppna upp relevanta källkodsfiler med `nvim`.

Vad vi vill börja med är att starta `simserver`, simulationsvaran för
`mdx07`-system. Öppna i normalmode med `<space>a`. Passa även på att köra
`make`.

Nu kan vi öppna debugmenyerna, använd `<space>dt`. För att köra eller debugga
programmet, trycker du på kör-knappen grafiskt, eller kallar `:DapNew`.

Jag orkar inte skriva alla keybinds, men vi har `which-key` så det är lätt
att upptäcka dem. Kika särskilt på `<space>d` och `<space>t`.

Om du vill läsa från minnet får du göra det direkt mot `gdb`. I fönstret
direkt under koden, `dap-repl`, så kan du skriva `gdb` kommandon.
I detta fallet är `x` kommandot eller varianter mest användbara.
Testa `x/8xb 0x20001000` för första övningen i kursen.
