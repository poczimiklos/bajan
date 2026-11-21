/**
 * E app ↔ Google Sheets híd.
 *
 * Telepítés: lásd TELEPITES.md. Röviden:
 *  1) Kiterjesztések → Apps Script → illeszd be a Code.gs-t és a Parser.gs-t
 *  2) futtasd a setup() függvényt (engedélyezd), a token megjelenik
 *  3) Üzembe helyezés → Új üzembe helyezés → Webalkalmazás
 *     Futtatás: Én, Hozzáférés: Bárki  → másold ki a webalkalmazás URL-jét
 *
 * Az app a tervet (Block-N fülek) olvassa, a naplót / check-int visszaírja.
 * A Block-N fülekbe ez a szkript SOHA nem ír.
 */

var TAB_LOG = 'Napló';
var TAB_WORKOUTS = 'Edzések';
var TAB_CHECKIN = 'Check-in';
var BLOCK_RE = /^block[\s\-_]*\d+/i;

var LOG_HEADERS = ['set_id', 'workout_id', 'Dátum', 'Blokk', 'Hét', 'Nap', 'Gyakorlat', 'Szett', 'Típus',
  'Terv ism', 'Terv súly / RPE', 'Súly (kg)', 'Ismétlés', 'RPE', 'e1RM (kg)', 'Megjegyzés'];
var WORKOUT_HEADERS = ['workout_id', 'Dátum', 'Blokk', 'Hét', 'Nap', 'Edzés', 'Kezdés', 'Vége', 'Perc',
  'Volumen (kg)', 'Kész szettek', 'Edzés megjegyzés'];
var CHECKIN_HEADERS = ['id', 'Dátum', 'Alvás (1-5)', 'Fáradtság (1-5)', 'Felkészültség (1-5)',
  'Koffein (mg)', 'Kreatin (g)', 'Megjegyzés'];

// ───────────────────────── belépési pontok ─────────────────────────

function doGet(e) {
  try {
    var p = (e && e.parameter) || {};
    if (!checkToken_(p.token)) return json_({ ok: false, error: 'unauthorized' });
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    switch (p.action || 'ping') {
      case 'ping':
        return json_({ ok: true, title: ss.getName(), tz: ss.getSpreadsheetTimeZone(), now: new Date().toISOString() });
      case 'blocks':
        return json_({ ok: true, blocks: blockSheets_(ss).map(function (s) { return s.getName(); }) });
      case 'plans':
        return json_(allPlans_(ss));
      case 'plan':
        var sh = ss.getSheetByName(p.sheet);
        if (!sh) return json_({ ok: false, error: 'nincs ilyen fül: ' + p.sheet });
        return json_({ ok: true, title: ss.getName(), plan: planOf_(sh) });
      default:
        return json_({ ok: false, error: 'ismeretlen action' });
    }
  } catch (err) {
    return json_({ ok: false, error: String(err && err.message || err) });
  }
}

function doPost(e) {
  try {
    var body = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (!checkToken_(body.token)) return json_({ ok: false, error: 'unauthorized' });
    if (body.action !== 'push') return json_({ ok: false, error: 'ismeretlen action' });
    return json_(handlePush_(body));
  } catch (err) {
    return json_({ ok: false, error: String(err && err.message || err) });
  }
}

// ───────────────────────── terv olvasása ─────────────────────────

function blockSheets_(ss) {
  var list = ss.getSheets().filter(function (s) { return BLOCK_RE.test(s.getName()); });
  list.sort(function (a, b) { return blockNo_(a.getName()) - blockNo_(b.getName()); });
  return list;
}

function blockNo_(name) {
  var m = /(\d+)/.exec(name);
  return m ? parseInt(m[1], 10) : 0;
}

function planOf_(sheet) {
  var grid = sheet.getDataRange().getDisplayValues();
  var plan = parsePlan(grid, sheet.getName());
  plan.hash = hash_(JSON.stringify(plan));
  return plan;
}

function allPlans_(ss) {
  return {
    ok: true,
    title: ss.getName(),
    plans: blockSheets_(ss).map(planOf_)
  };
}

function hash_(s) {
  var bytes = Utilities.computeDigest(Utilities.DigestAlgorithm.MD5, s, Utilities.Charset.UTF_8);
  return bytes.map(function (b) { return ('0' + (b & 0xff).toString(16)).slice(-2); }).join('');
}

