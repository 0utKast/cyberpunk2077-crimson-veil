"""
Generates Phase 0 (Spanish-first Vertical Slice) original dialogue voice clips and SFX
for Velo Carmesi / Crimson Veil using ElevenLabs Voice Design / TTS + Sound Generation + FFmpeg:
  - files/r6/audioware/CrimsonVeil/audio/{es,sfx}/*.ogg
  - files/r6/audioware/CrimsonVeil/CrimsonVeil.yaml
  - tools/custom_voices.json
  - tools/audio_durations.json
  - C:\\Users\\educa\\Desktop\\Audicion_Voces_Velo_Carmesi\\Misty_ES_Candidata_0X.wav

Ethics & Open Modding Policy:
  - 100% original synthetic voices designed from scratch (NEVER clones or extracts CDPR audio).
  - Security: reads ELEVENLABS_API_KEY via cp2077_config.load_env_var without logging it.
  - Idempotent: skips existing .ogg > 1024 B unless --force / --force-voices is passed.
"""

from __future__ import annotations

import argparse
import base64
import concurrent.futures
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
import wave
from pathlib import Path
from typing import Any

import numpy as np
import yaml

MOD_ROOT = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = MOD_ROOT.parent.parent
sys.path.insert(0, str(WORKSPACE_ROOT / "scripts"))

import cp2077_config as cfg  # noqa: E402

AUDIO_ROOT = MOD_ROOT / "files" / "r6" / "audioware" / "CrimsonVeil"
AUDIO_ES_DIR = AUDIO_ROOT / "audio" / "es"
AUDIO_EN_DIR = AUDIO_ROOT / "audio" / "en"
AUDIO_SFX_DIR = AUDIO_ROOT / "audio" / "sfx"
MANIFEST_YAML = AUDIO_ROOT / "CrimsonVeil.yaml"
DURATIONS_JSON = MOD_ROOT / "tools" / "audio_durations.json"
CUSTOM_VOICES_JSON = MOD_ROOT / "tools" / "custom_voices.json"
AUDITION_DIR = Path.home() / "Desktop" / "Audicion_Voces_Velo_Carmesi"

DEFAULT_MODEL_ID = "eleven_v3"
FALLBACK_MODEL_ID = "eleven_multilingual_v2"
VOICE_DESIGN_MODEL_ID = "eleven_ttv_v3"

# Reuse established custom protagonist V voices for cross-project consistency
SEEDED_VOICES: dict[str, dict[str, str]] = {
    "v_fem": {"es": "yKSdWc9iLoqy8SKr3vVg", "en": "vxoKa9xE9HoypzlDGiGk"},
    "v_male": {"es": "zIybPyqdVFC18UIjxJ7x", "en": "bXIrwX7pHsqRGsEHMrWA"},
}

VOICE_DESIGN_SPECS: dict[str, dict[str, dict[str, Any]]] = {
    "misty": {
        "es": {
            "voice_name": "CP2077_CrimsonVeil_Misty_ES",
            "f0_band": (155.0, 185.0, 215.0),
            "voice_description": (
                "Voz de mujer adulta de unos treinta años en español neutro peninsular cálido, "
                "registro medio aterciopelado, serena, pausada, empática e íntima, con aire meditativo de lectora de tarot "
                "sin sonar jamás infantil, chillona ni teatral. Dicción de estudio cristalina y natural."
            ),
            "sample_text": (
                "Aquí arriba Night City respira distinto cuando cae la noche, V. "
                "Esa carta de La Luna no estaba manchada con tinta normal: olía a cobre frío, líquido de diálisis y miedo disfrazado de rito."
            ),
        },
        "en": {
            "voice_name": "CP2077_CrimsonVeil_Misty_EN",
            "f0_band": (155.0, 185.0, 215.0),
            "voice_description": (
                "Adult American woman in her early thirties with a warm velvety mid-range voice, "
                "calm, unhurried, empathetic, and intimate like a grounded tarot reader on a quiet rooftop, "
                "never childish, shrill, or overly theatrical. Natural, crystal-clear studio diction."
            ),
            "sample_text": (
                "Night City breathes differently up here once the neon drowns out the sun, V. "
                "That stained Moon card wasn't marked with ordinary ink—it smelled like cold copper, dialysis fluid, and fear dressed as ritual."
            ),
        },
    },
    "vampyre": {
        "es": {
            "voice_name": "CP2077_CrimsonVeil_Vampyre_ES",
            "f0_band": (88.0, 112.0, 138.0),
            "voice_description": (
                "Voz masculina adulta en español neutro peninsular, barítono grave y ligeramente rasposo, "
                "intensidad oscura, febril e inquietante de fanático nocturno clandestino, manteniendo siempre articulación limpia de estudio."
            ),
            "sample_text": (
                "La noche pertenece al Coro, intruso. Aléjate del altar de plasma o derrama tu sangre fría entre estas torres de acero."
            ),
        },
        "en": {
            "voice_name": "CP2077_CrimsonVeil_Vampyre_EN",
            "f0_band": (88.0, 112.0, 138.0),
            "voice_description": (
                "Adult American male with a deep, slightly gravelly baritone voice, "
                "dark, feverish, and unsettling intensity of an underground nocturnal cult sentinel, "
                "maintaining crisp, clean studio articulation throughout."
            ),
            "sample_text": (
                "The night belongs to the Pale Chorus, outsider. Step away from the plasma shrine or spill your warm blood across this cold concrete."
            ),
        },
    },
    "valdes": {
        "es": {
            "voice_name": "CP2077_CrimsonVeil_Valdes_ES",
            "f0_band": (95.0, 115.0, 138.0),
            "voice_description": (
                "Voz masculina madura de unos cincuenta años en español neutro peninsular, barítono templado y ligeramente cansado, "
                "tono intelectual, nervioso pero contenido de ex-científico corporativo fugado que habla en voz baja, con dicción de estudio cristalina y natural, sin acento extranjero."
            ),
            "sample_text": (
                "Baja la voz y aparta esa pistola, por favor. No soy uno de esos fanáticos del Coro Pálido, soy el doctor Adrián Valdés."
            ),
        },
        "en": {
            "voice_name": "CP2077_CrimsonVeil_Valdes_EN",
            "f0_band": (95.0, 115.0, 138.0),
            "voice_description": (
                "Mature male around fifty years old in natural American English, weathered and slightly tired tempered baritone, "
                "intellectual, guarded, and quietly anxious tone of a fugitive former corporate hematologist speaking in a low voice, "
                "clean crystal-clear studio diction."
            ),
            "sample_text": (
                "Keep your voice down and lower that weapon, please. I am not one of those Pale Chorus zealots—I am Doctor Adrián Valdés."
            ),
        },
    },
    "lucia": {
        "es": {
            "voice_name": "CP2077_CrimsonVeil_Lucia_ES",
            "f0_band": (170.0, 200.0, 235.0),
            "voice_description": (
                "Voz femenina joven adulta de unos veintitrés años en español neutro peninsular, dulce pero firme, "
                "lúcida y valiente pese al agotamiento de haber estado retenida en un laboratorio, con dicción de estudio limpia y natural, sin tono infantil."
            ),
            "sample_text": (
                "Sabía que Misty descifraría las muescas en la carta de La Luna. Mateo intentó sabotear los tanques antes de que nos trajeran aquí."
            ),
        },
        "en": {
            "voice_name": "CP2077_CrimsonVeil_Lucia_EN",
            "f0_band": (170.0, 200.0, 235.0),
            "voice_description": (
                "Young adult woman around twenty-three years old in natural American English, warm yet resolute, "
                "lucid and brave despite exhaustion from captivity inside an underground lab, grounded adult tone without ever sounding childish, clean studio diction."
            ),
            "sample_text": (
                "I knew Misty would read those two fingernail notches on the Moon card. Mateo tried to cut the cryo lines in the desert before they brought me down here."
            ),
        },
    },
    "solis": {
        "es": {
            "voice_name": "CP2077_CrimsonVeil_Solis_ES",
            "f0_band": (135.0, 165.0, 195.0),
            "voice_description": (
                "Voz femenina madura de unos cuarenta y dos años en español neutro peninsular, contralto fría, culta, "
                "serena, quirúrgica y persuasiva de directora científica corporativa que dirige una secta elitista, con dicción de estudio cristalina."
            ),
            "sample_text": (
                "No soy una predicadora callejera, mercenario. Lo que Adrián Valdés dejó inacabado en los márgenes de Night City, yo lo convertí en evolución clínica."
            ),
        },
        "en": {
            "voice_name": "CP2077_CrimsonVeil_Solis_EN",
            "f0_band": (135.0, 165.0, 195.0),
            "voice_description": (
                "Mature woman around forty-two years old in polished, articulate American English, cool cultured surgical contralto "
                "of an elitist former corporate research director commanding a nocturnal cult, calm, clinical, and subtly persuasive with crystal-clear studio diction."
            ),
            "sample_text": (
                "I am no street-corner preacher, mercenary. What Adrián Valdés abandoned in Watson's gutters, I refined into clinical evolution inside this reactor chamber."
            ),
        },
    },
}

# Clean studio mastering — preserve vocal warmth & clarity without harsh band-pass distortion
CLEAN_VOCAL_FILTER = (
    "highpass=f=70,"
    "acompressor=threshold=-18dB:ratio=2.2:attack=5:release=80,"
    "alimiter=limit=0.812"
)

SFX_SPECS: list[dict[str, Any]] = [
    {
        "id": "cv_sfx_tarot_flip",
        "duration": 1.5,
        "prompt": "Crisp heavy cardstock tarot card flipped slowly onto a wooden table with a subtle warm dark harmonic chime",
    },
    {
        "id": "cv_sfx_uv_overload",
        "duration": 2.3,
        "prompt": "High-voltage industrial ultraviolet floodlight capacitor whine followed by a sharp violet electrical arc burst and humming glow",
    },
    {
        "id": "cv_sfx_night_chime",
        "duration": 2.0,
        "prompt": "Soft brass shopkeeper wind chime and velvet resonance echoing gently in an atmospheric nocturnal esoteric shop",
    },
    {
        "id": "cv_sfx_forensic_scan",
        "duration": 1.6,
        "prompt": "Subtle crisp futuristic Kiroshi biometric optic scanner sweep followed by a dark atmospheric low synth pulse",
    },
]

