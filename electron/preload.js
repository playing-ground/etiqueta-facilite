const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("electronAPI", {
  openQuery: (period) =>
    ipcRenderer.send("handle-query", period),
  onSqlQuery: (callback) => ipcRenderer.on("sql-query", callback),
  onRequestClose: () => ipcRenderer.send("close-window")
});

