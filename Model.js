// daitos.gpu-temp model helpers.
// Conventions follow hamsti.vitals/Model.js: plain top-level functions
// (imported from QML via `import "Model.js" as Model`), plus a Node
// module.exports guard so the module can be unit-tested with node.

function fileUrlToPath(url) {
  var s = String(url || "")
  if (s.indexOf("file://") === 0) s = s.substring(7)
  try {
    return decodeURIComponent(s)
  } catch (e) {
    return s
  }
}

function emptySnapshot() {
  return {
    ok: false,
    ts: 0,
    gpus: [],
    hottest: null
  }
}

// Parse raw collect.py stdout (a JSON array of {name, tempC} objects)
// into a snapshot {ok, ts, gpus, hottest}. Returns null when the output
// is empty or not valid JSON, so callers keep the previous snapshot.
function parseSnapshot(raw) {
  var text = String(raw || "").replace(/^\s+|\s+$/g, "")
  if (!text) return null
  try {
    var data = JSON.parse(text)
    if (!Array.isArray(data)) return null
    var gpus = []
    for (var i = 0; i < data.length; i++) {
      var entry = data[i] || {}
      var name = String(entry.name || "")
      var rawTemp = entry.tempC
      if (rawTemp === null || rawTemp === undefined) continue
      var tempC = Number(rawTemp)
      if (!name || !isFinite(tempC)) continue
      gpus.push({ name: name, tempC: tempC })
    }
    var hottest = null
    for (var j = 0; j < gpus.length; j++) {
      if (hottest === null || gpus[j].tempC > hottest.tempC) hottest = gpus[j]
    }
    return {
      ok: true,
      ts: Date.now(),
      gpus: gpus,
      hottest: hottest
    }
  } catch (e) {
    return null
  }
}

// Format a Celsius temperature with unit suffix, e.g. "68°C" / "154°F".
function formatTempFull(celsius, unit, emptyText) {
  if (celsius === undefined || celsius === null || !isFinite(Number(celsius))) return emptyText || "—"
  var c = Number(celsius)
  if (String(unit || "C").toUpperCase().indexOf("F") === 0) return Math.round(c * 9 / 5 + 32) + "°F"
  return Math.round(c) + "°C"
}

if (typeof module !== "undefined") {
  module.exports = {
    fileUrlToPath: fileUrlToPath,
    emptySnapshot: emptySnapshot,
    parseSnapshot: parseSnapshot,
    formatTempFull: formatTempFull
  }
}
