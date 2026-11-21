// Az Apps Script kódját Node-ban futtatjuk, SpreadsheetApp-szimulátorral.
const vm = require('vm'), fs = require('fs'), assert = require('assert');

class Sheet {
  constructor(name, rows = []) { this.name = name; this.rows = rows; this.hidden = []; }
  getName() { return this.name; }
  getLastRow() { let n = this.rows.length; while (n > 0 && this.rows[n - 1].every(v => v === '' || v === undefined)) n--; return n; }
  getMaxRows() { return 5000; }
  insertRowsAfter() {}
  getDataRange() { const s = this; return { getDisplayValues: () => s.rows.map(r => r.map(v => v === undefined ? '' : String(v))) }; }
  getRange(r, c, nr = 1, nc = 1) {
    const s = this;
    const chain = { setFontWeight() { return chain; }, setFontColor() { return chain; }, setBackground() { return chain; }, setHorizontalAlignment() { return chain; }, setVerticalAlignment() { return chain; }, setNumberFormat() { return chain; } };
    return Object.assign(chain, {
      getValues() { const out = []; for (let i = 0; i < nr; i++) { const row = []; for (let j = 0; j < nc; j++) row.push((s.rows[r - 1 + i] || [])[c - 1 + j] ?? ''); out.push(row); } return out; },
      setValues(v) { v.forEach((row, i) => { while (s.rows.length < r + i) s.rows.push([]); row.forEach((x, j) => { s.rows[r - 1 + i][c - 1 + j] = x; }); }); return chain; }
    });
  }
  deleteRow(n) { this.rows.splice(n - 1, 1); }
  setFrozenRows() {} setRowHeight() {} setTabColor() {} setColumnWidth() {} hideColumns(c) { this.hidden.push(c); }
  getConditionalFormatRules() { return []; } setConditionalFormatRules() {}
}
const sheets = [new Sheet('Block-1', JSON.parse(fs.readFileSync('grid_block1.json', 'utf8')))];
const ss = {
  getName: () => 'e2.0', getSpreadsheetTimeZone: () => 'Europe/Budapest',
  getSheets: () => sheets, getSheetByName: n => sheets.find(s => s.name === n) || null,
  insertSheet: n => { const s = new Sheet(n); sheets.push(s); return s; }
};
const props = {};
const ctx = {
  console, Date, JSON, Math, Object, String, Number, parseInt, isNaN,
  SpreadsheetApp: {
    getActiveSpreadsheet: () => ss, flush() {}, getUi: () => { throw new Error('no ui'); },
    newConditionalFormatRule: () => { const b = { setGradientMinpointWithValue() { return b; }, setGradientMidpointWithValue() { return b; }, setGradientMaxpointWithValue() { return b; }, setRanges() { return b; }, build() { return {}; } }; return b; },
    InterpolationType: { NUMBER: 'n' }
  },
  LockService: { getScriptLock: () => ({ waitLock() {}, releaseLock() {} }) },
  PropertiesService: { getScriptProperties: () => ({ getProperty: k => props[k], setProperty: (k, v) => { props[k] = v; } }) },
  Utilities: { getUuid: () => 'abcdef12-3456-7890-abcd-ef1234567890', computeDigest: () => [1, 2, 255], DigestAlgorithm: { MD5: 'md5' }, Charset: { UTF_8: 'utf8' } },
  ContentService: { createTextOutput: s => ({ text: s, setMimeType() { return this; } }), MimeType: { JSON: 'json' } }
};
vm.createContext(ctx);
vm.runInContext(fs.readFileSync('Parser.gs', 'utf8') + '\n' + fs.readFileSync('Code.gs', 'utf8'), ctx);
const call = (fn, arg) => JSON.parse(vm.runInContext(fn + '(' + JSON.stringify(arg) + ').text', ctx) ? vm.runInContext(fn + '(' + JSON.stringify(arg) + ')', ctx).text : '{}');

const token = vm.runInContext('getToken_()', ctx);
assert.strictEqual(token.length, 24);

assert.strictEqual(call('doGet', { parameter: { action: 'ping', token: 'rossz' } }).error, 'unauthorized');
assert.strictEqual(call('doGet', { parameter: { action: 'ping', token } }).title, 'e2.0');
assert.deepStrictEqual(call('doGet', { parameter: { action: 'blocks', token } }).blocks, ['Block-1']);

const plans = call('doGet', { parameter: { action: 'plans', token } });
assert.ok(plans.ok); assert.strictEqual(plans.plans[0].sheet, 'Block-1'); assert.strictEqual(plans.plans[0].days.length, 3);
assert.strictEqual(plans.plans[0].hash, '0102ff');

const push = (b) => call('doPost', { postData: { contents: JSON.stringify(Object.assign({ token, action: 'push' }, b)) } });
const set = (id, w, extra = {}) => Object.assign({ id, workoutId: 'W1', date: '2026-11-19', block: 'Block-1', week: 5, day: 'kedd', exercise: 'bench', set: 1, type: 'working', weight: w, reps: 5, rpe: 8, e1rm: 130.5, note: '' }, extra);
let r = push({ sets: [set('s1', 105), set('s2', 105, { set: 2 })], workouts: [{ id: 'W1', date: '2026-11-19', block: 'Block-1', week: 5, day: 'kedd', name: 'kedd', startedAt: '2026-11-19T17:00:00.000Z', endedAt: '2026-11-19T18:10:00.000Z', minutes: 70, volume: 1050, doneSets: 2, notes: 'jó edzés' }], checkins: [{ id: '2026-11-19', date: '2026-11-19', sleep: 4, fatigue: 2, readiness: 5, caffeineMg: 100, creatineG: 5 }] });
assert.ok(r.ok); assert.strictEqual(r.sets, 2);
const log = sheets.find(s => s.name === 'Napló');
assert.strictEqual(log.getLastRow(), 3);                 // fejléc + 2 sor
// újraküldés: nem duplázódik, frissül
push({ sets: [set('s1', 107.5), set('s2', 105, { set: 2 })], workouts: [{ id: 'W1', date: '2026-11-19', name: 'kedd' }] });
assert.strictEqual(log.getLastRow(), 3); assert.strictEqual(log.rows[1][11], 107.5);
// az edzésből kivett szett törlődik (s2 már nincs benne)
push({ sets: [set('s1', 107.5)], workouts: [{ id: 'W1', date: '2026-11-19', name: 'kedd' }] });
assert.strictEqual(log.getLastRow(), 2);
// edzés törlése
r = push({ deleteWorkouts: ['W1'] });
assert.strictEqual(log.getLastRow(), 1);
assert.strictEqual(sheets.find(s => s.name === 'Edzések').getLastRow(), 1);
assert.strictEqual(sheets.find(s => s.name === 'Check-in').getLastRow(), 2);
console.log('OK: Code.gs logika (auth, terv, push, upsert, törlés)');
