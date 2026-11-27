// ---------------------------------------------------------------------------
// Velo Carmesí / Crimson Veil — Prólogo Reiniciado (v0.5.0: La Luna Manchada)
// Flujo claro y narrativo:
//   0  -> Llamada entrante nativa de Misty (cv_misty) en Watson
//   5  -> En llamada: Misty pide ayuda (amigas desaparecidas + altar + carta)
//   10 -> Callejón trasero de Esoterica: Misty pide no tocar y escanear primero
//   15 -> Escaneo Kiroshi (porfirinas + Lucía) + Ronda de preguntas sobre Mateo y Coro Pálido
//   20 -> Cita a las 22:00 en la azotea de Esoterica (Tirada Tarot + pista UV 365 nm)
//   30 -> Depósitos Petrolíferos de Northside (Emisor UV + Escolta del Coro Pálido)
//   40 -> Recibo rasgado (Sujeto L-14, Lucía sigue viva) + vial vacío NOX-9
//   50 -> Regreso a la azotea con Misty: entrega de pruebas y cierre del Prólogo (+Velo Silente)
//   60 -> Prólogo completado (listo para el futuro Acto I: Dr. Adrián Valdés)
// 100% Base Game 2.x (0 ep1)
// ---------------------------------------------------------------------------

module CrimsonVeil

public class CrimsonVeilAct00Handler extends IScriptable {
    private let m_sys: wref<CrimsonVeilSystem>;

    // Escenario callejón trasero de Esoterica (Alley Misty separada de Rooftop Misty — CP77-EP-030)
    private let m_omenAltarId: EntityID;
    private let m_alleyMistyId: EntityID;
    private let m_alleyWsAnchorId: EntityID;
    private let m_alleyWarnedOnce: Bool;

    // Escenario azotea de Esoterica (Misty + mesa de Tarot)
    private let m_rooftopTableId: EntityID;
    private let m_mistyId: EntityID;
    private let m_mistyWsAnchorId: EntityID;

    // Escenario Depósitos Petrolíferos de Northside
    private let m_oilShrineId: EntityID;
    private let m_uvEmitterId: EntityID;
    private let m_scoutAId: EntityID;
    private let m_scoutBId: EntityID;
    private let m_scoutASpawned: Bool;
    private let m_scoutBSpawned: Bool;
    private let m_oilAmbushTriggered: Bool;
    private let m_oilAmbushTime: Float;
    private let m_oilIntroPlayed: Bool;
    private let m_oilClearBannerShown: Bool;

    // Caché de suelo y sincronización
    private let m_esotericaPosCached: Bool;
    private let m_esotericaAltarPos: Vector4;
    private let m_alleyMistyPosCached: Bool;
    private let m_alleyMistyPos: Vector4;
    private let m_oilShrinePosCached: Bool;
    private let m_oilShrinePos: Vector4;
    private let m_uvEmitterPosCached: Bool;
    private let m_uvEmitterPos: Vector4;
    private let m_lastSyncedStage: Int32;
    private let m_callAttempted: Bool;
    private let m_callReadyTicks: Int32;

    public final func Initialize(sys: ref<CrimsonVeilSystem>) -> Void {
        this.m_sys = sys;
        this.m_lastSyncedStage = -1;
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
    }

    public final func ResetPendingPrologueCallForRetry() -> Void {
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
    }

    public final func OnSaveRestored() -> Void {
        this.m_omenAltarId = new EntityID();
        this.m_alleyMistyId = new EntityID();
        this.m_alleyWsAnchorId = new EntityID();
        this.m_alleyWarnedOnce = false;
        this.m_rooftopTableId = new EntityID();
        this.m_mistyId = new EntityID();
        this.m_mistyWsAnchorId = new EntityID();
        this.m_oilShrineId = new EntityID();
        this.m_uvEmitterId = new EntityID();
        this.m_scoutAId = new EntityID();
        this.m_scoutBId = new EntityID();
        this.m_scoutASpawned = false;
        this.m_scoutBSpawned = false;
        this.m_oilAmbushTriggered = false;
        this.m_oilIntroPlayed = false;
        this.m_oilClearBannerShown = false;
        this.m_esotericaPosCached = false;
        this.m_alleyMistyPosCached = false;
        this.m_oilShrinePosCached = false;
        this.m_uvEmitterPosCached = false;
        this.m_lastSyncedStage = -1;
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
    }

