// Velo Carmesí / Crimson Veil — Sistema de Regeneración Hematológica y Emisor UV
module CrimsonVeil

public class VampyreCombatController {
    private let m_sys: wref<CrimsonVeilSystem>;
    private let m_uvSuppressUntil: Float;
    private let m_uvCooldownUntil: Float;
    private let m_uvTowerACooldownUntil: Float;
    private let m_uvTowerBCooldownUntil: Float;
    private let m_uvFlashUntil: Float;
    private let m_lastRegenAt: Float;
    private let m_hintPlayed: Bool;
    private let m_dayHintShown: Bool;

    public final func Initialize(sys: ref<CrimsonVeilSystem>) -> Void {
        this.m_sys = sys;
        this.ResetCombatTimers();
    }

    public final func ResetCombatTimers() -> Void {
        this.m_uvSuppressUntil = -10.00;
        this.m_uvCooldownUntil = -10.00;
        this.m_uvTowerACooldownUntil = -10.00;
        this.m_uvTowerBCooldownUntil = -10.00;
        this.m_uvFlashUntil = -10.00;
        this.m_lastRegenAt = -10.00;
        this.m_hintPlayed = false;
        this.m_dayHintShown = false;
    }

    public final func IsUvOnCooldown(nowSim: Float) -> Bool {
        return nowSim < this.m_uvCooldownUntil;
    }

    public final func IsUvFlashActive(nowSim: Float) -> Bool {
        return nowSim < this.m_uvFlashUntil;
    }

    public final func GetRemainingCooldownSeconds(nowSim: Float) -> Int32 {
        if nowSim >= this.m_uvCooldownUntil {
            return 0;
        }
        return Cast<Int32>(this.m_uvCooldownUntil - nowSim) + 1;
    }

    public final func IsUvTowerOnCooldown(towerSlot: Int32, nowSim: Float) -> Bool {
        let cdUntil: Float = (towerSlot == 2) ? this.m_uvTowerBCooldownUntil : this.m_uvTowerACooldownUntil;
        return nowSim < cdUntil;
    }

    public final func GetUvTowerCooldownSeconds(towerSlot: Int32, nowSim: Float) -> Int32 {
        let cdUntil: Float = (towerSlot == 2) ? this.m_uvTowerBCooldownUntil : this.m_uvTowerACooldownUntil;
        if nowSim >= cdUntil {
            return 0;
        }
        return Cast<Int32>(cdUntil - nowSim) + 1;
    }

    public final func TriggerUvDiagnosticPulse(player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) {
            return;
        }
        this.m_sys.PlaySfx(n"cv_sfx_uv_overload");
        this.m_sys.ShowRelicBanner(n"cv_banner_uv_ready", "[EMISOR UV LISTO] Condensador 365 nm armado — Examina el Altar de Sangre y úsalo cuando ataquen");
    }

    public final func TriggerUvOverload(player: ref<PlayerPuppet>, emitterPos: Vector4, scoutAId: EntityID, scoutBId: EntityID) -> Void {
        let ids: array<EntityID> = [scoutAId, scoutBId];
        this.TriggerUvOverloadSquad(player, emitterPos, ids, 0);
    }

    public final func TriggerUvOverloadSquad(player: ref<PlayerPuppet>, emitterPos: Vector4, squadIds: array<EntityID>, towerSlot: Int32) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_uvSuppressUntil = nowSim + 14.00;
        this.m_uvFlashUntil = nowSim + 2.20;
        if towerSlot == 1 {
            this.m_uvTowerACooldownUntil = nowSim + 20.00;
        } else if towerSlot == 2 {
            this.m_uvTowerBCooldownUntil = nowSim + 20.00;
        } else {
            this.m_uvCooldownUntil = nowSim + 22.00;
        }
        this.m_sys.PlaySfx(n"cv_sfx_uv_overload");

        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
        let pId: EntityID = player.GetEntityID();
        let hitCount: Int32 = 0;

        for eid in squadIds {
            if EntityID.IsDefined(eid) && IsDefined(des) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) && !npc.IsDead() && !ScriptedPuppet.IsDefeated(npc) && !ScriptedPuppet.IsUnconscious(npc) {
                    if this.m_sys.ComputeDistanceSq(npc.GetWorldPosition(), emitterPos) <= 576.00 {
                        hitCount += 1;
                        StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.Blind", pId);
                        StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.EMP", pId);
                        StatusEffectHelper.ApplyStatusEffect(npc, t"BaseStatusEffect.Burning", pId);
                        if IsDefined(sps) {
                            sps.RequestChangingStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, -35.00, player, false, true);
                        }
                        this.m_sys.MakeNpcHostile(npc, player);
                    }
                }
            }
        }

        if hitCount > 0 {
            this.m_sys.ShowRelicBanner(n"cv_banner_uv_overload", "[EMISOR UV] Porfiria fotosensible expuesta — Regeneración anulada (14 s)");
        } else {
            this.m_sys.ShowRelicBanner(n"cv_banner_uv_miss", "[EMISOR UV] Pulso 365 nm disparado — Atrae a los Vampyres más cerca de la torre (24 m)");
        }
    }

    public final func TickVampyreRegen(player: ref<PlayerPuppet>, shrinePos: Vector4, scoutAId: EntityID, scoutBId: EntityID) -> Void {
        let ids: array<EntityID> = [scoutAId, scoutBId];
        let isDay: Bool = IsDefined(this.m_sys) && this.m_sys.IsDaytimeNow();
        this.TickVampyreSquadRegen(player, shrinePos, ids, isDay);
    }

    public final func TickVampyreSquadRegen(player: ref<PlayerPuppet>, anchorPos: Vector4, squadIds: array<EntityID>, isDaytime: Bool) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        if isDaytime {
            if !this.m_dayHintShown {
                this.m_dayHintShown = true;
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_daylight", "[LUZ DIURNA] La luz solar debilita al Coro Pálido y bloquea su regeneración");
            }
            return;
        }
        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        if nowSim < this.m_uvSuppressUntil {
            return;
        }
        if (nowSim - this.m_lastRegenAt) < 1.00 {
            return;
        }
        this.m_lastRegenAt = nowSim;

        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
        if !IsDefined(des) || !IsDefined(sps) {
            return;
        }

        let didHealAny: Bool = false;
        for eid in squadIds {
            if !this.m_sys.IsNpcNeutralized(eid, anchorPos, 2.00) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) {
                    let hp: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, true);
                    if hp > 2.00 && hp < 96.00 {
                        sps.RequestChangingStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, 2.75, npc, false, true);
                        didHealAny = true;
                    }
                }
            }
        }

        if didHealAny && !this.m_hintPlayed {
            let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
            if !IsDefined(qs) || qs.GetFact(n"cv_p0_uv_hint_shown") == 0 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_p0_uv_hint_shown", 1);
                }
                this.m_hintPlayed = true;
                this.m_sys.ShowRelicBanner(n"cv_banner_uv_hint", "[TÁCTICO] Regeneración hematológica detectada — ¡Sobrecarga el Emisor UV cercano!");
                if !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_p0_v_uv_hint", n"v_narr", n"V", scnDialogLineType.Regular, 6.68));
                    this.m_sys.StartSpeechSequence(steps, 0);
                }
            }
        }
    }
}
