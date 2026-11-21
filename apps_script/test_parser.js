const { parsePlan } = require('./plan_parser.js');
const assert = require('assert');

// A valódi Block-1 fül 1-2. hete (A1:T46), ugyanazokkal a cellapozíciókkal.
function put(g, r, c, v) { while (g.length <= r) g.push([]); const row = g[r]; while (row.length <= c) row.push(''); row[c] = v; }
const g = [];
function week(c0, r, [name, set, ism, suly, note]) {
  put(g, r, c0, name); put(g, r, c0 + 4, set); put(g, r, c0 + 5, ism); put(g, r, c0 + 6, suly); if (note) put(g, r, c0 + 8, note);
}
function dayHeader(r, label1, label2, dayName) {
  put(g, r, 0, label1); put(g, r, 10, label2);
  [0, 10].forEach(c0 => { put(g, r + 1, c0, dayName); put(g, r + 1, c0 + 4, 'set'); put(g, r + 1, c0 + 5, 'ism'); put(g, r + 1, c0 + 6, 'suly'); put(g, r + 1, c0 + 8, 'megjegyzes'); });
}
function lines(r0, arr) { arr.forEach((p, i) => { week(0, r0 + i, p[0]); week(10, r0 + i, p[1]); }); }

dayHeader(0, '1. hét · 2026.10.20.', '2. hét · 2026.10.27.', 'kedd');
lines(2, [
  [['Tempo 4-2-0','1','2','190'],['Tempo 4-2-0','1','2','195']],
  [['Tempo 4-2-0','1','2','200'],['Tempo 4-2-0','1','2','205']],
  ...[0,1,2].map(()=>[['Low bar guggolás','1','5','185'],['Low bar guggolás','1','5','190']]),
  ...[0,1,2,3].map(()=>[['bench','1','5','105'],['bench','1','5','107,5']]),
  [['lehuzas magam melle','2','6','65'],['lehuzas magam melle','2','8','50','kinti gepen']],
  [['tarogatas','2','8-10','25','döntötpad'],['tarogatas','2','8-10','120','hoist']],
  [['b francia','2','8','45'],['b francia','2','8','45']],
  [['oldal emeles','2','8-10','18-19'],['oldal emeles','2','8','19']],
]);
dayHeader(17, '1. hét · 2026.10.22.', '2. hét · 2026.10.29.', 'csutortok');
lines(19, [
  ...[0,1,2].map(()=>[['bench','1','3','120'],['bench','1','3','122,5']]),
  [['deadlift','1','2','225'],['deadlift','1','2','230']],
  [['deadlift','1','1','235'],['deadlift','1','1','240']],
  [['deadlift','3','4','195'],['deadlift','3','4','197,5-200']],
  [['szeles lehuzas','2','6-12','','huzodzkodas'],['szeles lehuzas','2','6-12','','huzodzkodas']],
  [['kalapacsb','2','6-12','26'],['kalapacsb','2','6-12','26']],
  [['oldalemeles','2','8','19'],['oldalemeles','2','8','19']],
]);
dayHeader(30, '1. hét · 2026.10.24.', '2. hét · 2026.10.31.', 'szombat');
lines(32, [
  [['squat','1','2','195'],['squat','1','2','200']],
  [['squat','1','2','205'],['squat','1','2','210']],
  [['squat','2','5','185'],['squat','2','5','190']],
  [['bench','3','1','125'],['bench','3','1','127,5']],
  [['deadlift','1','5','210'],['deadlift','1','5','220']],
  [['deadlift','3','5','192,5'],['deadlift','3','5','200']],
  [['chest press alva','2','8-7','18-17'],['chest press alva','2','7-6','18-17']],
  [['evezes szeles','2','6','65'],['evezes szeles','2','6','65']],
  [['hatsoval','2','8-10','55'],['hatsoval','2','8-10','55']],
  [['cmbf','2','10','max'],['cmbf','2','10','max']],
  [['combh','2','10','max'],['combh','2','10','max']],
]);

const p = parsePlan(g, 'Block-1');
assert.strictEqual(p.days.length, 3);
assert.strictEqual(p.weeks, 2);
assert.strictEqual(p.startDate, '2026-10-20');
assert.deepStrictEqual(p.days.map(d => [d.name, d.weekday, d.lines.length]), [['kedd', 2, 13], ['csutortok', 4, 9], ['szombat', 6, 11]]);
assert.strictEqual(p.days[0].lines[0].cells.length, 2);
assert.deepStrictEqual(p.days[0].lines[0].cells[1], { week: 1, name: 'Tempo 4-2-0', sets: '1', reps: '2', load: '195', note: '' });
assert.strictEqual(p.days[0].lines[9].cells[1].note, 'kinti gepen');   // lehuzas magam melle, 2. hét (row idx 11 -> line 9)
assert.strictEqual(p.days[1].lines[5].cells[1].load, '197,5-200');
assert.strictEqual(p.days[2].lines[9].cells[0].load, 'max');
assert.strictEqual(p.days[2].dates[1].date, '2026-10-31');
console.log('OK: napok=%d, hetek=%d, start=%s, sorok=%s', p.days.length, p.weeks, p.startDate, p.days.map(d => d.lines.length).join('/'));
