/* ==========================================================
   SORTTABLE.JS — Prevent sorting of summary rows
   ========================================================== */

function _getNumeric(text) {
  const num = parseFloat(String(text).replace(/[^0-9.-]/g, ""));
  return isNaN(num) ? null : num;
}

function _cellValue(td) {
  if (td?.dataset?.pr) return parseFloat(td.dataset.pr);
  if (td?.dataset?.name) return td.dataset.name.trim().toLowerCase();
  const num = _getNumeric(td?.textContent);
  if (!isNaN(num)) return num;
  return td?.textContent?.trim() ?? "";
}

function sortTable(n) {
  const table = document.getElementById("leagueTable");
  if (!table) return;
  const tbody = table.tBodies[0];
  if (n === 0) return;

  // Exclude all summary rows (.avgRow)
  const allRows = Array.from(tbody.rows);
  const dataRows = allRows.filter(r => !r.classList.contains("avgRow"));

  const dir = table.getAttribute("data-dir") === "asc" ? "desc" : "asc";

  dataRows.sort((a, b) => {
    const aVal = _cellValue(a.cells[n]);
    const bVal = _cellValue(b.cells[n]);
    if (typeof aVal === "number" && typeof bVal === "number") {
      return dir === "asc" ? aVal - bVal : bVal - aVal;
    }
    return dir === "asc"
      ? String(aVal).localeCompare(String(bVal))
      : String(bVal).localeCompare(String(aVal));
  });

  // Rebuild table body: data rows first, then summary rows
  dataRows.forEach((r, i) => {
    r.cells[0].innerHTML = "<b>" + (i + 1) + "</b>";
    tbody.appendChild(r);
  });
  allRows.filter(r => r.classList.contains("avgRow"))
         .forEach(r => tbody.appendChild(r));

  table.setAttribute("data-dir", dir);
}

function sortPlayerTable(n) {
  const table = document.getElementById("playerTable");
  if (!table) return;
  const tbody = table.tBodies[0];
  const avgRow = tbody.querySelector(".avgRow");
  const rows = Array.from(tbody.rows).filter(r => !r.classList.contains("avgRow"));
  const dir = table.getAttribute("data-dir") === "asc" ? "desc" : "asc";

  rows.sort((a, b) => {
    const aVal = _getNumeric(a.cells[n]?.textContent);
    const bVal = _getNumeric(b.cells[n]?.textContent);
    if (aVal !== null && bVal !== null)
      return dir === "asc" ? aVal - bVal : bVal - aVal;
    const aTxt = a.cells[n]?.textContent?.trim() ?? "";
    const bTxt = b.cells[n]?.textContent?.trim() ?? "";
    return dir === "asc" ? aTxt.localeCompare(bTxt) : bTxt.localeCompare(aTxt);
  });

  rows.forEach(r => tbody.appendChild(r));
  if (avgRow) tbody.appendChild(avgRow);
  table.setAttribute("data-dir", dir);
}

window.sortTable = sortTable;
window.sortPlayerTable = sortPlayerTable;
