"""
Generates CR2W NPC templates, cloned Misty & Dr. Adrian Valdes appearances with live 30 FPS
JALI Sermo AnimGraphs, choreographed multi-animation conversational workspots, and invisible
workspot anchors for Velo Carmesi / Crimson Veil (100% Base Game 2.x, 0 ep1):

  wolvenkit_src/archive/crimson_veil/characters/
    - cv_misty.app.json + cv_misty.ent.json   (cv_woman_sermo.animgraph + cv_misty_lipsync.anims)
    - cv_valdes.app.json + cv_valdes.ent.json (cv_man_sermo.animgraph + cv_valdes_lipsync.anims)

  wolvenkit_src/archive/crimson_veil/workspots/
    - cv_misty_rooftop_loop.workspot.json     (8 stand__2h_on_sides idles + 18 calm female gestures)
    - cv_valdes_loop.workspot.json            (8 stand__2h_front idles + 14 calm male gestures)

  wolvenkit_src/archive/crimson_veil/entities/
    - cv_ws_misty_rooftop.ent.json
    - cv_ws_valdes.ent.json

Every output file is verified against real base-game clip lists and roundtrip-validated via WolvenKit.CLI.
"""

from __future__ import annotations

import copy
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

MOD_ROOT = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = MOD_ROOT.parent.parent
sys.path.insert(0, str(WORKSPACE_ROOT / "scripts"))
import cp2077_jali_lipsync as jali  # noqa: E402

WOLVENKIT_CLI = WORKSPACE_ROOT / "tools" / "sdk" / "wolvenkit_cli" / "WolvenKit.CLI.exe"
CP77_CONTENT_DIR = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\archive\pc\content")
GAMEDATA_ARC = CP77_CONTENT_DIR / "basegame_4_gamedata.archive"
APP_ARC = CP77_CONTENT_DIR / "basegame_4_appearance.archive"
ANIM_ARC = CP77_CONTENT_DIR / "basegame_4_animation.archive"
MEM_RES_ARC = CP77_CONTENT_DIR / "memoryresident_1_general.archive"

OUT_CHAR_DIR = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil" / "characters"
OUT_ENT_DIR = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil" / "entities"
OUT_WS_DIR = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil" / "workspots"

CV_MISTY_APP_DEPOT = "crimson_veil\\characters\\cv_misty.app"
CV_MISTY_ENT_DEPOT = "crimson_veil\\characters\\cv_misty.ent"
CV_WOMAN_SERMO_DEPOT = "crimson_veil\\animgraphs\\cv_woman_sermo.animgraph"
CV_MISTY_LIP_DEPOT = "crimson_veil\\animations\\cv_misty_lipsync.anims"

CV_VALDES_APP_DEPOT = "crimson_veil\\characters\\cv_valdes.app"
CV_VALDES_ENT_DEPOT = "crimson_veil\\characters\\cv_valdes.ent"
CV_MAN_SERMO_DEPOT = "crimson_veil\\animgraphs\\cv_man_sermo.animgraph"
CV_VALDES_LIP_DEPOT = "crimson_veil\\animations\\cv_valdes_lipsync.anims"

CV_LUCIA_APP_DEPOT = "crimson_veil\\characters\\cv_lucia.app"
CV_LUCIA_ENT_DEPOT = "crimson_veil\\characters\\cv_lucia.ent"
CV_LUCIA_SERMO_DEPOT = "crimson_veil\\animgraphs\\cv_lucia_sermo.animgraph"
CV_LUCIA_LIP_DEPOT = "crimson_veil\\animations\\cv_lucia_lipsync.anims"

CV_SOLIS_APP_DEPOT = "crimson_veil\\characters\\cv_solis.app"
CV_SOLIS_ENT_DEPOT = "crimson_veil\\characters\\cv_solis.ent"
CV_SOLIS_SERMO_DEPOT = "crimson_veil\\animgraphs\\cv_solis_sermo.animgraph"
CV_SOLIS_LIP_DEPOT = "crimson_veil\\animations\\cv_solis_lipsync.anims"

WOMAN_BASE_RIG = "base\\characters\\base_entities\\woman_base\\woman_base.rig"
FEMALE_2H_ON_SIDES_A = "base\\animations\\npc\\generic_characters\\female_average\\interactive_scene\\generic_average_female_stand__2h_on_sides.anims"
FEMALE_2H_ON_SIDES_B = "base\\animations\\npc\\generic_characters\\female_average\\interactive_scene\\generic_average_female_stand_2h_on_sides.anims"
Q001_MISTY_DECK_ANIMS = "base\\animations\\quest\\main_quests\\prologue\\q001\\q001_04a_rd_assistant\\anim\\body\\q001_04a_rd_assistant__female_average.anims"

MAN_BASE_RIG = "base\\characters\\base_entities\\man_base\\man_base.rig"
MALE_2H_FRONT_ANIMS = "base\\animations\\npc\\generic_characters\\male_average\\interactive_scene\\generic_male_average__stand__2h_front__01.anims"

# Misty Entry IDs 4..11: Natural relaxed idle poses & subtle weight-shifts
MISTY_IDLE_CLIPS: list[tuple[int, str, float]] = [
    (4, "stand__2h_on_sides__01", 0.24),
    (5, "stand__2h_on_sides__01__shuffle__01", 0.14),
    (6, "stand__2h_on_sides__01__shuffle__02", 0.14),
    (7, "stand__2h_on_sides__01__shuffle__03", 0.12),
    (8, "stand__2h_on_sides__01__shuffle__04", 0.12),
    (9, "stand__2h_on_sides__01__rub_hands__01", 0.09),
    (10, "stand__2h_on_sides__01__deep_breath__01", 0.08),
    (11, "stand__2h_on_sides__01__scratch_neck__03", 0.07),
]

