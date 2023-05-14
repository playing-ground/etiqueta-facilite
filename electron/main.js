const { BrowserWindow, app, ipcMain, dialog, Menu } = require("electron");
const Firebird = require("node-firebird");
const path = require("path");

// Electron reloader
try {
  require("electron-reloader")(module);
} catch {}

let mainWindow = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 250,
    height: 250,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
    },
    autoHideMenuBar: true,
  });

  mainWindow.loadFile("index.html");

  // Open DevTools
  /*   mainWindow.webContents.openDevTools(); */
}

function handleQuery(event, period) {
  console.log(period.firstDay, period.lastDay);
  const options = {
    host: "127.0.0.1",
    port: 3050,
    database: "C:\\Sinco\\Integrado\\FACILITE.FDB",
    user: "SYSDBA",
    password: "masterkey",
    lowercase_keys: false, // set to true to lowercase keys
    role: null, // default
    pageSize: 4096, // default when creating database
    pageSize: 4096, // default when creating database
    retryConnectionInterval: 1000, // reconnect interval in case of connection drop
  };

  function handleResponse(result) {
    return mainWindow.webContents.send("sql-query", result);
  }

  Firebird.attach(options, function (err, db) {
    if (err) throw err;

    db.query(
      `
      execute block as
      begin
        DELETE FROM GONDOLA;
        INSERT INTO GONDOLA (GOND_PRODUTO, GOND_BARRAS, GOND_NUMERO, GOND_SEQUENCIA, GOND_DESCRICAO, GOND_VALOR, GOND_NOMEREDUZIDO, GOND_STATUS, GOND_MARCA,
          GOND_CODIGOFABRICA, GOND_GRADE, GOND_COR, GOND_APRESENTACAO, GOND_VALORATACADO, GOND_VALIDADE)
          select PRO_CODIGO, PRO_CODIGOBARRA, PRO_ESTOQUEATUAL, 1, PRO_DESCRICAO, 1, PRO_NOMEREDUZIDO, 'Q', '', '', NULL, NULL, 'AP', 1000, NULL
          from PRODUTO WHERE ((PRO_INATIVO = 'False') or (PRO_INATIVO is null)) AND PRO_EMPRESA = '01' AND PRO_ESTOQUEATUAL > 0 and PRO_DATACADASTRO BETWEEN '${period.firstDay}' AND '${period.lastDay}';
      end`,
      function (err, result) {
        handleResponse(result);
        db.detach();
      }
    );
  });
}

app.whenReady().then(() => {
  ipcMain.on("handle-query", handleQuery);
  createWindow();

  ipcMain.on("close-window", () => {
    //if mainWindow is the window object
    mainWindow.close();
  });
});
