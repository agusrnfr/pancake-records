(function () {
	const LS_KEY = "sidebar-collapsed";

	function getSidebar() {
		return document.querySelector(".sidebar");
	}

	function ensureToggleButton(sidebar) {
		if (!sidebar) return null;

		let btn = document.querySelector(".sidebar-toggle");
		if (btn) return btn;

		btn = document.createElement("button");
		btn.type = "button";
		btn.className = "sidebar-toggle";
		btn.setAttribute("aria-label", "Toggle sidebar");
		btn.innerHTML = `<i class="fa-solid fa-angles-left" aria-hidden="true"></i>`;
		sidebar.insertAdjacentElement("afterend", btn);

		return btn;
	}

	function applyState(sidebar) {
		if (!sidebar) return;
		const collapsed = localStorage.getItem(LS_KEY) === "true";
		sidebar.classList.toggle("collapsed", collapsed);
	}

	function toggleSidebar(sidebar) {
		if (!sidebar) return;
		sidebar.classList.toggle("collapsed");
		const isCollapsed = sidebar.classList.contains("collapsed");
		localStorage.setItem(LS_KEY, isCollapsed);
	}

	function setupDelegatedHandler() {
		if (window.__backoffice_sidebar_delegated) return;
		window.__backoffice_sidebar_delegated = true;

		document.addEventListener("click", function (event) {
			const target = event.target;
			const toggle = target.closest && target.closest(".sidebar-toggle");
			if (toggle) {
	
				const sidebar = document.querySelector(".sidebar");
				toggleSidebar(sidebar);
			}
		});
	}

	function watchForSidebar() {
		if (window.__backoffice_sidebar_observer) return;

		const observer = new MutationObserver((mutations) => {
			for (const m of mutations) {
				if (m.addedNodes && m.addedNodes.length) {
					const sidebar = getSidebar();
					if (sidebar) {
						ensureToggleButton(sidebar);
						applyState(sidebar);
					}
				}
			}
		});

		observer.observe(document.documentElement || document.body, {
			childList: true,
			subtree: true,
		});

		window.__backoffice_sidebar_observer = observer;
	}

	function initSidebar() {
		const sidebar = getSidebar();
		if (!sidebar) return;

		ensureToggleButton(sidebar);
		applyState(sidebar);
	}

	document.addEventListener("DOMContentLoaded", () => {
		initSidebar();
		setupDelegatedHandler();
		watchForSidebar();
	});

	document.addEventListener("turbo:load", () => {
		initSidebar();
	});

	document.addEventListener("turbo:before-render", () => {
	});

	document.addEventListener("turbo:render", () => {
		initSidebar();
	});

	window.addEventListener("pageshow", (event) => {
		if (event.persisted) {
			initSidebar();
		}
	});

	setTimeout(() => {
		initSidebar();
	}, 300);
})();
