# GesClo

Inventory and sales management system with POS and NFC support.

GesClo is a self-hosted business management tool for small shops and warehouses. It runs entirely on your own machine (no cloud account needed): a Node.js API with an embedded SQLite database, and a React web interface.

## Features

- **Stock management** – products, categories, barcodes, quantities, low-stock and out-of-stock alerts
- **Sales / cash register** – cart, discounts, VAT, multiple payment methods, thermal (80 mm) and A4 receipts
- **Customers** – customer records linked to sales
- **Stock movements** – inbound/outbound history with user tracking
- **Reports and dashboard** – daily sales, revenue and stock overview
- **Barcode and NFC scanning** – scan products by barcode or NFC tag, contactless card payments through the companion Android POS app
- **AI assistant** (optional) – configurable provider and model, set up from *Admin → AI Setup*
- **Local authentication** – users and roles (`Super Admin`, `Admin`, `Manager`, `Operatore`, `Kiosk`), passwords hashed with scrypt
- **Operating modes** – *Standalone*, *Network Server* and *Network Terminal* (one central server, several LAN clients)

## Tech stack

| Part | Technology |
| --- | --- |
| API | Node.js, Express, WebSocket (`ws`) |
| Database | SQLite through [sql.js](https://github.com/sql-js/sql.js) (WebAssembly, no native build tools required) |
| Frontend | React 18, Vite, Tailwind CSS |
| Windows installer | [Inno Setup](https://jrsoftware.org/isinfo.php) 6 |

## Requirements

- **Node.js 18 or newer** (with npm)
- **Inno Setup 6 Compiler** – only if you want to build the Windows installer with `installer-webapp\build-installer.bat`
- Windows is the primary target; the API and web interface also run on any OS supported by Node.js

## Quick start (development)

Clone the repository, then start the API and the web interface in two terminals.

**1. API server** (port 3001)

```bash
cd server
npm install
node server.js
```

The database file `gesclo.sqlite` is created automatically in the project root on first start.

**2. Web interface** (port 3000)

```bash
cd frontend
npm install
npm run dev
```

Open <http://localhost:3000>. On the very first launch GesClo shows a **"Create the administrator account"** screen: choose a username and a password (minimum 8 characters). There is no default account. Additional users can be added from *Admin → Users*.

## Production build (without the installer)

Build the web interface once, then let the API server serve it:

```bash
cd frontend
npm install
npm run build
```

```bash
cd ../server
npm install --omit=dev
node server.js
```

The application is now available at <http://localhost:3001>: when `frontend/dist` exists, the API server serves the interface on the same port.

## Building the Windows installer

The installer is generated with Inno Setup. Everything is scripted:

1. Install **Inno Setup 6 (the Inno Setup Compiler, `ISCC.exe`)**. It is required: without it `build-installer.bat` prepares the `staging` folder but cannot produce the installer. Install it with `winget install JRSoftware.InnoSetup` or download it from the [official website](https://jrsoftware.org/isdl.php).
2. Run the build script from the project root:

```bat
installer-webapp\build-installer.bat
```

The script looks for `ISCC.exe` in the default Inno Setup install locations. It builds the frontend, prepares a `staging` folder (server, production dependencies, `frontend/dist`, and the Node.js runtime), and compiles `installer-webapp\GesClo.iss`. The result is:

```
installer-webapp\output\GesClo-Setup-2.0.exe
```

The installer:

- shows a standard wizard (install folder, optional desktop shortcut, Italian language);
- installs per user in `%LOCALAPPDATA%\GesClo` – **no administrator rights required**;
- bundles Node.js, so nothing else has to be installed on the target PC;
- creates Start menu entries: *GesClo* (starts the server in the background and opens the browser) and *Stop GesClo*;
- registers an uninstall entry in Windows *Apps & features*;
- does **not** ship any database: the first launch starts with an empty database and asks you to create the administrator account.

## Configuration

Copy `server/.env.example` to `server/.env` if you want to change the defaults:

```
PORT=3001
```

The web interface expects the API on port `3001` of the same host.

### Operating modes

Set from *Admin → System* (per device, stored in the browser):

- **Standalone** – everything runs on this machine.
- **Network Server** – this machine hosts the data; the LAN address to give to the other devices is shown on screen. The API listens on all network interfaces, so you may need to allow Node.js through the Windows firewall.
- **Network Terminal** – this device has no local server and connects to the address of a Network Server.

### POS / NFC integration security

The endpoints used by the Android POS and NFC reader apps (`/api/pos/*`, `/api/nfc/scan`) are protected by an **optional API key**. If no key is configured they are reachable by anyone on your network. Set a key in *Admin → Hardware* before exposing the server to a shared network.

### AI assistant

Configure the provider, API key and model in *Admin → AI Setup*. The key is stored in your local database only.

## Project structure

```
server/            Express API, SQLite access (db.js), NFC/POS endpoints
frontend/          React + Vite web interface
installer-webapp/  Inno Setup script and build script for the Windows installer
android-pos/       Android POS app (contactless payments)
android-nfc/       Android NFC reader app
electron/          Experimental desktop shell (not maintained)
client-winforms/   Experimental native Windows client (not maintained)
```

Data files (`gesclo.sqlite`), environment files (`.env`), build output and installers are excluded from version control by `.gitignore`.

## Backups

All data lives in a single file, `gesclo.sqlite`. To back it up, stop the server and copy that file. To restore, put it back in the same place (project root in development, the installation folder for the installed version).

## License

Released under the MIT License – see [LICENSE](LICENSE).
