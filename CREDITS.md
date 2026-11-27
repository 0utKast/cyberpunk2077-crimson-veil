# Credits & Attributions / Créditos y Reconocimientos

In accordance with **Open Modding Policy and Mandatory Attribution**, **Crimson Veil / Velo Carmesí** is released under the [MIT License & 100% Open Modding Permissions](LICENSE). Anyone is free to inspect, learn from, modify, translate, reuse assets, or redistribute this project with credit.

---

## Core Frameworks & Development Tools (Open Source)

This mod does **not** bundle any third-party framework binaries or `.dll` files. Players install the required community frameworks separately so their versions remain clean and up to date:

| Tool / Framework | Author(s) / Community | Repository / Link | Role in Crimson Veil |
| :--- | :--- | :--- | :--- |
| **WolvenKit & WolvenKit CLI** | WolvenKit Team & REDModding Community | https://github.com/WolvenKit/WolvenKit | REDengine 4 asset inspection, CR2W ↔ JSON conversion, and `.archive` packaging. |
| **Cyberpunk Blender Add-on (IO Suite)** | WolvenKit Team | https://github.com/WolvenKit/Cyberpunk-Blender-add-on | Mesh inspection and CR2W rig/material workflow verification. |
| **RED4ext** | WopsS & Contributors | https://github.com/WopsS/RED4ext | Native C++ script extender and plugin loader for REDengine 4. |
| **ArchiveXL** | psiberx | https://github.com/psiberx/cp2077-archive-xl | Non-destructive injection of entities, localization strings, journal quests, and factory resources. |
| **TweakXL** | psiberx | https://github.com/psiberx/cp2077-tweak-xl | Declarative TweakDB extensions (`.yaml`) for iconic weapons, characters, and status records. |
| **Codeware** | psiberx | https://github.com/psiberx/cp2077-codeware | Script/UI framework, dynamic entity spawning, inkWidget Tarot overlay, and scriptable systems. |
| **redscript & redscript-cli** | jac3km4 | https://github.com/jac3km4/redscript | Typed `.reds` script compilation and validation. |
| **Cyber Engine Tweaks (CET)** | yamashi, maximegmd & Contributors | https://github.com/maximegmd/CyberEngineTweaks | Optional ImGui control panel, runtime diagnostics, and manual start triggers. |
| **Audioware** | cyb3rpsych0s1s / Roms1383 | https://github.com/cyb3rpsych0s1s/audioware | External bilingual audio bank (`.ogg`), localization routing, and 3D spatial voice/SFX playback. |
| **Typst** | Typst GmbH & Open-Source Contributors | https://github.com/typst/typst | Offline typesetting of the 39-page *Crimson Veil* Illustrated Fanfic Novella (`fanfic/Crimson_Veil_Illustrated_Novella_EN.pdf`). |
| **FFmpeg** | FFmpeg Team | https://ffmpeg.org/ | Voice/SFX loudness mastering, format encoding (`.ogg` Vorbis), and video frame preparation. |

---

## Original Content, Voice Acting & Transparency Note

| Component | Creator / Method | Link / Notes | License |
| :--- | :--- | :--- | :--- |
| **Narrative Design, Story Bible, Quest Logic, Code & CR2W Templates** | **0utKast** | https://github.com/0utKast/cyberpunk2077-crimson-veil | **MIT / 100% Open Permissions** |
| **Bilingual Studio Voice Acting (`410` Lines: `205` EN + `205` ES) & `4` Custom SFX** | Original synthetic voices created from scratch via **ElevenLabs Voice Design / TTS** and mastered with **FFmpeg** (`30 FPS` JALI lip-sync generated procedurally). **Zero CD Projekt RED voice audio was extracted, sampled, or cloned.** | https://elevenlabs.io/ | **100% Open Permissions** (redistributable within the mod and forks with credit) |
| **Illustrated Companion Novella (`39` Pages)** | Written and laid out by **0utKast** in Typst, combining `21` 4K in-game captures and `5` custom collector's plates. | [fanfic/Crimson_Veil_Illustrated_Novella_EN.pdf](fanfic/Crimson_Veil_Illustrated_Novella_EN.pdf) | **MIT / Open Modding Policy** (Night City and *Cyberpunk 2077* IP belong to CD PROJEKT RED & R. Talsorian Games) |
| **Base Game World & Prop Meshes** | All world geometry, vanilla NPC/clothing templates, and prop records referenced non-destructively from **Cyberpunk 2077 Base Game (`2.x`, zero `ep1` dependencies)** | — | Owned by CD PROJEKT RED (referenced cleanly via ArchiveXL/TweakXL, never redistributed illegally) |