// ───────────────────────── napló visszaírása ─────────────────────────

function handlePush_(body) {
  var lock = LockService.getScriptLock();
  lock.waitLock(25000);
  try {
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var tabs = ensureTabs_(ss);
    var out = { ok: true, sets: 0, workouts: 0, checkins: 0, deleted: 0 };

    var del = body.deleteWorkouts || [];
    if (del.length) {
      out.deleted += deleteRowsByValue_(tabs.log, 1, del);       // workout_id a B oszlopban
      out.deleted += deleteRowsByValue_(tabs.workouts, 0, del);  // workout_id az A oszlopban
    }
    // ha egy edzést újra elküldünk, a már nem létező szettjeit töröljük
    var replace = (body.workouts || []).map(function (w) { return w.id; });
    if (replace.length) {
      var keep = {};
      (body.sets || []).forEach(function (s) { keep[s.id] = true; });
      deleteRowsWhere_(tabs.log, 1, replace, 0, keep);
    }

    out.sets = upsert_(tabs.log, (body.sets || []).map(setRow_), LOG_HEADERS.length);
    out.workouts = upsert_(tabs.workouts, (body.workouts || []).map(workoutRow_), WORKOUT_HEADERS.length);
    out.checkins = upsert_(tabs.checkin, (body.checkins || []).map(checkinRow_), CHECKIN_HEADERS.length);
    SpreadsheetApp.flush();
    return out;
  } finally {
    lock.releaseLock();
  }
}

function toDate_(iso) {
  if (!iso) return '';
  var m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso);
  if (m) return new Date(parseInt(m[1], 10), parseInt(m[2], 10) - 1, parseInt(m[3], 10));
  var d = new Date(iso);
  return isNaN(d.getTime()) ? '' : d;
}

function num_(v) { return (v === null || v === undefined || v === '') ? '' : Number(v); }

function setRow_(s) {
  return [s.id, s.workoutId, toDate_(s.date), s.block || '', num_(s.week), s.day || '', s.exercise || '',
    num_(s.set), s.type || '', s.targetReps === null || s.targetReps === undefined ? '' : s.targetReps,
    s.target || '', num_(s.weight), num_(s.reps), num_(s.rpe), num_(s.e1rm), s.note || ''];
}

function workoutRow_(w) {
  return [w.id, toDate_(w.date), w.block || '', num_(w.week), w.day || '', w.name || '',
    toDate_(w.startedAt), toDate_(w.endedAt), num_(w.minutes), num_(w.volume), num_(w.doneSets), w.notes || ''];
}

function checkinRow_(c) {
  return [c.id, toDate_(c.date), num_(c.sleep), num_(c.fatigue), num_(c.readiness),
    num_(c.caffeineMg), num_(c.creatineG), c.note || ''];
}

/** Sor beszúrás/felülírás az A oszlopban lévő azonosító alapján. */
function upsert_(sheet, rows, width) {
  if (!rows.length) return 0;
  var last = sheet.getLastRow();
  var index = {};
  if (last > 1) {
    var ids = sheet.getRange(2, 1, last - 1, 1).getValues();
    for (var i = 0; i < ids.length; i++) index[String(ids[i][0])] = i + 2;
  }
  var append = [];
  rows.forEach(function (r) {
    var at = index[String(r[0])];
    if (at) sheet.getRange(at, 1, 1, width).setValues([r]);
    else append.push(r);
  });
  if (append.length) {
    var start = Math.max(sheet.getLastRow(), 1) + 1;
    sheet.getRange(start, 1, append.length, width).setValues(append);
  }
  return rows.length;
}

/** Törli azokat a sorokat, ahol a (0-alapú) oszlop értéke szerepel a listában. */
function deleteRowsByValue_(sheet, colIdx, values) {
  return deleteRowsWhere_(sheet, colIdx, values, -1, {});
}

function deleteRowsWhere_(sheet, colIdx, values, keyIdx, keepKeys) {
  var last = sheet.getLastRow();
  if (last < 2) return 0;
  var data = sheet.getRange(2, 1, last - 1, Math.max(colIdx, keyIdx) + 1).getValues();
  var set = {};
  values.forEach(function (v) { set[String(v)] = true; });
  var removed = 0;
  for (var i = data.length - 1; i >= 0; i--) {
    if (!set[String(data[i][colIdx])]) continue;
    if (keyIdx >= 0 && keepKeys[String(data[i][keyIdx])]) continue;
    sheet.deleteRow(i + 2);
    removed++;
  }
  return removed;
}