# Misty Entry IDs 21..38: Serene conversational gestures (dZ <= 0.011 m, zero jumps or theatrical __broad__ arms)
MISTY_GESTURE_CLIPS: list[tuple[int, str]] = [
    (21, "stand__2h_on_sides__01__talk__neutral__07"),
    (22, "stand__2h_on_sides__01__talk__neutral__08"),
    (23, "stand__2h_on_sides__01__2h_flick__03"),
    (24, "stand__2h_on_sides__01__2h_flick__01"),
    (25, "stand__2h_on_sides__01__rh_flick__01"),
    (26, "stand__2h_on_sides__01__rh_flick__02"),
    (27, "stand__2h_on_sides__01__rh_flick__03"),
    (28, "stand__2h_on_sides__01__describe_down__01"),
    (29, "stand__2h_on_sides__01__describe_right__01"),
    (30, "stand__2h_on_sides__01__this_or_that__01"),
    (31, "stand__2h_on_sides__01__yes__head__01"),
    (32, "stand__2h_on_sides__01__yes__sad__01"),
    (33, "stand__2h_on_sides__01__yes__sad__02"),
    (34, "stand__2h_on_sides__01__no__head__01"),
    (35, "stand__2h_on_sides__01__no__02"),
    (36, "stand__2h_on_sides__01__shrug__narrow__02"),
    (37, "stand__2h_on_sides__01__what__sad__02"),
    (38, "stand__2h_on_sides__01__me__01"),
]

# Misty Entry IDs 40..50: Base-game q001_04a Tarot deck shuffling, dealing, holding-deck idle, flick & describing clips (motionExtraction=None)
MISTY_TAROT_DECK_CLIPS: list[tuple[int, str]] = [
    (40, "stand_bar_lean0__lh_deck__01__shuffle__01"),
    (41, "stand_bar_lean0__lh_deck__01__put_l_card__01"),
    (42, "stand_bar_lean0__lh_deck__01__put_u_card__01"),
    (43, "stand_bar_lean0__lh_deck__01__put_r_card__01"),
    (44, "stand_bar_lean0__lh_deck__01__describe_cards__01"),
    (45, "stand_bar_lean0__lh_deck__01__describe_cards__02"),
    (46, "stand_bar_lean0__lh_deck__01__describe_cards__03"),
    (47, "stand_bar_lean0__lh_deck__01__describe_cards__08"),
    (48, "stand_bar_lean0__lh_deck__01"),
    (49, "stand_bar_lean0__lh_deck__01__rh_flick__01"),
    (50, "stand_bar_lean0__lh_deck__01__rh_flick__03"),
]

# Dr. Valdes Entry IDs 4..11: Nervous ex-scientist standing idles
VALDES_IDLE_CLIPS: list[tuple[int, str, float]] = [
    (4, "stand__2h_front__01", 0.24),
    (5, "stand__2h_front__01__shuffle__01", 0.14),
    (6, "stand__2h_front__01__shuffle__02", 0.14),
    (7, "stand__2h_front__01__shuffle__03", 0.12),
    (8, "stand__2h_front__01__shuffle__04", 0.12),
    (9, "stand__2h_front__01__look_around__01", 0.08),
    (10, "stand__2h_front__01__scratch_neck__01", 0.08),
    (11, "stand__2h_front__01__rub_nose__01", 0.08),
]

