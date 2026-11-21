/**
 * Block-N fül feldolgozása JSON-ná. Tiszta JS, nincs benne SpreadsheetApp,
 * ezért Node-ban is tesztelhető. Az Apps Script ugyanezt a fájlt használja.
 *
 * Elrendezés (a te táblázatod alapján):
 *  - minden edzésnap egy vízszintes sáv: a hetek egymás mellett, 10 oszloponként
 *  - sáv 1. sora:  "1. hét · 2026.10.20."  (hét címke + dátum)
 *  - sáv 2. sora:  napnév | set | ism | suly | megjegyzes   (fejléc)
 *  - utána gyakorlat sorok: név (A-D) | set (E) | ism (F) | suly (G-H) | megjegyzes (I)
 */
var WEEK_RE = /^\s*(\d+)\.\s*hét\s*[·\-–]\s*(\d{4})\.\s*(\d{1,2})\.\s*(\d{1,2})\.?/i;

function pad2_(n) { return (n < 10 ? '0' : '') + n; }

function cell_(grid, r, c) {
  var row = grid[r];
  if (!row || c >= row.length || row[c] === null || row[c] === undefined) return '';
  return String(row[c]).trim();
}

/** Napnév -> hétköznap (1 = hétfő ... 7 = vasárnap), a dátumból. */
function weekdayOf_(y, m, d) {
  var js = new Date(Date.UTC(y, m - 1, d)).getUTCDay(); // 0 = vasárnap
  return js === 0 ? 7 : js;
}

function findHeaderCols_(grid, r, c0) {
  // alapértelmezett eltolások: set=4, ism=5, suly=6, megjegyzes=8
  var out = { set: c0 + 4, reps: c0 + 5, load: c0 + 6, note: c0 + 8 };
  for (var c = c0; c < c0 + 10; c++) {
    var t = cell_(grid, r, c).toLowerCase();
    if (t === 'set') out.set = c;
    else if (t === 'ism') out.reps = c;
    else if (t === 'suly' || t === 'súly') out.load = c;
    else if (t.indexOf('megjegyz') === 0) out.note = c;
  }
  return out;
}

function parsePlan(grid, sheetName) {
  // 1) hét-címkék keresése
  var labels = [];
  for (var r = 0; r < grid.length; r++) {
    var row = grid[r] || [];
    for (var c = 0; c < row.length; c++) {
      var m = WEEK_RE.exec(cell_(grid, r, c));
      if (m) {
        labels.push({
          r: r, c: c, week: parseInt(m[1], 10) - 1,
          y: parseInt(m[2], 10), mo: parseInt(m[3], 10), d: parseInt(m[4], 10)
        });
      }
    }
  }
  // 2) napsávok = ugyanabban a sorban lévő címkék
  var byRow = {};
  labels.forEach(function (l) { (byRow[l.r] = byRow[l.r] || []).push(l); });
  var rows = Object.keys(byRow).map(Number).sort(function (a, b) { return a - b; });

  var maxWeek = 0;
  var days = [];
  rows.forEach(function (r0, dayIndex) {
    var ls = byRow[r0].slice().sort(function (a, b) { return a.c - b.c; });
    var first = ls[0];
    var dayName = cell_(grid, r0 + 1, first.c) || ('Nap ' + (dayIndex + 1));
    var weekday = weekdayOf_(first.y, first.mo, first.d);

    var perWeek = ls.map(function (l) {
      maxWeek = Math.max(maxWeek, l.week);
      return {
        week: l.week, c: l.c,
        date: l.y + '-' + pad2_(l.mo) + '-' + pad2_(l.d),
        cols: findHeaderCols_(grid, r0 + 1, l.c)
      };
    });

    // gyakorlat sorok: a fejléc után, amíg bármelyik hétben van tartalom
    var lines = [];
    var blank = 0;
    for (var r = r0 + 2; r < grid.length; r++) {
      var any = false;
      var cells = perWeek.map(function (w) {
        var name = cell_(grid, r, w.c);
        var sets = cell_(grid, r, w.cols.set);
        var reps = cell_(grid, r, w.cols.reps);
        var load = cell_(grid, r, w.cols.load);
        var note = cell_(grid, r, w.cols.note);
        // a következő sáv címkéje nem gyakorlat
        if (WEEK_RE.test(name)) return null;
        if (!name && !sets && !reps && !load && !note) return null;
        any = true;
        return { week: w.week, name: name, sets: sets, reps: reps, load: load, note: note };
      });
      if (!any) { blank++; if (blank >= 1) break; continue; }
      blank = 0;
      lines.push({ row: r + 1, cells: cells.filter(function (x) { return x; }) });
    }

    days.push({
      index: dayIndex,
      name: dayName,
      weekday: weekday,
      row: r0 + 1,
      dates: perWeek.map(function (w) { return { week: w.week, date: w.date }; }),
      lines: lines
    });
  });

  var start = null;
  days.forEach(function (d) {
    d.dates.forEach(function (x) { if (x.week === 0 && (start === null || x.date < start)) start = x.date; });
  });

  return { sheet: sheetName, weeks: maxWeek + 1, startDate: start, days: days };
}

if (typeof module !== 'undefined') module.exports = { parsePlan: parsePlan, WEEK_RE: WEEK_RE };
