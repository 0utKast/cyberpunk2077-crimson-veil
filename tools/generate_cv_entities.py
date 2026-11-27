"""
Generates CR2W custom scene/prop entities for Velo Carmesi / Crimson Veil
(Phase 0 — Vertical Slice, 100% Cyberpunk 2077 Base Game 2.x, 0 ep1):

  wolvenkit_src/archive/crimson_veil/entities/
    - cv_esoterica_omen_altar.ent.json   (Misty's Esoterica side altar)
    - cv_rooftop_tarot_table.ent.json    (Misty's Rooftop Tarot reading table)
    - cv_blood_shrine.ent.json           (Northside Oilfields crime scene blood shrine)
    - cv_uv_emitter.ent.json             (Northside Oilfields interactive UV spotlight tower)

Every entity is built cleanly from base-game meshes/lights with static box colliders where solid
and roundtrip-verified via WolvenKit.CLI convert deserialize + serialize.
"""

from __future__ import annotations

import copy
import json
import math
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

MOD_ROOT = Path(__file__).resolve().parent.parent
WORKSPACE_ROOT = MOD_ROOT.parent.parent
WOLVENKIT_CLI = WORKSPACE_ROOT / "tools" / "sdk" / "wolvenkit_cli" / "WolvenKit.CLI.exe"
DONOR_CASE_ENT = WORKSPACE_ROOT / "mods" / "hei_gui_stealth" / "wolvenkit_src" / "archive" / "hei_gui_stealth" / "entities" / "heigui_dead_drop_case.ent.json"
OUT_ENT_DIR = MOD_ROOT / "wolvenkit_src" / "archive" / "crimson_veil" / "entities"
BASEGAME_GAMEDATA_ARCHIVE = Path(r"C:\Program Files (x86)\Steam\steamapps\common\Cyberpunk 2077\archive\pc\content\basegame_4_gamedata.archive")

FIXED_POINT_SCALE = 131072.0

# Verified Base-Game Meshes & Bounding Boxes (0 ep1)
MESH_POOR_TABLE_B = "base\\environment\\decoration\\furniture\\outdoor\\poor_utility_table\\poor_utility_table_b.mesh"  # top Z = 0.800
MESH_TAROT_SINGLE = "base\\environment\\decoration\\misc\\tarot\\tarot_card_single_a.mesh"
MESH_TAROT_DECK = "base\\environment\\decoration\\misc\\tarot\\tarot_card_deck_a.mesh"
MESH_DREAMCATCHER = "base\\environment\\decoration\\unique\\quest\\mq033\\mistys_dreamcatcher.mesh"
MESH_FUNERAL_STAND = "base\\environment\\decoration\\lighting\\candles\\candle_stand_funeral\\candle_stand_funeral_a.mesh"  # Z = 0.00..0.54
MESH_CANDLE_A = "base\\environment\\decoration\\lighting\\candles\\candle\\candle_a.mesh"  # Z = 0.00..0.23
MESH_IV_STAND = "base\\environment\\decoration\\electronics\\medical\\machine_iv_stand\\machine_iv_stand_a.mesh"  # Z = 0.00..1.36
MESH_BLOOD_DRIP = "base\\environment\\decoration\\medical\\accessories\\medkit\\medkit_stuff_drip_blood.mesh"  # Z = 0.005..0.168
MESH_ELEC_BOX_H = "base\\environment\\decoration\\public_utility\\generator\\electrical_box\\electrical_box_h.mesh"  # black pedestal Z = 0.00..1.10
MESH_SPOTLIGHT_MOUNT = "base\\environment\\decoration\\lighting\\industrial\\spotlight\\spotlight_a_mount_a.mesh"
MESH_SPOTLIGHT_A = "base\\environment\\decoration\\lighting\\industrial\\spotlight\\spotlight_a.mesh"
MESH_TERMINAL_ENTROPY = "base\\environment\\decoration\\electronics\\devices\\device_data_terminal\\device_data_terminal_a_entropy.mesh"
MESH_TERMINAL_NEOMIL = "base\\environment\\decoration\\electronics\\devices\\device_data_terminal\\device_data_terminal_c_neomilitary.mesh"
MESH_CYBERDECK_BASE = "base\\environment\\decoration\\unique\\quest\\q108\\q108_cyberdeck\\q108_cyberdeck_a_base_a.mesh"
MESH_CYBERDECK_SCREEN = "base\\environment\\decoration\\unique\\quest\\q108\\q108_cyberdeck\\q108_cyberdeck_a_screen_a.mesh"
MESH_SHARD = "base\\environment\\decoration\\electronics\\hardware\\shard\\shard_a.mesh"
MESH_CYBERWARE_POD = "base\\items\\interactive\\medical\\int_medical_002__cyberware_container\\int_medical_002__cyberware_container_01.mesh"
MESH_SURGICAL_MACHINE = "base\\environment\\decoration\\electronics\\medical\\surgical_machine\\surgical_machine_a.mesh"
MESH_DOOR_SLIDING_C = "base\\environment\\decoration\\doors\\sliding\\door_sliding_c.mesh"
MESH_DOOR_CASING_A = "base\\environment\\decoration\\doors\\sliding\\door_sliding_casing_single_a.mesh"
MESH_DOOR_FRAME_A = "base\\environment\\decoration\\doors\\door_frame\\door_frame_single_a.mesh"
MESH_DOOR_HANDLE_A = "base\\environment\\decoration\\doors\\door_devices\\door_handle_a_entropy.mesh"
MESH_DOOR_LIGHT_A = "base\\environment\\decoration\\doors\\door_devices\\door_light_a_entropy.mesh"


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


def _meters_to_bits(meters: float) -> int:
    return int(round(meters * FIXED_POINT_SCALE))


