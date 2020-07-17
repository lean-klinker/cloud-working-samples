export async function loadSettings() {
    const response = await fetch('/settings.json');
    return await response.json();
}