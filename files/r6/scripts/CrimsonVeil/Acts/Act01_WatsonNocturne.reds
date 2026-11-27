// Velo Carmesí / Crimson Veil — Acto I en Watson: «El Pulso del Lote NOX-9» (Juego Base 2.x, 0 ep1)
module CrimsonVeil

public class CrimsonVeilAct01Handler {
    private let m_sys: wref<CrimsonVeilSystem>;

    // Entidades del Muelle Sur de Kabuki (Escena Forense de 3 Pistas)
    private let m_coolerId: EntityID;
    private let m_kShrineId: EntityID;
    private let m_relayId: EntityID;
    private let m_kabukiIntroPlayed: Bool;

    // Entidades del Patio del Night City Medical Center en Little China (Dr. Adrián Valdés)
    private let m_valdesId: EntityID;
    private let m_valdesWsAnchorId: EntityID;
    private let m_valdesDeskId: EntityID;

    // Entidades del Puesto Criogénico en Northside Docks Oeste (Día vs. Noche + Torres UV + Sigilo vs. Combate)
    private let m_uvWestId: EntityID;
    private let m_uvEastId: EntityID;
    private let m_vaultTermId: EntityID;
    private let m_gatekeeperId: EntityID;
    private let m_gatekeeperWsId: EntityID;
    private let m_cellAId: EntityID;
    private let m_cellBId: EntityID;
    private let m_gateSpawned: Bool;
    private let m_cellASpawned: Bool;
    private let m_cellBSpawned: Bool;
    private let m_pierArrivalPlayed: Bool;
    private let m_pierSpawnTime: Float;
    private let m_pierClearBannerShown: Bool;
    private let m_pierStealthFriendlyApplied: Bool;
    private let m_pierDayPenaltyApplied: Bool;

    // Cachés de cota de suelo real (FindGroundZWideChecked)
    private let m_kabukiPosCached: Bool;
    private let m_coolerPos: Vector4;
    private let m_kShrinePos: Vector4;
    private let m_relayPos: Vector4;

    private let m_valdesPosCached: Bool;
    private let m_valdesPos: Vector4;
    private let m_valdesDeskPos: Vector4;

    private let m_pierPosCached: Bool;
    private let m_gatePos: Vector4;
    private let m_uvWestPos: Vector4;
    private let m_uvEastPos: Vector4;
    private let m_vaultPos: Vector4;
    private let m_cellAPos: Vector4;
    private let m_cellBPos: Vector4;

    // Estado de disparo de llamada puente y sincronización
    private let m_callAttempted: Bool;
    private let m_callReadyTicks: Int32;
    private let m_lastSyncedStage: Int32;

    // -----------------------------------------------------------------------
    // Localizaciones 100 % Originales y Peatonales (>= 250 m de otros mods)
    // Verificadas contra 03_night_city.mappins / poimappins (cero calzadas)
    // -----------------------------------------------------------------------

    // 1. Paseo peatonal del Muelle Sur de Kabuki (junto a sts_wat_kab_102)
    private final func GetKabukiArrivalPos() -> Vector4 = new Vector4(-1026.20, 1293.00, 5.15, 1.00);
    private final func GetKabukiCoolerRawPos() -> Vector4 = new Vector4(-1031.15, 1291.32, 5.10, 1.00);
    private final func GetKabukiShrineRawPos() -> Vector4 = new Vector4(-1033.30, 1291.10, 5.14, 1.00);
    private final func GetKabukiRelayRawPos() -> Vector4 = new Vector4(-1035.41, 1290.86, 5.17, 1.00);

    // 2. Plaza peatonal abierta en Little China Norte (captura CET en vivo + auditoría 3D exterior_-25_27_0_0: 0 techos/obstáculos, a 4.73 m del worldAISpotNode vanilla, 0 bandas/seguridad en 35 m)
    private final func GetValdesArrivalPos() -> Vector4 = new Vector4(-1576.20, 1764.90, 18.38, 1.00);
    private final func GetValdesNpcRawPos() -> Vector4 = new Vector4(-1578.39, 1766.98, 18.38, 1.00);
    private final func GetValdesDeskRawPos() -> Vector4 = new Vector4(-1579.70, 1766.15, 18.38, 1.00);
    private final func GetValdesPlayerRefPos() -> Vector4 = new Vector4(-1576.58, 1765.26, 18.38, 1.00);

    // 3. Muelle industrial abierto de Northside Docks Oeste (centro despejado de la explanada, alejado de workspots de mendigos del borde norte)
    private final func GetPierArrivalPos() -> Vector4 = new Vector4(-1896.00, 2738.00, 7.05, 1.00);
    private final func GetGatekeeperRawPos() -> Vector4 = new Vector4(-1904.40, 2746.40, 7.10, 1.00);
    private final func GetUvWestRawPos() -> Vector4 = new Vector4(-1909.50, 2746.50, 7.10, 1.00);
    private final func GetUvEastRawPos() -> Vector4 = new Vector4(-1901.00, 2752.50, 7.10, 1.00);
    private final func GetCellARawPos() -> Vector4 = new Vector4(-1909.50, 2752.00, 7.10, 1.00);
    private final func GetCellBRawPos() -> Vector4 = new Vector4(-1902.50, 2751.00, 7.10, 1.00);
    private final func GetVaultTerminalRawPos() -> Vector4 = new Vector4(-1905.80, 2748.20, 7.10, 1.00);

    private final func ComputeFacingYaw(fromPos: Vector4, toPos: Vector4) -> Float {
        let dx: Float = toPos.X - fromPos.X;
        let dy: Float = toPos.Y - fromPos.Y;
        return Rad2Deg(AtanF(dy, dx)) - 90.00;
    }

    public final func Initialize(sys: ref<CrimsonVeilSystem>) -> Void {
        this.m_sys = sys;
        this.ResetTransientFlags();
    }

    private final func ResetTransientFlags() -> Void {
        this.m_kabukiIntroPlayed = false;
        this.m_gateSpawned = false;
        this.m_cellASpawned = false;
        this.m_cellBSpawned = false;
        this.m_pierArrivalPlayed = false;
        this.m_pierSpawnTime = 0.00;
        this.m_pierClearBannerShown = false;
        this.m_pierStealthFriendlyApplied = false;
        this.m_pierDayPenaltyApplied = false;
        this.m_kabukiPosCached = false;
        this.m_valdesPosCached = false;
        this.m_pierPosCached = false;
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
        this.m_lastSyncedStage = -1;
    }

    public final func GetValdesEntityID() -> EntityID = this.m_valdesId;
    public final func GetGatekeeperEntityID() -> EntityID = this.m_gatekeeperId;

    public final func OnSaveRestored() -> Void {
        this.m_coolerId = new EntityID();
        this.m_kShrineId = new EntityID();
        this.m_relayId = new EntityID();
        this.m_valdesId = new EntityID();
        this.m_valdesWsAnchorId = new EntityID();
        this.m_valdesDeskId = new EntityID();
        this.m_uvWestId = new EntityID();
        this.m_uvEastId = new EntityID();
        this.m_vaultTermId = new EntityID();
        this.m_gatekeeperId = new EntityID();
        this.m_gatekeeperWsId = new EntityID();
        this.m_cellAId = new EntityID();
        this.m_cellBId = new EntityID();
        this.ResetTransientFlags();
    }

    public final func ResetPendingAct1CallForRetry() -> Void {
        this.m_callAttempted = false;
        this.m_callReadyTicks = 0;
        if IsDefined(this.m_sys) {
            let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
            if IsDefined(qs) && qs.GetFact(n"cv_a1_state") == 5 {
                qs.SetFact(n"cv_a1_state", 0);
            }
        }
    }

    public final func CleanupEntities() -> Void {
        if IsDefined(this.m_sys) {
            this.m_sys.DespawnStaticPropById(this.m_coolerId);
            this.m_sys.DespawnStaticPropById(this.m_kShrineId);
            this.m_sys.DespawnStaticPropById(this.m_relayId);
            this.m_sys.DespawnStaticPropById(this.m_valdesDeskId);
            this.m_sys.DespawnStaticPropById(this.m_uvWestId);
            this.m_sys.DespawnStaticPropById(this.m_uvEastId);
            this.m_sys.DespawnStaticPropById(this.m_vaultTermId);
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            des.DeleteTagged(n"CV_ValdesNPC");
            des.DeleteTagged(n"CV_WS_Valdes");
            des.DeleteTagged(n"CV_A1_Gatekeeper");
            des.DeleteTagged(n"CV_WS_Gatekeeper");
            des.DeleteTagged(n"CV_A1_CellA");
            des.DeleteTagged(n"CV_A1_CellB");
        }
        this.OnSaveRestored();
    }

