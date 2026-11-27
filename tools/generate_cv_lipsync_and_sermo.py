"""
Generates Crimson Veil (Phase 0 + Act I) JALI lip-sync animation banks, CSV lookup tables, and
cloned female/male Sermo AnimGraphs:

  wolvenkit_src/archive/crimson_veil/
    animgraphs/cv_woman_sermo.animgraph.json
    animations/cv_misty_lipsync.anims.json
    animations/cv_lipsync_db.csv.json
    animgraphs/cv_man_sermo.animgraph.json
    animations/cv_valdes_lipsync.anims.json
    animations/cv_valdes_lipsync_db.csv.json

Uses the workspace reusable engine `scripts/cp2077_jali_lipsync.py` (100% Base Game 2.x, 0 ep1).
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

MOD_ROOT = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = MOD_ROOT.parent.parent
sys.path.insert(0, str(WORKSPACE_ROOT / "scripts"))
sys.path.insert(0, str(MOD_ROOT / "tools"))

import cp2077_jali_lipsync as jali  # noqa: E402
import generate_cv_audio as cv_audio  # noqa: E402

WOLVENKIT_CLI = WORKSPACE_ROOT / "tools" / "sdk" / "wolvenkit_cli" / "WolvenKit.CLI.exe"
AUDIO_ES_DIR = MOD_ROOT / "files" / "r6" / "audioware" / "CrimsonVeil" / "audio" / "es"
AUDIO_EN_DIR = MOD_ROOT / "files" / "r6" / "audioware" / "CrimsonVeil" / "audio" / "en"
ARCH_ROOT = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil"

MISTY_ANIMGRAPH_DEPOT = "crimson_veil\\animgraphs\\cv_woman_sermo.animgraph"
MISTY_ANIMS_DEPOT = "crimson_veil\\animations\\cv_misty_lipsync.anims"
MISTY_CSV_DEPOT = "crimson_veil\\animations\\cv_lipsync_db.csv"
MISTY_RIG_DEPOT = "base\\characters\\main_npc\\misty\\h0_001_wa_c__misty\\h0_001_wa_c__misty_skeleton.rig"

VALDES_ANIMGRAPH_DEPOT = "crimson_veil\\animgraphs\\cv_man_sermo.animgraph"
VALDES_ANIMS_DEPOT = "crimson_veil\\animations\\cv_valdes_lipsync.anims"
VALDES_CSV_DEPOT = "crimson_veil\\animations\\cv_valdes_lipsync_db.csv"
VALDES_RIG_DEPOT = "base\\characters\\head\\ma\\h0_013_ma_c__older\\h0_013_ma_c__older_skeleton.rig"

LUCIA_ANIMGRAPH_DEPOT = "crimson_veil\\animgraphs\\cv_lucia_sermo.animgraph"
LUCIA_ANIMS_DEPOT = "crimson_veil\\animations\\cv_lucia_lipsync.anims"
LUCIA_CSV_DEPOT = "crimson_veil\\animations\\cv_lucia_lipsync_db.csv"
LUCIA_RIG_DEPOT = "base\\characters\\head\\wa\\h0_096_wa_a__young\\h0_096_wa_a__young_skeleton.rig"

SOLIS_ANIMGRAPH_DEPOT = "crimson_veil\\animgraphs\\cv_solis_sermo.animgraph"
SOLIS_ANIMS_DEPOT = "crimson_veil\\animations\\cv_solis_lipsync.anims"
SOLIS_CSV_DEPOT = "crimson_veil\\animations\\cv_solis_lipsync_db.csv"
SOLIS_RIG_DEPOT = "base\\characters\\head\\wa\\h0_023_wa_a__middle\\h0_023_wa_a__middle_skeleton.rig"

# Fixed Clip IDs matching CrimsonVeilSystem.ResolveNpcLipSyncClipId() (Bank 1 = ES)
MISTY_SPECS: list[tuple[int, str, str]] = [
    (1, "cv_p0_misty_esoterica_01", "concerned"),
    (2, "cv_p0_misty_rooftop_01", "warm_mystic"),
    (3, "cv_p0_misty_rooftop_02", "ominous"),
    (4, "cv_p0_misty_ans_chorus", "ominous"),
    (5, "cv_p0_misty_ans_uv", "analytical"),
    (6, "cv_p0_misty_tarot_forensic", "analytical"),
    (7, "cv_p0_misty_tarot_symbolic", "concerned"),
    (8, "cv_p0_misty_debrief_01", "warm_mystic"),
    (9, "cv_p0_misty_debrief_02", "concerned"),
    (10, "cv_a1_misty_debrief_stealth", "warm_mystic"),
    (11, "cv_a1_misty_debrief_combat", "concerned"),
    (12, "cv_a1_misty_debrief_badlands", "ominous"),
    (13, "cv_a1_misty_cliffhanger", "ominous"),
    # v0.5.0 Reboot Prologue: La Luna Manchada (IDs 14..27)
    (14, "cv_r2_call_misty_01", "concerned"),
    (15, "cv_r2_call_misty_02", "concerned"),
    (16, "cv_r2_alley_misty_warn", "concerned"),
    (17, "cv_r2_alley_misty_lucia_01", "ominous"),
    (18, "cv_r2_alley_misty_lucia_02", "concerned"),
    (19, "cv_r2_alley_qa_missing_m", "concerned"),
    (20, "cv_r2_alley_qa_watched_m", "ominous"),
    (21, "cv_r2_alley_qa_chorus_m", "ominous"),
    (22, "cv_r2_alley_misty_rooftop", "warm_mystic"),
    (23, "cv_r2_roof_misty_intro", "warm_mystic"),
    (24, "cv_r2_roof_misty_uv", "analytical"),
    (25, "cv_r2_oil_misty_radio", "concerned"),
    (26, "cv_r2_debrief_m1", "warm_mystic"),
    (27, "cv_r2_debrief_m2", "warm_mystic"),
    # v0.6.0 Faithful Literary Rooftop Scene (IDs 28..33)
    (28, "cv_r2_roof_open_m1", "warm_mystic"),
    (29, "cv_r2_roof_open_m2", "ominous"),
    (30, "cv_r2_roof_open_m3", "concerned"),
    (31, "cv_r2_roof_chem_m", "concerned"),
    (32, "cv_r2_roof_cards_m", "ominous"),
    (33, "cv_r2_roof_promise_m", "warm_mystic"),
    # v0.8.0 Act I Bridge Holocall (IDs 34..35)
    (34, "cv_a1_r2_call_m1", "concerned"),
    (35, "cv_a1_r2_call_m2", "analytical"),
    # v0.8.2 Act I Rooftop Finale Debrief (IDs 36..39)
    (36, "cv_a1_r2_debrief_m1_stealth", "warm_mystic"),
    (37, "cv_a1_r2_debrief_m1_combat", "concerned"),
    (38, "cv_a1_r2_debrief_m2", "ominous"),
    (39, "cv_a1_r2_debrief_m3", "analytical"),
    # v0.9.0 Act II Badlands Bridge & Finale (IDs 40..45)
    (40, "cv_a2_call_m1", "concerned"),
    (41, "cv_a2_call_m2", "analytical"),
    (42, "cv_a2_roof_misty_cure", "warm_mystic"),
    (43, "cv_a2_roof_misty_pact", "concerned"),
    (44, "cv_a2_roof_misty_burn", "ominous"),
    (45, "cv_a2_roof_misty_epilogue", "warm_mystic"),
]

LUCIA_SPECS: list[tuple[int, str, str]] = [
    (1, "cv_a2_lucia_intro", "warm_mystic"),
    (2, "cv_a2_lucia_a1", "concerned"),
    (3, "cv_a2_lucia_a2", "analytical"),
    (4, "cv_a2_lucia_adv", "concerned"),
    (5, "cv_a2_roof_lucia_greet", "warm_mystic"),
]

SOLIS_SPECS: list[tuple[int, str, str]] = [
    (1, "cv_a2_solis_intro", "analytical"),
    (2, "cv_a2_solis_a1", "ominous"),
    (3, "cv_a2_solis_a2", "analytical"),
    (4, "cv_a2_solis_a3", "ominous"),
    (5, "cv_a2_solis_combat", "ominous"),
    (6, "cv_a2_solis_pact", "analytical"),
]

VALDES_SPECS: list[tuple[int, str, str]] = [
    (1, "cv_a1_valdes_intro_01", "concerned"),
    (2, "cv_a1_valdes_ans_nox9", "analytical"),
    (3, "cv_a1_valdes_ans_misty", "ominous"),
    (4, "cv_a1_valdes_give_trust", "concerned"),
    (5, "cv_a1_valdes_give_pressure", "ominous"),
    # v0.8.0 Act I Full Testimony & Leads (IDs 6..11)
    (6, "cv_a1_r2_valdes_intro", "ominous"),
    (7, "cv_a1_r2_valdes_ans_role", "analytical"),
    (8, "cv_a1_r2_valdes_ans_sect", "concerned"),
    (9, "cv_a1_r2_valdes_ans_leads", "analytical"),
    (10, "cv_a1_r2_valdes_give_trust", "concerned"),
    (11, "cv_a1_r2_valdes_give_pressure", "ominous"),
]


def _run_wkit(args: list[str]) -> str:
    res = subprocess.run(
        [str(WOLVENKIT_CLI), *args],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )
    out = f"{res.stdout}\n{res.stderr}"
    if res.returncode != 0 or "[ 0: Error" in out or "Exception:" in out:
        raise RuntimeError(f"WolvenKit failed: {' '.join(args)}\n{out}")
    return out


def _build_speaker_outputs(
    *,
    label: str,
    specs: list[tuple[int, str, str]],
    es_text_map: dict[str, str],
    en_text_map: dict[str, str],
    rig_doc: dict[str, Any],
    sermo_doc: dict[str, Any],
    gfa_doc: dict[str, Any],
    csv_doc: dict[str, Any],
    rig_depot: str,
    animgraph_depot: str,
    anims_depot: str,
    csv_depot: str,
    out_ag: Path,
    out_anims: Path,
    out_csv: Path,
) -> list[tuple[Path, dict[str, Any]]]:
    track_names = [t["$value"] for t in rig_doc["Data"]["RootChunk"]["trackNames"]]
    num_joints = len(rig_doc["Data"]["RootChunk"]["boneNames"])

    clip_specs: list[dict[str, Any]] = []
    csv_rows: list[tuple[int, int, str]] = []
    for clip_id, line_id, emotion in specs:
        ogg_es = AUDIO_ES_DIR / f"{line_id}.ogg"
        if not ogg_es.is_file():
            raise FileNotFoundError(f"Missing {label} ES voice line audio: {ogg_es}")
        text_es = es_text_map.get(line_id)
        if not text_es:
            raise KeyError(f"Missing ES transcript for {line_id} in generate_cv_audio.DIALOGUE_LINES")
        clip_specs.append(
            {
                "name": line_id,
                "audio_path": ogg_es,
                "text": text_es,
                "lang": "es",
                "emotion": emotion,
            }
        )
        csv_rows.append((1, clip_id, line_id))

        ogg_en = AUDIO_EN_DIR / f"{line_id}.ogg"
        if not ogg_en.is_file():
            raise FileNotFoundError(f"Missing {label} EN voice line audio: {ogg_en}")
        text_en = en_text_map.get(line_id)
        if not text_en:
            raise KeyError(f"Missing EN transcript for {line_id} in generate_cv_audio.DIALOGUE_LINES")
        en_clip_name = f"{line_id}_en"
        clip_specs.append(
            {
                "name": en_clip_name,
                "audio_path": ogg_en,
                "text": text_en,
                "lang": "en",
                "emotion": emotion,
            }
        )
        csv_rows.append((2, clip_id, en_clip_name))

    print(f"  Synthesizing 30 FPS JALI phoneme-aligned curves for {len(clip_specs)} {label} lines...")
    anims_json, stats = jali.build_lipsync_anims_json(
        template_anims_json=gfa_doc,
        rig_depot_path=rig_depot,
        rig_track_names=track_names,
        num_joints=num_joints,
        archive_depot_path=anims_depot,
        clips=clip_specs,
    )
    for st in stats:
        print(
            f"    {st['name']:30s} dur={st['duration']:5.2f}s "
            f"frames={st['frames']:3d} phonemes={st['phonemes']:3d} "
            f"blinks={st['blinks']} tracks={st['animated_tracks']} keys={st['track_keys']}"
        )

    csv_json = jali.build_lipsync_csv_json(csv_doc, csv_depot, csv_rows)
    ag_json = jali.build_live_sermo_animgraph_json(sermo_doc, animgraph_depot, csv_depot)

    for out_p in (out_ag, out_anims, out_csv):
        out_p.parent.mkdir(parents=True, exist_ok=True)

    outputs = [
        (out_ag, ag_json),
        (out_anims, anims_json),
        (out_csv, csv_json),
    ]
    for out_p, data in outputs:
        txt = json.dumps(data, ensure_ascii=False) if out_p == out_anims else json.dumps(data, indent=2, ensure_ascii=False)
        if re.search(r'(?:^|["\\/])ep1[\\/]', txt, re.I):
            raise RuntimeError(f"Forbidden ep1 reference detected in {out_p.name}")
        out_p.write_text(txt, encoding="utf-8")
    return outputs


def generate_all() -> None:
    if not WOLVENKIT_CLI.is_file():
        raise FileNotFoundError(f"WolvenKit.CLI.exe not found at {WOLVENKIT_CLI}")

    es_text_map = {item["id"]: item["es_tts"] for item in cv_audio.DIALOGUE_LINES}
    en_text_map = {item["id"]: item["en_tts"] for item in cv_audio.DIALOGUE_LINES}
    all_outputs: list[tuple[Path, dict[str, Any]]] = []

    print("[1/4] Extracting base-game woman_average_sermo donors (0 ep1)...")
    woman_donors = jali.unbundle_and_serialize_donors(wk_cli=WOLVENKIT_CLI, gender="woman")
    all_outputs.extend(
        _build_speaker_outputs(
            label="Misty",
            specs=MISTY_SPECS,
            es_text_map=es_text_map,
            en_text_map=en_text_map,
            rig_doc=woman_donors["h0_001_wa_c__misty_skeleton.rig"],
            sermo_doc=woman_donors["woman_average_sermo.animgraph"],
            gfa_doc=woman_donors["generic_facial_additives.anims"],
            csv_doc=woman_donors["facial_reactions_male.csv"],
            rig_depot=MISTY_RIG_DEPOT,
            animgraph_depot=MISTY_ANIMGRAPH_DEPOT,
            anims_depot=MISTY_ANIMS_DEPOT,
            csv_depot=MISTY_CSV_DEPOT,
            out_ag=ARCH_ROOT / "animgraphs" / "cv_woman_sermo.animgraph.json",
            out_anims=ARCH_ROOT / "animations" / "cv_misty_lipsync.anims.json",
            out_csv=ARCH_ROOT / "animations" / "cv_lipsync_db.csv.json",
        )
    )

    print("[2/4] Extracting base-game man_average_sermo + older male head rig donors (0 ep1)...")
    man_donors = jali.unbundle_and_serialize_donors(
        wk_cli=WOLVENKIT_CLI,
        gender="man",
        rig_regex=r"h0_013_ma_c__older_skeleton\.rig",
    )
    all_outputs.extend(
        _build_speaker_outputs(
            label="Dr. Valdes",
            specs=VALDES_SPECS,
            es_text_map=es_text_map,
            en_text_map=en_text_map,
            rig_doc=man_donors["h0_013_ma_c__older_skeleton.rig"],
            sermo_doc=man_donors["man_average_sermo.animgraph"],
            gfa_doc=man_donors["generic_facial_additives.anims"],
            csv_doc=man_donors["facial_reactions_male.csv"],
            rig_depot=VALDES_RIG_DEPOT,
            animgraph_depot=VALDES_ANIMGRAPH_DEPOT,
            anims_depot=VALDES_ANIMS_DEPOT,
            csv_depot=VALDES_CSV_DEPOT,
            out_ag=ARCH_ROOT / "animgraphs" / "cv_man_sermo.animgraph.json",
            out_anims=ARCH_ROOT / "animations" / "cv_valdes_lipsync.anims.json",
            out_csv=ARCH_ROOT / "animations" / "cv_valdes_lipsync_db.csv.json",
        )
    )

    print("[2b/4] Extracting base-game young female rig donors for Lucia Reyes (0 ep1)...")
    lucia_donors = jali.unbundle_and_serialize_donors(
        wk_cli=WOLVENKIT_CLI,
        gender="woman",
        rig_regex=r"h0_096_wa_a__young_skeleton\.rig",
    )
    all_outputs.extend(
        _build_speaker_outputs(
            label="Lucia Reyes",
            specs=LUCIA_SPECS,
            es_text_map=es_text_map,
            en_text_map=en_text_map,
            rig_doc=lucia_donors["h0_096_wa_a__young_skeleton.rig"],
            sermo_doc=lucia_donors["woman_average_sermo.animgraph"],
            gfa_doc=lucia_donors["generic_facial_additives.anims"],
            csv_doc=lucia_donors["facial_reactions_male.csv"],
            rig_depot=LUCIA_RIG_DEPOT,
            animgraph_depot=LUCIA_ANIMGRAPH_DEPOT,
            anims_depot=LUCIA_ANIMS_DEPOT,
            csv_depot=LUCIA_CSV_DEPOT,
            out_ag=ARCH_ROOT / "animgraphs" / "cv_lucia_sermo.animgraph.json",
            out_anims=ARCH_ROOT / "animations" / "cv_lucia_lipsync.anims.json",
            out_csv=ARCH_ROOT / "animations" / "cv_lucia_lipsync_db.csv.json",
        )
    )

    print("[2c/4] Extracting base-game middle female rig donors for Dra. Helena Solis (0 ep1)...")
    solis_donors = jali.unbundle_and_serialize_donors(
        wk_cli=WOLVENKIT_CLI,
        gender="woman",
        rig_regex=r"h0_023_wa_a__middle_skeleton\.rig",
    )
    all_outputs.extend(
        _build_speaker_outputs(
            label="Dra. Helena Solis",
            specs=SOLIS_SPECS,
            es_text_map=es_text_map,
            en_text_map=en_text_map,
            rig_doc=solis_donors["h0_023_wa_a__middle_skeleton.rig"],
            sermo_doc=solis_donors["woman_average_sermo.animgraph"],
            gfa_doc=solis_donors["generic_facial_additives.anims"],
            csv_doc=solis_donors["facial_reactions_male.csv"],
            rig_depot=SOLIS_RIG_DEPOT,
            animgraph_depot=SOLIS_ANIMGRAPH_DEPOT,
            anims_depot=SOLIS_ANIMS_DEPOT,
            csv_depot=SOLIS_CSV_DEPOT,
            out_ag=ARCH_ROOT / "animgraphs" / "cv_solis_sermo.animgraph.json",
            out_anims=ARCH_ROOT / "animations" / "cv_solis_lipsync.anims.json",
            out_csv=ARCH_ROOT / "animations" / "cv_solis_lipsync_db.csv.json",
        )
    )

    print(f"[3/4] Generated {len(all_outputs)} JALI CR2W JSON artifacts.")
    print("[4/4] Verifying WolvenKit CR2W roundtrip deserialize+serialize...")
    with tempfile.TemporaryDirectory(prefix="cv_jali_rt_") as tmp:
        rt_dir = Path(tmp)
        rt_re = rt_dir / "re"
        rt_re.mkdir(parents=True, exist_ok=True)
        for src_p, _ in all_outputs:
            _run_wkit(["convert", "deserialize", str(src_p), "-o", str(rt_dir)])
            bin_p = rt_dir / src_p.name[:-5]
            if not bin_p.is_file() or bin_p.stat().st_size < 32:
                raise RuntimeError(f"Deserialized binary empty/missing for {src_p.name}")
            _run_wkit(["convert", "serialize", str(bin_p), "-o", str(rt_re)])
            rt_json = rt_re / src_p.name
            if not rt_json.is_file():
                raise RuntimeError(f"Roundtrip serialize failed for {src_p.name}")
            print(f"  [OK] {src_p.name} -> {bin_p.name} ({bin_p.stat().st_size} B)")


if __name__ == "__main__":
    try:
        generate_all()
        print("[DONE] JALI woman+man animgraphs, .anims, and CSVs generated & CR2W-verified.")
    except Exception as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