def _pitch_yaw_deg_to_quat(pitch_deg: float, yaw_deg: float) -> dict[str, Any]:
    """Compose Z-up yaw followed by local X pitch (q_yaw * q_pitch)."""
    pr = math.radians(pitch_deg) * 0.5
    yr = math.radians(yaw_deg) * 0.5
    px, pw = math.sin(pr), math.cos(pr)
    yz, yw = math.sin(yr), math.cos(yr)
    return {
        "$type": "Quaternion",
        "i": round(yw * px, 6),
        "j": round(yz * px, 6),
        "k": round(yz * pw, 6),
        "r": round(yw * pw, 6),
    }


def _yaw_deg_to_quat(yaw_deg: float) -> dict[str, Any]:
    return _pitch_yaw_deg_to_quat(0.0, yaw_deg)


def _set_pos_meters(
    comp: dict[str, Any],
    x: float,
    y: float,
    z: float,
    yaw_deg: float = 0.0,
    pitch_deg: float = 0.0,
) -> None:
    lt = comp["localTransform"]
    lt["Orientation"] = _pitch_yaw_deg_to_quat(pitch_deg, yaw_deg)
    lt["Position"]["x"]["Bits"] = _meters_to_bits(x)
    lt["Position"]["y"]["Bits"] = _meters_to_bits(y)
    lt["Position"]["z"]["Bits"] = _meters_to_bits(z)


def _make_mesh_comp(
    tmpl: dict[str, Any],
    cid: str,
    name: str,
    mesh_path: str,
    appearance: str = "default",
    pos: tuple[float, float, float] = (0.0, 0.0, 0.0),
    scale: tuple[float, float, float] = (1.0, 1.0, 1.0),
    yaw_deg: float = 0.0,
    pitch_deg: float = 0.0,
) -> dict[str, Any]:
    comp = copy.deepcopy(tmpl)
    comp["id"] = cid
    comp["name"]["$value"] = name
    comp["mesh"]["DepotPath"]["$value"] = mesh_path
    comp["meshAppearance"]["$value"] = appearance
    comp["visualScale"]["X"] = scale[0]
    comp["visualScale"]["Y"] = scale[1]
    comp["visualScale"]["Z"] = scale[2]
    _set_pos_meters(comp, pos[0], pos[1], pos[2], yaw_deg=yaw_deg, pitch_deg=pitch_deg)
    return comp


def _make_light_comp(
    tmpl: dict[str, Any],
    cid: str,
    name: str,
    rgb: tuple[int, int, int],
    intensity: int,
    radius: float,
    pos: tuple[float, float, float],
    auto_hide: float = 95.0,
    is_enabled: int = 1,
) -> dict[str, Any]:
    comp = copy.deepcopy(tmpl)
    comp["id"] = cid
    comp["name"]["$value"] = name
    comp["isEnabled"] = int(is_enabled)
    comp["color"]["Red"] = rgb[0]
    comp["color"]["Green"] = rgb[1]
    comp["color"]["Blue"] = rgb[2]
    comp["color"]["Alpha"] = 255
    comp["intensity"] = intensity
    comp["radius"] = radius
    comp["autoHideDistance"] = auto_hide
    _set_pos_meters(comp, pos[0], pos[1], pos[2], yaw_deg=0.0)
    return comp


def _make_world_static_collider(
    name: str,
    cid: str,
    box_handle_id: str,
    filter_handle_id: str,
    half_extents: tuple[float, float, float],
    pos: tuple[float, float, float],
) -> tuple[dict[str, Any], dict[str, Any]]:
    chunk_col: dict[str, Any] = {
        "$type": "entColliderComponent",
        "colliders": [
            {
                "HandleId": box_handle_id,
                "Data": {
                    "$type": "physicsColliderBox",
                    "filterData": None,
                    "halfExtents": {
                        "$type": "Vector3",
                        "X": float(half_extents[0]),
                        "Y": float(half_extents[1]),
                        "Z": float(half_extents[2]),
                    },
                    "isImported": 0,
                    "isObstacle": 0,
                    "isQueryShapeOnly": 0,
                    "localToBody": {
                        "$type": "Transform",
                        "orientation": {"$type": "Quaternion", "i": 0, "j": 0, "k": 0, "r": 1},
                        "position": {"$type": "Vector4", "W": 0, "X": 0, "Y": 0, "Z": 0},
                    },
                    "material": {"$type": "CName", "$storage": "string", "$value": "None"},
                    "materialApperanceOverrides": [],
                    "tag": {"$type": "CName", "$storage": "string", "$value": "None"},
                    "volumeModifier": 1,
                },
            }
        ],
        "comOffset": {
            "$type": "Transform",
            "orientation": {"$type": "Quaternion", "i": 0, "j": 0, "k": 0, "r": 1},
            "position": {"$type": "Vector4", "W": 0, "X": 0, "Y": 0, "Z": 0},
        },
        "dynamicTrafficSetting": {"$type": "TrafficGenDynamicTrafficSetting", "impact": "Ignored"},
        "filterData": {
            "HandleId": filter_handle_id,
            "Data": {
                "$type": "physicsFilterData",
                "customFilterData": None,
                "preset": {"$type": "CName", "$storage": "string", "$value": "World Static"},
                "queryFilter": {"$type": "physicsQueryFilter", "mask1": "0", "mask2": "143769604"},
                "simulationFilter": {"$type": "physicsSimulationFilter", "mask1": "376836", "mask2": "5070"},
            },
        },
        "id": cid,
        "inertia": {"$type": "Vector3", "X": 1, "Y": 1, "Z": 1},
        "isEnabled": 1,
        "isReplicable": 0,
        "localTransform": {
            "$type": "WorldTransform",
            "Orientation": {"$type": "Quaternion", "i": 0, "j": 0, "k": 0, "r": 1},
            "Position": {
                "$type": "WorldPosition",
                "x": {"$type": "FixedPoint", "Bits": _meters_to_bits(pos[0])},
                "y": {"$type": "FixedPoint", "Bits": _meters_to_bits(pos[1])},
                "z": {"$type": "FixedPoint", "Bits": _meters_to_bits(pos[2])},
            },
        },
        "mass": 16000,
        "massOverride": -1,
        "name": {"$type": "CName", "$storage": "string", "$value": name},
        "parentTransform": None,
        "simulationType": "Kinematic",
        "startInactive": 0,
        "useCCD": 0,
        "volume": 0,
    }
    comp_col = copy.deepcopy(chunk_col)
    comp_col["colliders"] = [{"HandleRefId": box_handle_id}]
    comp_col["filterData"] = {"HandleRefId": filter_handle_id}
    return chunk_col, comp_col


