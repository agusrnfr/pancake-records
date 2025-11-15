// app/assets/javascripts/backoffice.js

document.addEventListener("DOMContentLoaded", () => {
	const sidebar = document.querySelector(".sidebar");

	if (!sidebar) return;

	// Create toggle button dynamically
	const toggleBtn = document.createElement("button");
	toggleBtn.innerHTML = `<i class="fa-solid fa-angles-left"></i>`;
	toggleBtn.classList.add("sidebar-toggle");

	sidebar.appendChild(toggleBtn);

	toggleBtn.addEventListener("click", () => {
		sidebar.classList.toggle("collapsed");
	});
});
