/* assets/quiz.js — shared quiz component for all lessons.
 * Usage: <div class="q-card" data-quiz='{"q":"...","no":"Q1",
 *          "choices":["a","b"],"answer":1,"why":"..."}'></div>
 *        <div class="q-card" data-quiz='{"q":"...","no":"Q2",
 *          "input":true,"placeholder":"herdr ...","match":"^\\s*herdr agent wait\\s+reviewer\\s+--until\\s+blocked\\s*$","why":"..."}'></div>
 * Renders buttons / an input field with instant feedback (tight loop).
 */
(function () {
  "use strict";

  function el(tag, cls, text) {
    const n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function renderChoice(card, cfg) {
    const grid = el("div", "choice-grid");
    const fb = el("div", "q-feedback");
    const buttons = cfg.choices.map((c, i) => {
      const b = el("button", "choice", c);
      b.type = "button";
      b.addEventListener("click", () => {
        buttons.forEach((x) => (x.disabled = true));
        const ok = i === cfg.answer;
        b.classList.add(ok ? "correct" : "wrong");
        if (!ok) buttons[cfg.answer].classList.add("correct");
        fb.textContent = (ok ? "✔ " : "✘ ") + (cfg.why || "");
        fb.classList.add("show", ok ? "good" : "bad");
      });
      grid.appendChild(b);
      return b;
    });
    card.appendChild(grid);
    card.appendChild(fb);
  }

  function renderInput(card, cfg) {
    const row = el("div", "q-input-row");
    const input = el("input", "q-input");
    input.type = "text";
    input.placeholder = cfg.placeholder || "";
    input.autocapitalize = "off";
    input.autocomplete = "off";
    input.spellcheck = false;
    const btn = el("button", "choice", "檢查");
    btn.type = "button";
    const fb = el("div", "q-feedback");
    function check() {
      const v = input.value;
      const re = new RegExp(cfg.match, "i");
      const ok = re.test(v);
      fb.textContent = (ok ? "✔ " : "✘ ") + (cfg.why || "");
      fb.classList.remove("good", "bad");
      fb.classList.add("show", ok ? "good" : "bad");
    }
    btn.addEventListener("click", check);
    input.addEventListener("keydown", (e) => {
      if (e.key === "Enter") check();
    });
    row.appendChild(input);
    row.appendChild(btn);
    card.appendChild(row);
    card.appendChild(fb);
  }

  document.querySelectorAll("[data-quiz]").forEach((node) => {
    let cfg;
    try {
      cfg = JSON.parse(node.getAttribute("data-quiz"));
    } catch (e) {
      node.textContent = "(quiz config parse error)";
      return;
    }
    node.appendChild(el("span", "q-no", cfg.no || "QUIZ"));
    node.appendChild(el("p", "q-text", cfg.q));
    if (cfg.choices) renderChoice(node, cfg);
    else if (cfg.input) renderInput(node, cfg);
  });
})();
