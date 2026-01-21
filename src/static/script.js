"use strict";

let search;

function setUpSearch() {
  search = document.getElementById("search");
  if (!search) return;

  const groupElements = document.getElementsByTagName("section");
  const groups = Array.from(groupElements).map(group => {
    const links = Array.from(group.children)
      .filter(c => c.tagName === "A")
      .map(link => ({
        element: link,
        text: link.textContent.toLowerCase(),
      }));
    return ({
      element: group,
      links,
    })
  });

  search.addEventListener("input", () => {
    const query = search.value.toLowerCase();
    for (const group of groups) {
      let showGroup = false;

      for (const link of group.links) {
        const match = link.text.includes(query);
        link.element.style.display = match ? "block" : "none";
        showGroup = showGroup || match;
      }

      group.element.style.display = showGroup ? "block" : "none";
    }
  });
}

function onKeyDown(event) {
  if (document.activeElement === search) return;
  if (event.key !== "/") return;

  event.preventDefault();
  search.focus();
}

window.addEventListener("keydown", onKeyDown);
window.addEventListener("load", setUpSearch);