# Dr. Valdes Entry IDs 21..34: Grounded male conversational gestures (verified dZ == 0.000m)
VALDES_GESTURE_CLIPS: list[tuple[int, str]] = [
    (21, "stand__2h_front__01__be_quiet__01"),
    (22, "stand__2h_front__01__talk__02"),
    (23, "stand__2h_front__01__describe_front__01"),
    (24, "stand__2h_front__01__describe_left__01"),
    (25, "stand__2h_front__01__describe_right__01"),
    (26, "stand__2h_front__01__describe_back__01"),
    (27, "stand__2h_front__01__nod__respectful__01"),
    (28, "stand__2h_front__01__nod__respectful__02"),
    (29, "stand__2h_front__01__yes__neutral__01"),
    (30, "stand__2h_front__01__no__neutral__01"),
    (31, "stand__2h_front__01__shrug__01"),
    (32, "stand__2h_front__01__shrug__02"),
    (33, "stand__2h_front__01__stop__neutral__01"),
    (34, "stand__2h_front__01__come_closer__neutral__01"),
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
        raise RuntimeError(f"WolvenKit command failed: {' '.join(args)}\n{out}")
    return out


def _cname(val: str) -> dict[str, Any]:
    return {"$type": "CName", "$storage": "string", "$value": val}


def _str_resref(path: str, flags: str = "Soft") -> dict[str, Any]:
    return {
        "DepotPath": {"$type": "ResourcePath", "$storage": "string", "$value": path},
        "Flags": flags,
    }


def _extract_handle_defs(obj: Any, defs: dict[str, Any]) -> None:
    if isinstance(obj, dict):
        if "HandleId" in obj and "Data" in obj:
            defs[str(obj["HandleId"])] = copy.deepcopy(obj["Data"])
        for v in obj.values():
            _extract_handle_defs(v, defs)
    elif isinstance(obj, list):
        for v in obj:
            _extract_handle_defs(v, defs)


def _inline_handles(obj: Any, defs: dict[str, Any]) -> Any:
    if isinstance(obj, dict):
        if "HandleRefId" in obj:
            hid = str(obj["HandleRefId"])
            if hid not in defs:
                raise KeyError(f"Missing HandleRefId {hid}")
            return {"HandleId": hid, "Data": _inline_handles(copy.deepcopy(defs[hid]), defs)}
        if "HandleId" in obj and "Data" in obj:
            return {"HandleId": str(obj["HandleId"]), "Data": _inline_handles(copy.deepcopy(obj["Data"]), defs)}
        return {k: _inline_handles(v, defs) for k, v in obj.items()}
    if isinstance(obj, list):
        return [_inline_handles(v, defs) for v in obj]
    return copy.deepcopy(obj)


def _split_chunk_and_comp_handles(obj: Any, seen_ids: list[int]) -> tuple[Any, Any]:
    if isinstance(obj, dict):
        if "HandleId" in obj and "Data" in obj:
            next_id = str(seen_ids[0])
            seen_ids[0] += 1
            ch_data, cp_data = _split_chunk_and_comp_handles(obj["Data"], seen_ids)
            return {"HandleId": next_id, "Data": ch_data}, {"HandleRefId": next_id}
        ch_out: dict[str, Any] = {}
        cp_out: dict[str, Any] = {}
        for k, v in obj.items():
            ch_v, cp_v = _split_chunk_and_comp_handles(v, seen_ids)
            ch_out[k] = ch_v
            cp_out[k] = cp_v
        return ch_out, cp_out
    if isinstance(obj, list):
        ch_list: list[Any] = []
        cp_list: list[Any] = []
        for item in obj:
            ch_v, cp_v = _split_chunk_and_comp_handles(item, seen_ids)
            ch_list.append(ch_v)
            cp_list.append(cp_v)
        return ch_list, cp_list
    return copy.deepcopy(obj), copy.deepcopy(obj)


def _get_resolved_chunk_list(ad: dict[str, Any]) -> list[dict[str, Any]]:
    defs: dict[str, Any] = {}
    chunks = ad["compiledData"]["Data"]["Chunks"]
    _extract_handle_defs(chunks, defs)
    _extract_handle_defs(ad.get("components", []), defs)
    return [_inline_handles(c, defs) for c in chunks]


def _build_sermo_npc_app(
    source_app_doc: dict[str, Any],
    source_app_name: str,
    out_app_depot: str,
    sermo_depot: str,
    lip_depot: str,
) -> dict[str, Any]:
    """Clones a base-game appearance into `"default"`, wires cloned Sermo AnimGraph & JALI .anims."""
    doc = copy.deepcopy(source_app_doc)
    doc["Header"]["ArchiveFileName"] = out_app_depot
    rc = doc["Data"]["RootChunk"]
    picked_app = None
    for app_entry in rc.get("appearances", []):
        if app_entry.get("Data", {}).get("name", {}).get("$value") == source_app_name:
            picked_app = app_entry
            break
    if picked_app is None:
        raise RuntimeError(f"Appearance '{source_app_name}' not found in {out_app_depot} donor")
    rc["appearances"] = [picked_app]
    ad = picked_app["Data"]
    ad["name"] = _cname("default")

    def _patch_comp_list(comp_list: list[dict[str, Any]], label: str) -> tuple[bool, bool]:
        got_face = False
        got_bank = False
        for c in comp_list:
            if not isinstance(c, dict):
                continue
            cname = c.get("name", {}).get("$value", "")
            if cname == "face_rig":
                c["graph"] = _str_resref(sermo_depot, flags="Obligatory")
                got_face = True
            elif cname == "man_face_base_animations":
                anims = c.get("animations", {})
                gp = anims.setdefault("gameplay", [])
                gp = [e for e in gp if e.get("animSet", {}).get("DepotPath", {}).get("$value") != lip_depot]
                gp.append(
                    {
                        "$type": "animAnimSetupEntry",
                        "animSet": _str_resref(lip_depot, flags="Default"),
                        "priority": 200,
                        "variableNames": [],
                    }
                )
                anims["gameplay"] = gp
                all_paths = [
                    e.get("animSet", {}).get("DepotPath", {}).get("$value", "")
                    for e in gp + anims.get("cinematics", [])
                ]
                anims["hash"] = jali.fnv1a_64_str(all_paths)
                got_bank = True
        if not got_face or not got_bank:
            raise RuntimeError(f"Missing face_rig ({got_face}) or man_face_base_animations ({got_bank}) in {label}")
        return got_face, got_bank

    _patch_comp_list(ad.get("components", []), f"{source_app_name}.components")
    _patch_comp_list(ad.get("compiledData", {}).get("Data", {}).get("Chunks", []), f"{source_app_name}.Chunks")

    rdeps = ad.setdefault("resolvedDependencies", [])
    existing_paths = {d.get("DepotPath", {}).get("$value") for d in rdeps if isinstance(d, dict)}
    for dep_path, dep_flag in (
        (sermo_depot, "Obligatory"),
        (lip_depot, "Soft"),
    ):
        if dep_path not in existing_paths:
            rdeps.append(_str_resref(dep_path, flags=dep_flag))

    return doc


def _max_handle_id(obj: Any) -> int:
    max_h = -1
    if isinstance(obj, dict):
        if "HandleId" in obj:
            try:
                max_h = max(max_h, int(obj["HandleId"]))
            except (TypeError, ValueError):
                pass
        for v in obj.values():
            max_h = max(max_h, _max_handle_id(v))
    elif isinstance(obj, list):
        for v in obj:
            max_h = max(max_h, _max_handle_id(v))
    return max_h


def _attach_misty_tarot_hand_props(doc: dict[str, Any]) -> None:
    """Attach 4 toggleable base-game 3D Tarot hand props to WeaponLeft/WeaponRight slots."""
    rc = doc["Data"]["RootChunk"]
    cd = rc["compiledData"]["Data"]
    chunks = cd["Chunks"]
    cruid_dict = cd["CruidDict"]
    comps = rc["components"]
    rdeps = rc.setdefault("resolvedDependencies", [])
    next_hid = _max_handle_id(doc) + 1

    tarot_props = [
        ("cv_tarot_deck_left", "971000000000000201", "base\\environment\\decoration\\misc\\tarot\\tarot_card_deck_a.mesh", "default", "WeaponLeft"),
        ("cv_tarot_card_moon", "971000000000000202", "base\\environment\\decoration\\misc\\tarot\\tarot_card_single_a.mesh", "moon", "WeaponRight"),
        ("cv_tarot_card_hangman", "971000000000000203", "base\\environment\\decoration\\misc\\tarot\\tarot_card_single_a.mesh", "hangman_180", "WeaponRight"),
        ("cv_tarot_card_tower", "971000000000000204", "base\\environment\\decoration\\misc\\tarot\\tarot_card_single_a.mesh", "tower", "WeaponRight"),
    ]

    existing_names = {c.get("name", {}).get("$value") for c in comps if isinstance(c, dict)}
    for prop_name, comp_id, mesh_path, mesh_app, slot_name in tarot_props:
        if prop_name in existing_names:
            continue
        hid = str(next_hid)
        next_hid += 1

        binding_data = {
            "$type": "entHardTransformBinding",
            "bindName": _cname("Item_Attachment_Slot"),
            "enabled": 1,
            "enableMask": {
                "$type": "entTagMask",
                "excludedTags": {"$type": "redTagList", "tags": [_cname("NoBinding")]},
                "hardTags": {"$type": "redTagList", "tags": []},
                "softTags": {"$type": "redTagList", "tags": []},
            },
            "slotName": _cname(slot_name),
        }
        base_comp = {
            "$type": "entMeshComponent",
            "autoHideDistance": 0,
            "castLocalShadows": "Always",
            "castRayTracedGlobalShadows": "Always",
            "castRayTracedLocalShadows": "Default",
            "castShadows": "Always",
            "chunkMask": "9223372036854775807",
            "forcedLodDistance": "Default",
            "forceLODLevel": -1,
            "id": comp_id,
            "isEnabled": 0,
            "isReplicable": 0,
            "localTransform": {
                "$type": "WorldTransform",
                "Orientation": {"$type": "Quaternion", "i": 0, "j": 0, "k": 0, "r": 1},
                "Position": {
                    "$type": "WorldPosition",
                    "x": {"$type": "FixedPoint", "Bits": 0},
                    "y": {"$type": "FixedPoint", "Bits": 0},
                    "z": {"$type": "FixedPoint", "Bits": 0},
                },
            },
            "LODMode": "AlwaysVisible",
            "mesh": _str_resref(mesh_path, flags="Default"),
            "meshAppearance": _cname(mesh_app),
            "motionBlurScale": 1,
            "name": _cname(prop_name),
            "navigationImpact": {"$type": "NavGenNavigationSetting", "navmeshImpact": "Ignored"},
            "numInstances": 0,
            "objectTypeID": "ROT_Static",
            "order": 0,
            "overrideMeshNavigationImpact": 1,
            "renderingPlane": "RPl_Scene",
            "renderSceneLayerMask": "Default",
            "version": 0,
            "visualScale": {"$type": "Vector3", "X": 1, "Y": 1, "Z": 1},
        }

        chunk_entry = copy.deepcopy(base_comp)
        chunk_entry["parentTransform"] = {"HandleId": hid, "Data": binding_data}
        chunk_idx = len(chunks)
        chunks.append(chunk_entry)
        cruid_dict[str(chunk_idx)] = comp_id

        comp_entry = copy.deepcopy(base_comp)
        comp_entry["parentTransform"] = {"HandleRefId": hid}
        comps.append(comp_entry)

    existing_rdeps = {d.get("DepotPath", {}).get("$value") for d in rdeps if isinstance(d, dict)}
    for mesh_dep in (
        "base\\environment\\decoration\\misc\\tarot\\tarot_card_deck_a.mesh",
        "base\\environment\\decoration\\misc\\tarot\\tarot_card_single_a.mesh",
    ):
        if mesh_dep not in existing_rdeps:
            rdeps.append(_str_resref(mesh_dep, flags="Soft"))


def _build_sermo_npc_ent(
    source_ent_doc: dict[str, Any],
    out_ent_depot: str,
    app_depot: str,
    attach_tarot_hand_props: bool = False,
) -> dict[str, Any]:
    """Points NPC clone entity to custom single-appearance `.app` (0 ep1 refs)."""
    doc = copy.deepcopy(source_ent_doc)
    doc["Header"]["ArchiveFileName"] = out_ent_depot
    rc = doc["Data"]["RootChunk"]
    rc["defaultAppearance"] = _cname("default")
    rc["appearances"] = [
        {
            "$type": "entTemplateAppearance",
            "appearanceName": _cname("default"),
            "appearanceResource": _str_resref(app_depot, flags="Soft"),
            "name": _cname("default"),
        }
    ]
    if attach_tarot_hand_props:
        _attach_misty_tarot_hand_props(doc)
    return doc


def _build_workspot_anchor_ent(
    chair_ent_doc: dict[str, Any],
    shutters_ent_doc: dict[str, Any],
    anchor_depot_path: str,
    workspot_depot_path: str,
    comp_id: str,
) -> dict[str, Any]:
    doc = copy.deepcopy(chair_ent_doc)
    rc = doc["Data"]["RootChunk"]

    mapper_tmpl = None
    for c in _get_resolved_chunk_list({"compiledData": rc["compiledData"], "components": rc["components"]}):
        if c.get("$type") == "WorkspotMapperComponent":
            mapper_tmpl = c
            break
    if mapper_tmpl is None:
        raise RuntimeError("WorkspotMapperComponent not found in q001_ripperdoc_chair.ent")

    ws_comp_tmpl = None
    for c in shutters_ent_doc["Data"]["RootChunk"]["components"]:
        if c.get("$type") == "workWorkspotResourceComponent":
            ws_comp_tmpl = copy.deepcopy(c)
            break
    if ws_comp_tmpl is None:
        raise RuntimeError("workWorkspotResourceComponent not found in workspots_shutters.ent")

    ws_comp_tmpl["id"] = comp_id
    ws_comp_tmpl["name"] = _cname("workspot")
    ws_comp_tmpl["isReplicable"] = 0
    ws_comp_tmpl["shouldCrouch"] = 0
    ws_comp_tmpl["syncSlotName"] = _cname("None")
    ws_comp_tmpl["parentTransform"] = None
    ws_comp_tmpl["localTransform"] = {
        "$type": "WorldTransform",
        "Orientation": {"$type": "Quaternion", "i": 0, "j": 0, "k": 0, "r": 1},
        "Position": {
            "$type": "WorldPosition",
            "x": {"$type": "FixedPoint", "Bits": 0},
            "y": {"$type": "FixedPoint", "Bits": 0},
            "z": {"$type": "FixedPoint", "Bits": 0},
        },
    }
    ws_comp_tmpl["workspotResource"] = _str_resref(workspot_depot_path, flags="Default")

    mapper_comp = copy.deepcopy(mapper_tmpl)
    mapper_id = str(int(comp_id) + 1)
    mapper_comp["id"] = mapper_id

    root_game_obj = copy.deepcopy(rc["entity"]["Data"])
    root_game_obj["tags"] = {"$type": "redTagList", "tags": []}

    handle_counter = [0]
    ch_ws, cp_ws = _split_chunk_and_comp_handles(ws_comp_tmpl, handle_counter)
    ch_mp, cp_mp = _split_chunk_and_comp_handles(mapper_comp, handle_counter)
    ch_go, cp_go = _split_chunk_and_comp_handles(root_game_obj, handle_counter)

    doc["Header"]["ArchiveFileName"] = anchor_depot_path
    rc["entity"] = {"HandleId": str(handle_counter[0]), "Data": cp_go}
    rc["components"] = [cp_ws, cp_mp]
    rc["compiledData"] = {
        "BufferId": "0",
        "Flags": 7471104,
        "Type": "WolvenKit.RED4.Archive.Buffer.RedPackage, WolvenKit.RED4, Version=9.1.1.0, Culture=neutral, PublicKeyToken=null",
        "Data": {
            "Version": 4,
            "Sections": 6,
            "CruidIndex": 0,
            "CruidDict": {
                "0": "0",
                "1": comp_id,
                "2": mapper_id,
            },
            "Chunks": [ch_go, ch_ws, ch_mp],
        },
    }
    rc["appearances"] = []
    rc["resolvedDependencies"] = [_str_resref(workspot_depot_path, flags="Default")]
    return doc


def _build_conversational_workspot(
    base_ws_doc: dict[str, Any],
    *,
    archive_depot_path: str,
    rig_depot: str,
    animset_depots: list[str],
    idle_anim_name: str,
    idle_clips_spec: list[tuple[int, str, float]],
    gesture_clips_spec: list[tuple[int, str]],
    valid_clip_names: set[str],
    extra_clips_spec: list[tuple[int, str]] | None = None,
) -> dict[str, Any]:
    """
    Rebuilds a `.workspot.json` around an organic idle loop + jumpable conversational gesture bank:
      - IDs 4..11 in infinite idle loop [2] -> [3]
      - IDs 21+ triggered dynamically via SendJumpCommandEnt(npc, id, true)
    """
    doc = copy.deepcopy(base_ws_doc)
    doc["Header"]["ArchiveFileName"] = archive_depot_path
    wt = doc["Data"]["RootChunk"]["workspotTree"]["Data"]

    for _, cname, _ in idle_clips_spec:
        if cname not in valid_clip_names:
            raise KeyError(f"Idle clip '{cname}' not found in verified animsets for {archive_depot_path}!")
    for _, cname in gesture_clips_spec:
        if cname not in valid_clip_names:
            raise KeyError(f"Gesture clip '{cname}' not found in verified animsets for {archive_depot_path}!")
    for _, cname in extra_clips_spec or []:
        if cname not in valid_clip_names:
            raise KeyError(f"Extra Tarot clip '{cname}' not found in verified animsets for {archive_depot_path}!")

    patched_entry = None
    for fa in wt.get("finalAnimsets", []):
        if fa.get("rig", {}).get("DepotPath", {}).get("$value") == rig_depot:
            fa["animations"] = {
                "$type": "animAnimSetup",
                "cinematics": [
                    {
                        "$type": "animAnimSetupEntry",
                        "animSet": _str_resref(ap, flags="Default"),
                        "priority": 200,
                        "variableNames": [],
                    }
                    for ap in animset_depots
                ],
                "gameplay": [],
                "hash": jali.fnv1a_64_str(animset_depots),
            }
            fa["loadingHandles"] = [_str_resref(ap, flags="Default") for ap in animset_depots]
            patched_entry = fa
            break
    if patched_entry is None:
        raise RuntimeError(f"Rig '{rig_depot}' entry not found in finalAnimsets")
    # Keep single clean matching rig in finalAnimsets so donor rigs don't pull unrelated anim dependencies
    wt["finalAnimsets"] = [patched_entry]
    wt["customTransitionAnims"] = []

    hid_seq = 5

    def next_hid() -> str:
        nonlocal hid_seq
        val = str(hid_seq)
        hid_seq += 1
        return val

    def make_anim_clip(entry_id: int, anim_name: str, blend_out: float = 0.5) -> dict[str, Any]:
        return {
            "HandleId": next_hid(),
            "Data": {
                "$type": "workAnimClip",
                "animName": _cname(anim_name),
                "blendOutTime": blend_out,
                "flags": 2,
                "id": {"$type": "workWorkEntryId", "id": entry_id},
            },
        }

    idle_clips = [make_anim_clip(eid, nm, 0.5) for eid, nm, _ in idle_clips_spec]
    idle_weights = [w for _, _, w in idle_clips_spec]

    gesture_clips = [make_anim_clip(eid, nm, 0.5) for eid, nm in gesture_clips_spec]
    uniform_w = 1.0 / float(len(gesture_clips))
    gesture_weights = [uniform_w] * len(gesture_clips)

    root_hid = next_hid()
    idle_seq_hid = next_hid()
    idle_rand_hid = next_hid()
    gest_rand_hid = next_hid()

    root_list: list[dict[str, Any]] = [
        {
            "HandleId": idle_seq_hid,
            "Data": {
                "$type": "workSequence",
                "category": "Any",
                "disableAutoTransition": 0,
                "flags": 0,
                "id": {"$type": "workWorkEntryId", "id": 2},
                "idleAnim": _cname(idle_anim_name),
                "list": [
                    {
                        "HandleId": idle_rand_hid,
                        "Data": {
                            "$type": "workRandomList",
                            "disableAutoTransition": 0,
                            "dontRepeatLastAnims": 1,
                            "flags": 0,
                            "id": {"$type": "workWorkEntryId", "id": 3},
                            "idleAnim": _cname("None"),
                            "list": idle_clips,
                            "maxClips": 2,
                            "minClips": 1,
                            "pauseBetweenLength": 1.2,
                            "pauseBlendOutTime": 0.5,
                            "pauseLengthDeviation": 0.6,
                            "weights": idle_weights,
                        },
                    }
                ],
                "loopInfinitely": 1,
                "previousLoopInfinitely": 1,
            },
        },
        {
            "HandleId": gest_rand_hid,
            "Data": {
                "$type": "workRandomList",
                "disableAutoTransition": 0,
                "dontRepeatLastAnims": 1,
                "flags": 0,
                "id": {"$type": "workWorkEntryId", "id": 20},
                "idleAnim": _cname(idle_anim_name),
                "list": gesture_clips,
                "maxClips": 1,
                "minClips": 1,
                "pauseBetweenLength": 0.0,
                "pauseBlendOutTime": 0.5,
                "pauseLengthDeviation": 0.0,
                "weights": gesture_weights,
            },
        },
    ]

    if extra_clips_spec:
        extra_seq_hid = next_hid()
        extra_rand_hid = next_hid()
        extra_clips = [make_anim_clip(eid, nm, 0.5) for eid, nm in extra_clips_spec]
        extra_weights = [1.0 if eid == 48 else 0.0 for eid, _ in extra_clips_spec]
        root_list.append(
            {
                "HandleId": extra_seq_hid,
                "Data": {
                    "$type": "workSequence",
                    "category": "Any",
                    "disableAutoTransition": 0,
                    "flags": 0,
                    "id": {"$type": "workWorkEntryId", "id": 60},
                    "idleAnim": _cname("stand_bar_lean0__lh_deck__01"),
                    "list": [
                        {
                            "HandleId": extra_rand_hid,
                            "Data": {
                                "$type": "workRandomList",
                                "disableAutoTransition": 0,
                                "dontRepeatLastAnims": 0,
                                "flags": 0,
                                "id": {"$type": "workWorkEntryId", "id": 61},
                                "idleAnim": _cname("stand_bar_lean0__lh_deck__01"),
                                "list": extra_clips,
                                "maxClips": 1,
                                "minClips": 1,
                                "pauseBetweenLength": 0.0,
                                "pauseBlendOutTime": 0.5,
                                "pauseLengthDeviation": 0.0,
                                "weights": extra_weights,
                            },
                        }
                    ],
                    "loopInfinitely": 1,
                    "previousLoopInfinitely": 1,
                },
            }
        )

    wt["rootEntry"] = {
        "HandleId": root_hid,
        "Data": {
            "$type": "workSequence",
            "category": "Any",
            "disableAutoTransition": 0,
            "flags": 0,
            "id": {"$type": "workWorkEntryId", "id": 1},
            "idleAnim": _cname("None"),
            "list": root_list,
            "loopInfinitely": 1,
            "previousLoopInfinitely": 1,
        },
    }

    max_entry_id = max(
        [e[0] for e in idle_clips_spec]
        + [e[0] for e in gesture_clips_spec]
        + [e[0] for e in (extra_clips_spec or [])]
    )
    if extra_clips_spec:
        max_entry_id = max(max_entry_id, 61)
    wt["useTimeLimitForSequences"] = 0
    wt["idCounter"] = max_entry_id
    wt["inertializationDurationEnter"] = 0.5
    wt["inertializationDurationExitNatural"] = 0.5
    wt["autoTransitionBlendTime"] = 0.5
    return doc


def generate_all() -> None:
    if not WOLVENKIT_CLI.is_file():
        raise FileNotFoundError(f"WolvenKit.CLI.exe not found at {WOLVENKIT_CLI}")
    if not GAMEDATA_ARC.is_file():
        raise FileNotFoundError(f"Cyberpunk 2077 archive not found at {GAMEDATA_ARC}")

    OUT_CHAR_DIR.mkdir(parents=True, exist_ok=True)
    OUT_ENT_DIR.mkdir(parents=True, exist_ok=True)
    OUT_WS_DIR.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="cv_npc_ws_") as tmp:
        tmp_path = Path(tmp)
        raw_dir = tmp_path / "raw"
        flat_dir = tmp_path / "flat"
        json_dir = tmp_path / "json"
        roundtrip_dir = tmp_path / "rt"
        for d in (raw_dir, flat_dir, json_dir, roundtrip_dir):
            d.mkdir(parents=True, exist_ok=True)

        print("[1/3] Unbundling Misty, Dr. Valdes, Lucia & Dra. Solis (.ent/.app), workspots, and female/male animsets...")
        if APP_ARC.is_file():
            _run_wkit([
                "unbundle",
                str(APP_ARC),
                "-o",
                str(raw_dir),
                "-r",
                r"(appearances\\main_npc\\misty\.app|tertiary_characters\\misty\.ent|appearances\\service\\service__ripperdoc_ma\.app|entities\\service\\service__ripperdoc_ma\.ent|appearances\\citizen\\citizen__lowlife_wa\.app|entities\\citizen\\citizen__lowlife_wa\.ent|appearances\\corpo\\corpo__arasaka_wa\.app|entities\\corpo\\corpo__arasaka_wa\.ent)$",
            ])
        _run_wkit([
            "unbundle",
            str(GAMEDATA_ARC),
            "-o",
            str(raw_dir),
            "-r",
            r"(tertiary_characters\\misty\.ent|appearances\\main_npc\\misty\.app|entities\\citizen\\citizen__lowlife_wa\.ent|entities\\corpo\\corpo__arasaka_wa\.ent|q001_ripperdoc_chair\.ent|workspots_shutters\.ent)$",
        ])
        _run_wkit([
            "unbundle",
            str(MEM_RES_ARC),
            "-o",
            str(raw_dir),
            "-r",
            r"(misty__stand__stand_around__01\.workspot|generic__stand_ground__stand_around__08\.workspot|generic_average_female_stand__?2h_on_sides\.anims)$",
        ])
        if ANIM_ARC.is_file():
            _run_wkit([
                "unbundle",
                str(ANIM_ARC),
                "-o",
                str(raw_dir),
                "-r",
                r"(generic_average_female_stand__?2h_on_sides|generic_male_average__stand__2h_front__01|q001_04a_rd_assistant__female_average)\.anims$",
            ])

        raw_files = sorted(p for p in raw_dir.rglob("*") if p.is_file())
        if len(raw_files) < 10:
            raise RuntimeError(f"Expected >= 10 extracted donor templates, found {[p.name for p in raw_files]}")

        print(f"[2/3] Copying {len(raw_files)} donor files to short path & converting to JSON...")
        for rf in raw_files:
            short_f = flat_dir / rf.name
            shutil.copy2(rf, short_f)
            _run_wkit(["convert", "serialize", str(short_f), "-o", str(json_dir)])

        def load_json(name: str) -> dict[str, Any]:
            hits = list(json_dir.glob(f"{name}.json"))
            if not hits:
                raise FileNotFoundError(f"Missing serialized JSON for {name} in {json_dir}")
            return json.loads(hits[0].read_text(encoding="utf-8"))

        female_clips: set[str] = set()
        for anim_fname in (
            "generic_average_female_stand__2h_on_sides.anims",
            "generic_average_female_stand_2h_on_sides.anims",
            "q001_04a_rd_assistant__female_average.anims",
        ):
            aj = load_json(anim_fname)
            for ent in aj["Data"]["RootChunk"]["animations"]:
                female_clips.add(ent["Data"]["animation"]["Data"]["name"]["$value"])

        male_clips: set[str] = set()
        maj = load_json("generic_male_average__stand__2h_front__01.anims")
        for ent in maj["Data"]["RootChunk"]["animations"]:
            male_clips.add(ent["Data"]["animation"]["Data"]["name"]["$value"])
        print(f"  Verified {len(female_clips)} female + {len(male_clips)} male conversational clips loaded.")

        misty_app_doc = _build_sermo_npc_app(
            load_json("misty.app"),
            "default",
            CV_MISTY_APP_DEPOT,
            CV_WOMAN_SERMO_DEPOT,
            CV_MISTY_LIP_DEPOT,
        )
        misty_ent_doc = _build_sermo_npc_ent(load_json("misty.ent"), CV_MISTY_ENT_DEPOT, CV_MISTY_APP_DEPOT, attach_tarot_hand_props=True)
        misty_ws_doc = _build_conversational_workspot(
            load_json("misty__stand__stand_around__01.workspot"),
            archive_depot_path="crimson_veil\\workspots\\cv_misty_rooftop_loop.workspot",
            rig_depot=WOMAN_BASE_RIG,
            animset_depots=[FEMALE_2H_ON_SIDES_A, FEMALE_2H_ON_SIDES_B, Q001_MISTY_DECK_ANIMS],
            idle_anim_name="stand__2h_on_sides__01",
            idle_clips_spec=MISTY_IDLE_CLIPS,
            gesture_clips_spec=MISTY_GESTURE_CLIPS,
            valid_clip_names=female_clips,
            extra_clips_spec=MISTY_TAROT_DECK_CLIPS,
        )
        misty_anchor_doc = _build_workspot_anchor_ent(
            load_json("q001_ripperdoc_chair.ent"),
            load_json("workspots_shutters.ent"),
            "crimson_veil\\entities\\cv_ws_misty_rooftop.ent",
            "crimson_veil\\workspots\\cv_misty_rooftop_loop.workspot",
            "971000000000000101",
        )

        valdes_app_doc = _build_sermo_npc_app(
            load_json("service__ripperdoc_ma.app"),
            "_std_rcr_ripperdoc_01",
            CV_VALDES_APP_DEPOT,
            CV_MAN_SERMO_DEPOT,
            CV_VALDES_LIP_DEPOT,
        )
        valdes_ent_doc = _build_sermo_npc_ent(load_json("service__ripperdoc_ma.ent"), CV_VALDES_ENT_DEPOT, CV_VALDES_APP_DEPOT)
        valdes_ws_doc = _build_conversational_workspot(
            load_json("generic__stand_ground__stand_around__08.workspot"),
            archive_depot_path="crimson_veil\\workspots\\cv_valdes_loop.workspot",
            rig_depot=MAN_BASE_RIG,
            animset_depots=[MALE_2H_FRONT_ANIMS],
            idle_anim_name="stand__2h_front__01",
            idle_clips_spec=VALDES_IDLE_CLIPS,
            gesture_clips_spec=VALDES_GESTURE_CLIPS,
            valid_clip_names=male_clips,
        )
        valdes_anchor_doc = _build_workspot_anchor_ent(
            load_json("q001_ripperdoc_chair.ent"),
            load_json("workspots_shutters.ent"),
            "crimson_veil\\entities\\cv_ws_valdes.ent",
            "crimson_veil\\workspots\\cv_valdes_loop.workspot",
            "971000000000000111",
        )

        lucia_app_doc = _build_sermo_npc_app(
            load_json("citizen__lowlife_wa.app"),
            "queen_of_the_stoop_wa_12",
            CV_LUCIA_APP_DEPOT,
            CV_LUCIA_SERMO_DEPOT,
            CV_LUCIA_LIP_DEPOT,
        )
        lucia_ent_doc = _build_sermo_npc_ent(load_json("citizen__lowlife_wa.ent"), CV_LUCIA_ENT_DEPOT, CV_LUCIA_APP_DEPOT)
        lucia_ws_doc = _build_conversational_workspot(
            load_json("misty__stand__stand_around__01.workspot"),
            archive_depot_path="crimson_veil\\workspots\\cv_lucia_loop.workspot",
            rig_depot=WOMAN_BASE_RIG,
            animset_depots=[FEMALE_2H_ON_SIDES_A, FEMALE_2H_ON_SIDES_B],
            idle_anim_name="stand__2h_on_sides__01",
            idle_clips_spec=MISTY_IDLE_CLIPS,
            gesture_clips_spec=MISTY_GESTURE_CLIPS,
            valid_clip_names=female_clips,
        )
        lucia_anchor_doc = _build_workspot_anchor_ent(
            load_json("q001_ripperdoc_chair.ent"),
            load_json("workspots_shutters.ent"),
            "crimson_veil\\entities\\cv_ws_lucia.ent",
            "crimson_veil\\workspots\\cv_lucia_loop.workspot",
            "971000000000000121",
        )

        solis_app_doc = _build_sermo_npc_app(
            load_json("corpo__arasaka_wa.app"),
            "agent__lvl2_03",
            CV_SOLIS_APP_DEPOT,
            CV_SOLIS_SERMO_DEPOT,
            CV_SOLIS_LIP_DEPOT,
        )
        solis_ent_doc = _build_sermo_npc_ent(load_json("corpo__arasaka_wa.ent"), CV_SOLIS_ENT_DEPOT, CV_SOLIS_APP_DEPOT)
        solis_ws_doc = _build_conversational_workspot(
            load_json("misty__stand__stand_around__01.workspot"),
            archive_depot_path="crimson_veil\\workspots\\cv_solis_loop.workspot",
            rig_depot=WOMAN_BASE_RIG,
            animset_depots=[FEMALE_2H_ON_SIDES_A, FEMALE_2H_ON_SIDES_B],
            idle_anim_name="stand__2h_on_sides__01",
            idle_clips_spec=MISTY_IDLE_CLIPS,
            gesture_clips_spec=MISTY_GESTURE_CLIPS,
            valid_clip_names=female_clips,
        )
        solis_anchor_doc = _build_workspot_anchor_ent(
            load_json("q001_ripperdoc_chair.ent"),
            load_json("workspots_shutters.ent"),
            "crimson_veil\\entities\\cv_ws_solis.ent",
            "crimson_veil\\workspots\\cv_solis_loop.workspot",
            "971000000000000131",
        )

        written = [
            (OUT_CHAR_DIR / "cv_misty.app.json", misty_app_doc, True),
            (OUT_CHAR_DIR / "cv_misty.ent.json", misty_ent_doc, False),
            (OUT_WS_DIR / "cv_misty_rooftop_loop.workspot.json", misty_ws_doc, False),
            (OUT_ENT_DIR / "cv_ws_misty_rooftop.ent.json", misty_anchor_doc, False),
            (OUT_CHAR_DIR / "cv_valdes.app.json", valdes_app_doc, True),
            (OUT_CHAR_DIR / "cv_valdes.ent.json", valdes_ent_doc, False),
            (OUT_WS_DIR / "cv_valdes_loop.workspot.json", valdes_ws_doc, False),
            (OUT_ENT_DIR / "cv_ws_valdes.ent.json", valdes_anchor_doc, False),
            (OUT_CHAR_DIR / "cv_lucia.app.json", lucia_app_doc, True),
            (OUT_CHAR_DIR / "cv_lucia.ent.json", lucia_ent_doc, False),
            (OUT_WS_DIR / "cv_lucia_loop.workspot.json", lucia_ws_doc, False),
            (OUT_ENT_DIR / "cv_ws_lucia.ent.json", lucia_anchor_doc, False),
            (OUT_CHAR_DIR / "cv_solis.app.json", solis_app_doc, True),
            (OUT_CHAR_DIR / "cv_solis.ent.json", solis_ent_doc, False),
            (OUT_WS_DIR / "cv_solis_loop.workspot.json", solis_ws_doc, False),
            (OUT_ENT_DIR / "cv_ws_solis.ent.json", solis_anchor_doc, False),
        ]
        for out_p, data, compact in written:
            txt = json.dumps(data, ensure_ascii=False) if compact else json.dumps(data, indent=2, ensure_ascii=False)
            if re.search(r'(?:^|["\\/])ep1[\\/]', txt, re.I):
                raise RuntimeError(f"Forbidden ep1\\ archive reference found in {out_p.name}")
            out_p.write_text(txt, encoding="utf-8")

        print(f"[3/3] Verifying CR2W roundtrip deserialize+serialize on {len(written)} files...")
        for src_json, _, _ in written:
            bin_name = src_json.name[:-5]
            _run_wkit(["convert", "deserialize", str(src_json), "-o", str(roundtrip_dir)])
            bin_path = roundtrip_dir / bin_name
            if not bin_path.is_file() or bin_path.stat().st_size < 32:
                raise RuntimeError(f"Deserialized binary missing/empty for {src_json.name}")
            _run_wkit(["convert", "serialize", str(bin_path), "-o", str(roundtrip_dir)])
            rt_json = roundtrip_dir / src_json.name
            if not rt_json.is_file():
                raise RuntimeError(f"Roundtrip serialize failed for {src_json.name}")
            rt_data = json.loads(rt_json.read_text(encoding="utf-8"))
            if src_json.name.endswith(".workspot.json"):
                rt_wt = rt_data["Data"]["RootChunk"]["workspotTree"]["Data"]
                root_seq = rt_wt["rootEntry"]["Data"]
                assert root_seq.get("loopInfinitely") == 1, f"{src_json.name} loopInfinitely != 1"
                assert rt_wt.get("useTimeLimitForSequences") == 0, f"{src_json.name} useTimeLimitForSequences != 0"
                for fa in rt_wt.get("finalAnimsets", []):
                    anim_entries = fa.get("animations", {}).get("cinematics", []) + fa.get("animations", {}).get("gameplay", [])
                    anim_paths = [e.get("animSet", {}).get("DepotPath", {}).get("$value") for e in anim_entries]
                    lh_entries = fa.get("loadingHandles", [])
                    lh_paths = [h.get("DepotPath", {}).get("$value") for h in lh_entries]
                    assert set(anim_paths) == set(lh_paths) and len(anim_paths) == len(lh_paths), (
                        f"{src_json.name} loadingHandles mismatch: anims={anim_paths} vs lh={lh_paths}"
                    )
                    assert all(h.get("Flags") == "Default" for h in lh_entries), (
                        f"{src_json.name} loadingHandles Flags must be Default"
                    )
                print(f"  [OK] {src_json.name}: rigs={len(rt_wt.get('finalAnimsets', []))} idCounter={rt_wt.get('idCounter')} size={bin_path.stat().st_size}B")
            else:
                rt_rc = rt_data["Data"]["RootChunk"]
                if src_json.name == "cv_misty.ent.json":
                    rt_comps = {
                        c.get("name", {}).get("$value"): c
                        for c in rt_rc.get("components", [])
                        if isinstance(c, dict)
                    }
                    for req_prop in (
                        "cv_tarot_deck_left",
                        "cv_tarot_card_moon",
                        "cv_tarot_card_hangman",
                        "cv_tarot_card_tower",
                    ):
                        assert req_prop in rt_comps, f"Missing roundtrip Tarot hand prop: {req_prop}"
                        assert rt_comps[req_prop].get("isEnabled") == 0, f"{req_prop} isEnabled != 0"
                print(
                    f"  [OK] {src_json.name}: apps={len(rt_rc.get('appearances', []))} "
                    f"comps={len(rt_rc.get('components', []))} size={bin_path.stat().st_size}B"
                )


if __name__ == "__main__":
    try:
        generate_all()
        print("[DONE] Misty + Dr. Valdes .app/.ent + conversational workspots + anchors verified (0 ep1).")
    except Exception as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
