# Multi Theft Auto: San Andreas Gamemode

This project is a MTA:SA server developed by [Kobaaa01](https://github.com/Kobaaa01) and [ppowicz](https://github.com/ppowicz). 
It includes functionalities like login panel, ATMs, player and admin panels, saving the state of the server and players as they join/leave the server.

---

## Technologies Used

- **Lua** – the core scripting language used for server-side logic and client-server communication
- **HTML / CSS / JavaScript** – used for building interactive user interfaces (e.g. ATM panels, player HUDs)
- **MySQL** – a relational database used to store persistent player data and game state

---

## What lua handles?

Lua scripts handle:

- Game events (e.g. entering vehicles, interacting with objects)
- Client-server communication via `triggerServerEvent` and `triggerClientEvent`
- Database integration for clear and safe data

Example: connecting to the database

```lua
local db = dbConnect("mysql", "dbname=...;host=...;username=...;password=...", "utf8")