DIALOGUE_LINES: list[dict[str, str]] = [
    {
        "id": "cv_p0_misty_esoterica_01",
        "speaker": "misty",
        "es_sub": "Alguien dejó esa Luna manchada antes del alba, V. Espera a la noche y sube conmigo a la azotea.",
        "es_tts": "Alguien dejó esa Luna manchada antes del alba, V. Espera a la noche y sube conmigo a la azotea.",
        "en_sub": "Someone left that stained Moon card before dawn, V. Wait until nightfall and meet me upstairs on the roof.",
        "en_tts": "Someone left that stained Moon card before dawn, V. Wait until nightfall and meet me upstairs on the roof.",
    },
    {
        "id": "cv_p0_misty_rooftop_01",
        "speaker": "misty",
        "es_sub": "Aquí arriba Night City respira distinto. Gracias por subir cuando el neón apaga el sol, V.",
        "es_tts": "Aquí arriba Night City respira distinto. Gracias por subir cuando el neón apaga el sol, V.",
        "en_sub": "Night City breathes easier up here. Thank you for coming up once the neon drowned out the sun, V.",
        "en_tts": "Night City breathes easier up here. Thank you for coming up once the neon drowned out the sun, V.",
    },
    {
        "id": "cv_p0_misty_rooftop_02",
        "speaker": "misty",
        "es_sub": "Eso no era tinta en La Luna: olía a cobre frío, líquido de diálisis y miedo disfrazado de rito.",
        "es_tts": "Eso no era tinta en La Luna: olía a cobre frío, líquido de diálisis y miedo disfrazado de rito.",
        "en_sub": "That wasn't ordinary ink on the Moon card—it smelled like cold copper, dialysis fluid, and fear dressed as ritual.",
        "en_tts": "That was not ordinary ink on the Moon card—it smelled like cold copper, dialysis fluid, and fear dressed as ritual.",
    },
    {
        "id": "cv_p0_v_ask_chorus",
        "speaker": "v",
        "es_sub": "¿Quiénes son exactamente «El Coro Pálido»? ¿Cromados callejeros o una secta nueva?",
        "es_tts": "¿Quiénes son exactamente El Coro Pálido? ¿Cromados callejeros o una secta nueva?",
        "en_sub": "Who are 'The Pale Chorus' exactly—chromed street ghouls or some new corpo cult?",
        "en_tts": "Who are The Pale Chorus exactly—chromed street ghouls or some new corpo cult?",
    },
    {
        "id": "cv_p0_misty_ans_chorus",
        "speaker": "misty",
        "es_sub": "Antiguos biosculptores Exotics y fugados de clínicas negras. Usan colmillos Vampyre y sangre sintética para creerse inmortales.",
        "es_tts": "Antiguos biosculptores Exotics y fugados de clínicas negras. Usan colmillos Vampyre y sangre sintética para creerse inmortales.",
        "en_sub": "Former Exotics biosculptors and black-clinic dropouts. They inject cheap Vampyre fangs and synthetic blood to play immortal.",
        "en_tts": "Former Exotics biosculptors and black-clinic dropouts. They inject cheap Vampyre fangs and synthetic blood to play immortal.",
    },
    {
        "id": "cv_p0_v_ask_uv",
        "speaker": "v",
        "es_sub": "Espera... mis ópticas leyeron trazas de porfirina reactiva a UV. ¿De verdad les quema la luz?",
        "es_tts": "Espera... mis ópticas leyeron trazas de porfirina reactiva a luz ultravioleta. ¿De verdad les quema la luz?",
        "en_sub": "Wait—my optics tagged UV porphyrin warnings on that card. Are they actually allergic to sunlight?",
        "en_tts": "Wait—my optics tagged ultraviolet porphyrin warnings on that card. Are they actually allergic to sunlight?",
    },
    {
        "id": "cv_p0_misty_ans_uv",
        "speaker": "misty",
        "es_sub": "Es química rota, no magia. Su diálisis sucia arde bajo luz ultravioleta intensa; recuérdalo si se cruzan contigo.",
        "es_tts": "Es química rota, no magia. Su diálisis sucia arde bajo luz ultravioleta intensa; recuérdalo si se cruzan contigo.",
        "en_sub": "It's broken chemistry, not magic. Their dirty dialysis burns violently under harsh ultraviolet light—remember that if you cross them.",
        "en_tts": "It is broken chemistry, not magic. Their dirty dialysis burns violently under harsh ultraviolet light—remember that if you cross them.",
    },
    {
        "id": "cv_p0_misty_tarot_forensic",
        "speaker": "misty",
        "es_sub": "Frío y clínico, justo como tú. Rastrea los pozos petrolíferos de Northside y tráeme una muestra intacta de ese plasma.",
        "es_tts": "Frío y clínico, justo como tú. Rastrea los pozos petrolíferos de Northside y tráeme una muestra intacta de ese plasma.",
        "en_sub": "Sharp and clinical—just like a solo. Check the industrial oilfields up in Northside and bring me one clean plasma sample.",
        "en_tts": "Sharp and clinical—just like a solo. Check the industrial oilfields up in Northside and bring me one clean plasma sample.",
    },
    {
        "id": "cv_p0_misty_tarot_symbolic",
        "speaker": "misty",
        "es_sub": "Aún sabes leer lo que calla la ciudad. Sigue ese hilo carmesí hasta los Pozos Petrolíferos de Northside, pero no bajes la guardia.",
        "es_tts": "Aún sabes leer lo que calla la ciudad. Sigue ese hilo carmesí hasta los Pozos Petrolíferos de Northside, pero no bajes la guardia.",
        "en_sub": "You still read between the lines of this city. Follow that crimson thread into the Northside Oilfields—don't drop your guard.",
        "en_tts": "You still read between the lines of this city. Follow that crimson thread into the Northside Oilfields—do not drop your guard.",
    },
    {
        "id": "cv_p0_v_oilfields_arrive",
        "speaker": "v",
        "es_sub": "Pozos muertos, una bolsa de plasma entre velas y un foco UV industrial montado justo al lado. Toca vigilar las sombras.",
        "es_tts": "Pozos muertos, una bolsa de plasma entre velas y un foco ultravioleta industrial montado justo al lado. Toca vigilar las sombras.",
        "en_sub": "Abandoned derricks, blood drip on rust, and a heavy UV floodlight rigged right beside it. Stay sharp.",
        "en_tts": "Abandoned derricks, blood drip on rust, and a heavy ultraviolet floodlight rigged right beside it. Stay sharp.",
    },
    {
        "id": "cv_p0_vampyre_ambush",
        "speaker": "vampyre",
        "es_sub": "¡La noche pertenece al Coro, intruso! ¡Derrama tu sangre en el polvo o arrodíllate ante el Velo!",
        "es_tts": "¡La noche pertenece al Coro, intruso! ¡Derrama tu sangre en el polvo o arrodíllate ante el Velo!",
        "en_sub": "The night belongs to the Chorus, outsider! Bleed into the dust or kneel before the Crimson Veil!",
        "en_tts": "The night belongs to the Chorus, outsider! Bleed into the dust or kneel before the Crimson Veil!",
    },
    {
        "id": "cv_p0_v_uv_hint",
        "speaker": "v",
        "es_sub": "Maldición... ¡se están regenerando en la oscuridad! ¡Sobrecarga ese Emisor UV ahora mismo!",
        "es_tts": "Maldición... ¡se están regenerando en la oscuridad! ¡Sobrecarga ese Emisor ultravioleta ahora mismo!",
        "en_sub": "Damn it—their chrome is knitting flesh back together in the dark! Overload that UV Emitter!",
        "en_tts": "Damn it—their chrome is knitting flesh back together in the dark! Overload that ultraviolet Emitter!",
    },
    {
        "id": "cv_p0_v_sample_taken",
        "speaker": "v",
        "es_sub": "Vial de plasma sintético asegurado. Misty tiene que ver estos datos arriba en su azotea.",
        "es_tts": "Vial de plasma sintético asegurado. Misty tiene que ver estos datos arriba en su azotea.",
        "en_sub": "Synthetic porphyrin-plasma sealed. Misty needs to see this telemetry back up on her Little China roof.",
        "en_tts": "Synthetic porphyrin-plasma sealed. Misty needs to see this telemetry back up on her Little China roof.",
    },
    {
        "id": "cv_p0_misty_debrief_01",
        "speaker": "misty",
        "es_sub": "Mira estas lecturas de porfirina... Es peor que superstición: alguien prueba el Proyecto NOX-9 en los márgenes de Watson.",
        "es_tts": "Mira estas lecturas de porfirina... Es peor que superstición: alguien prueba el Proyecto Nox nueve en los márgenes de Watson.",
        "en_sub": "Look at those porphyrin readings... It's worse than superstition. Someone is testing Project NOX-9 across Watson's fringes.",
        "en_tts": "Look at those porphyrin readings... It is worse than superstition. Someone is testing Project Nox nine across Watson's fringes.",
    },
    {
        "id": "cv_p0_misty_debrief_02",
        "speaker": "misty",
        "es_sub": "Quédate esta hoja y tu paga, V. Cuando las sombras vuelvan a cerrarse sobre los almacenes, volveré a llamarte.",
        "es_tts": "Quédate esta hoja y tu paga, V. Cuando las sombras vuelvan a cerrarse sobre los almacenes, volveré a llamarte.",
        "en_sub": "Take this modified blade and your Eddies, V. When the shadows gather thicker in the warehouses, I'll call you back up.",
        "en_tts": "Take this modified blade and your Eddies, V. When the shadows gather thicker in the warehouses, I will call you back up.",
    },
    # --- Acto I en Watson: Réquiem de Porfirina (22 líneas nuevas) ---
    {
        "id": "cv_a1_v_kabuki_arrive",
        "speaker": "v",
        "es_sub": "Descartes clínicos tirados junto al canal de Kabuki... Toca revisar la zona sin alertar a nadie todavía.",
        "es_tts": "Descartes clínicos tirados junto al canal de Kabuki... Toca revisar la zona sin alertar a nadie todavía.",
        "en_sub": "Clinical waste dumped along Kabuki creek... Better inspect every trace carefully without raising alarms yet.",
        "en_tts": "Clinical waste dumped along Kabuki creek... Better inspect every trace carefully without raising alarms yet.",
    },
    {
        "id": "cv_a1_v_clue_blood",
        "speaker": "v",
        "es_sub": "Un refrigerador portátil con sellos de Biotechnica raspados... Lleva estabilizadores de porfirina sintética.",
        "es_tts": "Un refrigerador portátil con sellos de Biotechnica raspados... Lleva estabilizadores de porfirina sintética.",
        "en_sub": "A chilled cooler with scraped-off Biotechnica seals... Packed with synthetic porphyrin blood stabilizers.",
        "en_tts": "A chilled cooler with scraped-off Biotechnica seals... Packed with synthetic porphyrin blood stabilizers.",
    },
    {
        "id": "cv_a1_v_clue_tarot",
        "speaker": "v",
        "es_sub": "La Sacerdotisa invertida clavada entre cirios. En el reverso hay una licencia médica anulada en Little China.",
        "es_tts": "La Sacerdotisa invertida clavada entre cirios. En el reverso hay una licencia médica anulada en Little China.",
        "en_sub": "An inverted High Priestess pinned between candles. Scrawled on the back is a revoked medic license in Little China.",
        "en_tts": "An inverted High Priestess pinned between candles. Scrawled on the back is a revoked medic license in Little China.",
    },
    {
        "id": "cv_a1_v_clue_relay",
        "speaker": "v",
        "es_sub": "El relé triangular sigue activo: apunta a un callejón escondido en Little China. Doctor Adrián Valdés.",
        "es_tts": "El relé triangular sigue activo: apunta a un callejón escondido en Little China. Doctor Adrián Valdés.",
        "en_sub": "This relay link is still warm—it triangulates to a tucked-away alley in Little China. Doctor Adrián Valdés.",
        "en_tts": "This relay link is still warm—it triangulates to a tucked-away alley in Little China. Doctor Adrian Valdes.",
    },
    {
        "id": "cv_a1_valdes_intro_01",
        "speaker": "valdes",
        "es_sub": "¡Silencio, baja la mano y escúchame! Si el Coro Pálido te hubiera enviado, ya estaría muerto... ¿Tú qué quieres?",
        "es_tts": "¡Silencio, baja la mano y escúchame! Si el Coro Pálido te hubiera enviado, ya estaría muerto... ¿Tú qué quieres?",
        "en_sub": "Quiet—keep your voice down and listen! If the Pale Chorus sent you, I'd be dead already. What do you want?",
        "en_tts": "Quiet—keep your voice down and listen! If the Pale Chorus sent you, I would be dead already. What do you want?",
    },
    {
        "id": "cv_a1_v_ask_nox9",
        "speaker": "v",
        "es_sub": "Vengo por el Proyecto NOX-9, doctor. Explícame qué mete esa gente en la sangre y cómo romper sus implantes.",
        "es_tts": "Vengo por el Proyecto Nox nueve, doctor. Explícame qué mete esa gente en la sangre y cómo romper sus implantes.",
        "en_sub": "I'm tracking Project NOX-9, Doc. Tell me what they're pumping into their veins and how to shut it down.",
        "en_tts": "I am tracking Project Nox nine, Doc. Tell me what they are pumping into their veins and how to shut it down.",
    },
    {
        "id": "cv_a1_valdes_ans_nox9",
        "speaker": "valdes",
        "es_sub": "Fue un suero militar de Biotechnica para supervivencia en penumbra. En la calle lo corrompieron: regenera carne de noche, pero estalla bajo luz UV a 365 nm.",
        "es_tts": "Fue un suero militar de Biotechnica para supervivencia en penumbra. En la calle lo corrompieron: regenera carne de noche, pero estalla bajo luz ultravioleta a trescientos sesenta y cinco nanómetros.",
        "en_sub": "NOX-9 started as a Biotechnica low-light trauma serum. Street zealots corrupted it: cellular regen in darkness, lethal photolysis at 365 nm UV.",
        "en_tts": "Nox nine started as a Biotechnica low-light trauma serum. Street zealots corrupted it: cellular regen in darkness, lethal photolysis at three hundred sixty five nanometers ultraviolet.",
    },
    {
        "id": "cv_a1_v_ask_misty",
        "speaker": "v",
        "es_sub": "¿Y el teatro del Tarot? Están dejando cartas manchadas junto a la tienda de una amiga en Little China.",
        "es_tts": "¿Y el teatro del Tarot? Están dejando cartas manchadas junto a la tienda de una amiga en Little China.",
        "en_sub": "Then what's with all the Tarot theater? They're leaving stained cards behind a friend's shop in Little China.",
        "en_tts": "Then what is with all the Tarot theater? They are leaving stained cards behind a friend's shop in Little China.",
    },
    {
        "id": "cv_a1_valdes_ans_misty",
        "speaker": "valdes",
        "es_sub": "Eso no sé explicarlo con ciencia... En diálisis profunda dibujan Arcanos y oyen un coro desde un búnker en las Badlands. «La Cantora» cree que esa tienda resuena igual.",
        "es_tts": "Eso no sé explicarlo con ciencia... En diálisis profunda dibujan Arcanos y oyen un coro desde un búnker en las Badlands. La Cantora cree que esa tienda resuena igual.",
        "en_sub": "That part defies my charts... Under deep dialysis they sketch Arcana and hear a choir humming from an old Badlands bunker. The Cantor claims her shop tunes to it.",
        "en_tts": "That part defies my charts... Under deep dialysis they sketch Arcana and hear a choir humming from an old Badlands bunker. The Cantor claims her shop tunes to it.",
    },
    {
        "id": "cv_a1_valdes_give_trust",
        "speaker": "valdes",
        "es_sub": "Gracias por oírme antes de disparar. En el muelle oeste usan el santo y seña «La sombra bebe antes del alba». Úsalo y saca el manifiesto sin ruido.",
        "es_tts": "Gracias por oírme antes de disparar. En el muelle oeste usan el santo y seña La sombra bebe antes del alba. Úsalo y saca el manifiesto sin ruido.",
        "en_sub": "Thank you for listening instead of pulling a trigger. Use the pass phrase 'The shadow drinks before dawn' at the west pier and pull their manifest.",
        "en_tts": "Thank you for listening instead of pulling a trigger. Use the pass phrase The shadow drinks before dawn at the west pier and pull their manifest.",
    },
    {
        "id": "cv_a1_valdes_give_pressure",
        "speaker": "valdes",
        "es_sub": "¡Basta, te daré todo! Vigilan el muelle oeste con dos torres ultravioleta. Su contraseña es «La sombra bebe antes del alba». Déjame desaparecer después.",
        "es_tts": "¡Basta, te daré todo! Vigilan el muelle oeste con dos torres ultravioleta. Su contraseña es La sombra bebe antes del alba. Déjame desaparecer después.",
        "en_sub": "Enough—I'll give you everything! They guard the west pier beneath two UV towers. Their pass phrase is 'The shadow drinks before dawn'. Just let me vanish.",
        "en_tts": "Enough—I will give you everything! They guard the west pier beneath two ultraviolet towers. Their pass phrase is The shadow drinks before dawn. Just let me vanish.",
    },
    {
        "id": "cv_a1_v_valdes_depart",
        "speaker": "v",
        "es_sub": "Ya tengo su clave y el punto de descarga en el muelle oeste. Vamos a ver qué esconde el Coro Pálido.",
        "es_tts": "Ya tengo su clave y el punto de descarga en el muelle oeste. Vamos a ver qué esconde el Coro Pálido.",
        "en_sub": "Got their cipher and the west waterfront coordinates. Time to see what The Pale Chorus is shipping.",
        "en_tts": "Got their cipher and the west waterfront coordinates. Time to see what The Pale Chorus is shipping.",
    },
    {
        "id": "cv_a1_v_pier_arrive",
        "speaker": "v",
        "es_sub": "Puesto criogénico en el muelle y dos focos UV listos para barrer el cemento... puedo colarme con la clave o abrir fuego.",
        "es_tts": "Puesto criogénico en el muelle y dos focos ultravioleta listos para barrer el cemento... puedo colarme con la clave o abrir fuego.",
        "en_sub": "Waterfront cryo checkpoint with twin UV towers flanking the dock... I can bluff past the sentry or burn them down.",
        "en_tts": "Waterfront cryo checkpoint with twin ultraviolet towers flanking the dock... I can bluff past the sentry or burn them down.",
    },
    {
        "id": "cv_a1_gate_challenge",
        "speaker": "vampyre",
        "es_sub": "Alto ahí, carne tibia. Nadie cruza el muelle criogénico de noche sin cantar el velo de La Cantora.",
        "es_tts": "Alto ahí, carne tibia. Nadie cruza el muelle criogénico de noche sin cantar el velo de La Cantora.",
        "en_sub": "Halt right there, warmblood. Nobody steps onto the cryo pier without speaking The Cantor's veil.",
        "en_tts": "Halt right there, warmblood. Nobody steps onto the cryo pier without speaking The Cantor's veil.",
    },
    {
        "id": "cv_a1_v_gate_bluff",
        "speaker": "v",
        "es_sub": "La sombra bebe antes del alba. Me envía el doctor Valdés para revisar el manifiesto del relevo nocturno.",
        "es_tts": "La sombra bebe antes del alba. Me envía el doctor Valdés para revisar el manifiesto del relevo nocturno.",
        "en_sub": "The shadow drinks before dawn. Doctor Valdés sent me to verify the night-shift cryo manifest.",
        "en_tts": "The shadow drinks before dawn. Doctor Valdes sent me to verify the night-shift cryo manifest.",
    },
    {
        "id": "cv_a1_gate_bluff_ok",
        "speaker": "vampyre",
        "es_sub": "Que el frío te guarde, iniciado. El terminal del fondo sigue abierto para el relevo, pero no toques los tanques.",
        "es_tts": "Que el frío te guarde, iniciado. El terminal del fondo sigue abierto para el relevo, pero no toques los tanques.",
        "en_sub": "May the cold keep you, initiate. The far terminal is unlocked for handoff—don't linger near the vats.",
        "en_tts": "May the cold keep you, initiate. The far terminal is unlocked for handoff—do not linger near the vats.",
    },
    {
        "id": "cv_a1_gate_hostile",
        "speaker": "vampyre",
        "es_sub": "¡Intruso en el embarcadero! ¡Sellad las válvulas y arrancadle hasta la última gota!",
        "es_tts": "¡Intruso en el embarcadero! ¡Sellad las válvulas y arrancadle hasta la última gota!",
        "en_sub": "Intruder on the pier! Seal the vats and drain every last drop from their veins!",
        "en_tts": "Intruder on the pier! Seal the vats and drain every last drop from their veins!",
    },
    {
        "id": "cv_a1_v_manifest_taken",
        "speaker": "v",
        "es_sub": "Mierda... El manifiesto apunta a las Badlands y marca la tienda de Misty como «Nexo de Silencio». Tengo que avisarle ya.",
        "es_tts": "Mierda... El manifiesto apunta a las Badlands y marca la tienda de Misty como Nexo de Silencio. Tengo que avisarle ya.",
        "en_sub": "Damn it... The manifest points out to the Badlands and tags Misty's shop as 'Nexus of Silence'. Gotta warn her fast.",
        "en_tts": "Damn it... The manifest points out to the Badlands and tags Misty's shop as Nexus of Silence. Gotta warn her fast.",
    },
    {
        "id": "cv_a1_misty_debrief_stealth",
        "speaker": "misty",
        "es_sub": "Sentí que volvías en calma, V. Lograste arrancarle sus secretos al Coro sin derramar más sangre en el muelle.",
        "es_tts": "Sentí que volvías en calma, V. Lograste arrancarle sus secretos al Coro sin derramar más sangre en el muelle.",
        "en_sub": "I felt you return in stillness, V. You pried their secrets loose without spilling extra blood on the dock.",
        "en_tts": "I felt you return in stillness, V. You pried their secrets loose without spilling extra blood on the dock.",
    },
    {
        "id": "cv_a1_misty_debrief_combat",
        "speaker": "misty",
        "es_sub": "Vi el resplandor violeta recortar la niebla sobre el puerto, V. Me alivia tenerte de pie otra vez bajo mis faroles.",
        "es_tts": "Vi el resplandor violeta recortar la niebla sobre el puerto, V. Me alivia tenerte de pie otra vez bajo mis faroles.",
        "en_sub": "I saw violet arc light tear through the harbor fog, V. I'm just glad you're standing safe under my lanterns again.",
        "en_tts": "I saw violet arc light tear through the harbor fog, V. I am just glad you are standing safe under my lanterns again.",
    },
    {
        "id": "cv_a1_misty_debrief_badlands",
        "speaker": "misty",
        "es_sub": "Este manifiesto une a Biotechnica con las cartas de El Diablo y La Muerte. Toma esta pistola silenciada y tus edis para lo que viene.",
        "es_tts": "Este manifiesto une a Biotechnica con las cartas de El Diablo y La Muerte. Toma esta pistola silenciada y tus edis para lo que viene.",
        "en_sub": "This manifest links Biotechnica straight to The Devil and Death. Take this suppressed pistol and your Eddies for what's ahead.",
        "en_tts": "This manifest links Biotechnica straight to The Devil and Death. Take this suppressed pistol and your Eddies for what is ahead.",
    },
    {
        "id": "cv_a1_misty_cliffhanger",
        "speaker": "misty",
        "es_sub": "Espera... los sueños del patio no hablan solo de química. Si «La Cantora» viene a por mi tienda, nos veremos en las Badlands.",
        "es_tts": "Espera... los sueños del patio no hablan solo de química. Si La Cantora viene a por mi tienda, nos veremos en las Badlands.",
        "en_sub": "Wait... those dreams aren't pure chemistry after all. If The Cantor comes for my shop, our path leads straight into the Badlands.",
        "en_tts": "Wait... those dreams are not pure chemistry after all. If The Cantor comes for my shop, our path leads straight into the Badlands.",
    },
    # ------------------------------------------------------------------
    # v0.5.0 REBOOT PROLOGUE: LA LUNA MANCHADA (cv_r2_*)
    # ------------------------------------------------------------------
    {
        "id": "cv_r2_call_misty_01",
        "speaker": "misty",
        "es_sub": "¿V? Gracias a Dios que coges. Necesito que vengas al callejón trasero de Esoterica en cuanto puedas.",
        "es_tts": "¿V? Gracias a Dios que coges. Necesito que vengas al callejón trasero de Esoterica en cuanto puedas.",
        "en_sub": "V? Thank God you picked up. I need you at Esoterica's back alley as soon as you can.",
        "en_tts": "V? Thank God you picked up. I need you at Esoterica's back alley as soon as you can.",
    },
    {
        "id": "cv_r2_call_v_01",
        "speaker": "v",
        "es_sub": "¿Misty? Suenas asustada. ¿Ha pasado algo en la tienda?",
        "es_tts": "¿Misty? Suenas asustada. ¿Ha pasado algo en la tienda?",
        "en_sub": "Misty? You sound shaken. Did something happen at the shop?",
        "en_tts": "Misty? You sound shaken. Did something happen at the shop?",
    },
    {
        "id": "cv_r2_call_misty_02",
        "speaker": "misty",
        "es_sub": "Varias amigas y vecinos del barrio llevan días desapareciendo sin dejar rastro, y siento que alguien me vigila. Esta mañana encontré un extraño altar delante de la puerta: media docena de cirios derretidos por la humedad y una sola carta del Tarot cubierta por una mancha oscura.",
        "es_tts": "Varias amigas y vecinos del barrio llevan días desapareciendo sin dejar rastro, y siento que alguien me vigila. Esta mañana encontré un extraño altar delante de la puerta: media docena de cirios derretidos por la humedad y una sola carta del Tarot cubierta por una mancha oscura.",
        "en_sub": "Friends and neighbors have been vanishing for days without a trace, and I feel like someone is watching me. This morning I found a strange shrine outside my door: half a dozen damp melted candles and a single Tarot card covered in a dark stain.",
        "en_tts": "Friends and neighbors have been vanishing for days without a trace, and I feel like someone is watching me. This morning I found a strange shrine outside my door: half a dozen damp melted candles and a single Tarot card covered in a dark stain.",
    },
    {
        "id": "cv_r2_call_v_02",
        "speaker": "v",
        "es_sub": "No dejes entrar a nadie y quédate donde pueda verte. Voy para Watson ahora mismo.",
        "es_tts": "No dejes entrar a nadie y quédate donde pueda verte. Voy para Watson ahora mismo.",
        "en_sub": "Don't let anyone inside and stay where you can be seen. I'm heading to Watson right now.",
        "en_tts": "Don't let anyone inside and stay where you can be seen. I am heading to Watson right now.",
    },
    {
        "id": "cv_r2_alley_misty_warn",
        "speaker": "misty",
        "es_sub": "No la toques todavía, V. Escanéala primero. La dejaron de noche, antes del alba, sin que nadie viera quién fue.",
        "es_tts": "No la toques todavía, V. Escanéala primero. La dejaron de noche, antes del alba, sin que nadie viera quién fue.",
        "en_sub": "Don't touch it yet, V. Scan it first. They left it here at night, before dawn, without anyone seeing who it was.",
        "en_tts": "Do not touch it yet, V. Scan it first. They left it here at night, before dawn, without anyone seeing who it was.",
    },
    {
        "id": "cv_r2_alley_v_scan",
        "speaker": "v",
        "es_sub": "No es sangre normal, Misty. Es hemoglobina sintética mezclada con un estabilizador experimental, y tiene una traza altísima de porfirinas reactivas. Quien sangró sobre esta carta sufriría quemaduras internas graves si le diera el sol directo.",
        "es_tts": "No es sangre normal, Misty. Es hemoglobina sintética mezclada con un estabilizador experimental, y tiene una traza altísima de porfirinas reactivas. Quien sangró sobre esta carta sufriría quemaduras internas graves si le diera el sol directo.",
        "en_sub": "That's not normal blood, Misty. It's synthetic hemoglobin mixed with an experimental stabilizer, and it carries an extreme trace of reactive porphyrins. Whoever bled onto this card would suffer severe internal burns under direct sunlight.",
        "en_tts": "That is not normal blood, Misty. It is synthetic hemoglobin mixed with an experimental stabilizer, and it carries an extreme trace of reactive porphyrins. Whoever bled onto this card would suffer severe internal burns under direct sunlight.",
    },
    {
        "id": "cv_r2_alley_misty_lucia_01",
        "speaker": "misty",
        "es_sub": "Es de Lucía.",
        "es_tts": "Es de Lucía.",
        "en_sub": "It belongs to Lucía.",
        "en_tts": "It belongs to Lucía.",
    },
    {
        "id": "cv_r2_alley_v_lucia_01",
        "speaker": "v",
        "es_sub": "¿La chica del abrigo verde que a veces barre tu escaparate?",
        "es_tts": "¿La chica del abrigo verde que a veces barre tu escaparate?",
        "en_sub": "The girl in the green coat who sweeps your storefront sometimes?",
        "en_tts": "The girl in the green coat who sweeps your storefront sometimes?",
    },
    {
        "id": "cv_r2_alley_misty_lucia_02",
        "speaker": "misty",
        "es_sub": "Sí. Mira la esquina inferior izquierda, donde alguien hizo dos muescas minúsculas con una uña. Se lo enseñé el mes pasado, cuando me dijo que tenía pesadillas y no podía dormir. Jugábamos a que cada Arcano era una palabra secreta. La Luna significa: «Estoy despierta en la oscuridad, pero no puedo salir a la luz». Lleva tres noches sin aparecer por su pensión de Kabuki.",
        "es_tts": "Sí. Mira la esquina inferior izquierda, donde alguien hizo dos muescas minúsculas con una uña. Se lo enseñé el mes pasado, cuando me dijo que tenía pesadillas y no podía dormir. Jugábamos a que cada Arcano era una palabra secreta. La Luna significa: Estoy despierta en la oscuridad, pero no puedo salir a la luz. Lleva tres noches sin aparecer por su pensión de Kabuki.",
        "en_sub": "Yes. Look at the bottom left corner, where someone carved two tiny fingernail notches. I taught her that last month, when she told me nightmares kept her awake. We played that each Arcanum was a secret word. The Moon means: 'I am awake in the darkness, yet I cannot step into the light.' She hasn't returned to her boarding house in Kabuki for three nights.",
        "en_tts": "Yes. Look at the bottom left corner, where someone carved two tiny fingernail notches. I taught her that last month, when she told me nightmares kept her awake. We played that each Arcanum was a secret word. The Moon means: I am awake in the darkness, yet I cannot step into the light. She has not returned to her boarding house in Kabuki for three nights.",
    },
    {
        "id": "cv_r2_alley_v_candles",
        "speaker": "v",
        "es_sub": "Si alguien dejó esto aquí, no fue un simple secuestro de carroñeros. Los carroñeros no dejan velas ni cartas del Tarot. ¿Qué más sabes sobre las otras desapariciones?",
        "es_tts": "Si alguien dejó esto aquí, no fue un simple secuestro de carroñeros. Los carroñeros no dejan velas ni cartas del Tarot. ¿Qué más sabes sobre las otras desapariciones?",
        "en_sub": "If someone left this behind, it wasn't just scavengers grabbing people off the street. Scavs don't leave candles or Tarot cards. What else do you know about the others?",
        "en_tts": "If someone left this behind, it was not just scavengers grabbing people off the street. Scavs do not leave candles or Tarot cards. What else do you know about the others?",
    },
    {
        "id": "cv_r2_alley_qa_missing_v",
        "speaker": "v",
        "es_sub": "Dijiste por teléfono que había más desaparecidos antes que Lucía. ¿Quiénes son?",
        "es_tts": "Dijiste por teléfono que había más desaparecidos antes que Lucía. ¿Quiénes son?",
        "en_sub": "On the call you said others vanished before Lucía. Who are they?",
        "en_tts": "On the call you said others vanished before Lucía. Who are they?",
    },
    {
        "id": "cv_r2_alley_qa_missing_m",
        "speaker": "misty",
        "es_sub": "Mateo, un técnico nocturno del muelle de Northside, desapareció tres días antes que Lucía. Empezó a evitar la luz del día y no volvió tras decir que exigiría su historial médico. Antes que él faltaron otros dos jóvenes del barrio.",
        "es_tts": "Mateo, un técnico nocturno del muelle de Northside, desapareció tres días antes que Lucía. Empezó a evitar la luz del día y no volvió tras decir que exigiría su historial médico. Antes que él faltaron otros dos jóvenes del barrio.",
        "en_sub": "Mateo, a night-shift dock tech from Northside, vanished three days before Lucía. He began avoiding daylight and never came back after saying he'd demand his medical file. Before him, two other neighborhood youths vanished.",
        "en_tts": "Mateo, a night-shift dock tech from Northside, vanished three days before Lucía. He began avoiding daylight and never came back after saying he would demand his medical file. Before him, two other neighborhood youths vanished.",
    },
    {
        "id": "cv_r2_alley_qa_watched_v",
        "speaker": "v",
        "es_sub": "¿Por qué dices que alguien te está vigilando desde la calle?",
        "es_tts": "¿Por qué dices que alguien te está vigilando desde la calle?",
        "en_sub": "Why do you say someone has been watching you from the street?",
        "en_tts": "Why do you say someone has been watching you from the street?",
    },
    {
        "id": "cv_r2_alley_qa_watched_m",
        "speaker": "misty",
        "es_sub": "Dos madrugadas seguidas aparcó un furgón negro sin matrícula frente al callejón, con las luces apagadas. Y anoche alguien inutilizó las farolas de esta acera justo antes de dejar los cirios.",
        "es_tts": "Dos madrugadas seguidas aparcó un furgón negro sin matrícula frente al callejón, con las luces apagadas. Y anoche alguien inutilizó las farolas de esta acera justo antes de dejar los cirios.",
        "en_sub": "Two nights in a row a black van with no plates idled across from the alley with its headlights dead. And last night someone killed the streetlights on this block right before leaving the candles.",
        "en_tts": "Two nights in a row a black van with no plates idled across from the alley with its headlights dead. And last night someone killed the streetlights on this block right before leaving the candles.",
    },
    {
        "id": "cv_r2_alley_qa_chorus_v",
        "speaker": "v",
        "es_sub": "¿Lucía llegó a darte algún nombre o clínica antes de desaparecer?",
        "es_tts": "¿Lucía llegó a darte algún nombre o clínica antes de desaparecer?",
        "en_sub": "Did Lucía ever give you a name or clinic before she vanished?",
        "en_tts": "Did Lucía ever give you a name or clinic before she vanished?",
    },
    {
        "id": "cv_r2_alley_qa_chorus_m",
        "speaker": "misty",
        "es_sub": "Solo me dijo que aceptó un tratamiento nocturno gratuito en una clínica satélite para curarse los pulmones del smog. A la semana siguiente temía al amanecer y susurraba algo sobre El Coro Pálido.",
        "es_tts": "Solo me dijo que aceptó un tratamiento nocturno gratuito en una clínica satélite para curarse los pulmones del smog. A la semana siguiente temía al amanecer y susurraba algo sobre El Coro Pálido.",
        "en_sub": "She only told me she'd taken free night-shift treatment at a satellite clinic to heal her lungs from the smog. A week later she dreaded sunrise and whispered something about The Pale Chorus.",
        "en_tts": "She only told me she had taken free night-shift treatment at a satellite clinic to heal her lungs from the smog. A week later she dreaded sunrise and whispered something about The Pale Chorus.",
    },
    {
        "id": "cv_r2_alley_misty_rooftop",
        "speaker": "misty",
        "es_sub": "Sube conmigo a la azotea cuando anochezca del todo. Abajo hay demasiado ruido y demasiados ojos. A las diez te enseño todo lo que Lucía me contó antes de desaparecer.",
        "es_tts": "Sube conmigo a la azotea cuando anochezca del todo. Abajo hay demasiado ruido y demasiados ojos. A las diez te enseño todo lo que Lucía me contó antes de desaparecer.",
        "en_sub": "Come up to the rooftop with me once true night falls. Down here there is too much noise and too many eyes. At ten I'll show you everything Lucía told me before she disappeared.",
        "en_tts": "Come up to the rooftop with me once true night falls. Down here there is too much noise and too many eyes. At ten I will show you everything Lucía told me before she disappeared.",
    },
    {
        "id": "cv_r2_alley_v_rooftop",
        "speaker": "v",
        "es_sub": "De acuerdo. Quédate a cubierto dentro. Nos vemos en la azotea a las diez.",
        "es_tts": "De acuerdo. Quédate a cubierto dentro. Nos vemos en la azotea a las diez.",
        "en_sub": "All right. Stay inside out of sight. I'll see you on the roof at ten.",
        "en_tts": "All right. Stay inside out of sight. I will see you on the roof at ten.",
    },
    {
        "id": "cv_r2_roof_misty_intro",
        "speaker": "misty",
        "es_sub": "Gracias por subir a tiempo, V. He extendido las cartas junto a los apuntes de Lucía: La Luna, El Ermitaño y La Torre. Si alguien se la llevó tras dejar esa señal, no está lejos de Watson.",
        "es_tts": "Gracias por subir a tiempo, V. He extendido las cartas junto a los apuntes de Lucía: La Luna, El Ermitaño y La Torre. Si alguien se la llevó tras dejar esa señal, no está lejos de Watson.",
        "en_sub": "Thank you for coming up on time, V. I laid the cards beside Lucía's notes: The Moon, The Hermit, and The Tower. If someone took her after leaving that sign, they aren't far from Watson.",
        "en_tts": "Thank you for coming up on time, V. I laid the cards beside Lucía's notes: The Moon, The Hermit, and The Tower. If someone took her after leaving that sign, they are not far from Watson.",
    },
    {
        "id": "cv_r2_roof_misty_uv",
        "speaker": "misty",
        "es_sub": "Mira bajo esta lámpara ultravioleta de trescientos sesenta y cinco nanómetros. En el reverso de La Luna hay un sello químico de trasvase que apunta a los depósitos petrolíferos de Northside.",
        "es_tts": "Mira bajo esta lámpara ultravioleta de trescientos sesenta y cinco nanómetros. En el reverso de La Luna hay un sello químico de trasvase que apunta a los depósitos petrolíferos de Northside.",
        "en_sub": "Look under this three hundred sixty-five nanometer UV lamp. On the back of The Moon there's a chemical transfer stamp pointing straight to the Northside oilfields.",
        "en_tts": "Look under this three hundred sixty five nanometer UV lamp. On the back of The Moon there is a chemical transfer stamp pointing straight to the Northside oilfields.",
    },
    {
        "id": "cv_r2_roof_v_depart",
        "speaker": "v",
        "es_sub": "Depósitos de Northside, de noche y sin testigos. Voy para allá a buscar a Lucía antes de que la muevan.",
        "es_tts": "Depósitos de Northside, de noche y sin testigos. Voy para allá a buscar a Lucía antes de que la muevan.",
        "en_sub": "Northside oilfields, after dark with zero witnesses. I'm heading there now to find Lucía before they move her.",
        "en_tts": "Northside oilfields, after dark with zero witnesses. I am heading there now to find Lucía before they move her.",
    },
    {
        "id": "cv_r2_oil_v_arrive",
        "speaker": "v",
        "es_sub": "Veo el santuario improvisado entre los tanques y un emisor ultravioleta cubriendo la entrada. Voy a apagar ese foco y limpiar el perímetro.",
        "es_tts": "Veo el santuario improvisado entre los tanques y un emisor ultravioleta cubriendo la entrada. Voy a apagar ese foco y limpiar el perímetro.",
        "en_sub": "I see their makeshift shrine between the tanks and an ultraviolet emitter sweeping the entrance. Time to overload that rig and clear the yard.",
        "en_tts": "I see their makeshift shrine between the tanks and an ultraviolet emitter sweeping the entrance. Time to overload that rig and clear the yard.",
    },
    {
        "id": "cv_r2_oil_misty_radio",
        "speaker": "misty",
        "es_sub": "V, detecto un pico eléctrico en tus ópticas. Rompe la caja del emisor si te cierran el paso y revisa las cajas médicas que dejaron junto al altar.",
        "es_tts": "V, detecto un pico eléctrico en tus ópticas. Rompe la caja del emisor si te cierran el paso y revisa las cajas médicas que dejaron junto al altar.",
        "en_sub": "V, I hear electrical static tearing across your comms. Break the emitter housing if they pin you down, and search the medical crates beside the altar.",
        "en_tts": "V, I hear electrical static tearing across your comms. Break the emitter housing if they pin you down, and search the medical crates beside the altar.",
    },
    {
        "id": "cv_r2_oil_v_note",
        "speaker": "v",
        "es_sub": "Un vial clínico vacío de plasma NOX nueve y un recibo de transporte rasgado de esta misma madrugada: Sujeto L catorce, Lucía Reyes, trasladarla antes del relevo del muelle. Sigue viva, Misty. Vuelvo a la azotea con las pruebas.",
        "es_tts": "Un vial clínico vacío de plasma NOX nueve y un recibo de transporte rasgado de esta misma madrugada: Sujeto L catorce, Lucía Reyes, trasladarla antes del relevo del muelle. Sigue viva, Misty. Vuelvo a la azotea con las pruebas.",
        "en_sub": "An empty clinical vial of NOX-9 plasma and a torn transport slip stamped earlier this morning: Subject L-14, Lucía Reyes, transfer before pier shift change. She's still alive, Misty. Heading back to the roof with the proof.",
        "en_tts": "An empty clinical vial of NOX nine plasma and a torn transport slip stamped earlier this morning: Subject L fourteen, Lucía Reyes, transfer before pier shift change. She is still alive, Misty. Heading back to the roof with the proof.",
    },
    {
        "id": "cv_r2_debrief_m1",
        "speaker": "misty",
        "es_sub": "¿Sigue viva? Gracias al cielo, V. Ver el código de su lote médico y ese recibo confirma que no llegamos tarde.",
        "es_tts": "¿Sigue viva? Gracias al cielo, V. Ver el código de su lote médico y ese recibo confirma que no llegamos tarde.",
        "en_sub": "She's still alive? Thank heaven, V. Seeing that medical batch code and transport slip proves we aren't too late.",
        "en_tts": "She is still alive? Thank heaven, V. Seeing that medical batch code and transport slip proves we are not too late.",
    },
    {
        "id": "cv_r2_debrief_v1",
        "speaker": "v",
        "es_sub": "Los secuestradores la sacaron antes del alba, pero dejaron atrás un cargamento de plasma NOX nueve y esta pistola modificada con cargador de luz fría. Quien fabrique ese compuesto nos llevará directo hasta Lucía y Mateo.",
        "es_tts": "Los secuestradores la sacaron antes del alba, pero dejaron atrás un cargamento de plasma NOX nueve y esta pistola modificada con cargador de luz fría. Quien fabrique ese compuesto nos llevará directo hasta Lucía y Mateo.",
        "en_sub": "The abductors moved her before dawn, but they left behind a batch of NOX-9 plasma and this custom pistol loaded with cold-light rounds. Whoever synthesizes that compound will lead us straight to Lucía and Mateo.",
        "en_tts": "The abductors moved her before dawn, but they left behind a batch of NOX nine plasma and this custom pistol loaded with cold-light rounds. Whoever synthesizes that compound will lead us straight to Lucía and Mateo.",
    },
    {
        "id": "cv_r2_debrief_m2",
        "speaker": "misty",
        "es_sub": "Toma tus edis y guarda ese arma cerca. Quédate el archivo del códice actualizado y descansa un momento; en cuanto descifremos quién firma el lote NOX nueve iremos a por Lucía.",
        "es_tts": "Toma tus edis y guarda ese arma cerca. Quédate el archivo del códice actualizado y descansa un momento; en cuanto descifremos quién firma el lote NOX nueve iremos a por Lucía.",
        "en_sub": "Take your Eddies and keep that pistol close. Keep the updated codex file and catch your breath; as soon as we trace who signs the NOX-9 batch, we go after Lucía.",
        "en_tts": "Take your Eddies and keep that pistol close. Keep the updated codex file and catch your breath; as soon as we trace who signs the NOX nine batch, we go after Lucía.",
    },
    # v0.6.0 Faithful Literary Rooftop Scene (Fanfic)
    {
        "id": "cv_r2_roof_open_m1",
        "speaker": "misty",
        "es_sub": "Gracias por venir a las diez, V. Aquí arriba la lluvia apaga el ruido de abajo y nadie escucha.",
        "es_tts": "Gracias por venir a las diez, V. Aquí arriba la lluvia apaga el ruido de abajo y nadie escucha.",
        "en_sub": "Thank you for coming at ten, V. Up here the rain washes out the noise below, and no one is listening.",
        "en_tts": "Thank you for coming at ten, V. Up here the rain washes out the noise below, and no one is listening.",
    },
    {
        "id": "cv_r2_roof_open_m2",
        "speaker": "misty",
        "es_sub": "Lucía me pidió que le leyera estas cartas la última vez que subió: La Luna, El Colgado invertido y La Torre. En sus apuntes hablaba de El Coro Pálido, gente que se oculta de la luz cerca de Northside.",
        "es_tts": "Lucía me pidió que le leyera estas cartas la última vez que subió: La Luna, El Colgado invertido y La Torre. En sus apuntes hablaba de El Coro Pálido, gente que se oculta de la luz cerca de Northside.",
        "en_sub": "Lucía asked me to lay out these cards the last time she came up here: The Moon, The Hanged Man inverted, and The Tower. In her notes she wrote of The Pale Chorus, people hiding from daylight somewhere near Northside.",
        "en_tts": "Lucía asked me to lay out these cards the last time she came up here: The Moon, The Hanged Man inverted, and The Tower. In her notes she wrote of The Pale Chorus, people hiding from daylight somewhere near Northside.",
    },
    {
        "id": "cv_r2_roof_open_m3",
        "speaker": "misty",
        "es_sub": "Me preguntó si uno puede entregar algo de sí mismo para no morir solo en esta ciudad... Ojalá hubiera entendido entonces que no me hablaba de una metáfora.",
        "es_tts": "Me preguntó si uno puede entregar algo de sí mismo para no morir solo en esta ciudad... Ojalá hubiera entendido entonces que no me hablaba de una metáfora.",
        "en_sub": "She asked me if someone could give away a piece of themselves just so they wouldn't die alone in this city... I wish I'd realized then she wasn't speaking in metaphors.",
        "en_tts": "She asked me if someone could give away a piece of themselves just so they wouldn't die alone in this city... I wish I had realized then she wasn't speaking in metaphors.",
    },
    {
        "id": "cv_r2_roof_chem_v",
        "speaker": "v",
        "es_sub": "Misty, no es ningún hechizo ni un pacto de Tarot. Es química sucia: hemoglobina sintética y porfirinas reactivas que hierven bajo los rayos ultravioleta.",
        "es_tts": "Misty, no es ningún hechizo ni un pacto de Tarot. Es química sucia: hemoglobina sintética y porfirinas reactivas que hierven bajo los rayos ultravioleta.",
        "en_sub": "Misty, this isn't magic or a Tarot curse. It's dirty chemistry: synthetic hemoglobin and reactive porphyrins that boil under ultraviolet light.",
        "en_tts": "Misty, this isn't magic or a Tarot curse. It is dirty chemistry: synthetic hemoglobin and reactive porphyrins that boil under ultraviolet light.",
    },
    {
        "id": "cv_r2_roof_chem_m",
        "speaker": "misty",
        "es_sub": "Lo sé, V... pero quienes aceptan esa sangre no solo buscan huir de la enfermedad. Buscan pertenecer a algo que no los descarte al amanecer, y ahí es donde esa secta los atrapa.",
        "es_tts": "Lo sé, V... pero quienes aceptan esa sangre no solo buscan huir de la enfermedad. Buscan pertenecer a algo que no los descarte al amanecer, y ahí es donde esa secta los atrapa.",
        "en_sub": "I know, V... but the ones who accept that blood aren't only running from sickness. They're looking to belong to something that won't cast them aside at dawn, and that is how that cult traps them.",
        "en_tts": "I know, V... but the ones who accept that blood aren't only running from sickness. They are looking to belong to something that won't cast them aside at dawn, and that is how that cult traps them.",
    },
    {
        "id": "cv_r2_roof_cards_v",
        "speaker": "v",
        "es_sub": "Dime cómo conectabas estos tres arcanos con sus cuadernos: La Luna, El Colgado invertido y La Torre.",
        "es_tts": "Dime cómo conectabas estos tres arcanos con sus cuadernos: La Luna, El Colgado invertido y La Torre.",
        "en_sub": "Tell me how you read those three cards alongside her notebooks: The Moon, The Hanged Man inverted, and The Tower.",
        "en_tts": "Tell me how you read those three cards alongside her notebooks: The Moon, The Hanged Man inverted, and The Tower.",
    },
    {
        "id": "cv_r2_roof_cards_m",
        "speaker": "misty",
        "es_sub": "La Luna es el secreto nocturno que Lucía ya guardaba en su piel. El Colgado invertido es la promesa de renacer pagando un sacrificio en silencio. Y La Torre... es la caída cuando esa falsa salvación se derrumba.",
        "es_tts": "La Luna es el secreto nocturno que Lucía ya guardaba en su piel. El Colgado invertido es la promesa de renacer pagando un sacrificio en silencio. Y La Torre... es la caída cuando esa falsa salvación se derrumba.",
        "en_sub": "The Moon is the nocturnal secret Lucía was already carrying in her veins. The Hanged Man inverted is the false vow of rebirth through silent sacrifice. And The Tower... is the fall when that promised salvation collapses.",
        "en_tts": "The Moon is the nocturnal secret Lucía was already carrying in her veins. The Hanged Man inverted is the false vow of rebirth through silent sacrifice. And The Tower... is the fall when that promised salvation collapses.",
    },
    {
        "id": "cv_r2_roof_tower_v",
        "speaker": "v",
        "es_sub": "Espera, Misty, dale la vuelta a La Torre. La cera del borde tiene gravilla aceitosa y residuo petroquímico... esto viene directo de los depósitos abandonados de Northside.",
        "es_tts": "Espera, Misty, dale la vuelta a La Torre. La cera del borde tiene gravilla aceitosa y residuo petroquímico... esto viene directo de los depósitos abandonados de Northside.",
        "en_sub": "Wait, Misty, turn The Tower over. There's oily grit and petrochemical residue pressed into the wax along the edge... that comes straight from the abandoned Northside oilfields.",
        "en_tts": "Wait, Misty, turn The Tower over. There is oily grit and petrochemical residue pressed into the wax along the edge... that comes straight from the abandoned Northside oilfields.",
    },
    {
        "id": "cv_r2_roof_promise_m",
        "speaker": "misty",
        "es_sub": "Si te cruzas con ellos en Northside, recuerda la luz ultravioleta. Tráeme pruebas de que Lucía sigue viva, V... no dejes que se convierta en otra sombra más del Coro.",
        "es_tts": "Si te cruzas con ellos en Northside, recuerda la luz ultravioleta. Tráeme pruebas de que Lucía sigue viva, V... no dejes que se convierta en otra sombra más del Coro.",
        "en_sub": "If they corner you in Northside, remember the ultraviolet light. Bring me proof that Lucía is still alive, V... don't let her become another shadow in that Chorus.",
        "en_tts": "If they corner you in Northside, remember the ultraviolet light. Bring me proof that Lucía is still alive, V... do not let her become another shadow in that Chorus.",
    },
    # ------------------------------------------------------------------
    # v0.8.0 ACTO I PARTE 1: EL PULSO DEL LOTE NOX-9 (cv_a1_r2_*)
    # ------------------------------------------------------------------
    {
        "id": "cv_a1_r2_call_m1",
        "speaker": "misty",
        "es_sub": "V, ¿tienes un segundo? Le pasé a Vik el código del lote NOX-9-K4 y el recibo de Lucía que sacaste de Northside. Un viejo contacto suyo cruzó esa fórmula con patentes retiradas de Biotechnica: el único hematólogo que diseñó y firmó ese compuesto es un tal doctor Adrián Valdés.",
        "es_tts": "V, ¿tienes un segundo? Le pasé a Vik el código del lote NOX nueve ka cuatro y el recibo de Lucía que sacaste de Northside. Un viejo contacto suyo cruzó esa fórmula con patentes retiradas de Biotechnica: el único hematólogo que diseñó y firmó ese compuesto es un tal doctor Adrián Valdés.",
        "en_sub": "V, got a second? I passed the NOX-9-K4 batch code and Lucía's slip from Northside over to Vik. An old contact of his ran that formula against retired Biotechnica patents—the only hematologist who designed and signed off on it is a Dr. Adrián Valdés.",
        "en_tts": "V, got a second? I passed the NOX nine K four batch code and Lucía's slip from Northside over to Vik. An old contact of his ran that formula against retired Biotechnica patents—the only hematologist who designed and signed off on it is a Doctor Adrián Valdés.",
    },
    {
        "id": "cv_a1_r2_call_v1",
        "speaker": "v",
        "es_sub": "¿Y ese Valdés trabaja para El Coro Pálido o se esconde de ellos? Si firmó la fórmula del lote, sabrá quién se llevó a Lucía y a Mateo.",
        "es_tts": "¿Y ese Valdés trabaja para El Coro Pálido o se esconde de ellos? Si firmó la fórmula del lote, sabrá quién se llevó a Lucía y a Mateo.",
        "en_sub": "Is this Valdés working for The Pale Chorus or hiding from them? If his name is on the formula, he'll know who took Lucía and Mateo.",
        "en_tts": "Is this Valdés working for The Pale Chorus or hiding from them? If his name is on the formula, he will know who took Lucía and Mateo.",
    },
    {
        "id": "cv_a1_r2_call_m2",
        "speaker": "misty",
        "es_sub": "Justo hace unos minutos saltó un pulso de telemetría del mismo lote NOX-9-K4 junto a un embarcadero abandonado del Canal de Kabuki. Ve a revisar lo que hayan tirado allí: seguro que nos lleva directo hasta Valdés antes de que el Coro borre su rastro.",
        "es_tts": "Justo hace unos minutos saltó un pulso de telemetría del mismo lote NOX nueve ka cuatro junto a un embarcadero abandonado del Canal de Kabuki. Ve a revisar lo que hayan tirado allí: seguro que nos lleva directo hasta Valdés antes de que el Coro borre su rastro.",
        "en_sub": "Just a few minutes ago a live telemetry ping from that exact NOX-9-K4 batch fired near an abandoned dock along the Kabuki Canal. Check whatever they dumped there—it should lead straight to Valdés before the Chorus scrubs his trail.",
        "en_tts": "Just a few minutes ago a live telemetry ping from that exact NOX nine K four batch fired near an abandoned dock along the Kabuki Canal. Check whatever they dumped there—it should lead straight to Valdés before the Chorus scrubs his trail.",
    },
    {
        "id": "cv_a1_r2_call_v2",
        "speaker": "v",
        "es_sub": "Voy para el Canal de Kabuki ahora mismo. Si Valdés sigue en Watson, lo voy a encontrar.",
        "es_tts": "Voy para el Canal de Kabuki ahora mismo. Si Valdés sigue en Watson, lo voy a encontrar.",
        "en_sub": "Heading to the Kabuki Canal right now. If Valdés is still in Watson, I'll find him.",
        "en_tts": "Heading to the Kabuki Canal right now. If Valdés is still in Watson, I will find him.",
    },
    {
        "id": "cv_a1_r2_kabuki_arrive",
        "speaker": "v",
        "es_sub": "Embarcadero de desagüe en el Canal de Kabuki... Ahí están los descartes médicos, las velas y un relé todavía encendido. Vamos a revisar cada pista.",
        "es_tts": "Embarcadero de desagüe en el Canal de Kabuki... Ahí están los descartes médicos, las velas y un relé todavía encendido. Vamos a revisar cada pista.",
        "en_sub": "Drainage dock down by the Kabuki Canal... There's the dumped medical gear, the candles, and an active relay. Let's inspect every trace.",
        "en_tts": "Drainage dock down by the Kabuki Canal... There is the dumped medical gear, the candles, and an active relay. Let us inspect every trace.",
    },
    {
        "id": "cv_a1_r2_clue_cooler",
        "speaker": "v",
        "es_sub": "Un refrigerador de diálisis portátil con sellos de Biotechnica raspados. Dentro hay matraces vacíos del lote NOX-9-K4 y etiquetas de dosificación para el Sujeto L-14, Lucía Reyes, y el Sujeto M-09, Mateo. Esta es la misma fórmula de Valdés.",
        "es_tts": "Un refrigerador de diálisis portátil con sellos de Biotechnica raspados. Dentro hay matraces vacíos del lote NOX nueve ka cuatro y etiquetas de dosificación para el Sujeto L catorce, Lucía Reyes, y el Sujeto M cero nueve, Mateo. Esta es la misma fórmula de Valdés.",
        "en_sub": "A portable dialysis cooler with scraped Biotechnica seals. Inside are empty NOX-9-K4 flasks and dosing tags for Subject L-14, Lucía Reyes, and Subject M-09, Mateo. That's Valdés's exact formula.",
        "en_tts": "A portable dialysis cooler with scraped Biotechnica seals. Inside are empty NOX nine K four flasks and dosing tags for Subject L fourteen, Lucía Reyes, and Subject M oh nine, Mateo. That is Valdés's exact formula.",
    },
    {
        "id": "cv_a1_r2_clue_tarot",
        "speaker": "v",
        "es_sub": "La Sacerdotisa invertida clavada entre cirios húmedos... y grapada al reverso está la licencia médica anulada del doctor Adrián Valdés. No es un altar cualquiera: El Coro Pálido la dejó aquí como amenaza para demostrarle que saben que sigue en Watson.",
        "es_tts": "La Sacerdotisa invertida clavada entre cirios húmedos... y grapada al reverso está la licencia médica anulada del doctor Adrián Valdés. No es un altar cualquiera: El Coro Pálido la dejó aquí como amenaza para demostrarle que saben que sigue en Watson.",
        "en_sub": "The High Priestess inverted, pinned between damp candles... and stapled to the back is Dr. Adrián Valdés's revoked corporate medical license. Not just a shrine—The Pale Chorus left it as a threat to prove they know he's still in Watson.",
        "en_tts": "The High Priestess inverted, pinned between damp candles... and stapled to the back is Doctor Adrián Valdés's revoked corporate medical license. Not just a shrine—The Pale Chorus left it as a threat to prove they know he is still in Watson.",
    },
    {
        "id": "cv_a1_r2_clue_relay",
        "speaker": "v",
        "es_sub": "Este relé de telemetría de Biotechnica sigue caliente y rebotando señal. Acaba de triangular el retorno hacia un callejón escondido en Little China. Ya tengo el escondite exacto del doctor Valdés.",
        "es_tts": "Este relé de telemetría de Biotechnica sigue caliente y rebotando señal. Acaba de triangular el retorno hacia un callejón escondido en Little China. Ya tengo el escondite exacto del doctor Valdés.",
        "en_sub": "This Biotechnica telemetry relay is still warm and pinging. Just triangulated the return beacon to a hidden back alley in Little China. I've got Dr. Valdés's exact hideout.",
        "en_tts": "This Biotechnica telemetry relay is still warm and pinging. Just triangulated the return beacon to a hidden back alley in Little China. I have got Doctor Valdés's exact hideout.",
    },
    {
        "id": "cv_a1_r2_valdes_intro",
        "speaker": "valdes",
        "es_sub": "¡Quieto, no des un paso más! Si te envía La Cantora para callarme, dispara de una vez y acaba con esto.",
        "es_tts": "¡Quieto, no des un paso más! Si te envía La Cantora para callarme, dispara de una vez y acaba con esto.",
        "en_sub": "Stop—don't take another step! If The Cantor sent you to silence me, pull the trigger and get it over with.",
        "en_tts": "Stop—do not take another step! If The Cantor sent you to silence me, pull the trigger and get it over with.",
    },
    {
        "id": "cv_a1_r2_v_intro",
        "speaker": "v",
        "es_sub": "Baja el pulso, doctor Valdés. No vengo del Coro Pálido. Vengo por el lote NOX-9-K4 de Northside... y por Lucía Reyes y Mateo. Sabemos que tú firmaste esa fórmula.",
        "es_tts": "Baja el pulso, doctor Valdés. No vengo del Coro Pálido. Vengo por el lote NOX nueve ka cuatro de Northside... y por Lucía Reyes y Mateo. Sabemos que tú firmaste esa fórmula.",
        "en_sub": "Easy, Dr. Valdés. I'm not with The Pale Chorus. I'm here about the NOX-9-K4 batch from Northside—and Lucía Reyes and Mateo. We know your name is on that formula.",
        "en_tts": "Easy, Doctor Valdés. I am not with The Pale Chorus. I am here about the NOX nine K four batch from Northside—and Lucía Reyes and Mateo. We know your name is on that formula.",
    },
    {
        "id": "cv_a1_r2_v_ask_role",
        "speaker": "v",
        "es_sub": "Empieza por tu papel en todo esto. ¿Qué es exactamente el NOX-9 y por qué lleva tu firma de Biotechnica?",
        "es_tts": "Empieza por tu papel en todo esto. ¿Qué es exactamente el NOX nueve y por qué lleva tu firma de Biotechnica?",
        "en_sub": "Start with your part in this. What is NOX-9 really, and why does it carry your Biotechnica patent?",
        "en_tts": "Start with your part in this. What is NOX nine really, and why does it carry your Biotechnica patent?",
    },
    {
        "id": "cv_a1_r2_valdes_ans_role",
        "speaker": "valdes",
        "es_sub": "Diseñé el NOX-9 hace seis años para salvar a trabajadores con pulmones destrozados por el smog sin condenarlos a pagar implantes corporativos. Aumentaba el oxígeno en sangre y regeneraba tejido, pero acumulaba porfirinas letales: cualquier luz solar o ultravioleta de 365 nm te abrasa por dentro. Biotechnica enterró el proyecto y me echó a la calle. Arruinado, le vendí mis patentes y muestras a la doctora Helena Solís creyendo que terminaría la cura.",
        "es_tts": "Diseñé el NOX nueve hace seis años para salvar a trabajadores con pulmones destrozados por el smog sin condenarlos a pagar implantes corporativos. Aumentaba el oxígeno en sangre y regeneraba tejido, pero acumulaba porfirinas letales: cualquier luz solar o ultravioleta de trescientos sesenta y cinco nanómetros te abrasa por dentro. Biotechnica enterró el proyecto y me echó a la calle. Arruinado, le vendí mis patentes y muestras a la doctora Helena Solís creyendo que terminaría la cura.",
        "en_sub": "I engineered NOX-9 six years ago to save workers with smog-ruined lungs who couldn't afford corpo chrome. It boosted oxygen and tissue repair, but trapped lethal porphyrins—sunlight or 365 nm UV boils you from within. Biotechnica buried the trial and fired me. Broke, I sold my patents and samples to Dr. Helena Solís believing she'd finish the cure.",
        "en_tts": "I engineered NOX nine six years ago to save workers with smog-ruined lungs who could not afford corpo chrome. It boosted oxygen and tissue repair, but trapped lethal porphyrins—sunlight or three hundred sixty five nanometer ultraviolet boils you from within. Biotechnica buried the trial and fired me. Broke, I sold my patents and samples to Doctor Helena Solís believing she would finish the cure.",
    },
    {
        "id": "cv_a1_r2_v_ask_sect",
        "speaker": "v",
        "es_sub": "¿Y cómo acabó tu suero médico en manos de una secta que deja cartas del Tarot y caza gente de noche?",
        "es_tts": "¿Y cómo acabó tu suero médico en manos de una secta que deja cartas del Tarot y caza gente de noche?",
        "en_sub": "And how did your lung serum end up in the hands of a cult leaving Tarot cards and hunting people after dark?",
        "en_tts": "And how did your lung serum end up in the hands of a cult leaving Tarot cards and hunting people after dark?",
    },
    {
        "id": "cv_a1_r2_valdes_ans_sect",
        "speaker": "valdes",
        "es_sub": "Helena Solís se hace llamar ahora La Cantora y convirtió mi fracaso en El Coro Pálido. Atraen a chicos desesperados como Lucía y Mateo con clínicas nocturnas gratuitas, los vuelven dependientes de diálisis semanales y usan el pánico al amanecer como jaula y liturgia. Yo... seguí fabricándoles estabilizadores durante meses por culpa y por miedo a que me mataran. Cuando descubrí que secuestraban a quien intentaba dejarlo, escapé aquí. Por eso dejaron La Sacerdotisa invertida en Kabuki: para recordarme que me vigilan.",
        "es_tts": "Helena Solís se hace llamar ahora La Cantora y convirtió mi fracaso en El Coro Pálido. Atraen a chicos desesperados como Lucía y Mateo con clínicas nocturnas gratuitas, los vuelven dependientes de diálisis semanales y usan el pánico al amanecer como jaula y liturgia. Yo... seguí fabricándoles estabilizadores durante meses por culpa y por miedo a que me mataran. Cuando descubrí que secuestraban a quien intentaba dejarlo, escapé aquí. Por eso dejaron La Sacerdotisa invertida en Kabuki: para recordarme que me vigilan.",
        "en_sub": "Helena Solís now calls herself The Cantor and twisted my failure into The Pale Chorus. They lure desperate kids like Lucía and Mateo into free night clinics, hook them on weekly dialysis, and turn fear of sunrise into a cage and liturgy. I... kept making stabilizers for months out of guilt and fear. When I saw them abducting anyone who tried to quit, I ran here. That's why they pinned the inverted High Priestess in Kabuki—to warn me they're watching.",
        "en_tts": "Helena Solís now calls herself The Cantor and twisted my failure into The Pale Chorus. They lure desperate kids like Lucía and Mateo into free night clinics, hook them on weekly dialysis, and turn fear of sunrise into a cage and liturgy. I... kept making stabilizers for months out of guilt and fear. When I saw them abducting anyone who tried to quit, I ran here. That is why they pinned the inverted High Priestess in Kabuki—to warn me they are watching.",
    },
    {
        "id": "cv_a1_r2_v_ask_leads",
        "speaker": "v",
        "es_sub": "Si les preparabas estabilizadores, sabes adónde trasladaron a Lucía desde Northside y dónde tienen a Mateo.",
        "es_tts": "Si les preparabas estabilizadores, sabes adónde trasladaron a Lucía desde Northside y dónde tienen a Mateo.",
        "en_sub": "If you mixed their stabilizers, you know where they moved Lucía from Northside—and where they're holding Mateo.",
        "en_tts": "If you mixed their stabilizers, you know where they moved Lucía from Northside—and where they are holding Mateo.",
    },
    {
        "id": "cv_a1_r2_valdes_ans_leads",
        "speaker": "valdes",
        "es_sub": "Todos los sujetos recién despertados y los registros de traslado pasan antes por su puesto criogénico del Muelle Oeste de Watson, custodiado por un centinela nocturno y dos torres ultravioleta. Desde ese terminal coordinan los envíos hacia el búnker central de Helena en las Badlands, donde dice haber purificado una segunda generación del suero sin porfirinas: el NOX-9B.",
        "es_tts": "Todos los sujetos recién despertados y los registros de traslado pasan antes por su puesto criogénico del Muelle Oeste de Watson, custodiado por un centinela nocturno y dos torres ultravioleta. Desde ese terminal coordinan los envíos hacia el búnker central de Helena en las Badlands, donde dice haber purificado una segunda generación del suero sin porfirinas: el NOX nueve be.",
        "en_sub": "Every newly awakened subject and transfer manifest passes first through their cryogenic checkpoint on Watson's West Pier, guarded by a night sentry and twin UV towers. From that terminal they route shipments to Helena's main bunker in the Badlands—where she claims to have purified a second-generation serum without porphyrins: NOX-9B.",
        "en_tts": "Every newly awakened subject and transfer manifest passes first through their cryogenic checkpoint on Watson's West Pier, guarded by a night sentry and twin ultraviolet towers. From that terminal they route shipments to Helena's main bunker in the Badlands—where she claims to have purified a second-generation serum without porphyrins: NOX nine B.",
    },
    {
        "id": "cv_a1_r2_v_trust",
        "speaker": "v",
        "es_sub": "Aún puedes arreglar parte del daño, Adrián. Dame tus claves, las coordenadas del muelle y tus notas del NOX-9. Voy a sacar a Lucía y a Mateo de ahí.",
        "es_tts": "Aún puedes arreglar parte del daño, Adrián. Dame tus claves, las coordenadas del muelle y tus notas del NOX nueve. Voy a sacar a Lucía y a Mateo de ahí.",
        "en_sub": "You can still undo part of this, Adrián. Give me your pass codes, the pier coordinates, and your NOX-9 files. I'm pulling Lucía and Mateo out.",
        "en_tts": "You can still undo part of this, Adrián. Give me your pass codes, the pier coordinates, and your NOX nine files. I am pulling Lucía and Mateo out.",
    },
    {
        "id": "cv_a1_r2_valdes_give_trust",
        "speaker": "valdes",
        "es_sub": "Gracias por escucharme antes de juzgarme. Toma este pincho de la mesa: lleva la contraseña del relevo nocturno, «La sombra bebe antes del alba», las coordenadas del terminal criogénico del Muelle Oeste y mi expediente completo sobre el NOX-9 y el NOX-9B. Úsalo para entrar sin alertar a las torres si puedes.",
        "es_tts": "Gracias por escucharme antes de juzgarme. Toma este pincho de la mesa: lleva la contraseña del relevo nocturno, La sombra bebe antes del alba, las coordenadas del terminal criogénico del Muelle Oeste y mi expediente completo sobre el NOX nueve y el NOX nueve be. Úsalo para entrar sin alertar a las torres si puedes.",
        "en_sub": "Thank you for hearing me out before judging me. Take this shard on the desk—it holds the night-shift passphrase 'The shadow drinks before dawn', the West Pier cryo terminal coordinates, and my full NOX-9 and NOX-9B dossier. Use it to slip past the UV towers if you can.",
        "en_tts": "Thank you for hearing me out before judging me. Take this shard on the desk—it holds the night-shift passphrase The shadow drinks before dawn, the West Pier cryo terminal coordinates, and my full NOX nine and NOX nine B dossier. Use it to slip past the ultraviolet towers if you can.",
    },
    {
        "id": "cv_a1_r2_v_pressure",
        "speaker": "v",
        "es_sub": "Tu arrepentimiento no va a sacar a Lucía de una cámara criogénica. Dame la clave del muelle y todo lo que tengas sobre Solís ahora mismo.",
        "es_tts": "Tu arrepentimiento no va a sacar a Lucía de una cámara criogénica. Dame la clave del muelle y todo lo que tengas sobre Solís ahora mismo.",
        "en_sub": "Your guilt won't pull Lucía out of a cryo pod. Hand over the pier pass code and everything you have on Solís right now.",
        "en_tts": "Your guilt will not pull Lucía out of a cryo pod. Hand over the pier pass code and everything you have on Solís right now.",
    },
    {
        "id": "cv_a1_r2_valdes_give_pressure",
        "speaker": "valdes",
        "es_sub": "¡Está bien, llévatelo todo! En ese pincho de la mesa tienes el santo y seña nocturno, «La sombra bebe antes del alba», las coordenadas del Muelle Oeste y mis archivos del NOX-9 y el NOX-9B. Solo déjame desaparecer antes de que el Coro baje por este callejón.",
        "es_tts": "¡Está bien, llévatelo todo! En ese pincho de la mesa tienes el santo y seña nocturno, La sombra bebe antes del alba, las coordenadas del Muelle Oeste y mis archivos del NOX nueve y el NOX nueve be. Solo déjame desaparecer antes de que el Coro baje por este callejón.",
        "en_sub": "Fine—take all of it! That shard on the desk has the night-shift passphrase 'The shadow drinks before dawn', the West Pier coordinates, and all my NOX-9 and NOX-9B files. Just let me vanish before the Chorus drops into this alley.",
        "en_tts": "Fine—take all of it! That shard on the desk has the night-shift passphrase The shadow drinks before dawn, the West Pier coordinates, and all my NOX nine and NOX nine B files. Just let me vanish before the Chorus drops into this alley.",
    },
    {
        "id": "cv_a1_r2_v_depart",
        "speaker": "v",
        "es_sub": "Pincho cifrado en mi poder: clave nocturna del Coro, coordenadas del Muelle Oeste de Watson y expediente completo de Valdés sobre Solís y el NOX-9B. Ya tenemos todo para golpear el puesto criogénico.",
        "es_tts": "Pincho cifrado en mi poder: clave nocturna del Coro, coordenadas del Muelle Oeste de Watson y expediente completo de Valdés sobre Solís y el NOX nueve be. Ya tenemos todo para golpear el puesto criogénico.",
        "en_sub": "Encrypted shard secured—night-shift Chorus passphrase, West Pier coordinates, and Valdés's full dossier on Solís and NOX-9B. We've got everything we need to hit that cryo checkpoint.",
        "en_tts": "Encrypted shard secured—night-shift Chorus passphrase, West Pier coordinates, and Valdés's full dossier on Solís and NOX nine B. We have got everything we need to hit that cryo checkpoint.",
    },
    {
        "id": "cv_a1_r2_debrief_m1_stealth",
        "speaker": "misty",
        "es_sub": "Has vuelto de una pieza, V... y sin dejar otro rastro de pólvora en el puerto. La contraseña de Valdés funcionó. Dime qué sacaste de ese terminal del Muelle Oeste.",
        "es_tts": "Has vuelto de una pieza, V... y sin dejar otro rastro de pólvora en el puerto. La contraseña de Valdés funcionó. Dime qué sacaste de ese terminal del Muelle Oeste.",
        "en_sub": "You made it back in one piece, V—and without leaving another trail of gunfire across the docks. Valdés's cipher worked. Tell me what you pulled from that West Pier terminal.",
        "en_tts": "You made it back in one piece, V—and without leaving another trail of gunfire across the docks. Valdés's cipher worked. Tell me what you pulled from that West Pier terminal.",
    },
    {
        "id": "cv_a1_r2_debrief_m1_combat",
        "speaker": "misty",
        "es_sub": "Vi los destellos violetas sobre el puerto desde aquí arriba, V. Me alegra tenerte de vuelta y a salvo. Dime qué sacaste de ese terminal del Muelle Oeste.",
        "es_tts": "Vi los destellos violetas sobre el puerto desde aquí arriba, V. Me alegra tenerte de vuelta y a salvo. Dime qué sacaste de ese terminal del Muelle Oeste.",
        "en_sub": "I saw those violet UV flashes tearing across the harbor from up here, V. I'm just glad you're back safe. Tell me what you pulled from that West Pier terminal.",
        "en_tts": "I saw those violet ultraviolet flashes tearing across the harbor from up here, V. I am just glad you are back safe. Tell me what you pulled from that West Pier terminal.",
    },
    {
        "id": "cv_a1_r2_debrief_v1",
        "speaker": "v",
        "es_sub": "Ya tenemos el mapa completo, Misty. El doctor Adrián Valdés creó el NOX-9 hace seis años, pero la doctora Helena Solís —la que llaman La Cantora— le robó el proyecto para montar El Coro Pálido. El manifiesto del muelle confirma que sacaron a Lucía Reyes y a Mateo de Watson rumbo a un búnker clausurado de Biotechnica en las Badlands.",
        "es_tts": "Ya tenemos el mapa completo, Misty. El doctor Adrián Valdés creó el Nox nueve hace seis años, pero la doctora Helena Solís —la que llaman La Cantora— le robó el proyecto para montar El Coro Pálido. El manifiesto del muelle confirma que sacaron a Lucía Reyes y a Mateo de Watson rumbo a un búnker clausurado de Biotechnica en las Badlands.",
        "en_sub": "We finally have the full picture, Misty. Dr. Adrián Valdés created NOX-9 six years ago, and Dr. Helena Solís—'The Cantor'—hijacked his work to build The Pale Chorus. The pier manifest confirms they shipped Lucía Reyes and Mateo out of Watson to a sealed Biotechnica bunker in the Badlands.",
        "en_tts": "We finally have the full picture, Misty. Doctor Adrian Valdes created Nox nine six years ago, and Doctor Helena Solis—The Cantor—hijacked his work to build The Pale Chorus. The pier manifest confirms they shipped Lucia Reyes and Mateo out of Watson to a sealed Biotechnica bunker in the Badlands.",
    },
    {
        "id": "cv_a1_r2_debrief_m2",
        "speaker": "misty",
        "es_sub": "Entonces Lucía y Mateo siguen vivos, pero fuera de la ciudad... Espera, V: ¿qué es esta nota al final del manifiesto? Han marcado Misty's Esoterica como «Nexo de Silencio» y con vigilancia prioritaria. Saben que estamos tirando del hilo desde aquí.",
        "es_tts": "Entonces Lucía y Mateo siguen vivos, pero fuera de la ciudad... Espera, V: ¿qué es esta nota al final del manifiesto? Han marcado Misty's Esoterica como Nexo de Silencio y con vigilancia prioritaria. Saben que estamos tirando del hilo desde aquí.",
        "en_sub": "So Lucía and Mateo are still alive, just out beyond the city... Wait, V—what's this entry at the bottom of the manifest? They flagged Misty's Esoterica as 'Nexus of Silence' under priority watch. They know someone is pulling the thread from here.",
        "en_tts": "So Lucia and Mateo are still alive, just out beyond the city... Wait, V—what is this entry at the bottom of the manifest? They flagged Misty's Esoterica as Nexus of Silence under priority watch. They know someone is pulling the thread from here.",
    },
    {
        "id": "cv_a1_r2_debrief_v2",
        "speaker": "v",
        "es_sub": "Y todavía hay algo más peligroso. Según las notas de Valdés y los registros de carga, en ese búnker del desierto Solís está probando una segunda versión del suero llamada NOX-9B, sin porfirinas. Si consigue estabilizarlo, dejarán de arder con la luz ultravioleta y perderemos la única ventaja táctica que tenemos contra ellos.",
        "es_tts": "Y todavía hay algo más peligroso. Según las notas de Valdés y los registros de carga, en ese búnker del desierto Solís está probando una segunda versión del suero llamada Nox nueve be, sin porfirinas. Si consigue estabilizarlo, dejarán de arder con la luz ultravioleta y perderemos la única ventaja táctica que tenemos contra ellos.",
        "en_sub": "And there's an even bigger problem. Valdés's files and the cargo logs say Solís is testing a second-generation serum called NOX-9B out in that desert bunker—without porphyrins. If she stabilizes it, ultraviolet light won't burn them anymore, and we lose our only real edge against them.",
        "en_tts": "And there is an even bigger problem. Valdes's files and the cargo logs say Solis is testing a second-generation serum called Nox nine B out in that desert bunker—without porphyrins. If she stabilizes it, ultraviolet light will not burn them anymore, and we lose our only real edge against them.",
    },
    {
        "id": "cv_a1_r2_debrief_m3",
        "speaker": "misty",
        "es_sub": "No podemos dejar que terminen ese suero ni que nos encierren aquí. Voy a reforzar la tienda con Vik y a cruzar estas frecuencias del manifiesto para triangular la entrada exacta del búnker en las Badlands. Toma tus edis por lo que has hecho hoy, V. En cuanto descifremos la ruta, te llamaré para cruzar al desierto, rescatar a Lucía y a Mateo y detener a La Cantora de una vez por todas.",
        "es_tts": "No podemos dejar que terminen ese suero ni que nos encierren aquí. Voy a reforzar la tienda con Vik y a cruzar estas frecuencias del manifiesto para triangular la entrada exacta del búnker en las Badlands. Toma tus edis por lo que has hecho hoy, V. En cuanto descifremos la ruta, te llamaré para cruzar al desierto, rescatar a Lucía y a Mateo y detener a La Cantora de una vez por todas.",
        "en_sub": "We can't let her finish that serum or box us in here. I'll lock down the shop with Vik and cross-check these manifest frequencies to pinpoint the exact bunker entrance in the Badlands. Take your Eddies for everything you pulled off tonight, V. The moment we crack the route, I'll call you so we can head into the desert, bring Lucía and Mateo home, and stop The Cantor for good.",
        "en_tts": "We cannot let her finish that serum or box us in here. I will lock down the shop with Vik and cross-check these manifest frequencies to pinpoint the exact bunker entrance in the Badlands. Take your Eddies for everything you pulled off tonight, V. The moment we crack the route, I will call you so we can head into the desert, bring Lucia and Mateo home, and stop The Cantor for good.",
    },
    {
        "id": "cv_a1_r2_debrief_v3",
        "speaker": "v",
        "es_sub": "Mantén la persiana bajada y ten el móvil cerca, Misty. En cuanto tengas las coordenadas del búnker, nos vemos en las Badlands y acabamos con El Coro Pálido.",
        "es_tts": "Mantén la persiana bajada y ten el móvil cerca, Misty. En cuanto tengas las coordenadas del búnker, nos vemos en las Badlands y acabamos con El Coro Pálido.",
        "en_sub": "Keep the shutters down and your holo close, Misty. The second you lock down those bunker coordinates, I'm heading into the Badlands to finish The Pale Chorus.",
        "en_tts": "Keep the shutters down and your holo close, Misty. The second you lock down those bunker coordinates, I am heading into the Badlands to finish The Pale Chorus.",
    },
    # --- Acto II en Badlands: Liturgia de Ceniza (37 líneas) ---
    {
        "id": "cv_a2_call_m1",
        "speaker": "misty",
        "es_sub": "V, ya tenemos las coordenadas. Vik y yo cruzamos las balizas del manifiesto del Muelle Oeste con los repetidores del sur.",
        "es_tts": "V, ya tenemos las coordenadas. Vik y yo cruzamos las balizas del manifiesto del Muelle Oeste con los repetidores del sur.",
        "en_sub": "V, we cracked the coordinates. Vik and I cross-referenced the West Pier manifest beacons against the southern repeaters.",
        "en_tts": "V, we cracked the coordinates. Vik and I cross-referenced the West Pier manifest beacons against the southern repeaters.",
    },
    {
        "id": "cv_a2_call_v1",
        "speaker": "v",
        "es_sub": "¿Dónde descargaron a Lucía? ¿Seguimos a tiempo antes de que estabilicen el NOX-9B?",
        "es_tts": "¿Dónde descargaron a Lucía? ¿Seguimos a tiempo antes de que estabilicen el Nox nueve be?",
        "en_sub": "Where did they dump Lucía? Are we still ahead of their NOX-9B synthesis window?",
        "en_tts": "Where did they dump Lucia? Are we still ahead of their Nox nine B synthesis window?",
    },
    {
        "id": "cv_a2_call_m2",
        "speaker": "misty",
        "es_sub": "El convoy se detuvo por última vez en un punto de servicio de Biotechnica Flats antes de entrar al búnker clausurado de La Cantora. Ve allí y triangula el acceso.",
        "es_tts": "El convoy se detuvo por última vez en un punto de servicio de Biotechnica Flats antes de entrar al búnker clausurado de La Cantora. Ve allí y triangula el acceso.",
        "en_sub": "The convoy made one last drop in Biotechnica Flats before vanishing toward The Cantor's sealed bunker. Sweep that drop and lock the entrance.",
        "en_tts": "The convoy made one last drop in Biotechnica Flats before vanishing toward The Cantor's sealed bunker. Sweep that drop and lock the entrance.",
    },
    {
        "id": "cv_a2_call_v2",
        "speaker": "v",
        "es_sub": "Salgo hacia Biotechnica Flats ahora mismo. Tú no abras la tienda hasta que te avise, Misty.",
        "es_tts": "Salgo hacia Biotechnica Flats ahora mismo. Tú no abras la tienda hasta que te avise, Misty.",
        "en_sub": "Rolling out to Biotechnica Flats right now. Keep Esoterica locked down until I call back.",
        "en_tts": "Rolling out to Biotechnica Flats right now. Keep Esoterica locked down until I call back.",
    },
    {
        "id": "cv_a2_flats_arrive",
        "speaker": "v",
        "es_sub": "Zona de servicio en mitad de Biotechnica Flats... Ahí está el equipo criogénico descartado del convoy. Veamos qué dejaron atrás.",
        "es_tts": "Zona de servicio en mitad de Biotechnica Flats... Ahí está el equipo criogénico descartado del convoy. Veamos qué dejaron atrás.",
        "en_sub": "Abandoned service yard out in Biotechnica Flats... That's the convoy's dumped cryo rig. Let's see what they left behind.",
        "en_tts": "Abandoned service yard out in Biotechnica Flats... That is the convoy's dumped cryo rig. Let us see what they left behind.",
    },
    {
        "id": "cv_a2_clue_pod",
        "speaker": "v",
        "es_sub": "Cápsula de traslado con código L-14, Lucía Reyes... Está abierta y limpia por dentro, y las pruebas de carga marcan lotes nuevos de NOX-9B.",
        "es_tts": "Cápsula de traslado con código L catorce, Lucía Reyes... Está abierta y limpia por dentro, y las pruebas de carga marcan lotes nuevos de Nox nueve be.",
        "en_sub": "Cryo transfer pod tagged Subject L-14, Lucía Reyes. Unsealed and emptied here—alongside fresh shipping tags for NOX-9B trials.",
        "en_tts": "Cryo transfer pod tagged Subject L fourteen, Lucia Reyes. Unsealed and emptied here—alongside fresh shipping tags for Nox nine B trials.",
    },
    {
        "id": "cv_a2_clue_mateo",
        "speaker": "v",
        "es_sub": "Una placa de técnico de Northside partida y otra carta de La Luna... Mateo M-09 intentó sabotear el convoy para ayudar a escapar a Lucía, y Helena Solís lo ejecutó aquí mismo.",
        "es_tts": "Una placa de técnico de Northside partida y otra carta de La Luna... Mateo M cero nueve intentó sabotear el convoy para ayudar a escapar a Lucía, y Helena Solís lo ejecutó aquí mismo.",
        "en_sub": "A shattered Northside dock badge beside another Moon card... Mateo M-09 sabotaged this convoy trying to free Lucía, and Helena Solís executed him here.",
        "en_tts": "A shattered Northside dock badge beside another Moon card... Mateo M zero nine sabotaged this convoy trying to free Lucia, and Helena Solis executed him here.",
    },
    {
        "id": "cv_a2_clue_relay",
        "speaker": "v",
        "es_sub": "Este repetidor de microondas aún conserva el enlace del búnker: un kilómetro al noreste, bajo la antigua estación geotérmica de Biotechnica. Vamos a por ellas.",
        "es_tts": "Este repetidor de microondas aún conserva el enlace del búnker: un kilómetro al noreste, bajo la antigua estación geotérmica de Biotechnica. Vamos a por ellas.",
        "en_sub": "This microwave relay still holds the bunker handshake—one kilometer northeast, beneath Biotechnica's decommissioned geothermal plant. Time to end this.",
        "en_tts": "This microwave relay still holds the bunker handshake—one kilometer northeast, beneath Biotechnica's decommissioned geothermal plant. Time to end this.",
    },
    {
        "id": "cv_a2_bunker_arrive",
        "speaker": "v",
        "es_sub": "La estación geotérmica de las Badlands... El Coro Pálido vigila la entrada exterior con otra torre UV. Habrá que abrirse paso hasta Lucía.",
        "es_tts": "La estación geotérmica de las Badlands... El Coro Pálido vigila la entrada exterior con otra torre ultravioleta. Habrá que abrirse paso hasta Lucía.",
        "en_sub": "Biotechnica's old geothermal plant... The Pale Chorus has armed sentries and another UV tower guarding the outer perimeter. Gotta clear a path to Lucía.",
        "en_tts": "Biotechnica's old geothermal plant... The Pale Chorus has armed sentries and another ultraviolet tower guarding the outer perimeter. Gotta clear a path to Lucia.",
    },
    {
        "id": "cv_a2_lucia_intro",
        "speaker": "lucia",
        "es_sub": "¿V? ¡Sabía que Misty descifraría las dos muescas en la carta de La Luna! Creía que nadie saldría a buscarme tan lejos de Watson.",
        "es_tts": "¿V? ¡Sabía que Misty descifraría las dos muescas en la carta de La Luna! Creía que nadie saldría a buscarme tan lejos de Watson.",
        "en_sub": "V? I knew Misty would read the two notches on The Moon card! I thought nobody would ever track me out this far past Watson.",
        "en_tts": "V? I knew Misty would read the two notches on The Moon card! I thought nobody would ever track me out this far past Watson.",
    },
    {
        "id": "cv_a2_v_lucia_intro",
        "speaker": "v",
        "es_sub": "Misty removió media ciudad para encontrarte, Lucía. Estás fuera de peligro por ahora, pero antes dime todo lo que pasa ahí abajo.",
        "es_tts": "Misty removió media ciudad para encontrarte, Lucía. Estás fuera de peligro por ahora, pero antes dime todo lo que pasa ahí abajo.",
        "en_sub": "Misty tore half of Watson apart to find you, Lucía. You're clear for now—tell me everything happening down in that bunker.",
        "en_tts": "Misty tore half of Watson apart to find you, Lucia. You are clear for now—tell me everything happening down in that bunker.",
    },
    {
        "id": "cv_a2_v_lucia_q1",
        "speaker": "v",
        "es_sub": "Encontré la placa de Mateo en Biotechnica Flats. Dime la verdad sobre lo que ocurrió durante el traslado.",
        "es_tts": "Encontré la placa de Mateo en Biotechnica Flats. Dime la verdad sobre lo que ocurrió durante el traslado.",
        "en_sub": "I found Mateo's badge back in Biotechnica Flats. Tell me what really happened during the convoy transfer.",
        "en_tts": "I found Mateo's badge back in Biotechnica Flats. Tell me what really happened during the convoy transfer.",
    },
    {
        "id": "cv_a2_lucia_a1",
        "speaker": "lucia",
        "es_sub": "Mateo descubrió que no nos estaban curando, sino convirtiéndonos en cobayas dependientes del suero. Cortó los cables criogénicos en mitad del desierto para que yo pudiera huir, pero Solís lo abatió delante de mí y borró su expediente.",
        "es_tts": "Mateo descubrió que no nos estaban curando, sino convirtiéndonos en cobayas dependientes del suero. Cortó los cables criogénicos en mitad del desierto para que yo pudiera huir, pero Solís lo abatió delante de mí y borró su expediente.",
        "en_sub": "Mateo figured out they weren't curing us—they were locking us into chemical dependency. He cut the cryo lines out in the flats so I could bolt, and Solís gunned him down right in front of me.",
        "en_tts": "Mateo figured out they were not curing us—they were locking us into chemical dependency. He cut the cryo lines out in the flats so I could bolt, and Solis gunned him down right in front of me.",
    },
    {
        "id": "cv_a2_v_lucia_q2",
        "speaker": "v",
        "es_sub": "¿En qué punto está exactamente ese suero NOX-9B que prepara Helena Solís ahí abajo?",
        "es_tts": "¿En qué punto está exactamente ese suero Nox nueve be que prepara Helena Solís ahí abajo?",
        "en_sub": "How close is Helena Solís to actually stabilizing that NOX-9B serum down in the lab?",
        "en_tts": "How close is Helena Solis to actually stabilizing that Nox nine B serum down in the lab?",
    },
    {
        "id": "cv_a2_lucia_a2",
        "speaker": "lucia",
        "es_sub": "Lo tiene al noventa y ocho por ciento en el biorreactor inferior. Si termina la síntesis, El Coro Pálido dejará de ser vulnerable a la luz ultravioleta. Además, quiere silenciar la tienda de Misty porque la considera un puente de conciencia con sus pacientes.",
        "es_tts": "Lo tiene al noventa y ocho por ciento en el biorreactor inferior. Si termina la síntesis, El Coro Pálido dejará de ser vulnerable a la luz ultravioleta. Además, quiere silenciar la tienda de Misty porque la considera un puente de conciencia con sus pacientes.",
        "en_sub": "The lower bioreactor is already at ninety-eight percent synthesis. Once she finishes it, UV light won't touch them—and she ordered Misty's shop silenced as a subversive link.",
        "en_tts": "The lower bioreactor is already at ninety-eight percent synthesis. Once she finishes it, ultraviolet light will not touch them—and she ordered Misty's shop silenced as a subversive link.",
    },
    {
        "id": "cv_a2_v_lucia_adv",
        "speaker": "v",
        "es_sub": "Ponte a cubierto detrás del perímetro exterior y espera mi señal. Bajo ahora mismo a enfrentarme a La Cantora.",
        "es_tts": "Ponte a cubierto detrás del perímetro exterior y espera mi señal. Bajo ahora mismo a enfrentarme a La Cantora.",
        "en_sub": "Stay behind the outer perimeter and wait for my signal. I'm heading down to confront The Cantor now.",
        "en_tts": "Stay behind the outer perimeter and wait for my signal. I am heading down to confront The Cantor now.",
    },
    {
        "id": "cv_a2_lucia_adv",
        "speaker": "lucia",
        "es_sub": "Ten cuidado abajo, V: Solís tiene dos guardias y focos ultravioleta en la terraza del reactor. Si nos ves vivos en la azotea de Misty, por fin seremos libres.",
        "es_tts": "Ten cuidado abajo, V: Solís tiene dos guardias y focos ultravioleta en la terraza del reactor. Si nos ves vivos en la azotea de Misty, por fin seremos libres.",
        "en_sub": "Watch your step down there, V—Solís keeps two guards and UV rigs beside the reactor terrace. Meet us back on Misty's roof once it's over.",
        "en_tts": "Watch your step down there, V—Solis keeps two guards and ultraviolet rigs beside the reactor terrace. Meet us back on Misty's roof once it is over.",
    },
    {
        "id": "cv_a2_solis_intro",
        "speaker": "solis",
        "es_sub": "Así que tú eres la sombra de Misty Olszewski. Pensé que Adrián Valdés enviaría a un asesino corporativo, no a alguien que aún cree en rescates románticos.",
        "es_tts": "Así que tú eres la sombra de Misty Olszewski. Pensé que Adrián Valdés enviaría a un asesino corporativo, no a alguien que aún cree en rescates románticos.",
        "en_sub": "So you're Misty Olszewski's hound. I expected Biotechnica clean-up or Valdés's panic, not someone still chasing sentimental rescues.",
        "en_tts": "So you are Misty Olszewski's hound. I expected Biotechnica clean-up or Valdes's panic, not someone still chasing sentimental rescues.",
    },
    {
        "id": "cv_a2_v_solis_q1",
        "speaker": "v",
        "es_sub": "Valdés empezó el NOX-9 para curar pulmones, Solís. Tú lo convertiste en una secta y mataste a Mateo cuando intentó huir.",
        "es_tts": "Valdés empezó el Nox nueve para curar pulmones, Solís. Tú lo convertiste en una secta y mataste a Mateo cuando intentó huir.",
        "en_sub": "Valdés built NOX-9 to heal damaged lungs, Solís. You twisted it into a cult and executed Mateo when he tried to walk.",
        "en_tts": "Valdes built Nox nine to heal damaged lungs, Solis. You twisted it into a cult and executed Mateo when he tried to walk.",
    },
    {
        "id": "cv_a2_solis_a1",
        "speaker": "solis",
        "es_sub": "Biotechnica quería dejar morir a los pobres de Watson cuando no podían pagar implantes. Yo les di regeneración real y comunidad en la noche. Mateo rompió nuestro juramento de silencio y puso en riesgo a todo el Coro.",
        "es_tts": "Biotechnica quería dejar morir a los pobres de Watson cuando no podían pagar implantes. Yo les di regeneración real y comunidad en la noche. Mateo rompió nuestro juramento de silencio y puso en riesgo a todo el Coro.",
        "en_sub": "Biotechnica left Watson workers choking because they couldn't afford chrome. I gave them regeneration and belonging in the dark. Mateo broke our oath and endangered everyone.",
        "en_tts": "Biotechnica left Watson workers choking because they could not afford chrome. I gave them regeneration and belonging in the dark. Mateo broke our oath and endangered everyone.",
    },
    {
        "id": "cv_a2_v_solis_q2",
        "speaker": "v",
        "es_sub": "Explícame el NOX-9B. ¿De verdad quita las porfirinas o solo es otra correa química más cara?",
        "es_tts": "Explícame el Nox nueve be. ¿De verdad quita las porfirinas o solo es otra correa química más cara?",
        "en_sub": "Tell me about NOX-9B. Does it actually purge the porphyrins, or is it just a tighter leash?",
        "en_tts": "Tell me about Nox nine B. Does it actually purge the porphyrins, or is it just a tighter leash?",
    },
    {
        "id": "cv_a2_solis_a2",
        "speaker": "solis",
        "es_sub": "El NOX-9B elimina la fototoxicidad a trescientos sesenta y cinco nanómetros y estabiliza la sangre sin depender de diálisis semanales. Quien controle esta fórmula podrá caminar al sol… o elegir a quién deja atrás en las sombras.",
        "es_tts": "El Nox nueve be elimina la fototoxicidad a trescientos sesenta y cinco nanómetros y estabiliza la sangre sin depender de diálisis semanales. Quien controle esta fórmula podrá caminar al sol… o elegir a quién deja atrás en las sombras.",
        "en_sub": "NOX-9B strips out 365 nm phototoxicity and stabilizes hemoglobin without weekly dialysis. Whoever holds this formula walks back into sunlight—or decides who stays in the dark.",
        "en_tts": "Nox nine B strips out three hundred sixty five nanometers phototoxicity and stabilizes hemoglobin without weekly dialysis. Whoever holds this formula walks back into sunlight—or decides who stays in the dark.",
    },
    {
        "id": "cv_a2_v_solis_q3",
        "speaker": "v",
        "es_sub": "¿Y qué demonios pinta Misty Olszewski en tus manifiestos? ¿Por qué ordenaste vigilar Esoterica como Nexo de Silencio?",
        "es_tts": "¿Y qué demonios pinta Misty Olszewski en tus manifiestos? ¿Por qué ordenaste vigilar Esoterica como Nexo de Silencio?",
        "en_sub": "Why is Misty Olszewski in your shipping logs? Why mark Esoterica as 'Nexus of Silence'?",
        "en_tts": "Why is Misty Olszewski in your shipping logs? Why mark Esoterica as Nexus of Silence?",
    },
    {
        "id": "cv_a2_solis_a3",
        "speaker": "solis",
        "es_sub": "Porque Lucía usó sus cartas del Tarot para comunicarse fuera del Coro y porque esa tienda recuerda a mis acólitos la vida que abandonaron. Bajar de la torre empieza por cerrar todas las puertas del pasado.",
        "es_tts": "Porque Lucía usó sus cartas del Tarot para comunicarse fuera del Coro y porque esa tienda recuerda a mis acólitos la vida que abandonaron. Bajar de la torre empieza por cerrar todas las puertas del pasado.",
        "en_sub": "Because Lucía used those Tarot cards to signal outside the Chorus, and that little shop reminds my initiates of the past we asked them to shed.",
        "en_tts": "Because Lucia used those Tarot cards to signal outside the Chorus, and that little shop reminds my initiates of the past we asked them to shed.",
    },
    {
        "id": "cv_a2_v_end_cure",
        "speaker": "v",
        "es_sub": "No vas a negociar con la sangre de nadie más, Solís. Me llevo intacta la fórmula del NOX-9B para Valdés y saco a Lucía de aquí hoy mismo.",
        "es_tts": "No vas a negociar con la sangre de nadie más, Solís. Me llevo intacta la fórmula del Nox nueve be para Valdés y saco a Lucía de aquí hoy mismo.",
        "en_sub": "You're done trading in other people's veins, Solís. I'm taking NOX-9B intact to Valdés and walking Lucía out of here tonight.",
        "en_tts": "You are done trading in other people's veins, Solis. I am taking Nox nine B intact to Valdes and walking Lucia out of here tonight.",
    },
    {
        "id": "cv_a2_solis_combat",
        "speaker": "solis",
        "es_sub": "¡Entonces arderás entre el acero del Coro Pálido! ¡Cerrad las compuertas del reactor y no dejéis que toque el núcleo!",
        "es_tts": "¡Entonces arderás entre el acero del Coro Pálido! ¡Cerrad las compuertas del reactor y no dejéis que toque el núcleo!",
        "en_sub": "Then burn beneath the Pale Chorus! Lock the reactor terrace and keep them off that core!",
        "en_tts": "Then burn beneath the Pale Chorus! Lock the reactor terrace and keep them off that core!",
    },
    {
        "id": "cv_a2_v_end_pact",
        "speaker": "v",
        "es_sub": "Hagamos un trato rápido y sucio: liberas a Lucía, entregas dosis de emergencia y borras Misty's Esoterica de tus redes para siempre. A cambio, sigo de largo.",
        "es_tts": "Hagamos un trato rápido y sucio: liberas a Lucía, entregas dosis de emergencia y borras Esoterica de tus redes para siempre. A cambio, sigo de largo.",
        "en_sub": "Clean truce, Solís: release Lucía with clean stabilizers and scrub Misty's Esoterica from every ledger. Do that, and I walk away.",
        "en_tts": "Clean truce, Solis: release Lucia with clean stabilizers and scrub Misty's Esoterica from every ledger. Do that, and I walk away.",
    },
    {
        "id": "cv_a2_solis_pact",
        "speaker": "solis",
        "es_sub": "Sabia elección en Night City. Watson queda fuera de nuestros registros y Lucía puede irse con su amiga. Pero no vuelvas a cruzar nuestra sombra.",
        "es_tts": "Sabia elección en Night City. Watson queda fuera de nuestros registros y Lucía puede irse con su amiga. Pero no vuelvas a cruzar nuestra sombra.",
        "en_sub": "Pragmatic as always in Night City. Watson is struck from our manifest and Lucía walks free—just don't step into our shadow again.",
        "en_tts": "Pragmatic as always in Night City. Watson is struck from our manifest and Lucia walks free—just do not step into our shadow again.",
    },
    {
        "id": "cv_a2_v_end_burn",
        "speaker": "v",
        "es_sub": "Esta cámara muere aquí contigo, Cantora. Voy a calcinar hasta la última probeta del NOX-9B y borrar El Coro Pálido del mapa.",
        "es_tts": "Esta cámara muere aquí contigo, Cantora. Voy a calcinar hasta la última probeta del Nox nueve be y borrar El Coro Pálido del mapa.",
        "en_sub": "This chamber burns with you, Cantor. I'm torching every last vial of NOX-9B and erasing The Pale Chorus tonight.",
        "en_tts": "This chamber burns with you, Cantor. I am torching every last vial of Nox nine B and erasing The Pale Chorus tonight.",
    },
    {
        "id": "cv_a2_v_core_secured",
        "speaker": "v",
        "es_sub": "Fórmula depurada NOX-9B descargada y encriptada para Adrián Valdés y Misty. Hora de volver a Watson con Lucía.",
        "es_tts": "Fórmula depurada Nox nueve be descargada y encriptada para Adrián Valdés y Misty. Hora de volver a Watson con Lucía.",
        "en_sub": "Purified NOX-9B synthesis pulled and encrypted for Valdés and Misty. Time to bring Lucía home to Watson.",
        "en_tts": "Purified Nox nine B synthesis pulled and encrypted for Valdes and Misty. Time to bring Lucia home to Watson.",
    },
    {
        "id": "cv_a2_v_core_destroyed",
        "speaker": "v",
        "es_sub": "Biorreactor purgado y archivos reducidos a ceniza. Ya no fabricarán más cadenas químicas desde aquí. Volvamos con Misty.",
        "es_tts": "Biorreactor purgado y archivos reducidos a ceniza. Ya no fabricarán más cadenas químicas desde aquí. Volvamos con Misty.",
        "en_sub": "Bioreactor purged and archives torched to ash. No more chemical chains out of this hole—back to Misty's roof.",
        "en_tts": "Bioreactor purged and archives torched to ash. No more chemical chains out of this hole—back to Misty's roof.",
    },
    {
        "id": "cv_a2_roof_lucia_greet",
        "speaker": "lucia",
        "es_sub": "No sé cómo darte las gracias, V. Volver a oír la lluvia de Little China sin temer al próximo amanecer parecía imposible hasta hoy.",
        "es_tts": "No sé cómo darte las gracias, V. Volver a oír la lluvia de Little China sin temer al próximo amanecer parecía imposible hasta hoy.",
        "en_sub": "I don't know how to thank you, V. Hearing Little China rain without dreading the next sunrise felt impossible until today.",
        "en_tts": "I do not know how to thank you, V. Hearing Little China rain without dreading the next sunrise felt impossible until today.",
    },
    {
        "id": "cv_a2_roof_misty_cure",
        "speaker": "misty",
        "es_sub": "Vik ya está revisando tu fórmula del NOX-9B junto al doctor Valdés desde la distancia. Por primera vez, Lucía y los demás tienen esperanza real de volver a caminar bajo el sol.",
        "es_tts": "Vik ya está revisando tu fórmula del Nox nueve be junto al doctor Valdés desde la distancia. Por primera vez, Lucía y los demás tienen esperanza real de volver a caminar bajo el sol.",
        "en_sub": "Vik is already reviewing your NOX-9B formula with Dr. Valdés over encrypted comms. For the first time, Lucía and the others have a real shot at walking in daylight again.",
        "en_tts": "Vik is already reviewing your Nox nine B formula with Doctor Valdes over encrypted comms. For the first time, Lucia and the others have a real shot at walking in daylight again.",
    },
    {
        "id": "cv_a2_roof_misty_pact",
        "speaker": "misty",
        "es_sub": "Lucía está a salvo bajo mi techo y Watson ha quedado fuera del alcance de Solís. Sé que el Coro seguirá oculto en otros distritos, pero hoy salvaste a quien podíamos salvar.",
        "es_tts": "Lucía está a salvo bajo mi techo y Watson ha quedado fuera del alcance de Solís. Sé que el Coro seguirá oculto en otros distritos, pero hoy salvaste a quien podíamos salvar.",
        "en_sub": "Lucía is safe under my roof and Solís wiped Watson from her ledgers. The Chorus still lingers elsewhere in the city, yet tonight you saved the one life in reach.",
        "en_tts": "Lucia is safe under my roof and Solis wiped Watson from her ledgers. The Chorus still lingers elsewhere in the city, yet tonight you saved the one life in reach.",
    },
    {
        "id": "cv_a2_roof_misty_burn",
        "speaker": "misty",
        "es_sub": "Arrancaste ese laboratorio de raíz y nadie volverá a atrapar chicos desesperados bajo tierra. Tardaremos tiempo en limpiar el suero de la sangre de Lucía, pero al menos ya nadie la persigue.",
        "es_tts": "Arrancaste ese laboratorio de raíz y nadie volverá a atrapar chicos desesperados bajo tierra. Tardaremos tiempo en limpiar el suero de la sangre de Lucía, pero al menos ya nadie la persigue.",
        "en_sub": "You burned that lab down to its roots so no other desperate kids end up chained underground. Clearing Lucía's blood will take time, yet nobody hunts her anymore.",
        "en_tts": "You burned that lab down to its roots so no other desperate kids end up chained underground. Clearing Lucia's blood will take time, yet nobody hunts her anymore.",
    },
    {
        "id": "cv_a2_roof_misty_epilogue",
        "speaker": "misty",
        "es_sub": "Cuando volvamos a abrir Esoterica mañana, La Luna sobre esa mesa ya no será una llamada de socorro en la oscuridad. Toma este revólver Alba Carmesí y tu paga, V: Mateo no murió en vano.",
        "es_tts": "Cuando volvamos a abrir Esoterica mañana, La Luna sobre esa mesa ya no será una llamada de socorro en la oscuridad. Toma este revólver Alba Carmesí y tu paga, V: Mateo no murió en vano.",
        "en_sub": "When we raise Esoterica's shutters tomorrow, The Moon on this table won't be an SOS anymore. Take this Crimson Dawn revolver and your Eddies, V—Mateo didn't die for nothing.",
        "en_tts": "When we raise Esoterica's shutters tomorrow, The Moon on this table will not be an SOS anymore. Take this Crimson Dawn revolver and your Eddies, V—Mateo did not die for nothing.",
    },
    {
        "id": "cv_a2_roof_v_close",
        "speaker": "v",
        "es_sub": "Cuídate en el barrio, Lucía, y cierra bien cuando caiga la noche, Misty. Si El Coro Pálido vuelve a sacar cabeza en Night City, ya sabes qué número marcar.",
        "es_tts": "Cuídate en el barrio, Lucía, y cierra bien cuando caiga la noche, Misty. Si El Coro Pálido vuelve a sacar cabeza en Night City, ya sabes qué número marcar.",
        "en_sub": "Look after yourself in Kabuki, Lucía—and bolt the door at nightfall, Misty. If The Pale Chorus ever raises its head again, you know my holo.",
        "en_tts": "Look after yourself in Kabuki, Lucia—and bolt the door at nightfall, Misty. If The Pale Chorus ever raises its head again, you know my holo.",
    },
]


