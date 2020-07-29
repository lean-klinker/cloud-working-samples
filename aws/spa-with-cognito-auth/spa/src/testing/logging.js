export function ignoreConsoleErrors() {
    jest.spyOn(console, 'error').mockImplementation(() => {});
}

export function restoreConsoleError() {
    if (console.error.mockRestore) {
        console.error.mockRestore();
    }
}