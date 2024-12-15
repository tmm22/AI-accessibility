document.addEventListener('DOMContentLoaded', function() {
    // Create version selector
    const nav = document.querySelector('nav');
    if (!nav) return;

    const select = document.createElement('select');
    select.id = 'version-selector';
    select.className = 'version-selector';

    // Load versions from versions.html
    fetch('/versions.html')
        .then(response => response.text())
        .then(html => {
            select.innerHTML = html;
            
            // Set current version
            const path = window.location.pathname;
            const version = path.split('/')[1];
            if (version) {
                select.value = `/${version}/`;
            }
        });

    // Handle version change
    select.addEventListener('change', function() {
        const newPath = this.value;
        window.location.pathname = newPath + window.location.pathname.split('/').slice(2).join('/');
    });

    // Add to navigation
    const container = document.createElement('div');
    container.className = 'version-container';
    container.innerHTML = '<label for="version-selector">Version:</label>';
    container.appendChild(select);
    nav.appendChild(container);
});