// ───────────────────────── fülek létrehozása ─────────────────────────

function ensureTabs_(ss) {
  return {
    log: ensureTab_(ss, TAB_LOG, LOG_HEADERS, { hide: [1, 2], dateCols: [3], widths: { 7: 190, 11: 140, 16: 260 } }),
    workouts: ensureTab_(ss, TAB_WORKOUTS, WORKOUT_HEADERS, { hide: [1], dateCols: [2], dateTimeCols: [7, 8], widths: { 6: 170, 12: 300 } }),
    checkin: ensureTab_(ss, TAB_CHECKIN, CHECKIN_HEADERS, { hide: [1], dateCols: [2], widths: { 8: 300 }, scale: [3, 5] })
  };
}

function ensureTab_(ss, name, headers, opt) {
  var sh = ss.getSheetByName(name);
  if (sh) return sh;
  sh = ss.insertSheet(name);
  sh.getRange(1, 1, 1, headers.length).setValues([headers])
    .setFontWeight('bold').setFontColor('#F0E6D2').setBackground('#091428')
    .setHorizontalAlignment('center').setVerticalAlignment('middle');
  sh.setFrozenRows(1);
  sh.setRowHeight(1, 32);
  sh.setTabColor('#C8AA6E');
  var maxRows = 5000;
  if (sh.getMaxRows() < maxRows) sh.insertRowsAfter(sh.getMaxRows(), maxRows - sh.getMaxRows());
  (opt.dateCols || []).forEach(function (c) { sh.getRange(2, c, maxRows, 1).setNumberFormat('yyyy.mm.dd.'); });
  (opt.dateTimeCols || []).forEach(function (c) { sh.getRange(2, c, maxRows, 1).setNumberFormat('yyyy.mm.dd. hh:mm'); });
  Object.keys(opt.widths || {}).forEach(function (c) { sh.setColumnWidth(Number(c), opt.widths[c]); });
  sh.getRange(2, 1, maxRows, headers.length).setVerticalAlignment('middle');
  if (opt.scale) {
    var rule = SpreadsheetApp.newConditionalFormatRule()
      .setGradientMinpointWithValue('#E57373', SpreadsheetApp.InterpolationType.NUMBER, '1')
      .setGradientMidpointWithValue('#FFE082', SpreadsheetApp.InterpolationType.NUMBER, '3')
      .setGradientMaxpointWithValue('#81C784', SpreadsheetApp.InterpolationType.NUMBER, '5')
      .setRanges([sh.getRange(2, opt.scale[0], maxRows, opt.scale[1] - opt.scale[0] + 1)])
      .build();
    sh.setConditionalFormatRules(sh.getConditionalFormatRules().concat([rule]));
  }
  (opt.hide || []).forEach(function (c) { sh.hideColumns(c); });
  return sh;
}

// ───────────────────────── beállítás / token ─────────────────────────

function getToken_() {
  var props = PropertiesService.getScriptProperties();
  var t = props.getProperty('E_TOKEN');
  if (!t) {
    t = Utilities.getUuid().replace(/-/g, '').slice(0, 24);
    props.setProperty('E_TOKEN', t);
  }
  return t;
}

function checkToken_(t) {
  return !!t && String(t) === getToken_();
}

/** Egyszer futtasd: létrehozza a fülek és kiírja a tokent. */
function setup() {
  ensureTabs_(SpreadsheetApp.getActiveSpreadsheet());
  var token = getToken_();
  Logger.log('E app token: ' + token);
  try {
    SpreadsheetApp.getUi().alert('E app token', token + '\n\nEzt írd be az appban a Beállításoknál.', SpreadsheetApp.getUi().ButtonSet.OK);
  } catch (err) { /* szerkesztőből futtatva nincs UI, a Logger elég */ }
  return token;
}

function onOpen() {
  SpreadsheetApp.getUi().createMenu('E app')
    .addItem('Beállítás / token megjelenítése', 'setup')
    .addToUi();
}

function json_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
