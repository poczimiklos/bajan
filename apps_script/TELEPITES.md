# E app ↔ Google Sheets – telepítés (kb. 5 perc)

1. Nyisd meg a táblázatot → **Kiterjesztések → Apps Script**.
2. Hozz létre két fájlt: `Code.gs` és `Parser.gs`, és másold be a tartalmukat
   (a `Code.gs` az alap fájl, a `Parser.gs` új fájl). Opcionális: Projektbeállítások → „appsscript.json megjelenítése" és ide is másold be az `appsscript.json`-t (időzóna: Budapest).
3. Futtasd a **`setup`** függvényt (Futtatás gomb). Engedélyezd a hozzáférést. Létrejön a `Napló`, `Edzések` és `Check-in` fül, és a Naplóban (Végrehajtás napló) megjelenik a **token**. Ha a táblázatból futtatod a menüt (E app → Beállítás), ablakban is kiírja.
4. **Üzembe helyezés → Új üzembe helyezés → Webalkalmazás**: Futtatás: *Én*, Hozzáférés: *Bárki*. Másold ki a **webalkalmazás URL**-t (…/exec).
5. Az appban: **Profil → Google Sheets**: URL + token → *Mentés és szinkron*.

Új blokk: hozz létre egy új fület `Block-2` néven (a Block-1 fül másolata), és az app magától felveszi. A mai napot tartalmazó blokk lesz az aktív.

Megjegyzés a `suly` oszlophoz: szám (`190`, `107,5`), tartomány (`197,5-200`), `max`, `m+5`, RPE (`@8`, `rpe 8`, `R8`), vagy kombináció (`190 @8`). A `megjegyzes` oszlop elejére írt `top` / `backoff` megjelöli a szett típusát.
