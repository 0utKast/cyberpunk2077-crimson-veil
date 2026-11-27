// Velo Carmesí / Crimson Veil — Acto II en las Badlands: «Liturgia de Ceniza» (Juego Base 2.x, 0 ep1)
// Arquitectura lineal verificada:
// - Nivel 1 (Subnivel -1 · Nave de Diálisis): Sello Acceso -> Emisor UV -> Escuadra -> Puerta Nivel 2
// - Nivel 2 (Subnivel -2 · Santuario Carmesí & NOX-9B): Emisor UV -> Guardia -> Solís -> Biorreactor -> Extracción -> Azotea Misty
module CrimsonVeil

public class CrimsonVeilAct02Handler {
    private let m_sys: wref<CrimsonVeilSystem>;

    // Escena 1: Punto de descarga del convoy en Biotechnica Flats (3 pistas forenses)
    private let m_podId: EntityID;
    private let m_mateoShrineId: EntityID;
    private let m_desertRelayId: EntityID;
    private let m_flatsIntroPlayed: Bool;

    // Escena 2: Búnker clausurado de Biotechnica — Exterior (Guardia + Torre UV + Lucía Reyes + Compuerta)
    private let m_outerUvId: EntityID;
    private let m_surfaceHatchId: EntityID;
    private let m_sentryAId: EntityID;
    private let m_sentryBId: EntityID;
    private let m_luciaBunkerId: EntityID;
    private let m_luciaBunkerWsId: EntityID;

    // Escena 2B (Nivel 1): Subnivel -1 — Nave de Diálisis (zona 100 % abierta hasta puerta metálica X=57.05)
    private let m_sub1ExitHatchId: EntityID;
    private let m_sub1SealAId: EntityID;
    private let m_sub1UvId: EntityID;
    private let m_sub1TurretId: EntityID;
    private let m_sub1CamId: EntityID;
    private let m_sub1Level2DoorConsoleId: EntityID;
    private let m_sub1StalkerAId: EntityID;
    private let m_sub1StalkerBId: EntityID;
    private let m_sub1Fanatic1Id: EntityID;
    private let m_sub1Fanatic2Id: EntityID;
    private let m_sub1Fanatic3Id: EntityID;

    // Escena 2C (Nivel 2): Subnivel -2 — Santuario Carmesí & Cámara NOX-9B (0 puertas bloqueadas)
    private let m_sub2CorrUvId: EntityID;
    private let m_sub2TurretId: EntityID;
    private let m_sub2ExtractHatchId: EntityID;
    private let m_sub2ZealotAId: EntityID;
    private let m_sub2ZealotBId: EntityID;
    private let m_sub2FanaticCId: EntityID;
    private let m_sub2FanaticDId: EntityID;
    private let m_sub2FanaticEId: EntityID;
    private let m_chamberUvId: EntityID;
    private let m_nox9bChamberId: EntityID;

    private let m_solisId: EntityID;
    private let m_solisWsId: EntityID;
    private let m_solisGuardAId: EntityID;
    private let m_solisGuardBId: EntityID;
    private let m_solisReinfAId: EntityID;
    private let m_solisReinfBId: EntityID;

    // Escena 3: Azotea de Esoterica (Lucía Reyes rescatada junto a Misty)
    private let m_luciaRoofId: EntityID;
    private let m_luciaRoofWsId: EntityID;

    private let m_outerSpawnedA: Bool;
    private let m_outerSpawnedB: Bool;
    private let m_sub1SpawnedA: Bool;
    private let m_sub1SpawnedB: Bool;
    private let m_sub1SpawnedF1: Bool;
    private let m_sub1SpawnedF2: Bool;
    private let m_sub1SpawnedF3: Bool;
    private let m_sub2SpawnedZA: Bool;
    private let m_sub2SpawnedZB: Bool;
    private let m_sub2SpawnedFC: Bool;
    private let m_sub2SpawnedFD: Bool;
    private let m_sub2SpawnedFE: Bool;
    private let m_sub1TurretConfigured: Bool;
    private let m_sub1CamConfigured: Bool;
    private let m_sub2TurretConfigured: Bool;
    private let m_chamberSpawnedG1: Bool;
    private let m_chamberSpawnedG2: Bool;
    private let m_chamberSpawnedSolis: Bool;
    private let m_solisCombatSwapped: Bool;
    private let m_solisPhase2Triggered: Bool;
    private let m_bunkerArrivalPlayed: Bool;
    private let m_sub1ArrivalBannerShown: Bool;
    private let m_sub2ArrivalBannerShown: Bool;
    private let m_bunkerCombatStart: Float;
    private let m_sub1CombatStart: Float;
    private let m_sub2CombatStart: Float;
    private let m_chamberCombatStart: Float;
    private let m_outerClearBannerShown: Bool;
    private let m_chamberClearBannerShown: Bool;
    private let m_bunkerDayApplied: Bool;
    private let m_rooftopLuciaRelocated: Bool;

    // Cachés de cota real
    private let m_flatsPosCached: Bool;
    private let m_podPos: Vector4;
    private let m_mateoPos: Vector4;
    private let m_relayPos: Vector4;

    private let m_bunkerPosCached: Bool;
    private let m_outerUvPos: Vector4;
    private let m_surfaceHatchPos: Vector4;
    private let m_luciaPos: Vector4;
    private let m_sentryAPos: Vector4;
    private let m_sentryBPos: Vector4;

    private let m_sub1PosCached: Bool;
    private let m_sub1ExitHatchPos: Vector4;
    private let m_sub1SealAPos: Vector4;
    private let m_sub1UvPos: Vector4;
    private let m_sub1TurretPos: Vector4;
    private let m_sub1HallAnchorPos: Vector4;
    private let m_sub1Level2DoorConsolePos: Vector4;
    private let m_sub1Level2DoorTriggerPos: Vector4;
    private let m_sub1StalkerAPos: Vector4;
    private let m_sub1StalkerBPos: Vector4;
    private let m_sub1Fanatic1Pos: Vector4;
    private let m_sub1Fanatic2Pos: Vector4;
    private let m_sub1Fanatic3Pos: Vector4;

    private let m_sub2PosCached: Bool;
    private let m_sub2CorrUvPos: Vector4;
    private let m_sub2TurretPos: Vector4;
    private let m_sub2HallAnchorPos: Vector4;
    private let m_sub2ExtractHatchPos: Vector4;
    private let m_sub2ZealotAPos: Vector4;
    private let m_sub2ZealotBPos: Vector4;
    private let m_sub2FanaticCPos: Vector4;
    private let m_sub2FanaticDPos: Vector4;
    private let m_sub2FanaticEPos: Vector4;
    private let m_chamberUvPos: Vector4;
    private let m_corePos: Vector4;
    private let m_solisPos: Vector4;
    private let m_solisGuardAPos: Vector4;
    private let m_solisGuardBPos: Vector4;

    // Estado de llamada puente y sincronización
    private let m_callAttempted: Bool;
    private let m_callReadyTicks: Int32;
    private let m_lastSyncedStage: Int32;

    // -----------------------------------------------------------------------
    // Localizaciones 100 % Originales y Verificadas
    // -----------------------------------------------------------------------

    // 1. Biotechnica Flats — Punto de descarga del convoy (ma_bls_ina_se5_03)
    private final func GetFlatsArrivalPos() -> Vector4 = new Vector4(-746.50, -3635.00, 51.70, 1.00);
    private final func GetFlatsPodRawPos() -> Vector4 = new Vector4(-751.20, -3639.20, 51.70, 1.00);
    private final func GetFlatsMateoRawPos() -> Vector4 = new Vector4(-753.27, -3640.95, 51.72, 1.00);
    private final func GetFlatsRelayRawPos() -> Vector4 = new Vector4(-755.50, -3642.80, 51.70, 1.00);

    // 2. Superficie Búnker del Coro Pálido — Badlands Sur/NE (patio abierto ma_bls_ina_se5_15)
    private final func GetBunkerAnchorRawPos() -> Vector4 = new Vector4(-362.04, -2543.09, 27.23, 1.00);
    private final func GetBunkerArrivalPos() -> Vector4 = new Vector4(-370.00, -2548.00, 27.23, 1.00);
    private final func GetBunkerOuterUvRawPos() -> Vector4 = new Vector4(-364.50, -2544.50, 27.23, 1.00);
    private final func GetSurfaceHatchRawPos() -> Vector4 = new Vector4(-357.50, -2540.50, 27.23, 1.00);
    private final func GetSentryARawPos() -> Vector4 = new Vector4(-361.50, -2541.50, 27.23, 1.00);
    private final func GetSentryBRawPos() -> Vector4 = new Vector4(-358.50, -2545.00, 27.23, 1.00);
    private final func GetLuciaBunkerRawPos() -> Vector4 = new Vector4(-362.04, -2543.09, 27.23, 1.00);

    // 2B (Nivel 1). Subnivel -1 — Recorrido lineal estricto 1/4 -> 2/4 -> 3/4 -> 4/4 (X <= 55.60)
    private final func GetSubBunkerCenterPos() -> Vector4 = new Vector4(50.00, -498.00, -10.00, 1.00);
    private final func GetSub1EntryPos() -> Vector4 = new Vector4(31.50, -473.20, -5.74, 1.00);
    private final func GetSub1ExitHatchRawPos() -> Vector4 = new Vector4(33.50, -473.50, -5.74, 1.00);
    private final func GetSub1SealARawPos() -> Vector4 = new Vector4(36.20, -471.00, -5.74, 1.00);
    private final func GetSub1UvRawPos() -> Vector4 = new Vector4(42.00, -476.00, -5.65, 1.00);
    private final func GetSub1CamRawPos() -> Vector4 = new Vector4(44.00, -478.00, -2.80, 1.00);
    private final func GetSub1TurretRawPos() -> Vector4 = new Vector4(46.00, -482.00, -5.40, 1.00);
    private final func GetSub1HallAnchorRawPos() -> Vector4 = new Vector4(47.00, -482.00, -5.40, 1.00);
    private final func GetSub1StalkerARawPos() -> Vector4 = new Vector4(44.50, -471.50, -5.70, 1.00);
    private final func GetSub1Fanatic1RawPos() -> Vector4 = new Vector4(50.50, -475.00, -5.65, 1.00);
    private final func GetSub1Fanatic2RawPos() -> Vector4 = new Vector4(48.50, -486.00, -5.40, 1.00);
    private final func GetSub1StalkerBRawPos() -> Vector4 = new Vector4(47.50, -487.00, -5.40, 1.00);
    private final func GetSub1Fanatic3RawPos() -> Vector4 = new Vector4(54.20, -484.50, -4.70, 1.00);
    private final func GetSub1Level2DoorConsoleRawPos() -> Vector4 = new Vector4(55.60, -484.20, -4.70, 1.00);
    private final func GetSub1Level2DoorTriggerRawPos() -> Vector4 = new Vector4(55.50, -482.50, -4.70, 1.00);

    // 2C (Nivel 2). Subnivel -2 — Santuario Carmesí & Cámara NOX-9B (todas auditadas CLEAR Oodle, 0 puertas cerradas)
    private final func GetSub2EntryPos() -> Vector4 = new Vector4(69.35, -495.78, -16.66, 1.00);
    private final func GetSub2CorrUvRawPos() -> Vector4 = new Vector4(62.50, -498.00, -16.66, 1.00);
    private final func GetSub2TurretRawPos() -> Vector4 = new Vector4(56.00, -498.00, -16.66, 1.00);
    private final func GetSub2HallAnchorRawPos() -> Vector4 = new Vector4(59.31, -500.93, -16.66, 1.00);
    private final func GetSub2ZealotARawPos() -> Vector4 = new Vector4(60.00, -496.00, -16.66, 1.00);
    private final func GetSub2ZealotBRawPos() -> Vector4 = new Vector4(58.00, -504.00, -16.66, 1.00);
    private final func GetSub2FanaticCRawPos() -> Vector4 = new Vector4(62.00, -503.00, -16.66, 1.00);
    private final func GetSub2FanaticDRawPos() -> Vector4 = new Vector4(56.00, -504.00, -16.66, 1.00);
    private final func GetSub2FanaticERawPos() -> Vector4 = new Vector4(54.50, -514.00, -16.70, 1.00);
    private final func GetSub2ExtractHatchRawPos() -> Vector4 = new Vector4(52.50, -520.00, -16.70, 1.00);
    private final func GetChamberUvRawPos() -> Vector4 = new Vector4(49.20, -528.80, -16.70, 1.00);
    private final func GetChamberCoreRawPos() -> Vector4 = new Vector4(47.00, -532.80, -16.70, 1.00);
    private final func GetSolisRawPos() -> Vector4 = new Vector4(48.60, -531.80, -16.70, 1.00);
    private final func GetSolisGuardARawPos() -> Vector4 = new Vector4(46.40, -530.50, -16.70, 1.00);
    private final func GetSolisGuardBRawPos() -> Vector4 = new Vector4(50.80, -532.20, -16.70, 1.00);
    private final func GetSolisArrivalDebugPos() -> Vector4 = new Vector4(48.50, -527.20, -16.70, 1.00);

    // 3. Azotea de Misty's Esoterica (Lucía rescatada dentro de la terraza, junto a Misty)
    private final func GetLuciaRooftopPos() -> Vector4 = new Vector4(-1549.95, 1208.95, 57.00, 1.00);
    private final func GetRooftopPlayerRefPos() -> Vector4 = new Vector4(-1548.80, 1208.15, 57.05, 1.00);

    private final func ComputeFacingYaw(fromPos: Vector4, toPos: Vector4) -> Float {
        let dx: Float = toPos.X - fromPos.X;
        let dy: Float = toPos.Y - fromPos.Y;
        return Rad2Deg(AtanF(dy, dx)) - 90.00;
    }

    public final func IsInSubterraneanBunker(pPos: Vector4) -> Bool {
        if !IsDefined(this.m_sys) || pPos.Z > 12.00 {
            return false;
        }
        let c: Vector4 = this.GetSubBunkerCenterPos();
        let dx: Float = pPos.X - c.X;
        let dy: Float = pPos.Y - c.Y;
        return (dx * dx + dy * dy) <= 7225.00;
    }

    private final func IsVanillaQ105Active(qs: ref<QuestsSystem>) -> Bool {
        if !IsDefined(qs) || qs.GetFact(n"q105_03_active") == 0 || qs.GetFact(n"q105_03_done") > 0 {
            return false;
        }
        if IsDefined(this.m_sys) && this.m_sys.IsCrimsonVeilQuestTrackedInJournal() {
            return false;
        }
        return true;
    }

    public final func Initialize(sys: ref<CrimsonVeilSystem>) -> Void {
        this.m_sys = sys;
        this.ResetTransientFlags();
    }

    private final func ResetTransientFlags() -> Void {
        this.m_flatsIntroPlayed = false;
        this.m_outerSpawnedA = false;
        this.m_outerSpawnedB = false;
        this.m_sub1SpawnedA = false;
        this.m_sub1SpawnedB = false;
        this.m_sub1SpawnedF1 = false;
        this.m_sub1SpawnedF2 = false;
        this.m_sub1SpawnedF3 = false;
        this.m_sub2SpawnedZA = false;
        this.m_sub2SpawnedZB = false;
        this.m_sub2SpawnedFC = false;
        this.m_sub2SpawnedFD = false;
        this.m_sub2SpawnedFE = false;
        this.m_sub1TurretConfigured = false;
        this.m_sub1CamConfigured = false;
        this.m_sub2TurretConfigured = false;
        this.m_chamberSpawnedG1 = false;
        this.m_chamberSpawnedG2 = false;
        this.m_chamberSpawnedSolis = false;
        this.m_solisCombatSwapped = false;
        this.m_solisPhase2Triggered = false;
        this.m_bunkerArrivalPlayed = false;
        this.m_sub1ArrivalBannerShown = false;
        this.m_sub2ArrivalBannerShown = false;
        this.m_bunkerCombatStart = 0.00;
        this.m_sub1CombatStart = 0.00;
        this.m_sub2CombatStart = 0.00;
        this.m_chamberCombatStart = 0.00;
        this.m_outerClearBannerShown = false;
        this.m_chamberClearBannerShown = false;
        this.m_bunkerDayApplied = false;
        this.m_rooftopLuciaRelocated = false;
        this.m_flatsPosCached = false;
        this.m_bunkerPosCached = false;
        this.m_sub1PosCached = false;
        this.m_sub2PosCached = false;
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
        this.m_lastSyncedStage = -1;
    }