def _find_ffmpeg() -> str:
    ff = shutil.which("ffmpeg")
    if ff:
        return ff
    fallback = Path(r"C:\Users\educa\AppData\Local\Microsoft\WinGet\Links\ffmpeg.EXE")
    if fallback.is_file():
        return str(fallback)
    raise FileNotFoundError("No se encontró ffmpeg en PATH ni en WinGet Links.")


def _api_post_json(
    api_key: str,
    url: str,
    payload: dict[str, Any],
    accept: str = "application/json",
    timeout: int = 90,
) -> bytes:
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "xi-api-key": api_key,
            "Content-Type": "application/json",
            "Accept": accept,
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read()
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:400]
        raise RuntimeError(f"ElevenLabs HTTP {exc.code} on {url.split('?')[0]}: {body}") from exc


def _list_account_voices_by_name(api_key: str) -> dict[str, str]:
    req = urllib.request.Request(
        "https://api.elevenlabs.io/v1/voices",
        headers={"xi-api-key": api_key, "Accept": "application/json"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        return {
            str(v["name"]): str(v["voice_id"])
            for v in data.get("voices", [])
            if v.get("name") and v.get("voice_id")
        }
    except Exception:
        return {}


def _delete_voice_by_id(api_key: str, voice_id: str) -> bool:
    if not voice_id:
        return False
    req = urllib.request.Request(
        f"https://api.elevenlabs.io/v1/voices/{voice_id}",
        headers={"xi-api-key": api_key, "Accept": "application/json"},
        method="DELETE",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return 200 <= resp.status < 300
    except Exception:
        return False


def _estimate_f0_hz(ffmpeg_bin: str, audio_path: Path) -> float:
    with tempfile.TemporaryDirectory(prefix="cv_f0_") as tmp:
        wav_path = Path(tmp) / "probe16k.wav"
        subprocess.run(
            [ffmpeg_bin, "-y", "-loglevel", "error", "-i", str(audio_path), "-ar", "16000", "-ac", "1", str(wav_path)],
            check=True,
        )
        with wave.open(str(wav_path), "rb") as wf:
            pcm = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16).astype(np.float64) / 32768.0
    sr = 16000
    win, hop = 640, 160
    min_lag, max_lag = int(sr / 320), int(sr / 75)
    f0s: list[float] = []
    for start in range(0, len(pcm) - win - max_lag, hop):
        seg = pcm[start : start + win] - np.mean(pcm[start : start + win])
        if float(np.sqrt(np.mean(seg * seg))) < 0.025:
            continue
        ea = float(np.sum(seg * seg))
        if ea <= 1e-8:
            continue
        nccf = np.zeros(max_lag + 1)
        for lag in range(min_lag, max_lag + 1):
            b = pcm[start + lag : start + win + lag] - np.mean(pcm[start + lag : start + win + lag])
            denom = float(np.sqrt(ea * np.sum(b * b)))
            if denom > 1e-8:
                nccf[lag] = float(np.sum(seg * b)) / denom
        gmax = float(np.max(nccf[min_lag:]))
        if gmax < 0.55:
            continue
        thresh = 0.94 * gmax
        for lag in range(min_lag + 1, max_lag):
            if nccf[lag] >= thresh and nccf[lag] >= nccf[lag - 1] and nccf[lag] >= nccf[lag + 1]:
                f0s.append(sr / float(lag))
                break
    return round(float(np.median(f0s)), 1) if f0s else 0.0


def _export_candidates_and_pick(
    ffmpeg_bin: str,
    role: str,
    lang: str,
    candidates: list[dict[str, Any]],
    f0_band: tuple[float, float, float],
) -> tuple[str, float]:
    AUDITION_DIR.mkdir(parents=True, exist_ok=True)
    min_hz, target_hz, max_hz = f0_band
    scored: list[tuple[dict[str, Any], float]] = []
    with tempfile.TemporaryDirectory(prefix="cv_cand_") as tmp:
        for idx, prev in enumerate(candidates):
            b64 = prev.get("audio_base_64") or ""
            f0 = 0.0
            if b64:
                raw_mp3 = Path(tmp) / f"cand_{idx}.mp3"
                raw_mp3.write_bytes(base64.b64decode(b64))
                f0 = _estimate_f0_hz(ffmpeg_bin, raw_mp3)
                audition_wav = AUDITION_DIR / f"{role.capitalize()}_{lang.upper()}_Candidata_{idx + 1:02d}_{int(round(f0))}Hz.wav"
                subprocess.run(
                    [ffmpeg_bin, "-y", "-loglevel", "error", "-i", str(raw_mp3), "-ar", "44100", "-ac", "1", "-c:a", "pcm_s16le", str(audition_wav)],
                    check=True,
                )
            scored.append((prev, f0))
            print(f"[VOICE CANDIDATE] {role}:{lang} idx={idx + 1} f0={f0:.1f}Hz")

    target_band = [item for item in scored if min_hz <= item[1] <= max_hz]
    if target_band:
        chosen, chosen_f0 = min(target_band, key=lambda x: abs(x[1] - target_hz))
        return str(chosen["generated_voice_id"]), chosen_f0

    valid = [item for item in scored if item[1] >= 75.0]
    if valid:
        chosen, chosen_f0 = min(valid, key=lambda x: abs(x[1] - target_hz))
        return str(chosen["generated_voice_id"]), chosen_f0

    return str(candidates[0]["generated_voice_id"]), 0.0


def ensure_custom_voices(
    api_key: str,
    ffmpeg_bin: str,
    redesign: bool = False,
    langs: tuple[str, ...] = ("es",),
) -> dict[str, dict[str, str]]:
    voices_map: dict[str, dict[str, str]] = {}
    if CUSTOM_VOICES_JSON.is_file():
        voices_map = json.loads(CUSTOM_VOICES_JSON.read_text(encoding="utf-8"))

    for role, lang_ids in SEEDED_VOICES.items():
        role_map = voices_map.setdefault(role, {})
        for lang, vid in lang_ids.items():
            if not role_map.get(lang):
                role_map[lang] = vid

    existing_by_name = {} if redesign else _list_account_voices_by_name(api_key)

    for role, lang_specs in VOICE_DESIGN_SPECS.items():
        role_map = voices_map.setdefault(role, {})
        for lang, spec in lang_specs.items():
            if lang not in langs:
                continue
            if not redesign and role_map.get(lang):
                continue
            vname = spec["voice_name"]
            if not redesign and vname in existing_by_name:
                role_map[lang] = existing_by_name[vname]
                CUSTOM_VOICES_JSON.write_text(json.dumps(voices_map, indent=2, ensure_ascii=False), encoding="utf-8")
                print(f"[VOICE REUSE] {role}:{lang} ({vname}) -> {role_map[lang]}")
                continue

            previous_vid = role_map.get(lang, "")
            f0_band = tuple(spec["f0_band"])
            f0_min, _, f0_max = f0_band
            all_candidates: list[dict[str, Any]] = []
            for attempt, guidance in enumerate((4.0, 5.5), start=1):
                design_payload = {
                    "model_id": VOICE_DESIGN_MODEL_ID,
                    "voice_description": spec["voice_description"],
                    "text": spec["sample_text"],
                    "loudness": 0.45,
                    "guidance_scale": guidance,
                }
                design_raw = _api_post_json(
                    api_key,
                    "https://api.elevenlabs.io/v1/text-to-voice/design",
                    design_payload,
                    accept="application/json",
                    timeout=90,
                )
                design_resp = json.loads(design_raw.decode("utf-8"))
                batch_previews = [p for p in design_resp.get("previews", []) if p.get("generated_voice_id")]
                if not batch_previews:
                    raise RuntimeError(f"Voice design returned no previews for {role}:{lang} (attempt {attempt})")
                all_candidates.extend(batch_previews)

                _, best_f0 = _export_candidates_and_pick(ffmpeg_bin, role, lang, all_candidates, f0_band=f0_band)
                if f0_min <= best_f0 <= f0_max:
                    break
                print(f"[VOICE RETRY] {role}:{lang} batch {attempt} best F0={best_f0:.1f}Hz, retrying batch 2")

            gen_id, chosen_f0 = _export_candidates_and_pick(ffmpeg_bin, role, lang, all_candidates, f0_band=f0_band)
            print(f"[VOICE PICKED] {role}:{lang} ({vname}) gen={gen_id} F0={chosen_f0:.1f}Hz")

            create_payload = {
                "voice_name": vname,
                "voice_description": spec["voice_description"],
                "generated_voice_id": gen_id,
                "labels": {"project": "CP2077_CrimsonVeil", "role": role, "language": lang},
            }
            try:
                create_raw = _api_post_json(
                    api_key,
                    "https://api.elevenlabs.io/v1/text-to-voice",
                    create_payload,
                    accept="application/json",
                    timeout=60,
                )
            except RuntimeError as exc:
                if previous_vid and "limit" in str(exc).lower() and _delete_voice_by_id(api_key, previous_vid):
                    create_raw = _api_post_json(
                        api_key,
                        "https://api.elevenlabs.io/v1/text-to-voice",
                        create_payload,
                        accept="application/json",
                        timeout=60,
                    )
                else:
                    raise
            created = json.loads(create_raw.decode("utf-8"))
            vid = created.get("voice_id")
            if not vid:
                raise RuntimeError(f"Voice creation returned no voice_id for {role}:{lang}")

            role_map[lang] = str(vid)
            CUSTOM_VOICES_JSON.write_text(json.dumps(voices_map, indent=2, ensure_ascii=False), encoding="utf-8")
            print(f"[VOICE DESIGN] {role}:{lang} ({vname}) -> {vid}")

    CUSTOM_VOICES_JSON.write_text(json.dumps(voices_map, indent=2, ensure_ascii=False), encoding="utf-8")
    return voices_map


def _elevenlabs_tts(
    api_key: str,
    voice_id: str,
    lang: str,
    text: str,
    out_mp3: Path,
) -> None:
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}?output_format=mp3_44100_128"
    primary_payload = {
        "text": text,
        "model_id": DEFAULT_MODEL_ID,
        "language_code": lang,
        "voice_settings": {"stability": 0.45},
    }
    try:
        audio_bytes = _api_post_json(api_key, url, primary_payload, accept="audio/mpeg", timeout=60)
        out_mp3.write_bytes(audio_bytes)
        return
    except Exception as exc:
        print(f"[WARN] {DEFAULT_MODEL_ID} fallback -> {FALLBACK_MODEL_ID} ({exc})")

    fallback_payload = {
        "text": text,
        "model_id": FALLBACK_MODEL_ID,
        "voice_settings": {
            "stability": 0.45,
            "similarity_boost": 0.80,
            "style": 0.35,
            "use_speaker_boost": True,
        },
    }
    audio_bytes = _api_post_json(api_key, url, fallback_payload, accept="audio/mpeg", timeout=60)
    out_mp3.write_bytes(audio_bytes)


def _elevenlabs_sfx(api_key: str, prompt: str, duration: float, out_mp3: Path) -> None:
    url = "https://api.elevenlabs.io/v1/sound-generation"
    payload = {
        "text": prompt,
        "duration_seconds": duration,
        "prompt_influence": 0.45,
    }
    audio_bytes = _api_post_json(api_key, url, payload, accept="audio/mpeg", timeout=60)
    out_mp3.write_bytes(audio_bytes)


def _trim_pcm_bounds(samples: np.ndarray, sample_rate: int = 44100) -> tuple[int, int]:
    total = int(samples.shape[0])
    if total == 0:
        return 0, 0
    win = max(1, int(0.025 * sample_rate))
    active: list[int] = []
    for idx, start in enumerate(range(0, total, win)):
        chunk = samples[start : start + win]
        if chunk.size == 0:
            continue
        rms = float(np.sqrt(np.mean(chunk * chunk)))
        peak = float(np.max(np.abs(chunk)))
        if rms > 0.006 or peak > 0.020:
            active.append(idx)
    if not active:
        return 0, total
    first_active = active[0] * win
    last_active = min(total, (active[-1] + 1) * win)
    start_idx = max(0, first_active - int(0.030 * sample_rate))
    end_idx = min(total, last_active + int(0.220 * sample_rate))
    if end_idx <= start_idx:
        return 0, total
    return start_idx, end_idx


def _encode_trimmed_pcm_to_ogg(
    ffmpeg_bin: str,
    segment: np.ndarray,
    dst_ogg: Path,
    sample_rate: int = 44100,
) -> None:
    seg = np.array(segment, dtype=np.float32, copy=True)
    fade_in_n = min(int(0.012 * sample_rate), seg.shape[0] // 4)
    fade_out_n = min(int(0.030 * sample_rate), seg.shape[0] // 4)
    if fade_in_n > 1:
        seg[:fade_in_n] *= np.linspace(0.0, 1.0, fade_in_n, dtype=np.float32)
    if fade_out_n > 1:
        fade_out_curve = 0.5 * (1.0 + np.cos(np.linspace(0.0, np.pi, fade_out_n, dtype=np.float32)))
        seg[-fade_out_n:] *= fade_out_curve
    pad_zeros = np.zeros(int(0.120 * sample_rate), dtype=np.float32)
    seg = np.concatenate([seg, pad_zeros])

    pcm_s16 = np.clip(seg * 32768.0, -32768.0, 32767.0).astype(np.int16)
    dst_ogg.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="cv_trim_") as tmp:
        tmp_wav = Path(tmp) / "trimmed.wav"
        tmp_ogg = Path(tmp) / "out.ogg"
        with wave.open(str(tmp_wav), "wb") as wf:
            wf.setnchannels(1)
            wf.setsampwidth(2)
            wf.setframerate(sample_rate)
            wf.writeframes(pcm_s16.tobytes())
        subprocess.run(
            [
                ffmpeg_bin,
                "-y",
                "-loglevel",
                "error",
                "-i",
                str(tmp_wav),
                "-ar",
                str(sample_rate),
                "-ac",
                "1",
                "-c:a",
                "libvorbis",
                "-q:a",
                "6",
                str(tmp_ogg),
            ],
            check=True,
        )
        tmp_ogg.replace(dst_ogg)


def _convert_to_ogg(
    ffmpeg_bin: str,
    src_mp3: Path,
    dst_ogg: Path,
    trim_silence: bool = True,
) -> None:
    dst_ogg.parent.mkdir(parents=True, exist_ok=True)
    if not trim_silence:
        subprocess.run(
            [
                ffmpeg_bin,
                "-y",
                "-loglevel",
                "error",
                "-i",
                str(src_mp3),
                "-af",
                "volume=1.10",
                "-ar",
                "44100",
                "-ac",
                "1",
                "-c:a",
                "libvorbis",
                "-q:a",
                "6",
                str(dst_ogg),
            ],
            check=True,
        )
        return

    with tempfile.TemporaryDirectory(prefix="cv_flt_") as tmp:
        tmp_wav = Path(tmp) / "filtered.wav"
        subprocess.run(
            [
                ffmpeg_bin,
                "-y",
                "-loglevel",
                "error",
                "-i",
                str(src_mp3),
                "-af",
                CLEAN_VOCAL_FILTER,
                "-ar",
                "44100",
                "-ac",
                "1",
                str(tmp_wav),
            ],
            check=True,
        )
        with wave.open(str(tmp_wav), "rb") as wf:
            pcm = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16).astype(np.float32) / 32768.0
    start_idx, end_idx = _trim_pcm_bounds(pcm, 44100)
    _encode_trimmed_pcm_to_ogg(ffmpeg_bin, pcm[start_idx:end_idx], dst_ogg, 44100)


def _measure_ogg_duration(ffmpeg_bin: str, ogg_path: Path) -> float:
    with tempfile.TemporaryDirectory(prefix="cv_dur_") as tmp:
        wav_path = Path(tmp) / "probe.wav"
        subprocess.run(
            [ffmpeg_bin, "-y", "-loglevel", "error", "-i", str(ogg_path), "-ar", "44100", "-ac", "1", str(wav_path)],
            check=True,
        )
        with wave.open(str(wav_path), "rb") as wf:
            frames = wf.getnframes()
            rate = wf.getframerate()
            return round(frames / float(rate), 2)


def _generate_one_tts(
    api_key: str,
    ffmpeg_bin: str,
    voice_id: str,
    lang: str,
    text: str,
    dst_ogg: Path,
    force: bool,
) -> tuple[str, float]:
    if not force and dst_ogg.is_file() and dst_ogg.stat().st_size > 1024:
        return dst_ogg.name, _measure_ogg_duration(ffmpeg_bin, dst_ogg)

    with tempfile.TemporaryDirectory(prefix="cv_tts_") as tmp:
        tmp_mp3 = Path(tmp) / "raw.mp3"
        _elevenlabs_tts(api_key, voice_id, lang, text, tmp_mp3)
        _convert_to_ogg(ffmpeg_bin, tmp_mp3, dst_ogg, trim_silence=True)
    return dst_ogg.name, _measure_ogg_duration(ffmpeg_bin, dst_ogg)


def _generate_one_sfx(
    api_key: str,
    ffmpeg_bin: str,
    spec: dict[str, Any],
    force: bool,
) -> tuple[str, float]:
    dst_ogg = AUDIO_SFX_DIR / f"{spec['id']}.ogg"
    if not force and dst_ogg.is_file() and dst_ogg.stat().st_size > 1024:
        return spec["id"], _measure_ogg_duration(ffmpeg_bin, dst_ogg)

    with tempfile.TemporaryDirectory(prefix="cv_sfx_") as tmp:
        tmp_mp3 = Path(tmp) / "raw_sfx.mp3"
        _elevenlabs_sfx(api_key, spec["prompt"], float(spec["duration"]), tmp_mp3)
        _convert_to_ogg(ffmpeg_bin, tmp_mp3, dst_ogg, trim_silence=False)
    return spec["id"], _measure_ogg_duration(ffmpeg_bin, dst_ogg)


def write_audioware_yaml(all_locales_mode: bool = False) -> None:
    sfx_section = {
        spec["id"]: {"file": f"./audio/sfx/{spec['id']}.ogg"}
        for spec in SFX_SPECS
    }

    voices_section: dict[str, Any] = {}
    full_locales = (
        "en-us", "es-es", "es-mx", "de-de", "fr-fr", "pl-pl", "pt-br",
        "it-it", "ru-ru", "jp-jp", "kr-kr", "zh-cn", "zh-tw", "cz-cz",
        "hu-hu", "tr-tr", "ar-ar", "th-th", "ua-ua",
    )
    active_locales = ("es-es", "es-mx", "en-us")
    target_locales = full_locales if all_locales_mode else active_locales
    for line in DIALOGUE_LINES:
        lid = line["id"]
        entry: dict[str, Any] = {}
        if line["speaker"] == "v":
            en_fem = f"./audio/en/{lid}_fem.ogg" if (AUDIO_EN_DIR / f"{lid}_fem.ogg").is_file() else f"./audio/es/{lid}_fem.ogg"
            en_male = f"./audio/en/{lid}_male.ogg" if (AUDIO_EN_DIR / f"{lid}_male.ogg").is_file() else f"./audio/es/{lid}_male.ogg"
            for loc in target_locales:
                if loc in ("es-es", "es-mx"):
                    entry[loc] = {
                        "fem": {"file": f"./audio/es/{lid}_fem.ogg", "subtitle": line["es_sub"]},
                        "male": {"file": f"./audio/es/{lid}_male.ogg", "subtitle": line["es_sub"]},
                    }
                else:
                    entry[loc] = {
                        "fem": {"file": en_fem, "subtitle": line["en_sub"]},
                        "male": {"file": en_male, "subtitle": line["en_sub"]},
                    }
        else:
            en_file = f"./audio/en/{lid}.ogg" if (AUDIO_EN_DIR / f"{lid}.ogg").is_file() else f"./audio/es/{lid}.ogg"
            for loc in target_locales:
                if loc in ("es-es", "es-mx"):
                    entry[loc] = {"file": f"./audio/es/{lid}.ogg", "subtitle": line["es_sub"]}
                else:
                    entry[loc] = {"file": en_file, "subtitle": line["en_sub"]}
        voices_section[lid] = entry

    manifest = {
        "version": "1.0.0",
        "sfx": sfx_section,
        "voices": voices_section,
    }
    MANIFEST_YAML.parent.mkdir(parents=True, exist_ok=True)
    header = "# Velo Carmesí / Crimson Veil — Audioware Voice & SFX Manifest (Bilingual EN/ES + 19 Locales)\n"
    MANIFEST_YAML.write_text(
        header + yaml.safe_dump(manifest, allow_unicode=True, sort_keys=False, width=1000),
        encoding="utf-8",
    )


def _audit_tts_phonetics() -> None:
    for line in DIALOGUE_LINES:
        for key in ("es_tts", "en_tts"):
            if re.search(r"\d", line[key]):
                raise ValueError(f"Raw digit found in {line['id']} ({key}): {line[key]}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate Crimson Veil Phase 0 voices & SFX via ElevenLabs")
    parser.add_argument("--force", action="store_true", help="Regenerate all .ogg files (voices + SFX)")
    parser.add_argument("--force-voices", action="store_true", help="Regenerate voice .ogg files while keeping SFX")
    parser.add_argument("--redesign", action="store_true", help="Redesign Misty/Vampyre custom voices")
    parser.add_argument("--lang", choices=["es", "en", "all"], default="es", help="Language scope (default es)")
    parser.add_argument("--workers", type=int, default=4, help="Parallel ElevenLabs requests")
    parser.add_argument("--manifest-only", action="store_true", help="Rebuild CrimsonVeil.yaml from existing audio without calling ElevenLabs")
    parser.add_argument("--all-locales", action="store_true", help="Include all 19 Cyberpunk locales in CrimsonVeil.yaml instead of active es-es/es-mx/en-us")
    args = parser.parse_args()

    _audit_tts_phonetics()
    if args.manifest_only:
        write_audioware_yaml(all_locales_mode=args.all_locales)
        print(f"[DONE] Audioware YAML  -> {MANIFEST_YAML} ({MANIFEST_YAML.stat().st_size} B)")
        return
    ffmpeg_bin = _find_ffmpeg()

    AUDIO_ES_DIR.mkdir(parents=True, exist_ok=True)
    AUDIO_EN_DIR.mkdir(parents=True, exist_ok=True)
    AUDIO_SFX_DIR.mkdir(parents=True, exist_ok=True)

    api_key = cfg.load_env_var("ELEVENLABS_API_KEY", required=True)
    target_langs: tuple[str, ...] = ("en", "es") if args.lang == "all" else (args.lang,)
    active_voices = ensure_custom_voices(api_key, ffmpeg_bin, redesign=args.redesign, langs=target_langs)
    force_voices = bool(args.force or args.force_voices or args.redesign)

    tasks: list[tuple[str, Any]] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
        for spec in SFX_SPECS:
            fut = pool.submit(_generate_one_sfx, api_key, ffmpeg_bin, spec, bool(args.force))
            tasks.append((f"sfx:{spec['id']}", fut))

        for line in DIALOGUE_LINES:
            lid = line["id"]
            spk = line["speaker"]
            if spk == "v":
                for gender in ("fem", "male"):
                    v_key = f"v_{gender}"
                    for lang, out_dir in (("en", AUDIO_EN_DIR), ("es", AUDIO_ES_DIR)):
                        if lang not in target_langs:
                            continue
                        dst = out_dir / f"{lid}_{gender}.ogg"
                        fut = pool.submit(
                            _generate_one_tts,
                            api_key,
                            ffmpeg_bin,
                            active_voices[v_key][lang],
                            lang,
                            line[f"{lang}_tts"],
                            dst,
                            force_voices,
                        )
                        tasks.append((f"voice:{lid}:{lang}:{gender}", fut))
            else:
                for lang, out_dir in (("en", AUDIO_EN_DIR), ("es", AUDIO_ES_DIR)):
                    if lang not in target_langs:
                        continue
                    dst = out_dir / f"{lid}.ogg"
                    fut = pool.submit(
                        _generate_one_tts,
                        api_key,
                        ffmpeg_bin,
                        active_voices[spk][lang],
                        lang,
                        line[f"{lang}_tts"],
                        dst,
                        force_voices,
                    )
                    tasks.append((f"voice:{lid}:{lang}", fut))

        durations: dict[str, Any] = {"sfx": {}, "voices": {}}
        for tag, fut in tasks:
            _, sec = fut.result()
            parts = tag.split(":")
            if parts[0] == "sfx":
                durations["sfx"][parts[1]] = sec
            else:
                lid = parts[1]
                lang = parts[2]
                entry = durations["voices"].setdefault(lid, {})
                if len(parts) == 4:
                    entry[f"{lang}_{parts[3]}"] = sec
                else:
                    entry[lang] = sec
            print(f"[OK] {tag} -> {sec:.2f}s")

    for lid, d in durations["voices"].items():
        vals = [float(v) for k, v in d.items() if k != "max"]
        if vals:
            d["max"] = max(vals)

    DURATIONS_JSON.write_text(json.dumps(durations, indent=2, ensure_ascii=False), encoding="utf-8")
    write_audioware_yaml(all_locales_mode=args.all_locales)
    print(f"[DONE] Custom voices   -> {CUSTOM_VOICES_JSON}")
    print(f"[DONE] Audio durations -> {DURATIONS_JSON}")
    print(f"[DONE] Audioware YAML  -> {MANIFEST_YAML}")
    print(f"[DONE] Audition WAVs   -> {AUDITION_DIR}")


if __name__ == "__main__":
    main()