    private final func GetAllAct1PinPaths() -> array<String> {
        let p: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
        return [
            p + "/01_a1_kabuki_trace/mp_a1_kabuki",
            p + "/02_a1_valdes_hideout/mp_a1_valdes",
            p + "/03_a1_waterfront_cryo/mp_a1_waterfront",
            p + "/04_a1_return_misty/mp_a1_return_misty"
        ];
    }

    private final func SyncStageJournalAndPin(stage: Int32, notify: Bool) -> Void {
        if !IsDefined(this.m_sys) || stage < 10 {
            return;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) && qs.GetFact(n"cv_a2_state") > 0 {
            return;
        }
        let q: String = "quests/side_quest/crimson_veil_a1_quest";
        let p: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let allPins: array<String> = this.GetAllAct1PinPaths();

        if stage == 10 {
            this.m_sys.ActivateObjectiveWithPin(110, q, p, p + "/01_a1_kabuki_trace", p + "/01_a1_kabuki_trace/mp_a1_kabuki", p + "/01_a1_kabuki_trace/desc_a1_01", allPins, notify);
            this.m_sys.UpdateFallbackMappin(110, p + "/01_a1_kabuki_trace", new Vector4(-1033.30, 1291.10, 5.95, 1.00), n"cv_mappin_a1_kabuki", "Muelle Sur de Kabuki: Descarte Criogénico (3 Pistas)");
        } else if stage == 20 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_a1_kabuki_trace", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            this.m_sys.ActivateObjectiveWithPin(120, q, p, p + "/02_a1_valdes_hideout", p + "/02_a1_valdes_hideout/mp_a1_valdes", p + "/02_a1_valdes_hideout/desc_a1_02", allPins, notify);
            this.m_sys.UpdateFallbackMappin(120, p + "/02_a1_valdes_hideout", new Vector4(-1578.39, 1766.98, 19.73, 1.00), n"cv_mappin_a1_valdes", "Little China Norte (Plaza Peatonal): Dr. Adrián Valdés");
        } else if stage == 30 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_a1_kabuki_trace", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_a1_valdes_hideout", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            this.m_sys.ActivateObjectiveWithPin(130, q, p, p + "/03_a1_waterfront_cryo", p + "/03_a1_waterfront_cryo/mp_a1_waterfront", p + "/03_a1_waterfront_cryo/desc_a1_03", allPins, notify);
            this.m_sys.UpdateFallbackMappin(130, p + "/03_a1_waterfront_cryo", new Vector4(-1905.80, 2748.20, 8.60, 1.00), n"cv_mappin_a1_waterfront", "Muelle Oeste (Northside Docks): Puesto Criogénico del Coro");
        } else if stage == 40 {
            if IsDefined(jm) {
                jm.ChangeEntryState(p + "/01_a1_kabuki_trace", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/02_a1_valdes_hideout", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/03_a1_waterfront_cryo", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
            }
            this.m_sys.ActivateObjectiveWithPin(140, q, p, p + "/04_a1_return_misty", p + "/04_a1_return_misty/mp_a1_return_misty", p + "/04_a1_return_misty/desc_a1_04", allPins, notify);
            this.m_sys.UpdateFallbackMappin(140, p + "/04_a1_return_misty", new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_a1_return_misty", "Callejón tras Misty's Esoterica: Informar a Misty en la azotea");
        } else if stage >= 50 {
            this.m_sys.ClearJournalPinsAndResetSync(allPins);
            this.m_sys.ClearMappin();
        }
        this.m_sys.SyncCodexJournalShards();
        this.m_lastSyncedStage = stage;
    }

    private final func SyncActiveStageMappin(player: ref<PlayerPuppet>, stage: Int32) -> Void {
        if !IsDefined(this.m_sys) || !IsDefined(player) || stage < 10 || stage >= 50 {
            return;
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) && qs.GetFact(n"cv_a2_state") > 0 {
            return;
        }
        let q: String = "quests/side_quest/crimson_veil_a1_quest";
        let p: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
        let allPins: array<String> = this.GetAllAct1PinPaths();
        let pPos: Vector4 = player.GetWorldPosition();

        if stage == 10 {
            this.m_sys.SyncObjectivePinLoop(110, q, p, p + "/01_a1_kabuki_trace", p + "/01_a1_kabuki_trace/mp_a1_kabuki", allPins);
            this.m_sys.UpdateFallbackMappin(110, p + "/01_a1_kabuki_trace", new Vector4(-1033.30, 1291.10, 5.95, 1.00), n"cv_mappin_a1_kabuki", "Muelle Sur de Kabuki: Descarte Criogénico (3 Pistas)");
        } else if stage == 20 {
            let vPinPos: Vector4 = this.m_valdesPosCached ? new Vector4(this.m_valdesPos.X, this.m_valdesPos.Y, this.m_valdesPos.Z + 1.35, 1.00) : new Vector4(-1578.39, 1766.98, 19.73, 1.00);
            this.m_sys.SyncObjectivePinLoop(120, q, p, p + "/02_a1_valdes_hideout", p + "/02_a1_valdes_hideout/mp_a1_valdes", allPins);
            this.m_sys.UpdateFallbackMappin(120, p + "/02_a1_valdes_hideout", vPinPos, n"cv_mappin_a1_valdes", "Little China Norte (Plaza Peatonal): Dr. Adrián Valdés");
        } else if stage == 30 {
            let infiltrated: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_infiltrated") > 0;
            let combatActive: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_pier_combat") > 0;
            let cleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_pier_cleared") > 0;
            if this.m_sys.ComputeDistanceSq(pPos, this.GetPierArrivalPos()) <= 6400.00 {
                this.EnsurePierCache();
            }
            if infiltrated || cleared {
                let vPin: Vector4 = this.m_pierPosCached ? this.m_vaultPos : this.GetVaultTerminalRawPos();
                vPin.Z += 1.70;
                this.m_sys.ClearJournalPinsAndResetSync(allPins);
                this.m_sys.UpdateDynamicMappin(132, vPin, n"cv_act_take_manifest", "Descargar Manifiesto NOX-9 de las Badlands");
            } else if combatActive {
                let uvPin: Vector4 = this.m_pierPosCached ? this.m_uvWestPos : this.GetUvWestRawPos();
                uvPin.Z += 1.85;
                this.m_sys.ClearJournalPinsAndResetSync(allPins);
                this.m_sys.UpdateDynamicMappin(131, uvPin, n"cv_mappin_uv_emitter", "Torre UV Oeste / Este (Sobrecargar 365 nm)");
            } else {
                this.m_sys.SyncObjectivePinLoop(130, q, p, p + "/03_a1_waterfront_cryo", p + "/03_a1_waterfront_cryo/mp_a1_waterfront", allPins);
                this.m_sys.UpdateFallbackMappin(130, p + "/03_a1_waterfront_cryo", new Vector4(-1905.80, 2748.20, 8.60, 1.00), n"cv_mappin_a1_waterfront", "Muelle Oeste (Northside Docks): Puesto Criogénico del Coro");
            }
        } else if stage == 40 {
            if pPos.Z >= 38.00 {
                this.m_sys.ClearJournalPinsAndResetSync(allPins);
                this.m_sys.UpdateDynamicMappin(141, new Vector4(-1549.10, 1209.69, 58.65, 1.00), n"cv_mappin_rooftop", "Azotea de Misty (Little China)");
            } else {
                this.m_sys.SyncObjectivePinLoop(140, q, p, p + "/04_a1_return_misty", p + "/04_a1_return_misty/mp_a1_return_misty", allPins);
                this.m_sys.UpdateFallbackMappin(140, p + "/04_a1_return_misty", new Vector4(-1545.60, 1209.20, 16.45, 1.00), n"cv_mappin_a1_return_misty", "Callejón tras Misty's Esoterica: Informar a Misty en la azotea");
            }
        }
    }

    // --- Cachés de Suelo y Despliegue de Escenarios ---

    private final func EnsureKabukiCache() -> Void {
        if this.m_kabukiPosCached || !IsDefined(this.m_sys) {
            return;
        }
        let hitAny: Bool = false;
        let zHit: Float = 0.00;

        let p1: Vector4 = this.GetKabukiCoolerRawPos();
        if this.m_sys.FindGroundZWideChecked(p1, zHit) {
            p1.Z = zHit;
            hitAny = true;
        }
        this.m_coolerPos = p1;

        let p2: Vector4 = this.GetKabukiShrineRawPos();
        if this.m_sys.FindGroundZWideChecked(p2, zHit) {
            p2.Z = zHit;
            hitAny = true;
        }
        this.m_kShrinePos = p2;

        let p3: Vector4 = this.GetKabukiRelayRawPos();
        if this.m_sys.FindGroundZWideChecked(p3, zHit) {
            p3.Z = zHit;
            hitAny = true;
        }
        this.m_relayPos = p3;

        if hitAny {
            this.m_kabukiPosCached = true;
        }
    }

    private final func EnsureValdesCache() -> Void {
        if this.m_valdesPosCached || !IsDefined(this.m_sys) {
            return;
        }
        let resolvedNpc: Vector4;
        if !this.m_sys.ResolveClearPedestrianSpot(this.GetValdesNpcRawPos(), 0.85, 0.65, resolvedNpc) {
            return;
        }
        this.m_valdesPos = resolvedNpc;

        let rawDesk: Vector4 = this.GetValdesDeskRawPos();
        let resolvedDesk: Vector4 = rawDesk;
        let deskFound: Bool = false;
        if this.m_sys.HasStaticFloorNear(rawDesk, this.m_valdesPos.Z, 0.55, 1.20) {
            let zDesk: Float = this.m_sys.FindFloorZInRange(rawDesk, this.m_valdesPos.Z, 0.55, 1.20);
            let directDesk: Vector4 = new Vector4(rawDesk.X, rawDesk.Y, zDesk, 1.00);
            if AbsF(zDesk - this.m_valdesPos.Z) <= 0.40 && this.m_sys.IsSpotClearOfProps(directDesk, 0.65) && this.m_sys.HasClearWalkPath(this.m_valdesPos, directDesk) {
                resolvedDesk = directDesk;
                deskFound = true;
            }
        }
        if !deskFound {
            let sideX: array<Float> = [1.35, -1.35, 0.75, -0.75, 1.55, -1.55, 0.00, 1.10];
            let sideY: array<Float> = [0.75, 0.75, 1.35, 1.35, 0.00, 0.00, -1.55, -1.10];
            let i: Int32 = 0;
            while i < ArraySize(sideX) {
                let dCand: Vector4 = new Vector4(this.m_valdesPos.X + sideX[i], this.m_valdesPos.Y + sideY[i], this.m_valdesPos.Z, 1.00);
                if this.m_sys.HasStaticFloorNear(dCand, this.m_valdesPos.Z, 0.55, 1.20) {
                    let zHit: Float = this.m_sys.FindFloorZInRange(dCand, this.m_valdesPos.Z, 0.55, 1.20);
                    let dCandAtHit: Vector4 = new Vector4(dCand.X, dCand.Y, zHit, 1.00);
                    if AbsF(zHit - this.m_valdesPos.Z) <= 0.40 && this.m_sys.IsSpotClearOfProps(dCandAtHit, 0.65) && this.m_sys.HasClearWalkPath(this.m_valdesPos, dCandAtHit) {
                        resolvedDesk = dCandAtHit;
                        deskFound = true;
                        break;
                    }
                }
                i += 1;
            }
        }
        if !deskFound {
            resolvedDesk = new Vector4(rawDesk.X, rawDesk.Y, this.m_valdesPos.Z, 1.00);
        }
        this.m_valdesDeskPos = resolvedDesk;
        this.m_valdesPosCached = true;
    }

    private final func EnsurePierCache() -> Void {
        if this.m_pierPosCached || !IsDefined(this.m_sys) {
            return;
        }
        let hits: Int32 = 0;
        let outPos: Vector4;

        if this.m_sys.ResolveClearPedestrianSpot(this.GetVaultTerminalRawPos(), 0.70, 0.80, outPos) {
            this.m_vaultPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetGatekeeperRawPos(), 0.85, 0.80, outPos) {
            this.m_gatePos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetUvWestRawPos(), 0.70, 0.80, outPos) {
            this.m_uvWestPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetUvEastRawPos(), 0.70, 0.80, outPos) {
            this.m_uvEastPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetCellARawPos(), 0.80, 0.80, outPos) {
            this.m_cellAPos = outPos;
            hits += 1;
        }
        if this.m_sys.ResolveClearPedestrianSpot(this.GetCellBRawPos(), 0.80, 0.80, outPos) {
            this.m_cellBPos = outPos;
            hits += 1;
        }

        if hits == 6 {
            this.m_pierPosCached = true;
        }
    }

    private final func EnsureKabukiScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage != 10 || !IsDefined(player) {
            return;
        }
        let distSq: Float = this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.GetKabukiCoolerRawPos());
        if !forceSpawn && distSq > 6400.00 {
            return;
        }
        this.EnsureKabukiCache();
        if !forceSpawn && !this.m_kabukiPosCached && distSq > 2500.00 {
            return;
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_coolerId) {
            this.m_coolerId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a1_cryo_cooler.ent", this.m_coolerPos, 172.00, n"CV_A1_Cooler");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_kShrineId) {
            this.m_kShrineId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a1_tarot_shrine.ent", this.m_kShrinePos, 165.00, n"CV_A1_Shrine");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_relayId) {
            this.m_relayId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a1_relay_pad.ent", this.m_relayPos, 155.00, n"CV_A1_Relay");
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let relayTaken: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_clue_relay") > 0;
        this.m_sys.SyncKabukiRelayVisual(this.m_relayId, relayTaken);

        if !this.m_kabukiIntroPlayed && this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.m_coolerPos) <= 900.00 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.m_kabukiIntroPlayed = true;
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_kabuki_arrive", n"v_narr", n"V", scnDialogLineType.Regular, 10.36));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    private final func EnsureValdesScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage < 20 || stage >= 50 || !IsDefined(player) {
            return;
        }
        let distSq: Float = this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.GetValdesNpcRawPos());
        if !forceSpawn && distSq > 8100.00 {
            return;
        }
        this.EnsureValdesCache();
        if !this.m_valdesPosCached {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if EntityID.IsDefined(this.m_valdesId) && IsDefined(des) && des.IsSpawned(this.m_valdesId) {
            let existingValdes: ref<NPCPuppet> = des.GetEntity(this.m_valdesId) as NPCPuppet;
            if IsDefined(existingValdes) && this.m_sys.ComputeDistanceSq(existingValdes.GetWorldPosition(), this.m_valdesPos) > 9.00 {
                this.m_sys.DespawnStaticPropById(this.m_valdesDeskId);
                this.m_valdesDeskId = new EntityID();
                des.DeleteTagged(n"CV_ValdesNPC");
                des.DeleteTagged(n"CV_WS_Valdes");
                this.m_valdesId = new EntityID();
                this.m_valdesWsAnchorId = new EntityID();
            }
        }
        let deskYaw: Float = this.ComputeFacingYaw(this.m_valdesDeskPos, this.GetValdesPlayerRefPos());
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_valdesDeskId) {
            this.m_valdesDeskId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a1_valdes_desk.ent", this.m_valdesDeskPos, deskYaw, n"CV_A1_ValdesDesk");
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let cipherTaken: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_has_cipher") > 0;
        this.m_sys.SyncValdesDeskCipherVisual(this.m_valdesDeskId, cipherTaken);

        let valdesYaw: Float = this.ComputeFacingYaw(this.m_valdesPos, this.GetValdesPlayerRefPos());
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_valdesId) {
            this.m_valdesId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_DrValdes", this.m_valdesPos, valdesYaw, n"CV_ValdesNPC", n"default");
        }
        this.m_sys.EnsureNpcImmortal(this.m_valdesId);
        if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_valdesWsAnchorId) {
            this.m_valdesWsAnchorId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_valdes.ent", this.m_valdesPos, valdesYaw, n"CV_WS_Valdes");
        }
        this.m_sys.EnsureValdesWorkspotAndLook(this.m_valdesId, this.m_valdesWsAnchorId, player);
    }

    private final func EnsurePierScene(player: ref<PlayerPuppet>, stage: Int32, opt forceSpawn: Bool) -> Void {
        if stage < 30 || stage > 40 || !IsDefined(player) {
            return;
        }
        let pPos: Vector4 = player.GetWorldPosition();
        let distSq: Float = this.m_sys.ComputeDistanceSq(pPos, this.GetPierArrivalPos());
        if !forceSpawn && distSq > 8100.00 {
            return;
        }
        this.EnsurePierCache();
        if !this.m_pierPosCached {
            return;
        }

        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_uvWestId) {
            let yawW: Float = this.ComputeFacingYaw(this.m_uvWestPos, this.GetPierArrivalPos());
            this.m_uvWestId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_uvWestPos, yawW, n"CV_A1_UvWest");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_uvEastId) {
            let yawE: Float = this.ComputeFacingYaw(this.m_uvEastPos, this.GetPierArrivalPos());
            this.m_uvEastId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_uv_emitter.ent", this.m_uvEastPos, yawE, n"CV_A1_UvEast");
        }
        if !this.m_sys.IsStaticPropAliveOrSpawning(this.m_vaultTermId) {
            let yawT: Float = this.ComputeFacingYaw(this.m_vaultPos, this.m_gatePos);
            this.m_vaultTermId = this.m_sys.SpawnStaticProp(r"crimson_veil\\entities\\cv_a1_cryo_vault_terminal.ent", this.m_vaultPos, yawT, n"CV_A1_VaultTerm");
        }

        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let isDay: Bool = this.m_sys.IsDaytimeNow();

        if stage == 30 && IsDefined(this.m_sys.m_vampyreCombat) {
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let flashOn: Bool = this.m_sys.m_vampyreCombat.IsUvFlashActive(nowSim);
            this.m_sys.SyncUvEmitterVisual(this.m_uvWestId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim));
            this.m_sys.SyncUvEmitterVisual(this.m_uvEastId, flashOn, !this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(2, nowSim));
        }

        if stage != 30 {
            return;
        }

        let cleared: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_pier_cleared") > 0;
        let inCombat: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_pier_combat") > 0;
        let gYaw: Float = this.ComputeFacingYaw(this.m_gatePos, this.GetPierArrivalPos());
        let caYaw: Float = this.ComputeFacingYaw(this.m_cellAPos, this.GetPierArrivalPos());
        let cbYaw: Float = this.ComputeFacingYaw(this.m_cellBPos, this.GetPierArrivalPos());
        if !cleared {
            if !this.m_gateSpawned && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_gatekeeperId) {
                this.m_gatekeeperId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_Gatekeeper", this.m_gatePos, gYaw, n"CV_A1_Gatekeeper");
                this.m_pierSpawnTime = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            }
            if !inCombat {
                if !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_gatekeeperWsId) {
                    this.m_gatekeeperWsId = this.m_sys.SpawnWorkspotAnchor(r"crimson_veil\\entities\\cv_ws_valdes.ent", this.m_gatePos, gYaw, n"CV_WS_Gatekeeper");
                }
                this.m_sys.EnsureGatekeeperWorkspotAndLook(this.m_gatekeeperId, this.m_gatekeeperWsId, player);
            }
            if !this.m_cellASpawned && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_cellAId) {
                let caPos: Vector4 = this.m_cellAPos;
                caPos.Z += 0.10;
                this.m_cellAId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_VampyreCellA", caPos, caYaw, n"CV_A1_CellA");
            }
            if !isDay && !this.m_cellBSpawned && !this.m_sys.IsDynamicNpcAliveOrSpawning(this.m_cellBId) {
                let cbPos: Vector4 = this.m_cellBPos;
                cbPos.Z += 0.10;
                this.m_cellBId = this.m_sys.SpawnDynamicNpc(t"Character.CrimsonVeil_VampyreCellB", cbPos, cbYaw, n"CV_A1_CellB");
            }
            if !inCombat {
                this.m_sys.EnsurePassiveGuardAtPost(this.m_cellAId, this.m_cellAPos, caYaw);
                this.m_sys.EnsurePassiveGuardAtPost(this.m_cellBId, this.m_cellBPos, cbYaw);
            }
        }

        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) {
            if EntityID.IsDefined(this.m_gatekeeperId) && des.IsSpawned(this.m_gatekeeperId) {
                this.m_gateSpawned = true;
            }
            if EntityID.IsDefined(this.m_cellAId) && des.IsSpawned(this.m_cellAId) {
                this.m_cellASpawned = true;
            }
            if EntityID.IsDefined(this.m_cellBId) && des.IsSpawned(this.m_cellBId) {
                this.m_cellBSpawned = true;
            }
        }

        if isDay && !this.m_pierDayPenaltyApplied && this.m_gateSpawned && this.m_cellASpawned {
            this.ApplyDaylightPenalty();
        }

        if !this.m_pierArrivalPlayed && this.m_sys.ComputeDistanceSq(pPos, this.GetPierArrivalPos()) <= 900.00 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.m_pierArrivalPlayed = true;
            if isDay {
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_daylight", "[LUZ DIURNA] La luz solar debilita al Coro Pálido y bloquea su regeneración");
            }
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_v_pier_arrive", n"v_narr", n"V", scnDialogLineType.Regular, 7.73));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    private final func ApplyDaylightPenalty() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
        if !IsDefined(des) || !IsDefined(sps) {
            return;
        }
        this.m_pierDayPenaltyApplied = true;
        let ids: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
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

    private final func SetPierSquadFriendly(player: ref<PlayerPuppet>) -> Void {
        if this.m_pierStealthFriendlyApplied || !IsDefined(player) {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) {
            return;
        }
        let pAtt: ref<AttitudeAgent> = player.GetAttitudeAgent();
        if !IsDefined(pAtt) {
            return;
        }
        let ids: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
        for eid in ids {
            if EntityID.IsDefined(eid) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) && !npc.IsDead() {
                    let att: ref<AttitudeAgent> = npc.GetAttitudeAgent();
                    if IsDefined(att) {
                        att.SetAttitudeTowards(pAtt, EAIAttitude.AIA_Friendly);
                    }
                }
            }
        }
        this.m_pierStealthFriendlyApplied = true;
    }

    private final func EnsurePierSquadHostile(player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(player) {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) {
            return;
        }
        let ids: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
        for eid in ids {
            if EntityID.IsDefined(eid) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) && !npc.IsDead() && !ScriptedPuppet.IsDefeated(npc) && !ScriptedPuppet.IsUnconscious(npc) && !NPCPuppet.IsInCombat(npc) {
                    this.m_sys.MakeNpcHostile(npc, player);
                }
            }
        }
    }

    private final func CheckPierProvocation(player: ref<PlayerPuppet>) -> Bool {
        if !IsDefined(player) {
            return false;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(game);
        if !IsDefined(des) || !IsDefined(sps) {
            return false;
        }
        let ids: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
        for eid in ids {
            if EntityID.IsDefined(eid) && des.IsSpawned(eid) {
                let npc: ref<NPCPuppet> = des.GetEntity(eid) as NPCPuppet;
                if IsDefined(npc) {
                    if npc.IsDead() || ScriptedPuppet.IsDefeated(npc) || ScriptedPuppet.IsUnconscious(npc) || NPCPuppet.IsInCombat(npc) {
                        return true;
                    }
                    let hp: Float = sps.GetStatPoolValue(Cast<StatsObjectID>(eid), gamedataStatPoolType.Health, true);
                    if !this.m_pierDayPenaltyApplied && hp < 97.50 {
                        return true;
                    }
                    if this.m_pierDayPenaltyApplied && hp < 77.50 {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private final func TriggerPierCombat(player: ref<PlayerPuppet>, quietTrigger: Bool) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            qs.SetFact(n"cv_a1_pier_combat", 1);
            qs.SetFact(n"cv_a1_infiltrated", 0);
        }
        this.m_pierSpawnTime = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        if IsDefined(this.m_sys.m_vampyreCombat) {
            this.m_sys.m_vampyreCombat.ResetCombatTimers();
        }
        this.EnsurePierSquadHostile(player);
        this.SyncActiveStageMappin(player, 30);
        this.m_sys.ShowRelicBanner(n"cv_banner_a1_pier_combat", "[CÉLULA EN ALERTA] ¡Usa las dos torres UV del muelle para frenar su regeneración!");
        if !quietTrigger && !this.m_sys.m_isPlayingDialogueSequence {
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_gate_hostile", n"gatekeeper", n"Centinela del Coro Pálido", scnDialogLineType.Regular, 4.85));
            this.m_sys.StartSpeechSequence(steps, 0);
        }
    }

    private final func CheckKabukiCluesAdvanced() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if !IsDefined(qs) || qs.GetFact(n"cv_a1_state") != 10 {
            return;
        }
        if qs.GetFact(n"cv_a1_clue_blood") > 0 && qs.GetFact(n"cv_a1_clue_tarot") > 0 && qs.GetFact(n"cv_a1_clue_relay") > 0 {
            qs.SetFact(n"cv_a1_state", 20);
            this.SyncStageJournalAndPin(20, true);
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a1_clues_done", "[RASTRO TRIANGULADO] El relé señala al Dr. Adrián Valdés en el Callejón Oculto (Little China)");
            this.m_sys.RequestDelayedCheckpoint(1.20);
        }
    }

    // --- Cuadros de Diálogo Acto I ---
    // Convención Cyberpunk 2077 (CP77-EP-055): false = AZUL (preguntas arriba), true = AMARILLO (avance abajo)

    public final func OpenValdesDialogHub() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let askedRole: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_asked_role") > 0;
        let askedSect: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_asked_sect") > 0;
        let askedLeads: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_asked_leads") > 0;
        let hasCipher: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_has_cipher") > 0;
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a1_state") : 20;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        if !askedRole {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_ask_role", "¿Cuál es tu papel en el Proyecto NOX-9? ¿Por qué lleva tu firma?"), false, false));
            ArrayPush(optionIds, 11);
        }
        if !askedSect {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_ask_sect", "¿Quién es La Cantora y qué relación tienes tú con El Coro Pálido?"), false, false));
            ArrayPush(optionIds, 12);
        }
        if !askedLeads {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_ask_leads", "¿Adónde llevaron a Lucía Reyes y a Mateo desde Northside?"), false, false));
            ArrayPush(optionIds, 13);
        }

        if stage == 20 && !hasCipher {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_trust", "[Empatía] Aún puedes ayudar a sacarlos. Dame la clave y tus archivos."), true, false));
            ArrayPush(optionIds, 14);
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_pressure", "[Presión] Dame la clave del muelle y tus notas sobre Solís ahora mismo."), true, false));
            ArrayPush(optionIds, 15);
        }

        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_open_codex", "Abrir Códice de Arcanos"), false, false));
        ArrayPush(optionIds, 16);

        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_valdes_leave", "Me marcho por ahora."), false, false));
        ArrayPush(optionIds, 17);

        this.m_sys.PushDialogHub(n"cv_valdes_hub", this.m_sys.GetLoc(n"cv_hub_valdes_title", "Dr. Adrián Valdés — Callejón Oculto"), choices, optionIds);
    }

    public final func OpenGatekeeperDialogHub() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        let hasCipher: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_has_cipher") > 0;

        let choices: array<ListChoiceData>;
        let optionIds: array<Int32>;

        if hasCipher {
            ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_gate_bluff", "[Clave de Valdés] «La sombra bebe antes del alba.»"), true, false));
            ArrayPush(optionIds, 220);
        }
        ArrayPush(choices, this.m_sys.MakeDialogChoice(this.m_sys.GetLoc(n"cv_act_gate_fight", "Vuestra farsa termina esta noche."), !hasCipher, false));
        ArrayPush(optionIds, 221);

        this.m_sys.PushDialogHub(n"cv_a1_gate_hub", this.m_sys.GetLoc(n"cv_hub_gate_title", "Centinela del Coro Pálido — Muelle Oeste"), choices, optionIds);
    }

    public final func HandleDialogOption(ownerTag: CName, optionId: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;

        if Equals(ownerTag, n"cv_valdes_hub") {
            if optionId == 11 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_asked_role", 1);
                }
                this.m_sys.SyncCodexJournalShards();
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_ask_role", n"v_narr", n"V", scnDialogLineType.Regular, 6.94));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_ans_role", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 25.01));
                this.m_sys.StartSpeechSequence(steps, 103);
                return true;
            }
            if optionId == 12 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_asked_sect", 1);
                }
                this.m_sys.SyncCodexJournalShards();
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_ask_sect", n"v_narr", n"V", scnDialogLineType.Regular, 5.71));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_ans_sect", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 28.93));
                this.m_sys.StartSpeechSequence(steps, 103);
                return true;
            }
            if optionId == 13 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_asked_leads", 1);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_ask_leads", n"v_narr", n"V", scnDialogLineType.Regular, 6.20));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_ans_leads", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 19.23));
                this.m_sys.StartSpeechSequence(steps, 103);
                return true;
            }
            if optionId == 14 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_valdes_trust", 1);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_trust", n"v_narr", n"V", scnDialogLineType.Regular, 9.24));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_give_trust", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 15.80));
                this.m_sys.StartSpeechSequence(steps, 104);
                return true;
            }
            if optionId == 15 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_valdes_trust", 2);
                }
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_pressure", n"v_narr", n"V", scnDialogLineType.Regular, 7.89));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_give_pressure", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 14.75));
                this.m_sys.StartSpeechSequence(steps, 104);
                return true;
            }
            if optionId == 16 {
                this.m_sys.OpenTarotSpreadPopup(false);
                return true;
            }
            if optionId == 17 {
                return true;
            }
            return false;
        }

        if Equals(ownerTag, n"cv_a1_gate_hub") {
            if optionId == 220 {
                if IsDefined(qs) {
                    qs.SetFact(n"cv_a1_infiltrated", 1);
                }
                this.SetPierSquadFriendly(player);
                this.SyncActiveStageMappin(player, 30);
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_stealth_ok", "[INFILTRACIÓN LIMPIA] Centinela convencido — Accede al terminal criogénico del fondo");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_v_gate_bluff", n"v_narr", n"V", scnDialogLineType.Regular, 6.19));
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_gate_bluff_ok", n"gatekeeper", n"Centinela del Coro Pálido", scnDialogLineType.Regular, 7.28));
                this.m_sys.StartSpeechSequence(steps, 0);
                return true;
            }
            if optionId == 221 {
                this.TriggerPierCombat(player, false);
                return true;
            }
        }

        return false;
    }

    public final func CompleteAct1DebriefOnRooftop() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let stealthClear: Bool = IsDefined(qs) && qs.GetFact(n"cv_a1_infiltrated") > 0 && qs.GetFact(n"cv_a1_pier_combat") == 0;

        let steps: array<ref<CrimsonVeilSpeechStep>>;
        if stealthClear {
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_m1_stealth", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.53));
        } else {
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_m1_combat", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.51));
        }
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_v1", n"v_narr", n"V", scnDialogLineType.Regular, 21.24));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_m2", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 17.48));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_v2", n"v_narr", n"V", scnDialogLineType.Regular, 20.98));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_m3", n"misty", n"Misty Olszewski", scnDialogLineType.Regular, 24.68));
        ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_debrief_v3", n"v_narr", n"V", scnDialogLineType.Regular, 9.40));
        this.m_sys.StartSpeechSequence(steps, 108);
    }

    private final func FinalizeAct1Rewards() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);

        if IsDefined(qs) && qs.GetFact(n"cv_a1_done") == 0 {
            qs.SetFact(n"cv_a1_done", 1);
            qs.SetFact(n"cv_a1_state", 50);
            qs.SetFact(n"cv_a2_ready", 1);
            if IsDefined(ts) && IsDefined(player) {
                ts.GiveItem(player, ItemID.FromTDBID(t"Items.money"), 2500);
            }
            this.m_sys.GrantExperience(900);
            this.m_sys.ClearJournalPinsAndResetSync(this.GetAllAct1PinPaths());
            if IsDefined(jm) {
                let p: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
                jm.ChangeEntryState(p + "/04_a1_return_misty", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState(p + "/desc_a1_done", "gameJournalQuestDescription", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
                jm.ChangeEntryState("quests/side_quest/crimson_veil_a1_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.Notify);
            }
            this.m_sys.ClearMappin();
            this.m_sys.SyncCodexJournalShards();
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a1_complete", "[ACTO I COMPLETADO] +2.500 €$, +900 XP — Próximo capítulo: Búnker en las Badlands y NOX-9B");
            this.m_sys.RequestDelayedCheckpoint(2.80);
        }
    }

    public final func OnPostSpeech(actionId: Int32) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;

        if actionId == 101 {
            this.m_sys.EndMistyIntroCall();
            if IsDefined(qs) && qs.GetFact(n"cv_a1_state") < 10 {
                qs.SetFact(n"cv_a1_state", 10);
            }
            this.m_sys.ActivateMistyAct1CallRecapSms();
            this.SyncStageJournalAndPin(10, true);
            this.m_sys.PlaySfx(n"cv_sfx_night_chime");
            this.m_sys.ShowRelicBanner(n"cv_banner_a1_start", "[ACTO I · PULSO DEL NOX-9] Telemetría del lote NOX-9-K4 en el Muelle Sur de Kabuki");
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 102 {
            this.CheckKabukiCluesAdvanced();
            return;
        }
        if actionId == 103 {
            this.EnsureValdesCache();
            if IsDefined(player) && this.m_sys.ComputeDistanceSq(player.GetWorldPosition(), this.m_valdesPos) <= 81.00 {
                this.OpenValdesDialogHub();
            }
            return;
        }
        if actionId == 104 {
            if IsDefined(qs) {
                qs.SetFact(n"cv_a1_has_cipher", 1);
                if qs.GetFact(n"cv_a1_state") < 30 {
                    qs.SetFact(n"cv_a1_state", 30);
                }
            }
            this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
            this.m_sys.SyncValdesDeskCipherVisual(this.m_valdesDeskId, true);
            this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_ChorusCipher", 1, 0.25);
            this.SyncStageJournalAndPin(30, true);
            this.m_sys.ShowRelicBanner(n"cv_banner_a1_valdes_done", "[PISTAS RECOGIDAS] Clave «La sombra bebe antes del alba», Northside Docks y dossier NOX-9B en el Códice");
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_depart", n"v_narr", n"V", scnDialogLineType.Regular, 14.00));
            this.m_sys.StartSpeechSequence(steps, 105);
            return;
        }
        if actionId == 105 {
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 106 {
            this.OpenGatekeeperDialogHub();
            return;
        }
        if actionId == 107 {
            this.m_sys.RequestDelayedCheckpoint(1.20);
            return;
        }
        if actionId == 108 {
            this.FinalizeAct1Rewards();
            return;
        }
    }

    public final func HandleInteraction(kind: Int32) -> Bool {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let stage: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_a1_state") : 10;

        if kind == 101 {
            if IsDefined(qs) && qs.GetFact(n"cv_a1_clue_blood") == 0 {
                qs.SetFact(n"cv_a1_clue_blood", 1);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_clue_1", "[PISTA 1/3] Matraces NOX-9-K4 para Sujeto L-14 (Lucía) y M-09 (Mateo)");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_clue_cooler", n"v_narr", n"V", scnDialogLineType.Regular, 19.22));
                this.m_sys.StartSpeechSequence(steps, 102);
            }
            return true;
        }
        if kind == 102 {
            if IsDefined(qs) && qs.GetFact(n"cv_a1_clue_tarot") == 0 {
                qs.SetFact(n"cv_a1_clue_tarot", 1);
                this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_clue_2", "[PISTA 2/3] La Sacerdotisa invertida — Amenaza del Coro al Dr. Adrián Valdés");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_clue_tarot", n"v_narr", n"V", scnDialogLineType.Regular, 16.36));
                this.m_sys.StartSpeechSequence(steps, 102);
            }
            return true;
        }
        if kind == 103 {
            if IsDefined(qs) && qs.GetFact(n"cv_a1_clue_relay") == 0 {
                qs.SetFact(n"cv_a1_clue_relay", 1);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.SyncKabukiRelayVisual(this.m_relayId, true);
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_clue_3", "[PISTA 3/3] Relé triangular fijado en el Callejón Oculto de Little China");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_clue_relay", n"v_narr", n"V", scnDialogLineType.Regular, 12.36));
                this.m_sys.StartSpeechSequence(steps, 102);
            }
            return true;
        }
        if kind == 104 {
            if stage >= 20 && stage < 50 {
                if IsDefined(qs) && qs.GetFact(n"cv_a1_valdes_met") == 0 {
                    qs.SetFact(n"cv_a1_valdes_met", 1);
                    let steps: array<ref<CrimsonVeilSpeechStep>>;
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_valdes_intro", n"valdes", n"Dr. Adrián Valdés", scnDialogLineType.Regular, 5.25));
                    ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_r2_v_intro", n"v_narr", n"V", scnDialogLineType.Regular, 12.20));
                    this.m_sys.StartSpeechSequence(steps, 103);
                } else {
                    this.OpenValdesDialogHub();
                }
            }
            return true;
        }
        if kind == 105 {
            let steps: array<ref<CrimsonVeilSpeechStep>>;
            ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_gate_challenge", n"gatekeeper", n"Centinela del Coro Pálido", scnDialogLineType.Regular, 7.14));
            this.m_sys.StartSpeechSequence(steps, 106);
            return true;
        }
        if kind == 106 || kind == 107 {
            this.EnsurePierCache();
            let slot: Int32 = (kind == 106) ? 1 : 2;
            let pos: Vector4 = (slot == 1) ? this.m_uvWestPos : this.m_uvEastPos;
            let squad: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvOverloadSquad(player, pos, squad, slot);
                this.m_sys.SyncUvEmitterVisual((slot == 1) ? this.m_uvWestId : this.m_uvEastId, true, false);
            }
            if !IsDefined(qs) || qs.GetFact(n"cv_a1_pier_combat") == 0 {
                this.TriggerPierCombat(player, true);
            } else {
                this.EnsurePierSquadHostile(player);
            }
            return true;
        }
        if kind == 108 {
            if IsDefined(qs) && stage == 30 {
                qs.SetFact(n"cv_a1_manifest_taken", 1);
                qs.SetFact(n"cv_a1_state", 40);
                this.m_sys.PlaySfx(n"cv_sfx_forensic_scan");
                this.m_sys.GiveItemDelayed(t"Items.CrimsonVeil_Nox9Manifest", 1, 0.30);
                this.SyncStageJournalAndPin(40, true);
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_manifest_taken", "[MANIFIESTO NOX-9] La tienda de Misty es un objetivo — Regresa a su azotea");
                let steps: array<ref<CrimsonVeilSpeechStep>>;
                ArrayPush(steps, this.m_sys.MakeSpeechStep(n"cv_a1_v_manifest_taken", n"v_narr", n"V", scnDialogLineType.Regular, 8.36));
                this.m_sys.StartSpeechSequence(steps, 107);
            }
            return true;
        }
        if kind == 109 {
            if IsDefined(this.m_sys.m_vampyreCombat) {
                this.m_sys.m_vampyreCombat.TriggerUvDiagnosticPulse(player);
            }
            return true;
        }
        if kind == 110 || kind == 112 {
            let slot: Int32 = (kind == 110) ? 1 : 2;
            if IsDefined(this.m_sys.m_vampyreCombat) {
                let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
                let remSec: Int32 = this.m_sys.m_vampyreCombat.GetUvTowerCooldownSeconds(slot, nowSim);
                let msg: String = this.m_sys.GetLoc(n"cv_banner_uv_cooling_pre", "[EMISOR UV] Condensador recargando — listo en ") + IntToString(remSec) + " s";
                this.m_sys.ShowRelicBannerText(msg);
            }
            return true;
        }
        if kind == 111 {
            if IsDefined(qs) && qs.GetFact(n"cv_a1_pier_combat") > 0 {
                this.EnsurePierSquadHostile(player);
            }
            this.m_sys.ShowRelicBanner(n"cv_banner_a1_vault_locked", "[TERMINAL SELLADO] Engaña al centinela con la clave o neutraliza primero a la célula");
            return true;
        }
        return false;
    }

    // --- Botones CET Acto I ---

    public final func DebugTriggerAct1Call() -> Void {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_sys.GetGameInstance());
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_state", 5);
        }
        this.m_callAttempted = true;
        this.m_sys.StartMistyAct1Call();
    }

    public final func DebugGoToKabuki() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_state", 10);
            qs.SetFact(n"cv_a1_clue_blood", 0);
            qs.SetFact(n"cv_a1_clue_tarot", 0);
            qs.SetFact(n"cv_a1_clue_relay", 0);
        }
        this.m_kabukiIntroPlayed = false;
        this.SyncStageJournalAndPin(10, true);
        let arr: Vector4 = this.GetKabukiArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        let yaw: Float = this.ComputeFacingYaw(arr, this.GetKabukiShrineRawPos());
        this.m_sys.TeleportPlayerSmooth(arr, yaw);
        if IsDefined(player) {
            this.EnsureKabukiScene(player, 10, true);
        }
    }

    public final func DebugGoToValdes() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        this.m_sys.SetNightTime2200();
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_clue_blood", 1);
            qs.SetFact(n"cv_a1_clue_tarot", 1);
            qs.SetFact(n"cv_a1_clue_relay", 1);
            qs.SetFact(n"cv_a1_state", 20);
            qs.SetFact(n"cv_a1_valdes_met", 0);
            qs.SetFact(n"cv_a1_asked_role", 0);
            qs.SetFact(n"cv_a1_asked_sect", 0);
            qs.SetFact(n"cv_a1_asked_leads", 0);
            qs.SetFact(n"cv_a1_valdes_trust", 0);
            qs.SetFact(n"cv_a1_has_cipher", 0);
        }
        this.m_valdesPosCached = false;
        this.SyncStageJournalAndPin(20, true);
        this.m_sys.ResetValdesWorkspotRetryState();
        let arr: Vector4 = this.GetValdesArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        let yaw: Float = this.ComputeFacingYaw(arr, this.GetValdesNpcRawPos());
        this.m_sys.TeleportPlayerSmooth(arr, yaw);
    }

    public final func DebugGoToPier(isNight: Bool) -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if isNight {
            this.m_sys.SetNightTime2200();
        } else {
            GameInstance.GetTimeSystem(game).SetGameTimeByHMS(13, 0, 0, n"CrimsonVeil");
        }
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_clue_blood", 1);
            qs.SetFact(n"cv_a1_clue_tarot", 1);
            qs.SetFact(n"cv_a1_clue_relay", 1);
            qs.SetFact(n"cv_a1_has_cipher", 1);
            qs.SetFact(n"cv_a1_infiltrated", 0);
            qs.SetFact(n"cv_a1_pier_combat", 0);
            qs.SetFact(n"cv_a1_pier_cleared", 0);
            qs.SetFact(n"cv_a1_manifest_taken", 0);
            qs.SetFact(n"cv_a1_done", 0);
            qs.SetFact(n"cv_a1_state", 30);
        }
        this.m_pierArrivalPlayed = false;
        this.m_pierClearBannerShown = false;
        this.m_pierStealthFriendlyApplied = false;
        this.m_pierDayPenaltyApplied = false;
        this.m_pierPosCached = false;
        this.m_sys.ResetGatekeeperWorkspotRetryState();
        this.SyncStageJournalAndPin(30, true);
        let arr: Vector4 = this.GetPierArrivalPos();
        arr.Z = this.m_sys.FindGroundZWide(arr) + 0.15;
        let yaw: Float = this.ComputeFacingYaw(arr, this.GetGatekeeperRawPos());
        this.m_sys.TeleportPlayerSmooth(arr, yaw);
    }

    public final func DebugGoToDebrief() -> Void {
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        this.m_sys.SetNightTime2200();
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_clue_blood", 1);
            qs.SetFact(n"cv_a1_clue_tarot", 1);
            qs.SetFact(n"cv_a1_clue_relay", 1);
            qs.SetFact(n"cv_a1_has_cipher", 1);
            qs.SetFact(n"cv_a1_infiltrated", 1);
            qs.SetFact(n"cv_a1_pier_combat", 0);
            qs.SetFact(n"cv_a1_pier_cleared", 1);
            qs.SetFact(n"cv_a1_manifest_taken", 1);
            qs.SetFact(n"cv_a1_done", 0);
            qs.SetFact(n"cv_a1_state", 40);
        }
        this.SyncStageJournalAndPin(40, true);
        let arr: Vector4 = new Vector4(-1548.80, 1208.15, 57.05, 1.00);
        let mistyPos: Vector4 = new Vector4(-1549.10, 1209.69, 57.00, 1.00);
        let yaw: Float = this.ComputeFacingYaw(arr, mistyPos);
        this.m_sys.TeleportPlayerSmooth(arr, yaw);
        this.m_sys.ShowRelicBanner(n"cv_banner_a1_debrief_ready", "[MANIFIESTO NOX-9] Habla con Misty en la azotea para cerrar el Acto I");
    }

    public final func DebugResetAct1() -> Void {
        this.CleanupEntities();
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            qs.SetFact(n"cv_r2_done", 1);
            qs.SetFact(n"cv_r2_state", 60);
            qs.SetFact(n"cv_a1_state", 0);
            qs.SetFact(n"cv_a1_clue_blood", 0);
            qs.SetFact(n"cv_a1_clue_tarot", 0);
            qs.SetFact(n"cv_a1_clue_relay", 0);
            qs.SetFact(n"cv_a1_valdes_met", 0);
            qs.SetFact(n"cv_a1_asked_role", 0);
            qs.SetFact(n"cv_a1_asked_sect", 0);
            qs.SetFact(n"cv_a1_asked_leads", 0);
            qs.SetFact(n"cv_a1_valdes_trust", 0);
            qs.SetFact(n"cv_a1_has_cipher", 0);
            qs.SetFact(n"cv_a1_infiltrated", 0);
            qs.SetFact(n"cv_a1_pier_combat", 0);
            qs.SetFact(n"cv_a1_pier_cleared", 0);
            qs.SetFact(n"cv_a1_manifest_taken", 0);
            qs.SetFact(n"cv_a1_done", 0);
            qs.SetFact(n"cv_a2_ready", 0);
        }
        this.m_sys.ClearJournalPinsAndResetSync(this.GetAllAct1PinPaths());
        this.m_sys.ClearMappin();
        this.DebugTriggerAct1Call();
    }

    // --- Bucle de Evaluación Acto I ---

    public final func Tick(player: ref<PlayerPuppet>, fullGameplay: Bool) -> Float {
        if !IsDefined(player) || !this.m_sys.IsGameplayReady(player) || !fullGameplay {
            return 0.45;
        }
        if !this.m_sys.HasReachedNightCityAct1(player) {
            return 1.00;
        }
        if this.m_sys.IsHoloRecordStudioActive() {
            return 0.50;
        }
        let game: GameInstance = this.m_sys.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if !IsDefined(qs) {
            return 0.70;
        }

        if qs.GetFact(n"cv_a2_state") > 0 {
            if qs.GetFact(n"cv_a1_done") == 0 || qs.GetFact(n"cv_a1_state") < 50 {
                qs.SetFact(n"cv_a1_done", 1);
                qs.SetFact(n"cv_a1_state", 50);
                this.m_sys.ClearJournalPinsAndResetSync(this.GetAllAct1PinPaths());
                let jmClose: ref<JournalManager> = GameInstance.GetJournalManager(game);
                if IsDefined(jmClose) {
                    let pClose: String = "quests/side_quest/crimson_veil_a1_quest/phase_a1";
                    jmClose.ChangeEntryState(pClose + "/01_a1_kabuki_trace", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/02_a1_valdes_hideout", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/03_a1_waterfront_cryo", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState(pClose + "/04_a1_return_misty", "gameJournalQuestObjective", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                    jmClose.ChangeEntryState("quests/side_quest/crimson_veil_a1_quest", "gameJournalQuest", gameJournalEntryState.Succeeded, JournalNotifyOption.DoNotNotify);
                }
                this.m_lastSyncedStage = 50;
            }
            return 0.70;
        }

        let r2Done: Int32 = qs.GetFact(n"cv_r2_done");
        if r2Done == 0 {
            return 0.70;
        }

        let stage: Int32 = qs.GetFact(n"cv_a1_state");
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
                qs.SetFact(n"cv_a1_state", 5);
                this.m_sys.StartMistyAct1Call();
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
                    this.m_sys.StartMistyAct1Call();
                }
            }
            return 0.45;
        }

        if stage == 10 && !this.m_sys.m_isPlayingDialogueSequence && !this.m_sys.IsDialogActive() {
            this.CheckKabukiCluesAdvanced();
            stage = qs.GetFact(n"cv_a1_state");
        }
        if this.m_lastSyncedStage != stage {
            this.SyncStageJournalAndPin(stage, false);
        }

        this.EnsureKabukiScene(player, stage);
        this.EnsureValdesScene(player, stage);
        this.EnsurePierScene(player, stage);
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

        // 1. Muelle Sur de Kabuki (3 pistas forenses en el paseo peatonal)
        if stage == 10 && this.m_sys.ComputeDistanceSq(pPos, this.GetKabukiCoolerRawPos()) <= 2500.00 {
            this.EnsureKabukiCache();
            let bestKind: Int32 = 0;
            let bestDistSq: Float = 5.76;
            if qs.GetFact(n"cv_a1_clue_blood") == 0 && AbsF(pPos.Z - this.m_coolerPos.Z) < 2.20 {
                let d1: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_coolerPos);
                if d1 <= bestDistSq {
                    bestDistSq = d1;
                    bestKind = 101;
                }
            }
            if qs.GetFact(n"cv_a1_clue_tarot") == 0 && AbsF(pPos.Z - this.m_kShrinePos.Z) < 2.20 {
                let d2: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_kShrinePos);
                if d2 <= bestDistSq {
                    bestDistSq = d2;
                    bestKind = 102;
                }
            }
            if qs.GetFact(n"cv_a1_clue_relay") == 0 && AbsF(pPos.Z - this.m_relayPos.Z) < 2.20 {
                let d3: Float = this.m_sys.ComputeDistanceSq(pPos, this.m_relayPos);
                if d3 <= bestDistSq {
                    bestDistSq = d3;
                    bestKind = 103;
                }
            }
            if bestKind == 101 {
                this.m_sys.ShowWorldInteraction(101, n"cv_hub_a1_cooler", "Refrigerador de Plasma Criogénico", n"cv_act_a1_inspect_cooler", "Examinar matraces de sangre criogénica", false, true);
                return 0.20;
            }
            if bestKind == 102 {
                this.m_sys.ShowWorldInteraction(102, n"cv_hub_a1_shrine", "Marca Ocultista de La Sacerdotisa", n"cv_act_a1_inspect_shrine", "Examinar La Sacerdotisa invertida", false, true);
                return 0.20;
            }
            if bestKind == 103 {
                this.m_sys.ShowWorldInteraction(103, n"cv_hub_a1_relay", "Relé de Telemetría Biotechnica", n"cv_act_a1_inspect_relay", "Descifrar señal del Med Center", false, true);
                return 0.20;
            }
        }

        // 2. Dr. Adrián Valdés en el Patio del Night City Med Center (Little China)
        if stage >= 20 && stage < 50 && this.m_sys.ComputeDistanceSq(pPos, this.GetValdesNpcRawPos()) <= 2500.00 {
            this.EnsureValdesCache();
            if this.m_sys.ComputeDistanceSq(pPos, this.m_valdesPos) <= 10.24 && AbsF(pPos.Z - this.m_valdesPos.Z) < 3.00 {
                this.m_sys.ShowWorldInteraction(104, n"cv_hub_valdes_title", "Dr. Adrián Valdés — Patio del Med Center", n"cv_act_talk_valdes", "Hablar con el Dr. Adrián Valdés", true);
                return 0.20;
            }
        }

        // 3. Muelle Oeste de Watson — Northside Docks (Centinela + Dos Torres UV + Terminal Criogénica)
        if stage == 30 && this.m_sys.ComputeDistanceSq(pPos, this.GetPierArrivalPos()) <= 6400.00 {
            this.EnsurePierCache();
            let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            let combatElapsed: Float = MaxF(0.10, nowSim - this.m_pierSpawnTime);
            let infiltrated: Bool = qs.GetFact(n"cv_a1_infiltrated") > 0;
            let inCombat: Bool = qs.GetFact(n"cv_a1_pier_combat") > 0;
            let clearedFact: Bool = qs.GetFact(n"cv_a1_pier_cleared") > 0;

            if !clearedFact && !inCombat && combatElapsed > 1.50 && this.CheckPierProvocation(player) {
                this.TriggerPierCombat(player, true);
                inCombat = true;
                infiltrated = false;
            }

            let isCleared: Bool = clearedFact
                || (inCombat
                    && this.m_sys.IsNpcNeutralized(this.m_gatekeeperId, this.m_gatePos, combatElapsed)
                    && this.m_sys.IsNpcNeutralized(this.m_cellAId, this.m_gatePos, combatElapsed)
                    && (!this.m_cellBSpawned || this.m_sys.IsNpcNeutralized(this.m_cellBId, this.m_gatePos, combatElapsed)));

            if isCleared && !clearedFact {
                qs.SetFact(n"cv_a1_pier_cleared", 1);
                clearedFact = true;
                this.SyncActiveStageMappin(player, 30);
            }

            if inCombat && !clearedFact {
                this.EnsurePierSquadHostile(player);
                if IsDefined(this.m_sys.m_vampyreCombat) {
                    let squad: array<EntityID> = [this.m_gatekeeperId, this.m_cellAId, this.m_cellBId];
                    this.m_sys.m_vampyreCombat.TickVampyreSquadRegen(player, this.m_gatePos, squad, this.m_sys.IsDaytimeNow());
                }
            } else if clearedFact && !this.m_pierClearBannerShown {
                this.m_pierClearBannerShown = true;
                this.m_sys.ShowRelicBanner(n"cv_banner_a1_manifest_ready", "[MUELLE DESPEJADO] Descarga el Manifiesto NOX-9 en el terminal del fondo");
            }

            if (infiltrated || clearedFact) && this.m_sys.ComputeDistanceSq(pPos, this.m_vaultPos) <= 12.25 && AbsF(pPos.Z - this.m_vaultPos.Z) < 3.50 {
                this.m_sys.ShowWorldInteraction(108, n"cv_hub_vault_title", "Terminal del Manifiesto NOX-9", n"cv_act_take_manifest", "Descargar Manifiesto NOX-9 de las Badlands", false, true);
                return 0.20;
            }

            if !infiltrated && !inCombat && !clearedFact {
                let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
                if EntityID.IsDefined(this.m_gatekeeperId) && IsDefined(des) && des.IsSpawned(this.m_gatekeeperId) {
                    let gNpc: ref<NPCPuppet> = des.GetEntity(this.m_gatekeeperId) as NPCPuppet;
                    if IsDefined(gNpc) && !gNpc.IsDead() && this.m_sys.ComputeDistanceSq(pPos, gNpc.GetWorldPosition()) <= 16.00 {
                        this.m_sys.ShowWorldInteraction(105, n"cv_hub_gate_title", "Centinela del Coro Pálido — Muelle Oeste", n"cv_act_talk_gate", "Hablar con el centinela del muelle", true, true);
                        return 0.20;
                    }
                }
            }

            if !clearedFact {
                if this.m_sys.ComputeDistanceSq(pPos, this.m_uvWestPos) <= 20.25 && AbsF(pPos.Z - this.m_uvWestPos.Z) < 4.00 {
                    if inCombat {
                        if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(1, nowSim) {
                            this.m_sys.ShowWorldInteraction(110, n"cv_hub_uv_west", "Torre UV Oeste (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                        } else {
                            this.m_sys.ShowWorldInteraction(106, n"cv_hub_uv_west", "Torre UV Oeste (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                        }
                    } else {
                        this.m_sys.ShowWorldInteraction(109, n"cv_hub_uv_west", "Torre UV Oeste (365 nm)", n"cv_act_uv_check", "Comprobar torre emisora UV", false, true);
                    }
                    return 0.20;
                }
                if this.m_sys.ComputeDistanceSq(pPos, this.m_uvEastPos) <= 20.25 && AbsF(pPos.Z - this.m_uvEastPos.Z) < 4.00 {
                    if inCombat {
                        if IsDefined(this.m_sys.m_vampyreCombat) && this.m_sys.m_vampyreCombat.IsUvTowerOnCooldown(2, nowSim) {
                            this.m_sys.ShowWorldInteraction(112, n"cv_hub_uv_east", "Torre UV Este (365 nm)", n"cv_act_uv_cooling", "Condensador UV recargando", false, true);
                        } else {
                            this.m_sys.ShowWorldInteraction(107, n"cv_hub_uv_east", "Torre UV Este (365 nm)", n"cv_act_uv_trigger", "Sobrecargar Emisor UV (Pulso 365 nm)", false, true);
                        }
                    } else {
                        this.m_sys.ShowWorldInteraction(109, n"cv_hub_uv_east", "Torre UV Este (365 nm)", n"cv_act_uv_check", "Comprobar torre emisora UV", false, true);
                    }
                    return 0.20;
                }
            }

            if !infiltrated && !clearedFact && this.m_sys.ComputeDistanceSq(pPos, this.m_vaultPos) <= 7.84 && AbsF(pPos.Z - this.m_vaultPos.Z) < 3.50 {
                this.m_sys.ShowWorldInteraction(111, n"cv_hub_vault_title", "Terminal del Manifiesto NOX-9", n"cv_act_shrine_combat_lock", "Terminal sellado", false, true);
                return 0.20;
            }
        }

        this.m_sys.HideWorldInteraction();
        return 0.35;
    }
}