def _build_ent_doc(
    base_tmpl: dict[str, Any],
    archive_file_name: str,
    chunk_comps: list[dict[str, Any]],
    root_comps: list[dict[str, Any]],
    meshes: list[str],
) -> dict[str, Any]:
    doc = copy.deepcopy(base_tmpl)
    doc["Header"]["ArchiveFileName"] = archive_file_name
    root = doc["Data"]["RootChunk"]
    game_obj = copy.deepcopy(root["compiledData"]["Data"]["Chunks"][0])
    root["entity"]["HandleId"] = "999"

    cruid_dict: dict[str, str] = {"0": "0"}
    chunks: list[dict[str, Any]] = [game_obj]
    for idx, comp in enumerate(chunk_comps, start=1):
        cruid_dict[str(idx)] = str(comp["id"])
        chunks.append(copy.deepcopy(comp))

    pkg = root["compiledData"]["Data"]
    pkg["CruidDict"] = cruid_dict
    pkg["Chunks"] = chunks
    root["components"] = copy.deepcopy(root_comps)
    root["resolvedDependencies"] = [
        {"DepotPath": {"$type": "ResourcePath", "$storage": "string", "$value": m}, "Flags": "Soft"}
        for m in sorted(set(meshes))
    ]
    return doc


def generate_all() -> None:
    if not WOLVENKIT_CLI.is_file():
        raise FileNotFoundError(f"WolvenKit.CLI.exe not found at {WOLVENKIT_CLI}")
    if not DONOR_CASE_ENT.is_file():
        raise FileNotFoundError(f"Donor entity template not found at {DONOR_CASE_ENT}")

    OUT_ENT_DIR.mkdir(parents=True, exist_ok=True)
    case_tmpl = json.loads(DONOR_CASE_ENT.read_text(encoding="utf-8"))
    base_mesh_tmpl = case_tmpl["Data"]["RootChunk"]["components"][0]
    base_light_tmpl = case_tmpl["Data"]["RootChunk"]["components"][2]

    specs: list[tuple[str, list[tuple[dict[str, Any], dict[str, Any]]], list[str]]] = []

    # 1. cv_esoterica_omen_altar.ent — Misty's Esoterica back-alley crimson ritual table
    omen_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    omen_items.append(_make_world_static_collider("cv_omen_table_col", "971000000000000200", "100", "200", (0.35, 0.35, 0.40), (0.0, 0.0, 0.40)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000201", "cv_omen_table", MESH_POOR_TABLE_B, "default", (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000202", "cv_omen_candle_stand", MESH_FUNERAL_STAND, "default", (-0.62, 0.12, 0.0), (0.95, 0.95, 0.95), yaw_deg=20.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000203", "cv_omen_candle_l", MESH_CANDLE_A, "default", (-0.24, 0.18, 0.800), (1.05, 1.05, 1.05), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000204", "cv_omen_candle_r", MESH_CANDLE_A, "default", (0.24, 0.18, 0.800), (1.05, 1.05, 1.05), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000205", "cv_omen_tarot_card", MESH_TAROT_SINGLE, "moon", (0.0, -0.06, 0.803), (1.45, 1.45, 1.45), yaw_deg=-16.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000206", "cv_omen_tarot_deck", MESH_TAROT_DECK, "default", (0.22, -0.14, 0.801), (1.15, 1.15, 1.15), yaw_deg=22.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000207", "cv_omen_dreamcatcher", MESH_DREAMCATCHER, "default", (-0.25, -0.18, 0.865), (1.30, 1.30, 1.30), yaw_deg=30.0),
        _make_light_comp(base_light_tmpl, "971000000000000208", "cv_omen_crimson_glow", (255, 45, 70), 240, 4.2, (0.0, -0.05, 1.32)),
        _make_light_comp(base_light_tmpl, "971000000000000209", "cv_omen_candle_warm", (255, 175, 85), 125, 2.8, (0.0, 0.10, 1.18)),
    ]:
        omen_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_esoterica_omen_altar.ent", omen_items, [MESH_POOR_TABLE_B, MESH_FUNERAL_STAND, MESH_CANDLE_A, MESH_TAROT_SINGLE, MESH_TAROT_DECK, MESH_DREAMCATCHER]))

    # 2. cv_rooftop_tarot_table.ent — Misty's Rooftop reading altar (bar counter top Z = 1.032)
    roof_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    roof_items.append(_make_world_static_collider("cv_roof_table_col", "971000000000000300", "101", "201", (0.38, 0.38, 0.515), (0.0, 0.0, 0.515)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000301", "cv_roof_table", MESH_POOR_TABLE_B, "default", (0.0, 0.0, 0.0), (1.08, 1.08, 1.29), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000302", "cv_roof_card_moon", MESH_TAROT_SINGLE, "moon", (-0.17, 0.02, 1.035), (1.45, 1.45, 1.45), yaw_deg=-16.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000303", "cv_roof_card_hangman", MESH_TAROT_SINGLE, "hangman_180", (0.00, 0.06, 1.036), (1.45, 1.45, 1.45), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000304", "cv_roof_card_tower", MESH_TAROT_SINGLE, "tower", (0.17, 0.02, 1.035), (1.45, 1.45, 1.45), yaw_deg=16.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000305", "cv_roof_card_deck", MESH_TAROT_DECK, "default", (-0.26, -0.13, 1.033), (1.00, 1.00, 1.00), yaw_deg=80.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000306", "cv_roof_candle_l", MESH_CANDLE_A, "default", (-0.34, -0.31, 1.032), (0.58, 0.58, 0.58)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000307", "cv_roof_candle_r", MESH_CANDLE_A, "default", (0.34, -0.31, 1.032), (0.58, 0.58, 0.58)),
        _make_light_comp(base_light_tmpl, "971000000000000309", "cv_roof_amber_glow", (255, 175, 95), 115, 3.8, (0.0, 0.0, 1.62)),
        _make_light_comp(base_light_tmpl, "971000000000000310", "cv_roof_crimson_rim", (220, 55, 80), 90, 2.8, (0.0, 0.22, 1.18)),
    ]:
        roof_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_rooftop_tarot_table.ent", roof_items, [MESH_POOR_TABLE_B, MESH_TAROT_SINGLE, MESH_TAROT_DECK, MESH_CANDLE_A]))

    # 3. cv_blood_shrine.ent — Northside Oilfields crime scene centerpiece + biomedical transfer table
    shrine_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    shrine_items.append(_make_world_static_collider("cv_shrine_stand_col", "971000000000000400", "102", "202", (0.28, 0.28, 0.68), (0.0, 0.0, 0.68)))
    shrine_items.append(_make_world_static_collider("cv_shrine_med_col", "971000000000000409", "109", "209", (0.38, 0.38, 0.40), (0.95, 0.20, 0.40)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000401", "cv_shrine_iv_stand", MESH_IV_STAND, "default", (0.0, 0.0, 0.0), (1.05, 1.05, 1.05), yaw_deg=20.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000402", "cv_shrine_blood_drip", MESH_BLOOD_DRIP, "default", (0.14, 0.0, 1.12), (1.45, 1.45, 1.45), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000403", "cv_shrine_candle_stand", MESH_FUNERAL_STAND, "default", (-0.75, 0.35, 0.0), (1.0, 1.0, 1.0), yaw_deg=-25.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000404", "cv_shrine_candle_a", MESH_CANDLE_A, "default", (0.55, -0.35, 0.0), (1.25, 1.25, 1.25)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000405", "cv_shrine_candle_b", MESH_CANDLE_A, "default", (-0.42, -0.45, 0.0), (1.20, 1.20, 1.20)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000406", "cv_shrine_tarot_death", MESH_TAROT_SINGLE, "death", (0.30, -0.38, 0.005), (1.60, 1.60, 1.60), yaw_deg=14.0),
        _make_light_comp(base_light_tmpl, "971000000000000407", "cv_shrine_blood_beacon", (255, 32, 48), 245, 5.5, (0.0, 0.0, 1.45)),
        _make_light_comp(base_light_tmpl, "971000000000000408", "cv_shrine_candle_fill", (255, 130, 60), 120, 3.2, (-0.35, -0.15, 0.65)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000410", "cv_shrine_med_table", MESH_POOR_TABLE_B, "default", (0.95, 0.20, 0.0), (1.0, 1.0, 1.0), yaw_deg=-20.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000411", "cv_shrine_med_case_a", MESH_CYBERWARE_POD, "default", (0.84, 0.16, 0.802), (0.95, 0.95, 0.95), yaw_deg=-15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000412", "cv_shrine_med_case_b", MESH_CYBERWARE_POD, "default", (1.25, -0.35, 0.0), (1.05, 1.05, 1.05), yaw_deg=18.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000413", "cv_shrine_transfer_slip", MESH_SHARD, "default", (1.12, 0.28, 0.803), (1.35, 1.35, 1.35), yaw_deg=24.0),
        _make_light_comp(base_light_tmpl, "971000000000000414", "cv_shrine_med_glow", (120, 225, 255), 95, 2.6, (0.95, 0.20, 1.28)),
    ]:
        shrine_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_blood_shrine.ent", shrine_items, [MESH_IV_STAND, MESH_BLOOD_DRIP, MESH_FUNERAL_STAND, MESH_CANDLE_A, MESH_TAROT_SINGLE, MESH_POOR_TABLE_B, MESH_CYBERWARE_POD, MESH_SHARD]))

    # 4. cv_uv_emitter.ent — Northside Oilfields UV tactical floodlight
    uv_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    uv_items.append(_make_world_static_collider("cv_uv_pedestal_col", "971000000000000500", "103", "203", (0.22, 0.22, 0.56), (0.0, 0.0, 0.56)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000501", "cv_uv_pedestal", MESH_ELEC_BOX_H, "black", (0.0, 0.0, 0.0), (1.05, 1.05, 1.00)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000502", "cv_uv_mount", MESH_SPOTLIGHT_MOUNT, "default", (0.0, 0.0, 1.10), (1.15, 1.15, 1.15)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000503", "cv_uv_lamp_head", MESH_SPOTLIGHT_A, "cyan_bright", (0.0, 0.0, 1.38), (1.25, 1.25, 1.25), yaw_deg=-35.0),
        _make_light_comp(base_light_tmpl, "971000000000000504", "cv_uv_violet_glow", (145, 85, 255), 290, 7.0, (0.0, 0.0, 1.60)),
        _make_light_comp(base_light_tmpl, "971000000000000505", "cv_uv_core_cyan", (110, 195, 255), 145, 3.6, (0.0, 0.0, 1.42)),
        _make_light_comp(base_light_tmpl, "971000000000000506", "cv_uv_overload_flash", (190, 130, 255), 2400, 24.0, (0.0, 0.0, 1.72), is_enabled=0),
    ]:
        uv_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_uv_emitter.ent", uv_items, [MESH_ELEC_BOX_H, MESH_SPOTLIGHT_MOUNT, MESH_SPOTLIGHT_A]))

    # 5. cv_a1_cryo_cooler.ent — Kabuki Canal cryogenic blood discard station
    cooler_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    cooler_items.append(_make_world_static_collider("cv_a1_cooler_col", "971000000000000600", "104", "204", (0.35, 0.35, 0.40), (0.0, 0.0, 0.40)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000601", "cv_a1_cooler_table", MESH_POOR_TABLE_B, "default", (0.0, 0.0, 0.0), (1.0, 1.0, 1.0)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000602", "cv_a1_cooler_pod", MESH_CYBERWARE_POD, "default", (-0.06, 0.04, 0.802), (1.0, 1.0, 1.0), yaw_deg=14.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000603", "cv_a1_cooler_iv", MESH_IV_STAND, "default", (-0.56, -0.18, 0.0), (1.0, 1.0, 1.0), yaw_deg=-25.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000604", "cv_a1_cooler_drip", MESH_BLOOD_DRIP, "default", (-0.42, -0.18, 1.12), (1.35, 1.35, 1.35)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000605", "cv_a1_cooler_candle", MESH_CANDLE_A, "default", (0.28, -0.16, 0.800), (1.0, 1.0, 1.0)),
        _make_light_comp(base_light_tmpl, "971000000000000606", "cv_a1_cooler_light", (255, 42, 68), 210, 4.4, (0.0, 0.0, 1.35)),
    ]:
        cooler_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a1_cryo_cooler.ent", cooler_items, [MESH_POOR_TABLE_B, MESH_CYBERWARE_POD, MESH_IV_STAND, MESH_BLOOD_DRIP, MESH_CANDLE_A]))

    # 6. cv_a1_tarot_shrine.ent — Kabuki Canal inverted High Priestess seal
    kshrine_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    kshrine_items.append(_make_world_static_collider("cv_a1_tarot_col", "971000000000000610", "105", "205", (0.26, 0.26, 0.28), (0.0, 0.0, 0.28)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000611", "cv_a1_tarot_stand", MESH_FUNERAL_STAND, "default", (0.0, 0.0, 0.0), (1.05, 1.05, 1.05), yaw_deg=15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000612", "cv_a1_tarot_candle_l", MESH_CANDLE_A, "default", (-0.36, -0.22, 0.0), (1.2, 1.2, 1.2)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000613", "cv_a1_tarot_candle_r", MESH_CANDLE_A, "default", (0.36, 0.18, 0.0), (1.15, 1.15, 1.15)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000614", "cv_a1_tarot_priestess", MESH_TAROT_SINGLE, "priestess_180", (0.05, -0.35, 0.006), (1.65, 1.65, 1.65), yaw_deg=-22.0),
        _make_light_comp(base_light_tmpl, "971000000000000615", "cv_a1_tarot_glow", (255, 145, 70), 170, 3.8, (0.0, -0.1, 0.92)),
    ]:
        kshrine_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a1_tarot_shrine.ent", kshrine_items, [MESH_FUNERAL_STAND, MESH_CANDLE_A, MESH_TAROT_SINGLE]))

    # 7. cv_a1_relay_pad.ent — Kabuki Canal Biotechnica telemetry relay console
    relay_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    relay_items.append(_make_world_static_collider("cv_a1_relay_col", "971000000000000620", "106", "206", (0.50, 0.30, 0.65), (0.0, 0.0, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000621", "cv_a1_relay_term", MESH_TERMINAL_ENTROPY, "clean_a", (0.0, 0.0, 0.0), (0.92, 0.92, 0.92)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000622", "cv_a1_relay_deck_base", MESH_CYBERDECK_BASE, "cyberspace", (-0.18, -0.08, 0.94), (1.1, 1.1, 1.1), yaw_deg=12.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000623", "cv_a1_relay_deck_scr", MESH_CYBERDECK_SCREEN, "cyberspace", (-0.18, -0.02, 0.97), (1.1, 1.1, 1.1), yaw_deg=12.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000624", "cv_a1_relay_shard", MESH_SHARD, "default", (0.16, -0.10, 0.94), (1.35, 1.35, 1.35), yaw_deg=-18.0),
        _make_light_comp(base_light_tmpl, "971000000000000625", "cv_a1_relay_cyan", (75, 215, 255), 185, 3.8, (0.0, -0.15, 1.48)),
    ]:
        relay_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a1_relay_pad.ent", relay_items, [MESH_TERMINAL_ENTROPY, MESH_CYBERDECK_BASE, MESH_CYBERDECK_SCREEN, MESH_SHARD]))

    # 8. cv_a1_valdes_desk.ent — Dr. Valdes cluttered field workstation in Little China
    vdesk_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    vdesk_items.append(_make_world_static_collider("cv_a1_vdesk_col", "971000000000000630", "107", "207", (0.35, 0.35, 0.40), (0.0, 0.0, 0.40)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000631", "cv_a1_vdesk_table", MESH_POOR_TABLE_B, "default", (0.0, 0.0, 0.0), (1.0, 1.0, 1.0)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000632", "cv_a1_vdesk_med", MESH_CYBERWARE_POD, "default", (-0.16, 0.12, 0.802), (0.85, 0.85, 0.85), yaw_deg=18.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000633", "cv_a1_vdesk_deck", MESH_TAROT_DECK, "default", (0.18, -0.12, 0.801), (1.15, 1.15, 1.15), yaw_deg=-25.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000634", "cv_a1_vdesk_candle", MESH_CANDLE_A, "default", (0.24, 0.20, 0.800), (1.0, 1.0, 1.0)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000636", "cv_a1_vdesk_cipher", MESH_SHARD, "default", (-0.02, -0.18, 0.802), (1.35, 1.35, 1.35), yaw_deg=-14.0),
        _make_light_comp(base_light_tmpl, "971000000000000635", "cv_a1_vdesk_warm", (255, 180, 95), 165, 3.6, (0.0, 0.0, 1.28)),
        _make_light_comp(base_light_tmpl, "971000000000000637", "cv_a1_vdesk_cyan", (70, 215, 255), 95, 2.4, (-0.02, -0.18, 1.05)),
    ]:
        vdesk_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a1_valdes_desk.ent", vdesk_items, [MESH_POOR_TABLE_B, MESH_CYBERWARE_POD, MESH_TAROT_DECK, MESH_CANDLE_A, MESH_SHARD]))

    # 9. cv_a1_cryo_vault_terminal.ent — West Pier NOX-9 cryo-vault terminal & blood machine
    vault_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    vault_items.append(_make_world_static_collider("cv_a1_vault_col", "971000000000000640", "108", "208", (0.50, 0.30, 0.65), (0.0, 0.0, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000641", "cv_a1_vault_term", MESH_TERMINAL_NEOMIL, "clean_a", (0.0, 0.0, 0.0), (1.0, 1.0, 1.0)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000642", "cv_a1_vault_iv", MESH_IV_STAND, "default", (-0.90, -0.20, 0.0), (1.05, 1.05, 1.05), yaw_deg=15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000643", "cv_a1_vault_drip", MESH_BLOOD_DRIP, "default", (-0.76, -0.20, 1.14), (1.45, 1.45, 1.45)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000644", "cv_a1_vault_stand", MESH_FUNERAL_STAND, "default", (0.95, -0.25, 0.0), (1.0, 1.0, 1.0), yaw_deg=-20.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000645", "cv_a1_vault_devil", MESH_TAROT_SINGLE, "devil", (0.35, 0.45, 0.005), (1.6, 1.6, 1.6), yaw_deg=10.0),
        _make_light_comp(base_light_tmpl, "971000000000000646", "cv_a1_vault_crimson", (255, 38, 60), 235, 5.2, (-0.1, -0.1, 1.55)),
        _make_light_comp(base_light_tmpl, "971000000000000647", "cv_a1_vault_violet", (155, 95, 255), 140, 3.8, (0.3, -0.1, 1.38)),
    ]:
        vault_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a1_cryo_vault_terminal.ent", vault_items, [MESH_TERMINAL_NEOMIL, MESH_IV_STAND, MESH_BLOOD_DRIP, MESH_FUNERAL_STAND, MESH_TAROT_SINGLE]))

    # 10. cv_holo_record_lights.ent — Studio key & rim portrait lights for Holocall video recording (0 colliders)
    rec_lights_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    for c in [
        _make_light_comp(base_light_tmpl, "971000000000000701", "cv_rec_key_light", (255, 224, 196), 125, 3.8, (0.42, 0.92, 1.78)),
        _make_light_comp(base_light_tmpl, "971000000000000702", "cv_rec_rim_light", (185, 95, 225), 85, 3.4, (-0.62, -0.35, 1.72)),
    ]:
        rec_lights_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_holo_record_lights.ent", rec_lights_items, []))

    # 11. cv_a2_convoy_pod.ent — Biotechnica Flats abandoned NOX-9 convoy cryo-pod drop
    a2_pod_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    a2_pod_items.append(_make_world_static_collider("cv_a2_pod_col", "971000000000000800", "110", "210", (0.38, 0.38, 0.42), (0.0, 0.0, 0.42)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000801", "cv_a2_pod_table", MESH_POOR_TABLE_B, "default", (0.0, 0.0, 0.0), (1.05, 1.05, 1.0)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000802", "cv_a2_pod_case_a", MESH_CYBERWARE_POD, "default", (-0.20, 0.05, 0.802), (1.0, 1.0, 1.0), yaw_deg=12.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000803", "cv_a2_pod_case_b", MESH_CYBERWARE_POD, "default", (0.24, -0.10, 0.802), (0.92, 0.92, 0.92), yaw_deg=-24.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000804", "cv_a2_pod_iv", MESH_IV_STAND, "default", (-0.68, -0.22, 0.0), (1.0, 1.0, 1.0), yaw_deg=-15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000805", "cv_a2_pod_drip", MESH_BLOOD_DRIP, "default", (-0.54, -0.22, 1.12), (1.35, 1.35, 1.35)),
        _make_light_comp(base_light_tmpl, "971000000000000806", "cv_a2_pod_crimson", (255, 40, 68), 220, 4.8, (0.0, 0.0, 1.40)),
    ]:
        a2_pod_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_convoy_pod.ent", a2_pod_items, [MESH_POOR_TABLE_B, MESH_CYBERWARE_POD, MESH_IV_STAND, MESH_BLOOD_DRIP]))

    # 12. cv_a2_mateo_shrine.ent — Biotechnica Flats Mateo (M-09) memorial marker & shard
    a2_mateo_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    a2_mateo_items.append(_make_world_static_collider("cv_a2_mateo_col", "971000000000000820", "111", "211", (0.28, 0.28, 0.30), (0.0, 0.0, 0.30)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000821", "cv_a2_mateo_stand", MESH_FUNERAL_STAND, "default", (0.0, 0.0, 0.0), (1.05, 1.05, 1.05), yaw_deg=18.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000822", "cv_a2_mateo_candle_l", MESH_CANDLE_A, "default", (-0.36, -0.18, 0.0), (1.2, 1.2, 1.2)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000823", "cv_a2_mateo_candle_r", MESH_CANDLE_A, "default", (0.36, 0.14, 0.0), (1.15, 1.15, 1.15)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000824", "cv_a2_mateo_moon", MESH_TAROT_SINGLE, "moon", (-0.08, -0.32, 0.006), (1.65, 1.65, 1.65), yaw_deg=-15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000825", "cv_a2_mateo_shard", MESH_SHARD, "default", (0.16, -0.30, 0.008), (1.45, 1.45, 1.45), yaw_deg=22.0),
        _make_light_comp(base_light_tmpl, "971000000000000826", "cv_a2_mateo_amber", (255, 150, 75), 175, 4.0, (0.0, -0.12, 0.96)),
        _make_light_comp(base_light_tmpl, "971000000000000827", "cv_a2_mateo_crimson", (245, 45, 70), 120, 3.2, (0.0, -0.15, 0.55)),
    ]:
        a2_mateo_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_mateo_shrine.ent", a2_mateo_items, [MESH_FUNERAL_STAND, MESH_CANDLE_A, MESH_TAROT_SINGLE, MESH_SHARD]))

    # 13. cv_a2_desert_relay.ent — Biotechnica Flats microwave bunker relay beacon
    a2_relay_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    a2_relay_items.append(_make_world_static_collider("cv_a2_relay_col", "971000000000000840", "112", "212", (0.50, 0.30, 0.65), (0.0, 0.0, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000841", "cv_a2_relay_term", MESH_TERMINAL_ENTROPY, "clean_a", (0.0, 0.0, 0.0), (0.96, 0.96, 0.96)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000842", "cv_a2_relay_deck_base", MESH_CYBERDECK_BASE, "cyberspace", (-0.18, -0.06, 0.94), (1.1, 1.1, 1.1), yaw_deg=10.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000843", "cv_a2_relay_deck_scr", MESH_CYBERDECK_SCREEN, "cyberspace", (-0.18, 0.00, 0.97), (1.1, 1.1, 1.1), yaw_deg=10.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000844", "cv_a2_relay_shard", MESH_SHARD, "default", (0.18, -0.08, 0.94), (1.35, 1.35, 1.35), yaw_deg=-20.0),
        _make_light_comp(base_light_tmpl, "971000000000000845", "cv_a2_relay_cyan", (75, 220, 255), 195, 4.2, (0.0, -0.15, 1.50)),
    ]:
        a2_relay_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_desert_relay.ent", a2_relay_items, [MESH_TERMINAL_ENTROPY, MESH_CYBERDECK_BASE, MESH_CYBERDECK_SCREEN, MESH_SHARD]))

    # 14. cv_a2_nox9b_chamber.ent — Helena Solis Badlands bunker NOX-9B bioreactor & control console
    a2_core_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    a2_core_items.append(_make_world_static_collider("cv_a2_core_mach_col", "971000000000000860", "113", "213", (0.60, 0.45, 0.75), (0.0, -0.75, 0.75)))
    a2_core_items.append(_make_world_static_collider("cv_a2_core_term_col", "971000000000000861", "114", "214", (0.50, 0.30, 0.65), (0.0, 0.35, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000862", "cv_a2_core_machine", MESH_SURGICAL_MACHINE, "default", (0.0, -0.75, 0.0), (1.05, 1.05, 1.05), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000863", "cv_a2_core_terminal", MESH_TERMINAL_NEOMIL, "clean_a", (0.0, 0.35, 0.0), (1.0, 1.0, 1.0), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000864", "cv_a2_core_pod_l", MESH_CYBERWARE_POD, "default", (-0.95, -0.35, 0.0), (1.15, 1.15, 1.15), yaw_deg=25.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000865", "cv_a2_core_pod_r", MESH_CYBERWARE_POD, "default", (0.95, -0.35, 0.0), (1.15, 1.15, 1.15), yaw_deg=-25.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000866", "cv_a2_core_iv", MESH_IV_STAND, "default", (-1.15, -0.95, 0.0), (1.08, 1.08, 1.08), yaw_deg=15.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000867", "cv_a2_core_drip", MESH_BLOOD_DRIP, "default", (-1.01, -0.95, 1.16), (1.45, 1.45, 1.45)),
        _make_light_comp(base_light_tmpl, "971000000000000868", "cv_a2_core_crimson", (255, 36, 60), 280, 6.2, (0.0, -0.55, 1.75)),
        _make_light_comp(base_light_tmpl, "971000000000000869", "cv_a2_core_violet", (165, 95, 255), 185, 4.8, (0.0, 0.35, 1.48)),
    ]:
        a2_core_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_nox9b_chamber.ent", a2_core_items, [MESH_SURGICAL_MACHINE, MESH_TERMINAL_NEOMIL, MESH_CYBERWARE_POD, MESH_IV_STAND, MESH_BLOOD_DRIP]))

    # 15. cv_a2_bunker_hatch.ent — Ground-flush horizontal steel bunker trapdoor + access terminal + biotech case
    hatch_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    hatch_items.append(_make_world_static_collider("cv_a2_hatch_curb_col", "971000000000000880", "115", "215", (0.95, 1.10, 0.06), (0.0, 0.0, 0.06)))
    hatch_items.append(_make_world_static_collider("cv_a2_hatch_term_col", "971000000000000881", "116", "216", (0.48, 0.28, 0.65), (1.15, 0.0, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000882", "cv_a2_hatch_leaf", MESH_DOOR_SLIDING_C, "bare_rusty", (0.0, 1.20, 0.11), (1.0, 1.0, 1.0), yaw_deg=0.0, pitch_deg=90.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000883", "cv_a2_hatch_casing", MESH_DOOR_CASING_A, "default", (0.0, 1.20, 0.08), (1.0, 1.0, 1.0), yaw_deg=0.0, pitch_deg=90.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000884", "cv_a2_hatch_frame", MESH_DOOR_FRAME_A, "default", (0.0, 1.20, 0.08), (1.0, 1.0, 1.0), yaw_deg=0.0, pitch_deg=90.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000885", "cv_a2_hatch_terminal", MESH_TERMINAL_NEOMIL, "clean_a", (1.15, 0.0, 0.0), (1.0, 1.0, 1.0), yaw_deg=-20.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000886", "cv_a2_hatch_case", MESH_CYBERWARE_POD, "default", (-1.15, 0.15, 0.0), (1.0, 1.0, 1.0), yaw_deg=18.0),
        _make_light_comp(base_light_tmpl, "971000000000000888", "cv_a2_hatch_crimson", (255, 32, 55), 240, 5.2, (0.0, 0.0, 0.55)),
        _make_light_comp(base_light_tmpl, "971000000000000889", "cv_a2_hatch_violet", (160, 80, 255), 165, 4.0, (1.15, -0.15, 1.45)),
    ]:
        hatch_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_bunker_hatch.ent", hatch_items, [MESH_DOOR_SLIDING_C, MESH_DOOR_CASING_A, MESH_DOOR_FRAME_A, MESH_TERMINAL_NEOMIL, MESH_CYBERWARE_POD]))

    # 16. cv_a2_seal_relay.ent — Cryogenic security lock relay console + IV blood stand
    seal_items: list[tuple[dict[str, Any], dict[str, Any]]] = []
    seal_items.append(_make_world_static_collider("cv_a2_seal_col", "971000000000000900", "117", "217", (0.50, 0.30, 0.65), (0.0, 0.0, 0.65)))
    for c in [
        _make_mesh_comp(base_mesh_tmpl, "971000000000000901", "cv_a2_seal_term", MESH_TERMINAL_NEOMIL, "clean_a", (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), yaw_deg=0.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000902", "cv_a2_seal_iv", MESH_IV_STAND, "default", (-0.85, -0.15, 0.0), (1.05, 1.05, 1.05), yaw_deg=18.0),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000903", "cv_a2_seal_drip", MESH_BLOOD_DRIP, "default", (-0.71, -0.15, 1.14), (1.40, 1.40, 1.40)),
        _make_mesh_comp(base_mesh_tmpl, "971000000000000904", "cv_a2_seal_pod", MESH_CYBERWARE_POD, "default", (0.85, -0.18, 0.0), (0.95, 0.95, 0.95), yaw_deg=-20.0),
        _make_light_comp(base_light_tmpl, "971000000000000905", "cv_a2_seal_crimson", (255, 32, 55), 255, 5.4, (0.0, -0.10, 1.45)),
        _make_light_comp(base_light_tmpl, "971000000000000906", "cv_a2_seal_violet", (160, 80, 255), 165, 4.2, (0.25, 0.0, 1.25)),
    ]:
        seal_items.append((c, copy.deepcopy(c)))
    specs.append(("cv_a2_seal_relay.ent", seal_items, [MESH_TERMINAL_NEOMIL, MESH_IV_STAND, MESH_BLOOD_DRIP, MESH_CYBERWARE_POD]))

    written_jsons: list[Path] = []
    for ent_name, pairs, meshes in specs:
        chunk_comps = [p[0] for p in pairs]
        root_comps = [p[1] for p in pairs]
        doc = _build_ent_doc(
            case_tmpl,
            f"crimson_veil\\entities\\{ent_name}",
            chunk_comps,
            root_comps,
            meshes,
        )
        txt = json.dumps(doc, indent=2, ensure_ascii=False)
        if re.search(r'(?:^|["\\/])ep1[\\/]', txt, re.I):
            raise RuntimeError(f"Forbidden ep1\\ archive reference in {ent_name}")
        out_path = OUT_ENT_DIR / f"{ent_name}.json"
        out_path.write_text(txt, encoding="utf-8")
        written_jsons.append(out_path)

    print(f"[INFO] Verifying CR2W roundtrip deserialize+serialize on {len(written_jsons)} prop entities...")
    with tempfile.TemporaryDirectory(prefix="cv_ent_rt_") as rt:
        rt_dir = Path(rt)
        for jp in written_jsons:
            bin_name = jp.name[:-5]
            _run_wkit(["convert", "deserialize", str(jp), "-o", str(rt_dir)])
            bin_file = rt_dir / bin_name
            if not bin_file.is_file() or bin_file.stat().st_size < 32:
                raise RuntimeError(f"Deserialized binary empty for {jp.name}")
            _run_wkit(["convert", "serialize", str(bin_file), "-o", str(rt_dir)])
            rt_json = rt_dir / jp.name
            if not rt_json.is_file():
                raise RuntimeError(f"Roundtrip serialize failed for {jp.name}")
            rt_rc = json.loads(rt_json.read_text(encoding="utf-8"))["Data"]["RootChunk"]
            print(f"  [OK] {jp.name}: comps={len(rt_rc.get('components', []))} size={bin_file.stat().st_size}B")


if __name__ == "__main__":
    try:
        generate_all()
        print("[DONE] All Crimson Veil prop entities verified (0 ep1).")
    except Exception as exc:
        print(f"[ERROR] {exc}", file=sys.stderr)
        sys.exit(1)