    private final func CleanupAlleyMisty() -> Void {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_MistyAlley");
            des.DeleteTagged(n"CV_WS_MistyAlley");
        }
        this.m_alleyMistyId = new EntityID();
        this.m_alleyWsAnchorId = new EntityID();
        if IsDefined(this.m_sys) {
            this.m_sys.ResetMistyWorkspotRetryState();
        }
    }

    private final func CleanupRooftopMisty() -> Void {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CrimsonVeilMisty");
            des.DeleteTagged(n"CV_WS_MistyRoof");
        }
        this.m_mistyId = new EntityID();
        this.m_mistyWsAnchorId = new EntityID();
        if IsDefined(this.m_sys) {
            this.m_sys.ResetMistyWorkspotRetryState();
        }
    }

    public final func CleanupEntities() -> Void {
        if !IsDefined(this.m_sys) {
            return;
        }
        this.m_sys.DespawnStaticPropById(this.m_omenAltarId);
        this.m_sys.DespawnStaticPropById(this.m_rooftopTableId);
        this.m_sys.DespawnStaticPropById(this.m_oilShrineId);
        this.m_sys.DespawnStaticPropById(this.m_uvEmitterId);
        this.m_omenAltarId = new EntityID();
        this.m_rooftopTableId = new EntityID();
        this.m_oilShrineId = new EntityID();
        this.m_uvEmitterId = new EntityID();

        this.CleanupAlleyMisty();
        this.CleanupRooftopMisty();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_VampyreScoutA");
            des.DeleteTagged(n"CV_VampyreScoutB");
        }
        this.m_scoutAId = new EntityID();
        this.m_scoutBId = new EntityID();
        this.m_scoutASpawned = false;
        this.m_scoutBSpawned = false;
        this.m_oilAmbushTriggered = false;
    }

    public final func GetMistyEntityID() -> EntityID {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) && EntityID.IsDefined(this.m_mistyId) && des.IsSpawned(this.m_mistyId) {
            return this.m_mistyId;
        }
        if IsDefined(des) && EntityID.IsDefined(this.m_alleyMistyId) && des.IsSpawned(this.m_alleyMistyId) {
            return this.m_alleyMistyId;
        }
        return EntityID.IsDefined(this.m_mistyId) ? this.m_mistyId : this.m_alleyMistyId;
    }

    public final func GetRooftopTableEntityID() -> EntityID {
        return this.m_rooftopTableId;
    }

    // --- Coordenadas Verificadas (100% Juego Base 2.x) ---

    private final func GetEsotericaAltarPos() -> Vector4 = new Vector4(-1545.60, 1209.20, 15.55, 1.00);
    private final func GetEsotericaMistyAlleyRawPos() -> Vector4 = new Vector4(-1546.05, 1208.25, 15.55, 1.00);
    private final func GetEsotericaReturnPos() -> Vector4 = new Vector4(-1545.15, 1210.15, 15.55, 1.00);
    private final func GetRooftopTablePos() -> Vector4 = new Vector4(-1548.88, 1209.17, 57.00, 1.00);
    private final func GetRooftopMistyPos() -> Vector4 = new Vector4(-1549.10, 1209.69, 57.00, 1.00);
    private final func GetRooftopPlayerPos() -> Vector4 = new Vector4(-1548.20, 1207.80, 57.00, 1.00);
    private final func GetOilShrineRawPos() -> Vector4 = new Vector4(-1837.76, 3841.89, 5.50, 1.00);
    private final func GetUvEmitterRawPos() -> Vector4 = new Vector4(-1842.20, 3845.10, 5.50, 1.00);
    private final func GetScoutARawPos() -> Vector4 = new Vector4(-1831.50, 3846.50, 5.50, 1.00);
    private final func GetScoutBRawPos() -> Vector4 = new Vector4(-1844.50, 3836.50, 5.50, 1.00);
    private final func GetOilArrivalPos() -> Vector4 = new Vector4(-1853.50, 3826.50, 5.50, 1.00);

    private final func ComputeFacingYaw(fromPos: Vector4, toPos: Vector4) -> Float {
        return Rad2Deg(AtanF(toPos.Y - fromPos.Y, toPos.X - fromPos.X)) - 90.00;
    }

    private final func GetAllR2PinPaths() -> array<String> {
        let p: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
        return [
            p + "/01_r2_alley/mp_r2_alley",
            p + "/02_r2_scan/mp_r2_scan",
            p + "/03_r2_rooftop/mp_r2_rooftop",
            p + "/04_r2_oilfields/mp_r2_oilfields",
            p + "/05_r2_evidence/mp_r2_evidence",
            p + "/06_r2_debrief/mp_r2_debrief"
        ];
    }

    private final func SyncStageJournalAndPin(stage: Int32, notify: Bool) -> Void {
        if !IsDefined(this.m_sys) {
            return;
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) && (qs.GetFact(n"cv_a1_state") > 0 || qs.GetFact(n"cv_a2_state") > 0) {
            return;
        }
        let q: String = "quests/side_quest/crimson_veil_r2_quest";
        let p: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.m_sys.GetGameInstance());
        let allPins: array<String> = this.GetAllR2PinPaths();

        if stage == 10 {
            let pinPos: Vector4 = new Vector4(-1545.60, 1209.20, 16.45, 1.00);
            this.m_sys.ActivateObjectiveWithPin(10, q, p, p + "/01_r2_alley", p + "/01_r2_alley/mp_r2_alley", p + "/01_r2_alley/desc_r2_01", allPins, notify);
            this.m_sys.UpdateFallbackMappin(10, p + "/01_r2_alley", pinPos, n"cv_mappin_r2_alley", "Callejón de Esoterica (Misty)");
        } else if stage == 15 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            let scanPinPos: Vector4 = new Vector4(-1545.10, 1208.30, 15.85, 1.00);
            this.m_sys.ActivateObjectiveWithPin(15, q, p, p + "/02_r2_scan", p + "/02_r2_scan/mp_r2_scan", p + "/02_r2_scan/desc_r2_02", allPins, notify);
            this.m_sys.UpdateFallbackMappin(15, p + "/02_r2_scan", scanPinPos, n"cv_mappin_r2_alley", "Escanea la carta y pregunta a Misty");
        } else if stage == 20 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            let roofPinPos: Vector4 = new Vector4(-1549.10, 1209.69, 58.65, 1.00);
            this.m_sys.ActivateObjectiveWithPin(20, q, p, p + "/03_r2_rooftop", p + "/03_r2_rooftop/mp_r2_rooftop", p + "/03_r2_rooftop/desc_r2_03", allPins, notify);
            this.m_sys.UpdateFallbackMappin(20, p + "/03_r2_rooftop", roofPinPos, n"cv_mappin_r2_rooftop", "Azotea de Esoterica (22:00)");
        } else if stage == 30 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/03_r2_rooftop", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            let oilPinPos: Vector4 = this.GetOilShrineRawPos();
            oilPinPos.Z += 1.65;
            this.m_sys.ActivateObjectiveWithPin(30, q, p, p + "/04_r2_oilfields", p + "/04_r2_oilfields/mp_r2_oilfields", p + "/04_r2_oilfields/desc_r2_04", allPins, notify);
            this.m_sys.UpdateFallbackMappin(30, p + "/04_r2_oilfields", oilPinPos, n"cv_mappin_r2_oilfields", "Depósitos de Northside (Coro Pálido)");
        } else if stage == 40 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/03_r2_rooftop", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/04_r2_oilfields", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            let evPinPos: Vector4 = this.GetOilShrineRawPos();
            evPinPos.Z += 1.25;
            this.m_sys.ActivateObjectiveWithPin(40, q, p, p + "/05_r2_evidence", p + "/05_r2_evidence/mp_r2_evidence", p + "/05_r2_evidence/desc_r2_05", allPins, notify);
            this.m_sys.UpdateFallbackMappin(40, p + "/05_r2_evidence", evPinPos, n"cv_mappin_r2_oilfields", "Registrar cajas médicas del santuario");
        } else if stage == 50 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/03_r2_rooftop", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/04_r2_oilfields", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/05_r2_evidence", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            let debPinPos: Vector4 = new Vector4(-1549.10, 1209.69, 58.65, 1.00);
            this.m_sys.ActivateObjectiveWithPin(50, q, p, p + "/06_r2_debrief", p + "/06_r2_debrief/mp_r2_debrief", p + "/06_r2_debrief/desc_r2_06", allPins, notify);
            this.m_sys.UpdateFallbackMappin(50, p + "/06_r2_debrief", debPinPos, n"cv_mappin_r2_debrief", "Azotea de Esoterica (Regresar con Misty)");
        } else if stage >= 60 {
            if this.m_lastSyncedStage < 60 {
                this.m_sys.DeactivateJournalPinList(allPins);
            }
        }
        this.m_sys.SyncCodexJournalShards();
        this.m_lastSyncedStage = stage;
    }

    private final func SyncActiveStageMappin(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) || stage >= 60 {
            return;
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) && (qs.GetFact(n"cv_a1_state") > 0 || qs.GetFact(n"cv_a2_state") > 0) {
            return;
        }
        let q: String = "quests/side_quest/crimson_veil_r2_quest";
        let p: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
        let allPins: array<String> = this.GetAllR2PinPaths();
        let pPos: Vector4 = player.GetWorldPosition();

        if stage == 10 {
            let pinPos: Vector4 = new Vector4(-1545.60, 1209.20, 16.45, 1.00);
            this.m_sys.SyncObjectivePinLoop(10, q, p, p + "/01_r2_alley", p + "/01_r2_alley/mp_r2_alley", allPins);
            this.m_sys.UpdateFallbackMappin(10, p + "/01_r2_alley", pinPos, n"cv_mappin_r2_alley", "Callejón de Esoterica (Misty)");
        } else if stage == 15 {
            let scanPinPos: Vector4 = new Vector4(-1545.10, 1208.30, 15.85, 1.00);
            this.m_sys.SyncObjectivePinLoop(15, q, p, p + "/02_r2_scan", p + "/02_r2_scan/mp_r2_scan", allPins);
            this.m_sys.UpdateFallbackMappin(15, p + "/02_r2_scan", scanPinPos, n"cv_mappin_r2_alley", "Escanea la carta y pregunta a Misty");
        } else if stage == 20 {
            if pPos.Z < 38.00 {
                this.m_sys.SyncObjectivePinLoop(20, q, p, p + "/03_r2_rooftop", p + "/03_r2_rooftop/mp_r2_rooftop", allPins);
                this.m_sys.UpdateFallbackMappin(20, p + "/03_r2_rooftop", new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_r2_rooftop", "Subir a la azotea de Esoterica (22:00)");
            } else {
                this.m_sys.SyncObjectivePinLoop(20, q, p, p + "/03_r2_rooftop", p + "/03_r2_rooftop/mp_r2_rooftop", allPins);
                this.m_sys.UpdateFallbackMappin(20, p + "/03_r2_rooftop", new Vector4(-1549.10, 1209.69, 58.65, 1.00), n"cv_mappin_r2_rooftop", "Azotea de Esoterica (Misty)");
            }
        } else if stage == 30 {
            let nearOil: Bool = this.m_sys.ComputeDistanceSq(pPos, this.GetOilShrineRawPos()) <= 6400.00;
            if this.m_oilAmbushTriggered {
                let uvPinPos: Vector4 = nearOil ? this.ResolveUvEmitterPos() : this.GetUvEmitterRawPos();
                uvPinPos.Z += 1.85;
                this.m_sys.ClearJournalPinsAndResetSync(allPins);
                this.m_sys.UpdateDynamicMappin(31, uvPinPos, n"cv_mappin_r2_oilfields", "Emisor UV (Sobrecargar)");
            } else {
                let shrinePinPos: Vector4 = nearOil ? this.ResolveOilShrinePos() : this.GetOilShrineRawPos();
                shrinePinPos.Z += 1.65;
                this.m_sys.SyncObjectivePinLoop(30, q, p, p + "/04_r2_oilfields", p + "/04_r2_oilfields/mp_r2_oilfields", allPins);
                this.m_sys.UpdateFallbackMappin(30, p + "/04_r2_oilfields", shrinePinPos, n"cv_mappin_r2_oilfields", "Depósitos de Northside (Coro Pálido)");
            }
        } else if stage == 40 {
            let evPinPos: Vector4 = this.ResolveOilShrinePos();
            evPinPos.Z += 1.25;
            this.m_sys.SyncObjectivePinLoop(40, q, p, p + "/05_r2_evidence", p + "/05_r2_evidence/mp_r2_evidence", allPins);
            this.m_sys.UpdateFallbackMappin(40, p + "/05_r2_evidence", evPinPos, n"cv_mappin_r2_oilfields", "Registrar cajas médicas del santuario");
        } else if stage == 50 {
            if pPos.Z >= 38.00 {
                this.m_sys.SyncObjectivePinLoop(50, q, p, p + "/06_r2_debrief", p + "/06_r2_debrief/mp_r2_debrief", allPins);
                this.m_sys.UpdateFallbackMappin(50, p + "/06_r2_debrief", new Vector4(-1549.10, 1209.69, 58.65, 1.00), n"cv_mappin_r2_debrief", "Hablar con Misty en la azotea");
            } else {
                this.m_sys.SyncObjectivePinLoop(50, q, p, p + "/06_r2_debrief", p + "/06_r2_debrief/mp_r2_debrief", allPins);
                this.m_sys.UpdateFallbackMappin(50, p + "/06_r2_debrief", new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_r2_debrief", "Subir con Misty a la azotea (Pruebas)");
            }
        } else {
            this.m_sys.ClearJournalPinsAndResetSync(allPins);
            this.m_sys.ClearMappin();
        }
    }

    // --- Caché de Suelo ---

    private final func ResolveEsotericaAltarPos() -> Vector4 {
        if this.m_esotericaPosCached {
            return this.m_esotericaAltarPos;
        }
        let pos: Vector4 = this.GetEsotericaAltarPos();
        pos.Z = this.m_sys.FindGroundZ(pos);
        this.m_esotericaAltarPos = pos;
        this.m_esotericaPosCached = true;
        return pos;
    }

    private final func ResolveAlleyMistyPos() -> Vector4 {
        if this.m_alleyMistyPosCached {
            return this.m_alleyMistyPos;
        }
        let pos: Vector4 = this.GetEsotericaMistyAlleyRawPos();
        pos.Z = this.m_sys.FindGroundZ(pos);
        this.m_alleyMistyPos = pos;
        this.m_alleyMistyPosCached = true;
        return pos;
    }

    private final func ResolveOilShrinePos() -> Vector4 {
        if this.m_oilShrinePosCached {
            return this.m_oilShrinePos;
        }
        let pos: Vector4 = this.GetOilShrineRawPos();
        pos.Z = this.m_sys.FindGroundZWide(pos);
        this.m_oilShrinePos = pos;
        this.m_oilShrinePosCached = true;
        return pos;
    }

    private final func ResolveUvEmitterPos() -> Vector4 {
        if this.m_uvEmitterPosCached {
            return this.m_uvEmitterPos;
        }
        let pos: Vector4 = this.GetUvEmitterRawPos();
        pos.Z = this.m_sys.FindGroundZWide(pos);
        this.m_uvEmitterPos = pos;
        this.m_uvEmitterPosCached = true;
        return pos;
    }

    // --- Escenas Dinámicas (Separación estricta Callejón vs Azotea) ---

    private final func EnsureAlleyScene(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if stage < 10 || stage > 20 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        let nearAltar: Bool = this.m_sys.ComputeDistanceSq(pPos, this.GetEsotericaAltarPos()) <= 10000.00 && pPos.Z < 38.00;
        if !nearAltar {
            return;
        }
        let altarPos: Vector4 = this.ResolveEsotericaAltarPos();
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_omenAltarId) {
            let altarYaw: Float = this.ComputeFacingYaw(altarPos, this.GetEsotericaReturnPos());
            this.m_omenAltarId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_esoterica_omen_altar.ent", altarPos, altarYaw, n"CV_EsotericaAltar");
        }
        // Limpiar Misty de la azotea antes de instanciar Misty del callejón (CP77-EP-030)
        if stage < 20 || pPos.Z < 38.00 {
            this.CleanupRooftopMisty();
            let mistyPos: Vector4 = this.ResolveAlleyMistyPos();
            let mistyYaw: Float = this.ComputeFacingYaw(mistyPos, this.GetEsotericaReturnPos());
            if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_alleyMistyId) {
                this.m_alleyMistyId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Misty", mistyPos, mistyYaw, n"CV_MistyAlley", n"default");
            }
            if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_alleyWsAnchorId) {
                this.m_alleyWsAnchorId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_misty_rooftop.ent", mistyPos, mistyYaw, n"CV_WS_MistyAlley");
            }
            this.m_sys.EnsureMistyWorkspotAndLook(this.m_alleyMistyId, this.m_alleyWsAnchorId, player);
        }
    }

    private final func EnsureRooftopScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage < 20 || !IsDefined(player) {
            return;
        }
        let roofCenter: Vector4 = this.GetRooftopTablePos();
        let pPos: Vector4 = player.GetWorldPosition();
        let onRoof: Bool = forceSpawn || (pPos.Z >= 38.00 && this.m_sys.ComputeDistanceSq(pPos, roofCenter) <= 6400.00);
        if !onRoof {
            return;
        }
        // Despawning Alley Misty antes de entrar en la azotea
        this.CleanupAlleyMisty();

        let tableYaw: Float = this.ComputeFacingYaw(roofCenter, this.GetRooftopPlayerPos());
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_rooftopTableId) {
            this.m_rooftopTableId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_rooftop_tarot_table.ent", roofCenter, tableYaw, n"CV_RooftopTable");
        }
        let mistyPos: Vector4 = this.GetRooftopMistyPos();
        let mistyYaw: Float = this.ComputeFacingYaw(mistyPos, this.GetRooftopPlayerPos());
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_mistyId) {
            this.m_mistyId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Misty", mistyPos, mistyYaw, n"CrimsonVeilMisty", n"default");
        }
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_mistyWsAnchorId) {
            this.m_mistyWsAnchorId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_misty_rooftop.ent", mistyPos, mistyYaw, n"CV_WS_MistyRoof");
        }
        this.m_sys.EnsureMistyWorkspotAndLook(this.m_mistyId, this.m_mistyWsAnchorId, player);
        this.m_sys.SyncRooftopTableStateFromQuest();
    }

    private final func EnsureOilScoutsSpawned(player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(player) {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) {
            return;
        }
        let lookTarget: Vector4 = this.GetOilArrivalPos();
        let pA: Vector4 = this.GetScoutARawPos();
        pA.Z = this.m_sys.FindGroundZWide(pA) + 0.15;
        let yawA: Float = this.ComputeFacingYaw(pA, lookTarget);
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_scoutAId) {
            this.m_scoutAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_VampyreScoutA", pA, yawA, n"CV_VampyreScoutA");
        }
        if EntityID.IsDefined(this.m_scoutAId) && des.IsSpawned(this.m_scoutAId) {
            this.m_scoutASpawned = true;
        }

        let pB: Vector4 = this.GetScoutBRawPos();
        pB.Z = this.m_sys.FindGroundZWide(pB) + 0.15;
        let yawB: Float = this.ComputeFacingYaw(pB, lookTarget);
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_scoutBId) {
            this.m_scoutBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_VampyreScoutB", pB, yawB, n"CV_VampyreScoutB");
        }
        if EntityID.IsDefined(this.m_scoutBId) && des.IsSpawned(this.m_scoutBId) {
            this.m_scoutBSpawned = true;
        }
    }

    private final func IsScoutProvokedOrDown(id: EntityID) -> Bool {
        if !EntityID.IsDefined(id) {
            return false;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsSpawned(id) {
            return false;
        }
        let npc: ref<NPCPuppet> = des.GetEntity(id) as NPCPuppet;
        if !IsDefined(npc) {
            return false;
        }
        if npc.IsDead() || ScriptedPuppet.IsDefeated(npc) || ScriptedPuppet.IsUnconscious(npc) || NPCPuppet.IsInCombat(npc) {
            return true;
        }
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.m_sys.GetGameInstance());
        return IsDefined(sps) && sps.GetStatPoolValue(Cast<StatsObjectID>(id), gamedataStatPoolType.Health, true) < 98.00;
    }

    private final func EnsureOilScoutsHostile(player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(player) {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) {
            return;
        }
        if EntityID.IsDefined(this.m_scoutAId) && des.IsSpawned(this.m_scoutAId) {
            this.m_scoutASpawned = true;
            let npcA: ref<NPCPuppet> = des.GetEntity(this.m_scoutAId) as NPCPuppet;
            if IsDefined(npcA) && !npcA.IsDead() && !ScriptedPuppet.IsDefeated(npcA) && !ScriptedPuppet.IsUnconscious(npcA) && !NPCPuppet.IsInCombat(npcA) {
                this.m_sys.MakeNpcHostile(npcA, player);
            }
        }
        if EntityID.IsDefined(this.m_scoutBId) && des.IsSpawned(this.m_scoutBId) {
            this.m_scoutBSpawned = true;
            let npcB: ref<NPCPuppet> = des.GetEntity(this.m_scoutBId) as NPCPuppet;
            if IsDefined(npcB) && !npcB.IsDead() && !ScriptedPuppet.IsDefeated(npcB) && !ScriptedPuppet.IsUnconscious(npcB) && !NPCPuppet.IsInCombat(npcB) {
                this.m_sys.MakeNpcHostile(npcB, player);
            }
        }
    }

    private final func IsScoutCleared(id: EntityID, everSpawned: Bool, anchorPos: Vector4, combatElapsed: Float) -> Bool {
        if !everSpawned && combatElapsed < 8.00 {
            return false;
        }
        return this.m_sys.IsNpcNeutralized(id, anchorPos, combatElapsed);
    }

    private final func TriggerOilfieldsAmbush(player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(player) || this.m_oilAmbushTriggered {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));

        this.m_oilAmbushTriggered = true;
        this.m_oilAmbushTime = nowSim;
        if IsDefined(this.m_sys.m_vampyreCombat) {
            this.m_sys.m_vampyreCombat.ResetCombatTimers();
        }

        this.EnsureOilScoutsSpawned(player);
        this.EnsureOilScoutsHostile(player);

        this.m_sys.ClearJournalPinsAndResetSync(this.GetAllR2PinPaths());
        let uvPos: Vector4 = this.ResolveUvEmitterPos();
        this.m_sys.UpdateDynamicMappin(31, new Vector4(uvPos.X, uvPos.Y, uvPos.Z + 1.85, 1.00), n"cv_mappin_r2_oilfields", "Emisor UV (Sobrecargar)");
        this.m_sys.ShowRelicBanner(n"cv_banner_oil_ambush", "[EL CORO PÁLIDO] ¡Centinelas al ataque! Sobrecarga el emisor UV si se regeneran");
        let steps: array<ref<CrimsonVeilSpeechStep>>;
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_p0_vampyre_ambush", n"vampyre", n"Centinela del Coro Pálido", scnDialogLineType.Regular, 6.45));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_oil_misty_radio", n"phone", n"Misty Olszewski", scnDialogLineType.Regular, 10.04));
        this.m_sys.StartSpeechSequence(steps, 0);
    }

    private final func EnsureOilfieldsScene(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        let pPos: Vector4 = player.GetWorldPosition();
        let rawShrine: Vector4 = this.GetOilShrineRawPos();
        if this.m_sys.ComputeDistanceSq(pPos, rawShrine) > 6400.00 {
            return;
        }
        let shrinePos: Vector4 = this.ResolveOilShrinePos();
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_oilShrineId) {
            this.m_oilShrineId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_blood_shrine.ent", shrinePos, 15.00, n"CV_OilShrine");
        }
        let uvPos: Vector4 = this.ResolveUvEmitterPos();
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_uvEmitterId) {
            this.m_uvEmitterId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", uvPos, -35.00, n"CV_UvEmitter");
        }
        this.m_sys.SyncOilShrineEvidenceVisual(this.m_oilShrineId, stage >= 50);
        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.m_sys.GetGameInstance()));
        let uvFlash: Bool = IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvFlashActive(nowSim);
        let uvReady: Bool = !IsDefined(this.m_sys.m_vampyreCombat) || !this.m_sys.m_vampyreCombat.IsUvOnCooldown(nowSim);
        this.m_sys.SyncUvEmitterVisual(this.m_uvEmitterId, uvFlash, uvReady);

        if stage == 30 {
            this.EnsureOilScoutsSpawned(player);
            if this.m_oilAmbushTriggered {
                this.EnsureOilScoutsHostile(player);
            } else {
                let distShrineSq: Float = this.m_sys.ComputeDistanceSq(pPos, shrinePos);
                if distShrineSq <= 144.00 || this.IsScoutProvokedOrDown(this.m_scoutAId) || this.IsScoutProvokedOrDown(this.m_scoutBId) {
                    this.TriggerOilfieldsAmbush(player);
                }
            }
        }
        if stage == 30 && !this.m_oilIntroPlayed && !this.m_oilAmbushTriggered && this.m_sys.ComputeDistanceSq(pPos, shrinePos) <= 1600.00 {
            this.m_oilIntroPlayed = true;
            this.m_sys.ShowRelicBanner(n"cv_banner_oil_arrive", "[NORTHSIDE] Centinelas junto al santuario — usa el emisor UV o acércate");
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_oil_v_arrive", n"v_narr", n"V", scnDialogLineType.Regular, 8.20));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    // --- Diálogos del Prólogo: Callejón -> Preguntas -> Azotea ---

    public final func ShowAlleyInvestigationHub(stage: Int32) -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let scanned: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_scanned") > 0;
        let qMissing: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_qa_missing") > 0;
        let qWatched: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_qa_watched") > 0;
        let qChorus: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_qa_chorus") > 0;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        if !scanned {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_scan_tarot", "[Escáner Kiroshi] Analizar la mancha en la carta del Tarot"), true, false));
            ArrayPush(optionIds, 1);
        } else if stage < 20 {
            if !qMissing {
                ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_missing", "[Investigar] ¿Quiénes más desaparecieron antes que Lucía?"), false, false));
                ArrayPush(optionIds, 2);
            }
            if !qWatched {
                ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_watched", "[Investigar] ¿Por qué crees que alguien te vigila?"), false, false));
                ArrayPush(optionIds, 3);
            }
            if !qChorus {
                ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_chorus", "[Investigar] ¿Lucía mencionó alguna clínica o grupo?"), false, false));
                ArrayPush(optionIds, 4);
            }
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_rooftop_now", "Quédate a cubierto; nos vemos en la azotea a las diez."), true, false));
            ArrayPush(optionIds, 5);
        } else {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_wait_roof", "Esperar hasta las 22:00 y subir con Misty a la azotea"), true, false));
            ArrayPush(optionIds, 6);
        }
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_open_codex", "Abrir Códice de Investigación"), false, false));
        ArrayPush(optionIds, 7);

        this.m_sys.PushDialogHub(n"cv_alley_hub", this.m_sys.GetLoc(n"cv_hub_r2_alley_title", "Callejón de Esoterica — Misty Olszewski"), choices, optionIds);
    }

    public final func ShowMistyRooftopHub() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_r2_state") : 20;
        let roofOpened: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_roof_opened") > 0;
        let qChem: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_roof_qa_chem") > 0;
        let qCards: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_roof_qa_cards") > 0;
        let a1Stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a1_state") : 0;
        let a2Stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_state") : 0;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        if stage == 50 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_deliver_vial", "Entregar el vial NOX-9 y el recibo de Lucía a Misty"), true, false));
            ArrayPush(optionIds, 20);
        } else if a2Stage == 50 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_a2_finale_roof", "Reunirte con Misty y Lucía Reyes (Cierre Acto II)"), true, false));
            ArrayPush(optionIds, 22);
        } else if a1Stage == 40 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_deliver_manifest", "Entregar el Manifiesto NOX-9 a Misty (Cierre Acto I)"), true, false));
            ArrayPush(optionIds, 21);
        } else if stage == 20 {
            if !roofOpened {
                ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_sit_table", "Sentarte frente a Misty junto a la mesa del Tarot"), true, false));
                ArrayPush(optionIds, 10);
            } else {
                if !qChem {
                    ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_roof_chem", "No es ningún hechizo ni pacto, Misty: es química sucia."), false, false));
                    ArrayPush(optionIds, 11);
                }
                if !qCards {
                    ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_roof_cards", "¿Cómo conectabas estos tres arcanos con sus cuadernos?"), false, false));
                    ArrayPush(optionIds, 12);
                }
                ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_choice_r2_roof_tower", "Espera — dale la vuelta a La Torre y mira la cera del borde."), true, false));
                ArrayPush(optionIds, 16);
            }
        } else if stage == 30 || stage == 40 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_go_northside", "Ir ahora a los Depósitos de Northside"), true, false));
            ArrayPush(optionIds, 14);
        }

        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_open_codex", "Abrir Códice de Investigación"), false, false));
        ArrayPush(optionIds, 13);

        if stage >= 20 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_r2_descend_alley", "Bajar al callejón trasero de Esoterica"), false, false));
            ArrayPush(optionIds, 15);
        }

        this.m_sys.PushDialogHub(n"cv_misty_roof_hub", this.m_sys.GetLoc(n"cv_hub_r2_roof_night_title", "Misty Olszewski — Azotea (22:00)"), choices, optionIds);
    }

    public final func HandleDialogOption(ownerTag: CName, optionId: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;

        if Equals(ownerTag, n"cv_alley_hub") {
            if optionId == 1 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_scanned", 1);
                    if qs.GetFact(n"cv_r2_state") < 15 {
                        qs.SetFact(n"cv_r2_state", 15);
                    }
                }
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_StainedMoonCard", 1, 0.40);
                this.SyncStageJournalAndPin(15, true);
                this.m_sys.ShowRelicBanner(n"cv_banner_r2_scan_done", "[ESCÁNER KIROSHI] Hemoglobina sintética y porfirinas NOX-9 — La carta es de Lucía");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_v_scan", n"v_narr", n"V", scnDialogLineType.Regular, 15.08));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_misty_lucia_01", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 1.04));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_v_lucia_01", n"v_narr", n"V", scnDialogLineType.Regular, 2.93));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_misty_lucia_02", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 25.10));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_v_candles", n"v_narr", n"V", scnDialogLineType.Regular, 9.80));
                this.m_sys.StartSpeechSequence(steps, 11);
                return true;
            }
            if optionId == 2 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_qa_missing", 1);
                }
                this.m_sys.SyncCodexJournalShards();
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_missing_v", n"v_narr", n"V", scnDialogLineType.Regular, 4.77));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_missing_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 16.12));
                this.m_sys.StartSpeechSequence(steps, 11);
                return true;
            }
            if optionId == 3 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_qa_watched", 1);
                }
                this.m_sys.SyncCodexJournalShards();
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_watched_v", n"v_narr", n"V", scnDialogLineType.Regular, 2.99));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_watched_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 13.16));
                this.m_sys.StartSpeechSequence(steps, 11);
                return true;
            }
            if optionId == 4 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_qa_chorus", 1);
                }
                this.m_sys.SyncCodexJournalShards();
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_chorus_v", n"v_narr", n"V", scnDialogLineType.Regular, 3.65));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_qa_chorus_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 13.16));
                this.m_sys.StartSpeechSequence(steps, 11);
                return true;
            }
            if optionId == 5 {
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_misty_rooftop", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.84));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_v_rooftop", n"v_narr", n"V", scnDialogLineType.Regular, 3.86));
                this.m_sys.StartSpeechSequence(steps, 12);
                return true;
            }
            if optionId == 6 {
                this.EnterRooftopNightScene(player);
                return true;
            }
            if optionId == 7 {
                this.m_sys.OpenTarotSpreadPopup(false);
                return true;
            }
        }

        if Equals(ownerTag, n"cv_misty_roof_hub") {
            if optionId == 10 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_roof_opened", 1);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m1", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 6.56));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m2", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 13.24));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m3", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.60));
                this.m_sys.StartSpeechSequence(steps, 21);
                this.m_sys.BeginRooftopTarotReadingVisuals();
                return true;
            }
            if optionId == 11 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_roof_qa_chem", 1);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_chem_v", n"v_narr", n"V", scnDialogLineType.Regular, 9.64));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_chem_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 11.72));
                this.m_sys.StartSpeechSequence(steps, 21);
                return true;
            }
            if optionId == 12 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_r2_roof_qa_cards", 1);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_cards_v", n"v_narr", n"V", scnDialogLineType.Regular, 7.24));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_cards_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 14.76));
                this.m_sys.StartSpeechSequence(steps, 21);
                return true;
            }
            if optionId == 16 {
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_tower_v", n"v_narr", n"V", scnDialogLineType.Regular, 10.04));
                this.m_sys.StartSpeechSequence(steps, 20);
                return true;
            }
            if optionId == 13 {
                this.m_sys.OpenTarotSpreadPopup(false);
                return true;
            }
            if optionId == 14 {
                this.DebugGoToOilfieldsNight();
                return true;
            }
            if optionId == 15 {
                this.CleanupRooftopMisty();
                let retPos: Vector4 = this.GetEsotericaReturnPos();
                retPos.Z = this.m_sys.FindGroundZ(retPos) + 0.10;
                let retYaw: Float = this.ComputeFacingYaw(retPos, this.GetEsotericaAltarPos());
                this.m_sys.TeleportPlayerSmooth(retPos, retYaw);
                return true;
            }
            if optionId == 20 {
                this.CompletePrologueDebrief();
                return true;
            }
            if optionId == 21 {
                if IsDefined(this.m_sys.m_act01) {
                    this.m_sys.m_act01.CompleteAct1DebriefOnRooftop();
                }
                return true;
            }
            if optionId == 22 {
                if IsDefined(this.m_sys.m_act02) {
                    this.m_sys.m_act02.CompleteAct2FinaleOnRooftop();
                }
                return true;
            }
        }
        return false;
    }

    private final func EnterRooftopNightScene(player: ref<PlayerPuppet>) -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) && qs.GetFact(n"cv_r2_state") < 20 {
            qs.SetFact(n"cv_r2_state", 20);
        }
        this.m_sys.SetNightTime2200();
        this.EnsureRooftopScene(player, 20, true);
        let lookYaw: Float = this.ComputeFacingYaw(this.GetRooftopPlayerPos(), this.GetRooftopMistyPos());
        this.m_sys.TeleportPlayerSmooth(this.GetRooftopPlayerPos(), lookYaw);
        this.SyncStageJournalAndPin(20, true);
        this.m_sys.ShowRelicBanner(n"cv_banner_r2_rooftop_wait", "[22:00 · AZOTEA] Habla con Misty junto a la mesa del Tarot");
    }

    public final func OnTarotReadingConfirmed(cardId: Int32, lensMode: Int32) -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_regent_card", cardId);
            qs.SetFact(n"cv_r2_lens", lensMode);
            qs.SetFact(n"cv_r2_tarot_done", 1);
            if qs.GetFact(n"cv_r2_state") < 30 {
                qs.SetFact(n"cv_r2_state", 30);
            }
        }
        this.SyncStageJournalAndPin(30, true);
        this.m_sys.ShowRelicBanner(n"cv_banner_p0_oilfields_unlocked", "[RASTRO EN LA TORRE] Residuo petroquímico señala los Depósitos de Northside");

        let steps: array<ref<CrimsonVeilSpeechStep>>;
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_promise_m", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.20));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_v_depart", n"v_narr", n"V", scnDialogLineType.Regular, 6.02));
        this.m_sys.StartSpeechSequence(steps, 0);
    }

    private final func CompletePrologueDebrief() -> Void {
        let steps: array<ref<CrimsonVeilSpeechStep>>;
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_debrief_m1", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 8.84));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_debrief_v1", n"v_narr", n"V", scnDialogLineType.Regular, 12.34));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_debrief_m2", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 11.84));
        this.m_sys.StartSpeechSequence(steps, 25);
    }

    private final func FinalizePrologueRewards() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
        if IsDefined(qs) && qs.GetFact(n"cv_r2_done") == 0 {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            if IsDefined(ts) && IsDefined(player) {
                ts.GiveItem(player, ItemID.FromTDBID(t"Items.money"), 1200);
                this.m_sys.GiveItemDelayed(t"Items.Preset_Nue_CrimsonVeil", 1, 1.10);
            }
            this.m_sys.GrantExperience(500);
            this.m_sys.ClearJournalPinsAndResetSync(this.GetAllR2PinPaths());
            if IsDefined(jm) {
                let p: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
                jm.ChangeEntryState(p + "/06_r2_debrief", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/desc_r2_done", "gameJournalQuestDescription", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState("quests/side_quest/crimson_veil_r2_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.Notify);
            }
            this.m_sys.ClearMappin();
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_r2_prologue_done", "[PRÓLOGO COMPLETADO] +1.200 €$ · +500 EXP · «Velo Silente» · Códice actualizado");
            this.m_sys.RequestDelayedCheckpoint(3.40);
        }
    }

    public final func OnPostSpeech(actionId: Int32) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if actionId == 1 {
            if IsDefined(qs) && (qs.GetFact(n"cv_a1_state") > 0 || qs.GetFact(n"cv_a2_state") > 0) {
                this.m_sys.EndMistyIntroCall();
                return;
            }
            this.m_sys.EndMistyIntroCall();
            if IsDefined(qs) && qs.GetFact(n"cv_r2_state") < 10 {
                qs.SetFact(n"cv_r2_state", 10);
            }
            this.m_sys.ActivateMistyCallRecapSms();
            this.SyncStageJournalAndPin(10, true);
            this.m_sys.ShowRelicBanner(n"cv_banner_r2_call", "[HOLOMENSAJE] Misty te espera en el callejón trasero de Esoterica");
            return;
        }
        if actionId == 11 {
            let st: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_r2_state") : 15;
            this.ShowAlleyInvestigationHub(st);
            return;
        }
        if actionId == 12 {
            if IsDefined(qs) && qs.GetFact(n"cv_r2_state") < 20 {
                qs.SetFact(n"cv_r2_state", 20);
            }
            this.SyncStageJournalAndPin(20, true);
            this.m_sys.ShowRelicBanner(n"cv_banner_r2_rooftop_wait", "[22:00] Sube a la azotea de Esoterica cuando anochezca");
            return;
        }
        if actionId == 20 {
            this.m_sys.OpenTarotSpreadPopup(true);
            return;
        }
        if actionId == 21 {
            this.ShowMistyRooftopHub();
            return;
        }
        if actionId == 25 {
            this.FinalizePrologueRewards();
            return;
        }
    }

    public final func HandleInteraction(kind: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_r2_state") : 10;

        if kind == 1 {
            if stage == 10 && !this.m_alleyWarnedOnce {
                this.m_alleyWarnedOnce = true;
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_alley_misty_warn", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 8.44));
                this.m_sys.StartSpeechSequence(steps, 11);
            } else {
                this.ShowAlleyInvestigationHub(stage);
            }
            return true;
        }
        if kind == 2 {
            if stage == 20 && IsDefined(qs) && qs.GetFact(n"cv_r2_roof_opened") == 0 {
                qs.SetFact(n"cv_r2_roof_opened", 1);
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m1", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 6.56));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m2", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 13.24));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_roof_open_m3", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.60));
                this.m_sys.StartSpeechSequence(steps, 21);
                this.m_sys.BeginRooftopTarotReadingVisuals();
            } else {
                this.ShowMistyRooftopHub();
            }
            return true;
        }
        if kind == 3 {
            if !this.m_oilAmbushTriggered && stage == 30 {
                this.TriggerOilfieldsAmbush(player);
            }
            if IsDefined(this.m_sys.m_vampyreCombat) {
                let uvPos: Vector4 = this.ResolveUvEmitterPos();
                this.m_sys.m_vampyreCombat.TriggerUvOverload(player, uvPos, this.m_scoutAId, this.m_scoutBId);
                this.m_sys.SyncUvEmitterVisual(this.m_uvEmitterId, true, false);
            }
            this.EnsureOilScoutsHostile(player);
            return true;
        }
        if kind == 4 {
            if IsDefined(qs) && stage == 40 {
                qs.SetFact(n"cv_r2_state", 50);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.SyncOilShrineEvidenceVisual(this.m_oilShrineId, true);
                this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_PlasmaSample", 1, 0.25);
                this.SyncStageJournalAndPin(50, true);
                this.m_sys.ShowRelicBanner(n"cv_banner_r2_proof_taken", "[PRUEBA RECUPERADA] Lucía sigue viva (Sujeto L-14) — Vuelve con Misty");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_r2_oil_v_note", n"v_narr", n"V", scnDialogLineType.Regular, 18.53));
                this.m_sys.StartSpeechSequence(steps, 0);
            }
            return true;
        }
        if kind == 5 {
            if !this.m_oilAmbushTriggered && stage == 30 {
                this.TriggerOilfieldsAmbush(player);
            }
            return true;
        }
        if kind == 6 {
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvDiagnosticPulse(player);
            }
            return true;
        }
        if kind == 7 {
            if IsDefined(this.m_sys.m_vampyreCombat) {
                let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
                let remSec: Int32 = this.m_sys.m_vampyreCombat.GetRemainingCooldownSeconds(nowSim);
                let msg: String = this.m_sys.GetLoc(n"cv_banner_uv_cooling_pre", "[EMISOR UV] Condensador recargando — listo en ") + IntToString(remSec) + " s";
                this.m_sys.ShowRelicBannerText(msg);
            }
            return true;
        }
        if kind == 8 {
            this.EnsureOilScoutsHostile(player);
            this.m_sys.ShowRelicBanner(n"cv_banner_shrine_combat_lock", "[COMBATE ACTIVO] Neutraliza a los centinelas antes de registrar las cajas");
            return true;
        }
        if kind == 9 {
            this.EnterRooftopNightScene(player);
            return true;
        }
        return false;
    }

    // --- Botones CET de Pruebas Rápidas ---

    public final func DebugTriggerIntroCall() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_state", 5);
        }
        this.m_callAttempted = true;
        this.m_sys.StartMistyIntroCall();
    }

    public final func DebugGoToEsoterica() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(qs) && qs.GetFact(n"cv_r2_state") < 10 {
            qs.SetFact(n"cv_r2_state", 10);
            this.SyncStageJournalAndPin(10, true);
        }
        let retPos: Vector4 = this.GetEsotericaReturnPos();
        retPos.Z = this.m_sys.FindGroundZ(retPos) + 0.10;
        let retYaw: Float = this.ComputeFacingYaw(retPos, this.GetEsotericaAltarPos());
        this.m_sys.TeleportPlayerSmooth(retPos, retYaw);
        if IsDefined(player) {
            this.EnsureAlleyScene(player, 10);
        }
    }

    public final func DebugGoToRooftopNight() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        this.EnterRooftopNightScene(player);
    }

    public final func DebugGoToOilfieldsNight() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        this.m_sys.SetNightTime2200();
        if IsDefined(qs) && qs.GetFact(n"cv_r2_state") < 30 {
            qs.SetFact(n"cv_r2_state", 30);
            this.SyncStageJournalAndPin(30, true);
        }
        let arr: Vector4 = this.GetOilArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        let lookYaw: Float = this.ComputeFacingYaw(arr, this.GetOilShrineRawPos());
        this.m_sys.TeleportPlayerSmooth(arr, lookYaw);
        if IsDefined(player) {
            this.EnsureOilfieldsScene(player, 30);
        }
    }

    public final func DebugGoToDebriefNight() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_roof_opened", 1);
            qs.SetFact(n"cv_r2_done", 0);
            qs.SetFact(n"cv_r2_state", 50);
        }
        this.m_sys.SetNightTime2200();
        this.EnsureRooftopScene(player, 50, true);
        let lookYaw: Float = this.ComputeFacingYaw(this.GetRooftopPlayerPos(), this.GetRooftopMistyPos());
        this.m_sys.TeleportPlayerSmooth(this.GetRooftopPlayerPos(), lookYaw);
        this.SyncStageJournalAndPin(50, true);
        this.m_sys.ShowRelicBanner(n"cv_banner_r2_debrief_ready", "[PRUEBAS RECUPERADAS] Habla con Misty en la azotea para cerrar el Prólogo");
    }

    public final func DebugResetAll() -> Void {
        this.CleanupEntities();
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_state", 0);
            qs.SetFact(n"cv_r2_done", 0);
            qs.SetFact(n"cv_r2_scanned", 0);
            qs.SetFact(n"cv_r2_qa_missing", 0);
            qs.SetFact(n"cv_r2_qa_watched", 0);
            qs.SetFact(n"cv_r2_qa_chorus", 0);
            qs.SetFact(n"cv_r2_tarot_done", 0);
            qs.SetFact(n"cv_r2_regent_card", 0);
            qs.SetFact(n"cv_r2_lens", 0);
            qs.SetFact(n"cv_r2_roof_opened", 0);
            qs.SetFact(n"cv_r2_roof_qa_chem", 0);
            qs.SetFact(n"cv_r2_roof_qa_cards", 0);
        }
        this.m_alleyWarnedOnce = false;
        this.m_oilIntroPlayed = false;
        this.m_oilClearBannerShown = false;
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
        this.m_lastSyncedStage = -1;
        this.m_sys.ClearJournalPinsAndResetSync(this.GetAllR2PinPaths());
        this.m_sys.ClearMappin();
        this.m_sys.ResetRooftopTarotTableVisualState();
    }

    public final func EnterHolocallRecordingStudio() -> Float {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        this.CleanupAlleyMisty();
        this.m_sys.DespawnStaticPropById(this.m_rooftopTableId);
        this.m_rooftopTableId = new EntityID();
        this.m_sys.SetNightTime2200();

        let mistyPos: Vector4 = this.GetRooftopMistyPos();
        let camPos: Vector4 = new Vector4(-1548.57, 1208.44, 57.00, 1.00);
        let mistyYaw: Float = this.ComputeFacingYaw(mistyPos, camPos);
        let camYaw: Float = this.ComputeFacingYaw(camPos, mistyPos);

        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_mistyId) {
            this.m_mistyId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Misty", mistyPos, mistyYaw, n"CrimsonVeilMisty", n"default");
        }
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_mistyWsAnchorId) {
            this.m_mistyWsAnchorId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_misty_rooftop.ent", mistyPos, mistyYaw, n"CV_WS_MistyRoof");
        }
        this.m_sys.ResetMistyWorkspotRetryState();
        if IsDefined(player) {
            this.EnsureStudioMistyReady(player);
        }
        this.m_sys.TeleportPlayerSmooth(camPos, camYaw);
        return mistyYaw;
    }

    public final func EnsureStudioMistyReady(player: ref<PlayerPuppet>) -> Void {
        if IsDefined(player) {
            this.m_sys.EnsureMistyWorkspotAndLook(this.m_mistyId, this.m_mistyWsAnchorId, player);
        }
    }

    // --- Bucle Principal del Prólogo ---

    public final func Tick(player: ref<PlayerPuppet>, fullGameplay: Bool) -> Float {
        if !IsDefined(player) || !this.m_sys.IsGameplayReady(player) || !fullGameplay {
            this.m_sys.HideWorldInteraction();
            return 0.45;
        }
        if !this.m_sys.HasReachedNightCityAct1(player) {
            return 1.00;
        }
        if this.m_sys.IsHoloRecordStudioActive() {
            this.m_sys.EnsureStudioUnblurredAndLive();
            this.m_sys.HideWorldInteraction();
            this.EnsureStudioMistyReady(player);
            return 0.25;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if !IsDefined(qs) {
            return 0.70;
        }
        if qs.GetFact(n"cv_a2_state") > 0 || qs.GetFact(n"cv_a1_state") > 0 {
            this.m_sys.AbortPrologueCallAndSpeech();
            if qs.GetFact(n"cv_r2_done") == 0 || qs.GetFact(n"cv_r2_state") < 60 {
                qs.SetFact(n"cv_r2_done", 1);
                qs.SetFact(n"cv_r2_state", 60);
                this.m_sys.ClearJournalPinsAndResetSync(this.GetAllR2PinPaths());
                let jmClose: ref<JournalManager> = GameInstance.GetJournalManager(game);
                if IsDefined(jmClose) {
                    let pClose: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
                    jmClose.ChangeEntryState(pClose + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/03_r2_rooftop", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/04_r2_oilfields", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/05_r2_evidence", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/06_r2_debrief", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState("quests/side_quest/crimson_veil_r2_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                }
                this.m_lastSyncedStage = 60;
            }
        }
        let stage: Int32 = qs.GetFact(n"cv_r2_state");
        if stage == 0 {
            let tooCloseToEsoterica: Bool = qs.GetFact(n"cv_force_start") == 0
                && this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), new Vector4(-1544.00, 1236.00, 18.00, 1.00)) <= 225.00;
            if this.m_sys.IsVanillaPhoneBusy() || this.m_sys.IsPhoneOverlayOpen() || player.IsInCombat() || tooCloseToEsoterica {
                this.m_callReadyTicks = 0;
                return 0.60;
            }
            this.m_callReadyTicks += 1;
            if this.m_callReadyTicks >= 10 && !this.m_callAttempted {
                this.m_callAttempted = true;
                qs.SetFact(n"cv_r2_state", 5);
                this.m_sys.StartMistyIntroCall();
            }
            return 0.60;
        }
        if stage == 5 {
            if this.m_sys.IsVanillaPhoneBusy() || this.m_sys.IsPhoneOverlayOpen() {
                this.m_callReadyTicks = 0;
                return 0.60;
            }
            if !this.m_callAttempted {
                this.m_callReadyTicks += 1;
                if this.m_callReadyTicks >= 6 {
                    this.m_callAttempted = true;
                    this.m_sys.StartMistyIntroCall();
                }
            }
            return 0.45;
        }
        if this.m_lastSyncedStage != stage {
            this.SyncStageJournalAndPin(stage, false);
        }

        let pPos: Vector4 = player.GetWorldPosition();
        if stage >= 10 && stage <= 20 && pPos.Z < 38.00 {
            this.EnsureAlleyScene(player, stage);
        }
        if stage >= 20 && (stage < 60 || pPos.Z >= 38.00) {
            this.EnsureRooftopScene(player, stage);
        }
        if stage >= 30 && stage <= 50 {
            this.EnsureOilfieldsScene(player, stage);
        }
        this.SyncActiveStageMappin(player, stage);

        if stage >= 60 {
            if !this.m_sys.IsDialogActive() && !this.m_sys.IsSpeechBlockingWorldInteraction() && !this.m_sys.IsUiBlockingWorldInput() {
                if pPos.Z >= 38.00 && this.m_sys.ComputeDistanceSq(pPos, this.GetRooftopMistyPos()) <= 10.24 {
                    this.m_sys.ShowWorldInteraction(2, n"cv_hub_misty_roof_title", "Misty Olszewski — Azotea", n"cv_act_talk_misty", "Hablar con Misty Olszewski", true);
                    return 0.20;
                }
                let a1Debrief: Bool = qs.GetFact(n"cv_a1_state") == 40;
                let a2Finale: Bool = qs.GetFact(n"cv_a2_state") == 50;
                if (a1Debrief || a2Finale) && pPos.Z < 38.00 && this.m_sys.ComputeDistanceSq(pPos, this.GetEsotericaAltarPos()) <= 9.00 {
                    if a2Finale {
                        this.m_sys.ShowWorldInteraction(9, n"cv_hub_esoterica_title", "Acceso a la Azotea — Misty y Lucía", n"cv_act_ascend_rooftop_a2", "Subir con Misty y Lucía a la azotea (Final Acto II)", true);
                    } else {
                        this.m_sys.ShowWorldInteraction(9, n"cv_hub_esoterica_title", "Acceso a la Azotea — Misty", n"cv_act_ascend_rooftop", "Subir con Misty a la azotea (Informar Acto I)", true);
                    }
                    return 0.20;
                }
            }
            return 0.70;
        }

        if this.m_sys.IsDialogActive() || this.m_sys.IsSpeechBlockingWorldInteraction() || this.m_sys.IsUiBlockingWorldInput() {
            this.m_sys.HideWorldInteraction();
            return 0.25;
        }

        // 1. Callejón trasero de Esoterica (Altar y Misty abajo)
        if stage >= 10 && stage <= 20 && pPos.Z < 38.00 {
            let altarPos: Vector4 = this.ResolveEsotericaAltarPos();
            let mistyPos: Vector4 = this.ResolveAlleyMistyPos();
            let nearAltar: Bool = this.m_sys.ComputeDistanceSq(pPos, altarPos) <= 9.00 && AbsF(pPos.Z - altarPos.Z) < 2.50;
            let nearMisty: Bool = this.m_sys.ComputeDistanceSq(pPos, mistyPos) <= 9.00 && AbsF(pPos.Z - mistyPos.Z) < 2.50;
            if nearAltar || nearMisty {
                if stage == 10 {
                    this.m_sys.ShowWorldInteraction(1, n"cv_hub_esoterica_title", "Callejón de Esoterica — Misty", n"cv_int_r2_alley", "Escanear altar y hablar con Misty", true);
                } else {
                    this.m_sys.ShowWorldInteraction(1, n"cv_hub_esoterica_title", "Callejón de Esoterica — Misty", n"cv_int_r2_alley_qa", "Preguntar a Misty por lo ocurrido", true);
                }
                return 0.20;
            }
        }

        // 2. Azotea de Esoterica (Misty arriba a las 22:00)
        if stage >= 20 && pPos.Z >= 38.00 && this.m_sys.ComputeDistanceSq(pPos, this.GetRooftopMistyPos()) <= 10.24 {
            this.m_sys.ShowWorldInteraction(2, n"cv_hub_misty_roof_title", "Misty Olszewski — Azotea", n"cv_act_talk_misty", "Hablar con Misty Olszewski", true);
            return 0.20;
        }

        // 3. Depósitos Petrolíferos de Northside (Emisor UV -> Combate -> Pruebas)
        if stage == 30 || stage == 40 {
            if this.m_sys.ComputeDistanceSq(pPos, this.GetOilShrineRawPos()) > 6400.00 {
                this.m_sys.HideWorldInteraction();
                return 0.35;
            }
            let shrinePos: Vector4 = this.ResolveOilShrinePos();
            let uvPos: Vector4 = this.ResolveUvEmitterPos();
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let elapsedCombat: Float = MaxF(0.10, nowSim - this.m_oilAmbushTime);

            if stage == 30 {
                let cleared: Bool = this.m_oilAmbushTriggered
                    && this.IsScoutCleared(this.m_scoutAId, this.m_scoutASpawned, shrinePos, elapsedCombat)
                    && this.IsScoutCleared(this.m_scoutBId, this.m_scoutBSpawned, shrinePos, elapsedCombat);
                if cleared {
                    qs.SetFact(n"cv_r2_state", 40);
                    stage = 40;
                    this.SyncStageJournalAndPin(40, true);
                    if !this.m_oilClearBannerShown {
                        this.m_oilClearBannerShown = true;
                        this.m_sys.ShowRelicBanner(n"cv_banner_sample_ready", "[PERÍMETRO DESPEJADO] Registra las cajas médicas junto al santuario");
                    }
                } else if this.m_oilAmbushTriggered {
                    this.EnsureOilScoutsHostile(player);
                    if IsDefined(this.m_sys.m_vampyreCombat) {
                        this.m_sys.m_vampyreCombat.TickVampyreRegen(player, shrinePos, this.m_scoutAId, this.m_scoutBId);
                    }
                }
            }

            let distShrineSq: Float = this.m_sys.ComputeDistanceSq(pPos, shrinePos);
            let distUvSq: Float = this.m_sys.ComputeDistanceSq(pPos, uvPos);

            if stage == 40 {
                if distShrineSq <= 12.25 && AbsF(pPos.Z - shrinePos.Z) < 3.50 {
                    this.m_sys.ShowWorldInteraction(4, n"cv_hub_shrine_title", "Santuario de Northside", n"cv_int_r2_evidence", "Registrar cajas médicas (vial y recibo)", false, true);
                    return 0.20;
                }
            } else if this.m_oilAmbushTriggered {
                if distUvSq <= 25.00 && AbsF(pPos.Z - uvPos.Z) < 4.00 {
                    if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvOnCooldown(nowSim) {
                        this.m_sys.ShowWorldInteraction(7, n"cv_hub_uv_title", "Emisor UV Industrial", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                    } else {
                        this.m_sys.ShowWorldInteraction(3, n"cv_hub_uv_title", "Emisor UV Industrial", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (365 nm)", false, true);
                    }
                    return 0.20;
                }
                if distShrineSq <= 6.25 && AbsF(pPos.Z - shrinePos.Z) < 3.50 {
                    this.m_sys.ShowWorldInteraction(8, n"cv_hub_shrine_title", "Santuario de Northside", n"cv_act_shrine_combat_lock", "Santuario vigilado (Abate al Coro Pálido)", false, true);
                    return 0.20;
                }
            } else {
                let nearShrinePre: Bool = distShrineSq <= 9.00 && AbsF(pPos.Z - shrinePos.Z) < 3.50;
                let nearUvPre: Bool = distUvSq <= 16.00 && AbsF(pPos.Z - uvPos.Z) < 4.00;
                if nearShrinePre && (!nearUvPre || distShrineSq <= distUvSq) {
                    this.m_sys.ShowWorldInteraction(5, n"cv_hub_shrine_title", "Santuario de Northside", n"cv_act_inspect_shrine", "Examinar el santuario del Coro Pálido", false, true);
                    return 0.20;
                }
                if nearUvPre {
                    this.m_sys.ShowWorldInteraction(3, n"cv_hub_uv_title", "Emisor UV Industrial", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (365 nm)", false, true);
                    return 0.20;
                }
            }
        }

        this.m_sys.HideWorldInteraction();
        return 0.35;
    }
}
