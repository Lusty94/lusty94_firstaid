![firstaid](https://github.com/user-attachments/assets/cf0a0212-f161-40c9-a22b-f8277eb7bd95)


## Script Support

📌 **Important:**  
- **Support** is provided **via Discord tickets** for **PAID** resources **ONLY**: [Join the Discord](https://discord.gg/BJGFrThmA8)  
- ❌ **Any tickets created for free scripts will be immediately closed.**  
- 💬 **For free script support**, please use the **gated channels** in Discord.  
- **Extensive documentation** for this script can be found by clicking [here](https://lusty94-scripts.gitbook.io/documentation/free/first-aid)


## Features

- 👵 Immersive Revival Points
Bring roleplay to life with fully configurable grandma/grandpa NPCs and medical professionals who revive players using animations, props, and progress circles.
- 💊 Integrated Medical Shops
Each location acts as a mini first aid store where players can purchase healing items (e.g. bandages, ifaks, painkillers) with customizable prices and live stock management.
- 🧾 Persistent Dynamic Stock System
Stock levels are saved per zone and item using SQL. Automatically initialized on first run and updated in real-time as items are purchased or restocked.
- 💰 Custom Revival Costs per Location
Tailor your server economy by setting different revival fees at each NPC location.
- 🗺️ Fully Modular Zone Configuration
Add unlimited medical NPCs with individual settings for coordinates, animations, pricing, and available items — perfect for both rural grandmas and urban clinics.


## DEPENDENCIES

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib/releases/)
- [oxmysql](https://github.com/overextended/oxmysql/releases/)
- [fm-logs](https://github.com/FiveMerr/fm-logs) (only required if using for logs)

- [qb-target](https://github.com/qbcore-framework/qb-target) or [ox_target](https://github.com/overextended/ox_target/releases/)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or [ox_inventory](https://github.com/overextended/ox_inventory/releases/) or supported scripts




## INSTALLATION

- Ensure all depenedencies are start BEFORE this script
- Ensure you have imported or ran the provided SQL file
- Configure the core settings to suit your server requirements
- Configure revival zones and their repestive information to suit your requirements
- Ensure the items you set to be purchasable exist in your items.lua
- Refer to the official documentation if required: https://lusty94-scripts.gitbook.io/documentation/free/first-aid
