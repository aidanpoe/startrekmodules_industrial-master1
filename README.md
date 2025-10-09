# 🖖 Star Trek Modules - Industrial Replicator
### Dark Gold Nuaghty Bhop theme Enhanced Edition v2.0

[![License](https://img.shields.io/badge/License-Proprietary-orange.svg)](LICENSE)
[![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Addon-blue.svg)](https://store.steampowered.com/app/4000/Garrys_Mod/)
[![Lua](https://img.shields.io/badge/Lua-5.1-purple.svg)](https://www.lua.org/)
[![Version](https://img.shields.io/badge/Version-2.0-green.svg)](CHANGELOG.md)

> A fully-featured Star Trek replicator system with LCARS interface, persistent database, vehicle support, and comprehensive management tools.

---

## 🌟 Features

### **Core Functionality**
- ✅ **50+ Pre-configured Items** - Props, entities, weapons, vehicles, and chairs
- ✅ **LCARS Interface** - Authentic Star Trek computer interface with Dark Gold Gaming theme
- ✅ **Persistent Database** - SQLite storage for custom items across server restarts
- ✅ **Vehicle System** - Auto-detection and smart spawning of GMod vehicles
- ✅ **Chair Support** - Special handling prevents wheel attachment crashes
- ✅ **8 Default Categories** - FURNITURE, EQUIPMENT, CARGO, MEDICAL, ENG, AWAY MISSION, TOOLS, MISC

### **Advanced Management**
- 🔧 **ADD Panel** - Add unlimited custom items (props, entities, weapons, vehicles, chairs)
- 🚗 **BROWSE Panel** - Browse all GMod vehicles and chairs with type filter
- 🗑️ **REMOVE Panel** - Delete custom items with search functionality
- 👁️ **HIDE/SHOW Panel** - Hide unwanted items without deleting (works on hardcoded + custom items)
- ✏️ **MODIFY Panel** - Edit item names, categories, and types
- 📁 **MANAGE CATEGORIES Panel** - Create and delete custom categories

### **Quality of Life**
- 🎨 **Gold Theme** - Consistent Dark Gold Gaming style (#D6B140) throughout
- 🔙 **Back Buttons** - Navigate easily between all panels
- 🔍 **Search Functionality** - Find items quickly in all panels
- 📊 **Status Indicators** - See which items are visible/hidden
- ⚡ **Auto-Refresh** - Lists update automatically after changes
- 🎯 **Smart Detection** - Automatically configures vehicles and chairs

---



---

## 🚀 Installation

### **Requirements**
- Garry's Mod dedicated or listen server
- **Star Trek Modules (Base)** - REQUIRED
- **Star Trek LCARS** - REQUIRED
- **Star Trek Replicator** - REQUIRED
- **Star Trek Utilities** - REQUIRED

### **Installation Steps**

1. **Download** this addon
2. **Extract** to `garrysmod/addons/` folder
3. **Ensure** Star Trek Modules (base) and dependencies are installed
4. **Restart** your server
5. **Spawn** "Industrial Replicator" from spawn menu (Star Trek category)

### **File Structure**
```
garrysmod/
└── addons/
    └── startrekmodules_industrial-master/
        ├── lua/
        │   ├── autorun/
        │   └── star_trek/
        │       └── industrial_replicator/
        ├── materials/
        └── README.md
```

---

## 📖 Quick Start Guide

### **For Players: Spawning Items**

1. **Spawn** Industrial Replicator entity from spawn menu
2. **Walk up** and press **E** (use key)
3. **Select category** (FURNITURE, EQUIPMENT, etc.)
4. **Select item** from the list
5. **Item spawns** at replicator output location!

### **For Admins: Managing Items**

1. **Right-click** the replicator entity
2. Select **"Edit Replicator Items"**
3. Choose management action:
   - **ADD** - Add new custom items
   - **BROWSE** - Browse and add vehicles/chairs
   - **REMOVE** - Delete custom items
   - **HIDE** - Hide/show items from menu
   - **MODIFY** - Edit item properties
   - **Manage Categories** - Create/delete categories

---

## 🎮 Usage Examples

### **Adding a Custom Prop**
```
1. Right-click replicator → "Edit Replicator Items"
2. Click "Add New Item"
3. Enter:
   - Model Path: models/props_c17/chair02a.mdl
   - Display Name: Office Chair
   - Category: FURNITURE
   - Type: prop
4. Click "Add Item"
5. Item now available in spawn menu!
```

### **Adding a Vehicle**
```
1. Right-click replicator → "Edit Replicator Items"
2. Click "Browse Vehicles & Chairs"
3. Use filter: "Vehicles Only"
4. Search for "Jeep"
5. Select "Jeep Standard"
6. Choose category: VEHICLES (or create new)
7. Click "Add to Replicator"
8. Vehicle now spawnable!
```

### **Hiding Unwanted Items**
```
1. Right-click replicator → "Edit Replicator Items"
2. Click "Hide Item"
3. Search for item you want to hide
4. Select item from list
5. Click "Hide Selected Item"
6. Item no longer appears in spawn menu
7. Can unhide later by selecting and clicking "Show Selected Item"
```

---

## 🛠️ Technical Details

### **Database**
- **Technology:** SQLite (built into GMod)
- **Tables:** `indrepprops2025`, `indreppcategories2025`
- **Persistence:** All custom items and visibility states saved
- **Location:** `garrysmod/sv.db`

### **Network Communication**
- **14 Network Messages** for client-server communication
- **Efficient data transfer** - only necessary data sent
- **Validation** - all user input sanitized
- **Error handling** - comprehensive error messages

### **Item Types Supported**
- **Props** - `models/path/to/model.mdl`
- **Entities** - `class:entity_classname`
- **Weapons** - `class:weapon_name`
- **Vehicles** - `vehicle:Name:model:script` (auto-configured)
- **Chairs** - Special seating entities (crash-safe)

### **Vehicle System**
- **Auto-Scanner** - Detects all GMod vehicle scripts on server start
- **Smart Spawning** - Vehicles get scripts, chairs don't
- **Crash Prevention** - Chair detection prevents wheel attachment errors
- **Format** - `vehicle:JeepStandard:models/buggy.mdl:scripts/vehicles/jeep_test.txt`

---



---

## 🐛 Known Issues & Solutions

### **"Vehicle has invalid wheel attachment" Error**
✅ **FIXED!** Chair detection system prevents this automatically.

### **Items not appearing in menu?**
- Check if item is hidden (use HIDE/SHOW panel)
- Verify database loaded (check server console)
- Restart server to reload files

### **Panels not opening?**
- Check client console (F10) for errors
- Ensure all files loaded correctly
- Restart server and reconnect

**More help?** See [ADDON_DOCUMENTATION.md](ADDON_DOCUMENTATION.md) for comprehensive troubleshooting.

---

## 🎯 Default Item Categories

### **FURNITURE** (5 items)
Office Chair, Comfort Chair, Small Table, Large Table, Guest Bed

### **EQUIPMENT** (5 items)
Universal Console, Jef Door Hatch, Single Door, Double Door, Ladder

### **CARGO** (14 items)
Security Supplies, Medical Supplies, Engineering Supplies, Warp Plasma, Containers, Cases

### **MEDICAL** (11 items)
Sickbay Storage, Med Kits, Cabinets, Microscope, Med Bed, Medical Tools

### **ENG** (4 items)
Hyperspanner, ODN Scanner, Sonic Driver, Object Mover

### **AWAY MISSION** (2 items)
Pattern Enhancer Case, Pattern Enhancer

### **TOOLS** (1 item)
Extinguisher

### **MISC** (8 items)
Toy Serenity, LCARS Laptop, Stem Bolt, Plaque, Banner, LCARS Tablet, Tricorder, Musical Keyboard

**Total: 50+ Pre-configured Items**

---

## 🔄 Recent Updates (v2.0)

### **UI/UX Enhancements**
- ✅ Added back buttons to all 6 management panels
- ✅ Fixed text overlap with separator lines
- ✅ Made all text gold (#D6B140) for consistency
- ✅ Added theme functions for combo boxes, text entries, and list views

### **Feature Additions**
- ✅ Merged Browse Vehicles and Browse Chairs into unified panel
- ✅ Added type filter (All/Vehicles/Chairs)
- ✅ Added SHOW functionality to unhide hidden items
- ✅ Vehicle auto-detection from GMod scripts
- ✅ Chair crash prevention system

### **Bug Fixes**
- ✅ Fixed GetNumColumns() error
- ✅ Fixed CreateCloseButton error
- ✅ Fixed missing IRep_Label font
- ✅ Fixed infoLabel reference errors
- ✅ Fixed hideBtn scope error



---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

**Code Style:**
- Follow existing patterns
- Comment your code
- Use descriptive variable names
- Test on dedicated server

---

## 📜 Credits

**Original Framework:** Jan 'Oninoni' Ziegler
- Star Trek Modules base system
- LCARS interface framework
- Replicator entity foundation

**Enhanced Edition:** Dark Gold Gaming Community
- Complete UI/UX overhaul
- Vehicle system implementation
- Database management tools
- Comprehensive documentation
- Bug fixes and improvements

---

## 📄 License

**Copyright © 2022 Jan Ziegler**

This software can be used freely, but only distributed by the original author.

**Modifications:** Dark Gold Gaming enhancements are provided as-is with permission to use on private servers. Redistribution of modified version requires permission from original author.

---

## 🆘 Support

### **Need Help?**
1. 📖 Read [ADDON_DOCUMENTATION.md](ADDON_DOCUMENTATION.md) - Complete guide
2. 🔍 Check [HOW_IT_WORKS.md](HOW_IT_WORKS.md) - Technical details
3. 📋 Review [LATEST_FIX.md](LATEST_FIX.md) - Recent changes
4. 🐛 Check console for error messages (`developer 1`)
5. 💬 Contact server admin or addon developer

### **Reporting Issues**
Please include:
- GMod version
- Server or singleplayer
- Console errors (full log)
- Steps to reproduce
- Expected vs actual behavior

---

## 🔗 Links

- **Star Trek Modules** - [Original Framework](#)
- **Workshop Page** - [Steam Workshop](#)
- **Documentation** - [Complete Docs](ADDON_DOCUMENTATION.md)
- **Changelog** - [Recent Updates](LATEST_FIX.md)

---

## ⭐ Features Roadmap

### **Planned (Future Updates)**
- [ ] Item preview images
- [ ] Bulk import/export (JSON)
- [ ] Permission system
- [ ] Item cooldowns
- [ ] Resource cost system
- [ ] Item favorites/quick access
- [ ] Advanced filtering
- [ ] Item tags
- [ ] Multi-replicator support

### **Technical Improvements**
- [ ] MySQL support for multi-server
- [ ] Caching layer
- [ ] Item version control
- [ ] API for other addons
- [ ] Admin logging system
- [ ] Usage statistics
- [ ] Spawn limits per player

---



---

<div align="center">

**Made with ❤️ by the Star Trek Modules Community &   TBN**

**Version 2.0** | **Dark Gold Gaming Enhanced Edition based off Nuaghty bhop theming** | **October 2025**

[⬆ Back to Top](#-star-trek-modules---industrial-replicator)

</div>