    public final func GetLuciaEntityID() -> EntityID {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
            let pPos: Vector4 = player.GetWorldPosition();
            if pPos.Z >= 38.00 && EntityID.IsDefined(this.m_luciaRoofId) && IsDefined(des) && des.IsSpawned(this.m_luciaRoofId) {
                return this.m_luciaRoofId;
            }
        }
        return this.m_luciaBunkerId;
    }

    public final func GetSolisEntityID() -> EntityID = this.m_solisId;

    public final func OnSaveRestored() -> Void {
        this.m_podId = new EntityID();
        this.m_mateoShrineId = new EntityID();
        this.m_desertRelayId = new EntityID();
        this.m_outerUvId = new EntityID();
        this.m_surfaceHatchId = new EntityID();
        this.m_sentryAId = new EntityID();
        this.m_sentryBId = new EntityID();
        this.m_luciaBunkerId = new EntityID();
        this.m_luciaBunkerWsId = new EntityID();
        this.m_sub1ExitHatchId = new EntityID();
        this.m_sub1SealAId = new EntityID();
        this.m_sub1UvId = new EntityID();
        this.m_sub1TurretId = new EntityID();
        this.m_sub1CamId = new EntityID();
        this.m_sub1Level2DoorConsoleId = new EntityID();
        this.m_sub1StalkerAId = new EntityID();
        this.m_sub1StalkerBId = new EntityID();
        this.m_sub1Fanatic1Id = new EntityID();
        this.m_sub1Fanatic2Id = new EntityID();
        this.m_sub1Fanatic3Id = new EntityID();
        this.m_sub2CorrUvId = new EntityID();
        this.m_sub2TurretId = new EntityID();
        this.m_sub2ExtractHatchId = new EntityID();
        this.m_sub2ZealotAId = new EntityID();
        this.m_sub2ZealotBId = new EntityID();
        this.m_sub2FanaticCId = new EntityID();
        this.m_sub2FanaticDId = new EntityID();
        this.m_sub2FanaticEId = new EntityID();
        this.m_chamberUvId = new EntityID();
        this.m_nox9bChamberId = new EntityID();
        this.m_solisId = new EntityID();
        this.m_solisWsId = new EntityID();
        this.m_solisGuardAId = new EntityID();
        this.m_solisGuardBId = new EntityID();
        this.m_solisReinfAId = new EntityID();
        this.m_solisReinfBId = new EntityID();
        this.m_luciaRoofId = new EntityID();
        this.m_luciaRoofWsId = new EntityID();
        this.ResetTransientFlags();
    }

    public final func ResetPendingAct2CallForRetry() -> Void {
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
        if IsDefined(this.m_sys) {
            let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
            if IsDefined(qs) && qs.GetFact(n"cv_a2_state") == 5 {
                qs.SetFact(n"cv_a2_state", 0);
            }
        }
    }

    public final func DespawnSub1EntitiesOnly() -> Void {
        if IsDefined(this.m_sys) {
            this.m_sys.DespawnStaticPropById(this.m_sub1ExitHatchId);
            this.m_sys.DespawnStaticPropById(this.m_sub1SealAId);
            this.m_sys.DespawnStaticPropById(this.m_sub1UvId);
            this.m_sys.DespawnStaticPropById(this.m_sub1TurretId);
            this.m_sys.DespawnStaticPropById(this.m_sub1CamId);
            this.m_sys.DespawnStaticPropById(this.m_sub1Level2DoorConsoleId);
        }
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        if IsDefined(ses) {
            ses.DespawnTagged(n"CV_A2_Sub1ExitHatch");
            ses.DespawnTagged(n"CV_A2_Sub1SealA");
            ses.DespawnTagged(n"CV_A2_Sub1Uv");
            ses.DespawnTagged(n"CV_A2_Sub1Turret");
            ses.DespawnTagged(n"CV_A2_Sub1Cam");
            ses.DespawnTagged(n"CV_A2_Sub1Level2Door");
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_A2_LabStalkerA");
            des.DeleteTagged(n"CV_A2_LabStalkerB");
            des.DeleteTagged(n"CV_A2_Sub1Fanatic1");
            des.DeleteTagged(n"CV_A2_Sub1Fanatic2");
            des.DeleteTagged(n"CV_A2_Sub1Fanatic3");
        }
        this.m_sub1ExitHatchId = new EntityID();
        this.m_sub1SealAId = new EntityID();
        this.m_sub1UvId = new EntityID();
        this.m_sub1TurretId = new EntityID();
        this.m_sub1CamId = new EntityID();
        this.m_sub1Level2DoorConsoleId = new EntityID();
        this.m_sub1StalkerAId = new EntityID();
        this.m_sub1StalkerBId = new EntityID();
        this.m_sub1Fanatic1Id = new EntityID();
        this.m_sub1Fanatic2Id = new EntityID();
        this.m_sub1Fanatic3Id = new EntityID();
        this.m_sub1SpawnedA = false;
        this.m_sub1SpawnedB = false;
        this.m_sub1SpawnedF1 = false;
        this.m_sub1SpawnedF2 = false;
        this.m_sub1SpawnedF3 = false;
        this.m_sub1TurretConfigured = false;
        this.m_sub1CamConfigured = false;
    }

    public final func DespawnSubterraneanEntities() -> Void {
        this.DespawnSub1EntitiesOnly();
        if IsDefined(this.m_sys) {
            this.m_sys.StopNpcWorkspotById(this.m_solisId);
            this.m_sys.RemoveNpcImmortal(this.m_solisId);
            this.m_sys.DespawnStaticPropById(this.m_sub2CorrUvId);
            this.m_sys.DespawnStaticPropById(this.m_sub2TurretId);
            this.m_sys.DespawnStaticPropById(this.m_sub2ExtractHatchId);
            this.m_sys.DespawnStaticPropById(this.m_chamberUvId);
            this.m_sys.DespawnStaticPropById(this.m_nox9bChamberId);
            this.m_sys.SetSubterraneanBunkerEnvActive(false);
        }
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        if IsDefined(ses) {
            ses.DespawnTagged(n"CV_A2_Sub2CorrUv");
            ses.DespawnTagged(n"CV_A2_Sub2Turret");
            ses.DespawnTagged(n"CV_A2_Sub2ExtractHatch");
            ses.DespawnTagged(n"CV_A2_ChamberUv");
            ses.DespawnTagged(n"CV_A2_Nox9bChamber");
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_A2_Sub2ZealotA");
            des.DeleteTagged(n"CV_A2_Sub2ZealotB");
            des.DeleteTagged(n"CV_A2_Sub2FanaticC");
            des.DeleteTagged(n"CV_A2_Sub2FanaticD");
            des.DeleteTagged(n"CV_A2_Sub2FanaticE");
            des.DeleteTagged(n"CV_A2_Solis");
            des.DeleteTagged(n"CV_WS_Solis");
            des.DeleteTagged(n"CV_A2_SolisCombat");
            des.DeleteTagged(n"CV_A2_SolisGuardA");
            des.DeleteTagged(n"CV_A2_SolisGuardB");
            des.DeleteTagged(n"CV_A2_SolisGuardACombat");
            des.DeleteTagged(n"CV_A2_SolisGuardBCombat");
            des.DeleteTagged(n"CV_A2_SolisReinfA");
            des.DeleteTagged(n"CV_A2_SolisReinfB");
        }
        this.m_sub2CorrUvId = new EntityID();
        this.m_sub2TurretId = new EntityID();
        this.m_sub2ExtractHatchId = new EntityID();
        this.m_sub2ZealotAId = new EntityID();
        this.m_sub2ZealotBId = new EntityID();
        this.m_sub2FanaticCId = new EntityID();
        this.m_sub2FanaticDId = new EntityID();
        this.m_sub2FanaticEId = new EntityID();
        this.m_chamberUvId = new EntityID();
        this.m_nox9bChamberId = new EntityID();
        this.m_solisId = new EntityID();
        this.m_solisWsId = new EntityID();
        this.m_solisGuardAId = new EntityID();
        this.m_solisGuardBId = new EntityID();
        this.m_solisReinfAId = new EntityID();
        this.m_solisReinfBId = new EntityID();
        this.m_sub2SpawnedZA = false;
        this.m_sub2SpawnedZB = false;
        this.m_sub2SpawnedFC = false;
        this.m_sub2SpawnedFD = false;
        this.m_sub2SpawnedFE = false;
        this.m_sub2TurretConfigured = false;
        this.m_chamberSpawnedG1 = false;
        this.m_chamberSpawnedG2 = false;
        this.m_chamberSpawnedSolis = false;
        this.m_solisCombatSwapped = false;
        this.m_solisPhase2Triggered = false;
    }

    public final func CleanupEntities() -> Void {
        if IsDefined(this.m_sys) {
            this.m_sys.DespawnStaticPropById(this.m_podId);
            this.m_sys.DespawnStaticPropById(this.m_mateoShrineId);
            this.m_sys.DespawnStaticPropById(this.m_desertRelayId);
            this.m_sys.DespawnStaticPropById(this.m_outerUvId);
            this.m_sys.DespawnStaticPropById(this.m_surfaceHatchId);
        }
        this.DespawnSubterraneanEntities();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_A2_SentryA");
            des.DeleteTagged(n"CV_A2_SentryB");
            des.DeleteTagged(n"CV_A2_LuciaBunker");
            des.DeleteTagged(n"CV_WS_LuciaBunker");
            des.DeleteTagged(n"CV_A2_LuciaRoof");
            des.DeleteTagged(n"CV_WS_LuciaRoof");
        }
        this.OnSaveRestored();
    }

    private final func GetAllAct2PinPaths() -> array<String> {
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        return [
            p + "/01_a2_flats_convoy/mp_a2_flats",
            p + "/02_a2_bunker_lucia/mp_a2_bunker_lucia",
            p + "/02b_a2_enter_bunker/mp_a2_surface_hatch",
            p + "/02c_a2_sub1_seal_a/mp_a2_seal_a",
            p + "/02d_a2_sub1_uv_tower/mp_a2_uv_tower",
            p + "/02e_a2_sub1_clear_hall/mp_a2_clear_hall",
            p + "/02f_a2_sub1_level2_door/mp_a2_level2_door",
            p + "/03a_a2_sub2_uv_tower/mp_a2_sub2_uv",
            p + "/03b_a2_sub2_clear_hall/mp_a2_sub2_clear",
            p + "/03c_a2_solis_chamber/mp_a2_solis",
            p + "/04_a2_secure_core/mp_a2_core",
            p + "/05_a2_sub2_extract/mp_a2_sub2_extract",
            p + "/06_a2_return_misty/mp_a2_return_misty"
        ];
    }

    private final func EnsureAct2ObjectiveState(jm: ref<JournalManager>, objPath: String, targetState: gameJournalEntryState) -> Void {
        if !IsDefined(jm) {
            return;
        }
        let entry: wref<JournalEntry> = jm.GetEntryByString(objPath, "gameJournalQuestObjective");
        if IsDefined(entry) && NotEquals(jm.GetEntryState(entry), targetState) {
            jm.ChangeEntryState(objPath, "gameJournalQuestObjective", targetState, JournalNotifyOption.DoNotNotify);
        }
    }

    private final func SetAct2ObjectivesInactive(jm: ref<JournalManager>, paths: array<String>) -> Void {
        for objPath in paths {
            this.EnsureAct2ObjectiveState(jm, objPath, gameJournalEntryState.Inactive);
        }
    }

    private final func SetAct2ObjectivesSucceeded(jm: ref<JournalManager>, paths: array<String>) -> Void {
        for objPath in paths {
            this.EnsureAct2ObjectiveState(jm, objPath, gameJournalEntryState.Succeeded);
        }
    }

    private final func EnsurePriorActsClosed() -> Void {
        if !IsDefined(this.m_sys) {
            return;
        }
        this.m_sys.AbortPrologueCallAndSpeech();
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_done", 1);
            qs.SetFact(n"cv_a1_state", 50);
        }
        let pr2: String = "quests/side_quest/crimson_veil_r2_quest/phase_r2";
        let pa1: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
        let priorPins: array<String> = [
            pr2 + "/01_r2_alley/mp_r2_alley",
            pr2 + "/02_r2_scan/mp_r2_scan",
            pr2 + "/03_r2_rooftop/mp_r2_rooftop",
            pr2 + "/04_r2_oilfields/mp_r2_oilfields",
            pr2 + "/05_r2_evidence/mp_r2_evidence",
            pr2 + "/06_r2_debrief/mp_r2_debrief",
            pa1 + "/01_a1_kabuki_trace/mp_a1_kabuki",
            pa1 + "/02_a1_valdes_hideout/mp_a1_valdes",
            pa1 + "/03_a1_waterfront_cryo/mp_a1_waterfront",
            pa1 + "/04_a1_return_misty/mp_a1_return_misty"
        ];
        this.m_sys.DeactivateJournalPinList(priorPins);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        if IsDefined(jm) {
            jm.ChangeEntryState(pr2 + "/01_r2_alley", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pr2 + "/02_r2_scan", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pr2 + "/03_r2_rooftop", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pr2 + "/04_r2_oilfields", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pr2 + "/05_r2_evidence", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pr2 + "/06_r2_debrief", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState("quests/side_quest/crimson_veil_r2_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pa1 + "/01_a1_kabuki_trace", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pa1 + "/02_a1_valdes_hideout", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pa1 + "/03_a1_waterfront_cryo", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState(pa1 + "/04_a1_return_misty", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            jm.ChangeEntryState("quests/side_quest/crimson_veil_a1_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
        }
    }

    private final func SyncStageJournalAndPin(stage: Int32, notify: Bool) -> Void {
        if !IsDefined(this.m_sys) || stage < 10 {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let q: String = "quests/side_quest/crimson_veil_a2_quest";
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        let allPins: array<String> = this.GetAllAct2PinPaths();

        let playerObj: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let inSub: Bool = false;
        let pZ: Float = 27.23;
        if IsDefined(playerObj) {
            let pPosSync: Vector4 = playerObj.GetWorldPosition();
            inSub = this.IsInSubterraneanBunker(pPosSync);
            pZ = pPosSync.Z;
        }

        if stage == 10 {
            this.SetAct2ObjectivesInactive(jm, [
                p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
                p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
            ]);
            this.m_sys.ActivateObjectiveWithPin(210, q, p, p + "/01_a2_flats_convoy", p + "/01_a2_flats_convoy/mp_a2_flats", p + "/01_a2_flats_convoy/desc_a2_01", allPins, notify);
            this.m_sys.UpdateFallbackMappin(210, p + "/01_a2_flats_convoy", new Vector4(-753.27, -3640.95, 52.80, 1.00), n"cv_mappin_a2_flats", "Biotechnica Flats: Convoy NOX-9 (3 Pistas)");
        } else if stage == 20 {
            this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy"]);
            this.SetAct2ObjectivesInactive(jm, [
                p + "/02b_a2_enter_bunker",
                p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
            ]);
            this.m_sys.ActivateObjectiveWithPin(220, q, p, p + "/02_a2_bunker_lucia", p + "/02_a2_bunker_lucia/mp_a2_bunker_lucia", p + "/02_a2_bunker_lucia/desc_a2_02", allPins, notify);
            this.m_sys.UpdateFallbackMappin(220, p + "/02_a2_bunker_lucia", new Vector4(-362.04, -2543.09, 28.40, 1.00), n"cv_mappin_a2_bunker", "Búnker de Biotechnica (Badlands): Rescatar a Lucía");
        } else if stage == 25 || stage == 30 {
            this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia"]);
            let sealAOkSync: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_seal_a") > 0;
            let uvDoneSync: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_uv_done") > 0;
            let hallClearedSync: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_cleared") > 0;
            let sub2UvSync: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_uv_done") > 0;
            let corrClearedSync: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_corr_cleared") > 0;

            if !inSub {
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let tag2b: Int32 = (stage == 25) ? 225 : 231;
                let obj2b: String = p + "/02b_a2_enter_bunker";
                this.m_sys.ActivateObjectiveWithPin(tag2b, q, p, obj2b, obj2b + "/mp_a2_surface_hatch", obj2b + "/desc_a2_02b", allPins, notify);
                this.m_sys.UpdateFallbackMappin(tag2b, obj2b, new Vector4(-357.50, -2540.50, 28.88, 1.00), n"cv_act_hatch_enter", "[ENTRADA BÚNKER] Escotilla de acceso al Subnivel -1");
            } else if stage == 25 && !sealAOkSync {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj2c: String = p + "/02c_a2_sub1_seal_a";
                this.m_sys.ActivateObjectiveWithPin(226, q, p, obj2c, obj2c + "/mp_a2_seal_a", obj2c + "/desc_a2_02c", allPins, notify);
                this.m_sys.UpdateFallbackMappin(226, obj2c, new Vector4(36.20, -471.00, -4.90, 1.00), n"cv_hub_seal_a", "[1/4 · NIVEL 1] Purgar sello de acceso");
            } else if stage == 25 && !uvDoneSync {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj2d: String = p + "/02d_a2_sub1_uv_tower";
                this.m_sys.ActivateObjectiveWithPin(227, q, p, obj2d, obj2d + "/mp_a2_uv_tower", obj2d + "/desc_a2_02d", allPins, notify);
                this.m_sys.UpdateFallbackMappin(227, obj2d, new Vector4(42.00, -476.00, -4.60, 1.00), n"cv_pin_uv_tower", "[2/4 · EMISOR UV] Sobrecargar Emisor UV (365 nm)");
            } else if stage == 25 && !hallClearedSync {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/02f_a2_sub1_level2_door",
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj2e: String = p + "/02e_a2_sub1_clear_hall";
                this.m_sys.ActivateObjectiveWithPin(228, q, p, obj2e, obj2e + "/mp_a2_clear_hall", obj2e + "/desc_a2_02e", allPins, notify);
                this.m_sys.UpdateFallbackMappin(228, obj2e, new Vector4(47.00, -482.00, -4.30, 1.00), n"cv_pin_clear_hall", "[3/4 · NAVE DE DIÁLISIS] Eliminar escuadra del Coro Pálido");
            } else if pZ > -10.50 {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj2f: String = p + "/02f_a2_sub1_level2_door";
                this.m_sys.ActivateObjectiveWithPin(229, q, p, obj2f, obj2f + "/mp_a2_level2_door", obj2f + "/desc_a2_02f", allPins, notify);
                this.m_sys.UpdateFallbackMappin(229, obj2f, new Vector4(55.50, -482.50, -3.90, 1.00), n"cv_pin_level2_door", "[4/4 · NIVEL 1] Puerta de entrada al Nivel 2");
            } else if !sub2UvSync {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                    p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj3a: String = p + "/03a_a2_sub2_uv_tower";
                this.m_sys.ActivateObjectiveWithPin(232, q, p, obj3a, obj3a + "/mp_a2_sub2_uv", obj3a + "/desc_a2_03a", allPins, notify);
                this.m_sys.UpdateFallbackMappin(232, obj3a, new Vector4(62.50, -498.00, -15.60, 1.00), n"cv_pin_sub2_uv", "[1/5 · EMISOR UV CORREDOR] Sobrecargar Emisor UV (365 nm)");
            } else if !corrClearedSync {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door", p + "/03a_a2_sub2_uv_tower"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/03c_a2_solis_chamber", p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
                ]);
                let obj3b: String = p + "/03b_a2_sub2_clear_hall";
                this.m_sys.ActivateObjectiveWithPin(233, q, p, obj3b, obj3b + "/mp_a2_sub2_clear", obj3b + "/desc_a2_03b", allPins, notify);
                this.m_sys.UpdateFallbackMappin(233, obj3b, new Vector4(59.31, -500.93, -15.50, 1.00), n"cv_pin_sub2_clear", "[2/5 · CORREDOR] Eliminar guardia del Coro Pálido");
            } else {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door", p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall"]);
                this.SetAct2ObjectivesInactive(jm, [p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"]);
                let obj3c: String = p + "/03c_a2_solis_chamber";
                this.m_sys.ActivateObjectiveWithPin(230, q, p, obj3c, obj3c + "/mp_a2_solis", obj3c + "/desc_a2_03c", allPins, notify);
                this.m_sys.UpdateFallbackMappin(230, obj3c, new Vector4(48.60, -531.80, -15.05, 1.00), n"cv_mappin_a2_solis", "[3/5 · SUBNIVEL -2] Confrontar a Dra. Helena Solís («La Cantora»)");
            }
        } else if stage == 40 {
            this.SetAct2ObjectivesSucceeded(jm, [
                p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
                p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber"
            ]);
            this.SetAct2ObjectivesInactive(jm, [p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"]);
            let obj4: String = p + "/04_a2_secure_core";
            this.m_sys.ActivateObjectiveWithPin(240, q, p, obj4, obj4 + "/mp_a2_core", obj4 + "/desc_a2_04", allPins, notify);
            this.m_sys.UpdateFallbackMappin(240, obj4, new Vector4(47.00, -532.80, -15.05, 1.00), n"cv_hub_core_title", "[4/5 · BIORREACTOR] Asegurar o purgar NOX-9B");
        } else if stage == 50 {
            this.SetAct2ObjectivesSucceeded(jm, [
                p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
                p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber", p + "/04_a2_secure_core"
            ]);
            if inSub {
                this.SetAct2ObjectivesInactive(jm, [p + "/06_a2_return_misty"]);
                let obj5: String = p + "/05_a2_sub2_extract";
                this.m_sys.ActivateObjectiveWithPin(252, q, p, obj5, obj5 + "/mp_a2_sub2_extract", obj5 + "/desc_a2_05_extract", allPins, notify);
                this.m_sys.UpdateFallbackMappin(252, obj5, new Vector4(52.50, -520.00, -15.60, 1.00), n"cv_hub_hatch_extract", "[5/5 · EVACUACIÓN] Conducto de extracción a la superficie");
            } else {
                this.SetAct2ObjectivesSucceeded(jm, [p + "/05_a2_sub2_extract"]);
                let obj6: String = p + "/06_a2_return_misty";
                this.m_sys.ActivateObjectiveWithPin(250, q, p, obj6, obj6 + "/mp_a2_return_misty", obj6 + "/desc_a2_05", allPins, notify);
                this.m_sys.UpdateFallbackMappin(250, obj6, new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_a2_return_misty", "Azotea de Misty (Little China): Reunirse con Misty y Lucía");
            }
        } else if stage >= 60 {
            this.SetAct2ObjectivesSucceeded(jm, [
                p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
                p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
                p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
            ]);
            this.m_sys.ClearJournalPinsAndResetSync(allPins);
            this.m_sys.ClearMappin();
        }
        this.m_sys.SyncCodexJournalShards();
        this.m_lastSyncedStage = stage;
    }

    private final func SyncActiveStageMappin(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) || stage < 10 || stage >= 60 {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let q: String = "quests/side_quest/crimson_veil_a2_quest";
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        let allPins: array<String> = this.GetAllAct2PinPaths();
        let pPos: Vector4 = player.GetWorldPosition();
        let inSub: Bool = this.IsInSubterraneanBunker(pPos);

        if stage == 10 {
            this.m_sys.SyncObjectivePinLoop(210, q, p, p + "/01_a2_flats_convoy", p + "/01_a2_flats_convoy/mp_a2_flats", allPins);
            this.m_sys.UpdateFallbackMappin(210, p + "/01_a2_flats_convoy", new Vector4(-753.27, -3640.95, 52.80, 1.00), n"cv_mappin_a2_flats", "Biotechnica Flats: Convoy NOX-9 (3 Pistas)");
        } else if stage == 20 {
            let outerCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_bunker_cleared") > 0;
            if this.m_sys.ComputeDistanceSq(pPos, this.GetBunkerArrivalPos()) <= 6400.00 {
                this.EnsureBunkerCache();
            }
            this.m_sys.SyncObjectivePinLoop(220, q, p, p + "/02_a2_bunker_lucia", p + "/02_a2_bunker_lucia/mp_a2_bunker_lucia", allPins);
            if outerCleared {
                let lPin: Vector4 = this.m_bunkerPosCached ? this.m_luciaPos : this.GetLuciaBunkerRawPos();
                lPin.Z += 1.80;
                this.m_sys.UpdateFallbackMappin(220, p + "/02_a2_bunker_lucia", lPin, n"cv_act_talk_lucia", "Hablar con Lucía Reyes");
            } else {
                let oPin: Vector4 = this.m_bunkerPosCached ? this.m_luciaPos : new Vector4(-362.04, -2543.09, 28.40, 1.00);
                if this.m_bunkerPosCached {
                    oPin.Z += 1.20;
                }
                this.m_sys.UpdateFallbackMappin(220, p + "/02_a2_bunker_lucia", oPin, n"cv_mappin_a2_bunker", "Búnker de Biotechnica (Badlands): Abate a la guardia UV");
            }
        } else if stage == 25 || stage == 30 {
            if !inSub {
                if this.m_sys.ComputeDistanceSq(pPos, this.GetBunkerArrivalPos()) <= 6400.00 {
                    this.EnsureBunkerCache();
                }
                let obj2b: String = p + "/02b_a2_enter_bunker";
                this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia"]);
                this.SetAct2ObjectivesInactive(jm, [
                    p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
                    p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber"
                ]);
                let tag2b: Int32 = (stage == 25) ? 225 : 231;
                let hPin: Vector4 = this.m_bunkerPosCached ? this.m_surfaceHatchPos : this.GetSurfaceHatchRawPos();
                hPin.Z += 1.65;
                this.m_sys.SyncObjectivePinLoop(tag2b, q, p, obj2b, obj2b + "/mp_a2_surface_hatch", allPins);
                this.m_sys.UpdateFallbackMappin(tag2b, obj2b, hPin, n"cv_act_hatch_enter", "[ENTRADA BÚNKER] Escotilla de acceso al Subnivel -1");
            } else if stage == 25 || pPos.Z > -10.50 {
                let sealAOk: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_seal_a") > 0;
                let uvDone: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_uv_done") > 0;
                let hallCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_cleared") > 0;
                if stage == 25 && !sealAOk {
                    let obj2c: String = p + "/02c_a2_sub1_seal_a";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker"]);
                    this.SetAct2ObjectivesInactive(jm, [p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door"]);
                    let s1Pin: Vector4 = this.m_sub1PosCached ? this.m_sub1SealAPos : this.GetSub1SealARawPos();
                    s1Pin.Z += 0.85;
                    this.m_sys.SyncObjectivePinLoop(226, q, p, obj2c, obj2c + "/mp_a2_seal_a", allPins);
                    this.m_sys.UpdateFallbackMappin(226, obj2c, s1Pin, n"cv_hub_seal_a", "[1/4 · NIVEL 1] Purgar sello de acceso");
                } else if stage == 25 && !uvDone {
                    let obj2d: String = p + "/02d_a2_sub1_uv_tower";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a"]);
                    this.SetAct2ObjectivesInactive(jm, [p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door"]);
                    let uvPin: Vector4 = this.m_sub1PosCached ? this.m_sub1UvPos : this.GetSub1UvRawPos();
                    uvPin.Z += 1.05;
                    this.m_sys.SyncObjectivePinLoop(227, q, p, obj2d, obj2d + "/mp_a2_uv_tower", allPins);
                    this.m_sys.UpdateFallbackMappin(227, obj2d, uvPin, n"cv_pin_uv_tower", "[2/4 · EMISOR UV] Sobrecargar Emisor UV (365 nm)");
                } else if stage == 25 && !hallCleared {
                    let obj2e: String = p + "/02e_a2_sub1_clear_hall";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower"]);
                    this.SetAct2ObjectivesInactive(jm, [p + "/02f_a2_sub1_level2_door"]);
                    let hPin2: Vector4 = this.m_sub1PosCached ? this.m_sub1HallAnchorPos : this.GetSub1HallAnchorRawPos();
                    hPin2.Z += 1.10;
                    this.m_sys.SyncObjectivePinLoop(228, q, p, obj2e, obj2e + "/mp_a2_clear_hall", allPins);
                    this.m_sys.UpdateFallbackMappin(228, obj2e, hPin2, n"cv_pin_clear_hall", "[3/4 · NAVE DE DIÁLISIS] Eliminar escuadra del Coro Pálido");
                } else {
                    let obj2f: String = p + "/02f_a2_sub1_level2_door";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall"]);
                    this.SetAct2ObjectivesInactive(jm, [p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber"]);
                    let dPin: Vector4 = this.m_sub1PosCached ? this.m_sub1Level2DoorTriggerPos : this.GetSub1Level2DoorTriggerRawPos();
                    dPin.Z += 0.80;
                    this.m_sys.SyncObjectivePinLoop(229, q, p, obj2f, obj2f + "/mp_a2_level2_door", allPins);
                    this.m_sys.UpdateFallbackMappin(229, obj2f, dPin, n"cv_pin_level2_door", "[4/4 · NIVEL 1] Puerta de entrada al Nivel 2");
                }
            } else {
                // Nivel 2 (Subnivel -2): 1/5 Emisor UV -> 2/5 Guardia -> 3/5 Helena Solís
                let sub2UvDone: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_uv_done") > 0;
                let corrCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_corr_cleared") > 0;
                this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker", p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door"]);
                if !sub2UvDone {
                    let obj3a: String = p + "/03a_a2_sub2_uv_tower";
                    this.SetAct2ObjectivesInactive(jm, [p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber"]);
                    let uv2Pin: Vector4 = this.m_sub2PosCached ? this.m_sub2CorrUvPos : this.GetSub2CorrUvRawPos();
                    uv2Pin.Z += 1.06;
                    this.m_sys.SyncObjectivePinLoop(232, q, p, obj3a, obj3a + "/mp_a2_sub2_uv", allPins);
                    this.m_sys.UpdateFallbackMappin(232, obj3a, uv2Pin, n"cv_pin_sub2_uv", "[1/5 · EMISOR UV CORREDOR] Sobrecargar Emisor UV (365 nm)");
                } else if !corrCleared {
                    let obj3b: String = p + "/03b_a2_sub2_clear_hall";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/03a_a2_sub2_uv_tower"]);
                    this.SetAct2ObjectivesInactive(jm, [p + "/03c_a2_solis_chamber"]);
                    let c2Pin: Vector4 = this.m_sub2PosCached ? this.m_sub2HallAnchorPos : this.GetSub2HallAnchorRawPos();
                    c2Pin.Z += 1.16;
                    this.m_sys.SyncObjectivePinLoop(233, q, p, obj3b, obj3b + "/mp_a2_sub2_clear", allPins);
                    this.m_sys.UpdateFallbackMappin(233, obj3b, c2Pin, n"cv_pin_sub2_clear", "[2/5 · CORREDOR] Eliminar guardia del Coro Pálido");
                } else {
                    let obj3c: String = p + "/03c_a2_solis_chamber";
                    this.SetAct2ObjectivesSucceeded(jm, [p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall"]);
                    let sPin: Vector4 = this.m_sub2PosCached ? this.m_solisPos : this.GetSolisRawPos();
                    sPin.Z += 1.65;
                    this.m_sys.SyncObjectivePinLoop(230, q, p, obj3c, obj3c + "/mp_a2_solis", allPins);
                    this.m_sys.UpdateFallbackMappin(230, obj3c, sPin, n"cv_mappin_a2_solis", "[3/5 · SUBNIVEL -2] Confrontar a Dra. Helena Solís («La Cantora»)");
                }
            }
        } else if stage == 40 {
            let bossCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_chamber_cleared") > 0;
            let obj4: String = p + "/04_a2_secure_core";
            this.m_sys.SyncObjectivePinLoop(240, q, p, obj4, obj4 + "/mp_a2_core", allPins);
            if bossCleared {
                let cPin: Vector4 = this.m_sub2PosCached ? this.m_corePos : this.GetChamberCoreRawPos();
                cPin.Z += 1.65;
                this.m_sys.UpdateFallbackMappin(240, obj4, cPin, n"cv_hub_core_title", "[4/5 · BIORREACTOR] Asegurar o purgar NOX-9B");
            } else {
                let uPin: Vector4 = this.m_sub2PosCached ? this.m_solisPos : this.GetSolisRawPos();
                uPin.Z += 1.65;
                this.m_sys.UpdateFallbackMappin(240, obj4, uPin, n"cv_mappin_a2_core", "[JEFE] Abate a Helena Solís y su escolta (usa la Torre UV)");
            }
        } else if stage == 50 {
            if inSub {
                let obj5: String = p + "/05_a2_sub2_extract";
                this.SetAct2ObjectivesSucceeded(jm, [p + "/04_a2_secure_core"]);
                this.SetAct2ObjectivesInactive(jm, [p + "/06_a2_return_misty"]);
                let exPin: Vector4 = this.m_sub2PosCached ? this.m_sub2ExtractHatchPos : this.GetSub2ExtractHatchRawPos();
                exPin.Z += 1.10;
                this.m_sys.SyncObjectivePinLoop(252, q, p, obj5, obj5 + "/mp_a2_sub2_extract", allPins);
                this.m_sys.UpdateFallbackMappin(252, obj5, exPin, n"cv_hub_hatch_extract", "[5/5 · EVACUACIÓN] Conducto de extracción a la superficie");
            } else if pPos.Z >= 38.00 {
                this.m_sys.ClearJournalPinsAndResetSync(allPins);
                this.m_sys.UpdateDynamicMappin(251, new Vector4(-1549.10, 1209.69, 58.65, 1.00), n"cv_mappin_rooftop", "Azotea de Misty (Little China)");
            } else {
                let obj6: String = p + "/06_a2_return_misty";
                this.SetAct2ObjectivesSucceeded(jm, [p + "/04_a2_secure_core", p + "/05_a2_sub2_extract"]);
                this.m_sys.SyncObjectivePinLoop(250, q, p, obj6, obj6 + "/mp_a2_return_misty", allPins);
                this.m_sys.UpdateFallbackMappin(250, obj6, new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_a2_return_misty", "Azotea de Misty (Little China): Reunirse con Misty y Lucía");
            }
        }
    }

    // --- Cachés de Suelo y Despliegue de Escenarios ---

    private final func EnsureFlatsCache() -> Void {
        if this.m_flatsPosCached || !IsDefined(this.m_sys) {
            return;
        }
        let hits: Int32 = 0;
        let zHit: Float = 0.00;

        let p1: Vector4 = this.GetFlatsPodRawPos();
        if this.m_sys.FindGroundZWideChecked(p1, zHit) {
            p1.Z = zHit;
            hits += 1;
        }
        this.m_podPos = p1;

        let p2: Vector4 = this.GetFlatsMateoRawPos();
        if this.m_sys.FindGroundZWideChecked(p2, zHit) {
            p2.Z = zHit;
            hits += 1;
        }
        this.m_mateoPos = p2;

        let p3: Vector4 = this.GetFlatsRelayRawPos();
        if this.m_sys.FindGroundZWideChecked(p3, zHit) {
            p3.Z = zHit;
            hits += 1;
        }
        this.m_relayPos = p3;

        if hits == 3 {
            this.m_flatsPosCached = true;
        }
    }

    private final func EnsureBunkerCache() -> Void {
        if this.m_bunkerPosCached || !IsDefined(this.m_sys) {
            return;
        }
        let anchor: Vector4 = this.GetBunkerAnchorRawPos();
        let anchorZ: Float = 0.00;
        if !this.m_sys.FindGroundZWideChecked(anchor, anchorZ) {
            return;
        }
        anchor.Z = anchorZ;

        let hits: Int32 = 0;
        let outPos: Vector4;
        if this.m_sys.ResolveClearPedestrianSpot(this.GetLuciaBunkerRawPos(), 0.55, 2.20, outPos) {
            this.m_luciaPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetBunkerOuterUvRawPos(), 0.55, 2.20, outPos) {
            this.m_outerUvPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetSurfaceHatchRawPos(), 0.65, 2.20, outPos) {
            this.m_surfaceHatchPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetSentryARawPos(), 0.55, 2.20, outPos) {
            this.m_sentryAPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetSentryBRawPos(), 0.55, 2.20, outPos) {
            this.m_sentryBPos = outPos;
            hits += 1;
        }
        if hits == 5 {
            this.m_bunkerPosCached = true;
        }
    }

    private final func EnsureSub1Cache() -> Void {
        if this.m_sub1PosCached || !IsDefined(this.m_sys) {
            return;
        }
        if !this.m_sys.HasStaticFloorNear(this.GetSub1EntryPos(), -5.78, 2.00, 2.50) {
            return;
        }
        let hits: Int32 = 0;
        let outPos: Vector4;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1ExitHatchRawPos(), -5.74, 0.50, outPos) { hits += 1; }
        this.m_sub1ExitHatchPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1SealARawPos(), -5.74, 0.50, outPos) { hits += 1; }
        this.m_sub1SealAPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1UvRawPos(), -5.65, 0.50, outPos) { hits += 1; }
        this.m_sub1UvPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1TurretRawPos(), -5.40, 0.50, outPos) { hits += 1; }
        this.m_sub1TurretPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1HallAnchorRawPos(), -5.40, 0.45, outPos) { hits += 1; }
        this.m_sub1HallAnchorPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1Level2DoorConsoleRawPos(), -4.70, 0.50, outPos) { hits += 1; }
        this.m_sub1Level2DoorConsolePos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1Level2DoorTriggerRawPos(), -4.70, 0.45, outPos) { hits += 1; }
        this.m_sub1Level2DoorTriggerPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1StalkerARawPos(), -5.70, 0.48, outPos) { hits += 1; }
        this.m_sub1StalkerAPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1Fanatic1RawPos(), -5.65, 0.48, outPos) { hits += 1; }
        this.m_sub1Fanatic1Pos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1Fanatic2RawPos(), -5.40, 0.48, outPos) { hits += 1; }
        this.m_sub1Fanatic2Pos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1StalkerBRawPos(), -5.40, 0.48, outPos) { hits += 1; }
        this.m_sub1StalkerBPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub1Fanatic3RawPos(), -4.70, 0.48, outPos) { hits += 1; }
        this.m_sub1Fanatic3Pos = outPos;
        if hits >= 1 {
            this.m_sub1PosCached = true;
        }
    }

    private final func EnsureSub2Cache() -> Void {
        if this.m_sub2PosCached || !IsDefined(this.m_sys) {
            return;
        }
        if !this.m_sys.HasStaticFloorNear(this.GetSub2EntryPos(), -16.66, 2.00, 2.50) {
            return;
        }
        let hits: Int32 = 0;
        let outPos: Vector4;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2CorrUvRawPos(), -16.66, 0.50, outPos) { hits += 1; }
        this.m_sub2CorrUvPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2TurretRawPos(), -16.66, 0.50, outPos) { hits += 1; }
        this.m_sub2TurretPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2HallAnchorRawPos(), -16.66, 0.45, outPos) { hits += 1; }
        this.m_sub2HallAnchorPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2ZealotARawPos(), -16.66, 0.48, outPos) { hits += 1; }
        this.m_sub2ZealotAPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2ZealotBRawPos(), -16.66, 0.48, outPos) { hits += 1; }
        this.m_sub2ZealotBPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2FanaticCRawPos(), -16.66, 0.48, outPos) { hits += 1; }
        this.m_sub2FanaticCPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2FanaticDRawPos(), -16.66, 0.48, outPos) { hits += 1; }
        this.m_sub2FanaticDPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2FanaticERawPos(), -16.70, 0.48, outPos) { hits += 1; }
        this.m_sub2FanaticEPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSub2ExtractHatchRawPos(), -16.70, 0.50, outPos) { hits += 1; }
        this.m_sub2ExtractHatchPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetChamberUvRawPos(), -16.70, 0.50, outPos) { hits += 1; }
        this.m_chamberUvPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetChamberCoreRawPos(), -16.70, 0.50, outPos) { hits += 1; }
        this.m_corePos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSolisRawPos(), -16.70, 0.50, outPos) { hits += 1; }
        this.m_solisPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSolisGuardARawPos(), -16.70, 0.48, outPos) { hits += 1; }
        this.m_solisGuardAPos = outPos;
        if this.m_sys.ResolveClearInteriorSpot(this.GetSolisGuardBRawPos(), -16.70, 0.48, outPos) { hits += 1; }
        this.m_solisGuardBPos = outPos;
        if hits >= 1 {
            this.m_sub2PosCached = true;
        }
    }

    private final func EnsureFlatsScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage != 10 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        let distSq: Float = this.m_sys.ComputeDistanceSq(pPos, this.GetFlatsMateoRawPos());
        if !forceSpawn && distSq > 3600.00 {
            return;
        }
        this.EnsureFlatsCache();
        if !this.m_flatsPosCached {
            return;
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_podId) {
            let y1: Float = this.ComputeFacingYaw(this.m_podPos, this.GetFlatsArrivalPos());
            this.m_podId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_convoy_pod.ent", this.m_podPos, y1, n"CV_A2_Pod");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_mateoShrineId) {
            let y2: Float = this.ComputeFacingYaw(this.m_mateoPos, this.GetFlatsArrivalPos());
            this.m_mateoShrineId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_mateo_shrine.ent", this.m_mateoPos, y2, n"CV_A2_MateoShrine");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_desertRelayId) {
            let y3: Float = this.ComputeFacingYaw(this.m_relayPos, this.GetFlatsArrivalPos());
            this.m_desertRelayId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_desert_relay.ent", this.m_relayPos, y3, n"CV_A2_DesertRelay");
        }
        if !this.m_flatsIntroPlayed && this.m_sys.ComputeDistanceSq(pPos, this.m_mateoPos) <= 900.00 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.m_flatsIntroPlayed = true;
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_flats_arrive", n"v_narr", n"V", scnDialogLineType.Regular, 8.36));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    private final func EnsureBunkerScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage < 20 || stage > 50 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        if this.IsInSubterraneanBunker(pPos) {
            return;
        }
        let distSq: Float = this.m_sys.ComputeDistanceSq(pPos, this.GetBunkerArrivalPos());
        if !forceSpawn && distSq > 10000.00 {
            return;
        }
        this.EnsureBunkerCache();
        if !this.m_bunkerPosCached {
            return;
        }

        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_outerUvId) {
            let yU1: Float = this.ComputeFacingYaw(this.m_outerUvPos, this.m_sentryAPos);
            this.m_outerUvId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_outerUvPos, yU1, n"CV_A2_OuterUv");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_surfaceHatchId) {
            let yHatch: Float = this.ComputeFacingYaw(this.m_surfaceHatchPos, this.m_luciaPos);
            this.m_surfaceHatchId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_bunker_hatch.ent", this.m_surfaceHatchPos, yHatch, n"CV_A2_SurfaceHatch");
        }

        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let isDay: Bool = this.m_sys.IsDaytimeNow();
        let outerCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_bunker_cleared") > 0;

        if IsDefined(this.m_sys.m_vampyreCombat) {
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let flashOn: Bool = this.m_sys.m_vampyreCombat.IsUvFlashActive(nowSim);
            this.m_sys.SyncUvEmitterVisual(this.m_outerUvId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim));
        }

        if stage == 20 && !outerCleared {
            if !this.m_outerSpawnedA && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sentryAId) {
                let saPos: Vector4 = this.m_sentryAPos;
                saPos.Z += 0.10;
                this.m_sentryAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_BunkerSentryA", saPos, this.ComputeFacingYaw(saPos, this.GetBunkerArrivalPos()), n"CV_A2_SentryA");
                this.m_bunkerCombatStart = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            }
            if !this.m_outerSpawnedB && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sentryBId) {
                let sbPos: Vector4 = this.m_sentryBPos;
                sbPos.Z += 0.10;
                this.m_sentryBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_BunkerSentryB", sbPos, this.ComputeFacingYaw(sbPos, this.GetBunkerArrivalPos()), n"CV_A2_SentryB");
            }
        }

        if stage >= 20 && stage <= 40 {
            let luciaYaw: Float = this.ComputeFacingYaw(this.m_luciaPos, this.GetBunkerArrivalPos());
            if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_luciaBunkerId) {
                this.m_luciaBunkerId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_LuciaReyes", this.m_luciaPos, luciaYaw, n"CV_A2_LuciaBunker", n"default");
            }
            if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_luciaBunkerWsId) {
                this.m_luciaBunkerWsId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_lucia.ent", this.m_luciaPos, luciaYaw, n"CV_WS_LuciaBunker");
            }
            this.m_sys.EnsureLuciaWorkspotAndLook(this.m_luciaBunkerId, this.m_luciaBunkerWsId, player);
        }

        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            if EntityID.IsDefined(this.m_sentryAId) && des.IsSpawned(this.m_sentryAId) {
                this.m_outerSpawnedA = true;
            }
            if EntityID.IsDefined(this.m_sentryBId) && des.IsSpawned(this.m_sentryBId) {
                this.m_outerSpawnedB = true;
            }
        }

        if isDay && !this.m_bunkerDayApplied && this.m_outerSpawnedA {
            this.ApplyDaylightPenaltyList([this.m_sentryAId, this.m_sentryBId]);
            this.m_bunkerDayApplied = true;
        }

        if stage == 20 && !this.m_bunkerArrivalPlayed && this.m_sys.ComputeDistanceSq(pPos, this.GetBunkerArrivalPos()) <= 1024.00 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.m_bunkerArrivalPlayed = true;
            if isDay {
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_daylight", "[LUZ DIURNA] La luz solar debilita al Coro Pálido y bloquea su regeneración");
            }
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_bunker_arrive", n"v_narr", n"V", scnDialogLineType.Regular, 9.84));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    private final func EnsureSub1Scene(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if stage < 25 || stage > 30 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        if !this.IsInSubterraneanBunker(pPos) || pPos.Z <= -10.50 {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if this.IsVanillaQ105Active(qs) {
            return;
        }
        this.EnsureSub1Cache();
        if !this.m_sub1PosCached {
            return;
        }
        this.m_sys.SetSubterraneanBunkerEnvActive(true);
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();

        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1ExitHatchId) {
            this.m_sub1ExitHatchId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_bunker_hatch.ent", this.m_sub1ExitHatchPos, 135.00, n"CV_A2_Sub1ExitHatch");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1SealAId) {
            this.m_sub1SealAId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_seal_relay.ent", this.m_sub1SealAPos, 180.00, n"CV_A2_Sub1SealA");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1UvId) {
            this.m_sub1UvId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_sub1UvPos, -30.00, n"CV_A2_Sub1Uv");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1Level2DoorConsoleId) {
            this.m_sub1Level2DoorConsoleId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_seal_relay.ent", this.m_sub1Level2DoorConsolePos, -90.00, n"CV_A2_Sub1Level2Door");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1CamId) {
            this.m_sub1CamConfigured = false;
            this.m_sub1CamId = this.m_sys.SpawnStaticPropEx(r"base\\gameplay\\devices\\security_systems\\surveillance_cameras\\surveillance_camera.ent", n"appearances_camera_wall_old", this.GetSub1CamRawPos(), -22.00, -135.00, n"CV_A2_Sub1Cam");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub1TurretId) {
            this.m_sub1TurretConfigured = false;
            this.m_sub1TurretId = this.m_sys.SpawnStaticPropEx(r"base\\gameplay\\devices\\security_systems\\security_turret\\security_turret_1_nav.ent", n"security_turret_1_default", this.m_sub1TurretPos, 0.00, 180.00, n"CV_A2_Sub1Turret");
        }

        if IsDefined(this.m_sys.m_vampyreCombat) {
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let flashOn: Bool = this.m_sys.m_vampyreCombat.IsUvFlashActive(nowSim);
            this.m_sys.SyncUvEmitterVisual(this.m_sub1UvId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim));
        }
        if !this.m_sub1CamConfigured && IsDefined(ses) && EntityID.IsDefined(this.m_sub1CamId) && ses.IsSpawned(this.m_sub1CamId) {
            let cam: ref<SurveillanceCamera> = GameInstance.FindEntityByID(game, this.m_sub1CamId) as SurveillanceCamera;
            if IsDefined(cam) && IsDefined(cam.GetDevicePS()) {
                cam.GetDevicePS().CvConfigureSecurityCamera();
                this.m_sub1CamConfigured = true;
            }
        }
        if IsDefined(ses) && EntityID.IsDefined(this.m_sub1TurretId) && ses.IsSpawned(this.m_sub1TurretId) {
            let turret: ref<SecurityTurret> = GameInstance.FindEntityByID(game, this.m_sub1TurretId) as SecurityTurret;
            if IsDefined(turret) && IsDefined(turret.GetDevicePS()) {
                let tps: ref<SecurityTurretControllerPS> = turret.GetDevicePS() as SecurityTurretControllerPS;
                if IsDefined(tps) {
                    if IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_turret_down") > 0 {
                        if tps.IsON() {
                            tps.CvDisableSecurityTurret();
                        }
                    } else if !tps.IsON() || turret.IsDead() {
                        if IsDefined(qs) { qs.SetFact(n"cv_a2_sub1_turret_down", 1); }
                    } else if !this.m_sub1TurretConfigured {
                        tps.CvConfigureSecurityTurret(true);
                        this.m_sub1TurretConfigured = true;
                    }
                }
            }
        }

        let sub1Cleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub1_cleared") > 0;
        if stage == 25 && !sub1Cleared && IsDefined(des) && des.IsReady() {
            if !this.m_sub1SpawnedA && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub1StalkerAId) {
                let sPosA: Vector4 = this.m_sub1StalkerAPos;
                sPosA.Z += 0.10;
                this.m_sub1StalkerAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_LabStalkerA", sPosA, 180.00, n"CV_A2_LabStalkerA");
                this.m_sub1CombatStart = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            }
            if !this.m_sub1SpawnedF1 && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub1Fanatic1Id) {
                let f1Pos: Vector4 = this.m_sub1Fanatic1Pos;
                f1Pos.Z += 0.10;
                this.m_sub1Fanatic1Id = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub1FanaticA", f1Pos, 90.00, n"CV_A2_Sub1Fanatic1");
            }
            if !this.m_sub1SpawnedF2 && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub1Fanatic2Id) {
                let f2Pos: Vector4 = this.m_sub1Fanatic2Pos;
                f2Pos.Z += 0.10;
                this.m_sub1Fanatic2Id = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub1FanaticB", f2Pos, 0.00, n"CV_A2_Sub1Fanatic2");
            }
            if !this.m_sub1SpawnedB && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub1StalkerBId) {
                let sPosB: Vector4 = this.m_sub1StalkerBPos;
                sPosB.Z += 0.10;
                this.m_sub1StalkerBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_LabStalkerB", sPosB, 45.00, n"CV_A2_LabStalkerB");
            }
            if !this.m_sub1SpawnedF3 && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub1Fanatic3Id) {
                let f3Pos: Vector4 = this.m_sub1Fanatic3Pos;
                f3Pos.Z += 0.10;
                this.m_sub1Fanatic3Id = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub1FanaticC", f3Pos, 90.00, n"CV_A2_Sub1Fanatic3");
            }
            if EntityID.IsDefined(this.m_sub1StalkerAId) && des.IsSpawned(this.m_sub1StalkerAId) { this.m_sub1SpawnedA = true; }
            if EntityID.IsDefined(this.m_sub1StalkerBId) && des.IsSpawned(this.m_sub1StalkerBId) { this.m_sub1SpawnedB = true; }
            if EntityID.IsDefined(this.m_sub1Fanatic1Id) && des.IsSpawned(this.m_sub1Fanatic1Id) { this.m_sub1SpawnedF1 = true; }
            if EntityID.IsDefined(this.m_sub1Fanatic2Id) && des.IsSpawned(this.m_sub1Fanatic2Id) { this.m_sub1SpawnedF2 = true; }
            if EntityID.IsDefined(this.m_sub1Fanatic3Id) && des.IsSpawned(this.m_sub1Fanatic3Id) { this.m_sub1SpawnedF3 = true; }
        }

        if !this.m_sub1ArrivalBannerShown {
            this.m_sub1ArrivalBannerShown = true;
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_sub1_arrive", "[NIVEL 1 · NAVE DE DIÁLISIS] Purga el sello de acceso frente a ti para comenzar");
        }
    }

    private final func EnsureSub2Scene(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if stage < 30 || stage > 50 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        if !this.IsInSubterraneanBunker(pPos) || pPos.Z > -10.50 {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if this.IsVanillaQ105Active(qs) {
            return;
        }
        this.EnsureSub2Cache();
        if !this.m_sub2PosCached {
            return;
        }
        this.m_sys.SetSubterraneanBunkerEnvActive(true);
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();

        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub2CorrUvId) {
            this.m_sub2CorrUvId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_sub2CorrUvPos, 180.00, n"CV_A2_Sub2CorrUv");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub2TurretId) {
            this.m_sub2TurretConfigured = false;
            this.m_sub2TurretId = this.m_sys.SpawnStaticPropEx(r"base\\gameplay\\devices\\security_systems\\security_turret\\security_turret_1_nav.ent", n"security_turret_1_default", this.m_sub2TurretPos, 0.00, 0.00, n"CV_A2_Sub2Turret");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_sub2ExtractHatchId) {
            this.m_sub2ExtractHatchId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_bunker_hatch.ent", this.m_sub2ExtractHatchPos, 180.00, n"CV_A2_Sub2ExtractHatch");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_chamberUvId) {
            this.m_chamberUvId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_chamberUvPos, this.ComputeFacingYaw(this.m_chamberUvPos, this.m_solisPos), n"CV_A2_ChamberUv");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_nox9bChamberId) {
            this.m_nox9bChamberId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a2_nox9b_chamber.ent", this.m_corePos, this.ComputeFacingYaw(this.m_corePos, this.m_solisPos), n"CV_A2_Nox9bChamber");
        }

        if IsDefined(this.m_sys.m_vampyreCombat) {
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let flashOn: Bool = this.m_sys.m_vampyreCombat.IsUvFlashActive(nowSim);
            this.m_sys.SyncUvEmitterVisual(this.m_sub2CorrUvId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim));
            this.m_sys.SyncUvEmitterVisual(this.m_chamberUvId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(2, nowSim));
        }

        if IsDefined(ses) && EntityID.IsDefined(this.m_sub2TurretId) && ses.IsSpawned(this.m_sub2TurretId) {
            let turret2: ref<SecurityTurret> = GameInstance.FindEntityByID(game, this.m_sub2TurretId) as SecurityTurret;
            if IsDefined(turret2) && IsDefined(turret2.GetDevicePS()) {
                let tps2: ref<SecurityTurretControllerPS> = turret2.GetDevicePS() as SecurityTurretControllerPS;
                if IsDefined(tps2) {
                    if IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_turret_down") > 0 {
                        if tps2.IsON() {
                            tps2.CvDisableSecurityTurret();
                        }
                    } else if !tps2.IsON() || turret2.IsDead() {
                        if IsDefined(qs) { qs.SetFact(n"cv_a2_sub2_turret_down", 1); }
                    } else if !this.m_sub2TurretConfigured {
                        tps2.CvConfigureSecurityTurret(true);
                        this.m_sub2TurretConfigured = true;
                    }
                }
            }
        }

        let corrCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_sub2_corr_cleared") > 0;
        if stage <= 40 && !corrCleared && IsDefined(des) && des.IsReady() {
            if !this.m_sub2SpawnedZA && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub2ZealotAId) {
                let zPosA: Vector4 = this.m_sub2ZealotAPos;
                zPosA.Z += 0.10;
                this.m_sub2ZealotAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2ZealotA", zPosA, 0.00, n"CV_A2_Sub2ZealotA");
                this.m_sub2CombatStart = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            }
            if !this.m_sub2SpawnedZB && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub2ZealotBId) {
                let zPosB: Vector4 = this.m_sub2ZealotBPos;
                zPosB.Z += 0.10;
                this.m_sub2ZealotBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2ZealotB", zPosB, 0.00, n"CV_A2_Sub2ZealotB");
            }
            if !this.m_sub2SpawnedFC && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub2FanaticCId) {
                let fcPos: Vector4 = this.m_sub2FanaticCPos;
                fcPos.Z += 0.10;
                this.m_sub2FanaticCId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2FanaticC", fcPos, 180.00, n"CV_A2_Sub2FanaticC");
            }
            if !this.m_sub2SpawnedFD && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub2FanaticDId) {
                let fdPos: Vector4 = this.m_sub2FanaticDPos;
                fdPos.Z += 0.10;
                this.m_sub2FanaticDId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2FanaticD", fdPos, 180.00, n"CV_A2_Sub2FanaticD");
            }
            if !this.m_sub2SpawnedFE && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_sub2FanaticEId) {
                let fePos: Vector4 = this.m_sub2FanaticEPos;
                fePos.Z += 0.10;
                this.m_sub2FanaticEId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2FanaticE", fePos, 90.00, n"CV_A2_Sub2FanaticE");
            }
            if EntityID.IsDefined(this.m_sub2ZealotAId) && des.IsSpawned(this.m_sub2ZealotAId) { this.m_sub2SpawnedZA = true; }
            if EntityID.IsDefined(this.m_sub2ZealotBId) && des.IsSpawned(this.m_sub2ZealotBId) { this.m_sub2SpawnedZB = true; }
            if EntityID.IsDefined(this.m_sub2FanaticCId) && des.IsSpawned(this.m_sub2FanaticCId) { this.m_sub2SpawnedFC = true; }
            if EntityID.IsDefined(this.m_sub2FanaticDId) && des.IsSpawned(this.m_sub2FanaticDId) { this.m_sub2SpawnedFD = true; }
            if EntityID.IsDefined(this.m_sub2FanaticEId) && des.IsSpawned(this.m_sub2FanaticEId) { this.m_sub2SpawnedFE = true; }
        }

        if !this.m_sub2ArrivalBannerShown {
            this.m_sub2ArrivalBannerShown = true;
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_sub2_breach", "[NIVEL 2 · SANTUARIO CARMESÍ] Sobrecarga el Emisor UV del corredor frente a ti");
        }

        let pactMade: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_ending") == 2;
        let chamberCleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_chamber_cleared") > 0;
        let sYaw: Float = this.ComputeFacingYaw(this.m_solisPos, this.GetSolisArrivalDebugPos());

        if stage == 30 && !chamberCleared {
            if !this.m_chamberSpawnedSolis && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_solisId) {
                this.m_solisId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_HelenaSolis", this.m_solisPos, sYaw, n"CV_A2_Solis", n"default");
            }
            if !pactMade {
                if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_solisWsId) {
                    this.m_solisWsId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_solis.ent", this.m_solisPos, sYaw, n"CV_WS_Solis");
                }
                this.m_sys.EnsureSolisWorkspotAndLook(this.m_solisId, this.m_solisWsId, player);
            }
            if !this.m_chamberSpawnedG1 && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_solisGuardAId) {
                let g1Pos: Vector4 = this.m_solisGuardAPos;
                g1Pos.Z += 0.10;
                this.m_solisGuardAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_SolisGuardA", g1Pos, sYaw, n"CV_A2_SolisGuardA");
            }
            if !this.m_chamberSpawnedG2 && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_solisGuardBId) {
                let g2Pos: Vector4 = this.m_solisGuardBPos;
                g2Pos.Z += 0.10;
                this.m_solisGuardBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_SolisGuardB", g2Pos, sYaw, n"CV_A2_SolisGuardB");
            }
            if !pactMade {
                this.m_sys.EnsurePassiveGuardAtPost(this.m_solisGuardAId, this.m_solisGuardAPos, sYaw);
                this.m_sys.EnsurePassiveGuardAtPost(this.m_solisGuardBId, this.m_solisGuardBPos, sYaw);
            }
            if IsDefined(des) {
                if EntityID.IsDefined(this.m_solisId) && des.IsSpawned(this.m_solisId) { this.m_chamberSpawnedSolis = true; }
                if EntityID.IsDefined(this.m_solisGuardAId) && des.IsSpawned(this.m_solisGuardAId) { this.m_chamberSpawnedG1 = true; }
                if EntityID.IsDefined(this.m_solisGuardBId) && des.IsSpawned(this.m_solisGuardBId) { this.m_chamberSpawnedG2 = true; }
            }
        } else if stage == 40 && !chamberCleared {
            if !this.m_solisCombatSwapped {
                this.SpawnSolisCombatSquad(player);
            }
        }
    }

    private final func SpawnSolisCombatSquad(player: ref<PlayerPuppet>) -> Void {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsReady() {
            return;
        }
        this.EnsureSub2Cache();
        if EntityID.IsDefined(this.m_solisId) {
            this.m_sys.StopNpcWorkspotById(this.m_solisId);
            this.m_sys.RemoveNpcImmortal(this.m_solisId);
        }
        des.DeleteTagged(n"CV_A2_Solis");
        des.DeleteTagged(n"CV_WS_Solis");
        des.DeleteTagged(n"CV_A2_SolisGuardA");
        des.DeleteTagged(n"CV_A2_SolisGuardB");

        this.m_solisWsId = new EntityID();
        this.m_chamberSpawnedSolis = true;
        this.m_chamberSpawnedG1 = true;
        this.m_chamberSpawnedG2 = true;
        this.m_solisCombatSwapped = true;

        let sYaw: Float = this.ComputeFacingYaw(this.m_solisPos, this.GetSolisArrivalDebugPos());
        let sPos: Vector4 = this.m_solisPos;
        sPos.Z += 0.08;
        this.m_solisId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_HelenaSolisCombat", sPos, sYaw, n"CV_A2_SolisCombat", n"default");

        let g1Pos: Vector4 = this.m_solisGuardAPos;
        g1Pos.Z += 0.08;
        this.m_solisGuardAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_SolisGuardACombat", g1Pos, sYaw, n"CV_A2_SolisGuardACombat");

        let g2Pos: Vector4 = this.m_solisGuardBPos;
        g2Pos.Z += 0.08;
        this.m_solisGuardBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_SolisGuardBCombat", g2Pos, sYaw, n"CV_A2_SolisGuardBCombat");

        if IsDefined(player) {
            this.EnsureListHostile([this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId], player, true);
        }
    }

    private final func EnsureRooftopLuciaScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage < 50 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        let onRoof: Bool = forceSpawn || (pPos.Z >= 38.00 && this.m_sys.ComputeDistanceSq(pPos, this.GetLuciaRooftopPos()) <= 6400.00);
        if !onRoof {
            return;
        }
        if !this.IsInSubterraneanBunker(pPos) {
            this.DespawnSubterraneanEntities();
        }
        let lPos: Vector4 = this.GetLuciaRooftopPos();
        lPos.Z = this.m_sys.FindFloorZInRange(lPos, 57.00, 1.00, 1.50);
        let lYaw: Float = this.ComputeFacingYaw(lPos, this.GetRooftopPlayerRefPos());

        if !this.m_rooftopLuciaRelocated && EntityID.IsDefined(this.m_luciaRoofId) {
            let desCheck: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
            if IsDefined(desCheck) && desCheck.IsSpawned(this.m_luciaRoofId) {
                let luciaEnt: ref<GameObject> = desCheck.GetEntity(this.m_luciaRoofId) as GameObject;
                if IsDefined(luciaEnt) && this.m_sys.ComputeDistanceSq(luciaEnt.GetWorldPosition(), lPos) > 0.36 {
                    this.m_sys.StopNpcWorkspotById(this.m_luciaRoofId);
                    desCheck.DeleteTagged(n"CV_A2_LuciaRoof");
                    desCheck.DeleteTagged(n"CV_WS_LuciaRoof");
                    this.m_luciaRoofId = new EntityID();
                    this.m_luciaRoofWsId = new EntityID();
                    this.m_sys.ResetLuciaWorkspotRetryState();
                }
            }
        }
        this.m_rooftopLuciaRelocated = true;

        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_luciaRoofId) {
            this.m_luciaRoofId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_LuciaReyes", lPos, lYaw, n"CV_A2_LuciaRoof", n"default");
        }
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_luciaRoofWsId) {
            this.m_luciaRoofWsId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_lucia.ent", lPos, lYaw, n"CV_WS_LuciaRoof");
        }
        this.m_sys.EnsureLuciaWorkspotAndLook(this.m_luciaRoofId, this.m_luciaRoofWsId, player);
    }

    private final func ApplyDaylightPenaltyList(ids: array<EntityID>) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
        if !IsDefined(des) || !IsDefined(sps) {
            return;
        }
        for eid in ids {
            if EntityID.IsDefined(eid) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                let hp: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, true);
                if IsDefined(npc) && hp > 82.00 {
                    sps.RequestChangingStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, -20.00, npc, false, true);
                }
            }
        }
    }

    private final func EnsureListHostile(ids: array<EntityID>, player: ref<PlayerPuppet>, stopWorkspots: Bool) -> Void {
        if !IsDefined(player) {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(game);
        if !IsDefined(des) {
            return;
        }
        for eid in ids {
            if EntityID.IsDefined(eid) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) && !npc.IsDead() && !ScriptedPuppet.IsDefeated(npc) && !ScriptedPuppet.IsUnconscious(npc) {
                    if stopWorkspots && IsDefined(ws) && ws.IsActorInWorkspot(npc) {
                        this.m_sys.StopNpcWorkspotById(eid);
                    }
                    if !NPCPuppet.IsInCombat(npc) {
                        this.m_sys.MakeNpcHostile(npc, player);
                    } else {
                        this.m_sys.EnsureCombatNpcArmed(npc);
                    }
                }
            }
        }
    }

    private final func CheckFlatsCluesAdvanced() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if !IsDefined(qs) || qs.GetFact(n"cv_a2_state") != 10 {
            return;
        }
        if qs.GetFact(n"cv_a2_clue_pod") > 0 && qs.GetFact(n"cv_a2_clue_mateo") > 0 && qs.GetFact(n"cv_a2_clue_relay") > 0 {
            qs.SetFact(n"cv_a2_state", 20);
            this.SyncStageJournalAndPin(20, true);
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a2_clues_done", "[BÚNKER LOCALIZADO] El repetidor señala la estación geotérmica de Biotechnica (1 km NE)");
            this.m_sys.RequestDelayedCheckpoint(1.20);
        }
    }

    private final func TriggerSolisCombat(player: ref<PlayerPuppet>, endingChoice: Int32) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ending", endingChoice);
            qs.SetFact(n"cv_a2_state", 40);
        }
        this.m_chamberCombatStart = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_solisPhase2Triggered = false;
        if IsDefined(this.m_sys.m_vampyreCombat) {
            this.m_sys.m_vampyreCombat.ResetCombatTimers();
        }
        this.SpawnSolisCombatSquad(player);
        this.SyncStageJournalAndPin(40, true);
        this.m_sys.ShowRelicBanner(n"cv_banner_a2_solis_combat", "[LA CANTORA EN COMBATE] Usa la Torre UV del biorreactor para neutralizar a Helena Solís");
    }

    private final func TriggerSolisPhase2(player: ref<PlayerPuppet>) -> Void {
        if this.m_solisPhase2Triggered {
            return;
        }
        this.m_solisPhase2Triggered = true;
        this.EnsureSub2Cache();
        let reinfPosA: Vector4 = new Vector4(48.50, -527.20, this.m_solisPos.Z + 0.12, 1.00);
        let reinfPosB: Vector4 = new Vector4(52.50, -520.00, this.m_solisPos.Z + 0.12, 1.00);
        this.m_solisReinfAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_LabStalkerA", reinfPosA, 0.00, n"CV_A2_SolisReinfA");
        this.m_solisReinfBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Sub2ZealotB", reinfPosB, 0.00, n"CV_A2_SolisReinfB");
        this.EnsureListHostile([this.m_solisReinfAId, this.m_solisReinfBId], player, false);
        this.m_sys.PlaySfx(n"cv_sfx_uv_overload");
        this.m_sys.ShowRelicBanner(n"cv_banner_solis_phase2", "[LA CANTORA · FASE II] ¡El Coro responde! Acólitos de refuerzo irrumpen en la cámara");
    }

    // --- Cuadros de Diálogo Acto II ---
    // Convención obligatoria: AZUL (preguntas) ARRIBA, AMARILLO (avance / decisiones finales) ABAJO

    public final func OpenLuciaDialogHub() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let q1Done: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_lucia_q1") > 0;
        let q2Done: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_lucia_q2") > 0;
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_state") : 20;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        if !q1Done {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_lucia_q1", "Encontré la placa de Mateo en Biotechnica Flats. ¿Qué pasó durante el traslado?"), false, false));
            ArrayPush(optionIds, 31);
        }
        if !q2Done {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_lucia_q2", "¿En qué estado está exactamente el suero NOX-9B ahí abajo?"), false, false));
            ArrayPush(optionIds, 32);
        }
        if stage == 20 {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_lucia_adv", "Ponte a cubierto. Bajo a enfrentarme a Helena Solís («La Cantora»)."), true, false));
            ArrayPush(optionIds, 33);
        }
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_open_codex", "Abrir Códice de Arcanos"), false, false));
        ArrayPush(optionIds, 34);
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_a2_leave", "Volver ahora."), false, false));
        ArrayPush(optionIds, 35);

        this.m_sys.PushDialogHub(n"cv_a2_lucia_hub", this.m_sys.GetLoc(n"cv_hub_lucia_title", "Lucía Reyes — Acceso al Búnker"), choices, optionIds);
    }

    public final func OpenSolisDialogHub() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let q1Done: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_solis_q1") > 0;
        let q2Done: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_solis_q2") > 0;
        let q3Done: Bool = IsDefined(qs) && qs.GetFact(n"cv_a2_solis_q3") > 0;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        // Preguntas informativas AZULES ARRIBA
        if !q1Done {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_q1", "Valdés diseñó el NOX-9 para curar pulmones. Tú montaste una secta y mataste a Mateo."), false, false));
            ArrayPush(optionIds, 41);
        }
        if !q2Done {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_q2", "Explícame el NOX-9B. ¿De verdad elimina la dependencia y el daño solar?"), false, false));
            ArrayPush(optionIds, 42);
        }
        if !q3Done {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_q3", "¿Por qué marcaste Misty's Esoterica como «Nexo de Silencio» en tus manifiestos?"), false, false));
            ArrayPush(optionIds, 43);
        }

        // Decisiones finales AMARILLAS ABAJO
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_end_cure", "[Final A · El Segundo Suero] Luchar por la fórmula intacta del NOX-9B para Valdés y liberar a Lucía."), true, false));
        ArrayPush(optionIds, 44);
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_end_pact", "[Final B · Pacto en la Penumbra] Pactar la liberación de Lucía y borrar Watson de tus registros."), true, false));
        ArrayPush(optionIds, 45);
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_solis_end_burn", "[Final C · Alba de Sangre] Abatir a Solís y calcinar por completo el biorreactor del Coro Pálido."), true, false));
        ArrayPush(optionIds, 46);

        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_open_codex", "Abrir Códice de Arcanos"), false, false));
        ArrayPush(optionIds, 47);
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_a2_leave", "Volver ahora."), false, false));
        ArrayPush(optionIds, 48);

        this.m_sys.PushDialogHub(n"cv_a2_solis_hub", this.m_sys.GetLoc(n"cv_hub_solis_title", "Dra. Helena Solís («La Cantora») — Cámara NOX-9B"), choices, optionIds);
    }

    public final func HandleDialogOption(ownerTag: CName, optionId: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;

        if Equals(ownerTag, n"cv_a2_lucia_hub") {
            if optionId == 31 {
                if IsDefined(qs) { qs.SetFact(n"cv_a2_lucia_q1", 1); }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_lucia_q1", n"v_narr", n"V", scnDialogLineType.Regular, 5.80));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_lucia_a1", n"lucia", n"Lucía Reyes", scnDialogLineType.Regular, 14.82));
                this.m_sys.StartSpeechSequence(steps, 203);
                return true;
            }
            if optionId == 32 {
                if IsDefined(qs) { qs.SetFact(n"cv_a2_lucia_q2", 1); }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_lucia_q2", n"v_narr", n"V", scnDialogLineType.Regular, 5.65));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_lucia_a2", n"lucia", n"Lucía Reyes", scnDialogLineType.Regular, 14.76));
                this.m_sys.StartSpeechSequence(steps, 203);
                return true;
            }
            if optionId == 33 {
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_lucia_adv", n"v_narr", n"V", scnDialogLineType.Regular, 6.44));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_lucia_adv", n"lucia", n"Lucía Reyes", scnDialogLineType.Regular, 9.68));
                this.m_sys.StartSpeechSequence(steps, 204);
                return true;
            }
            if optionId == 34 {
                this.m_sys.OpenTarotSpreadPopup(false);
                return true;
            }
            if optionId == 35 {
                return true;
            }
            return false;
        }

        if Equals(ownerTag, n"cv_a2_solis_hub") {
            if optionId == 41 {
                if IsDefined(qs) { qs.SetFact(n"cv_a2_solis_q1", 1); }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_solis_q1", n"v_narr", n"V", scnDialogLineType.Regular, 7.09));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_a1", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 14.60));
                this.m_sys.StartSpeechSequence(steps, 205);
                return true;
            }
            if optionId == 42 {
                if IsDefined(qs) { qs.SetFact(n"cv_a2_solis_q2", 1); }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_solis_q2", n"v_narr", n"V", scnDialogLineType.Regular, 6.56));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_a2", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 16.05));
                this.m_sys.StartSpeechSequence(steps, 205);
                return true;
            }
            if optionId == 43 {
                if IsDefined(qs) { qs.SetFact(n"cv_a2_solis_q3", 1); }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_solis_q3", n"v_narr", n"V", scnDialogLineType.Regular, 6.83));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_a3", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 13.84));
                this.m_sys.StartSpeechSequence(steps, 205);
                return true;
            }
            if optionId == 44 {
                this.TriggerSolisCombat(player, 1);
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_end_cure", n"v_narr", n"V", scnDialogLineType.Regular, 8.92));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_combat", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 7.63));
                this.m_sys.StartSpeechSequence(steps, 0);
                return true;
            }
            if optionId == 45 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a2_ending", 2);
                    qs.SetFact(n"cv_a2_chamber_cleared", 1);
                    qs.SetFact(n"cv_a2_core_done", 1);
                    qs.SetFact(n"cv_a2_state", 50);
                }
                this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_Nox9bFormula", 1, 0.30);
                this.SyncStageJournalAndPin(50, true);
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_end_pact", n"v_narr", n"V", scnDialogLineType.Regular, 10.56));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_pact", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 9.32));
                this.m_sys.StartSpeechSequence(steps, 206);
                return true;
            }
            if optionId == 46 {
                this.TriggerSolisCombat(player, 3);
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_end_burn", n"v_narr", n"V", scnDialogLineType.Regular, 8.08));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_combat", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 7.63));
                this.m_sys.StartSpeechSequence(steps, 0);
                return true;
            }
            if optionId == 47 {
                this.m_sys.OpenTarotSpreadPopup(false);
                return true;
            }
            if optionId == 48 {
                return true;
            }
        }
        return false;
    }

    public final func CompleteAct2FinaleOnRooftop() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let endingChoice: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_ending") : 1;

        let steps: array<ref<CrimsonVeilSpeechStep>>;
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_lucia_greet", n"lucia", n"Lucía Reyes", scnDialogLineType.Regular, 8.42));
        if endingChoice == 2 {
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_misty_pact", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 12.04));
        } else if endingChoice == 3 {
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_misty_burn", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 12.26));
        } else {
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_misty_cure", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 11.80));
        }
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_misty_epilogue", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 15.46));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_roof_v_close", n"v_narr", n"V", scnDialogLineType.Regular, 9.57));
        this.m_sys.StartSpeechSequence(steps, 207);
    }

    private final func FinalizeAct2Rewards() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);

        if IsDefined(qs) && qs.GetFact(n"cv_a2_done") == 0 {
            qs.SetFact(n"cv_a2_done", 1);
            qs.SetFact(n"cv_a2_state", 60);
            if IsDefined(ts) && IsDefined(player) {
                ts.GiveItem(player, ItemID.FromTDBID(t"Items.money"), 4000);
            }
            this.m_sys.GiveItemDelayed(t"Items.Preset_Burya_CrimsonVeil", 1, 0.35);
            this.m_sys.GrantExperience(1500);
            this.m_sys.ClearJournalPinsAndResetSync(this.GetAllAct2PinPaths());
            if IsDefined(jm) {
                let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
                jm.ChangeEntryState(p + "/06_a2_return_misty", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/desc_a2_done", "gameJournalQuestDescription", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState("quests/side_quest/crimson_veil_a2_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.Notify);
            }
            this.m_sys.ClearMappin();
            this.m_sys.SyncCodexJournalShards();
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a2_complete", "[VELO CARMESÍ COMPLETADO] +4.000 €$, +1.500 XP y revólver icónico «Alba Carmesí»");
            this.m_sys.RequestDelayedCheckpoint(2.80);
        }
    }

    public final func OnPostSpeech(actionId: Int32) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);

        if actionId == 201 {
            this.m_sys.EndMistyIntroCall();
            if IsDefined(qs) && qs.GetFact(n"cv_a2_state") < 10 {
                qs.SetFact(n"cv_a2_state", 10);
            }
            this.m_sys.ActivateMistyAct2CallRecapSms();
            this.SyncStageJournalAndPin(10, true);
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a2_start", "[ACTO II · LITURGIA DE CENIZA] Rastro del convoy en Biotechnica Flats");
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 202 {
            this.CheckFlatsCluesAdvanced();
            return;
        }
        if actionId == 203 {
            this.EnsureBunkerCache();
            if IsDefined(player) && this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.m_luciaPos) <= 81.00 {
                this.OpenLuciaDialogHub();
            }
            return;
        }
        if actionId == 204 {
            if IsDefined(qs) && qs.GetFact(n"cv_a2_state") < 25 {
                qs.SetFact(n"cv_a2_state", 25);
            }
            this.SyncStageJournalAndPin(25, true);
            this.SyncActiveStageMappin(player, 25);
            this.m_sys.ShowRelicBanner(n"cv_banner_a2_descent", "[ACCESO ABIERTO] Sigue el marcador hacia la escotilla metálica del suelo para bajar al Subnivel -1");
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 205 {
            this.EnsureSub2Cache();
            if IsDefined(player) && this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.m_solisPos) <= 100.00 {
                this.OpenSolisDialogHub();
            }
            return;
        }
        if actionId == 206 {
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 207 {
            this.FinalizeAct2Rewards();
            return;
        }
    }

    public final func HandleInteraction(kind: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_state") : 10;

        if kind == 201 {
            if IsDefined(qs) && qs.GetFact(n"cv_a2_clue_pod") == 0 {
                qs.SetFact(n"cv_a2_clue_pod", 1);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.ShowRelicBanner(n"cv_banner_a2_clue_1", "[PISTA 1/3] Cápsula de Lucía (L-14) y envíos de NOX-9B");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_clue_pod", n"v_narr", n"V", scnDialogLineType.Regular, 10.16));
                this.m_sys.StartSpeechSequence(steps, 202);
            }
            return true;
        }
        if kind == 202 {
            if IsDefined(qs) && qs.GetFact(n"cv_a2_clue_mateo") == 0 {
                qs.SetFact(n"cv_a2_clue_mateo", 1);
                this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
                this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_MateoBadge", 1, 0.25);
                this.m_sys.SyncCodexJournalShards();
                this.m_sys.ShowRelicBanner(n"cv_banner_a2_clue_2", "[PISTA 2/3] Placa de Mateo (M-09) — Ejecutado al sabotear el convoy");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_clue_mateo", n"v_narr", n"V", scnDialogLineType.Regular, 13.20));
                this.m_sys.StartSpeechSequence(steps, 202);
            }
            return true;
        }
        if kind == 203 {
            if IsDefined(qs) && qs.GetFact(n"cv_a2_clue_relay") == 0 {
                qs.SetFact(n"cv_a2_clue_relay", 1);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.ShowRelicBanner(n"cv_banner_a2_clue_3", "[PISTA 3/3] Baliza del Búnker de Biotechnica fijada");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_clue_relay", n"v_narr", n"V", scnDialogLineType.Regular, 10.52));
                this.m_sys.StartSpeechSequence(steps, 202);
            }
            return true;
        }
        if kind == 204 {
            this.EnsureBunkerCache();
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvOverloadSquad(player, this.m_outerUvPos, [this.m_sentryAId, this.m_sentryBId], 1);
                this.m_sys.SyncUvEmitterVisual(this.m_outerUvId, true, false);
            }
            this.EnsureListHostile([this.m_sentryAId, this.m_sentryBId], player, false);
            return true;
        }
        if kind == 205 || kind == 210 {
            let slot: Int32 = (kind == 205) ? 1 : 2;
            if IsDefined(this.m_sys.m_vampyreCombat) {
                let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
                let remSec: Int32 = this.m_sys.m_vampyreCombat.GetUvTowerCooldownSeconds(slot, nowSim);
                let msg: String = this.m_sys.GetLoc(n"cv_banner_uv_cooling_pre", "[EMISOR UV] Condensador recargando — listo en ") + IntToString(remSec) + " s";
                this.m_sys.ShowRelicBannerText(msg);
            }
            return true;
        }
        if kind == 206 {
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvDiagnosticPulse(player);
            }
            return true;
        }
        if kind == 207 {
            if stage >= 20 && stage <= 40 {
                if IsDefined(qs) && qs.GetFact(n"cv_a2_lucia_met") == 0 {
                    qs.SetFact(n"cv_a2_lucia_met", 1);
                    this.m_sys.SyncCodexJournalShards();
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_lucia_intro", n"lucia", n"Lucía Reyes", scnDialogLineType.Regular, 8.08));
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_lucia_intro", n"v_narr", n"V", scnDialogLineType.Regular, 7.78));
                    this.m_sys.StartSpeechSequence(steps, 203);
                } else {
                    this.OpenLuciaDialogHub();
                }
            }
            return true;
        }
        if kind == 208 {
            if stage == 30 {
                if IsDefined(qs) && qs.GetFact(n"cv_a2_solis_met") == 0 {
                    qs.SetFact(n"cv_a2_solis_met", 1);
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_solis_intro", n"solis", n"Dra. Helena Solís", scnDialogLineType.Regular, 9.00));
                    this.m_sys.StartSpeechSequence(steps, 205);
                } else {
                    this.OpenSolisDialogHub();
                }
            }
            return true;
        }
        if kind == 209 {
            this.EnsureSub2Cache();
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvOverloadSquad(player, this.m_chamberUvPos, [this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId, this.m_solisReinfAId, this.m_solisReinfBId], 2);
                this.m_sys.SyncUvEmitterVisual(this.m_chamberUvId, true, false);
            }
            if stage == 40 {
                this.EnsureListHostile([this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId, this.m_solisReinfAId, this.m_solisReinfBId], player, true);
            }
            return true;
        }
        if kind == 211 {
            if IsDefined(qs) && stage == 40 {
                let endChoice: Int32 = qs.GetFact(n"cv_a2_ending");
                qs.SetFact(n"cv_a2_core_done", 1);
                qs.SetFact(n"cv_a2_state", 50);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                if endChoice == 3 {
                    this.m_sys.ShowRelicBanner(n"cv_banner_a2_core_burned", "[BIORREACTOR PURGADO] Fórmula destruida — Evacúa por el conducto de extracción");
                    this.SyncStageJournalAndPin(50, true);
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_core_destroyed", n"v_narr", n"V", scnDialogLineType.Regular, 8.12));
                    this.m_sys.StartSpeechSequence(steps, 206);
                } else {
                    this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_Nox9bFormula", 1, 0.30);
                    this.m_sys.ShowRelicBanner(n"cv_banner_a2_core_secured", "[FÓRMULA NOX-9B ASEGURADA] Evacúa por el conducto de extracción");
                    this.SyncStageJournalAndPin(50, true);
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a2_v_core_secured", n"v_narr", n"V", scnDialogLineType.Regular, 8.28));
                    this.m_sys.StartSpeechSequence(steps, 206);
                }
            }
            return true;
        }
        if kind == 212 {
            this.EnsureListHostile([this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId, this.m_solisReinfAId, this.m_solisReinfBId], player, true);
            this.m_sys.ShowRelicBanner(n"cv_banner_a2_core_locked", "[BIORREACTOR SELLADO] Neutraliza primero a Helena Solís y su escolta");
            return true;
        }
        // Compuerta de superficie -> Subnivel -1 (Inicio Nivel 1)
        if kind == 215 {
            if stage < 25 {
                this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
                this.m_sys.ShowRelicBanner(n"cv_act_hatch_locked", "[COMPUERTA SELLADA] Despeja la guardia y habla con Lucía Reyes");
                return true;
            }
            this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
            this.m_sys.SetNightTime2200();
            this.m_sys.SetSubterraneanBunkerEnvActive(true);
            this.m_sub1PosCached = false;
            this.m_sub1ArrivalBannerShown = false;
            let entryPos: Vector4 = new Vector4(31.50, -473.20, -5.60, 1.00);
            this.m_sys.TeleportPlayerSmooth(entryPos, this.ComputeFacingYaw(entryPos, this.GetSub1SealARawPos()));
            if IsDefined(qs) && qs.GetFact(n"cv_a2_seal_a") == 0 {
                this.SyncStageJournalAndPin(25, true);
            }
            return true;
        }
        // Subnivel -1 -> Regresar a Superficie
        if kind == 216 {
            this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
            this.DespawnSubterraneanEntities();
            this.EnsureBunkerCache();
            let retPos: Vector4 = new Vector4(-359.50, -2542.00, 27.38, 1.00);
            retPos.Z = this.m_sys.FindGroundZWide(retPos) + 0.15;
            this.m_sys.TeleportPlayerSmooth(retPos, this.ComputeFacingYaw(retPos, this.GetLuciaBunkerRawPos()));
            return true;
        }
        // Nivel 1 · Paso 1/4: Sello de acceso
        if kind == 219 {
            if IsDefined(qs) && qs.GetFact(n"cv_a2_seal_a") == 0 {
                qs.SetFact(n"cv_a2_seal_a", 1);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.ShowRelicBanner(n"cv_banner_seal_a_done", "[SELLO DE ACCESO PURGADO] Cruza la puerta doble verde y sobrecarga el Emisor UV marcado");
                this.SyncStageJournalAndPin(25, true);
                this.SyncActiveStageMappin(player, 25);
            }
            return true;
        }
        // Nivel 1 · Paso 2/4: Emisor UV Subnivel -1
        if kind == 217 {
            this.EnsureSub1Cache();
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvOverloadSquad(player, this.m_sub1UvPos, [this.m_sub1StalkerAId, this.m_sub1StalkerBId, this.m_sub1Fanatic1Id, this.m_sub1Fanatic2Id, this.m_sub1Fanatic3Id], 1);
                this.m_sys.SyncUvEmitterVisual(this.m_sub1UvId, true, false);
            }
            this.EnsureListHostile([this.m_sub1StalkerAId, this.m_sub1StalkerBId, this.m_sub1Fanatic1Id, this.m_sub1Fanatic2Id, this.m_sub1Fanatic3Id], player, false);
            if IsDefined(qs) {
                qs.SetFact(n"cv_p0_uv_hint_shown", 1);
                if qs.GetFact(n"cv_a2_sub1_uv_done") == 0 {
                    qs.SetFact(n"cv_a2_sub1_uv_done", 1);
                    if qs.GetFact(n"cv_a2_sub1_cleared") > 0 {
                        this.m_sys.ShowRelicBanner(n"cv_banner_hall_cleared", "[NAVE DESPEJADA] Sube la rampa hasta la puerta de entrada al Nivel 2");
                    } else {
                        this.m_sys.ShowRelicBanner(n"cv_banner_uv_step_done", "[EMISOR UV SOBRECARGADO] Regeneración anulada — Elimina a la escuadra del Coro Pálido");
                    }
                    this.SyncStageJournalAndPin(25, true);
                    this.SyncActiveStageMappin(player, 25);
                }
            }
            return true;
        }
        if kind == 218 {
            if IsDefined(this.m_sys.m_vampyreCombat) {
                let rem1: Int32 = this.m_sys.m_vampyreCombat.GetUvTowerCooldownSeconds(1, EngineTime.ToFloat(GameInstance.GetSimTime(game)));
                this.m_sys.ShowRelicBannerText(this.m_sys.GetLoc(n"cv_banner_uv_cooling_pre", "[EMISOR UV] Condensador recargando — listo en ") + IntToString(rem1) + " s");
            }
            return true;
        }
        // Nivel 1 · Paso 4/4: Puerta metálica de entrada al Nivel 2 -> Transición limpia a Subnivel -2
        if kind == 221 {
            let readyForDoor: Bool = IsDefined(qs)
                && qs.GetFact(n"cv_a2_seal_a") > 0
                && qs.GetFact(n"cv_a2_sub1_uv_done") > 0
                && qs.GetFact(n"cv_a2_sub1_cleared") > 0;
            if !readyForDoor && stage < 30 {
                this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
                this.m_sys.ShowRelicBanner(n"cv_act_level2_door_locked", "[PUERTA SELLADA] Sobrecarga el Emisor UV y despeja la nave primero");
                return true;
            }
            this.DespawnSub1EntitiesOnly();
            if IsDefined(qs) {
                qs.SetFact(n"cv_a2_sub1_door_done", 1);
                if stage < 30 {
                    qs.SetFact(n"cv_a2_state", 30);
                }
            }
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sub2PosCached = false;
            this.m_sub2ArrivalBannerShown = false;
            this.m_sys.SetNightTime2200();
            this.m_sys.SetSubterraneanBunkerEnvActive(true);
            let sub2Entry: Vector4 = new Vector4(69.35, -495.78, -16.52, 1.00);
            this.m_sys.TeleportPlayerSmooth(sub2Entry, this.ComputeFacingYaw(sub2Entry, this.GetSub2CorrUvRawPos()));
            this.SyncStageJournalAndPin(30, true);
            this.m_sys.ShowRelicBanner(n"cv_banner_sub1_complete", "[NIVEL 1 COMPLETADO] Descendiendo al Nivel 2 (Santuario Carmesí)");
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return true;
        }
        // Nivel 2 · Paso 5/5: Conducto de Extracción -> Superficie
        if kind == 222 {
            this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
            this.DespawnSubterraneanEntities();
            this.EnsureBunkerCache();
            let extPos: Vector4 = new Vector4(-359.50, -2542.00, 27.38, 1.00);
            extPos.Z = this.m_sys.FindGroundZWide(extPos) + 0.15;
            this.m_sys.TeleportPlayerSmooth(extPos, this.ComputeFacingYaw(extPos, this.GetLuciaBunkerRawPos()));
            if IsDefined(qs) && qs.GetFact(n"cv_a2_state") == 50 {
                let pExt: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
                let jmExt: ref<JournalManager> = GameInstance.GetJournalManager(game);
                this.SetAct2ObjectivesSucceeded(jmExt, [pExt + "/05_a2_sub2_extract"]);
                let obj6Ext: String = pExt + "/06_a2_return_misty";
                this.m_sys.ActivateObjectiveWithPin(250, "quests/side_quest/crimson_veil_a2_quest", pExt, obj6Ext, obj6Ext + "/mp_a2_return_misty", obj6Ext + "/desc_a2_05", this.GetAllAct2PinPaths(), true);
                this.m_sys.UpdateFallbackMappin(250, obj6Ext, new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_a2_return_misty", "Azotea de Misty (Little China): Reunirse con Misty y Lucía");
                this.m_lastSyncedStage = 50;
            }
            this.m_sys.ShowRelicBanner(n"cv_banner_sub2_extracted", "[NIVEL 2 COMPLETADO · EVACUACIÓN] Vuelve a la azotea de Esoterica con Misty y Lucía");
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return true;
        }
        // Nivel 2 · Paso 1/5: Emisor UV Corredor Subnivel -2
        if kind == 223 {
            this.EnsureSub2Cache();
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvOverloadSquad(player, this.m_sub2CorrUvPos, [this.m_sub2ZealotAId, this.m_sub2ZealotBId, this.m_sub2FanaticCId, this.m_sub2FanaticDId, this.m_sub2FanaticEId], 1);
                this.m_sys.SyncUvEmitterVisual(this.m_sub2CorrUvId, true, false);
            }
            this.EnsureListHostile([this.m_sub2ZealotAId, this.m_sub2ZealotBId, this.m_sub2FanaticCId, this.m_sub2FanaticDId, this.m_sub2FanaticEId], player, false);
            if IsDefined(qs) {
                qs.SetFact(n"cv_p0_uv_hint_shown", 1);
                if qs.GetFact(n"cv_a2_sub2_uv_done") == 0 {
                    qs.SetFact(n"cv_a2_sub2_uv_done", 1);
                    if qs.GetFact(n"cv_a2_sub2_corr_cleared") > 0 {
                        this.m_sys.ShowRelicBanner(n"cv_banner_sub2_hall_clear", "[CORREDOR DESPEJADO] Avanza al sur por el pasillo hasta la Dra. Helena Solís");
                    } else {
                        this.m_sys.ShowRelicBanner(n"cv_banner_sub2_uv_done", "[EMISOR UV SOBRECARGADO] Regeneración anulada — Abate a la guardia del corredor");
                    }
                    this.SyncStageJournalAndPin(30, true);
                    this.SyncActiveStageMappin(player, 30);
                }
            }
            return true;
        }
        return false;
    }

    // --- Botones CET Acto II ---

    public final func DebugTriggerAct2Call() -> Void {
        this.EnsurePriorActsClosed();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_state", 5);
        }
        this.m_callAttempted = true;
        this.m_sys.StartMistyAct2Call();
    }

    public final func DebugGoToFlats() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        this.EnsurePriorActsClosed();
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_state", 10);
            qs.SetFact(n"cv_a2_clue_pod", 0);
            qs.SetFact(n"cv_a2_clue_mateo", 0);
            qs.SetFact(n"cv_a2_clue_relay", 0);
        }
        this.DespawnSubterraneanEntities();
        this.m_sys.DespawnStaticPropById(this.m_podId);
        this.m_sys.DespawnStaticPropById(this.m_mateoShrineId);
        this.m_sys.DespawnStaticPropById(this.m_desertRelayId);
        this.m_podId = new EntityID();
        this.m_mateoShrineId = new EntityID();
        this.m_desertRelayId = new EntityID();
        this.m_flatsIntroPlayed = false;
        this.m_flatsPosCached = false;
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        this.SetAct2ObjectivesInactive(jm, [
            p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
            p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
            p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
            p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
        ]);
        this.SyncStageJournalAndPin(10, true);
        let arr: Vector4 = this.GetFlatsArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        this.m_sys.TeleportPlayerSmooth(arr, this.ComputeFacingYaw(arr, this.GetFlatsMateoRawPos()));
    }

    public final func DebugGoToBunker() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        this.m_sys.SetNightTime2200();
        this.EnsurePriorActsClosed();
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_clue_pod", 1);
            qs.SetFact(n"cv_a2_clue_mateo", 1);
            qs.SetFact(n"cv_a2_clue_relay", 1);
            qs.SetFact(n"cv_a2_bunker_cleared", 0);
            qs.SetFact(n"cv_a2_lucia_met", 0);
            qs.SetFact(n"cv_a2_lucia_q1", 0);
            qs.SetFact(n"cv_a2_lucia_q2", 0);
            qs.SetFact(n"cv_a2_state", 20);
        }
        this.DespawnSubterraneanEntities();
        this.m_bunkerArrivalPlayed = false;
        this.m_outerClearBannerShown = false;
        this.m_bunkerPosCached = false;
        this.SyncStageJournalAndPin(20, true);
        let arr: Vector4 = this.GetBunkerArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        this.m_sys.TeleportPlayerSmooth(arr, this.ComputeFacingYaw(arr, this.GetSentryARawPos()));
    }

    public final func DebugGoToSublevel1() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(game);
        this.m_sys.SetNightTime2200();
        this.DespawnSubterraneanEntities();
        this.EnsurePriorActsClosed();
        if IsDefined(ms) {
            ms.UntrackMappin();
        }
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_clue_pod", 1);
            qs.SetFact(n"cv_a2_clue_mateo", 1);
            qs.SetFact(n"cv_a2_clue_relay", 1);
            qs.SetFact(n"cv_a2_bunker_cleared", 1);
            qs.SetFact(n"cv_a2_lucia_met", 1);
            qs.SetFact(n"cv_a2_seal_a", 0);
            qs.SetFact(n"cv_a2_sub1_uv_done", 0);
            qs.SetFact(n"cv_a2_sub1_cleared", 0);
            qs.SetFact(n"cv_a2_sub1_turret_down", 0);
            qs.SetFact(n"cv_a2_sub1_door_done", 0);
            qs.SetFact(n"cv_a2_sub2_uv_done", 0);
            qs.SetFact(n"cv_a2_sub2_corr_cleared", 0);
            qs.SetFact(n"cv_a2_sub2_turret_down", 0);
            qs.SetFact(n"cv_a2_solis_met", 0);
            qs.SetFact(n"cv_a2_chamber_cleared", 0);
            qs.SetFact(n"cv_a2_ending", 0);
            qs.SetFact(n"cv_a2_core_done", 0);
            qs.SetFact(n"cv_a2_done", 0);
            qs.SetFact(n"cv_a2_state", 25);
        }
        this.m_sub1PosCached = false;
        this.m_sub1ArrivalBannerShown = false;
        this.m_sys.SetSubterraneanBunkerEnvActive(true);
        let entryPos: Vector4 = new Vector4(31.50, -473.20, -5.60, 1.00);
        this.m_sys.TeleportPlayerSmooth(entryPos, this.ComputeFacingYaw(entryPos, this.GetSub1SealARawPos()));
        let q: String = "quests/side_quest/crimson_veil_a2_quest";
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        this.SetAct2ObjectivesSucceeded(jm, [p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker"]);
        this.SetAct2ObjectivesInactive(jm, [
            p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door",
            p + "/03a_a2_sub2_uv_tower", p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
            p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
        ]);
        this.m_sys.ActivateObjectiveWithPin(226, q, p, p + "/02c_a2_sub1_seal_a", p + "/02c_a2_sub1_seal_a/mp_a2_seal_a", p + "/02c_a2_sub1_seal_a/desc_a2_02c", this.GetAllAct2PinPaths(), true);
        this.m_sys.UpdateFallbackMappin(226, p + "/02c_a2_sub1_seal_a", new Vector4(36.20, -471.00, -4.90, 1.00), n"cv_hub_seal_a", "[1/4 · NIVEL 1] Purgar sello de acceso");
        this.m_lastSyncedStage = 25;
    }

    public final func DebugGoToSublevel2() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(game);
        this.m_sys.SetNightTime2200();
        this.DespawnSubterraneanEntities();
        this.EnsurePriorActsClosed();
        if IsDefined(ms) {
            ms.UntrackMappin();
        }
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_clue_pod", 1);
            qs.SetFact(n"cv_a2_clue_mateo", 1);
            qs.SetFact(n"cv_a2_clue_relay", 1);
            qs.SetFact(n"cv_a2_bunker_cleared", 1);
            qs.SetFact(n"cv_a2_lucia_met", 1);
            qs.SetFact(n"cv_a2_seal_a", 1);
            qs.SetFact(n"cv_a2_sub1_uv_done", 1);
            qs.SetFact(n"cv_a2_sub1_cleared", 1);
            qs.SetFact(n"cv_a2_sub1_door_done", 1);
            qs.SetFact(n"cv_a2_sub2_uv_done", 0);
            qs.SetFact(n"cv_a2_sub2_corr_cleared", 0);
            qs.SetFact(n"cv_a2_sub2_turret_down", 0);
            qs.SetFact(n"cv_a2_solis_met", 0);
            qs.SetFact(n"cv_a2_solis_q1", 0);
            qs.SetFact(n"cv_a2_solis_q2", 0);
            qs.SetFact(n"cv_a2_solis_q3", 0);
            qs.SetFact(n"cv_a2_chamber_cleared", 0);
            qs.SetFact(n"cv_a2_ending", 0);
            qs.SetFact(n"cv_a2_core_done", 0);
            qs.SetFact(n"cv_a2_done", 0);
            qs.SetFact(n"cv_a2_state", 30);
        }
        this.m_sub2PosCached = false;
        this.m_sub2ArrivalBannerShown = false;
        this.m_chamberClearBannerShown = false;
        this.m_sys.SetSubterraneanBunkerEnvActive(true);
        let sub2Entry: Vector4 = new Vector4(69.35, -495.78, -16.52, 1.00);
        this.m_sys.TeleportPlayerSmooth(sub2Entry, this.ComputeFacingYaw(sub2Entry, this.GetSub2CorrUvRawPos()));
        let q: String = "quests/side_quest/crimson_veil_a2_quest";
        let p: String = "quests/side_quest/crimson_veil_a2_quest/phase_a2";
        this.SetAct2ObjectivesSucceeded(jm, [
            p + "/01_a2_flats_convoy", p + "/02_a2_bunker_lucia", p + "/02b_a2_enter_bunker",
            p + "/02c_a2_sub1_seal_a", p + "/02d_a2_sub1_uv_tower", p + "/02e_a2_sub1_clear_hall", p + "/02f_a2_sub1_level2_door"
        ]);
        this.SetAct2ObjectivesInactive(jm, [
            p + "/03b_a2_sub2_clear_hall", p + "/03c_a2_solis_chamber",
            p + "/04_a2_secure_core", p + "/05_a2_sub2_extract", p + "/06_a2_return_misty"
        ]);
        this.m_sys.ActivateObjectiveWithPin(232, q, p, p + "/03a_a2_sub2_uv_tower", p + "/03a_a2_sub2_uv_tower/mp_a2_sub2_uv", p + "/03a_a2_sub2_uv_tower/desc_a2_03a", this.GetAllAct2PinPaths(), true);
        this.m_sys.UpdateFallbackMappin(232, p + "/03a_a2_sub2_uv_tower", new Vector4(62.50, -498.00, -15.60, 1.00), n"cv_pin_sub2_uv", "[1/5 · EMISOR UV CORREDOR] Sobrecargar Emisor UV (365 nm)");
        this.m_lastSyncedStage = 30;
    }

    public final func DebugResetAct2() -> Void {
        this.CleanupEntities();
        this.EnsurePriorActsClosed();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) {
            qs.SetFact(n"cv_a2_ready", 1);
            qs.SetFact(n"cv_a2_state", 0);
            qs.SetFact(n"cv_a2_clue_pod", 0);
            qs.SetFact(n"cv_a2_clue_mateo", 0);
            qs.SetFact(n"cv_a2_clue_relay", 0);
            qs.SetFact(n"cv_a2_bunker_cleared", 0);
            qs.SetFact(n"cv_a2_lucia_met", 0);
            qs.SetFact(n"cv_a2_lucia_q1", 0);
            qs.SetFact(n"cv_a2_lucia_q2", 0);
            qs.SetFact(n"cv_a2_seal_a", 0);
            qs.SetFact(n"cv_a2_sub1_uv_done", 0);
            qs.SetFact(n"cv_a2_sub1_cleared", 0);
            qs.SetFact(n"cv_a2_sub1_turret_down", 0);
            qs.SetFact(n"cv_a2_sub1_door_done", 0);
            qs.SetFact(n"cv_a2_sub2_uv_done", 0);
            qs.SetFact(n"cv_a2_sub2_corr_cleared", 0);
            qs.SetFact(n"cv_a2_sub2_turret_down", 0);
            qs.SetFact(n"cv_a2_solis_met", 0);
            qs.SetFact(n"cv_a2_solis_q1", 0);
            qs.SetFact(n"cv_a2_solis_q2", 0);
            qs.SetFact(n"cv_a2_solis_q3", 0);
            qs.SetFact(n"cv_a2_chamber_cleared", 0);
            qs.SetFact(n"cv_a2_ending", 0);
            qs.SetFact(n"cv_a2_core_done", 0);
            qs.SetFact(n"cv_a2_done", 0);
        }
        this.m_sys.ClearJournalPinsAndResetSync(this.GetAllAct2PinPaths());
        this.m_sys.ClearMappin();
        this.DebugTriggerAct2Call();
    }

    // --- Bucle de Evaluación Acto II ---

    public final func Tick(player: ref<PlayerPuppet>, fullGameplay: Bool) -> Float {
        if !IsDefined(player) || !this.m_sys.IsGameplayReady(player) || !fullGameplay {
            return 0.50;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if !IsDefined(qs) || qs.GetFact(n"cv_a1_done") == 0 {
            return 0.80;
        }

        let stage: Int32 = qs.GetFact(n"cv_a2_state");
        let pPos: Vector4 = player.GetWorldPosition();

        if stage == 0 {
            if this.m_sys.m_isPlayingDialogueSequence || this.m_sys.IsDialogActive() || this.m_sys.IsVanillaPhoneBusy() || this.m_sys.IsPhoneOverlayOpen() {
                this.m_callReadyTicks = 0;
                return 0.60;
            }
            if pPos.Z >= 38.00 {
                this.m_callReadyTicks = 0;
                return 0.60;
            }
            this.m_callReadyTicks += 1;
            if this.m_callReadyTicks >= 5 && !this.m_callAttempted {
                this.m_callAttempted = true;
                qs.SetFact(n"cv_a2_state", 5);
                this.m_sys.StartMistyAct2Call();
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
                if this.m_callReadyTicks >= 4 {
                    this.m_callAttempted = true;
                    this.m_sys.StartMistyAct2Call();
                }
            }
            return 0.45;
        }

        if stage == 10 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.CheckFlatsCluesAdvanced();
            stage = qs.GetFact(n"cv_a2_state");
        }
        if stage >= 10 && (qs.GetFact(n"cv_r2_done") == 0 || qs.GetFact(n"cv_r2_state") < 60 || qs.GetFact(n"cv_a1_done") == 0) {
            this.EnsurePriorActsClosed();
            this.m_lastSyncedStage = -1;
        }
        if this.m_lastSyncedStage != stage {
            this.SyncStageJournalAndPin(stage, false);
        }

        let q105Active: Bool = this.IsVanillaQ105Active(qs);
        let inSubBunker: Bool = this.IsInSubterraneanBunker(pPos);
        this.m_sys.SetSubterraneanBunkerEnvActive(inSubBunker && stage >= 25 && stage <= 50 && !q105Active);
        if (!inSubBunker || q105Active) && (this.m_sub1SpawnedA || this.m_sub1SpawnedF1 || this.m_sub2SpawnedZA || this.m_sub2SpawnedFC || this.m_chamberSpawnedSolis || EntityID.IsDefined(this.m_sub1SealAId) || EntityID.IsDefined(this.m_solisId)) {
            this.DespawnSubterraneanEntities();
        }
        if stage >= 50 && !inSubBunker {
            let desClean: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
            if IsDefined(desClean) {
                desClean.DeleteTagged(n"CV_A2_Solis");
                desClean.DeleteTagged(n"CV_WS_Solis");
                desClean.DeleteTagged(n"CV_A2_SolisCombat");
                desClean.DeleteTagged(n"CV_A2_SolisGuardA");
                desClean.DeleteTagged(n"CV_A2_SolisGuardB");
                desClean.DeleteTagged(n"CV_A2_SolisGuardACombat");
                desClean.DeleteTagged(n"CV_A2_SolisGuardBCombat");
            }
        }

        this.EnsureFlatsScene(player, stage);
        this.EnsureBunkerScene(player, stage);
        this.EnsureSub1Scene(player, stage);
        this.EnsureSub2Scene(player, stage);
        this.EnsureRooftopLuciaScene(player, stage);
        this.SyncActiveStageMappin(player, stage);

        let atEsoterica: Bool = this.m_sys.ComputeDistanceSq(pPos, new Vector4(-1545.60, 1209.20, 15.55, 1.00)) <= 7.84 && AbsF(pPos.Z - 15.55) < 2.80;
        let atMistyRoof: Bool = pPos.Z >= 38.00 && this.m_sys.ComputeDistanceSq(pPos, new Vector4(-1549.10, 1209.69, 57.00, 1.00)) <= 10.24;
        if atEsoterica || atMistyRoof {
            return 0.25;
        }

        if this.m_sys.IsDialogActive() || this.m_sys.IsSpeechBlockingWorldInteraction() || this.m_sys.IsUiBlockingWorldInput() {
            this.m_sys.HideWorldInteraction();
            return 0.25;
        }

        // 1. Biotechnica Flats (3 pistas)
        if stage == 10 && this.m_sys.ComputeDistanceSq(pPos, this.GetFlatsMateoRawPos()) <= 3600.00 {
            this.EnsureFlatsCache();
            let bestKind: Int32 = 0;
            let bestDistSq: Float = 6.25;
            if qs.GetFact(n"cv_a2_clue_pod") == 0 && AbsF(pPos.Z - this.m_podPos.Z) < 2.50 {
                let d1: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_podPos);
                if d1 <= bestDistSq { bestDistSq = d1; bestKind = 201; }
            }
            if qs.GetFact(n"cv_a2_clue_mateo") == 0 && AbsF(pPos.Z - this.m_mateoPos.Z) < 2.50 {
                let d2: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_mateoPos);
                if d2 <= bestDistSq { bestDistSq = d2; bestKind = 202; }
            }
            if qs.GetFact(n"cv_a2_clue_relay") == 0 && AbsF(pPos.Z - this.m_relayPos.Z) < 2.50 {
                let d3: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_relayPos);
                if d3 <= bestDistSq { bestDistSq = d3; bestKind = 203; }
            }
            if bestKind == 201 {
                this.m_sys.ShowWorldInteraction(201, n"cv_hub_a2_pod", "Cápsula Criogénica del Convoy NOX-9", n"cv_act_a2_inspect_pod", "Examinar cápsula de Lucía (L-14)", false, true);
                return 0.20;
            }
            if bestKind == 202 {
                this.m_sys.ShowWorldInteraction(202, n"cv_hub_a2_mateo", "Placa de Mateo y Carta de La Luna", n"cv_act_a2_inspect_mateo", "Recoger placa de Mateo (M-09)", false, true);
                return 0.20;
            }
            if bestKind == 203 {
                this.m_sys.ShowWorldInteraction(203, n"cv_hub_a2_relay", "Repetidor de Microondas Biotechnica", n"cv_act_a2_inspect_relay", "Triangular búnker del Coro Pálido", false, true);
                return 0.20;
            }
        }

        // 2. Superficie del Búnker (Exterior + conversación con Lucía + Escotilla)
        if stage >= 20 && stage <= 40 && !inSubBunker && this.m_sys.ComputeDistanceSq(pPos, this.GetBunkerArrivalPos()) <= 8100.00 {
            this.EnsureBunkerCache();
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let isDay: Bool = this.m_sys.IsDaytimeNow();

            let outerCleared: Bool = qs.GetFact(n"cv_a2_bunker_cleared") > 0;
            if stage == 20 && !outerCleared && this.m_outerSpawnedA {
                let outerElapsed: Float = MaxF(0.10, nowSim - this.m_bunkerCombatStart);
                let outClearedNow: Bool = this.m_sys.IsNpcNeutralized(this.m_sentryAId, this.m_luciaPos, outerElapsed)
                    && this.m_sys.IsNpcNeutralized(this.m_sentryBId, this.m_luciaPos, outerElapsed);
                if outClearedNow {
                    qs.SetFact(n"cv_a2_bunker_cleared", 1);
                    outerCleared = true;
                    this.SyncActiveStageMappin(player, 20);
                } else if IsDefined(this.m_sys.m_vampyreCombat) {
                    this.m_sys.m_vampyreCombat.TickVampyreSquadRegen(player, this.m_luciaPos, [this.m_sentryAId, this.m_sentryBId], isDay);
                }
            }
            if outerCleared && !this.m_outerClearBannerShown {
                this.m_outerClearBannerShown = true;
                this.m_sys.ShowRelicBanner(n"cv_banner_a2_outer_clear", "[PERÍMETRO DESPEJADO] Habla con Lucía Reyes junto al acceso");
            }

            if (stage > 20 || outerCleared) && this.m_sys.ComputeDistanceSq(pPos, this.m_luciaPos) <= 10.24 && AbsF(pPos.Z - this.m_luciaPos.Z) < 3.00 {
                this.m_sys.ShowWorldInteraction(207, n"cv_hub_lucia_title", "Lucía Reyes — Acceso al Búnker", n"cv_act_talk_lucia", "Hablar con Lucía Reyes", true, true);
                return 0.20;
            }

            if this.m_sys.ComputeDistanceSq(pPos, this.m_surfaceHatchPos) <= 10.24 && AbsF(pPos.Z - this.m_surfaceHatchPos.Z) < 3.50 {
                if stage >= 25 {
                    this.m_sys.ShowWorldInteraction(215, n"cv_hub_hatch_surface", "Compuerta del Búnker Subterráneo", n"cv_act_hatch_enter", "Descender al Subnivel -1 (Nave de Diálisis)", false, true);
                } else {
                    this.m_sys.ShowWorldInteraction(215, n"cv_hub_hatch_surface", "Compuerta del Búnker Subterráneo", n"cv_act_hatch_locked", "Compuerta sellada (Despeja el acceso y habla con Lucía)", false, true);
                }
                return 0.20;
            }

            if !outerCleared && this.m_sys.ComputeDistanceSq(pPos, this.m_outerUvPos) <= 20.25 && AbsF(pPos.Z - this.m_outerUvPos.Z) < 4.00 {
                if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim) {
                    this.m_sys.ShowWorldInteraction(205, n"cv_hub_uv_bunker", "Torre UV Exterior (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                } else {
                    this.m_sys.ShowWorldInteraction(204, n"cv_hub_uv_bunker", "Torre UV Exterior (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                }
                return 0.20;
            }
        }

        // 3. Búnker Subterráneo: Nivel 1 (Z > -10.50) y Nivel 2 (Z <= -10.50)
        if inSubBunker && stage >= 25 && stage <= 50 && !q105Active {
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));

            if pPos.Z > -10.50 {
                this.EnsureSub1Cache();
                let all5SpawnedSub1: Bool = this.m_sub1SpawnedA && this.m_sub1SpawnedB && this.m_sub1SpawnedF1 && this.m_sub1SpawnedF2 && this.m_sub1SpawnedF3;
                let sub1Cleared: Bool = qs.GetFact(n"cv_a2_sub1_cleared") > 0;
                if stage == 25 && !sub1Cleared && all5SpawnedSub1 {
                    let s1El: Float = MaxF(0.10, nowSim - this.m_sub1CombatStart);
                    if this.m_sys.IsNpcNeutralized(this.m_sub1StalkerAId, this.m_sub1StalkerAPos, s1El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub1StalkerBId, this.m_sub1StalkerBPos, s1El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub1Fanatic1Id, this.m_sub1Fanatic1Pos, s1El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub1Fanatic2Id, this.m_sub1Fanatic2Pos, s1El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub1Fanatic3Id, this.m_sub1Fanatic3Pos, s1El) {
                        qs.SetFact(n"cv_a2_sub1_cleared", 1);
                        sub1Cleared = true;
                        if qs.GetFact(n"cv_a2_sub1_uv_done") > 0 {
                            this.m_sys.ShowRelicBanner(n"cv_banner_hall_cleared", "[NAVE DESPEJADA] Sube la rampa hasta la puerta de entrada al Nivel 2");
                        }
                        this.SyncStageJournalAndPin(25, true);
                        this.SyncActiveStageMappin(player, 25);
                    } else if IsDefined(this.m_sys.m_vampyreCombat) {
                        this.m_sys.m_vampyreCombat.TickVampyreSquadRegen(player, this.m_sub1StalkerAPos, [this.m_sub1StalkerAId, this.m_sub1StalkerBId, this.m_sub1Fanatic1Id, this.m_sub1Fanatic2Id, this.m_sub1Fanatic3Id], false);
                    }
                }

                if this.m_sys.ComputeDistanceSq(pPos, this.m_sub1ExitHatchPos) <= 4.00 {
                    this.m_sys.ShowWorldInteraction(216, n"cv_hub_hatch_exit", "Montacargas de Subida a Superficie", n"cv_act_hatch_surface", "Subir a la superficie junto a Lucía", false, true);
                    return 0.20;
                }
                if qs.GetFact(n"cv_a2_seal_a") == 0 && this.m_sys.ComputeDistanceSq(pPos, this.m_sub1SealAPos) <= 10.24 {
                    this.m_sys.ShowWorldInteraction(219, n"cv_hub_seal_a", "Relé de Sello de Acceso", n"cv_act_seal_purge", "Puentear y purgar sello criogénico", false, true);
                    return 0.20;
                }
                if this.m_sys.ComputeDistanceSq(pPos, this.m_sub1UvPos) <= 16.00 {
                    if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim) {
                        this.m_sys.ShowWorldInteraction(218, n"cv_hub_uv_sub1", "Torre UV de la Nave (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                    } else {
                        this.m_sys.ShowWorldInteraction(217, n"cv_hub_uv_sub1", "Torre UV de la Nave (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                    }
                    return 0.20;
                }
                if qs.GetFact(n"cv_a2_sub1_door_done") == 0
                    && (this.m_sys.ComputeDistanceSq(pPos, this.m_sub1Level2DoorTriggerPos) <= 10.24
                        || this.m_sys.ComputeDistanceSq(pPos, this.m_sub1Level2DoorConsolePos) <= 10.24) {
                    let allReady: Bool = (qs.GetFact(n"cv_a2_seal_a") > 0 && qs.GetFact(n"cv_a2_sub1_uv_done") > 0 && sub1Cleared) || stage >= 30;
                    if allReady {
                        this.m_sys.ShowWorldInteraction(221, n"cv_hub_level2_door", "Puerta de Entrada al Nivel 2", n"cv_act_level2_door_open", "Descender al Nivel 2 (Santuario Carmesí)", false, true);
                    } else {
                        this.m_sys.ShowWorldInteraction(221, n"cv_hub_level2_door", "Puerta de Entrada al Nivel 2", n"cv_act_level2_door_locked", "Puerta sellada (Sobrecarga el Emisor UV y despeja la nave primero)", false, true);
                    }
                    return 0.20;
                }
            } else {
                // Subnivel -2 (Z <= -10.50)
                this.EnsureSub2Cache();
                let all5SpawnedSub2: Bool = this.m_sub2SpawnedZA && this.m_sub2SpawnedZB && this.m_sub2SpawnedFC && this.m_sub2SpawnedFD && this.m_sub2SpawnedFE;
                let corrCleared: Bool = qs.GetFact(n"cv_a2_sub2_corr_cleared") > 0;
                if stage >= 30 && stage <= 40 && !corrCleared && all5SpawnedSub2 {
                    let s2El: Float = MaxF(0.10, nowSim - this.m_sub2CombatStart);
                    if this.m_sys.IsNpcNeutralized(this.m_sub2ZealotAId, this.m_sub2ZealotAPos, s2El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub2ZealotBId, this.m_sub2ZealotBPos, s2El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub2FanaticCId, this.m_sub2FanaticCPos, s2El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub2FanaticDId, this.m_sub2FanaticDPos, s2El)
                        && this.m_sys.IsNpcNeutralized(this.m_sub2FanaticEId, this.m_sub2FanaticEPos, s2El) {
                        qs.SetFact(n"cv_a2_sub2_corr_cleared", 1);
                        corrCleared = true;
                        if qs.GetFact(n"cv_a2_sub2_uv_done") > 0 {
                            this.m_sys.ShowRelicBanner(n"cv_banner_sub2_hall_clear", "[CORREDOR DESPEJADO] Avanza al sur por el pasillo hasta la Dra. Helena Solís");
                        }
                        this.SyncStageJournalAndPin(30, true);
                        this.SyncActiveStageMappin(player, 30);
                    } else if IsDefined(this.m_sys.m_vampyreCombat) {
                        this.m_sys.m_vampyreCombat.TickVampyreSquadRegen(player, this.m_sub2ZealotAPos, [this.m_sub2ZealotAId, this.m_sub2ZealotBId, this.m_sub2FanaticCId, this.m_sub2FanaticDId, this.m_sub2FanaticEId], false);
                    }
                }

                let chamberCleared: Bool = qs.GetFact(n"cv_a2_chamber_cleared") > 0;
                if stage == 40 && !chamberCleared {
                    let chElapsed: Float = MaxF(0.10, nowSim - this.m_chamberCombatStart);
                    let chClearedNow: Bool = this.m_solisCombatSwapped
                        && this.m_sys.IsNpcNeutralized(this.m_solisId, this.m_solisPos, chElapsed)
                        && this.m_sys.IsNpcNeutralized(this.m_solisGuardAId, this.m_solisPos, chElapsed)
                        && this.m_sys.IsNpcNeutralized(this.m_solisGuardBId, this.m_solisPos, chElapsed)
                        && (!this.m_solisPhase2Triggered || (this.m_sys.IsNpcNeutralized(this.m_solisReinfAId, this.m_solisPos, chElapsed) && this.m_sys.IsNpcNeutralized(this.m_solisReinfBId, this.m_solisPos, chElapsed)));
                    if chClearedNow {
                        qs.SetFact(n"cv_a2_chamber_cleared", 1);
                        chamberCleared = true;
                        this.SyncActiveStageMappin(player, 40);
                    } else {
                        if !this.m_solisCombatSwapped {
                            this.SpawnSolisCombatSquad(player);
                        }
                        this.EnsureListHostile([this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId, this.m_solisReinfAId, this.m_solisReinfBId], player, true);
                        if !this.m_solisPhase2Triggered && EntityID.IsDefined(this.m_solisId) {
                            let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
                            if IsDefined(sps) {
                                let solisHp: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(this.m_solisId), gamedataStatPoolType.Health, true);
                                if solisHp > 1.00 && solisHp <= 55.00 {
                                    this.TriggerSolisPhase2(player);
                                }
                            }
                        }
                        if IsDefined(this.m_sys.m_vampyreCombat) {
                            this.m_sys.m_vampyreCombat.TickVampyreSquadRegen(player, this.m_solisPos, [this.m_solisId, this.m_solisGuardAId, this.m_solisGuardBId, this.m_solisReinfAId, this.m_solisReinfBId], false);
                        }
                    }
                }
                if stage == 40 && chamberCleared && !this.m_chamberClearBannerShown {
                    this.m_chamberClearBannerShown = true;
                    this.m_sys.ShowRelicBanner(n"cv_banner_a2_chamber_clear", "[CÁMARA DESPEJADA] Accede al biorreactor NOX-9B");
                }

                if this.m_sys.ComputeDistanceSq(pPos, this.m_sub2ExtractHatchPos) <= 10.24 {
                    this.m_sys.ShowWorldInteraction(222, n"cv_hub_hatch_extract", "Conducto de Extracción de Emergencia", n"cv_act_hatch_extract", "Evacuar a la superficie junto a Lucía", false, true);
                    return 0.20;
                }
                if this.m_sys.ComputeDistanceSq(pPos, this.m_sub2CorrUvPos) <= 16.00 {
                    if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim) {
                        this.m_sys.ShowWorldInteraction(218, n"cv_hub_uv_sub2_corr", "Torre UV del Corredor (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                    } else {
                        this.m_sys.ShowWorldInteraction(223, n"cv_hub_uv_sub2_corr", "Torre UV del Corredor (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                    }
                    return 0.20;
                }
                if stage == 30 && this.m_sys.ComputeDistanceSq(pPos, this.m_solisPos) <= 12.25 && AbsF(pPos.Z - this.m_solisPos.Z) < 3.00 {
                    this.m_sys.ShowWorldInteraction(208, n"cv_hub_solis_title", "Dra. Helena Solís («La Cantora»)", n"cv_act_talk_solis", "Confrontar a Helena Solís", true, true);
                    return 0.20;
                }
                if !chamberCleared && EntityID.IsDefined(this.m_chamberUvId) && this.m_sys.ComputeDistanceSq(pPos, this.m_chamberUvPos) <= 20.25 && AbsF(pPos.Z - this.m_chamberUvPos.Z) < 4.00 {
                    if stage == 40 {
                        if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(2, nowSim) {
                            this.m_sys.ShowWorldInteraction(210, n"cv_hub_uv_chamber", "Torre UV del Reactor (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                        } else {
                            this.m_sys.ShowWorldInteraction(209, n"cv_hub_uv_chamber", "Torre UV del Reactor (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                        }
                    } else {
                        this.m_sys.ShowWorldInteraction(206, n"cv_hub_uv_chamber", "Torre UV del Reactor (365 nm)", n"cv_act_uv_check", "Comprobar torre emisora UV", false, true);
                    }
                    return 0.20;
                }
                if stage == 40 && this.m_sys.ComputeDistanceSq(pPos, this.m_corePos) <= 12.25 && AbsF(pPos.Z - this.m_corePos.Z) < 3.50 {
                    if chamberCleared {
                        let endChoice: Int32 = qs.GetFact(n"cv_a2_ending");
                        if endChoice == 3 {
                            this.m_sys.ShowWorldInteraction(211, n"cv_hub_core_title", "Biorreactor NOX-9B", n"cv_act_burn_core", "Purgar y destruir el suero NOX-9B", false, true);
                        } else {
                            this.m_sys.ShowWorldInteraction(211, n"cv_hub_core_title", "Biorreactor NOX-9B", n"cv_act_take_core", "Descargar fórmula NOX-9B intacta", false, true);
                        }
                    } else {
                        this.m_sys.ShowWorldInteraction(212, n"cv_hub_core_title", "Biorreactor NOX-9B", n"cv_act_core_locked", "Biorreactor sellado", false, true);
                    }
                    return 0.20;
                }
            }
        }

        this.m_sys.HideWorldInteraction();
        return 0.35;
    }

    public final func GetSub1DebugStatus() -> String {
        if !IsDefined(this.m_sys) {
            return "Sub1: sin sistema";
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let inSub: Bool = IsDefined(player) && this.IsInSubterraneanBunker(player.GetWorldPosition());
        let q105Blk: Bool = this.IsVanillaQ105Active(qs);
        let envOn: Bool = this.m_sys.IsSubterraneanBunkerEnvActive();
        let sealA: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_seal_a") : -1;
        let uvDone: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_sub1_uv_done") : -1;
        let clr: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_sub1_cleared") : -1;
        let doorDone: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_sub1_door_done") : -1;
        let hasA: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_sub1SealAId) && ses.IsSpawned(this.m_sub1SealAId);
        let hasUV: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_sub1UvId) && ses.IsSpawned(this.m_sub1UvId);
        let hasL2: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_sub1Level2DoorConsoleId) && ses.IsSpawned(this.m_sub1Level2DoorConsoleId);
        return "Sub1[inSub=" + (inSub ? "1" : "0")
            + " cached=" + (this.m_sub1PosCached ? "1" : "0")
            + " q105Blk=" + (q105Blk ? "1" : "0")
            + " env=" + (envOn ? "1" : "0")
            + " sealA=" + IntToString(sealA)
            + " uv=" + IntToString(uvDone)
            + " clr=" + IntToString(clr)
            + " door=" + IntToString(doorDone)
            + " entA=" + (hasA ? "1" : "0")
            + " entUV=" + (hasUV ? "1" : "0")
            + " entL2=" + (hasL2 ? "1" : "0") + "]";
    }

    public final func GetSub2DebugStatus() -> String {
        if !IsDefined(this.m_sys) {
            return "Sub2: sin sistema";
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let inSub2: Bool = false;
        if IsDefined(player) {
            let pPos2: Vector4 = player.GetWorldPosition();
            inSub2 = this.IsInSubterraneanBunker(pPos2) && pPos2.Z <= -10.50;
        }
        let uv: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_sub2_uv_done") : -1;
        let clr: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_sub2_corr_cleared") : -1;
        let solisMet: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_solis_met") : -1;
        let core: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a2_core_done") : -1;
        let hasUV: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_sub2CorrUvId) && ses.IsSpawned(this.m_sub2CorrUvId);
        let hasSolis: Bool = IsDefined(des) && EntityID.IsDefined(this.m_solisId) && des.IsSpawned(this.m_solisId);
        let hasCore: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_nox9bChamberId) && ses.IsSpawned(this.m_nox9bChamberId);
        let hasExt: Bool = IsDefined(ses) && EntityID.IsDefined(this.m_sub2ExtractHatchId) && ses.IsSpawned(this.m_sub2ExtractHatchId);
        return "Sub2[inSub2=" + (inSub2 ? "1" : "0")
            + " cached=" + (this.m_sub2PosCached ? "1" : "0")
            + " uv=" + IntToString(uv)
            + " clr=" + IntToString(clr)
            + " solis=" + IntToString(solisMet)
            + " core=" + IntToString(core)
            + " entUV=" + (hasUV ? "1" : "0")
            + " entSolis=" + (hasSolis ? "1" : "0")
            + " entCore=" + (hasCore ? "1" : "0")
            + " entExt=" + (hasExt ? "1" : "0") + "]";
    }
}
