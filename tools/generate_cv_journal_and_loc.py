"""
Generates CR2W JSON sources for Velo Carmesi / Crimson Veil (Phase 0 — Vertical Slice):
  - wolvenkit_src/archive/crimson_veil/journal/crimson_veil.journal.json
  - wolvenkit_src/archive/crimson_veil/localization/es-es.json.json
  - wolvenkit_src/archive/crimson_veil/localization/en-us.json.json

100% Cyberpunk 2077 Base Game (2.x), 0 ep1 references.
Spanish-first primary authoring with clean English fallback strings so no raw LocKey# appears.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

MOD_ROOT = Path(__file__).resolve().parent.parent
WK_ARCHIVE = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil"

LOC_STRINGS: dict[str, tuple[str, str]] = {
    # (en-us, es-es)
    # --- Actors ---
    "cv_npc_misty_name": ("Misty Olszewski", "Misty Olszewski"),
    "cv_npc_vampyre_a_name": (
        "Pale Chorus Stalker",
        "Acechadora del Coro Pálido",
    ),
    "cv_npc_vampyre_b_name": (
        "Pale Chorus Night Acolyte",
        "Acólito Nocturno del Coro Pálido",
    ),
    # --- Quest Items & Iconic Reward ---
    "cv_item_moon_card_name": (
        "Stained Tarot Card — The Blood Moon",
        "Carta del Tarot Manchada — La Luna de Sangre",
    ),
    "cv_item_moon_card_desc": (
        "An Arcane Moon card left face-up beside funeral candles in the back alley behind Misty's Esoterica, stained with dark synthetic hemoglobin.",
        "Una carta de La Luna hallada boca arriba junto a los cirios en el callejón trasero tras Misty's Esoterica, marcada con restos de hemoglobina sintética oscura.",
    ),
    "cv_item_plasma_name": (
        "Synthetic Plasma Vial — Pale Chorus",
        "Vial de Plasma Sintético — Coro Pálido",
    ),
    "cv_item_plasma_desc": (
        "Chilled portable dialysis vial recovered from the Northside blood shrine. Shows high-density porphyrin photosensitizers triggered by 365 nm UV.",
        "Vial de diálisis portátil recogido en el altar de Northside. Contiene fotosensibilizadores de porfirina reactivos bajo radiación UV de 365 nm.",
    ),
    "cv_weapon_fang_name": ("Pale Fang", "Colmillo Pálido"),
    "cv_weapon_fang_desc": (
        "Clandestine throwing neurotoxin dagger balanced for nocturnal Pale Chorus initiates. Rewired by V for anti-regeneration strikes.",
        "Daga neurotóxica equilibrada utilizada por iniciados nocturnos de El Coro Pálido. Recalibrada para cortar regeneración cromática.",
    ),
    "cv_weapon_fang_ability": (
        "PALE FANG: +28 Chemical/Neurotoxin damage, +18% Crit Chance, and +25% Crit Damage.",
        "COLMILLO PÁLIDO: +28 de daño químico/neurotóxico, +18 % de probabilidad de crítico y +25 % de daño crítico.",
    ),
    # --- Journal Quest, Objectives & Descriptions ---
    "cv_quest_p0_title": (
        "Crimson Veil: Blood Beneath the Neon",
        "Velo Carmesí: Sangre bajo el Neón",
    ),
    "cv_obj_p0_01": (
        "Inspect the crimson omen altar in the back alley behind Misty's Esoterica (rooftop access).",
        "Examina el altar carmesí en el callejón trasero tras la tienda de Misty (acceso a la azotea).",
    ),
    "cv_desc_p0_01": (
        "A makeshift candlelit altar with a chemically stained Moon Tarot card has appeared in the back courtyard behind Misty's Esoterica, on the walkway toward Vik's alley and the rooftop access. Inspect the crimson altar (outside the shop) and ascend with Misty at dusk.",
        "Una mesa improvisada con cirios fúnebres y una carta de La Luna manchada ha aparecido en el callejón trasero tras Misty's Esoterica, camino de la clínica de Vik y el acceso a la azotea. Examina el altar carmesí fuera de la tienda y sube con Misty a la azotea al anochecer.",
    ),
    "cv_obj_p0_02": (
        "Speak with Misty on the night rooftop and perform the Three-Arcana spread.",
        "Habla con Misty en la azotea nocturna y realiza la tirada de los Tres Arcanos.",
    ),
    "cv_desc_p0_02": (
        "Overlooking Little China at 22:00, talk with Misty about The Pale Chorus and decode the Three-Arcana spread through either a Forensic or Symbolic lens.",
        "Sobre los neones de Little China a las 22:00 h, habla con Misty sobre El Coro Pálido y decodifica la tirada de los Tres Arcanos bajo un enfoque forense o simbólico.",
    ),
    "cv_obj_p0_03": (
        "Investigate the Northside Oilfields blood shrine and overload the UV Emitter against The Pale Chorus.",
        "Investiga el altar de sangre en los Campos Petrolíferos de Northside (usa el Emisor UV contra El Coro Pálido).",
    ),
    "cv_desc_p0_03": (
        "The ritual coordinates point to an abandoned oil derrick lot in Northside. Neutralize the Pale Chorus scouts—use the violet UV Emitter nearby to halt their dark blood regeneration—and collect the plasma vial.",
        "Las coordenadas señalan una explanada desierta entre torres petrolíferas en Northside. Abate a los acólitos de El Coro Pálido —sobrecarga el Emisor UV cercano para frenar su regeneración hematológica— y recoge la muestra de plasma.",
    ),
    "cv_obj_p0_04": (
        "Return to Misty on the Little China rooftop with the synthetic plasma sample.",
        "Regresa con Misty a la azotea de Little China con la muestra de plasma sintético.",
    ),
    "cv_desc_p0_04": (
        "Bring the synthetic plasma dialysis sample back to Misty on her rooftop (or ascend via the back-alley altar behind Misty's Esoterica) to close this initial trace.",
        "Lleva el vial de plasma sintético de vuelta con Misty en la azotea de Little China (subiendo desde el altar del callejón trasero tras su tienda si bajaste) para cerrar este primer rastro.",
    ),
    "cv_desc_p0_done": (
        "You examined Misty's stained Moon card, decoded the Three-Arcana spread on the Little China rooftop, broke the Pale Chorus ambush at Northside Oilfields with the UV Emitter, and returned with synthetic plasma data (+1,200 E$ & Pale Fang).",
        "Examinaste el presagio de La Luna en Misty's Esoterica, descifraste los Tres Arcanos con Misty sobre Little China, desbarataste la emboscada de El Coro Pálido en los Campos Petrolíferos con el Emisor UV y entregaste la muestra de plasma (+1.200 €$ y «Colmillo Pálido»).",
    ),
    # --- 3 Journal Shards ---
    "cv_shard_tarot_p0_name": (
        "Arcana Codex — The Blood Moon & The Inverted Hanged Man",
        "Códice de Arcanos — La Luna de Sangre y El Colgado",
    ),
    "cv_shard_tarot_p0_text": (
        "CRYPTIC PATTERN MAPPING // MISTY'S ESOTERICA\n\nI. THE BLOOD MOON: Nocturnal activity window (22:00-04:00). Pale Chorus operatives inject erythropoietin derivatives before sundown.\nII. INVERTED HANGED MAN: Suspended hemodialysis cycles inside abandoned industrial rigs.\nIII. THE TOWER: Structural collapse of subdermal repair nanites when exposed to high-intensity UV radiation.",
        "MAPEO DE PATRONES // MISTY'S ESOTERICA\n\nI. LA LUNA DE SANGRE: Ventana operativa estrictamente nocturna (22:00–04:00). Los iniciados se transfunden plasma modificado antes del anochecer.\nII. EL COLGADO INVERTIDO: Ciclos clandestinos de hemodiálisis suspendida en polígonos olvidados.\nIII. LA TORRE: Colapso inmediato del escudo nanítico dérmico al recibir radiación ultravioleta concentrada.",
    ),
    "cv_shard_porphyria_p0_name": (
        "Clinical Note — Synthetic Hemodialysis & UV Porphyria",
        "Nota Clínica — Hemodiálisis Sintética y Porfiria Cromática (Vulnerabilidad UV)",
    ),
    "cv_shard_porphyria_p0_text": (
        "PHOTOTOXIC VULNERABILITY REPORT // WATSON RIPPER-AUDIT\n\nVampyre fang injectors combined with unlicensed nocturnal blood exchange leave free-floating synthetic porphyrins in superficial capillaries. Under darkness, repair nanites boost cellular closure (+2.5%/s). Direct exposure to 365 nm UV triggers oxidative photolysis: instant blindness, cyberware micro-arcs, and total suppression of blood regeneration.",
        "INFORME DE VULNERABILIDAD FOTOTÓXICA // AUDITORÍA WATSON\n\nLos colmillos Vampyre combinados con diálisis clandestina de eritrocitos sintéticos dejan porfirinas reactivas acumuladas en la dermis. En oscuridad absoluta, sus nanitos aceleran la cicatrización (+2,5 %/s). Sin embargo, un pulso UV de 365 nm desata fotolisis oxidativa: ceguera instantánea, cortocircuito en implantes y anulación total de la regeneración.",
    ),
    "cv_shard_chorus_p0_name": (
        "Field Dossier — The Pale Chorus (Northside)",
        "Informe de Campo — El Coro Pálido (Northside)",
    ),
    "cv_shard_chorus_p0_text": (
        "RECOVERED FIELD TAG // NORTHSIDE OILFIELDS\n\n'Chorus Protocol — Cell Zero': Disillusioned Exotics biosculptors and black-clinic techs masquerading synthetic hematology as an occult coven. Symbolic Tarot tags mark every drop site to conceal telemetry under superstition—Project NOX-9 feeds data back through abandoned Watson relays.",
        "ETIQUETA RECUPERADA // CAMPOS PETROLÍFEROS DE NORTHSIDE\n\n«Protocolo Coro — Célula Cero»: antiguos biosculptores Exotics y técnicos de clínicas negras ocultan sus pruebas de hematología sintética tras rituales ocultistas y arcanos invertidos. Bajo la máscara del Tarot se esconde la telemetría del Proyecto NOX-9.",
    ),
    # --- Mappins, Prompts & HUD Banners ---
    "cv_mappin_esoterica": (
        "Back Alley behind Misty's Esoterica: Crimson Omen Altar",
        "Callejón tras Misty's Esoterica: Altar del Presagio Carmesí",
    ),
    "cv_mappin_rooftop": (
        "Misty's Rooftop Sanctuary",
        "Azotea de Misty (Little China)",
    ),
    "cv_mappin_return_esoterica": (
        "Back Alley behind Misty's Esoterica: Ascend to Misty's Rooftop",
        "Callejón tras Misty's Esoterica: Subir con Misty a la azotea",
    ),
    "cv_mappin_oilfields": (
        "Northside Oilfields: Blood Shrine",
        "Campos Petrolíferos de Northside: Altar de Sangre",
    ),
    "cv_mappin_uv_emitter": (
        "Industrial UV Emitter (Overload)",
        "Emisor UV Industrial (Sobrecargar)",
    ),
    "cv_banner_p0_start": (
        "[CRIMSON VEIL] A crimson omen altar awaits in the back alley behind Misty's Esoterica",
        "[VELO CARMESÍ] Un altar carmesí aguarda en el callejón trasero tras la tienda de Misty",
    ),
    "cv_banner_p0_rooftop_enter": (
        "[LITTLE CHINA · 22:00] Misty awaits beside the Tarot table",
        "[LITTLE CHINA · 22:00] Misty te espera junto a la mesa del Tarot",
    ),
    "cv_banner_p0_oilfields_unlocked": (
        "[TAROT DECODED] Northside Oilfields coordinates marked on map",
        "[TIRADA DECODIFICADA] Coordenadas marcadas en Campos Petrolíferos de Northside",
    ),
    "cv_banner_oil_arrive": (
        "[NORTHSIDE] Inspect the Blood Shrine to analyze The Pale Chorus ritual",
        "[NORTHSIDE] Examina el Altar de Sangre para analizar el ritual del Coro Pálido",
    ),
    "cv_banner_oil_ambush": (
        "[AMBUSH · THE PALE CHORUS] Vampyre acolytes attacking! Overload the nearby UV Emitter to halt their regen",
        "[EMBOSCADA · EL CORO PÁLIDO] ¡Acólitos Vampyre al ataque! Usa el Emisor UV cercano contra su regeneración",
    ),
    "cv_banner_uv_ready": (
        "[UV EMITTER ARMED] 365 nm capacitor charged — Inspect the Blood Shrine and trigger it once they attack",
        "[EMISOR UV LISTO] Condensador 365 nm armado — Examina el Altar de Sangre y úsalo cuando ataquen",
    ),
    "cv_banner_uv_overload": (
        "[UV EMITTER] Synthetic porphyria exposed — Vampyre regen halted (14 s)",
        "[EMISOR UV] Porfiria fotosensible expuesta — Regeneración anulada (14 s)",
    ),
    "cv_banner_uv_miss": (
        "[UV EMITTER] 365 nm pulse fired — Lure the Vampyres closer to the tower (24 m range)",
        "[EMISOR UV] Pulso 365 nm disparado — Atrae a los Vampyres más cerca de la torre (24 m)",
    ),
    "cv_banner_uv_cooling_pre": (
        "[UV EMITTER] Capacitor recharging — ready in ",
        "[EMISOR UV] Condensador recargando — listo en ",
    ),
    "cv_banner_shrine_combat_lock": (
        "[COMBAT ACTIVE] Defeat the Pale Chorus acolytes (use the UV Emitter) before collecting the plasma sample",
        "[COMBATE ACTIVO] Abate a los acólitos del Coro Pálido (usa el Emisor UV) antes de recoger la muestra",
    ),
    "cv_banner_uv_hint": (
        "[TACTICAL] Enemy dark-blood regeneration detected — Overload the UV Emitter!",
        "[TÁCTICO] Regeneración hematológica detectada — ¡Sobrecarga el Emisor UV cercano!",
    ),
    "cv_banner_sample_ready": (
        "[CORO PÁLIDO] Threats neutralized — Collect the plasma vial at the Blood Shrine",
        "[CORO PÁLIDO] Amenazas neutralizadas — Recoge el vial de plasma en el altar",
    ),
    "cv_banner_sample_taken": (
        "[PLASMA SECURED] Return with Misty to the Little China rooftop",
        "[PLASMA RECOGIDO] Regresa con Misty a la azotea de Little China",
    ),
    "cv_banner_p0_complete": (
        "[CRIMSON VEIL] Phase 0 complete (+1,200 E$ & Pale Fang)",
        "[VELO CARMESÍ] Fase 0 completada (+1.200 €$ y «Colmillo Pálido»)",
    ),
    # --- Native Dialogue & Interaction Hubs ---
    "cv_hub_esoterica_title": ("Crimson Omen Altar", "Altar del Presagio Carmesí"),
    "cv_act_ascend_rooftop": (
        "Meet Misty on the rooftop (22:00 · Night)",
        "Subir con Misty a la azotea (22:00 · Noche)",
    ),
    "cv_act_inspect_card": (
        "What is this stained card beside the candles?",
        "¿Qué es esta carta manchada junto a las velas?",
    ),
    "cv_act_open_codex": (
        "Open Arcana Codex (Journal Shards)",
        "Abrir Códice de Arcanos",
    ),
    "cv_hub_misty_roof_title": ("Misty Olszewski — Rooftop Sanctuary", "Misty Olszewski — Azotea Privada"),
    "cv_act_ask_chorus": (
        "Who exactly are 'The Pale Chorus'?",
        "¿Quiénes son «El Coro Pálido» exactamente?",
    ),
    "cv_act_ask_uv": (
        "Why do they recoil from ultraviolet light?",
        "¿Por qué huyen de la luz ultravioleta?",
    ),
    "cv_act_start_tarot": (
        "Perform the Three-Arcana Tarot spread",
        "Realizar la tirada de los Tres Arcanos",
    ),
    "cv_act_descend_esoterica": (
        "Head back down to Misty's Esoterica",
        "Bajar de nuevo a Misty's Esoterica",
    ),
    "cv_act_deliver_plasma": (
        "Hand over the synthetic plasma vial to Misty",
        "Entregar la muestra de plasma sintético a Misty",
    ),
    "cv_act_fast_travel_oil": (
        "Ride straight out to Northside Oilfields (Night)",
        "Ir directamente a los Campos Petrolíferos de Northside",
    ),
    "cv_hub_uv_title": ("Industrial UV Spotlight Tower", "Torre Emisora UV Industrial"),
    "cv_act_uv_check": (
        "Inspect industrial UV Emitter tower",
        "Comprobar torre emisora UV",
    ),
    "cv_act_uv_trigger": (
        "Overload UV Emitter (365 nm Phototoxic Burst)",
        "Sobrecargar Emisor UV (Pulso 365 nm)",
    ),
    "cv_act_uv_cooling": (
        "UV Capacitor Recharging",
        "Condensador UV recargando",
    ),
    "cv_hub_shrine_title": ("Northside Blood Shrine", "Altar de Sangre — Northside"),
    "cv_act_inspect_shrine": (
        "Examine the Blood Shrine",
        "Examinar el altar de sangre",
    ),
    "cv_act_shrine_combat_lock": (
        "Blood Shrine (Defeat The Pale Chorus)",
        "Altar de sangre (Abate al Coro Pálido)",
    ),
    "cv_act_take_plasma": (
        "Collect synthetic plasma dialysis vial",
        "Recoger muestra de plasma sintético",
    ),
    # --- Interactive Tarot UI (CrimsonTarotPopup) ---
    "cv_ui_title": ("CRIMSON VEIL // ARCANA SPREAD & FORENSIC CODEX", "VELO CARMESÍ // TIRADA DE ARCANOS Y CÓDICE"),
    "cv_ui_subtitle": ("ESOTERIC SYMBOLISM MEETS CLANDESTINE HEMATOLOGY · MISTY'S ROOFTOP SANCTUARY", "SIMBOLISMO ESOTÉRICO FRENTE A HEMATOLOGÍA CLANDESTINA · AZOTEA DE MISTY"),
    "cv_ui_tab_spread": ("THREE-ARCANA SPREAD", "TIRADA DE ARCANOS"),
    "cv_ui_tab_codex": ("FIELD CODEX [SHARDS]", "CÓDICE DE CAMPO [PINCHOS]"),
    "cv_ui_lens_forensic": ("LENS: FORENSIC [REASON]", "ENFOQUE: FORENSE [RAZÓN]"),
    "cv_ui_lens_symbolic": ("LENS: SYMBOLIC [MISTY]", "ENFOQUE: SIMBÓLICO [MISTY]"),
    "cv_ui_confirm": ("CONFIRM SPREAD & TRACK NORTHSIDE", "CONFIRMAR TIRADA Y RASTREAR EL ALTAR"),
    "cv_ui_close": ("CLOSE [ESC]", "CERRAR [ESC]"),
    "cv_ui_pick_hint": ("Select an Arcana card to focus your trace", "Elige una carta como Arcano Regente antes de confirmar"),
    "cv_card1_name": ("I · THE MOON", "I · LA LUNA"),
    "cv_card1_tag": ("NOCTURNAL SECRET & PORPHYRINS", "SECRETO NOCTURNO Y PORFIRINAS"),
    "cv_card1_forensic": (
        "FORENSIC READING: Synthetic hemoglobin saturated with reactive porphyrins. Anyone who bled onto The Moon would suffer severe internal burns in direct sunlight.",
        "LECTURA FORENSE: Hemoglobina sintética y traza extrema de porfirinas reactivas. Quien sangró sobre La Luna sufriría quemaduras internas graves bajo el sol directo.",
    ),
    "cv_card1_symbolic": (
        "MISTY'S READING: Two fingernail notches on the lower corner — 'Awake in the dark, unable to face the light.' Lucía already carried that nocturnal secret on her skin.",
        "LECTURA DE MISTY: Dos muescas de uña en la esquina inferior izquierda — «Estoy despierta en la oscuridad, pero no puedo salir a la luz». Lucía guardaba ya ese secreto en su piel.",
    ),
    "cv_card2_name": ("II · INVERTED HANGED MAN", "II · EL COLGADO INVERTIDO"),
    "cv_card2_tag": ("FALSE VOW & NOCTURNAL DIALYSIS", "PROMESA DE RENACER Y DIÁLISIS"),
    "cv_card2_forensic": (
        "FORENSIC READING: Clandestine night clinics offer pulmonary therapy that swaps natural blood for NOX-9 dialysis, binding patients to life after sundown.",
        "LECTURA FORENSE: Supuestas clínicas nocturnas ofrecen terapias respiratorias que sustituyen sangre por diálisis NOX-9 para atrapar a los pacientes tras el anochecer.",
    ),
    "cv_card2_symbolic": (
        "MISTY'S READING: The Hanged Man inverted is a false vow of rebirth through silent sacrifice: they aren't just dodging illness, they're searching for somewhere to belong.",
        "LECTURA DE MISTY: El Colgado invertido es el falso voto de renacer pagando un sacrificio en silencio: buscan pertenecer a algo que no los descarte al amanecer.",
    ),
    "cv_card3_name": ("III · THE TOWER", "III · LA TORRE"),
    "cv_card3_tag": ("PETROCHEMICAL WAX · NORTHSIDE", "RESIDUO PETROQUÍMICO · NORTHSIDE"),
    "cv_card3_forensic": (
        "FORENSIC READING: Turning The Tower over reveals oily petrochemical grit pressed into candle wax from the abandoned Northside oilfields. 365 nm UV light shatters their blood.",
        "LECTURA FORENSE: La cera en el borde de La Torre atrapó gravilla aceitosa y residuo petroquímico de los depósitos abandonados de Northside. Su sangre hierve bajo luz UV a 365 nm.",
    ),
    "cv_card3_symbolic": (
        "MISTY'S READING: The Tower is the inevitable fall when a borrowed salvation collapses. Under pure ultraviolet light, The Pale Chorus cannot hold its shadow.",
        "LECTURA DE MISTY: La Torre es la caída inevitable cuando esa falsa salvación se derrumba. Bajo la luz ultravioleta, la sombra del Coro Pálido no puede sostenerse.",
    ),
    "cv_ui_locked_shard": ("[LOCKED DOSSIER] Advance Phase 0 investigation to decrypt.", "[EXPEDIENTE SELLADO] Avanza en la investigación de la Fase 0 para descifrarlo."),
    # --- Speaker Display Names ---
    "cv_spk_v": ("V", "V"),
    "cv_spk_misty": ("Misty Olszewski", "Misty Olszewski"),
    "cv_spk_vampyre": ("Pale Chorus Acolyte", "Acólito del Coro Pálido"),
    # --- Dialogue Lines (Subtitles <= 140 chars / crisp Spanish-first) ---
    "cv_p0_misty_esoterica_01": (
        "Someone left that stained Moon card before dawn, V. Wait until nightfall and meet me upstairs on the roof.",
        "Alguien dejó esa Luna manchada antes del alba, V. Espera a la noche y sube conmigo a la azotea.",
    ),
    "cv_p0_misty_rooftop_01": (
        "Night City breathes easier up here. Thank you for coming up once the neon drowned out the sun, V.",
        "Aquí arriba Night City respira distinto. Gracias por subir cuando el neón apaga el sol, V.",
    ),
    "cv_p0_misty_rooftop_02": (
        "That wasn't ordinary ink on the Moon card—it smelled like cold copper, dialysis fluid, and fear dressed as ritual.",
        "Eso no era tinta en La Luna: olía a cobre frío, líquido de diálisis y miedo disfrazado de rito.",
    ),
    "cv_p0_v_ask_chorus": (
        "Who are 'The Pale Chorus' exactly—chromed street ghouls or some new corpo cult?",
        "¿Quiénes son exactamente «El Coro Pálido»? ¿Cromados callejeros o una secta nueva?",
    ),
    "cv_p0_misty_ans_chorus": (
        "Former Exotics biosculptors and black-clinic dropouts. They inject cheap Vampyre fangs and synthetic blood to play immortal.",
        "Antiguos biosculptores Exotics y fugados de clínicas negras. Usan colmillos Vampyre y sangre sintética para creerse inmortales.",
    ),
    "cv_p0_v_ask_uv": (
        "Wait—my optics tagged UV porphyrin warnings on that card. Are they actually allergic to sunlight?",
        "Espera... mis ópticas leyeron trazas de porfirina reactiva a UV. ¿De verdad les quema la luz?",
    ),
    "cv_p0_misty_ans_uv": (
        "It's broken chemistry, not magic. Their dirty dialysis burns violently under harsh ultraviolet light—remember that if you cross them.",
        "Es química rota, no magia. Su diálisis sucia arde bajo luz ultravioleta intensa; recuérdalo si se cruzan contigo.",
    ),
    "cv_p0_misty_tarot_forensic": (
        "Sharp and clinical—just like a solo. Check the industrial oilfields up in Northside and bring me one clean plasma sample.",
        "Frío y clínico, justo como tú. Rastrea los pozos petrolíferos de Northside y tráeme una muestra intacta de ese plasma.",
    ),
    "cv_p0_misty_tarot_symbolic": (
        "You still read between the lines of this city. Follow that crimson thread into the Northside Oilfields—don't drop your guard.",
        "Aún sabes leer lo que calla la ciudad. Sigue ese hilo carmesí hasta los Pozos Petrolíferos de Northside, pero no bajes la guardia.",
    ),
    "cv_p0_v_oilfields_arrive": (
        "Abandoned derricks, blood drip on rust, and a heavy UV floodlight rigged right beside it. Stay sharp.",
        "Pozos muertos, una bolsa de plasma entre velas y un foco UV industrial montado justo al lado. Toca vigilar las sombras.",
    ),
    "cv_p0_vampyre_ambush": (
        "The night belongs to the Chorus, outsider! Bleed into the dust or kneel before the Crimson Veil!",
        "¡La noche pertenece al Coro, intruso! ¡Derrama tu sangre en el polvo o arrodíllate ante el Velo!",
    ),
    "cv_p0_v_uv_hint": (
        "Damn it—their chrome is knitting flesh back together in the dark! Overload that UV Emitter!",
        "Maldición... ¡se están regenerando en la oscuridad! ¡Sobrecarga ese Emisor UV ahora mismo!",
    ),
    "cv_p0_v_sample_taken": (
        "Synthetic porphyrin-plasma sealed. Misty needs to see this telemetry back up on her Little China roof.",
        "Vial de plasma sintético asegurado. Misty tiene que ver estos datos arriba en su azotea.",
    ),
    "cv_p0_misty_debrief_01": (
        "Look at those porphyrin readings... It's worse than superstition. Someone is testing Project NOX-9 across Watson's fringes.",
        "Mira estas lecturas de porfirina... Es peor que superstición: alguien prueba el Proyecto NOX-9 en los márgenes de Watson.",
    ),
    "cv_p0_misty_debrief_02": (
        "Take this modified blade and your Eddies, V. When the shadows gather thicker in the warehouses, I'll call you back up.",
        "Quédate esta hoja y tu paga, V. Cuando las sombras vuelvan a cerrarse sobre los almacenes, volveré a llamarte.",
    ),
    # =========================================================================
    # ACTO I EN WATSON — RÉQUIEM DE PORFIRINA (v0.3.0)
    # =========================================================================
    "cv_npc_valdes_name": ("Dr. Adrián Valdés", "Dr. Adrián Valdés"),
    "cv_npc_gatekeeper_name": (
        "Pale Chorus Pier Sentinel",
        "Centinela del Coro Pálido",
    ),
    "cv_npc_vampyre_cell_a_name": (
        "Pale Chorus Blood-Blade",
        "Filo Carmesí del Coro Pálido",
    ),
    "cv_npc_vampyre_cell_b_name": (
        "Pale Chorus Cryo-Guard",
        "Guardia Criogénico del Coro",
    ),
    "cv_spk_valdes": ("Dr. Adrián Valdés", "Dr. Adrián Valdés"),
    "cv_spk_gatekeeper": ("Pale Chorus Sentinel", "Centinela del Coro Pálido"),
    # --- Quest Items & Iconic Weapon Reward (Act I) ---
    "cv_item_cipher_name": (
        "Pale Chorus Frequency Cipher",
        "Clave de Frecuencia del Coro Pálido",
    ),
    "cv_item_cipher_desc": (
        "Nocturnal shift pass-phrase provided by Dr. Adrián Valdés: 'The shadow drinks before dawn.' Lets V bluff past the west pier checkpoint.",
        "Santo y seña nocturno entregado por el doctor Adrián Valdés: «La sombra bebe antes del alba». Permite franquear pacíficamente el control del muelle oeste.",
    ),
    "cv_item_manifest_name": (
        "Project NOX-9 Manifest — Badlands Link",
        "Manifiesto Proyecto NOX-9 — Enlace Badlands",
    ),
    "cv_item_manifest_desc": (
        "Encrypted cryo-shipping ledger pulled from the west pier terminal. Ties Biotechnica porphyrin batches to a desert facility and tags Misty's Esoterica as 'Nexus of Silence'.",
        "Registro criogénico extraído del terminal del muelle oeste. Vincula lotes de porfirina de Biotechnica con una planta del desierto y señala Misty's Esoterica como «Nexo de Silencio».",
    ),
    "cv_weapon_veil_name": ("Silent Veil", "Velo Silente"),
    "cv_weapon_veil_desc": (
        "Precision suppressed Nue pistol modified with porphyrin-reactive neurotoxin rounds. Crafted for quiet nocturnal strikes.",
        "Pistola Nue de precisión modificada con munición neurotóxica antiporfirina y supresor acústico equilibrado para incursiones nocturnas.",
    ),
    "cv_weapon_veil_ability": (
        "SILENT VEIL: +35 Chemical/Toxin damage, +22% Crit Chance, +35% Headshot Multiplier, and faster reload speed.",
        "VELO SILENTE: +35 de daño químico, +22 % de probabilidad de crítico, +35 % de multiplicador en cabeza y recarga más veloz.",
    ),
    # --- Act I Journal Quest, Objectives & Descriptions (v0.8.0) ---
    "cv_quest_a1_title": (
        "Crimson Veil — Act I: Pulse of Batch NOX-9",
        "Velo Carmesí — Acto I: El Pulso del Lote NOX-9",
    ),
    "cv_sms_a1_call_recap": (
        "V — Vik's contact matched the NOX-9-K4 batch to retired Biotechnica hematologist Dr. Adrián Valdés. A live telemetry ping from that batch just triggered at an abandoned Kabuki Canal dock. Check the dumped cryo gear before the Chorus scrubs the trail.",
        "V — El contacto de Vik cruzó el lote NOX-9-K4 con patentes retiradas de Biotechnica: lo firmó el ex-hematólogo Dr. Adrián Valdés. Acaba de saltar un pulso de telemetría del mismo lote en un embarcadero del Canal de Kabuki. Revisa el descarte antes de que el Coro borre el rastro.",
    ),
    "cv_obj_a1_01": (
        "Investigate the NOX-9-K4 telemetry ping at the Kabuki Canal dock (3 clues)",
        "Investiga el pulso del lote NOX-9-K4 en el Canal de Kabuki (3 pistas)",
    ),
    "cv_desc_a1_01": (
        "Vik's Biotechnica patent lookup tied the Northside NOX-9-K4 batch to former researcher Dr. Adrián Valdés, and a live telemetry ping just hit the Kabuki Canal promenade. Inspect the discarded cryo cooler, the inverted Tarot marker, and the relay pad to find where Valdés is hiding.",
        "El contacto de Vik vinculó el lote NOX-9-K4 de Northside con el ex-hematólogo de Biotechnica Dr. Adrián Valdés, y acaba de saltar telemetría suya en el Canal de Kabuki. Examina el refrigerador criogénico, la carta invertida y el relé de campo para localizar dónde se esconde Valdés.",
    ),
    "cv_obj_a1_02": (
        "Find and question Dr. Adrián Valdés in Little China",
        "Localiza e interroga al Dr. Adrián Valdés en Little China",
    ),
    "cv_desc_a1_02": (
        "The Kabuki relay triangulates to a hidden street-level back alley in southern Little China, where The Pale Chorus left a death threat. Confront Dr. Adrián Valdés to learn his role in NOX-9, the truth about Dr. Helena Solís ('The Cantor') and her cult, and where Lucía and Mateo were moved.",
        "El relé de Kabuki señala un callejón oculto a cota de calle al sur de Little China, donde El Coro Pálido le dejó una amenaza. Habla con el Dr. Adrián Valdés para descubrir su papel con el suero NOX-9, toda la verdad sobre la Dra. Helena Solís («La Cantora») y su secta, y adónde trasladaron a Lucía y Mateo.",
    ),
    "cv_obj_a1_03": (
        "Track the NOX-9 transfer manifest at Watson's West Pier (cipher: 'The shadow drinks before dawn')",
        "Rastrea el traslado de Lucía en el Muelle Oeste de Watson (clave: «La sombra bebe antes del alba»)",
    ),
    "cv_desc_a1_03": (
        "Dr. Valdés revealed that Helena Solís ('The Cantor') weaponized his NOX-9 lung serum into The Pale Chorus, and routed Lucía Reyes and Mateo's manifests through the West Pier Cryogenic Checkpoint in Watson before shipping to the Badlands (NOX-9B). Take Valdés's encrypted cipher shard to breach or bypass the checkpoint.",
        "El Dr. Valdés reveló que Helena Solís («La Cantora») convirtió su suero NOX-9 en la jaula química de El Coro Pálido, y que todo traslado de Lucía Reyes y Mateo pasa por el Puesto Criogénico del Muelle Oeste de Watson hacia las Badlands (NOX-9B). Usa su pincho con la clave nocturna «La sombra bebe antes del alba».",
    ),
    "cv_obj_a1_04": (
        "Bring the NOX-9 Manifest back to Misty on her Little China rooftop",
        "Lleva el Manifiesto NOX-9 de vuelta con Misty a su azotea de Little China",
    ),
    "cv_desc_a1_04": (
        "The manifest flags Misty's Esoterica as 'Nexus of Silence' and points to a closed Biotechnica bunker in the Badlands. Head up to Misty's rooftop right away.",
        "El manifiesto señala la tienda de Misty como «Nexo de Silencio» y apunta hacia un búnker clausurado en las Badlands. Sube con Misty a su azotea de Little China para analizar la amenaza.",
    ),
    "cv_desc_a1_done": (
        "You uncovered the full truth behind Batch NOX-9: ex-Biotechnica researcher Dr. Adrián Valdés created the serum six years ago, and Dr. Helena Solís ('The Cantor') hijacked it to run The Pale Chorus. The West Pier manifest confirms Lucía Reyes (L-14) and Mateo (M-09) were moved out of Watson to a sealed Biotechnica bunker in the Badlands, where Solís is developing porphyrin-free NOX-9B to eliminate their weakness to UV light—and flagged Misty's Esoterica as 'Nexus of Silence'. Misty and Vik will fortify the shop and triangulate the bunker entrance ahead of Act II.",
        "Destapaste toda la verdad tras el lote NOX-9: el exinvestigador de Biotechnica Dr. Adrián Valdés creó el suero hace seis años y la Dra. Helena Solís («La Cantora») lo secuestró para levantar El Coro Pálido. El manifiesto del Muelle Oeste confirma que sacaron a Lucía Reyes (L-14) y a Mateo (M-09) de Watson rumbo a un búnker clausurado en las Badlands donde Solís prueba el suero NOX-9B sin porfirinas (inmune a la luz UV), y marca Misty's Esoterica como «Nexo de Silencio». Misty y Vik reforzarán la tienda y triangularán el búnker para cruzar al desierto en el Acto II.",
    ),
    # --- 3 New Act I Codex Shards (Shards 5..7) ---
    "cv_shard_a1_kabuki_name": (
        "Kabuki Trace — NOX-9-K4 Batch & Valdés Threat",
        "Rastro de Kabuki — Lote NOX-9-K4 y amenaza a Valdés",
    ),
    "cv_shard_a1_kabuki_text": (
        "KABUKI CANAL DOCK // FORENSIC TRACE\\n"
        "- Cryo Cooler: Scraped Biotechnica seals, empty NOX-9-K4 vials, dosing tags for Subject L-14 (Lucía Reyes) and Subject M-09 (Mateo).\\n"
        "- Inverted High Priestess: Stapled with the revoked medical license of ex-Biotechnica hematologist Dr. Adrián Valdés—left as a warning by The Pale Chorus.\\n"
        "- Telemetry Relay: Active return beacon pointing straight to Dr. Valdés's hideout in Little China.",
        "EMBARCADERO DEL CANAL DE KABUKI // RASTRO FORENSE\\n"
        "- Refrigerador criogénico: Sellos de Biotechnica raspados, matraces vacíos del lote NOX-9-K4 y etiquetas de dosificación para Sujeto L-14 (Lucía Reyes) y Sujeto M-09 (Mateo).\\n"
        "- La Sacerdotisa invertida: Grapada a la licencia médica anulada del ex-hematólogo de Biotechnica Dr. Adrián Valdés — amenaza directa de El Coro Pálido.\\n"
        "- Relé de telemetría: Baliza de retorno activa apuntando al callejón de Little China donde se oculta Valdés.",
    ),
    "cv_shard_a1_valdes_name": (
        "Valdés Testimony — NOX-9, Helena Solís & The Cult",
        "Testimonio de Valdés — NOX-9, Helena Solís y la secta",
    ),
    "cv_shard_a1_valdes_text": (
        "LITTLE CHINA // DR. ADRIÁN VALDÉS INTERROGATION\\n"
        "- Origin of NOX-9: Designed 6 years ago to treat smog-damaged workers without corpo cyberware; causes fatal porphyrin phototoxicity under sunlight or 365 nm UV. Fired by Biotechnica, Valdés sold his patents to Dr. Helena Solís.\\n"
        "- The Pale Chorus ('The Cantor'): Solís weaponized NOX-9 as a nocturnal cult—luring youth with free night clinics, creating weekly dialysis dependency, and using fear of sunrise as control.\\n"
        "- Complicity & Break: Valdés mixed stabilizers out of guilt and fear until he learned they abduct patients who try to leave.",
        "LITTLE CHINA // INTERROGATORIO AL DR. ADRIÁN VALDÉS\\n"
        "- Origen de NOX-9: Diseñado hace 6 años para salvar pulmones dañados por el smog sin implantes corporativos; acumula porfirinas letales bajo luz solar o UV a 365 nm. Despedido y arruinado, Valdés vendió sus patentes a la Dra. Helena Solís.\\n"
        "- El Coro Pálido («La Cantora»): Solís convirtió la fórmula en una secta nocturna: captan jóvenes vulnerables en clínicas gratuitas, crean adicción semanal y usan el miedo al alba como jaula.\\n"
        "- Complicidad y ruptura: Valdés les fabricó estabilizadores por culpa y miedo hasta descubrir que secuestran a quienes intentan salir.",
    ),
    "cv_shard_a1_pier_lead_name": (
        "Valdés Cipher Shard — West Pier & NOX-9B Lead",
        "Pincho de Valdés — Muelle Oeste y pista NOX-9B",
    ),
    "cv_shard_a1_pier_lead_text": (
        "ENCRYPTED SHARD HANDOFF // NEXT OBJECTIVE\\n"
        "- Transfer Route: Newly awakened subjects (Lucía Reyes L-14) and Mateo's logs route through the West Pier Cryogenic Checkpoint in Watson before shipment to Helena Solís's Badlands bunker.\\n"
        "- Night-Shift Passphrase: 'The shadow drinks before dawn' (grants stealth bypass past the pier sentry and twin 365 nm UV towers).\\n"
        "- Second-Generation Serum: Solís claims to have purified a porphyrin-free formula called NOX-9B at her Badlands core lab.",
        "PINCHO CIFRADO ENTREGADO // PISTAS PARA AVANZAR\\n"
        "- Ruta de traslado: Todos los sujetos recién despertados (Lucía Reyes L-14) y los historiales de Mateo pasan por el Puesto Criogénico del Muelle Oeste de Watson rumbo al búnker de Helena Solís en las Badlands.\\n"
        "- Santo y seña nocturno: «La sombra bebe antes del alba» (permite burlar al centinela y las dos torres UV de 365 nm).\\n"
        "- Suero de 2.ª generación: Solís afirma haber purificado una variante sin porfirinas denominada NOX-9B en su laboratorio central.",
    ),
    # --- Act I Mappins, Banners & Prompts ---
    "cv_mappin_a1_kabuki": (
        "Kabuki South Canal: Cryogenic Bio-Trace Dump",
        "Muelle Sur de Kabuki: Descarte Criogénico (3 Pistas)",
    ),
    "cv_mappin_a1_valdes": (
        "Little China (Hidden Alley): Dr. Adrián Valdés",
        "Little China (Callejón Oculto): Dr. Adrián Valdés",
    ),
    "cv_mappin_a1_waterfront": (
        "Northside West Docks: Pale Chorus Cryo Outpost",
        "Muelle Oeste (Northside Docks): Puesto Criogénico del Coro",
    ),
    "cv_mappin_a1_return_misty": (
        "Misty's Esoterica Alley: Report NOX-9 Manifest to Misty",
        "Callejón tras Misty's Esoterica: Informar a Misty en la azotea",
    ),
    "cv_banner_a1_start": (
        "[ACT I · PULSE OF NOX-9] Live NOX-9-K4 telemetry located at Kabuki Canal",
        "[ACTO I · PULSO DEL NOX-9] Telemetría del lote NOX-9-K4 localizada en el Canal de Kabuki",
    ),
    "cv_banner_a1_clue_1": (
        "[TRACE 1/3] NOX-9-K4 flasks for Subject L-14 (Lucía) & M-09 (Mateo)",
        "[PISTA 1/3] Matraces NOX-9-K4 para Sujeto L-14 (Lucía) y M-09 (Mateo)",
    ),
    "cv_banner_a1_clue_2": (
        "[TRACE 2/3] Inverted High Priestess — Chorus threat to Dr. Adrián Valdés",
        "[PISTA 2/3] La Sacerdotisa invertida — Amenaza del Coro al Dr. Adrián Valdés",
    ),
    "cv_banner_a1_clue_3": (
        "[TRACE 3/3] Relay beacon locked to Dr. Valdés's Little China hideout",
        "[PISTA 3/3] Relé triangular fijado en el escondite del Dr. Valdés",
    ),
    "cv_banner_a1_clues_done": (
        "[TRACE TRIANGULATED] Telemetry points to Dr. Adrián Valdés in the Hidden Alley (Little China)",
        "[RASTRO TRIANGULADO] El relé señala al Dr. Adrián Valdés en el Callejón Oculto (Little China)",
    ),
    "cv_banner_a1_valdes_done": (
        "[LEADS SECURED] Cipher 'The shadow drinks before dawn', West Pier & NOX-9B dossier in Codex",
        "[PISTAS RECOGIDAS] Clave «La sombra bebe antes del alba», Muelle Oeste y dossier NOX-9B en el Códice",
    ),
    "cv_banner_a1_stealth_ok": (
        "[INFILTRACIÓN LIMPIA] Centinela engañado — Accede al terminal criogénico del fondo",
        "[INFILTRACIÓN LIMPIA] Centinela convencido — Accede al terminal criogénico del fondo",
    ),
    "cv_banner_a1_pier_combat": (
        "[CELL ALERTED] Use the two pier UV towers to halt their regeneration!",
        "[CÉLULA EN ALERTA] ¡Usa las dos torres UV del muelle para frenar su regeneración!",
    ),
    "cv_banner_a1_daylight": (
        "[LUZ DIURNA] La radiación solar debilita la porfirina del Coro Pálido (sin regeneración)",
        "[LUZ DIURNA] La luz solar debilita al Coro Pálido y bloquea su regeneración",
    ),
    "cv_banner_a1_manifest_ready": (
        "[ZONA DESPEJADA] Descarga el Manifiesto NOX-9 en el terminal del fondo",
        "[MUELLE DESPEJADO] Descarga el Manifiesto NOX-9 en el terminal del fondo",
    ),
    "cv_banner_a1_manifest_taken": (
        "[MANIFIESTO NOX-9] Misty corre peligro — Vuelve rápido a su azotea en Little China",
        "[MANIFIESTO NOX-9] La tienda de Misty es un objetivo — Regresa a su azotea",
    ),
    "cv_banner_a1_complete": (
        "[ACT I COMPLETE] +2,500 E$, +900 XP — Next Chapter: Badlands Bunker & NOX-9B",
        "[ACTO I COMPLETADO] +2.500 €$, +900 XP — Próximo capítulo: Búnker en las Badlands y NOX-9B",
    ),
    "cv_banner_a1_vault_locked": (
        "[ACCESO BLOQUEADO] Usa el santo y seña con el centinela o abate a la célula del muelle",
        "[TERMINAL SELLADO] Engaña al centinela con la clave o neutraliza primero a la célula",
    ),
    "cv_hub_a1_cooler": ("Cryogenic Blood Cooler", "Refrigerador de Plasma Criogénico"),
    "cv_act_a1_inspect_cooler": ("Inspect cryogenic blood flasks", "Examinar matraces de sangre criogénica"),
    "cv_hub_a1_shrine": ("Inverted Tarot Marker", "Marca Ocultista de La Sacerdotisa"),
    "cv_act_a1_inspect_shrine": ("Inspect inverted High Priestess card", "Examinar La Sacerdotisa invertida"),
    "cv_hub_a1_relay": ("Biotechnica Telemetry Relay", "Relé de Telemetría Biotechnica"),
    "cv_act_a1_inspect_relay": ("Decrypt Little China coordinate trace", "Descifrar coordenadas de Little China"),
    "cv_hub_valdes_title": ("Dr. Adrián Valdés — Ex-Biotechnica Hematologist", "Dr. Adrián Valdés — Callejón Oculto"),
    "cv_act_talk_valdes": ("Question Dr. Adrián Valdés", "Hablar con el Dr. Adrián Valdés"),
    "cv_act_valdes_ask_role": ("What is your role in NOX-9? Why is your Biotechnica patent on it?", "¿Cuál es tu papel en el Proyecto NOX-9? ¿Por qué lleva tu firma?"),
    "cv_act_valdes_ask_sect": ("Who is The Cantor and what is your relationship with The Pale Chorus?", "¿Quién es La Cantora y qué relación tienes tú con El Coro Pálido?"),
    "cv_act_valdes_ask_leads": ("Where did they move Lucía Reyes and Mateo from Northside?", "¿Adónde llevaron a Lucía Reyes y a Mateo desde Northside?"),
    "cv_act_valdes_trust": ("[Empathy] You can still help pull them out. Give me the cipher and your files.", "[Empatía] Aún puedes ayudar a sacarlos. Dame la clave y tus archivos."),
    "cv_act_valdes_pressure": ("[Pressure] Hand over the pier cipher and your Solís notes right now.", "[Presión] Dame la clave del muelle y tus notas sobre Solís ahora mismo."),
    "cv_act_valdes_leave": ("I'm leaving for now.", "Me marcho por ahora."),
    "cv_hub_gate_title": ("Pale Chorus Sentinel — West Pier", "Centinela del Coro Pálido — Muelle Oeste"),
    "cv_act_talk_gate": ("Approach checkpoint sentinel", "Hablar con el centinela del muelle"),
    "cv_act_gate_bluff": ("[Chorus Cipher] \"The shadow drinks before dawn.\"", "[Clave de Valdés] «La sombra bebe antes del alba.»"),
    "cv_act_gate_fight": ("Your cult ends here on this pier.", "Vuestra farsa termina esta noche."),
    "cv_hub_uv_west": ("UV Tower West (365 nm)", "Torre UV Oeste (365 nm)"),
    "cv_hub_uv_east": ("UV Tower East (365 nm)", "Torre UV Este (365 nm)"),
    "cv_hub_vault_title": ("NOX-9 Cryo Manifest Terminal", "Terminal del Manifiesto NOX-9"),
    "cv_act_take_manifest": ("Download Badlands NOX-9 Shipping Manifest", "Descargar Manifiesto NOX-9 de las Badlands"),
    "cv_act_deliver_manifest": ("Give the NOX-9 Manifest to Misty (Act I Finale)", "Entregar el Manifiesto NOX-9 a Misty (Cierre Acto I)"),
    # --- Act I Dialogue Subtitles (22 lines) ---
    "cv_a1_v_kabuki_arrive": (
        "Clinical waste dumped along Kabuki creek... Better inspect every trace carefully without raising alarms yet.",
        "Descartes clínicos tirados junto al canal de Kabuki... Toca revisar la zona sin alertar a nadie todavía.",
    ),
    "cv_a1_v_clue_blood": (
        "A chilled cooler with scraped-off Biotechnica seals... Packed with synthetic porphyrin blood stabilizers.",
        "Un refrigerador portátil con sellos de Biotechnica raspados... Lleva estabilizadores de porfirina sintética.",
    ),
    "cv_a1_v_clue_tarot": (
        "An inverted High Priestess pinned between candles. Scrawled on the back is a revoked medic license in Little China.",
        "La Sacerdotisa invertida clavada entre cirios. En el reverso hay una licencia médica anulada en Little China.",
    ),
    "cv_a1_v_clue_relay": (
        "This relay link is still warm—it triangulates to a tucked-away alley in Little China. Doctor Adrián Valdés.",
        "El relé triangular sigue activo: apunta a un callejón escondido en Little China. Doctor Adrián Valdés.",
    ),
    "cv_a1_valdes_intro_01": (
        "Quiet—keep your voice down and listen! If the Pale Chorus sent you, I'd be dead already. What do you want?",
        "¡Silencio, baja la mano y escúchame! Si el Coro Pálido te hubiera enviado, ya estaría muerto... ¿Tú qué quieres?",
    ),
    "cv_a1_v_ask_nox9": (
        "I'm tracking Project NOX-9, Doc. Tell me what they're pumping into their veins and how to shut it down.",
        "Vengo por el Proyecto NOX-9, doctor. Explícame qué mete esa gente en la sangre y cómo romper sus implantes.",
    ),
    "cv_a1_valdes_ans_nox9": (
        "NOX-9 started as a Biotechnica low-light trauma serum. Street zealots corrupted it: cellular regen in darkness, lethal photolysis at 365 nm UV.",
        "Fue un suero militar de Biotechnica para supervivencia en penumbra. En la calle lo corrompieron: regenera carne de noche, pero estalla bajo luz UV a 365 nm.",
    ),
    "cv_a1_v_ask_misty": (
        "Then what's with all the Tarot theater? They're leaving stained cards behind a friend's shop in Little China.",
        "¿Y el teatro del Tarot? Están dejando cartas manchadas junto a la tienda de una amiga en Little China.",
    ),
    "cv_a1_valdes_ans_misty": (
        "That part defies my charts... Under deep dialysis they sketch Arcana and hear a choir humming from an old Badlands bunker. The Cantor claims her shop tunes to it.",
        "Eso no sé explicarlo con ciencia... En diálisis profunda dibujan Arcanos y oyen un coro desde un búnker en las Badlands. «La Cantora» cree que esa tienda resuena igual.",
    ),
    "cv_a1_valdes_give_trust": (
        "Thank you for listening instead of pulling a trigger. Use the pass phrase 'The shadow drinks before dawn' at the west pier and pull their manifest.",
        "Gracias por oírme antes de disparar. En el muelle oeste usan el santo y seña «La sombra bebe antes del alba». Úsalo y saca el manifiesto sin ruido.",
    ),
    "cv_a1_valdes_give_pressure": (
        "Enough—I'll give you everything! They guard the west pier beneath two UV towers. Their pass phrase is 'The shadow drinks before dawn'. Just let me vanish.",
        "¡Basta, te daré todo! Vigilan el muelle oeste con dos torres ultravioleta. Su contraseña es «La sombra bebe antes del alba». Déjame desaparecer después.",
    ),
    "cv_a1_v_valdes_depart": (
        "Got their cipher and the west waterfront coordinates. Time to see what The Pale Chorus is shipping.",
        "Ya tengo su clave y el punto de descarga en el muelle oeste. Vamos a ver qué esconde el Coro Pálido.",
    ),
    "cv_a1_v_pier_arrive": (
        "Waterfront cryo checkpoint with twin UV towers flanking the dock... I can bluff past the sentry or burn them down.",
        "Puesto criogénico en el muelle y dos focos UV listos para barrer el cemento... puedo colarme con la clave o abrir fuego.",
    ),
    "cv_a1_gate_challenge": (
        "Halt right there, warmblood. Nobody steps onto the cryo pier without speaking The Cantor's veil.",
        "Alto ahí, carne tibia. Nadie cruza el muelle criogénico de noche sin cantar el velo de La Cantora.",
    ),
    "cv_a1_v_gate_bluff": (
        "The shadow drinks before dawn. Doctor Valdés sent me to verify the night-shift cryo manifest.",
        "La sombra bebe antes del alba. Me envía el doctor Valdés para revisar el manifiesto del relevo nocturno.",
    ),
    "cv_a1_gate_bluff_ok": (
        "May the cold keep you, initiate. The far terminal is unlocked for handoff—don't linger near the vats.",
        "Que el frío te guarde, iniciado. El terminal del fondo sigue abierto para el relevo, pero no toques los tanques.",
    ),
    "cv_a1_gate_hostile": (
        "Intruder on the pier! Seal the vats and drain every last drop from their veins!",
        "¡Intruso en el embarcadero! ¡Sellad las válvulas y arrancadle hasta la última gota!",
    ),
    "cv_a1_v_manifest_taken": (
        "Damn it... The manifest points out to the Badlands and tags Misty's shop as 'Nexus of Silence'. Gotta warn her fast.",
        "Mierda... El manifiesto apunta a las Badlands y marca la tienda de Misty como «Nexo de Silencio». Tengo que avisarle ya.",
    ),
    "cv_a1_misty_debrief_stealth": (
        "I felt you return in stillness, V. You pried their secrets loose without spilling extra blood on the dock.",
        "Sentí que volvías en calma, V. Lograste arrancarle sus secretos al Coro sin derramar más sangre en el muelle.",
    ),
    "cv_a1_misty_debrief_combat": (
        "I saw violet arc light tear through the harbor fog, V. I'm just glad you're standing safe under my lanterns again.",
        "Vi el resplandor violeta recortar la niebla sobre el puerto, V. Me alivia tenerte de pie otra vez bajo mis faroles.",
    ),
    "cv_a1_misty_debrief_badlands": (
        "This manifest links Biotechnica straight to The Devil and Death. Take this suppressed pistol and your Eddies for what's ahead.",
        "Este manifiesto une a Biotechnica con las cartas de El Diablo y La Muerte. Toma esta pistola silenciada y tus edis para lo que viene.",
    ),
    "cv_a1_misty_cliffhanger": (
        "Wait... those dreams aren't pure chemistry after all. If The Cantor comes for my shop, our path leads straight into the Badlands.",
        "Espera... los sueños del patio no hablan solo de química. Si «La Cantora» viene a por mi tienda, nos veremos en las Badlands.",
    ),
    # ------------------------------------------------------------------
    # v0.5.0 REBOOT PROLOGUE: LA LUNA MANCHADA (cv_r2_*)
    # ------------------------------------------------------------------
    "cv_quest_r2_title": (
        "Crimson Veil: The Stained Moon",
        "Velo Carmesí: La Luna Manchada",
    ),
    "cv_conv_misty_title": (
        "Misty's Esoterica — Urgent Notice",
        "Misty's Esoterica — Aviso urgente",
    ),
    "cv_sms_r2_call_recap": (
        "V, thanks for picking up. Don't touch the card at the back alley door without scanning it first. I'm waiting right beside the candles behind Esoterica.",
        "V, gracias por contestar. No toques la carta de la puerta trasera sin escanearla antes. Te espero junto a los cirios, en el callejón de Esoterica.",
    ),
    "cv_obj_r2_01": (
        "Go to Esoterica's back alley",
        "Acude al callejón trasero de Esoterica",
    ),
    "cv_desc_r2_01": (
        "Misty called in panic after finding an eerie shrine with six damp wax candles and a darkly stained Tarot card outside Esoterica's back entrance in Watson.",
        "Misty llamó asustada tras encontrar un altar improvisado con media docena de cirios derretidos por la humedad y una sola carta del Tarot manchada frente a la puerta trasera de Esoterica.",
    ),
    "cv_obj_r2_02": (
        "Scan the stained card and speak with Misty",
        "Escanea la carta manchada y habla con Misty",
    ),
    "cv_desc_r2_02": (
        "Use your Kiroshi optics to analyze the dark stain on the Moon Tarot card and ask Misty everything she knows about Lucía, Mateo, and the surveillance outside her shop.",
        "Analiza la mancha de la carta de La Luna con tus ópticas Kiroshi y pregunta a Misty todo lo que sabe sobre Lucía, Mateo y la vigilancia frente a su tienda.",
    ),
    "cv_obj_r2_03": (
        "Meet Misty on the rooftop at 22:00",
        "Sube a la azotea con Misty a las 22:00",
    ),
    "cv_desc_r2_03": (
        "Misty asked you to wait until nightfall and meet her on Esoterica's rooftop away from prying eyes so she can show you everything Lucía told her before vanishing.",
        "Misty te pidió subir a la azotea de Esoterica cuando anochezca del todo, lejos de oídos indiscretos, para enseñarte todo lo que Lucía le contó antes de desaparecer.",
    ),
    "cv_obj_r2_04": (
        "Infiltrate the Northside oilfields shrine",
        "Investiga los depósitos de Northside de noche",
    ),
    "cv_desc_r2_04": (
        "Oily petrochemical grit trapped in candle wax along The Tower's edge points to an industrial shrine in the Northside oilfields. Overload the UV emitter and defeat The Pale Chorus guards.",
        "La gravilla aceitosa y el residuo petroquímico en el borde de La Torre señalan un santuario en los depósitos abandonados de Northside. Sobrecarga el emisor UV y neutraliza a la escolta.",
    ),
    "cv_obj_r2_05": (
        "Search the Northside altar for clues on Lucía",
        "Registra el santuario en busca de pruebas de Lucía",
    ),
    "cv_desc_r2_05": (
        "With the sentries down, search the medical crates beside the altar for physical proof of where Lucía Reyes was taken.",
        "Despejado el perímetro, revisa las cajas médicas junto al altar para averiguar adónde trasladaron a Lucía Reyes.",
    ),
    "cv_obj_r2_06": (
        "Return to Misty on the rooftop with the proof",
        "Vuelve con Misty a la azotea con las pruebas",
    ),
    "cv_desc_r2_06": (
        "You found an empty NOX-9 plasma vial and a torn transport slip proving Lucía is alive. Bring the evidence back to Misty on Esoterica's rooftop.",
        "Recuperaste un vial vacío de plasma NOX-9 y un recibo rasgado que demuestra que Lucía sigue viva. Lleva las pruebas a Misty en la azotea de Esoterica.",
    ),
    "cv_desc_r2_done": (
        "Prologue complete. Lucía Reyes is alive in the hands of The Pale Chorus, supplied with experimental NOX-9 plasma. Next leads point toward the batch's creator, Dr. Adrián Valdés.",
        "Prólogo completado. Lucía Reyes sigue con vida en manos del Coro Pálido, abastecido con plasma experimental NOX-9. El siguiente rastro apunta al responsable del lote médico, el doctor Adrián Valdés.",
    ),
    "cv_mappin_r2_alley": (
        "Esoterica Alley (Misty)",
        "Callejón de Esoterica (Misty)",
    ),
    "cv_mappin_r2_rooftop": (
        "Esoterica Rooftop (22:00)",
        "Azotea de Esoterica (22:00)",
    ),
    "cv_mappin_r2_oilfields": (
        "Northside Oilfields (Pale Chorus)",
        "Depósitos de Northside (Coro Pálido)",
    ),
    "cv_mappin_r2_debrief": (
        "Esoterica Rooftop (Return to Misty)",
        "Azotea de Esoterica (Regresar con Misty)",
    ),
    "cv_shard_r2_lucia_name": (
        "Personal File — Lucía Reyes & The Moon Code",
        "Ficha Personal — Lucía Reyes y el código de La Luna",
    ),
    "cv_shard_r2_lucia_text": (
        "KABUKI // MISTY'S ESOTERICA BACK ALLEY\\n"
        "Subject: Lucía Reyes (23), green coat, sweeps Esoterica's storefront and lives at a Kabuki boarding house.\\n"
        "Status: Missing for three nights after accepting free night-shift pulmonary therapy.\\n"
        "Secret Tarot Sign: Two fingernail notches on the bottom-left corner of The Moon — 'Awake in the dark, unable to face the light.'\\n"
        "Northside Slip: 'Subject L-14 — Transfer before pier shift change.' Confirms Lucía is alive.",
        "KABUKI // CALLEJÓN DE MISTY'S ESOTERICA\\n"
        "Sujeto: Lucía Reyes (23 años), abrigo verde, suele barrer el escaparate de Esoterica y vive en una pensión de Kabuki.\\n"
        "Estado: Lleva tres noches desaparecida tras aceptar un supuesto tratamiento pulmonar nocturno gratuito.\\n"
        "Código del Arcano: Dos muescas minúsculas de uña en la esquina inferior izquierda de La Luna — «Estoy despierta en la oscuridad, pero no puedo salir a la luz».\\n"
        "Recibo de Northside: «Sujeto L-14 — Trasladarla antes del relevo del muelle». Confirma que Lucía sigue con vida.",
    ),
    "cv_shard_r2_porphyria_name": (
        "Kiroshi Forensics — Synthetic Hemoglobin & NOX-9 Porphyrins",
        "Análisis Kiroshi — Hemoglobina Sintética y Porfirinas NOX-9",
    ),
    "cv_shard_r2_porphyria_text": (
        "BIOTECHNICA / UNREGISTERED BATCH NOX-9\\n"
        "Sample: Dark stain lifted from The Moon card outside Esoterica.\\n"
        "Composition: Synthetic hemoglobin carrier mixed with experimental hematological stabilizer and extreme reactive porphyrin concentration.\\n"
        "Clinical Effect: Sustains oxygenation at night, yet triggers severe internal burns and cellular necrosis under 365 nm UV or direct sunlight.\\n"
        "Recovered Hardware: Custom pistol 'Velo Silente' loaded with cold-light ammunition.",
        "BIOTECHNICA / LOTE NO REGISTRADO NOX-9\\n"
        "Muestra: Mancha oscura analizada sobre la carta de La Luna.\\n"
        "Composición: Hemoglobina sintética mezclada con un estabilizador experimental y traza extrema de porfirinas reactivas.\\n"
        "Efecto clínico: Mantiene el metabolismo activo de noche, pero provoca quemaduras internas graves y colapso celular bajo luz UV de 365 nm o sol directo.\\n"
        "Equipo recuperado: Pistola modificada «Velo Silente» con munición de luz fría.",
    ),
    "cv_shard_r2_missing_name": (
        "Watson Disappearances — Mateo & Street Surveillance",
        "Desapariciones en Watson — Mateo y vigilancia callejera",
    ),
    "cv_shard_r2_missing_text": (
        "NEIGHBORHOOD WITNESS NOTES // MISTY OLSZEWSKI\\n"
        "- Mateo (Northside dock technician): Vanished three days before Lucía after avoiding sunlight and demanding his clinical dosage file.\\n"
        "- Two unattached neighborhood youths disappeared under similar nighttime fever symptoms.\\n"
        "- Street Surveillance: An unmarked black van idled opposite Esoterica two nights in a row before someone disabled the alley lamps to place the candles.",
        "NOTAS DE TESTIGO // MISTY OLSZEWSKI\\n"
        "- Mateo (técnico nocturno del muelle de Northside): Desapareció tres días antes que Lucía tras empezar a evitar la luz del sol y exigir su historial de dosis.\\n"
        "- Otros dos jóvenes del barrio sin familia cercana faltaron días antes con síntomas parecidos.\\n"
        "- Vigilancia: Un furgón negro sin matrícula aparcó dos madrugadas frente al callejón e inutilizaron las farolas antes de colocar los cirios.",
    ),
    "cv_shard_r2_northside_name": (
        "Field Report — Northside Oilfields & The Pale Chorus",
        "Informe de Campo — Depósitos de Northside y El Coro Pálido",
    ),
    "cv_shard_r2_northside_text": (
        "NORTHSIDE INDUSTRIAL SHRINE // PROLOGUE TRAIL\\n"
        "Rooftop Spread: The Moon, Inverted Hanged Man, and The Tower laid alongside Lucía's notes about The Pale Chorus.\\n"
        "Wax Trace on The Tower: Oily petrochemical grit lifted from the wax edge points directly to the abandoned Northside oilfields.\\n"
        "Hostile Group: 'The Pale Chorus' — armed night sentries using UV emitters to test and guard transfers.\\n"
        "Next Lead: Trace batch signature NOX-9 to locate the original researcher and intercept Lucía's transfer.",
        "SANTUARIO DE NORTHSIDE // PISTA DEL PRÓLOGO\\n"
        "Tirada en la azotea: La Luna, El Colgado invertido y La Torre junto a los apuntes de Lucía sobre El Coro Pálido.\\n"
        "Rastro en La Torre: Gravilla aceitosa y residuo petroquímico atrapado en la cera señalan los depósitos abandonados de Northside.\\n"
        "Facción detectada: «El Coro Pálido», vigías nocturnos armados con emisores UV de contención.\\n"
        "Siguiente paso: Seguir la firma farmacéutica del lote NOX-9 para encontrar al investigador responsable y rescatar a Lucía.",
    ),
    "cv_int_r2_alley": (
        "Inspect stained Tarot & talk to Misty",
        "Escanear altar y hablar con Misty",
    ),
    "cv_int_r2_alley_qa": (
        "Ask Misty about the missing people",
        "Preguntar a Misty por lo ocurrido",
    ),
    "cv_int_r2_evidence": (
        "Search shrine crates (NOX-9 & slip)",
        "Registrar cajas médicas (vial y recibo)",
    ),
    "cv_choice_r2_missing": (
        "[Investigate] Who else vanished before Lucía?",
        "[Investigar] ¿Quiénes más desaparecieron antes que Lucía?",
    ),
    "cv_choice_r2_watched": (
        "[Investigate] Why do you think someone is watching you?",
        "[Investigar] ¿Por qué crees que alguien te vigila?",
    ),
    "cv_choice_r2_chorus": (
        "[Investigate] Did Lucía name a clinic or group?",
        "[Investigar] ¿Lucía mencionó alguna clínica o grupo?",
    ),
    "cv_choice_r2_rooftop_now": (
        "Stay out of sight — let's meet on the rooftop at 22:00.",
        "Quédate a cubierto; nos vemos arriba a las diez.",
    ),
    "cv_choice_r2_roof_chem": (
        "It isn't magic or a curse, Misty — it's dirty chemistry.",
        "No es ningún hechizo ni pacto, Misty: es química sucia.",
    ),
    "cv_choice_r2_roof_cards": (
        "How do these three cards connect to Lucía's notebooks?",
        "¿Cómo conectabas estos tres arcanos con sus cuadernos?",
    ),
    "cv_choice_r2_roof_tower": (
        "Wait — turn The Tower over and check the wax on the edge.",
        "Espera — dale la vuelta a La Torre y mira la cera del borde.",
    ),
    "cv_banner_r2_call": (
        "[HOLOCALL] Misty needs help at Esoterica's back alley",
        "[HOLOMENSAJE] Misty te espera en el callejón trasero de Esoterica",
    ),
    "cv_banner_r2_scan_done": (
        "[KIROSHI FORENSICS] Synthetic NOX-9 porphyrins — The Moon belongs to Lucía",
        "[ESCÁNER KIROSHI] Hemoglobina sintética y porfirinas NOX-9 — La carta es de Lucía",
    ),
    "cv_banner_r2_rooftop_wait": (
        "[NIGHTFALL 22:00] Head up to Esoterica's rooftop when night falls",
        "[22:00] Sube a la azotea de Esoterica cuando anochezca",
    ),
    "cv_banner_r2_proof_taken": (
        "[PROOF FOUND] Lucía is alive (Subject L-14) — Return to Misty on the rooftop",
        "[PRUEBA RECUPERADA] Lucía sigue viva (Sujeto L-14) — Vuelve con Misty",
    ),
    "cv_banner_r2_prologue_done": (
        "[PROLOGUE COMPLETE] +1.200 €$ · +500 XP · 'Velo Silente' · Codex Updated",
        "[PRÓLOGO COMPLETADO] +1.200 €$ · +500 EXP · «Velo Silente» · Códice actualizado",
    ),
    "cv_r2_call_misty_01": (
        "V? Thank God you picked up. I need you at Esoterica's back alley as soon as you can.",
        "¿V? Gracias a Dios que coges. Necesito que vengas al callejón trasero de Esoterica en cuanto puedas.",
    ),
    "cv_r2_call_v_01": (
        "Misty? You sound shaken. Did something happen at the shop?",
        "¿Misty? Suenas asustada. ¿Ha pasado algo en la tienda?",
    ),
    "cv_r2_call_misty_02": (
        "Friends and neighbors have been vanishing for days without a trace, and I feel like someone is watching me. This morning I found a strange shrine outside my door: half a dozen damp melted candles and a single Tarot card covered in a dark stain.",
        "Varias amigas y vecinos del barrio llevan días desapareciendo sin dejar rastro, y siento que alguien me vigila. Esta mañana encontré un extraño altar delante de la puerta: media docena de cirios derretidos por la humedad y una sola carta del Tarot cubierta por una mancha oscura.",
    ),
    "cv_r2_call_v_02": (
        "Don't let anyone inside and stay where you can be seen. I'm heading to Watson right now.",
        "No dejes entrar a nadie y quédate donde pueda verte. Voy para Watson ahora mismo.",
    ),
    "cv_r2_alley_misty_warn": (
        "Don't touch it yet, V. Scan it first. They left it here at night, before dawn, without anyone seeing who it was.",
        "No la toques todavía, V. Escanéala primero. La dejaron de noche, antes del alba, sin que nadie viera quién fue.",
    ),
    "cv_r2_alley_v_scan": (
        "That's not normal blood, Misty. It's synthetic hemoglobin mixed with an experimental stabilizer, and it carries an extreme trace of reactive porphyrins. Whoever bled onto this card would suffer severe internal burns under direct sunlight.",
        "No es sangre normal, Misty. Es hemoglobina sintética mezclada con un estabilizador experimental, y tiene una traza altísima de porfirinas reactivas. Quien sangró sobre esta carta sufriría quemaduras internas graves si le diera el sol directo.",
    ),
    "cv_r2_alley_misty_lucia_01": (
        "It belongs to Lucía.",
        "Es de Lucía.",
    ),
    "cv_r2_alley_v_lucia_01": (
        "The girl in the green coat who sweeps your storefront sometimes?",
        "¿La chica del abrigo verde que a veces barre tu escaparate?",
    ),
    "cv_r2_alley_misty_lucia_02": (
        "Yes. Look at the bottom left corner, where someone carved two tiny fingernail notches. I taught her that last month, when she told me nightmares kept her awake. We played that each Arcanum was a secret word. The Moon means: 'I am awake in the darkness, yet I cannot step into the light.' She hasn't returned to her boarding house in Kabuki for three nights.",
        "Sí. Mira la esquina inferior izquierda, donde alguien hizo dos muescas minúsculas con una uña. Se lo enseñé el mes pasado, cuando me dijo que tenía pesadillas y no podía dormir. Jugábamos a que cada Arcano era una palabra secreta. La Luna significa: «Estoy despierta en la oscuridad, pero no puedo salir a la luz». Lleva tres noches sin aparecer por su pensión de Kabuki.",
    ),
    "cv_r2_alley_v_candles": (
        "If someone left this behind, it wasn't just scavengers grabbing people off the street. Scavs don't leave candles or Tarot cards. What else do you know about the others?",
        "Si alguien dejó esto aquí, no fue un simple secuestro de carroñeros. Los carroñeros no dejan velas ni cartas del Tarot. ¿Qué más sabes sobre las otras desapariciones?",
    ),
    "cv_r2_alley_qa_missing_v": (
        "On the call you said others vanished before Lucía. Who are they?",
        "Dijiste por teléfono que había más desaparecidos antes que Lucía. ¿Quiénes son?",
    ),
    "cv_r2_alley_qa_missing_m": (
        "Mateo, a night-shift dock tech from Northside, vanished three days before Lucía. He began avoiding daylight and never came back after saying he'd demand his medical file. Before him, two other neighborhood youths vanished.",
        "Mateo, un técnico nocturno del muelle de Northside, desapareció tres días antes que Lucía. Empezó a evitar la luz del día y no volvió tras decir que exigiría su historial médico. Antes que él faltaron otros dos jóvenes del barrio.",
    ),
    "cv_r2_alley_qa_watched_v": (
        "Why do you say someone has been watching you from the street?",
        "¿Por qué dices que alguien te está vigilando desde la calle?",
    ),
    "cv_r2_alley_qa_watched_m": (
        "Two nights in a row a black van with no plates idled across from the alley with its headlights dead. And last night someone killed the streetlights on this block right before leaving the candles.",
        "Dos madrugadas seguidas aparcó un furgón negro sin matrícula frente al callejón, con las luces apagadas. Y anoche alguien inutilizó las farolas de esta acera justo antes de dejar los cirios.",
    ),
    "cv_r2_alley_qa_chorus_v": (
        "Did Lucía ever give you a name or clinic before she vanished?",
        "¿Lucía llegó a darte algún nombre o clínica antes de desaparecer?",
    ),
    "cv_r2_alley_qa_chorus_m": (
        "She only told me she'd taken free night-shift treatment at a satellite clinic to heal her lungs from the smog. A week later she dreaded sunrise and whispered something about The Pale Chorus.",
        "Solo me dijo que aceptó un tratamiento nocturno gratuito en una clínica satélite para curarse los pulmones del smog. A la semana siguiente temía al amanecer y susurraba algo sobre El Coro Pálido.",
    ),
    "cv_r2_alley_misty_rooftop": (
        "Come up to the rooftop with me once true night falls. Down here there is too much noise and too many eyes. At ten I'll show you everything Lucía told me before she disappeared.",
        "Sube conmigo a la azotea cuando anochezca del todo. Abajo hay demasiado ruido y demasiados ojos. A las diez te enseño todo lo que Lucía me contó antes de desaparecer.",
    ),
    "cv_r2_alley_v_rooftop": (
        "All right. Stay inside out of sight. I'll see you on the roof at ten.",
        "De acuerdo. Quédate a cubierto dentro. Nos vemos en la azotea a las diez.",
    ),
    "cv_r2_roof_misty_intro": (
        "Thank you for coming up on time, V. I laid the cards beside Lucía's notes: The Moon, Inverted Hanged Man, and The Tower. If someone took her after leaving that sign, they aren't far from Watson.",
        "Gracias por subir a tiempo, V. He extendido las cartas junto a los apuntes de Lucía: La Luna, El Colgado invertido y La Torre. Si alguien se la llevó tras dejar esa señal, no está lejos de Watson.",
    ),
    "cv_r2_roof_misty_uv": (
        "Look under this three hundred sixty-five nanometer UV lamp. On the back of The Moon there's a chemical transfer stamp pointing straight to the Northside oilfields.",
        "Mira bajo esta lámpara ultravioleta de trescientos sesenta y cinco nanómetros. En el reverso de La Luna hay un sello químico de trasvase que apunta a los depósitos petrolíferos de Northside.",
    ),
    "cv_r2_roof_v_depart": (
        "Northside oilfields, after dark with zero witnesses. I'm heading there now to find Lucía before they move her.",
        "Depósitos de Northside, de noche y sin testigos. Voy para allá a buscar a Lucía antes de que la muevan.",
    ),
    "cv_r2_oil_v_arrive": (
        "I see their makeshift shrine between the tanks and an ultraviolet emitter sweeping the entrance. Time to overload that rig and clear the yard.",
        "Veo el santuario improvisado entre los tanques y un emisor ultravioleta cubriendo la entrada. Voy a apagar ese foco y limpiar el perímetro.",
    ),
    "cv_r2_oil_misty_radio": (
        "V, I hear electrical static tearing across your comms. Break the emitter housing if they pin you down, and search the medical crates beside the altar.",
        "V, detecto un pico eléctrico en tus ópticas. Rompe la caja del emisor si te cierran el paso y revisa las cajas médicas que dejaron junto al altar.",
    ),
    "cv_r2_oil_v_note": (
        "An empty clinical vial of NOX-9 plasma and a torn transport slip stamped earlier this morning: Subject L-14, Lucía Reyes, transfer before pier shift change. She's still alive, Misty. Heading back to the roof with the proof.",
        "Un vial clínico vacío de plasma NOX-9 y un recibo de transporte rasgado de esta misma madrugada: Sujeto L-14, Lucía Reyes, trasladarla antes del relevo del muelle. Sigue viva, Misty. Vuelvo a la azotea con las pruebas.",
    ),
    "cv_r2_debrief_m1": (
        "She's still alive? Thank heaven, V. Seeing that medical batch code and transport slip proves we aren't too late.",
        "¿Sigue viva? Gracias al cielo, V. Ver el código de su lote médico y ese recibo confirma que no llegamos tarde.",
    ),
    "cv_r2_debrief_v1": (
        "The abductors moved her before dawn, but they left behind a batch of NOX-9 plasma and this custom pistol loaded with cold-light rounds. Whoever synthesizes that compound will lead us straight to Lucía and Mateo.",
        "Los secuestradores la sacaron antes del alba, pero dejaron atrás un cargamento de plasma NOX-9 y esta pistola modificada con cargador de luz fría. Quien fabrique ese compuesto nos llevará directo hasta Lucía y Mateo.",
    ),
    "cv_r2_debrief_m2": (
        "Take your Eddies and keep that pistol close. Keep the updated codex file and catch your breath; as soon as we trace who signs the NOX-9 batch, we go after Lucía.",
        "Toma tus edis y guarda ese arma cerca. Quédate el archivo del códice actualizado y descansa un momento; en cuanto descifremos quién firma el lote NOX-9 iremos a por Lucía.",
    ),
    "cv_r2_roof_open_m1": (
        "Thank you for coming at ten, V. Up here the rain washes out the noise below, and no one is listening.",
        "Gracias por venir a las diez, V. Aquí arriba la lluvia apaga el ruido de abajo y nadie escucha.",
    ),
    "cv_r2_roof_open_m2": (
        "Lucía asked me to lay out these cards the last time she came up here: The Moon, The Hanged Man inverted, and The Tower. In her notes she wrote of The Pale Chorus, people hiding from daylight somewhere near Northside.",
        "Lucía me pidió que le leyera estas cartas la última vez que subió: La Luna, El Colgado invertido y La Torre. En sus apuntes hablaba de El Coro Pálido, gente que se oculta de la luz cerca de Northside.",
    ),
    "cv_r2_roof_open_m3": (
        "She asked me if someone could give away a piece of themselves just so they wouldn't die alone in this city... I wish I'd realized then she wasn't speaking in metaphors.",
        "Me preguntó si uno puede entregar algo de sí mismo para no morir solo en esta ciudad... Ojalá hubiera entendido entonces que no me hablaba de una metáfora.",
    ),
    "cv_r2_roof_chem_v": (
        "Misty, this isn't magic or a Tarot curse. It's dirty chemistry: synthetic hemoglobin and reactive porphyrins that boil under ultraviolet light.",
        "Misty, no es ningún hechizo ni un pacto de Tarot. Es química sucia: hemoglobina sintética y porfirinas reactivas que hierven bajo los rayos ultravioleta.",
    ),
    "cv_r2_roof_chem_m": (
        "I know, V... but the ones who accept that blood aren't only running from sickness. They're looking to belong to something that won't cast them aside at dawn, and that is how that cult traps them.",
        "Lo sé, V... pero quienes aceptan esa sangre no solo buscan huir de la enfermedad. Buscan pertenecer a algo que no los descarte al amanecer, y ahí es donde esa secta los atrapa.",
    ),
    "cv_r2_roof_cards_v": (
        "Tell me how you read those three cards alongside her notebooks: The Moon, The Hanged Man inverted, and The Tower.",
        "Dime cómo conectabas estos tres arcanos con sus cuadernos: La Luna, El Colgado invertido y La Torre.",
    ),
    "cv_r2_roof_cards_m": (
        "The Moon is the nocturnal secret Lucía was already carrying in her veins. The Hanged Man inverted is the false vow of rebirth through silent sacrifice. And The Tower... is the fall when that promised salvation collapses.",
        "La Luna es el secreto nocturno que Lucía ya guardaba en su piel. El Colgado invertido es la promesa de renacer pagando un sacrificio en silencio. Y La Torre... es la caída cuando esa falsa salvación se derrumba.",
    ),
    "cv_r2_roof_tower_v": (
        "Wait, Misty, turn The Tower over. There's oily grit and petrochemical residue pressed into the wax along the edge... that comes straight from the abandoned Northside oilfields.",
        "Espera, Misty, dale la vuelta a La Torre. La cera del borde tiene gravilla aceitosa y residuo petroquímico... esto viene directo de los depósitos abandonados de Northside.",
    ),
    "cv_r2_roof_promise_m": (
        "If they corner you in Northside, remember the ultraviolet light. Bring me proof that Lucía is still alive, V... don't let her become another shadow in that Chorus.",
        "Si te cruzas con ellos en Northside, recuerda la luz ultravioleta. Tráeme pruebas de que Lucía sigue viva, V... no dejes que se convierta en otra sombra más del Coro.",
    ),
    # --- v0.8.0 Act I Part 1 Subtitles (21 lines: Bridge Holocall -> Kabuki -> Dr. Valdés) ---
    "cv_a1_r2_call_m1": (
        "V, got a second? I passed the NOX-9-K4 batch code and Lucía's slip from Northside over to Vik. An old contact of his ran that formula against retired Biotechnica patents—the only hematologist who designed and signed off on it is a Dr. Adrián Valdés.",
        "V, ¿tienes un segundo? Le pasé a Vik el código del lote NOX-9-K4 y el recibo de Lucía que sacaste de Northside. Un viejo contacto suyo cruzó esa fórmula con patentes retiradas de Biotechnica: el único hematólogo que diseñó y firmó ese compuesto es un tal doctor Adrián Valdés.",
    ),
    "cv_a1_r2_call_v1": (
        "Is this Valdés working for The Pale Chorus or hiding from them? If his name is on the formula, he'll know who took Lucía and Mateo.",
        "¿Y ese Valdés trabaja para El Coro Pálido o se esconde de ellos? Si firmó la fórmula del lote, sabrá quién se llevó a Lucía y a Mateo.",
    ),
    "cv_a1_r2_call_m2": (
        "Just a few minutes ago a live telemetry ping from that exact NOX-9-K4 batch fired near an abandoned dock along the Kabuki Canal. Check whatever they dumped there—it should lead straight to Valdés before the Chorus scrubs his trail.",
        "Justo hace unos minutos saltó un pulso de telemetría del mismo lote NOX-9-K4 junto a un embarcadero abandonado del Canal de Kabuki. Ve a revisar lo que hayan tirado allí: seguro que nos lleva directo hasta Valdés antes de que el Coro borre su rastro.",
    ),
    "cv_a1_r2_call_v2": (
        "Heading to the Kabuki Canal right now. If Valdés is still in Watson, I'll find him.",
        "Voy para el Canal de Kabuki ahora mismo. Si Valdés sigue en Watson, lo voy a encontrar.",
    ),
    "cv_a1_r2_kabuki_arrive": (
        "Drainage dock down by the Kabuki Canal... There's the dumped medical gear, the candles, and an active relay. Let's inspect every trace.",
        "Embarcadero de desagüe en el Canal de Kabuki... Ahí están los descartes médicos, las velas y un relé todavía encendido. Vamos a revisar cada pista.",
    ),
    "cv_a1_r2_clue_cooler": (
        "A portable dialysis cooler with scraped Biotechnica seals. Inside are empty NOX-9-K4 flasks and dosing tags for Subject L-14, Lucía Reyes, and Subject M-09, Mateo. That's Valdés's exact formula.",
        "Un refrigerador de diálisis portátil con sellos de Biotechnica raspados. Dentro hay matraces vacíos del lote NOX-9-K4 y etiquetas de dosificación para el Sujeto L-14, Lucía Reyes, y el Sujeto M-09, Mateo. Esta es la misma fórmula de Valdés.",
    ),
    "cv_a1_r2_clue_tarot": (
        "The High Priestess inverted, pinned between damp candles... and stapled to the back is Dr. Adrián Valdés's revoked corporate medical license. Not just a shrine—The Pale Chorus left it as a threat to prove they know he's still in Watson.",
        "La Sacerdotisa invertida clavada entre cirios húmedos... y grapada al reverso está la licencia médica anulada del doctor Adrián Valdés. No es un altar cualquiera: El Coro Pálido la dejó aquí como amenaza para demostrarle que saben que sigue en Watson.",
    ),
    "cv_a1_r2_clue_relay": (
        "This Biotechnica telemetry relay is still warm and pinging. Just triangulated the return beacon to a hidden back alley in Little China. I've got Dr. Valdés's exact hideout.",
        "Este relé de telemetría de Biotechnica sigue caliente y rebotando señal. Acaba de triangular el retorno hacia un callejón escondido en Little China. Ya tengo el escondite exacto del doctor Valdés.",
    ),
    "cv_a1_r2_valdes_intro": (
        "Stop—don't take another step! If The Cantor sent you to silence me, pull the trigger and get it over with.",
        "¡Quieto, no des un paso más! Si te envía La Cantora para callarme, dispara de una vez y acaba con esto.",
    ),
    "cv_a1_r2_v_intro": (
        "Easy, Dr. Valdés. I'm not with The Pale Chorus. I'm here about the NOX-9-K4 batch from Northside—and Lucía Reyes and Mateo. We know your name is on that formula.",
        "Baja el pulso, doctor Valdés. No vengo del Coro Pálido. Vengo por el lote NOX-9-K4 de Northside... y por Lucía Reyes y Mateo. Sabemos que tú firmaste esa fórmula.",
    ),
    "cv_a1_r2_v_ask_role": (
        "Start with your part in this. What is NOX-9 really, and why does it carry your Biotechnica patent?",
        "Empieza por tu papel en todo esto. ¿Qué es exactamente el NOX-9 y por qué lleva tu firma de Biotechnica?",
    ),
    "cv_a1_r2_valdes_ans_role": (
        "I engineered NOX-9 six years ago to save workers with smog-ruined lungs who couldn't afford corpo chrome. It boosted oxygen and tissue repair, but trapped lethal porphyrins—sunlight or 365 nm UV boils you from within. Biotechnica buried the trial and fired me. Broke, I sold my patents and samples to Dr. Helena Solís believing she'd finish the cure.",
        "Diseñé el NOX-9 hace seis años para salvar a trabajadores con pulmones destrozados por el smog sin condenarlos a pagar implantes corporativos. Aumentaba el oxígeno en sangre y regeneraba tejido, pero acumulaba porfirinas letales: cualquier luz solar o ultravioleta de 365 nm te abrasa por dentro. Biotechnica enterró el proyecto y me echó a la calle. Arruinado, le vendí mis patentes y muestras a la doctora Helena Solís creyendo que terminaría la cura.",
    ),
    "cv_a1_r2_v_ask_sect": (
        "And how did your lung serum end up in the hands of a cult leaving Tarot cards and hunting people after dark?",
        "¿Y cómo acabó tu suero médico en manos de una secta que deja cartas del Tarot y caza gente de noche?",
    ),
    "cv_a1_r2_valdes_ans_sect": (
        "Helena Solís now calls herself The Cantor and twisted my failure into The Pale Chorus. They lure desperate kids like Lucía and Mateo into free night clinics, hook them on weekly dialysis, and turn fear of sunrise into a cage and liturgy. I... kept making stabilizers for months out of guilt and fear. When I saw them abducting anyone who tried to quit, I ran here. That's why they pinned the inverted High Priestess in Kabuki—to warn me they're watching.",
        "Helena Solís se hace llamar ahora La Cantora y convirtió mi fracaso en El Coro Pálido. Atraen a chicos desesperados como Lucía y Mateo con clínicas nocturnas gratuitas, los vuelven dependientes de diálisis semanales y usan el pánico al amanecer como jaula y liturgia. Yo... seguí fabricándoles estabilizadores durante meses por culpa y por miedo a que me mataran. Cuando descubrí que secuestraban a quien intentaba dejarlo, escapé aquí. Por eso dejaron La Sacerdotisa invertida en Kabuki: para recordarme que me vigilan.",
    ),
    "cv_a1_r2_v_ask_leads": (
        "If you mixed their stabilizers, you know where they moved Lucía from Northside—and where they're holding Mateo.",
        "Si les preparabas estabilizadores, sabes adónde trasladaron a Lucía desde Northside y dónde tienen a Mateo.",
    ),
    "cv_a1_r2_valdes_ans_leads": (
        "Every newly awakened subject and transfer manifest passes first through their cryogenic checkpoint on Watson's West Pier, guarded by a night sentry and twin UV towers. From that terminal they route shipments to Helena's main bunker in the Badlands—where she claims to have purified a second-generation serum without porphyrins: NOX-9B.",
        "Todos los sujetos recién despertados y los registros de traslado pasan antes por su puesto criogénico del Muelle Oeste de Watson, custodiado por un centinela nocturno y dos torres ultravioleta. Desde ese terminal coordinan los envíos hacia el búnker central de Helena en las Badlands, donde dice haber purificado una segunda generación del suero sin porfirinas: el NOX-9B.",
    ),
    "cv_a1_r2_v_trust": (
        "You can still undo part of this, Adrián. Give me your pass codes, the pier coordinates, and your NOX-9 files. I'm pulling Lucía and Mateo out.",
        "Aún puedes arreglar parte del daño, Adrián. Dame tus claves, las coordenadas del muelle y tus notas del NOX-9. Voy a sacar a Lucía y a Mateo de ahí.",
    ),
    "cv_a1_r2_valdes_give_trust": (
        "Thank you for hearing me out before judging me. Take this shard on the desk—it holds the night-shift passphrase 'The shadow drinks before dawn', the West Pier cryo terminal coordinates, and my full NOX-9 and NOX-9B dossier. Use it to slip past the UV towers if you can.",
        "Gracias por escucharme antes de juzgarme. Toma este pincho de la mesa: lleva la contraseña del relevo nocturno, «La sombra bebe antes del alba», las coordenadas del terminal criogénico del Muelle Oeste y mi expediente completo sobre el NOX-9 y el NOX-9B. Úsalo para entrar sin alertar a las torres si puedes.",
    ),
    "cv_a1_r2_v_pressure": (
        "Your guilt won't pull Lucía out of a cryo pod. Hand over the pier pass code and everything you have on Solís right now.",
        "Tu arrepentimiento no va a sacar a Lucía de una cámara criogénica. Dame la clave del muelle y todo lo que tengas sobre Solís ahora mismo.",
    ),
    "cv_a1_r2_valdes_give_pressure": (
        "Fine—take all of it! That shard on the desk has the night-shift passphrase 'The shadow drinks before dawn', the West Pier coordinates, and all my NOX-9 and NOX-9B files. Just let me vanish before the Chorus drops into this alley.",
        "¡Está bien, llévatelo todo! En ese pincho de la mesa tienes el santo y seña nocturno, «La sombra bebe antes del alba», las coordenadas del Muelle Oeste y mis archivos del NOX-9 y el NOX-9B. Solo déjame desaparecer antes de que el Coro baje por este callejón.",
    ),
    "cv_a1_r2_v_depart": (
        "Encrypted shard secured—night-shift Chorus passphrase, West Pier coordinates, and Valdés's full dossier on Solís and NOX-9B. We've got everything we need to hit that cryo checkpoint.",
        "Pincho cifrado en mi poder: clave nocturna del Coro, coordenadas del Muelle Oeste de Watson y expediente completo de Valdés sobre Solís y el NOX-9B. Ya tenemos todo para golpear el puesto criogénico.",
    ),
    "cv_a1_r2_debrief_m1_stealth": (
        "You made it back in one piece, V—and without leaving another trail of gunfire across the docks. Valdés's cipher worked. Tell me what you pulled from that West Pier terminal.",
        "Has vuelto de una pieza, V... y sin dejar otro rastro de pólvora en el puerto. La contraseña de Valdés funcionó. Dime qué sacaste de ese terminal del Muelle Oeste.",
    ),
    "cv_a1_r2_debrief_m1_combat": (
        "I saw those violet UV flashes tearing across the harbor from up here, V. I'm just glad you're back safe. Tell me what you pulled from that West Pier terminal.",
        "Vi los destellos violetas sobre el puerto desde aquí arriba, V. Me alegra tenerte de vuelta y a salvo. Dime qué sacaste de ese terminal del Muelle Oeste.",
    ),
    "cv_a1_r2_debrief_v1": (
        "We finally have the full picture, Misty. Dr. Adrián Valdés created NOX-9 six years ago, and Dr. Helena Solís—'The Cantor'—hijacked his work to build The Pale Chorus. The pier manifest confirms they shipped Lucía Reyes and Mateo out of Watson to a sealed Biotechnica bunker in the Badlands.",
        "Ya tenemos el mapa completo, Misty. El doctor Adrián Valdés creó el NOX-9 hace seis años, pero la doctora Helena Solís —la que llaman La Cantora— le robó el proyecto para montar El Coro Pálido. El manifiesto del muelle confirma que sacaron a Lucía Reyes y a Mateo de Watson rumbo a un búnker clausurado de Biotechnica en las Badlands.",
    ),
    "cv_a1_r2_debrief_m2": (
        "So Lucía and Mateo are still alive, just out beyond the city... Wait, V—what's this entry at the bottom of the manifest? They flagged Misty's Esoterica as 'Nexus of Silence' under priority watch. They know someone is pulling the thread from here.",
        "Entonces Lucía y Mateo siguen vivos, pero fuera de la ciudad... Espera, V: ¿qué es esta nota al final del manifiesto? Han marcado Misty's Esoterica como «Nexo de Silencio» y con vigilancia prioritaria. Saben que estamos tirando del hilo desde aquí.",
    ),
    "cv_a1_r2_debrief_v2": (
        "And there's an even bigger problem. Valdés's files and the cargo logs say Solís is testing a second-generation serum called NOX-9B out in that desert bunker—without porphyrins. If she stabilizes it, ultraviolet light won't burn them anymore, and we lose our only real edge against them.",
        "Y todavía hay algo más peligroso. Según las notas de Valdés y los registros de carga, en ese búnker del desierto Solís está probando una segunda versión del suero llamada NOX-9B, sin porfirinas. Si consigue estabilizarlo, dejarán de arder con la luz ultravioleta y perderemos la única ventaja táctica que tenemos contra ellos.",
    ),
    "cv_a1_r2_debrief_m3": (
        "We can't let her finish that serum or box us in here. I'll lock down the shop with Vik and cross-check these manifest frequencies to pinpoint the exact bunker entrance in the Badlands. Take your Eddies for everything you pulled off tonight, V. The moment we crack the route, I'll call you so we can head into the desert, bring Lucía and Mateo home, and stop The Cantor for good.",
        "No podemos dejar que terminen ese suero ni que nos encierren aquí. Voy a reforzar la tienda con Vik y a cruzar estas frecuencias del manifiesto para triangular la entrada exacta del búnker en las Badlands. Toma tus edis por lo que has hecho hoy, V. En cuanto descifremos la ruta, te llamaré para cruzar al desierto, rescatar a Lucía y a Mateo y detener a La Cantora de una vez por todas.",
    ),
    "cv_a1_r2_debrief_v3": (
        "Keep the shutters down and your holo close, Misty. The second you lock down those bunker coordinates, I'm heading into the Badlands to finish The Pale Chorus.",
        "Mantén la persiana bajada y ten el móvil cerca, Misty. En cuanto tengas las coordenadas del búnker, nos vemos en las Badlands y acabamos con El Coro Pálido.",
    ),
    # =========================================================================
    # ACTO II EN BADLANDS — LITURGIA DE CENIZA (v0.9.0)
    # =========================================================================
    "cv_npc_lucia_name": ("Lucía Reyes", "Lucía Reyes"),
    "cv_npc_solis_name": ('Dr. Helena Solís ("The Cantor")', "Dra. Helena Solís («La Cantora»)"),
    "cv_npc_bunker_sentry_a_name": ("Bunker Chorus Sentinel", "Centinela del Búnker del Coro"),
    "cv_npc_bunker_sentry_b_name": ("Bunker Chorus Cryo-Guard", "Guardia Criogénico del Búnker"),
    "cv_npc_solis_guard_a_name": ("Cantor Honor Blade", "Hoja de Honor de La Cantora"),
    "cv_npc_solis_guard_b_name": ("Cantor Bioreactor Guard", "Guardia del Biorreactor NOX-9B"),
    "cv_npc_lab_stalker_a_name": ("Dialysis Wing Stalker", "Acechadora del Ala de Diálisis"),
    "cv_npc_lab_stalker_b_name": ("Cryo-Conduit Sentinel", "Centinela de Conductos"),
    "cv_npc_sub2_zealot_a_name": ("Sanguine Choir Zealot", "Fanático del Coro Carmesí"),
    "cv_npc_sub2_zealot_b_name": ("NOX-9B Sanctum Weaver", "Tejedora del Santuario NOX-9B"),
    "cv_npc_sub1_fanatic_a_name": ("Pale Chorus Dialysis Fanatic", "Fanático de Diálisis del Coro Pálido"),
    "cv_npc_sub1_fanatic_b_name": ("Pale Chorus Crypt Gunner", "Tirador de la Cripta del Coro Pálido"),
    "cv_npc_sub1_fanatic_c_name": ("Pale Chorus Blood-Blade", "Hoja Carmesí del Coro Pálido"),
    "cv_npc_sub1_fanatic_d_name": ("Pale Chorus East Sentinel", "Centinela del Ala Este"),
    "cv_npc_sub2_fanatic_c_name": ("Pale Chorus Choir Zealot", "Zelote del Coro Pálido"),
    "cv_npc_sub2_fanatic_d_name": ("Pale Chorus Crimson Butcher", "Carnicero Carmesí del Coro"),
    "cv_npc_sub2_fanatic_e_name": ("Pale Chorus Sanctum Gunner", "Fusilero del Santuario Carmesí"),
    "cv_npc_sub2_fanatic_f_name": ("Pale Chorus Staircase Warden", "Guardián de la Escalera"),
    "cv_spk_lucia": ("Lucía Reyes", "Lucía Reyes"),
    "cv_spk_solis": ("Dr. Helena Solís", "Dra. Helena Solís"),
    # --- Act II Quest Items & Iconic Weapon «Alba Carmesí» ---
    "cv_item_mateo_badge_name": (
        "Mateo's Shattered Dock Badge (M-09)",
        "Placa Rota de Mateo (Sujeto M-09)",
    ),
    "cv_item_mateo_badge_desc": (
        "Northside industrial dock technician badge split by gunfire in Biotechnica Flats. Mateo cut the convoy's cryo lines so Lucía Reyes could escape.",
        "Placa de técnico del muelle de Northside partida por disparos en Biotechnica Flats. Mateo saboteó las líneas criogénicas del convoy para que Lucía escapara.",
    ),
    "cv_item_nox9b_formula_name": (
        "Purified NOX-9B Bioreactor Synthesis",
        "Síntesis Purificada NOX-9B",
    ),
    "cv_item_nox9b_formula_desc": (
        "Second-generation Biotechnica hematology dataset stripped of phototoxic 365 nm porphyrins, allowing safe cellular recovery for Lucía and surviving Chorus initiates.",
        "Fórmula hematológica de segunda generación sin porfirinas fototóxicas a 365 nm, capaz de revertir la dependencia nocturna de Lucía y los supervivientes.",
    ),
    "cv_weapon_dawn_name": ("Crimson Dawn", "Alba Carmesí"),
    "cv_weapon_dawn_desc": (
        "Heavy Burya revolver fitted with thermal-incandescent rounds tuned to purge porphyrin contagion.",
        "Revólver pesado Burya modificado con munición térmica de espectro solar pensada para quemar implantes del Coro Pálido.",
    ),
    "cv_weapon_dawn_ability": (
        "CRIMSON DAWN: +40 Thermal Damage, +25% Crit Chance, and +40% Headshot Multiplier.",
        "ALBA CARMESÍ: +40 de daño térmico, +25 % de probabilidad de crítico y +40 % de multiplicador en cabeza.",
    ),
    # --- Act II Quest, Objectives, Descriptions & SMS ---
    "cv_quest_a2_title": (
        "Crimson Veil — Act II: Liturgy of Ash",
        "Velo Carmesí — Acto II: Liturgia de Ceniza",
    ),
    "cv_sms_a2_call_recap": (
        "V — Vik and I matched the West Pier beacons to the southern desert repeaters. The NOX-9 convoy stopped at a desert service lot in Biotechnica Flats before entering The Cantor's sealed bunker. Check that drop site first.",
        "V — Vik y yo cruzamos las balizas del Muelle Oeste con los repetidores del sur. El convoy NOX-9 se detuvo en un punto de servicio de Biotechnica Flats antes de entrar al búnker clausurado de La Cantora. Revisa ese punto primero.",
    ),
    "cv_obj_a2_01": (
        "Investigate the NOX-9 convoy drop in Biotechnica Flats (3 clues)",
        "Investiga el descarte del convoy NOX-9 en Biotechnica Flats (3 pistas)",
    ),
    "cv_desc_a2_01": (
        "Misty and Vik traced the West Pier manifest frequencies to a desert service yard in Biotechnica Flats. Search the abandoned cryo pods, the Moon marker, and the microwave relay to uncover Mateo's fate and locate Helena Solís's bunker.",
        "Misty y Vik siguieron las frecuencias del Muelle Oeste hasta un área de servicio en Biotechnica Flats. Revisa las cápsulas criogénicas, la placa rota y el repetidor de microondas para averiguar qué pasó con Mateo y triangular el búnker de Helena Solís.",
    ),
    "cv_obj_a2_02": (
        "Breach the Badlands Geothermal Bunker and find Lucía Reyes",
        "Asalta el Búnker Geotérmico de las Badlands y localiza a Lucía Reyes",
    ),
    "cv_desc_a2_02": (
        "The microwave relay locks onto Biotechnica's decommissioned geothermal compound 1 km northeast, where Helena Solís executed Mateo (M-09) during Lucía's escape attempt. Overload the perimeter UV emitter, defeat the sentries, and talk to Lucía.",
        "El repetidor apunta a la estación geotérmica de Biotechnica a 1 km al noreste, donde Solís ejecutó a Mateo (M-09) tras su sabotaje. Neutraliza a la guardia exterior con la torre UV y habla con Lucía Reyes.",
    ),
    "cv_obj_a2_02b": (
        "Enter the subterranean Biotechnica bunker via the surface hatch.",
        "Accede al búnker subterráneo de Biotechnica por la escotilla exterior.",
    ),
    "cv_desc_a2_02b": (
        "Use the unlocked surface hatch beside Lucía Reyes to descend into Sublevel -1 of the Pale Chorus complex.",
        "Usa la escotilla desbloqueada junto a Lucía Reyes para descender al Subnivel -1 del complejo del Coro Pálido.",
    ),
    "cv_obj_a2_02c": (
        "Level 1 (1/4): Purge the entry Cryogenic Seal.",
        "Nivel 1 (1/4): Purga el sello de acceso criogénico.",
    ),
    "cv_desc_a2_02c": (
        "Bypass the entry Cryogenic Seal terminal right in front of you to unlock the route to the Dialysis Hall.",
        "Puentea el terminal del sello criogénico frente a ti para iniciar el asalto a la nave de diálisis.",
    ),
    "cv_obj_a2_02d": (
        "Level 1 (2/4): Overload the UV Emitter (365 nm) in the Dialysis Hall.",
        "Nivel 1 (2/4): Sobrecarga el Emisor UV (365 nm) en la nave de diálisis.",
    ),
    "cv_desc_a2_02d": (
        "Cross the unlocked green double door and overload the marked 365 nm UV Emitter to halt the Pale Chorus regeneration.",
        "Cruza la puerta doble verde y sobrecarga el Emisor UV marcado (365 nm) para cortar la regeneración del Coro Pálido.",
    ),
    "cv_obj_a2_02e": (
        "Level 1 (3/4): Eliminate the Pale Chorus squad in the Dialysis Hall.",
        "Nivel 1 (3/4): Neutraliza a la escuadra del Coro Pálido.",
    ),
    "cv_desc_a2_02e": (
        "Eliminate all five Pale Chorus operatives inside the Dialysis Hall and on the ramp.",
        "Elimina a los cinco operativos del Coro Pálido desplegados en la nave de diálisis y en la rampa.",
    ),
    "cv_obj_a2_02f": (
        "Level 1 (4/4): Reach and unlock the Level 2 Entrance Door.",
        "Nivel 1 (4/4): Sube la rampa y desbloquea la puerta de entrada al Nivel 2.",
    ),
    "cv_desc_a2_02f": (
        "Climb the concrete ramp at the east end of the hall and unlock the steel entrance door to Level 2.",
        "Sube la rampa de hormigón en el extremo este de la nave y desbloquea la puerta metálica de entrada al Nivel 2.",
    ),
    "cv_obj_a2_03a": (
        "Level 2 (1/5): Overload the Corridor UV Emitter (365 nm).",
        "Nivel 2 (1/5): Sobrecarga el Emisor UV del corredor (365 nm).",
    ),
    "cv_desc_a2_03a": (
        "Overload the marked 365 nm UV Emitter in the Sublevel -2 sanctum hall to suppress the Pale Chorus's regeneration.",
        "Sobrecarga el Emisor UV marcado (365 nm) en la sala principal del Subnivel -2 para cortar la regeneración del Coro Pálido.",
    ),
    "cv_obj_a2_03b": (
        "Level 2 (2/5): Eliminate the Pale Chorus vanguard in Sublevel -2.",
        "Nivel 2 (2/5): Neutraliza a la guardia del Coro Pálido en el Subnivel -2.",
    ),
    "cv_desc_a2_03b": (
        "Defeat all five Pale Chorus zealots and fanatics guarding the Sublevel -2 approach corridor.",
        "Abate a los cinco fanáticos y celotes del Coro Pálido que custodian el corredor del Subnivel -2.",
    ),
    "cv_obj_a2_03c": (
        "Level 2 (3/5): Confront Dr. Helena Solís ('The Cantor') in Studio NOX-9B.",
        "Nivel 2 (3/5): Confronta a la Dra. Helena Solís («La Cantora») en la cámara NOX-9B.",
    ),
    "cv_desc_a2_03c": (
        "Follow the clear passage south past the strip curtains into Studio NOX-9B and confront Dr. Helena Solís.",
        "Avanza hacia el sur por el pasillo abierto tras las cortinas plásticas hasta el estudio NOX-9B y confronta a la Dra. Helena Solís.",
    ),
    "cv_obj_a2_03": (
        "Confront Dr. Helena Solís ('The Cantor') at the NOX-9B reactor terrace",
        "Enfréntate a la Dra. Helena Solís («La Cantora») en la cámara NOX-9B",
    ),
    "cv_desc_a2_03": (
        "Lucía confirmed Helena Solís is at 98% completion on porphyrin-free NOX-9B and wants Esoterica silenced. Breach the underground security bulkhead, clear Sublevel -1, fight through Sublevel -2, and confront Dr. Helena Solís.",
        "Lucía confirmó que Solís está al 98 % del suero NOX-9B inmune a la luz UV y pretende silenciar Esoterica. Cruza el Subnivel -1, ábrete paso por el Subnivel -2 y confronta a la Dra. Helena Solís.",
    ),
    "cv_obj_a2_04": (
        "Level 2 (4/5): Defeat Solís's guards and access the NOX-9B bioreactor core",
        "Nivel 2 (4/5): Abate a Helena Solís y accede al biorreactor NOX-9B",
    ),
    "cv_desc_a2_04": (
        "Overload the sanctum's 365 nm UV emitter to stop Dr. Helena Solís ('The Cantor') and her Pale Chorus reinforcements from regenerating, defeat them, and secure or purge the NOX-9B bioreactor core before extracting.",
        "Sobrecarga el emisor UV de 365 nm de la cámara para anular la regeneración de Helena Solís («La Cantora») y sus refuerzos, abátelos y asegura o purga el núcleo del biorreactor NOX-9B antes de evacuar.",
    ),
    "cv_obj_a2_05_extract": (
        "Level 2 (5/5): Evacuate via the Emergency Extraction Shaft.",
        "Nivel 2 (5/5): Evacúa por el conducto de extracción hacia la superficie.",
    ),
    "cv_desc_a2_05_extract": (
        "The NOX-9B core is resolved. Use the marked emergency extraction hatch in the corridor to return to Badlands surface.",
        "El núcleo NOX-9B ha quedado resuelto. Usa la escotilla de extracción marcada en el corredor para salir a la superficie.",
    ),
    "cv_obj_a2_05": (
        "Return to Misty and Lucía on Esoterica's rooftop in Little China",
        "Regresa con Misty y Lucía a la azotea de Esoterica en Little China",
    ),
    "cv_desc_a2_05": (
        "The Badlands sanctuary is resolved. Head back up to Misty's rooftop in Little China where Misty and Lucía Reyes are waiting for the final debrief.",
        "La crisis del búnker en las Badlands ha quedado resuelta. Vuelve a la azotea de Esoterica en Little China, donde te esperan Misty y Lucía Reyes para el cierre definitivo.",
    ),
    "cv_desc_a2_done": (
        "Crimson Veil complete. Lucía Reyes returned safely to Little China, the truth of Mateo's sacrifice in Biotechnica Flats was uncovered, and the fate of NOX-9B and Helena Solís's Pale Chorus was sealed.",
        "Velo Carmesí completado. Lucía Reyes ha regresado a salvo a Little China, se esclareció el sacrificio de Mateo en Biotechnica Flats y quedó sellado el destino del suero NOX-9B y de El Coro Pálido de Helena Solís.",
    ),
    # --- Act II Mappins, Banners & Hubs ---
    "cv_mappin_a2_flats": (
        "Biotechnica Flats: NOX-9 Convoy Drop (3 Clues)",
        "Biotechnica Flats: Convoy NOX-9 (3 Pistas)",
    ),
    "cv_mappin_a2_bunker": (
        "Closed Biotechnica Bunker (Badlands): Rescue Lucía",
        "Búnker de Biotechnica (Badlands): Rescatar a Lucía",
    ),
    "cv_mappin_a2_solis": (
        "NOX-9B Chamber: Confront Dr. Helena Solís",
        "Cámara NOX-9B: Confrontar a Helena Solís («La Cantora»)",
    ),
    "cv_mappin_a2_core": (
        "NOX-9B Bioreactor Core",
        "Biorreactor NOX-9B: Asegurar o Purgar la Fórmula",
    ),
    "cv_mappin_a2_return_misty": (
        "Misty's Rooftop (Little China): Reunite with Misty & Lucía",
        "Azotea de Misty (Little China): Reunirse con Misty y Lucía",
    ),
    "cv_banner_a2_start": (
        "[ACT II · LITURGY OF ASH] Convoy telemetry locked in Biotechnica Flats",
        "[ACTO II · LITURGIA DE CENIZA] Rastro del convoy en Biotechnica Flats",
    ),
    "cv_banner_a2_clue_1": (
        "[TRACE 1/3] Lucía's pod (L-14) & NOX-9B trials confirmed",
        "[PISTA 1/3] Cápsula de Lucía (L-14) y envíos de NOX-9B",
    ),
    "cv_banner_a2_clue_2": (
        "[TRACE 2/3] Mateo's badge (M-09) — Executed sabotaging the convoy",
        "[PISTA 2/3] Placa de Mateo (M-09) — Ejecutado al sabotear el convoy",
    ),
    "cv_banner_a2_clue_3": (
        "[TRACE 3/3] Geothermal Bunker beacon locked 1 km NE",
        "[PISTA 3/3] Baliza del Búnker de Biotechnica fijada",
    ),
    "cv_banner_a2_clues_done": (
        "[BUNKER LOCKED] Relay points to Biotechnica's geothermal station (1 km NE)",
        "[BÚNKER LOCALIZADO] El repetidor señala la estación geotérmica de Biotechnica (1 km NE)",
    ),
    "cv_banner_a2_outer_clear": (
        "[PERIMETER CLEAR] Speak with Lucía Reyes by the bunker access",
        "[PERÍMETRO DESPEJADO] Habla con Lucía Reyes junto al acceso",
    ),
    "cv_banner_a2_descent": (
        "[BUNKER ACCESS OPEN] Use the steel floor hatch beside Lucía to descend into Sublevel -1",
        "[ACCESO ABIERTO] Usa la escotilla metálica del suelo junto a Lucía para bajar al Subnivel -1",
    ),
    "cv_banner_a2_solis_combat": (
        "[THE CANTOR HOSTILE] Use the bioreactor UV emitter to neutralize Helena Solís",
        "[LA CANTORA EN COMBATE] Usa la Torre UV del biorreactor para neutralizar a Helena Solís",
    ),
    "cv_banner_a2_chamber_clear": (
        "[CHAMBER CLEAR] Access the NOX-9B bioreactor console",
        "[CÁMARA DESPEJADA] Accede al biorreactor NOX-9B",
    ),
    "cv_banner_a2_core_secured": (
        "[NOX-9B FORMULA SECURED] Return to Misty & Lucía at Esoterica",
        "[FÓRMULA NOX-9B ASEGURADA] Regresa a Esoterica con Misty y Lucía",
    ),
    "cv_banner_a2_core_burned": (
        "[BIOREACTOR PURGED] Formula destroyed — Return to Misty & Lucía",
        "[BIORREACTOR PURGADO] Fórmula destruida — Regresa con Misty y Lucía",
    ),
    "cv_banner_a2_core_locked": (
        "[BIOREACTOR LOCKED] Neutralize Helena Solís and her honor guard first",
        "[BIORREACTOR SELLADO] Neutraliza primero a Helena Solís y su escolta",
    ),
    "cv_banner_a2_finale_ready": (
        "[ACT II FINALE] Speak with Misty and Lucía on the rooftop",
        "[FINAL ACTO II] Habla con Misty y Lucía en la azotea",
    ),
    "cv_banner_a2_complete": (
        "[CRIMSON VEIL COMPLETE] +4,000 E$, +1,500 XP & Iconic 'Crimson Dawn'",
        "[VELO CARMESÍ COMPLETADO] +4.000 €$, +1.500 XP y revólver icónico «Alba Carmesí»",
    ),
    "cv_hub_a2_pod": ("NOX-9 Convoy Cryo-Pod", "Cápsula Criogénica del Convoy NOX-9"),
    "cv_act_a2_inspect_pod": ("Inspect Lucía's cryo-pod (L-14)", "Examinar cápsula de Lucía (L-14)"),
    "cv_hub_a2_mateo": ("Mateo's Shattered Badge & Moon Card", "Placa de Mateo y Carta de La Luna"),
    "cv_act_a2_inspect_mateo": ("Recover Mateo's badge (M-09)", "Recoger placa de Mateo (M-09)"),
    "cv_hub_a2_relay": ("Biotechnica Microwave Relay", "Repetidor de Microondas Biotechnica"),
    "cv_act_a2_inspect_relay": ("Triangulate Pale Chorus bunker", "Triangular búnker del Coro Pálido"),
    "cv_hub_uv_bunker": ("Perimeter UV Tower (365 nm)", "Torre UV Exterior (365 nm)"),
    "cv_hub_uv_chamber": ("Bioreactor UV Tower (365 nm)", "Torre UV del Reactor (365 nm)"),
    "cv_hub_lucia_title": ("Lucía Reyes — Bunker Access", "Lucía Reyes — Acceso al Búnker"),
    "cv_act_talk_lucia": ("Speak with Lucía Reyes", "Hablar con Lucía Reyes"),
    "cv_act_lucia_q1": ("I found Mateo's badge in Biotechnica Flats. What happened during the transfer?", "Encontré la placa de Mateo en Biotechnica Flats. ¿Qué pasó durante el traslado?"),
    "cv_act_lucia_q2": ("How close is Helena Solís to finishing NOX-9B down there?", "¿En qué estado está exactamente el suero NOX-9B ahí abajo?"),
    "cv_act_lucia_adv": ("Stay in cover. I'm going down to confront Helena Solís ('The Cantor').", "Ponte a cubierto. Bajo a enfrentarme a Helena Solís («La Cantora»)."),
    "cv_hub_solis_title": ("Dr. Helena Solís ('The Cantor') — NOX-9B Chamber", "Dra. Helena Solís («La Cantora») — Cámara NOX-9B"),
    "cv_act_talk_solis": ("Confront Helena Solís", "Confrontar a Helena Solís"),
    "cv_act_solis_q1": ("Valdés built NOX-9 to heal lungs. You built a cult and killed Mateo.", "Valdés diseñó el NOX-9 para curar pulmones. Tú montaste una secta y mataste a Mateo."),
    "cv_act_solis_q2": ("Explain NOX-9B. Does it truly remove UV dependency and phototoxicity?", "Explícame el NOX-9B. ¿De verdad elimina la dependencia y el daño solar?"),
    "cv_act_solis_q3": ("Why flag Misty's Esoterica as 'Nexus of Silence' in your shipping logs?", "¿Por qué marcaste Misty's Esoterica como «Nexo de Silencio» en tus manifiestos?"),
    "cv_act_solis_end_cure": ("[Ending A · The Second Serum] Fight for intact NOX-9B for Valdés & free Lucía.", "[Final A · El Segundo Suero] Luchar por la fórmula intacta del NOX-9B para Valdés y liberar a Lucía."),
    "cv_act_solis_end_pact": ("[Ending B · Pact in Dusk] Broker Lucía's release & scrub Watson from ledgers.", "[Final B · Pacto en la Penumbra] Pactar la liberación de Lucía y borrar Watson de tus registros."),
    "cv_act_solis_end_burn": ("[Ending C · Crimson Dawn] Take down Solís and incinerate the NOX-9B bioreactor.", "[Final C · Alba de Sangre] Abatir a Solís y calcinar por completo el biorreactor del Coro Pálido."),
    "cv_act_a2_leave": ("Step back for now.", "Volver ahora."),
    "cv_hub_core_title": ("NOX-9B Bioreactor", "Biorreactor NOX-9B"),
    "cv_act_take_core": ("Download intact NOX-9B formula", "Descargar fórmula NOX-9B intacta"),
    "cv_act_burn_core": ("Purge & destroy NOX-9B serum core", "Purgar y destruir el suero NOX-9B"),
    "cv_act_core_locked": ("Bioreactor sealed", "Biorreactor sellado"),
    "cv_act_a2_finale": ("Meet Misty & Lucía with the Badlands report (Act II Finale)", "Informar a Misty y Lucía sobre el búnker (Final Acto II)"),
    "cv_hub_hatch_surface": ("Geothermal Bunker Bulkhead", "Compuerta del Búnker Subterráneo"),
    "cv_act_hatch_enter": ("Descend into Sublevel -1 (Dialysis Labyrinth)", "Descender al Subnivel -1 (Laberinto de Diálisis)"),
    "cv_act_hatch_locked": ("Bulkhead sealed (Defeat guards & speak to Lucía)", "Compuerta sellada (Despeja el acceso y habla con Lucía)"),
    "cv_hub_hatch_exit": ("Freight Lift to Badlands Surface", "Montacargas de Subida a Superficie"),
    "cv_act_hatch_surface": ("Ascend back to Lucía on the Badlands surface", "Subir a la superficie junto a Lucía"),
    "cv_hub_seal_a": ("Cryogenic Seal Relay Alpha", "Relé de Sello Criogénico Alfa"),
    "cv_act_seal_purge": ("Override & purge cryogenic lock", "Puentear y purgar sello criogénico"),
    "cv_hub_seal_b": ("Cryogenic Seal Relay Beta", "Relé de Sello Criogénico Beta"),
    "cv_hub_hatch_sub2": ("Sublevel -2 Sanctum Hatch", "Compuerta del Subnivel -2 (Santuario)"),
    "cv_act_hatch_sub2_go": ("Descend into Sublevel -2 (NOX-9B Inner Sanctum)", "Descender al Subnivel -2 (Cámara NOX-9B)"),
    "cv_act_hatch_sub2_locked": ("Hatch locked (Purge both Sublevel -1 seals first)", "Compuerta sellada (Purga los dos sellos del Subnivel -1)"),
    "cv_hub_uv_sub1": ("Lab Wing UV Emitter (365 nm)", "Torre UV del Laberinto (365 nm)"),
    "cv_hub_uv_sub2_corr": ("Sanctum Approach UV Emitter (365 nm)", "Torre UV del Corredor (365 nm)"),
    "cv_hub_hatch_extract": ("Emergency Extraction Shaft", "Conducto de Extracción de Emergencia"),
    "cv_act_hatch_extract": ("Extract to Badlands surface beside Lucía", "Evacuar a la superficie junto a Lucía"),
    "cv_banner_sub1_arrive": ("[LEVEL 1 · DIALYSIS HALL] Purge the entry seal in front of you to begin", "[NIVEL 1 · NAVE DE DIÁLISIS] Purga el sello de acceso frente a ti para comenzar"),
    "cv_banner_seal_a_done": ("[ACCESS SEAL PURGED] Cross the green double door and overload the marked UV Emitter", "[SELLO DE ACCESO PURGADO] Cruza la puerta doble verde y sobrecarga el Emisor UV marcado"),
    "cv_pin_uv_tower": ("[2/4 · UV EMITTER] Overload UV Emitter (365 nm)", "[2/4 · EMISOR UV] Sobrecargar Emisor UV (365 nm)"),
    "cv_banner_uv_step_done": ("[UV OVERLOADED] Regeneration suppressed — Eliminate the Pale Chorus squad in the hall", "[EMISOR UV SOBRECARGADO] Regeneración anulada — Elimina a la escuadra del Coro Pálido"),
    "cv_pin_clear_hall": ("[3/4 · DIALYSIS HALL] Eliminate Pale Chorus squad", "[3/4 · NAVE DE DIÁLISIS] Eliminar escuadra del Coro Pálido"),
    "cv_banner_hall_cleared": ("[HALL CLEARED] Climb the ramp to the Level 2 entrance door", "[NAVE DESPEJADA] Sube la rampa hasta la puerta de entrada al Nivel 2"),
    "cv_pin_level2_door": ("[4/4 · LEVEL 2 ENTRANCE] Sealed steel door", "[4/4 · ENTRADA NIVEL 2] Puerta metálica sellada"),
    "cv_hub_level2_door": ("Level 2 Entrance Door", "Puerta de Entrada al Nivel 2"),
    "cv_act_level2_door_open": ("Descend to Level 2 (Crimson Sanctum)", "Descender al Nivel 2 (Santuario Carmesí)"),
    "cv_act_level2_door_locked": ("Door sealed (Overload UV Emitter and clear the hall first)", "Puerta sellada (Sobrecarga el Emisor UV y despeja la nave primero)"),
    "cv_banner_sub1_complete": ("[LEVEL 1 COMPLETE] Descending to Level 2 (Crimson Sanctum)", "[NIVEL 1 COMPLETADO] Descendiendo al Nivel 2 (Santuario Carmesí)"),
    "cv_pin_sub2_uv": ("[1/5 · CORRIDOR UV EMITTER] Overload UV Emitter (365 nm)", "[1/5 · EMISOR UV CORREDOR] Sobrecargar Emisor UV (365 nm)"),
    "cv_pin_sub2_clear": ("[2/5 · SANCTUM APPROACH] Eliminate Pale Chorus vanguard", "[2/5 · CORREDOR] Eliminar guardia del Coro Pálido"),
    "cv_banner_sub2_uv_done": ("[CORRIDOR UV OVERLOADED] Regeneration suppressed — Clear the sanctum vanguard", "[EMISOR UV SOBRECARGADO] Regeneración anulada — Abate a la guardia del corredor"),
    "cv_banner_sub2_hall_clear": ("[CORRIDOR CLEARED] Follow the passage south to confront Dr. Helena Solís", "[CORREDOR DESPEJADO] Avanza al sur por el pasillo hasta la Dra. Helena Solís"),
    "cv_banner_sub2_extracted": ("[LEVEL 2 COMPLETE · EVACUATION] Return to Esoterica rooftop with Misty and Lucía", "[NIVEL 2 COMPLETADO · EVACUACIÓN] Vuelve a la azotea de Esoterica con Misty y Lucía"),
    "cv_banner_sub2_horror": ("[NEURAL INTERFERENCE · THE CHORUS] The Cantor's carrier wave spikes ahead in the NOX-9B chamber", "[INTERFERENCIA NEURAL · EL CORO] Frecuencia vocal de «La Cantora» al máximo en la cámara interior"),
    "cv_banner_sub2_breach": ("[SUBLEVEL -2 · CRIMSON SANCTUM] You reached the lower level — Fight through to Dr. Helena Solis in Studio NOX-9B", "[SUBNIVEL -2 · SANTUARIO CARMESÍ] Has descendido al nivel inferior — Ábrete paso hasta Dra. Helena Solís en el estudio NOX-9B"),
    "cv_banner_solis_phase2": ("[THE CANTOR · PHASE II] The Chorus answers! Reinforcement stalkers breach the chamber", "[LA CANTORA · FASE II] ¡El Coro responde! Acólitos de refuerzo irrumpen en la cámara"),
    # --- 3 New Act II Codex Shards (Shards 8..10) ---
    "cv_shard_a2_flats_name": (
        "Biotechnica Flats — Mateo's Sacrifice (M-09)",
        "Biotechnica Flats — El Sacrificio de Mateo (M-09)",
    ),
    "cv_shard_a2_flats_text": (
        "BIOTECHNICA FLATS CONVOY DROP // FORENSIC RECORD\\n"
        "- Cryo-Pod L-14: Held Lucía Reyes during desert transit alongside NOX-9B calibration samples.\\n"
        "- Subject M-09 (Mateo): Cut the pod's cryo cables to give Lucía a chance to break away; Helena Solís executed him beside the service yard and purged his medical ledger.\\n"
        "- Microwave Relay: Points 1 km northeast to Biotechnica's decommissioned geothermal plant.",
        "DESCARTE EN BIOTECHNICA FLATS // REGISTRO FORENSE\\n"
        "- Cápsula L-14: Transportaba a Lucía Reyes junto a muestras de calibración del NOX-9B.\\n"
        "- Sujeto M-09 (Mateo): Cortó los cables criogénicos para intentar liberar a Lucía; Helena Solís lo ejecutó junto al área de servicio y borró su expediente.\\n"
        "- Repetidor de microondas: Señala a 1 km al noreste hacia la estación geotérmica clausurada.",
    ),
    "cv_shard_a2_lucia_solis_name": (
        "Badlands Bunker — Lucía & Dr. Helena Solís",
        "Búnker de las Badlands — Lucía y la Dra. Helena Solís",
    ),
    "cv_shard_a2_lucia_solis_text": (
        "BIOTECHNICA GEOTHERMAL BUNKER // ACT II\\n"
        "- Lucía Reyes: Survived the convoy and was held under outer UV guard at the geothermal bunker. She recognized Misty's Moon code immediately.\\n"
        "- Dr. Helena Solís ('The Cantor'): Former Biotechnica clinical director who weaponized NOX-9 to trap Watson dropouts in nocturnal dependence. Her lower bioreactor brought porphyrin-free NOX-9B to 98% synthesis.\\n"
        "- Nexus of Silence: Solís marked Esoterica because Lucía used Tarot notches to reach outside the Chorus.",
        "ESTACIÓN GEOTÉRMICA DE BIOTECHNICA // ACTO II\\n"
        "- Lucía Reyes: Sobrevivió al traslado bajo vigilancia UV en el búnker geotérmico y reconoció al instante el código de La Luna de Misty.\\n"
        "- Dra. Helena Solís («La Cantora»): Exdirectora clínica que convirtió el NOX-9 en una red sectaria. Su biorreactor llevó el NOX-9B sin porfirinas al 98 % de síntesis.\\n"
        "- Nexo de Silencio: Solís señaló Esoterica tras detectar las señales del Tarot de Lucía.",
    ),
    "cv_shard_a2_epilogue_name": (
        "Epilogue — Esoterica's Shutters & The Moon",
        "Epílogo — Esoterica Vuelve a Abrir y La Luna",
    ),
    "cv_shard_a2_epilogue_text": (
        "MISTY'S ESOTERICA // CAMPAIGN CLOSURE\\n"
        "- Lucía Reyes returned safely to Little China under Misty's care.\\n"
        "- Depending on V's choice in the NOX-9B chamber (El Segundo Suero, Pacto en la Penumbra, or Alba de Sangre), either Dr. Valdés & Vik received the purified formula, Solís struck Watson from all Chorus manifests, or the Badlands bioreactor burned to ash.\\n"
        "- Mateo (M-09) will be remembered in Kabuki; The Moon card now marks survival rather than a cry in the dark.",
        "MISTY'S ESOTERICA // CIERRE DE CAMPAÑA\\n"
        "- Lucía Reyes regresó sana y salva a Little China bajo el cuidado de Misty.\\n"
        "- Según la decisión de V en la cámara del biorreactor (El Segundo Suero, Pacto en la Penumbra o Alba de Sangre), Vik y Valdés obtuvieron la cura NOX-9B, Solís borró Watson de sus registros o el reactor ardió hasta los cimientos.\\n"
        "- La carta de La Luna sobre la mesa deja de ser una llamada de socorro en la oscuridad: Mateo (M-09) no murió en vano.",
    ),
    # --- Act II Dialogue Subtitles (37 lines) ---
    "cv_a2_call_m1": (
        "V, we cracked the coordinates. Vik and I cross-referenced the West Pier manifest beacons against the southern repeaters.",
        "V, ya tenemos las coordenadas. Vik y yo cruzamos las balizas del manifiesto del Muelle Oeste con los repetidores del sur.",
    ),
    "cv_a2_call_v1": (
        "Where did they dump Lucía? Are we still ahead of their NOX-9B synthesis window?",
        "¿Dónde descargaron a Lucía? ¿Seguimos a tiempo antes de que estabilicen el NOX-9B?",
    ),
    "cv_a2_call_m2": (
        "The convoy made one last drop in Biotechnica Flats before vanishing toward The Cantor's sealed bunker. Sweep that drop and lock the entrance.",
        "El convoy se detuvo por última vez en un punto de servicio de Biotechnica Flats antes de entrar al búnker clausurado de La Cantora. Ve allí y triangula el acceso.",
    ),
    "cv_a2_call_v2": (
        "Rolling out to Biotechnica Flats right now. Keep Esoterica locked down until I call back.",
        "Salgo hacia Biotechnica Flats ahora mismo. Tú no abras la tienda hasta que te avise, Misty.",
    ),
    "cv_a2_flats_arrive": (
        "Abandoned service yard out in Biotechnica Flats... That's the convoy's dumped cryo rig. Let's see what they left behind.",
        "Zona de servicio en mitad de Biotechnica Flats... Ahí está el equipo criogénico descartado del convoy. Veamos qué dejaron atrás.",
    ),
    "cv_a2_clue_pod": (
        "Cryo transfer pod tagged Subject L-14, Lucía Reyes. Unsealed and emptied here—alongside fresh shipping tags for NOX-9B trials.",
        "Cápsula de traslado con código L-14, Lucía Reyes... Está abierta y limpia por dentro, y las pruebas de carga marcan lotes nuevos de NOX-9B.",
    ),
    "cv_a2_clue_mateo": (
        "A shattered Northside dock badge beside another Moon card... Mateo M-09 sabotaged this convoy trying to free Lucía, and Helena Solís executed him here.",
        "Una placa de técnico de Northside partida y otra carta de La Luna... Mateo M-09 intentó sabotear el convoy para ayudar a escapar a Lucía, y Helena Solís lo ejecutó aquí mismo.",
    ),
    "cv_a2_clue_relay": (
        "This microwave relay still holds the bunker handshake—one kilometer northeast, beneath Biotechnica's decommissioned geothermal plant. Time to end this.",
        "Este repetidor de microondas aún conserva el enlace del búnker: un kilómetro al noreste, bajo la antigua estación geotérmica de Biotechnica. Vamos a por ellas.",
    ),
    "cv_a2_bunker_arrive": (
        "Biotechnica's old geothermal plant... The Pale Chorus has armed sentries and another UV tower guarding the outer perimeter. Gotta clear a path to Lucía.",
        "La estación geotérmica de las Badlands... El Coro Pálido vigila la entrada exterior con otra torre UV. Habrá que abrirse paso hasta Lucía.",
    ),
    "cv_a2_lucia_intro": (
        "V? I knew Misty would read the two notches on The Moon card! I thought nobody would ever track me out this far past Watson.",
        "¿V? ¡Sabía que Misty descifraría las dos muescas en la carta de La Luna! Creía que nadie saldría a buscarme tan lejos de Watson.",
    ),
    "cv_a2_v_lucia_intro": (
        "Misty tore half of Watson apart to find you, Lucía. You're clear for now—tell me everything happening down in that bunker.",
        "Misty removió media ciudad para encontrarte, Lucía. Estás fuera de peligro por ahora, pero antes dime todo lo que pasa ahí abajo.",
    ),
    "cv_a2_v_lucia_q1": (
        "I found Mateo's badge back in Biotechnica Flats. Tell me what really happened during the convoy transfer.",
        "Encontré la placa de Mateo en Biotechnica Flats. Dime la verdad sobre lo que ocurrió durante el traslado.",
    ),
    "cv_a2_lucia_a1": (
        "Mateo figured out they weren't curing us—they were locking us into chemical dependency. He cut the cryo lines out in the flats so I could bolt, and Solís gunned him down right in front of me.",
        "Mateo descubrió que no nos estaban curando, sino convirtiéndonos en cobayas dependientes del suero. Cortó los cables criogénicos en mitad del desierto para que yo pudiera huir, pero Solís lo abatió delante de mí y borró su expediente.",
    ),
    "cv_a2_v_lucia_q2": (
        "How close is Helena Solís to actually stabilizing that NOX-9B serum down in the lab?",
        "¿En qué punto está exactamente ese suero NOX-9B que prepara Helena Solís ahí abajo?",
    ),
    "cv_a2_lucia_a2": (
        "The lower bioreactor is already at ninety-eight percent synthesis. Once she finishes it, UV light won't touch them—and she ordered Misty's shop silenced as a subversive link.",
        "Lo tiene al noventa y ocho por ciento en el biorreactor inferior. Si termina la síntesis, El Coro Pálido dejará de ser vulnerable a la luz ultravioleta. Además, quiere silenciar la tienda de Misty porque la considera un puente de conciencia con sus pacientes.",
    ),
    "cv_a2_v_lucia_adv": (
        "Stay behind the outer perimeter and wait for my signal. I'm heading down to confront The Cantor now.",
        "Ponte a cubierto detrás del perímetro exterior y espera mi señal. Bajo ahora mismo a enfrentarme a La Cantora.",
    ),
    "cv_a2_lucia_adv": (
        "Watch your step down there, V—Solís keeps two guards and UV rigs beside the reactor terrace. Meet us back on Misty's roof once it's over.",
        "Ten cuidado abajo, V: Solís tiene dos guardias y focos ultravioleta en la terraza del reactor. Si nos ves vivos en la azotea de Misty, por fin seremos libres.",
    ),
    "cv_a2_solis_intro": (
        "So you're Misty Olszewski's hound. I expected Biotechnica clean-up or Valdés's panic, not someone still chasing sentimental rescues.",
        "Así que tú eres la sombra de Misty Olszewski. Pensé que Adrián Valdés enviaría a un asesino corporativo, no a alguien que aún cree en rescates románticos.",
    ),
    "cv_a2_v_solis_q1": (
        "Valdés built NOX-9 to heal damaged lungs, Solís. You twisted it into a cult and executed Mateo when he tried to walk.",
        "Valdés empezó el NOX-9 para curar pulmones, Solís. Tú lo convertiste en una secta y mataste a Mateo cuando intentó huir.",
    ),
    "cv_a2_solis_a1": (
        "Biotechnica left Watson workers choking because they couldn't afford chrome. I gave them regeneration and belonging in the dark. Mateo broke our oath and endangered everyone.",
        "Biotechnica quería dejar morir a los pobres de Watson cuando no podían pagar implantes. Yo les di regeneración real y comunidad en la noche. Mateo rompió nuestro juramento de silencio y puso en riesgo a todo el Coro.",
    ),
    "cv_a2_v_solis_q2": (
        "Tell me about NOX-9B. Does it actually purge the porphyrins, or is it just a tighter leash?",
        "Explícame el NOX-9B. ¿De verdad quita las porfirinas o solo es otra correa química más cara?",
    ),
    "cv_a2_solis_a2": (
        "NOX-9B strips out 365 nm phototoxicity and stabilizes hemoglobin without weekly dialysis. Whoever holds this formula walks back into sunlight—or decides who stays in the dark.",
        "El NOX-9B elimina la fototoxicidad a trescientos sesenta y cinco nanómetros y estabiliza la sangre sin depender de diálisis semanales. Quien controle esta fórmula podrá caminar al sol… o elegir a quién deja atrás en las sombras.",
    ),
    "cv_a2_v_solis_q3": (
        "Why is Misty Olszewski in your shipping logs? Why mark Esoterica as 'Nexus of Silence'?",
        "¿Y qué demonios pinta Misty Olszewski en tus manifiestos? ¿Por qué ordenaste vigilar Esoterica como Nexo de Silencio?",
    ),
    "cv_a2_solis_a3": (
        "Because Lucía used those Tarot cards to signal outside the Chorus, and that little shop reminds my initiates of the past we asked them to shed.",
        "Porque Lucía usó sus cartas del Tarot para comunicarse fuera del Coro y porque esa tienda recuerda a mis acólitos la vida que abandonaron. Bajar de la torre empieza por cerrar todas las puertas del pasado.",
    ),
    "cv_a2_v_end_cure": (
        "You're done trading in other people's veins, Solís. I'm taking NOX-9B intact to Valdés and walking Lucía out of here tonight.",
        "No vas a negociar con la sangre de nadie más, Solís. Me llevo intacta la fórmula del NOX-9B para Valdés y saco a Lucía de aquí hoy mismo.",
    ),
    "cv_a2_solis_combat": (
        "Then burn beneath the Pale Chorus! Lock the reactor terrace and keep them off that core!",
        "¡Entonces arderás entre el acero del Coro Pálido! ¡Cerrad las compuertas del reactor y no dejéis que toque el núcleo!",
    ),
    "cv_a2_v_end_pact": (
        "Clean truce, Solís: release Lucía with clean stabilizers and scrub Misty's Esoterica from every ledger. Do that, and I walk away.",
        "Hagamos un trato rápido y sucio: liberas a Lucía, entregas dosis de emergencia y borras Misty's Esoterica de tus redes para siempre. A cambio, sigo de largo.",
    ),
    "cv_a2_solis_pact": (
        "Pragmatic as always in Night City. Watson is struck from our manifest and Lucía walks free—just don't step into our shadow again.",
        "Sabia elección en Night City. Watson queda fuera de nuestros registros y Lucía puede irse con su amiga. Pero no vuelvas a cruzar nuestra sombra.",
    ),
    "cv_a2_v_end_burn": (
        "This chamber burns with you, Cantor. I'm torching every last vial of NOX-9B and erasing The Pale Chorus tonight.",
        "Esta cámara muere aquí contigo, Cantora. Voy a calcinar hasta la última probeta del NOX-9B y borrar El Coro Pálido del mapa.",
    ),
    "cv_a2_v_core_secured": (
        "Purified NOX-9B synthesis pulled and encrypted for Valdés and Misty. Time to bring Lucía home to Watson.",
        "Fórmula depurada NOX-9B descargada y encriptada para Adrián Valdés y Misty. Hora de volver a Watson con Lucía.",
    ),
    "cv_a2_v_core_destroyed": (
        "Bioreactor purged and archives torched to ash. No more chemical chains out of this hole—back to Misty's roof.",
        "Biorreactor purgado y archivos reducidos a ceniza. Ya no fabricarán más cadenas químicas desde aquí. Volvamos con Misty.",
    ),
    "cv_a2_roof_lucia_greet": (
        "I don't know how to thank you, V. Hearing Little China rain without dreading the next sunrise felt impossible until today.",
        "No sé cómo darte las gracias, V. Volver a oír la lluvia de Little China sin temer al próximo amanecer parecía imposible hasta hoy.",
    ),
    "cv_a2_roof_misty_cure": (
        "Vik is already reviewing your NOX-9B formula with Dr. Valdés over encrypted comms. For the first time, Lucía and the others have a real shot at walking in daylight again.",
        "Vik ya está revisando tu fórmula del NOX-9B junto al doctor Valdés desde la distancia. Por primera vez, Lucía y los demás tienen esperanza real de volver a caminar bajo el sol.",
    ),
    "cv_a2_roof_misty_pact": (
        "Lucía is safe under my roof and Solís wiped Watson from her ledgers. The Chorus still lingers elsewhere in the city, yet tonight you saved the one life in reach.",
        "Lucía está a salvo bajo mi techo y Watson ha quedado fuera del alcance de Solís. Sé que el Coro seguirá oculto en otros distritos, pero hoy salvaste a quien podíamos salvar.",
    ),
    "cv_a2_roof_misty_burn": (
        "You burned that lab down to its roots so no other desperate kids end up chained underground. Clearing Lucía's blood will take time, yet nobody hunts her anymore.",
        "Arrancaste ese laboratorio de raíz y nadie volverá a atrapar chicos desesperados bajo tierra. Tardaremos tiempo en limpiar el suero de la sangre de Lucía, pero al menos ya nadie la persigue.",
    ),
    "cv_a2_roof_misty_epilogue": (
        "When we raise Esoterica's shutters tomorrow, The Moon on this table won't be an SOS anymore. Take this Crimson Dawn revolver and your Eddies, V—Mateo didn't die for nothing.",
        "Cuando volvamos a abrir Esoterica mañana, La Luna sobre esa mesa ya no será una llamada de socorro en la oscuridad. Toma este revólver Alba Carmesí y tu paga, V: Mateo no murió en vano.",
    ),
    "cv_pin_sub2_descent": (
        "[DESCEND TO SUBLEVEL -2] Hatch / Stairs to NOX-9B Chamber",
        "[BAJAR AL SUBNIVEL -2] Escotilla / Escaleras hacia la cámara NOX-9B",
    ),
    "cv_a2_roof_v_close": (
        "Look after yourself in Kabuki, Lucía—and bolt the door at nightfall, Misty. If The Pale Chorus ever raises its head again, you know my holo.",
        "Cuídate en el barrio, Lucía, y cierra bien cuando caiga la noche, Misty. Si El Coro Pálido vuelve a sacar cabeza en Night City, ya sabes qué número marcar.",
    ),
    # --- Missing & UI Bilingual Keys (Full English Release) ---
    "cv_act_a2_finale_roof": (
        "Meet with Misty and Lucía Reyes (Act II Finale)",
        "Reunirte con Misty y Lucía Reyes (Cierre Acto II)",
    ),
    "cv_act_ascend_rooftop_a2": (
        "Go up to the rooftop with Misty and Lucía (Act II Finale)",
        "Subir con Misty y Lucía a la azotea (Final Acto II)",
    ),
    "cv_banner_a1_debrief_ready": (
        "[ACT I READY] Talk to Misty on the rooftop to wrap up Act I",
        "[ACTO I LISTO] Habla con Misty en la azotea para cerrar el Acto I",
    ),
    "cv_banner_r2_debrief_ready": (
        "[EVIDENCE RECOVERED] Talk to Misty on the rooftop to wrap up the Prologue",
        "[PRUEBAS RECUPERADAS] Habla con Misty en la azotea para cerrar el Prólogo",
    ),
    "cv_act_r2_scan_tarot": (
        "[Kiroshi Scanner] Analyze the stain on the Tarot card",
        "[Escáner Kiroshi] Analizar la mancha en la carta del Tarot",
    ),
    "cv_act_r2_wait_roof": (
        "Wait until 22:00 and go up to the roof with Misty",
        "Esperar hasta las 22:00 y subir con Misty a la azotea",
    ),
    "cv_act_r2_open_codex": (
        "Open Investigation Codex",
        "Abrir Códice de Investigación",
    ),
    "cv_hub_r2_alley_title": (
        "Esoterica Back Alley — Misty Olszewski",
        "Callejón de Esoterica — Misty Olszewski",
    ),
    "cv_act_r2_deliver_vial": (
        "Hand over the NOX-9 vial and Lucía's receipt to Misty",
        "Entregar el vial NOX-9 y el recibo de Lucía a Misty",
    ),
    "cv_act_r2_sit_table": (
        "Sit across from Misty at the Tarot table",
        "Sentarte frente a Misty junto a la mesa del Tarot",
    ),
    "cv_act_r2_go_northside": (
        "Head to the Northside Oilfields now",
        "Ir ahora a los Depósitos de Northside",
    ),
    "cv_act_r2_descend_alley": (
        "Head down to Esoterica's back alley",
        "Bajar al callejón trasero de Esoterica",
    ),
    "cv_hub_r2_roof_night_title": (
        "Misty Olszewski — Rooftop (22:00)",
        "Misty Olszewski — Azotea (22:00)",
    ),
    "cv_act_talk_misty": (
        "Talk to Misty Olszewski",
        "Hablar con Misty Olszewski",
    ),
    "cv_ui_locked_shard_title": (
        "SEALED FILE",
        "EXPEDIENTE SELLADO",
    ),
    "cv_ui_locked_shard_row": (
        "[SEALED]",
        "[SELLADO]",
    ),
    "cv_hint_skip_line": (
        "Skip line",
        "Saltar línea",
    ),
}


class HandleCounter:
    def __init__(self, start: int = 0) -> None:
        self._val = start

    def next(self) -> str:
        s = str(self._val)
        self._val += 1
        return s


def _loc_val(key: str) -> dict[str, str]:
    return {"unk1": "0", "value": key}


def _tdb_uint0() -> dict[str, str]:
    return {"$type": "TweakDBID", "$storage": "uint64", "$value": "0"}


def _tdb_str(val: str) -> dict[str, str]:
    return {"$type": "TweakDBID", "$storage": "string", "$value": val}


def _noderef0() -> dict[str, str]:
    return {"$type": "NodeRef", "$storage": "uint64", "$value": "0"}


def _cname_str(val: str) -> dict[str, str]:
    return {"$type": "CName", "$storage": "string", "$value": val}


def build_journal_json() -> dict[str, Any]:
    hc = HandleCounter()
    root_handle = hc.next()
    quests_h = hc.next()
    side_quest_h = hc.next()

    def make_node(type_name: str, **kwargs: Any) -> dict[str, Any]:
        h = hc.next()
        obj: dict[str, Any] = {"$type": type_name}
        obj.update(kwargs)
        return {"HandleId": h, "Data": obj}

    def make_quest_mappin_node(pin_id: str, caption_key: str, x: float, y: float, z: float) -> dict[str, Any]:
        ANCHOR_NODEREF = "#q101_mp_to_elev_helper1"
        ANCHOR_X = -1402.38293
        ANCHOR_Y = 1289.48730
        ANCHOR_Z = 119.97745
        return make_node(
            "gameJournalQuestMapPin",
            enableGPS=1,
            entries=[],
            id=pin_id,
            journalEntryOverrideDataList=[],
            mappinData={
                "$type": "gamemappinsMappinData",
                "active": 1,
                "debugCaption": "",
                "localizedCaption": _loc_val(caption_key),
                "mappinType": _tdb_str("Mappins.QuestStaticMappinDefinition"),
                "scriptData": None,
                "variant": "ExclamationMarkVariant",
                "visibleThroughWalls": 1,
            },
            offset={
                "$type": "Vector3",
                "X": round(x - ANCHOR_X, 3),
                "Y": round(y - ANCHOR_Y, 3),
                "Z": round(z - ANCHOR_Z, 3),
            },
            reference={
                "$type": "gameEntityReference",
                "dynamicEntityUniqueName": _cname_str("None"),
                "names": [],
                "reference": {
                    "$type": "NodeRef",
                    "$storage": "string",
                    "$value": ANCHOR_NODEREF,
                },
                "sceneActorContextName": _cname_str("None"),
                "slotName": _cname_str("None"),
                "type": "EntityRef",
            },
            slotName=_cname_str("None"),
            uiAnimation=_tdb_uint0(),
        )

    r2_specs: list[tuple[str, str, str, str, str, list[tuple[str, str, float, float, float]]]] = [
        (
            "01_r2_alley",
            "cv_obj_r2_01",
            "desc_r2_01",
            "cv_desc_r2_01",
            "Districts.LittleChina",
            [("mp_r2_alley", "cv_mappin_r2_alley", -1545.60, 1209.20, 16.45)],
        ),
        (
            "02_r2_scan",
            "cv_obj_r2_02",
            "desc_r2_02",
            "cv_desc_r2_02",
            "Districts.LittleChina",
            [("mp_r2_scan", "cv_mappin_r2_alley", -1545.10, 1208.30, 15.85)],
        ),
        (
            "03_r2_rooftop",
            "cv_obj_r2_03",
            "desc_r2_03",
            "cv_desc_r2_03",
            "Districts.LittleChina",
            [("mp_r2_rooftop", "cv_mappin_r2_rooftop", -1548.82, 1209.81, 58.65)],
        ),
        (
            "04_r2_oilfields",
            "cv_obj_r2_04",
            "desc_r2_04",
            "cv_desc_r2_04",
            "Districts.Northside",
            [("mp_r2_oilfields", "cv_mappin_r2_oilfields", -1837.76, 3841.89, 6.60)],
        ),
        (
            "05_r2_evidence",
            "cv_obj_r2_05",
            "desc_r2_05",
            "cv_desc_r2_05",
            "Districts.Northside",
            [("mp_r2_evidence", "cv_mappin_r2_oilfields", -1837.76, 3841.89, 6.20)],
        ),
        (
            "06_r2_debrief",
            "cv_obj_r2_06",
            "desc_r2_06",
            "cv_desc_r2_06",
            "Districts.LittleChina",
            [("mp_r2_debrief", "cv_mappin_r2_debrief", -1548.82, 1209.81, 58.65)],
        ),
    ]

    r2_qh = hc.next()
    r2_ph = hc.next()
    r2_entries: list[dict[str, Any]] = []
    for oid, okey, did, dkey, obj_district, mappin_specs in r2_specs:
        oh = hc.next()
        o_children: list[dict[str, Any]] = [
            make_node(
                "gameJournalQuestDescription",
                description=_loc_val(dkey),
                id=did,
                journalEntryOverrideDataList=[],
            )
        ]
        for mappin_spec in mappin_specs:
            o_children.append(make_quest_mappin_node(*mappin_spec))
        r2_entries.append(
            {
                "HandleId": oh,
                "Data": {
                    "$type": "gameJournalQuestObjective",
                    "counter": 0,
                    "description": _loc_val(okey),
                    "districtID": obj_district,
                    "entries": o_children,
                    "id": oid,
                    "itemID": _tdb_uint0(),
                    "journalEntryOverrideDataList": [],
                    "locationPrefabRef": _noderef0(),
                    "optional": 0,
                },
            }
        )
    r2_entries.append(
        make_node(
            "gameJournalQuestDescription",
            description=_loc_val("cv_desc_r2_done"),
            id="desc_r2_done",
            journalEntryOverrideDataList=[],
        )
    )

    quest_r2 = {
        "HandleId": r2_qh,
        "Data": {
            "$type": "gameJournalQuest",
            "districtID": "Districts.LittleChina",
            "id": "crimson_veil_r2_quest",
            "journalEntryOverrideDataList": [],
            "recommendedLevelID": _tdb_str("DeviceContentAssignment.q001"),
            "title": _loc_val("cv_quest_r2_title"),
            "type": "SideQuest",
            "entries": [
                {
                    "HandleId": r2_ph,
                    "Data": {
                        "$type": "gameJournalQuestPhase",
                        "id": "phase_r2",
                        "journalEntryOverrideDataList": [],
                        "locationPrefabRef": _noderef0(),
                        "entries": r2_entries,
                    },
                }
            ],
        },
    }

    contacts_h = hc.next()
    misty_h = hc.next()
    conv_misty_h = hc.next()
    msg_r2_recap = make_node(
        "gameJournalPhoneMessage",
        attachment=None,
        delay=0,
        id="msg_r2_call_recap",
        imageId=_tdb_uint0(),
        isQuestImportant=1,
        journalEntryOverrideDataList=[],
        sender="NPC",
        text=_loc_val("cv_sms_r2_call_recap"),
    )
    msg_a1_recap = make_node(
        "gameJournalPhoneMessage",
        attachment=None,
        delay=0,
        id="msg_a1_call_recap",
        imageId=_tdb_uint0(),
        isQuestImportant=1,
        journalEntryOverrideDataList=[],
        sender="NPC",
        text=_loc_val("cv_sms_a1_call_recap"),
    )
    msg_a2_recap = make_node(
        "gameJournalPhoneMessage",
        attachment=None,
        delay=0,
        id="msg_a2_call_recap",
        imageId=_tdb_uint0(),
        isQuestImportant=1,
        journalEntryOverrideDataList=[],
        sender="NPC",
        text=_loc_val("cv_sms_a2_call_recap"),
    )
    contact_misty = {
        "HandleId": misty_h,
        "Data": {
            "$type": "gameJournalContact",
            "avatarID": _tdb_str("PhoneAvatars.Avatar_Misty"),
            "entries": [
                {
                    "HandleId": conv_misty_h,
                    "Data": {
                        "$type": "gameJournalPhoneConversation",
                        "entries": [msg_r2_recap, msg_a1_recap, msg_a2_recap],
                        "id": "conv_cv_misty",
                        "journalEntryOverrideDataList": [],
                        "title": _loc_val("cv_conv_misty_title"),
                    },
                }
            ],
            "id": "cv_misty",
            "isCallableDefault": 0,
            "journalEntryOverrideDataList": [],
            "name": _loc_val("cv_spk_misty"),
            "type": "Caller",
            "useFlatMessageLayout": 1,
        },
    }
    contacts_folder = {
        "HandleId": contacts_h,
        "Data": {
            "$type": "gameJournalPrimaryFolderEntry",
            "id": "contacts",
            "journalEntryOverrideDataList": [],
            "entries": [contact_misty],
        },
    }

    a1_specs: list[tuple[str, str, str, str, str, list[tuple[str, str, float, float, float]]]] = [
        (
            "01_a1_kabuki_trace",
            "cv_obj_a1_01",
            "desc_a1_01",
            "cv_desc_a1_01",
            "Districts.Kabuki",
            [("mp_a1_kabuki", "cv_mappin_a1_kabuki", -1033.30, 1291.10, 5.95)],
        ),
        (
            "02_a1_valdes_hideout",
            "cv_obj_a1_02",
            "desc_a1_02",
            "cv_desc_a1_02",
            "Districts.LittleChina",
            [("mp_a1_valdes", "cv_mappin_a1_valdes", -1578.39, 1766.98, 19.73)],
        ),
        (
            "03_a1_waterfront_cryo",
            "cv_obj_a1_03",
            "desc_a1_03",
            "cv_desc_a1_03",
            "Districts.Northside",
            [("mp_a1_waterfront", "cv_mappin_a1_waterfront", -1905.80, 2748.20, 8.60)],
        ),
        (
            "04_a1_return_misty",
            "cv_obj_a1_04",
            "desc_a1_04",
            "cv_desc_a1_04",
            "Districts.LittleChina",
            [("mp_a1_return_misty", "cv_mappin_a1_return_misty", -1545.60, 1209.20, 16.45)],
        ),
    ]

    a1_qh = hc.next()
    a1_ph = hc.next()
    a1_entries: list[dict[str, Any]] = []
    for oid, okey, did, dkey, obj_district, mappin_specs in a1_specs:
        oh = hc.next()
        o_children: list[dict[str, Any]] = [
            make_node(
                "gameJournalQuestDescription",
                description=_loc_val(dkey),
                id=did,
                journalEntryOverrideDataList=[],
            )
        ]
        for mappin_spec in mappin_specs:
            o_children.append(make_quest_mappin_node(*mappin_spec))
        a1_entries.append(
            {
                "HandleId": oh,
                "Data": {
                    "$type": "gameJournalQuestObjective",
                    "counter": 0,
                    "description": _loc_val(okey),
                    "districtID": obj_district,
                    "entries": o_children,
                    "id": oid,
                    "itemID": _tdb_uint0(),
                    "journalEntryOverrideDataList": [],
                    "locationPrefabRef": _noderef0(),
                    "optional": 0,
                },
            }
        )
    a1_entries.append(
        make_node(
            "gameJournalQuestDescription",
            description=_loc_val("cv_desc_a1_done"),
            id="desc_a1_done",
            journalEntryOverrideDataList=[],
        )
    )

    quest_a1 = {
        "HandleId": a1_qh,
        "Data": {
            "$type": "gameJournalQuest",
            "districtID": "Districts.LittleChina",
            "id": "crimson_veil_a1_quest",
            "journalEntryOverrideDataList": [],
            "recommendedLevelID": _tdb_str("DeviceContentAssignment.q001"),
            "title": _loc_val("cv_quest_a1_title"),
            "type": "SideQuest",
            "entries": [
                {
                    "HandleId": a1_ph,
                    "Data": {
                        "$type": "gameJournalQuestPhase",
                        "id": "phase_a1",
                        "journalEntryOverrideDataList": [],
                        "locationPrefabRef": _noderef0(),
                        "entries": a1_entries,
                    },
                }
            ],
        },
    }

    a2_specs: list[tuple[str, str, str, str, str, list[tuple[str, str, float, float, float]]]] = [
        (
            "01_a2_flats_convoy",
            "cv_obj_a2_01",
            "desc_a2_01",
            "cv_desc_a2_01",
            "Districts.Badlands",
            [("mp_a2_flats", "cv_mappin_a2_flats", -753.27, -3640.95, 52.80)],
        ),
        (
            "02_a2_bunker_lucia",
            "cv_obj_a2_02",
            "desc_a2_02",
            "cv_desc_a2_02",
            "Districts.Badlands",
            [("mp_a2_bunker_lucia", "cv_mappin_a2_bunker", -362.04, -2543.09, 28.40)],
        ),
        (
            "02b_a2_enter_bunker",
            "cv_obj_a2_02b",
            "desc_a2_02b",
            "cv_desc_a2_02b",
            "Districts.Badlands",
            [("mp_a2_surface_hatch", "cv_act_hatch_enter", -357.50, -2540.50, 28.88)],
        ),
        (
            "02c_a2_sub1_seal_a",
            "cv_obj_a2_02c",
            "desc_a2_02c",
            "cv_desc_a2_02c",
            "Districts.SantoDomingo",
            [("mp_a2_seal_a", "cv_hub_seal_a", 36.20, -471.00, -4.90)],
        ),
        (
            "02d_a2_sub1_uv_tower",
            "cv_obj_a2_02d",
            "desc_a2_02d",
            "cv_desc_a2_02d",
            "Districts.SantoDomingo",
            [("mp_a2_uv_tower", "cv_pin_uv_tower", 42.00, -476.00, -4.60)],
        ),
        (
            "02e_a2_sub1_clear_hall",
            "cv_obj_a2_02e",
            "desc_a2_02e",
            "cv_desc_a2_02e",
            "Districts.SantoDomingo",
            [("mp_a2_clear_hall", "cv_pin_clear_hall", 47.00, -482.00, -4.30)],
        ),
        (
            "02f_a2_sub1_level2_door",
            "cv_obj_a2_02f",
            "desc_a2_02f",
            "cv_desc_a2_02f",
            "Districts.SantoDomingo",
            [("mp_a2_level2_door", "cv_pin_level2_door", 55.50, -482.50, -3.90)],
        ),
        (
            "03a_a2_sub2_uv_tower",
            "cv_obj_a2_03a",
            "desc_a2_03a",
            "cv_desc_a2_03a",
            "Districts.SantoDomingo",
            [("mp_a2_sub2_uv", "cv_pin_sub2_uv", 62.50, -498.00, -15.60)],
        ),
        (
            "03b_a2_sub2_clear_hall",
            "cv_obj_a2_03b",
            "desc_a2_03b",
            "cv_desc_a2_03b",
            "Districts.SantoDomingo",
            [("mp_a2_sub2_clear", "cv_pin_sub2_clear", 59.31, -500.93, -15.50)],
        ),
        (
            "03c_a2_solis_chamber",
            "cv_obj_a2_03c",
            "desc_a2_03c",
            "cv_desc_a2_03c",
            "Districts.SantoDomingo",
            [("mp_a2_solis", "cv_mappin_a2_solis", 48.60, -531.80, -15.05)],
        ),
        (
            "04_a2_secure_core",
            "cv_obj_a2_04",
            "desc_a2_04",
            "cv_desc_a2_04",
            "Districts.SantoDomingo",
            [("mp_a2_core", "cv_hub_core_title", 47.00, -532.80, -15.05)],
        ),
        (
            "05_a2_sub2_extract",
            "cv_obj_a2_05_extract",
            "desc_a2_05_extract",
            "cv_desc_a2_05_extract",
            "Districts.SantoDomingo",
            [("mp_a2_sub2_extract", "cv_hub_hatch_extract", 52.50, -520.00, -15.60)],
        ),
        (
            "06_a2_return_misty",
            "cv_obj_a2_05",
            "desc_a2_05",
            "cv_desc_a2_05",
            "Districts.LittleChina",
            [("mp_a2_return_misty", "cv_mappin_a2_return_misty", -1545.60, 1209.20, 16.45)],
        ),
    ]

    a2_qh = hc.next()
    a2_ph = hc.next()
    a2_entries: list[dict[str, Any]] = []
    for oid, okey, did, dkey, obj_district, mappin_specs in a2_specs:
        oh = hc.next()
        o_children = [
            make_node(
                "gameJournalQuestDescription",
                description=_loc_val(dkey),
                id=did,
                journalEntryOverrideDataList=[],
            )
        ]
        for mappin_spec in mappin_specs:
            o_children.append(make_quest_mappin_node(*mappin_spec))
        a2_entries.append(
            {
                "HandleId": oh,
                "Data": {
                    "$type": "gameJournalQuestObjective",
                    "counter": 0,
                    "description": _loc_val(okey),
                    "districtID": obj_district,
                    "entries": o_children,
                    "id": oid,
                    "itemID": _tdb_uint0(),
                    "journalEntryOverrideDataList": [],
                    "locationPrefabRef": _noderef0(),
                    "optional": 0,
                },
            }
        )
    a2_entries.append(
        make_node(
            "gameJournalQuestDescription",
            description=_loc_val("cv_desc_a2_done"),
            id="desc_a2_done",
            journalEntryOverrideDataList=[],
        )
    )

    quest_a2 = {
        "HandleId": a2_qh,
        "Data": {
            "$type": "gameJournalQuest",
            "districtID": "Districts.Badlands",
            "id": "crimson_veil_a2_quest",
            "journalEntryOverrideDataList": [],
            "recommendedLevelID": _tdb_str("DeviceContentAssignment.q001"),
            "title": _loc_val("cv_quest_a2_title"),
            "type": "SideQuest",
            "entries": [
                {
                    "HandleId": a2_ph,
                    "Data": {
                        "$type": "gameJournalQuestPhase",
                        "id": "phase_a2",
                        "journalEntryOverrideDataList": [],
                        "locationPrefabRef": _noderef0(),
                        "entries": a2_entries,
                    },
                }
            ],
        },
    }

    quests_folder = {
        "HandleId": quests_h,
        "Data": {
            "$type": "gameJournalPrimaryFolderEntry",
            "id": "quests",
            "journalEntryOverrideDataList": [],
            "entries": [
                {
                    "HandleId": side_quest_h,
                    "Data": {
                        "$type": "gameJournalFolderEntry",
                        "entries": [quest_r2, quest_a1, quest_a2],
                        "id": "side_quest",
                        "journalEntryOverrideDataList": [],
                    },
                }
            ],
        },
    }

    onscreens_h = hc.next()
    group_h = hc.next()
    shards = [
        make_node(
            "gameJournalOnscreen",
            description=_loc_val(f"{sid}_text"),
            iconID=_tdb_uint0(),
            id=sid,
            journalEntryOverrideDataList=[],
            tag={"$type": "CName", "$storage": "string", "$value": "quests"},
            title=_loc_val(f"{sid}_name"),
        )
        for sid in (
            "cv_shard_r2_lucia",
            "cv_shard_r2_porphyria",
            "cv_shard_r2_missing",
            "cv_shard_r2_northside",
            "cv_shard_a1_kabuki",
            "cv_shard_a1_valdes",
            "cv_shard_a1_pier_lead",
            "cv_shard_a2_flats",
            "cv_shard_a2_lucia_solis",
            "cv_shard_a2_epilogue",
        )
    ]
    onscreens_folder = {
        "HandleId": onscreens_h,
        "Data": {
            "$type": "gameJournalPrimaryFolderEntry",
            "id": "onscreens",
            "journalEntryOverrideDataList": [],
            "entries": [
                {
                    "HandleId": group_h,
                    "Data": {
                        "$type": "gameJournalOnscreenGroup",
                        "id": "crimson_veil_shards",
                        "journalEntryOverrideDataList": [],
                        "entries": shards,
                    },
                }
            ],
        },
    }

    return {
        "Header": {
            "WolvenKitVersion": "9.1.1",
            "WKitJsonVersion": "0.0.9",
            "GameVersion": 2310,
            "ExportedDateTime": "2026-11-24T08:00:00.0000000Z",
            "DataType": "CR2W",
            "ArchiveFileName": "crimson_veil\\journal\\crimson_veil.journal",
        },
        "Data": {
            "Version": 195,
            "BuildVersion": 0,
            "RootChunk": {
                "$type": "gameJournalResource",
                "cookingPlatform": "PLATFORM_PC",
                "entry": {
                    "HandleId": root_handle,
                    "Data": {
                        "$type": "gameJournalRootFolderEntry",
                        "descriptor": {
                            "DepotPath": {
                                "$type": "ResourcePath",
                                "$storage": "string",
                                "$value": "base\\journal\\descriptor.journaldesc",
                            },
                            "Flags": "Soft",
                        },
                        "entries": [contacts_folder, quests_folder, onscreens_folder],
                    },
                },
            },
        },
    }


def build_localization_json(lang: str) -> dict[str, Any]:
    idx = 0 if lang == "en-us" else 1
    entries = [
        {
            "$type": "localizationPersistenceOnScreenEntry",
            "femaleVariant": pair[idx],
            "maleVariant": "",
            "primaryKey": "0",
            "secondaryKey": key,
        }
        for key, pair in LOC_STRINGS.items()
    ]
    return {
        "Header": {
            "WolvenKitVersion": "9.1.1",
            "WKitJsonVersion": "0.0.9",
            "GameVersion": 2310,
            "ExportedDateTime": "2026-11-24T08:00:00.0000000Z",
            "DataType": "CR2W",
            "ArchiveFileName": f"crimson_veil\\localization\\{lang}.json",
        },
        "Data": {
            "Version": 195,
            "BuildVersion": 0,
            "RootChunk": {
                "$type": "JsonResource",
                "cookingPlatform": "PLATFORM_PC",
                "root": {
                    "HandleId": "0",
                    "Data": {
                        "$type": "localizationPersistenceOnScreenEntries",
                        "entries": entries,
                    },
                },
            },
        },
    }


def main() -> None:
    journal_path = WK_ARCHIVE / "journal" / "crimson_veil.journal.json"
    en_path = WK_ARCHIVE / "localization" / "en-us.json.json"
    es_path = WK_ARCHIVE / "localization" / "es-es.json.json"

    journal_path.parent.mkdir(parents=True, exist_ok=True)
    en_path.parent.mkdir(parents=True, exist_ok=True)

    journal_path.write_text(json.dumps(build_journal_json(), indent=2, ensure_ascii=False), encoding="utf-8")
    en_path.write_text(json.dumps(build_localization_json("en-us"), indent=2, ensure_ascii=False), encoding="utf-8")
    es_path.write_text(json.dumps(build_localization_json("es-es"), indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"[OK] Journal -> {journal_path}")
    print(f"[OK] EN Loc  -> {en_path} ({len(LOC_STRINGS)} keys)")
    print(f"[OK] ES Loc  -> {es_path} ({len(LOC_STRINGS)} keys)")


if __name__ == "__main__":
    main()
