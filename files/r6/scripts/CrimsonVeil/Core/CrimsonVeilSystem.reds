// Velo Carmesí / Crimson Veil — Núcleo Modular Redscript (Juego Base 2.x, 0 ep1)
module CrimsonVeil

import Codeware.Localization.*
import Codeware.UI.*

// ---------------------------------------------------------------------------
// Estructuras de Eventos Diferidos y Datos de Marcador
// ---------------------------------------------------------------------------

public class CrimsonVeilMappinData extends MappinScriptData {}

public class CrimsonVeilTickCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnTick();
        }
    }
}

public class CrimsonVeilFlushDeferredCallsCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.FlushDeferredVanillaCalls();
        }
    }
}

public class CrimsonVeilSpeechStep {
    public let eventName: CName;
    public let speakerTag: CName;
    public let speakerName: CName;
    public let lineType: scnDialogLineType;
    public let fallbackDuration: Float;
}

public class CrimsonVeilSequenceCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;
    public let nextIndex: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.AdvanceSpeechSequence(this.token, this.nextIndex);
        }
    }
}

public class CrimsonVeilSpeechSubtitleCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;
    public let nextPageIndex: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.AdvanceSpeechSubtitlePage(this.token, this.nextPageIndex);
        }
    }
}

public class CrimsonVeilSpeechSubtitleReassertCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;
    public let expectedCruid: CRUID;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ReassertActiveSpeechSubtitleIfNeeded(this.token, this.expectedCruid);
        }
    }
}

public class CrimsonVeilDelayedItemCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let itemTdbId: TweakDBID;
    public let amount: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ExecuteDelayedItemGrant(this.itemTdbId, this.amount);
        }
    }
}

public class CrimsonVeilCheckpointCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ExecuteDelayedCheckpoint();
        }
    }
}

public class CrimsonVeilLipSyncCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnLipSyncTick(this.token);
        }
    }
}

public class CrimsonVeilBodyBeatCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;
    public let entryId: Int32;
    public let instant: Bool;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnBodyBeatTick(this.token, this.entryId, this.instant);
        }
    }
}

public class CrimsonVeilCardPlaceCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;
    public let cardSlot: Int32;
    public let isShowInHand: Bool;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnTarotCardPlaceTick(this.token, this.cardSlot, this.isShowInHand);
        }
    }
}

public class CrimsonVeilWorldMapTrackCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.OnDeferredWorldMapAutoTrack();
        }
    }
}

public class CrimsonVeilDelayedActionCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let actionId: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ExecuteDelayedPostAction(this.actionId);
        }
    }
}

public class CrimsonVeilCallAnswerCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let contactName: CName;
    public let callToken: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.AnswerIncomingCallInternal(this.contactName, this.callToken, false);
        }
    }
}

public class CrimsonVeilStudioLoopCallback extends DelayCallback {
    public let system: wref<CrimsonVeilSystem>;
    public let token: Int32;

    public func Call() -> Void {
        if IsDefined(this.system) {
            this.system.ExecuteHolocallRecordingLoop(this.token);
        }
    }
}

// ---------------------------------------------------------------------------
// Monitor de Sesión Real
// ---------------------------------------------------------------------------

public class CrimsonVeilSessionService extends ScriptableService {
    private let m_sessionReady: Bool;

    public static func IsSessionReady() -> Bool {
        let svc: ref<CrimsonVeilSessionService> = GameInstance.GetScriptableServiceContainer().GetService(n"CrimsonVeil.CrimsonVeilSessionService") as CrimsonVeilSessionService;
        return IsDefined(svc) && svc.m_sessionReady;
    }

    private cb func OnLoad() -> Void {
        this.m_sessionReady = false;
        let cbSys: ref<CallbackSystem> = GameInstance.GetCallbackSystem();
        cbSys.RegisterCallback(n"Session/BeforeStart", this, n"OnSessionEvent");
        cbSys.RegisterCallback(n"Session/Start", this, n"OnSessionEvent");
        cbSys.RegisterCallback(n"Session/Ready", this, n"OnSessionEvent");
        cbSys.RegisterCallback(n"Session/BeforeEnd", this, n"OnSessionEvent");
        cbSys.RegisterCallback(n"Session/End", this, n"OnSessionEvent");
    }

    private cb func OnSessionEvent(event: ref<GameSessionEvent>) -> Void {
        if event.IsPreGame() {
            this.m_sessionReady = false;
            return;
        }
        let name: CName = event.GetEventName();
        if Equals(name, n"Session/Ready") {
            this.m_sessionReady = true;
        } else if Equals(name, n"Session/BeforeStart") || Equals(name, n"Session/Start") || Equals(name, n"Session/BeforeEnd") || Equals(name, n"Session/End") {
            this.m_sessionReady = false;
        }
    }
}

// ---------------------------------------------------------------------------
// Sistema Central «Velo Carmesí / Crimson Veil»
// ---------------------------------------------------------------------------

public class CrimsonVeilSystem extends ScriptableSystem {
    public let m_tickScheduled: Bool;
    public let m_spawnGraceEnded: Bool;
    public let m_sessionReadyTicks: Int32;

    public let m_act00: ref<CrimsonVeilAct00Handler>;
    public let m_act01: ref<CrimsonVeilAct01Handler>;
    public let m_act02: ref<CrimsonVeilAct02Handler>;
    public let m_vampyreCombat: ref<VampyreCombatController>;

    // Holollamadas nativas en vídeo 3D en vivo (Misty)
    private let m_activeCallToken: Int32;
    private let m_activeCallScenario: Int32;
    private let m_activeCallContact: CName;
    private let m_activeCallPendingPickup: Bool;
    private let m_holoCallActive: Bool;
    private let m_phoneAvatarCtrl: wref<HudPhoneAvatarController>;
    private let m_mistyCallSpeaking: Bool;
    private let m_vanillaCallCooldownUntil: Float;
    private let m_deferredVanillaCalls: array<ref<questTriggerCallRequest>>;
    private let m_flushingDeferredCalls: Bool;

    // Diálogos nativos, interacción [F] y popup Tarot
    private let m_dialogWidgetCtrl: wref<dialogWidgetGameController>;
    private let m_dialogActive: Bool;
    private let m_dialogConfirmArmed: Bool;
    private let m_dialogHubSeqId: Int32;
    private let m_dialogSelectedIdx: Int32;
    private let m_dialogOptionCount: Int32;
    private let m_dialogOptionIds: array<Int32>;
    private let m_dialogOwnerTag: CName;
    private let m_cachedDialogHubs: DialogChoiceHubs;
    private let m_dialogOpenedAt: Float;
    private let m_lastDialogNavAt: Float;
    private let m_lastDialogReopenAt: Float;

    private let m_interactionShown: Bool;
    private let m_interactionKind: Int32;
    private let m_interactionGuardUntil: Float;
    private let m_isTarotPopupOpen: Bool;

    // Marcadores dinámicos, pines GPS cocinados y mapa mundial
    private let m_mappinId: NewMappinID;
    private let m_hasMappin: Bool;
    private let m_isRegisteringMappin: Bool;
    private let m_mappinStageTag: Int32;
    private let m_journalPinSyncedTag: Int32;
    private let m_journalPinRetryTicks: Int32;
    private let m_mappinTitle: String;
    private let m_mappinDesc: String;
    private let m_activeWorldMap: wref<WorldMapMenuGameController>;
    private let m_activeMapPinCtrl: wref<BaseWorldMapMappinController>;
    private let m_worldMapReady: Bool;

    // Orquestación de voz y subtítulos
    private let m_speechSteps: array<ref<CrimsonVeilSpeechStep>>;
    private let m_speechToken: Int32;
    private let m_speechActionOnComplete: Int32;
    private let m_pendingPostSpeechAction: Int32;
    public let m_isPlayingDialogueSequence: Bool;
    private let m_speechAllowManualSkip: Bool;
    private let m_currentSpeechIndex: Int32;
    private let m_speechStepStartedAt: Float;
    private let m_currentPlayingEvent: CName;
    private let m_currentPlayingEntity: EntityID;
    private let m_currentPlayingSpeaker: CName;
    private let m_currentPlayingBackend: Int32;
    private let m_currentPlayingVariant: CName;
    private let m_speechSkipBlockedUntil: Float;
    private let m_skipHintVisible: Bool;

    private let m_speechSubtitleSeq: Uint64;
    private let m_speechSubtitleToken: Int32;
    private let m_activeSpeechSubtitleCruid: CRUID;
    private let m_hasActiveSpeechSubtitle: Bool;
    private let m_speechSubtitlePages: array<String>;
    private let m_speechSubtitlePageDurs: array<Float>;
    private let m_speechSubtitleSpeakerObj: wref<GameObject>;
    private let m_speechSubtitleSpeakerName: String;
    private let m_speechSubtitleLineType: scnDialogLineType;
    private let m_uiMenuListener: ref<CallbackHandle>;
    private let m_pausedByUiMenu: Bool;
    private let m_speechSeqDelayId: DelayID;
    private let m_speechSeqRemaining: Float;
    private let m_speechSeqExpectedDur: Float;
    private let m_speechSeqScheduledSimAt: Float;
    private let m_speechSubDelayId: DelayID;
    private let m_speechSubCurrentPageIdx: Int32;
    private let m_speechSubRemaining: Float;
    private let m_speechSubExpectedDur: Float;
    private let m_speechSubScheduledSimAt: Float;

    // Lip-sync JALI 30 FPS, coreografía corporal y mirada conversacional (Misty y Dr. Valdés)
    private let m_lipSyncToken: Int32;
    private let m_lipSyncSlot: Int32;
    private let m_lipSyncActiveClip: Int32;
    private let m_lipSyncSpeakerTag: CName;
    private let m_bodyBeatToken: Int32;
    private let m_lipSyncEntityId: EntityID;
    private let m_lipSyncRemaining: Float;
    private let m_lipSyncStartedAt: Float;
    private let m_lipSyncStepIdx: Int32;
    private let m_lipSyncGestureIdx: Int32;
    private let m_lipSyncLastLevel: Int32;
    private let m_lipSyncEnvelope: String;
    private let m_lookAtMistyEvt: ref<LookAtAddEvent>;
    private let m_lookAtValdesEvt: ref<LookAtAddEvent>;
    private let m_lookAtLuciaEvt: ref<LookAtAddEvent>;
    private let m_lookAtSolisEvt: ref<LookAtAddEvent>;
    private let m_lookAtGateEvt: ref<LookAtAddEvent>;
    private let m_wsAttempts: Int32;
    private let m_wsLastTryAt: Float;
    private let m_valdesWsAttempts: Int32;
    private let m_valdesWsLastTryAt: Float;
    private let m_luciaWsAttempts: Int32;
    private let m_luciaWsLastTryAt: Float;
    private let m_solisWsAttempts: Int32;
    private let m_solisWsLastTryAt: Float;
    private let m_gateWsAttempts: Int32;
    private let m_gateWsLastTryAt: Float;
    private let m_roofReadingActive: Bool;
    private let m_mistyHoldingDeck: Bool;
    private let m_roofCardMoonDealt: Bool;
    private let m_roofCardHangmanDealt: Bool;
    private let m_roofCardTowerDealt: Bool;

    // Estudio de grabación de vídeo Holocall (.bk2) y ocultación limpia de retícula
    private let m_holoRecordStudioActive: Bool;
    private let m_holoRecordToken: Int32;
    private let m_holoRecordLightsId: EntityID;
    private let m_crosshairCtrl: wref<gameuiCrosshairContainerController>;
    private let m_persistentDotCtrl: wref<CrosshairGameControllerPersistentDot>;
    private let m_subBunkerEnvActive: Bool;

    public static func GetInstance(game: GameInstance) -> ref<CrimsonVeilSystem> {
        return GameInstance.GetScriptableSystemsContainer(game).Get(n"CrimsonVeil.CrimsonVeilSystem") as CrimsonVeilSystem;
    }

    private func OnAttach() -> Void {
        this.m_act00 = new CrimsonVeilAct00Handler();
        this.m_act00.Initialize(this);
        this.m_act01 = new CrimsonVeilAct01Handler();
        this.m_act01.Initialize(this);
        this.m_act02 = new CrimsonVeilAct02Handler();
        this.m_act02.Initialize(this);
        this.m_vampyreCombat = new VampyreCombatController();
        this.m_vampyreCombat.Initialize(this);
        this.m_activeCallToken = 0;
        this.m_activeCallScenario = 0;
        this.m_activeCallContact = n"None";
        this.m_activeCallPendingPickup = false;
        this.m_holoCallActive = false;
        this.m_phoneAvatarCtrl = null;
        this.m_mistyCallSpeaking = false;
        this.m_vanillaCallCooldownUntil = 0.00;
        ArrayClear(this.m_deferredVanillaCalls);
        this.m_flushingDeferredCalls = false;
        this.m_holoRecordStudioActive = false;
        this.m_holoRecordToken = 0;
        this.m_holoRecordLightsId = new EntityID();

        this.m_tickScheduled = false;
        this.m_spawnGraceEnded = false;
        this.m_sessionReadyTicks = 0;
        this.m_dialogWidgetCtrl = null;
        this.m_dialogActive = false;
        this.m_dialogConfirmArmed = false;
        this.m_dialogHubSeqId = -974110;
        ArrayClear(this.m_cachedDialogHubs.choiceHubs);
        this.m_interactionShown = false;
        this.m_interactionKind = 0;
        this.m_interactionGuardUntil = 0.00;
        this.m_isTarotPopupOpen = false;
        this.m_hasMappin = false;
        this.m_isRegisteringMappin = false;
        this.m_mappinStageTag = -1;
        this.m_journalPinSyncedTag = 0;
        this.m_journalPinRetryTicks = 0;
        this.m_worldMapReady = false;

        this.m_isPlayingDialogueSequence = false;
        this.m_speechAllowManualSkip = false;
        this.m_speechActionOnComplete = 0;
        this.m_pendingPostSpeechAction = 0;
        this.m_currentSpeechIndex = 0;
        this.m_speechStepStartedAt = 0.00;
        this.m_currentPlayingEvent = n"None";
        this.m_currentPlayingEntity = new EntityID();
        this.m_currentPlayingSpeaker = n"None";
        this.m_currentPlayingBackend = 0;
        this.m_currentPlayingVariant = n"None";
        this.m_speechSkipBlockedUntil = 0.00;
        this.m_skipHintVisible = false;
        this.m_speechSubtitleSeq = 0ul;
        this.m_speechSubtitleToken = 0;
        this.m_hasActiveSpeechSubtitle = false;
        ArrayClear(this.m_speechSubtitlePages);
        ArrayClear(this.m_speechSubtitlePageDurs);
        this.m_speechSeqDelayId = GetInvalidDelayID();
        this.m_speechSubDelayId = GetInvalidDelayID();
        this.m_speechSubCurrentPageIdx = -1;
        this.m_lipSyncToken = 0;
        this.m_lipSyncSlot = 0;
        this.m_lipSyncActiveClip = 0;
        this.m_lipSyncSpeakerTag = n"None";
        this.m_bodyBeatToken = 0;
        this.m_lipSyncRemaining = 0.00;
        this.m_lipSyncStartedAt = 0.00;
        this.m_lipSyncStepIdx = 0;
        this.m_lipSyncGestureIdx = 0;
        this.m_lipSyncLastLevel = -1;
        this.m_lipSyncEnvelope = "";
        this.m_wsAttempts = 0;
        this.m_wsLastTryAt = -10.00;
        this.m_valdesWsAttempts = 0;
        this.m_valdesWsLastTryAt = -10.00;
        this.m_gateWsAttempts = 0;
        this.m_gateWsLastTryAt = -10.00;
        this.m_roofReadingActive = false;
        this.m_mistyHoldingDeck = false;
        this.m_roofCardMoonDealt = false;
        this.m_roofCardHangmanDealt = false;
        this.m_roofCardTowerDealt = false;
        this.m_subBunkerEnvActive = false;

        let uiSysBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_System);
        if IsDefined(uiSysBB) {
            this.m_uiMenuListener = uiSysBB.RegisterListenerBool(GetAllBlackboardDefs().UI_System.IsInMenu, this, n"OnUiMenuChanged");
            this.m_pausedByUiMenu = uiSysBB.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
        }
        this.ScheduleTick(0.60);
    }

    private func OnDetach() -> Void {
        if IsDefined(this.m_uiMenuListener) {
            let uiSysBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_System);
            if IsDefined(uiSysBB) {
                uiSysBB.UnregisterListenerBool(GetAllBlackboardDefs().UI_System.IsInMenu, this.m_uiMenuListener);
            }
            this.m_uiMenuListener = null;
        }
        this.m_isTarotPopupOpen = false;
        this.SetSkipSpeechHintVisible(false);
        this.StopCurrentSpeechAudio();
        this.HideDialogChoices();
        this.HideWorldInteraction();
        this.ClearMappin();
        this.m_activeCallPendingPickup = false;
        this.m_holoCallActive = false;
        this.m_mistyCallSpeaking = false;
        this.m_vanillaCallCooldownUntil = 0.00;
        ArrayClear(this.m_deferredVanillaCalls);
        this.m_flushingDeferredCalls = false;
        this.m_phoneAvatarCtrl = null;
        this.StopHolocallRecordingStudio();
        if IsDefined(this.m_act00) {
            this.m_act00.CleanupEntities();
        }
        if IsDefined(this.m_act01) {
            this.m_act01.CleanupEntities();
        }
        if IsDefined(this.m_act02) {
            this.m_act02.CleanupEntities();
        }
        this.SetSubterraneanBunkerEnvActive(false);
        this.m_lookAtMistyEvt = null;
        this.m_lookAtValdesEvt = null;
        this.m_lookAtLuciaEvt = null;
        this.m_lookAtSolisEvt = null;
        this.m_lookAtGateEvt = null;
    }

    private func OnRestored(saveVersion: Int32, gameVersion: Int32) -> Void {
        this.m_isTarotPopupOpen = false;
        this.m_dialogWidgetCtrl = null;
        this.m_activeWorldMap = null;
        this.m_activeMapPinCtrl = null;
        this.m_tickScheduled = false;
        this.m_spawnGraceEnded = false;
        this.m_sessionReadyTicks = 0;
        this.m_journalPinSyncedTag = 0;
        this.m_journalPinRetryTicks = 0;
        this.m_wsAttempts = 0;
        this.m_wsLastTryAt = -10.00;
        this.m_valdesWsAttempts = 0;
        this.m_valdesWsLastTryAt = -10.00;
        this.m_gateWsAttempts = 0;
        this.m_gateWsLastTryAt = -10.00;
        this.m_luciaWsAttempts = 0;
        this.m_luciaWsLastTryAt = -10.00;
        this.m_solisWsAttempts = 0;
        this.m_solisWsLastTryAt = -10.00;
        this.m_roofReadingActive = false;
        this.m_mistyHoldingDeck = false;
        this.m_roofCardMoonDealt = false;
        this.m_roofCardHangmanDealt = false;
        this.m_roofCardTowerDealt = false;
        this.m_subBunkerEnvActive = false;
        this.m_lookAtMistyEvt = null;
        this.m_lookAtValdesEvt = null;
        this.m_lookAtLuciaEvt = null;
        this.m_lookAtSolisEvt = null;
        this.m_lookAtGateEvt = null;
        this.m_activeCallPendingPickup = false;
        this.m_activeCallScenario = 0;
        this.m_activeCallContact = n"None";
        this.m_holoCallActive = false;
        this.m_phoneAvatarCtrl = null;
        this.m_mistyCallSpeaking = false;
        this.m_vanillaCallCooldownUntil = 0.00;
        ArrayClear(this.m_deferredVanillaCalls);
        this.m_flushingDeferredCalls = false;
        this.StopHolocallRecordingStudio();
        if IsDefined(this.m_act00) {
            this.m_act00.OnSaveRestored();
        }
        if IsDefined(this.m_act01) {
            this.m_act01.OnSaveRestored();
        }
        if IsDefined(this.m_act02) {
            this.m_act02.OnSaveRestored();
        }
        this.ScheduleTick(0.60);
    }

    public final func SetDialogWidgetController(ctrl: wref<dialogWidgetGameController>) -> Void {
        this.m_dialogWidgetCtrl = ctrl;
    }

    public final func ScheduleTick(delaySeconds: Float) -> Void {
        if this.m_tickScheduled {
            return;
        }
        let cb: ref<CrimsonVeilTickCallback> = new CrimsonVeilTickCallback();
        cb.system = this;
        this.m_tickScheduled = true;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, delaySeconds, false);
    }

    // --- Utilidades Espaciales, Hora, Objetos y Localización ---

    public final func GetLoc(key: CName, fallback: String) -> String {
        if !IsNameValid(key) || Equals(key, n"None") {
            return fallback;
        }
        let txt: String = GetLocalizedTextByKey(key);
        if NotEquals(txt, "") {
            return txt;
        }
        return fallback;
    }

    public final func ComputeDistanceSq(a: Vector4, b: Vector4) -> Float {
        let dx: Float = a.X - b.X;
        let dy: Float = a.Y - b.Y;
        let dz: Float = a.Z - b.Z;
        return dx * dx + dy * dy + dz * dz;
    }

    private final func RaycastGroundSurface(pos: Vector4, upOffset: Float, downOffset: Float, out hitZ: Float) -> Bool {
        let startPos: Vector4 = new Vector4(pos.X, pos.Y, pos.Z + upOffset, 1.00);
        let endPos: Vector4 = new Vector4(pos.X, pos.Y, pos.Z - downOffset, 1.00);
        let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(this.GetGameInstance());
        if !IsDefined(sqs) {
            hitZ = pos.Z;
            return false;
        }
        let staticHit: TraceResult;
        let terrainHit: TraceResult;
        let hasStatic: Bool = sqs.SyncRaycastByCollisionGroup(startPos, endPos, n"Static", staticHit, true, false) && TraceResult.IsValid(staticHit);
        let hasTerrain: Bool = sqs.SyncRaycastByCollisionGroup(startPos, endPos, n"Terrain", terrainHit, true, false) && TraceResult.IsValid(terrainHit);
        if hasStatic && hasTerrain {
            hitZ = MaxF(staticHit.position.Z, terrainHit.position.Z);
            return true;
        }
        if hasStatic {
            hitZ = staticHit.position.Z;
            return true;
        }
        if hasTerrain {
            hitZ = terrainHit.position.Z;
            return true;
        }
        hitZ = pos.Z;
        return false;
    }

    public final func FindGroundZ(pos: Vector4) -> Float {
        let hitZ: Float = pos.Z;
        if this.RaycastGroundSurface(pos, 1.50, 2.50, hitZ) {
            return hitZ;
        }
        return pos.Z;
    }

    public final func FindGroundZWide(pos: Vector4) -> Float {
        let hitZ: Float = pos.Z;
        if this.RaycastGroundSurface(pos, 2.20, 5.50, hitZ) {
            return hitZ;
        }
        return pos.Z;
    }

    public final func FindGroundZWideChecked(pos: Vector4, out hitZ: Float) -> Bool {
        return this.RaycastGroundSurface(pos, 2.20, 5.50, hitZ);
    }

    public final func HasStaticFloorNear(pos: Vector4, expectedFloorZ: Float, upMargin: Float, downMargin: Float) -> Bool {
        let startPos: Vector4 = new Vector4(pos.X, pos.Y, expectedFloorZ + upMargin, 1.00);
        let endPos: Vector4 = new Vector4(pos.X, pos.Y, expectedFloorZ - downMargin, 1.00);
        let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(this.GetGameInstance());
        if !IsDefined(sqs) {
            return false;
        }
        let hitResult: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(startPos, endPos, n"Static", hitResult, true, false) && TraceResult.IsValid(hitResult) {
            let hz: Float = hitResult.position.Z;
            return hz >= (expectedFloorZ - downMargin) && hz <= (expectedFloorZ + upMargin);
        }
        return false;
    }

    public final func FindFloorZInRange(pos: Vector4, expectedFloorZ: Float, upMargin: Float, downMargin: Float) -> Float {
        let startPos: Vector4 = new Vector4(pos.X, pos.Y, expectedFloorZ + upMargin, 1.00);
        let endPos: Vector4 = new Vector4(pos.X, pos.Y, expectedFloorZ - downMargin, 1.00);
        let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(this.GetGameInstance());
        if !IsDefined(sqs) {
            return expectedFloorZ;
        }
        let hitResult: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(startPos, endPos, n"Static", hitResult, true, false) && TraceResult.IsValid(hitResult) {
            let hz: Float = hitResult.position.Z;
            if hz >= (expectedFloorZ - downMargin) && hz <= (expectedFloorZ + upMargin) {
                return hz;
            }
        }
        return expectedFloorZ;
    }

    public final func ResolveClearInteriorSpot(anchorPos: Vector4, expectedZ: Float, clearanceRadius: Float, out resolved: Vector4) -> Bool {
        if !this.HasStaticFloorNear(anchorPos, expectedZ, 1.60, 2.40) {
            resolved = new Vector4(anchorPos.X, anchorPos.Y, expectedZ, 1.00);
            return false;
        }
        let baseZ: Float = this.FindFloorZInRange(anchorPos, expectedZ, 1.60, 2.40);
        let basePos: Vector4 = new Vector4(anchorPos.X, anchorPos.Y, baseZ, 1.00);
        if this.IsSpotClearOfProps(basePos, clearanceRadius) {
            resolved = basePos;
            return true;
        }
        let radii: array<Float> = [1.10, 1.90, 2.80];
        let angles: array<Float> = [0.00, 0.7854, 1.5708, 2.3562, 3.1416, -2.3562, -1.5708, -0.7854];
        for r in radii {
            for ang in angles {
                let cand: Vector4 = new Vector4(basePos.X + r * CosF(ang), basePos.Y + r * SinF(ang), baseZ, 1.00);
                if this.HasStaticFloorNear(cand, baseZ, 1.40, 2.00) {
                    let hz: Float = this.FindFloorZInRange(cand, baseZ, 1.40, 2.00);
                    let candAtHit: Vector4 = new Vector4(cand.X, cand.Y, hz, 1.00);
                    if this.IsSpotClearOfProps(candAtHit, clearanceRadius) && this.HasClearWalkPath(basePos, candAtHit) {
                        resolved = candAtHit;
                        return true;
                    }
                }
            }
        }
        resolved = basePos;
        return true;
    }

    public final func HasClearWalkPath(fromPos: Vector4, toPos: Vector4) -> Bool {
        let dx: Float = toPos.X - fromPos.X;
        let dy: Float = toPos.Y - fromPos.Y;
        if (dx * dx + dy * dy) <= 0.25 {
            return true;
        }
        let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(this.GetGameInstance());
        if !IsDefined(sqs) {
            return false;
        }
        let waistStart: Vector4 = new Vector4(fromPos.X, fromPos.Y, fromPos.Z + 1.10, 1.00);
        let waistEnd: Vector4 = new Vector4(toPos.X, toPos.Y, toPos.Z + 1.10, 1.00);
        let waistHit: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(waistStart, waistEnd, n"Static", waistHit, true, false) && TraceResult.IsValid(waistHit) {
            return false;
        }
        let chestStart: Vector4 = new Vector4(fromPos.X, fromPos.Y, fromPos.Z + 1.55, 1.00);
        let chestEnd: Vector4 = new Vector4(toPos.X, toPos.Y, toPos.Z + 1.55, 1.00);
        let chestHit: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(chestStart, chestEnd, n"Static", chestHit, true, false) && TraceResult.IsValid(chestHit) {
            return false;
        }
        return true;
    }

    public final func ResolveSafeFlatGroundPos(anchorPos: Vector4, desiredPos: Vector4, maxDz: Float, out outPos: Vector4) -> Bool {
        let hitZ: Float = 0.00;
        if this.RaycastGroundSurface(desiredPos, 3.00, 6.00, hitZ) && AbsF(hitZ - anchorPos.Z) <= maxDz {
            let directCand: Vector4 = new Vector4(desiredPos.X, desiredPos.Y, hitZ, 1.00);
            if this.HasClearWalkPath(anchorPos, directCand) {
                outPos = directCand;
                return true;
            }
        }
        let dx: Float = desiredPos.X - anchorPos.X;
        let dy: Float = desiredPos.Y - anchorPos.Y;
        let baseRadius: Float = SqrtF(dx * dx + dy * dy);
        if baseRadius > 0.35 {
            let baseAngle: Float = AtanF(dy, dx);
            let radii: array<Float> = [baseRadius, baseRadius * 0.65, baseRadius * 0.35];
            let offsets: array<Float> = [0.52, -0.52, 1.05, -1.05, 1.57, -1.57, 2.09, -2.09, 2.62, -2.62, 3.14];
            for r in radii {
                for off in offsets {
                    let ang: Float = baseAngle + off;
                    let cand: Vector4 = new Vector4(anchorPos.X + r * CosF(ang), anchorPos.Y + r * SinF(ang), anchorPos.Z, 1.00);
                    if this.RaycastGroundSurface(cand, 3.00, 6.00, hitZ) && AbsF(hitZ - anchorPos.Z) <= maxDz {
                        let resolved: Vector4 = new Vector4(cand.X, cand.Y, hitZ, 1.00);
                        if this.HasClearWalkPath(anchorPos, resolved) {
                            outPos = resolved;
                            return true;
                        }
                    }
                }
            }
        }
        if this.RaycastGroundSurface(anchorPos, 3.00, 6.00, hitZ) {
            outPos = new Vector4(anchorPos.X, anchorPos.Y, hitZ, 1.00);
            return true;
        }
        outPos = anchorPos;
        return false;
    }

    public final func IsSpotClearOfProps(pos: Vector4, radius: Float) -> Bool {
        let sqs: ref<SpatialQueriesSystem> = GameInstance.GetSpatialQueriesSystem(this.GetGameInstance());
        if !IsDefined(sqs) {
            return false;
        }
        let headStart: Vector4 = new Vector4(pos.X, pos.Y, pos.Z + 0.30, 1.00);
        let headEnd: Vector4 = new Vector4(pos.X, pos.Y, pos.Z + 2.05, 1.00);
        let headStatic: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(headStart, headEnd, n"Static", headStatic, true, false) && TraceResult.IsValid(headStatic) {
            return false;
        }
        let headDyn: TraceResult;
        if sqs.SyncRaycastByCollisionGroup(headStart, headEnd, n"Dynamic", headDyn, true, false) && TraceResult.IsValid(headDyn) {
            return false;
        }

        let rad: Float = MaxF(0.45, radius);
        let angles: array<Float> = [0.00, 0.7854, 1.5708, 2.3562, 3.1416, -2.3562, -1.5708, -0.7854];
        let heights: array<Float> = [0.55, 1.10, 1.65];
        for h in heights {
            let orig: Vector4 = new Vector4(pos.X, pos.Y, pos.Z + h, 1.00);
            for ang in angles {
                let endPos: Vector4 = new Vector4(pos.X + rad * CosF(ang), pos.Y + rad * SinF(ang), pos.Z + h, 1.00);
                let hitS: TraceResult;
                if sqs.SyncRaycastByCollisionGroup(orig, endPos, n"Static", hitS, true, false) && TraceResult.IsValid(hitS) {
                    return false;
                }
                let hitD: TraceResult;
                if sqs.SyncRaycastByCollisionGroup(orig, endPos, n"Dynamic", hitD, true, false) && TraceResult.IsValid(hitD) {
                    return false;
                }
                let hitV: TraceResult;
                if sqs.SyncRaycastByCollisionGroup(orig, endPos, n"Vehicle", hitV, true, false) && TraceResult.IsValid(hitV) {
                    return false;
                }
            }
        }
        return true;
    }

    public final func ResolveClearPedestrianSpot(anchorPos: Vector4, clearanceRadius: Float, maxDeltaZ: Float, out resolved: Vector4) -> Bool {
        let anchorZ: Float = 0.00;
        if !this.RaycastGroundSurface(anchorPos, 0.55, 2.20, anchorZ) {
            resolved = anchorPos;
            return false;
        }
        if anchorZ > (anchorPos.Z + maxDeltaZ) {
            anchorZ = anchorPos.Z;
        }
        let basePos: Vector4 = new Vector4(anchorPos.X, anchorPos.Y, anchorZ, 1.00);
        if this.IsSpotClearOfProps(basePos, clearanceRadius) {
            resolved = basePos;
            return true;
        }

        let radii: array<Float> = [1.25, 2.10, 3.00, 4.00];
        let angles: array<Float> = [0.00, 0.7854, 1.5708, 2.3562, 3.1416, -2.3562, -1.5708, -0.7854];
        let hitZ: Float = 0.00;
        for r in radii {
            for ang in angles {
                let cand: Vector4 = new Vector4(basePos.X + r * CosF(ang), basePos.Y + r * SinF(ang), basePos.Z, 1.00);
                if this.RaycastGroundSurface(cand, 0.55, 2.20, hitZ) && AbsF(hitZ - anchorZ) <= maxDeltaZ {
                    let candAtHit: Vector4 = new Vector4(cand.X, cand.Y, hitZ, 1.00);
                    if this.IsSpotClearOfProps(candAtHit, clearanceRadius) && this.HasClearWalkPath(basePos, candAtHit) {
                        resolved = candAtHit;
                        return true;
                    }
                }
            }
        }

        let reducedRad: Float = MaxF(0.45, clearanceRadius * 0.65);
        for r in radii {
            for ang in angles {
                let cand2: Vector4 = new Vector4(basePos.X + r * CosF(ang), basePos.Y + r * SinF(ang), basePos.Z, 1.00);
                if this.RaycastGroundSurface(cand2, 0.55, 2.20, hitZ) && AbsF(hitZ - anchorZ) <= maxDeltaZ {
                    let candAtHit2: Vector4 = new Vector4(cand2.X, cand2.Y, hitZ, 1.00);
                    if this.IsSpotClearOfProps(candAtHit2, reducedRad) && this.HasClearWalkPath(basePos, candAtHit2) {
                        resolved = candAtHit2;
                        return true;
                    }
                }
            }
        }

        resolved = basePos;
        return true;
    }

    public final func SetNightTime2200() -> Void {
        GameInstance.GetTimeSystem(this.GetGameInstance()).SetGameTimeByHMS(22, 0, 0, n"CrimsonVeil");
    }

    public final func IsDaytimeNow() -> Bool {
        let h: Int32 = GameTime.Hours(GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTime());
        return h >= 7 && h < 20;
    }

    public final func TeleportPlayerSmooth(pos: Vector4, yaw: Float) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if !IsDefined(player) {
            return;
        }
        let ang: EulerAngles;
        ang.Yaw = yaw;
        GameInstance.GetTeleportationFacility(game).Teleport(player, pos, ang);
    }

    public final func GiveItemDelayed(itemTdbId: TweakDBID, amount: Int32, delaySeconds: Float) -> Void {
        if amount <= 0 {
            return;
        }
        let cb: ref<CrimsonVeilDelayedItemCallback> = new CrimsonVeilDelayedItemCallback();
        cb.system = this;
        cb.itemTdbId = itemTdbId;
        cb.amount = amount;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.05, delaySeconds), false);
    }

    public final func ExecuteDelayedItemGrant(itemTdbId: TweakDBID, amount: Int32) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
        if IsDefined(player) && IsDefined(ts) {
            ts.GiveItem(player, ItemID.FromTDBID(itemTdbId), amount);
        }
    }

    public final func ExecuteDelayedCheckpoint() -> Void {
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if this.IsGameplayReady(player) {
            GameInstance.GetAutoSaveSystem(game).RequestCheckpoint();
        }
    }

    public final func RequestDelayedCheckpoint(delaySeconds: Float) -> Void {
        let cb: ref<CrimsonVeilCheckpointCallback> = new CrimsonVeilCheckpointCallback();
        cb.system = this;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.10, delaySeconds), false);
    }

    public final func GrantExperience(xpAmount: Int32) -> Void {
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) && xpAmount > 0 {
            let xpEvt: ref<ExperiencePointsEvent> = new ExperiencePointsEvent();
            xpEvt.amount = xpAmount;
            xpEvt.type = gamedataProficiencyType.Level;
            xpEvt.isDebug = false;
            player.QueueEvent(xpEvt);
        }
    }

    // --- Gestión de Entidades CR2W, Misty y Workspots ---

    public final func SpawnStaticProp(templatePath: ResRef, pos: Vector4, yaw: Float, tagName: CName) -> EntityID {
        return this.SpawnStaticPropEx(templatePath, n"None", pos, 0.00, yaw, tagName);
    }

    public final func SpawnStaticPropEx(templatePath: ResRef, appearanceName: CName, pos: Vector4, pitch: Float, yaw: Float, tagName: CName) -> EntityID {
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        if !IsDefined(ses) || !ses.IsReady() {
            return new EntityID();
        }
        let spec: ref<StaticEntitySpec> = new StaticEntitySpec();
        spec.templatePath = templatePath;
        if IsNameValid(appearanceName) && NotEquals(appearanceName, n"None") {
            spec.appearanceName = appearanceName;
        }
        spec.position = pos;
        let ang: EulerAngles;
        ang.Pitch = pitch;
        ang.Yaw = yaw;
        spec.orientation = EulerAngles.ToQuat(ang);
        spec.attached = true;
        spec.tags = [n"CrimsonVeilProp", tagName];
        return ses.SpawnEntity(spec);
    }

    public final func IsStaticPropAliveOrSpawning(id: EntityID) -> Bool {
        if !EntityID.IsDefined(id) {
            return false;
        }
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        return IsDefined(ses) && (ses.IsSpawned(id) || ses.IsSpawning(id));
    }

    public final func DespawnStaticPropById(id: EntityID) -> Void {
        if !EntityID.IsDefined(id) {
            return;
        }
        let ses: ref<StaticEntitySystem> = GameInstance.GetStaticEntitySystem();
        if IsDefined(ses) && ses.IsSpawned(id) {
            ses.DespawnEntity(id);
        }
    }

    public final func SpawnDynamicNpc(recordId: TweakDBID, pos: Vector4, yaw: Float, tagName: CName, opt appearanceName: CName) -> EntityID {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsReady() {
            return new EntityID();
        }
        let existingId: EntityID = des.GetTaggedID(tagName);
        if EntityID.IsDefined(existingId) && des.IsManaged(existingId) {
            return existingId;
        }
        let spec: ref<DynamicEntitySpec> = new DynamicEntitySpec();
        spec.recordID = recordId;
        if IsNameValid(appearanceName) && NotEquals(appearanceName, n"None") {
            spec.appearanceName = appearanceName;
        }
        spec.position = pos;
        let ang: EulerAngles;
        ang.Yaw = yaw;
        spec.orientation = EulerAngles.ToQuat(ang);
        spec.persistState = false;
        spec.persistSpawn = false;
        spec.alwaysSpawned = true;
        spec.spawnInView = true;
        spec.active = true;
        spec.tags = [n"CrimsonVeilNPC", tagName];
        return des.CreateEntity(spec);
    }

    public final func IsDynamicNpcAliveOrSpawning(id: EntityID) -> Bool {
        if !EntityID.IsDefined(id) {
            return false;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        return IsDefined(des) && des.IsManaged(id);
    }

    public final func SpawnWorkspotAnchor(templatePath: ResRef, pos: Vector4, yaw: Float, tagName: CName) -> EntityID {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsReady() {
            return new EntityID();
        }
        let existingId: EntityID = des.GetTaggedID(tagName);
        if EntityID.IsDefined(existingId) && des.IsManaged(existingId) {
            return existingId;
        }
        let spec: ref<DynamicEntitySpec> = new DynamicEntitySpec();
        spec.templatePath = templatePath;
        spec.position = pos;
        let ang: EulerAngles;
        ang.Yaw = yaw;
        spec.orientation = EulerAngles.ToQuat(ang);
        spec.persistState = false;
        spec.persistSpawn = false;
        spec.alwaysSpawned = true;
        spec.spawnInView = true;
        spec.active = true;
        spec.tags = [n"CrimsonVeilWorkspot", tagName];
        return des.CreateEntity(spec);
    }

    public final func EnsureNpcImmortal(npcId: EntityID) -> Void {
        if !EntityID.IsDefined(npcId) {
            return;
        }
        let gms: ref<GodModeSystem> = GameInstance.GetGodModeSystem(this.GetGameInstance());
        if IsDefined(gms) {
            gms.AddGodMode(npcId, gameGodModeType.Immortal, n"CrimsonVeil");
        }
    }

    public final func RemoveNpcImmortal(npcId: EntityID) -> Void {
        if !EntityID.IsDefined(npcId) {
            return;
        }
        let gms: ref<GodModeSystem> = GameInstance.GetGodModeSystem(this.GetGameInstance());
        if IsDefined(gms) {
            gms.RemoveGodMode(npcId, gameGodModeType.Immortal, n"CrimsonVeil");
        }
    }

    public final func StopNpcWorkspotById(npcId: EntityID) -> Void {
        if !EntityID.IsDefined(npcId) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsSpawned(npcId) {
            return;
        }
        let npc: ref<GameObject> = des.GetEntity(npcId) as GameObject;
        let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(game);
        if IsDefined(npc) && IsDefined(ws) && ws.IsActorInWorkspot(npc) {
            ws.SendFastExitSignal(npc, new Vector3(0.00, 0.00, 0.00), false, false, true, false);
            let puppet: ref<ScriptedPuppet> = npc as ScriptedPuppet;
            if IsDefined(puppet) {
                AIActionHelper.ClearWorkspotCommand(puppet, true);
            }
            ws.StopNpcInWorkspot(npc);
            ws.StopInDevice(npc);
        }
    }

    public final func EnsureCombatNpcArmed(npc: ref<NPCPuppet>) -> Void {
        if !IsDefined(npc) || npc.IsDead() {
            return;
        }
        let weaponInHand: ref<WeaponObject> = ScriptedPuppet.GetWeaponRight(npc);
        if IsDefined(weaponInHand) {
            return;
        }
        let aiComp: ref<AIHumanComponent> = npc.GetAIControllerComponent();
        if !IsDefined(aiComp) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(game);
        let shingenId: ItemID = ItemID.FromTDBID(t"Items.Preset_Shingen_Default");
        if IsDefined(ts) && ts.GetItemQuantity(npc, shingenId) == 0 {
            ts.GiveItem(npc, shingenId, 1);
            let eqCmd: ref<AIEquipCommand> = new AIEquipCommand();
            eqCmd.slotId = t"AttachmentSlots.WeaponRight";
            eqCmd.itemId = t"Items.Preset_Shingen_Default";
            eqCmd.failIfItemNotFound = false;
            aiComp.SendCommand(eqCmd);
        } else {
            let drawCmd: ref<AISwitchToPrimaryWeaponCommand> = new AISwitchToPrimaryWeaponCommand();
            drawCmd.unEquip = false;
            aiComp.SendCommand(drawCmd);
        }
    }

    public final func MakeNpcHostile(npc: ref<NPCPuppet>, player: ref<PlayerPuppet>) -> Void {
        if !IsDefined(npc) || !IsDefined(player) || npc.IsDead() || ScriptedPuppet.IsDefeated(npc) || ScriptedPuppet.IsUnconscious(npc) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let npcId: EntityID = npc.GetEntityID();
        this.RemoveNpcImmortal(npcId);
        let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(game);
        if IsDefined(ws) && ws.IsActorInWorkspot(npc) {
            ws.SendFastExitSignal(npc, new Vector3(0.00, 0.00, 0.00), false, false, true, false);
            AIActionHelper.ClearWorkspotCommand(npc, true);
            ws.StopNpcInWorkspot(npc);
            ws.StopInDevice(npc);
        }
        AnimationControllerComponent.SetAnimWrapperWeightOnOwnerAndItems(npc, n"Relaxed", 0.00);
        let aiComp: ref<AIHumanComponent> = npc.GetAIControllerComponent();
        if IsDefined(aiComp) {
            let curRole: ref<AIRole> = aiComp.GetAIRole();
            if IsDefined(curRole) && NotEquals(curRole.GetRoleEnum(), EAIRole.None) {
                AIHumanComponent.SetCurrentRole(npc, new AINoRole());
            }
        }
        let alreadyInCombat: Bool = NPCPuppet.IsInCombat(npc);
        if !alreadyInCombat {
            SenseComponent.ResetPreset(npc);
        }
        let attAgent: ref<AttitudeAgent> = npc.GetAttitudeAgent();
        if IsDefined(attAgent) {
            attAgent.SetAttitudeGroup(n"hostile");
            attAgent.SetAttitudeTowards(player.GetAttitudeAgent(), EAIAttitude.AIA_Hostile);
        }
        TargetTrackingExtension.InjectThreat(npc, player);
        let ttc: ref<TargetTrackerComponent> = npc.GetTargetTrackerComponent();
        if IsDefined(ttc) {
            ttc.AddThreat(player, true, player.GetWorldPosition(), 1.00, 30.00, true);
            ttc.SetThreatAccuracy(player, 1.00);
            ttc.SetThreatBeliefAccuracy(player, 1.00);
            ttc.ActivateThreat(player);
        }
        if !alreadyInCombat {
            NPCPuppet.ChangeHighLevelState(npc, gamedataNPCHighLevelState.Combat);
            AIActionHelper.TryStartCombatWithTarget(npc, player);
            let reactComp: ref<ReactionManagerComponent> = npc.GetStimReactionComponent();
            if IsDefined(reactComp) {
                reactComp.TriggerCombat(player);
            }
        }
        this.EnsureCombatNpcArmed(npc);
    }

    public final func IsSubterraneanBunkerEnvActive() -> Bool = this.m_subBunkerEnvActive;

    public final func SetSubterraneanBunkerEnvActive(active: Bool) -> Void {
        if Equals(this.m_subBunkerEnvActive, active) {
            return;
        }
        let wss: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
        if !IsDefined(wss) || !wss.IsReady() {
            return;
        }
        this.m_subBunkerEnvActive = active;
        let lightShort: NodeRef = CreateNodeRef("#loc_q105_braindance_studio_lighting");
        let lightFull: NodeRef = CreateNodeRef("$/03_night_city/c_westbrook/charter_hill/loc_q105_braindance_studio_prefabXLFXRXI/#loc_q105_braindance_studio_lighting");
        if active {
            wss.ToggleVariant(lightShort, n"braindance_base", false);
            wss.ToggleVariant(lightShort, n"braindance_death", true);
            wss.ToggleVariant(lightFull, n"braindance_base", false);
            wss.ToggleVariant(lightFull, n"braindance_death", true);
            wss.DeactivateCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_0"));
            wss.DeactivateCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_1"));
            wss.DeactivateCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_2"));
        } else {
            wss.ToggleVariant(lightShort, n"braindance_death", false);
            wss.ToggleVariant(lightShort, n"braindance_base", true);
            wss.ToggleVariant(lightFull, n"braindance_death", false);
            wss.ToggleVariant(lightFull, n"braindance_base", true);
            wss.ResetCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_0"));
            wss.ResetCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_1"));
            wss.ResetCommunity(CreateNodeRef("#q105_com_braindance_combat_floor_2"));
        }
    }

    public final func ResetMistyWorkspotRetryState() -> Void {
        this.m_wsAttempts = 0;
        this.m_wsLastTryAt = -10.00;
        this.m_lookAtMistyEvt = null;
    }

    public final func ResetValdesWorkspotRetryState() -> Void {
        this.m_valdesWsAttempts = 0;
        this.m_valdesWsLastTryAt = -10.00;
        this.m_lookAtValdesEvt = null;
    }

    public final func ResetLuciaWorkspotRetryState() -> Void {
        this.m_luciaWsAttempts = 0;
        this.m_luciaWsLastTryAt = -10.00;
        this.m_lookAtLuciaEvt = null;
    }

    public final func ResetSolisWorkspotRetryState() -> Void {
        this.m_solisWsAttempts = 0;
        this.m_solisWsLastTryAt = -10.00;
        this.m_lookAtSolisEvt = null;
    }

    public final func ResetGatekeeperWorkspotRetryState() -> Void {
        this.m_gateWsAttempts = 0;
        this.m_gateWsLastTryAt = -10.00;
        this.m_lookAtGateEvt = null;
    }

    public final func EnsureMistyWorkspotAndLook(mistyId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>) -> Void {
        this.EnsureChoreographedNpcInWorkspot(mistyId, anchorId, player, 0);
    }

    public final func EnsureValdesWorkspotAndLook(valdesId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>) -> Void {
        this.EnsureChoreographedNpcInWorkspot(valdesId, anchorId, player, 1);
    }

    public final func EnsureLuciaWorkspotAndLook(luciaId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>) -> Void {
        this.EnsureChoreographedNpcInWorkspot(luciaId, anchorId, player, 2);
    }

    public final func EnsureSolisWorkspotAndLook(solisId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>) -> Void {
        this.EnsureChoreographedNpcInWorkspot(solisId, anchorId, player, 3);
    }

    public final func EnsureGatekeeperWorkspotAndLook(gateId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>) -> Void {
        this.EnsureChoreographedNpcInWorkspot(gateId, anchorId, player, 4);
    }

    public final func EnsurePassiveGuardAtPost(npcId: EntityID, homePos: Vector4, homeYaw: Float) -> Void {
        if !EntityID.IsDefined(npcId) {
            return;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsSpawned(npcId) {
            return;
        }
        let npc: ref<NPCPuppet> = des.GetEntity(npcId) as NPCPuppet;
        if !IsDefined(npc) || npc.IsDead() || ScriptedPuppet.IsDefeated(npc) || ScriptedPuppet.IsUnconscious(npc) || NPCPuppet.IsInCombat(npc) {
            return;
        }
        NPCPuppet.ChangeHighLevelState(npc, gamedataNPCHighLevelState.Relaxed);
        NPCPuppet.ChangeStanceState(npc, gamedataNPCStanceState.Stand);
        if this.ComputeDistanceSq(npc.GetWorldPosition(), homePos) > 4.00 {
            let ang: EulerAngles;
            ang.Yaw = homeYaw;
            GameInstance.GetTeleportationFacility(this.GetGameInstance()).Teleport(npc, homePos, ang);
        }
    }

    private final func EnsureChoreographedNpcInWorkspot(npcId: EntityID, anchorId: EntityID, player: ref<PlayerPuppet>, npcRole: Int32) -> Void {
        if !EntityID.IsDefined(npcId) || !EntityID.IsDefined(anchorId) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsSpawned(npcId) || !des.IsSpawned(anchorId) {
            return;
        }
        let npc: ref<NPCPuppet> = des.GetEntity(npcId) as NPCPuppet;
        let anchor: ref<GameObject> = des.GetEntity(anchorId) as GameObject;
        let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(game);
        if !IsDefined(npc) || npc.IsDead() || !IsDefined(anchor) || !IsDefined(ws) {
            return;
        }
        this.EnsureNpcImmortal(npcId);
        npc.CvDisableVanillaInteraction();

        if ws.IsActorInWorkspot(npc) {
            let activeLook: Bool = false;
            if npcRole == 1 {
                activeLook = IsDefined(this.m_lookAtValdesEvt);
            } else if npcRole == 2 {
                activeLook = IsDefined(this.m_lookAtLuciaEvt);
            } else if npcRole == 3 {
                activeLook = IsDefined(this.m_lookAtSolisEvt);
            } else if npcRole == 4 {
                activeLook = IsDefined(this.m_lookAtGateEvt);
            } else {
                activeLook = IsDefined(this.m_lookAtMistyEvt);
            }
            if IsDefined(player) && !activeLook {
                this.ApplyNpcLookAt(npcRole, npc, player);
            }
            return;
        }

        let aPos: Vector4 = anchor.GetWorldPosition();
        if this.ComputeDistanceSq(npc.GetWorldPosition(), aPos) > 2.25 {
            let ang: EulerAngles;
            ang.Yaw = anchor.GetWorldYaw();
            GameInstance.GetTeleportationFacility(game).Teleport(npc, aPos, ang);
        }

        NPCPuppet.ChangeHighLevelState(npc, gamedataNPCHighLevelState.Relaxed);
        NPCPuppet.ChangeStanceState(npc, gamedataNPCStanceState.Stand);

        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        let attempts: Int32 = this.m_wsAttempts;
        let lastTry: Float = this.m_wsLastTryAt;
        if npcRole == 1 {
            attempts = this.m_valdesWsAttempts;
            lastTry = this.m_valdesWsLastTryAt;
        } else if npcRole == 2 {
            attempts = this.m_luciaWsAttempts;
            lastTry = this.m_luciaWsLastTryAt;
        } else if npcRole == 3 {
            attempts = this.m_solisWsAttempts;
            lastTry = this.m_solisWsLastTryAt;
        } else if npcRole == 4 {
            attempts = this.m_gateWsAttempts;
            lastTry = this.m_gateWsLastTryAt;
        }
        let interval: Float = attempts <= 5 ? 0.45 : 3.00;
        if (nowSim - lastTry) < interval {
            return;
        }
        let tier: Int32 = (attempts % 3) + 1;
        if tier == 1 {
            ws.PlayInDeviceSimple(anchor, npc, false, n"workspot", n"None", n"None", 0.00, WorkspotSlidingBehaviour.PlayAtResourcePosition);
        } else if tier == 2 {
            ws.PlayInDevice(anchor, npc, n"lockedCamera", n"workspot", n"None", n"None", 0.00, WorkspotSlidingBehaviour.PlayAtResourcePosition);
        } else {
            ws.PlayNpcInWorkspot(npc, anchor, anchor, n"workspot", n"None", 0.00);
        }
        if npcRole == 1 {
            this.m_valdesWsAttempts += 1;
            this.m_valdesWsLastTryAt = nowSim;
        } else if npcRole == 2 {
            this.m_luciaWsAttempts += 1;
            this.m_luciaWsLastTryAt = nowSim;
        } else if npcRole == 3 {
            this.m_solisWsAttempts += 1;
            this.m_solisWsLastTryAt = nowSim;
        } else if npcRole == 4 {
            this.m_gateWsAttempts += 1;
            this.m_gateWsLastTryAt = nowSim;
        } else {
            this.m_wsAttempts += 1;
            this.m_wsLastTryAt = nowSim;
        }
    }

    private final func ApplyNpcLookAt(npcRole: Int32, npc: ref<NPCPuppet>, player: ref<PlayerPuppet>, opt targetOffset: Vector4) -> Void {
        if !IsDefined(npc) || !IsDefined(player) || npc.IsDead() {
            return;
        }
        let prevEvt: ref<LookAtAddEvent> = this.m_lookAtMistyEvt;
        if npcRole == 1 {
            prevEvt = this.m_lookAtValdesEvt;
        } else if npcRole == 2 {
            prevEvt = this.m_lookAtLuciaEvt;
        } else if npcRole == 3 {
            prevEvt = this.m_lookAtSolisEvt;
        } else if npcRole == 4 {
            prevEvt = this.m_lookAtGateEvt;
        }
        if IsDefined(prevEvt) {
            LookAtRemoveEvent.QueueRemoveLookatEvent(npc, prevEvt);
            if npcRole == 1 {
                this.m_lookAtValdesEvt = null;
            } else if npcRole == 2 {
                this.m_lookAtLuciaEvt = null;
            } else if npcRole == 3 {
                this.m_lookAtSolisEvt = null;
            } else if npcRole == 4 {
                this.m_lookAtGateEvt = null;
            } else {
                this.m_lookAtMistyEvt = null;
            }
        }
        let lookEvt: ref<LookAtAddEvent> = new LookAtAddEvent();
        lookEvt.SetEntityTarget(player, n"pla_default_tgt", targetOffset);
        lookEvt.SetStyle(animLookAtStyle.Normal);
        lookEvt.request.limits.softLimitDegrees = 360.00;
        lookEvt.request.limits.hardLimitDegrees = 270.00;
        lookEvt.request.limits.backLimitDegrees = 210.00;
        lookEvt.request.limits.hardLimitDistance = GetLookAtLimitDistanceValue(animLookAtLimitDistanceType.None);
        lookEvt.request.calculatePositionInParentSpace = true;
        lookEvt.bodyPart = n"Eyes";
        let parts: array<LookAtPartRequest>;
        let headReq: LookAtPartRequest;
        headReq.partName = n"Head";
        headReq.weight = 0.85;
        headReq.suppress = 0.72;
        headReq.mode = 0;
        ArrayPush(parts, headReq);
        let chestReq: LookAtPartRequest;
        chestReq.partName = n"Chest";
        chestReq.weight = 0.40;
        chestReq.suppress = 0.65;
        chestReq.mode = 0;
        ArrayPush(parts, chestReq);
        lookEvt.SetAdditionalPartsArray(parts);
        npc.QueueEvent(lookEvt);
        if npcRole == 1 {
            this.m_lookAtValdesEvt = lookEvt;
        } else if npcRole == 2 {
            this.m_lookAtLuciaEvt = lookEvt;
        } else if npcRole == 3 {
            this.m_lookAtSolisEvt = lookEvt;
        } else if npcRole == 4 {
            this.m_lookAtGateEvt = lookEvt;
        } else {
            this.m_lookAtMistyEvt = lookEvt;
        }
    }

    public final func IsNpcNeutralized(id: EntityID, anchorPos: Vector4, combatElapsed: Float) -> Bool {
        if !EntityID.IsDefined(id) {
            return true;
        }
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if !IsDefined(des) || !des.IsManaged(id) {
            return true;
        }
        if !des.IsSpawned(id) {
            if des.IsSpawning(id) && (combatElapsed <= 0.01 || combatElapsed < 6.00) {
                return false;
            }
            return combatElapsed > 0.01;
        }
        let npc: ref<NPCPuppet> = des.GetEntity(id) as NPCPuppet;
        if !IsDefined(npc) {
            return true;
        }
        if npc.IsDead()
            || ScriptedPuppet.IsDefeated(npc)
            || ScriptedPuppet.IsUnconscious(npc)
            || !ScriptedPuppet.IsActive(npc) {
            return true;
        }
        let sps: ref<StatPoolsSystem> = GameInstance.GetStatPoolsSystem(this.GetGameInstance());
        if combatElapsed >= 1.50 && IsDefined(sps)
            && sps.GetStatPoolValue(Cast<StatsObjectID>(id), gamedataStatPoolType.Health, true) <= 1.50 {
            return true;
        }
        let np: Vector4 = npc.GetWorldPosition();
        if AbsF(np.Z - anchorPos.Z) > 10.00 || this.ComputeDistanceSq(np, anchorPos) > 3600.00 {
            return true;
        }
        return false;
    }

    // --- Lip-Sync JALI Real + Coreografía Corporal de Misty ---

    public final func IsActiveLipSyncEntity(id: EntityID) -> Bool {
        return EntityID.IsDefined(id) && EntityID.IsDefined(this.m_lipSyncEntityId) && Equals(id, this.m_lipSyncEntityId) && this.m_lipSyncRemaining > 0.05;
    }

    private final func ApplyMistyFacial(npc: ref<NPCPuppet>, category: Int32, idle: Int32) -> Void {
        if !IsDefined(npc) || npc.IsDead() {
            return;
        }
        let react: ref<AnimFeature_FacialReaction> = new AnimFeature_FacialReaction();
        react.category = category;
        react.idle = idle;
        AnimationControllerComponent.ApplyFeatureToReplicate(npc, n"FacialReaction", react);
    }

    private final func ApplyCvLipSync(npc: ref<NPCPuppet>, slot: Int32, bank: Int32, clip: Int32, weight: Float) -> Void {
        if !IsDefined(npc) || npc.IsDead() {
            return;
        }
        let feat: ref<AnimFeature_CvLipSync> = new AnimFeature_CvLipSync();
        feat.slot = slot;
        feat.bank = bank;
        feat.clip = clip;
        feat.weight = weight;
        AnimationControllerComponent.ApplyFeatureToReplicate(npc, n"CvLipSync", feat);
    }

    private final func ResolveNpcLipSyncClipId(speakerTag: CName, eventName: CName) -> Int32 {
        if Equals(speakerTag, n"lucia") {
            switch eventName {
                case n"cv_a2_lucia_intro":
                    return 1;
                case n"cv_a2_lucia_a1":
                    return 2;
                case n"cv_a2_lucia_a2":
                    return 3;
                case n"cv_a2_lucia_adv":
                    return 4;
                case n"cv_a2_roof_lucia_greet":
                    return 5;
                default:
                    return 0;
            }
        }
        if Equals(speakerTag, n"solis") {
            switch eventName {
                case n"cv_a2_solis_intro":
                    return 1;
                case n"cv_a2_solis_a1":
                    return 2;
                case n"cv_a2_solis_a2":
                    return 3;
                case n"cv_a2_solis_a3":
                    return 4;
                case n"cv_a2_solis_combat":
                    return 5;
                case n"cv_a2_solis_pact":
                    return 6;
                default:
                    return 0;
            }
        }
        if Equals(speakerTag, n"valdes") {
            switch eventName {
                case n"cv_a1_valdes_intro_01":
                    return 1;
                case n"cv_a1_valdes_ans_nox9":
                    return 2;
                case n"cv_a1_valdes_ans_misty":
                    return 3;
                case n"cv_a1_valdes_give_trust":
                    return 4;
                case n"cv_a1_valdes_give_pressure":
                    return 5;
                case n"cv_a1_r2_valdes_intro":
                    return 6;
                case n"cv_a1_r2_valdes_ans_role":
                    return 7;
                case n"cv_a1_r2_valdes_ans_sect":
                    return 8;
                case n"cv_a1_r2_valdes_ans_leads":
                    return 9;
                case n"cv_a1_r2_valdes_give_trust":
                    return 10;
                case n"cv_a1_r2_valdes_give_pressure":
                    return 11;
                default:
                    return 0;
            }
        }
        switch eventName {
            case n"cv_p0_misty_esoterica_01":
                return 1;
            case n"cv_p0_misty_rooftop_01":
                return 2;
            case n"cv_p0_misty_rooftop_02":
                return 3;
            case n"cv_p0_misty_ans_chorus":
                return 4;
            case n"cv_p0_misty_ans_uv":
                return 5;
            case n"cv_p0_misty_tarot_forensic":
                return 6;
            case n"cv_p0_misty_tarot_symbolic":
                return 7;
            case n"cv_p0_misty_debrief_01":
                return 8;
            case n"cv_p0_misty_debrief_02":
                return 9;
            case n"cv_a1_misty_debrief_stealth":
                return 10;
            case n"cv_a1_misty_debrief_combat":
                return 11;
            case n"cv_a1_misty_debrief_badlands":
                return 12;
            case n"cv_a1_misty_cliffhanger":
                return 13;
            case n"cv_r2_call_misty_01":
                return 14;
            case n"cv_r2_call_misty_02":
                return 15;
            case n"cv_r2_alley_misty_warn":
                return 16;
            case n"cv_r2_alley_misty_lucia_01":
                return 17;
            case n"cv_r2_alley_misty_lucia_02":
                return 18;
            case n"cv_r2_alley_qa_missing_m":
                return 19;
            case n"cv_r2_alley_qa_watched_m":
                return 20;
            case n"cv_r2_alley_qa_chorus_m":
                return 21;
            case n"cv_r2_alley_misty_rooftop":
                return 22;
            case n"cv_r2_roof_misty_intro":
                return 23;
            case n"cv_r2_roof_misty_uv":
                return 24;
            case n"cv_r2_oil_misty_radio":
                return 25;
            case n"cv_r2_debrief_m1":
                return 26;
            case n"cv_r2_debrief_m2":
                return 27;
            case n"cv_r2_roof_open_m1":
                return 28;
            case n"cv_r2_roof_open_m2":
                return 29;
            case n"cv_r2_roof_open_m3":
                return 30;
            case n"cv_r2_roof_chem_m":
                return 31;
            case n"cv_r2_roof_cards_m":
                return 32;
            case n"cv_r2_roof_promise_m":
                return 33;
            case n"cv_a1_r2_call_m1":
                return 34;
            case n"cv_a1_r2_call_m2":
                return 35;
            case n"cv_a1_r2_debrief_m1_stealth":
                return 36;
            case n"cv_a1_r2_debrief_m1_combat":
                return 37;
            case n"cv_a1_r2_debrief_m2":
                return 38;
            case n"cv_a1_r2_debrief_m3":
                return 39;
            case n"cv_a2_call_m1":
                return 40;
            case n"cv_a2_call_m2":
                return 41;
            case n"cv_a2_roof_misty_cure":
                return 42;
            case n"cv_a2_roof_misty_pact":
                return 43;
            case n"cv_a2_roof_misty_burn":
                return 44;
            case n"cv_a2_roof_misty_epilogue":
                return 45;
            default:
                return 0;
        }
    }

    private final func ApplyRooftopTableState() -> Void {
        if !IsDefined(this.m_act00) {
            return;
        }
        let tableId: EntityID = this.m_act00.GetRooftopTableEntityID();
        if !EntityID.IsDefined(tableId) {
            return;
        }
        let tbl: ref<Entity> = GameInstance.FindEntityByID(this.GetGameInstance(), tableId);
        if IsDefined(tbl) {
            tbl.SetCvRooftopTableState(!this.m_mistyHoldingDeck, this.m_roofCardMoonDealt, this.m_roofCardHangmanDealt, this.m_roofCardTowerDealt);
        }
    }

    public final func SyncOilShrineEvidenceVisual(shrineId: EntityID, taken: Bool) -> Void {
        if !EntityID.IsDefined(shrineId) {
            return;
        }
        let ent: ref<Entity> = GameInstance.FindEntityByID(this.GetGameInstance(), shrineId);
        if IsDefined(ent) {
            ent.SetCvOilShrineEvidenceTaken(taken);
        }
    }

    public final func SyncUvEmitterVisual(emitterId: EntityID, flashActive: Bool, readyGlow: Bool) -> Void {
        if !EntityID.IsDefined(emitterId) {
            return;
        }
        let ent: ref<Entity> = GameInstance.FindEntityByID(this.GetGameInstance(), emitterId);
        if IsDefined(ent) {
            ent.SetCvUvEmitterVisualState(flashActive, readyGlow);
        }
    }

    public final func SyncKabukiRelayVisual(relayId: EntityID, taken: Bool) -> Void {
        if !EntityID.IsDefined(relayId) {
            return;
        }
        let ent: ref<Entity> = GameInstance.FindEntityByID(this.GetGameInstance(), relayId);
        if IsDefined(ent) {
            ent.SetCvKabukiRelayTaken(taken);
        }
    }

    public final func SyncValdesDeskCipherVisual(deskId: EntityID, taken: Bool) -> Void {
        if !EntityID.IsDefined(deskId) {
            return;
        }
        let ent: ref<Entity> = GameInstance.FindEntityByID(this.GetGameInstance(), deskId);
        if IsDefined(ent) {
            ent.SetCvValdesDeskCipherTaken(taken);
        }
    }

    public final func ResetRooftopTarotTableVisualState() -> Void {
        this.m_roofReadingActive = false;
        this.m_mistyHoldingDeck = false;
        this.m_roofCardMoonDealt = false;
        this.m_roofCardHangmanDealt = false;
        this.m_roofCardTowerDealt = false;
        this.ApplyRooftopTableState();
    }

    public final func BeginRooftopTarotReadingVisuals() -> Void {
        this.m_roofReadingActive = true;
        this.m_mistyHoldingDeck = true;
        this.m_roofCardMoonDealt = false;
        this.m_roofCardHangmanDealt = false;
        this.m_roofCardTowerDealt = false;
        this.ApplyRooftopTableState();
    }

    public final func SyncRooftopTableStateFromQuest() -> Void {
        if this.m_roofReadingActive {
            this.ApplyRooftopTableState();
            return;
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
        let opened: Bool = IsDefined(qs) && qs.GetFact(n"cv_r2_roof_opened") >= 1;
        this.m_roofCardMoonDealt = opened;
        this.m_roofCardHangmanDealt = opened;
        this.m_roofCardTowerDealt = opened;
        this.ApplyRooftopTableState();
    }

    private final func ScheduleTarotCardPlaceHandoff(delaySec: Float, cardSlot: Int32, isShowInHand: Bool) -> Void {
        let cb: ref<CrimsonVeilCardPlaceCallback> = new CrimsonVeilCardPlaceCallback();
        cb.system = this;
        cb.token = this.m_lipSyncToken;
        cb.cardSlot = cardSlot;
        cb.isShowInHand = isShowInHand;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.10, delaySec), false);
    }

    public final func OnTarotCardPlaceTick(token: Int32, cardSlot: Int32, isShowInHand: Bool) -> Void {
        if token != this.m_lipSyncToken || cardSlot < 1 || cardSlot > 3 {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        if this.m_pausedByUiMenu {
            let pcb: ref<CrimsonVeilCardPlaceCallback> = new CrimsonVeilCardPlaceCallback();
            pcb.system = this;
            pcb.token = token;
            pcb.cardSlot = cardSlot;
            pcb.isShowInHand = isShowInHand;
            GameInstance.GetDelaySystem(game).DelayCallback(pcb, 0.15, false);
            return;
        }
        let npc: ref<NPCPuppet> = EntityID.IsDefined(this.m_lipSyncEntityId) ? (GameInstance.FindEntityByID(game, this.m_lipSyncEntityId) as NPCPuppet) : null;
        if isShowInHand {
            if IsDefined(npc) && !npc.IsDead() {
                npc.SetCvTarotHandProps(true, cardSlot == 1, cardSlot == 2, cardSlot == 3);
            }
            return;
        }
        if IsDefined(npc) && !npc.IsDead() {
            npc.SetCvTarotHandProps(true, false, false, false);
        }
        if cardSlot == 1 {
            this.m_roofCardMoonDealt = true;
        } else if cardSlot == 2 {
            this.m_roofCardHangmanDealt = true;
        } else if cardSlot == 3 {
            this.m_roofCardTowerDealt = true;
        }
        this.ApplyRooftopTableState();
        this.PlaySfx(n"cv_sfx_tarot_flip");
    }

    private final func TriggerNpcBodyGesture(npc: ref<NPCPuppet>, entryId: Int32, instant: Bool) -> Void {
        if !IsDefined(npc) || npc.IsDead() || entryId <= 0 {
            return;
        }
        if entryId == 40 {
            npc.SetCvTarotHandProps(true, false, false, false);
            this.m_mistyHoldingDeck = true;
        } else if entryId == 41 {
            npc.SetCvTarotHandProps(true, false, false, false);
            this.m_mistyHoldingDeck = true;
            this.ScheduleTarotCardPlaceHandoff(0.55, 1, true);
            this.ScheduleTarotCardPlaceHandoff(2.45, 1, false);
        } else if entryId == 42 {
            npc.SetCvTarotHandProps(true, false, false, false);
            this.m_mistyHoldingDeck = true;
            this.ScheduleTarotCardPlaceHandoff(0.55, 2, true);
            this.ScheduleTarotCardPlaceHandoff(2.35, 2, false);
        } else if entryId == 43 {
            npc.SetCvTarotHandProps(true, false, false, false);
            this.m_mistyHoldingDeck = true;
            this.ScheduleTarotCardPlaceHandoff(0.55, 3, true);
            this.ScheduleTarotCardPlaceHandoff(2.75, 3, false);
        } else if entryId >= 44 && entryId <= 50 {
            npc.SetCvTarotHandProps(true, false, false, false);
            this.m_mistyHoldingDeck = true;
        } else {
            npc.SetCvTarotHandProps(false, false, false, false);
            this.m_mistyHoldingDeck = false;
        }
        this.ApplyRooftopTableState();
        let ws: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(this.GetGameInstance());
        if !IsDefined(ws) || !ws.IsActorInWorkspot(npc) {
            return;
        }
        ws.SendJumpCommandEnt(npc, entryId, instant);
    }

    public final func OnBodyBeatTick(token: Int32, entryId: Int32, instant: Bool) -> Void {
        if token != this.m_lipSyncToken || entryId <= 0 {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        if this.m_pausedByUiMenu {
            let pcb: ref<CrimsonVeilBodyBeatCallback> = new CrimsonVeilBodyBeatCallback();
            pcb.system = this;
            pcb.token = token;
            pcb.entryId = entryId;
            pcb.instant = instant;
            GameInstance.GetDelaySystem(game).DelayCallback(pcb, 0.20, false);
            return;
        }
        let npc: ref<NPCPuppet> = EntityID.IsDefined(this.m_lipSyncEntityId) ? (GameInstance.FindEntityByID(game, this.m_lipSyncEntityId) as NPCPuppet) : null;
        if IsDefined(npc) && !npc.IsDead() {
            this.TriggerNpcBodyGesture(npc, entryId, instant);
        }
    }

    private final func ScheduleBodyBeat(delaySec: Float, entryId: Int32, instant: Bool) -> Void {
        if entryId <= 0 {
            return;
        }
        let cb: ref<CrimsonVeilBodyBeatCallback> = new CrimsonVeilBodyBeatCallback();
        cb.system = this;
        cb.token = this.m_lipSyncToken;
        cb.entryId = entryId;
        cb.instant = instant;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.04, delaySec), false);
    }

    private final func ScheduleNpcBodyChoreography(npc: ref<NPCPuppet>, speakerTag: CName, eventName: CName, duration: Float) -> Void {
        let g1: Int32 = Equals(speakerTag, n"valdes") ? 22 : 21;
        let g2: Int32 = 0;
        let g3: Int32 = 0;
        let t2: Float = -1.00;
        let t3: Float = -1.00;
        let i1: Bool = true;
        let i2: Bool = true;
        let i3: Bool = true;
        if Equals(speakerTag, n"valdes") {
            switch eventName {
                case n"cv_a1_valdes_intro_01":
                    g1 = 21; // be_quiet__01
                    g2 = 33; // stop__neutral__01
                    break;
                case n"cv_a1_valdes_ans_nox9":
                    g1 = 23; // describe_front__01
                    g2 = 27; // nod__respectful__01
                    g3 = 22; // talk__02
                    break;
                case n"cv_a1_valdes_ans_misty":
                    g1 = 24; // describe_left__01
                    g2 = 31; // shrug__01
                    g3 = 28; // nod__respectful__02
                    break;
                case n"cv_a1_valdes_give_trust":
                    g1 = 29; // yes__neutral__01
                    g2 = 34; // come_closer__neutral__01
                    g3 = 25; // describe_right__01
                    break;
                case n"cv_a1_valdes_give_pressure":
                    g1 = 33; // stop__neutral__01
                    g2 = 26; // describe_back__01
                    g3 = 30; // no__neutral__01
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_a1_r2_valdes_intro":
                    g1 = 33; // stop__neutral__01
                    g2 = 21; // be_quiet__01
                    i2 = false;
                    break;
                case n"cv_a1_r2_valdes_ans_role":
                    g1 = 23; // describe_front__01
                    g2 = 31; // shrug__01
                    g3 = 22; // talk__02
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_a1_r2_valdes_ans_sect":
                    g1 = 24; // describe_left__01
                    g2 = 30; // no__neutral__01
                    g3 = 28; // nod__respectful__02
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_a1_r2_valdes_ans_leads":
                    g1 = 25; // describe_right__01
                    g2 = 23; // describe_front__01
                    g3 = 27; // nod__respectful__01
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_a1_r2_valdes_give_trust":
                    g1 = 29; // yes__neutral__01
                    g2 = 34; // come_closer__neutral__01
                    g3 = 25; // describe_right__01
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_a1_r2_valdes_give_pressure":
                    g1 = 33; // stop__neutral__01
                    g2 = 26; // describe_back__01
                    g3 = 30; // no__neutral__01
                    i2 = false;
                    i3 = false;
                    break;
                default:
                    g1 = 22;
                    break;
            }
        } else {
            switch eventName {
                case n"cv_p0_misty_rooftop_01":
                    g1 = 29;
                    g2 = 31;
                    break;
                case n"cv_p0_misty_rooftop_02":
                    g1 = 34;
                    g2 = 37;
                    break;
                case n"cv_p0_misty_ans_chorus":
                    g1 = 21;
                    g2 = 30;
                    g3 = 26;
                    break;
                case n"cv_p0_misty_ans_uv":
                    g1 = 35;
                    g2 = 25;
                    g3 = 27;
                    break;
                case n"cv_p0_misty_tarot_forensic":
                    g1 = 28;
                    g2 = 23;
                    break;
                case n"cv_p0_misty_tarot_symbolic":
                    g1 = 32;
                    g2 = 22;
                    break;
                case n"cv_p0_misty_debrief_01":
                    g1 = 28;
                    g2 = 33;
                    break;
                case n"cv_p0_misty_debrief_02":
                    g1 = 23;
                    g2 = 36;
                    break;
                case n"cv_p0_misty_esoterica_01":
                    g1 = 22;
                    break;
                case n"cv_a1_misty_debrief_stealth":
                    g1 = 31; // yes__head__01
                    g2 = 29; // describe_right__01
                    break;
                case n"cv_a1_misty_debrief_combat":
                    g1 = 33; // yes__sad__02
                    g2 = 25; // rh_flick__01
                    break;
                case n"cv_a1_misty_debrief_badlands":
                    g1 = 28; // describe_down__01
                    g2 = 23; // 2h_flick__03
                    g3 = 22; // talk__neutral__08
                    break;
                case n"cv_a1_misty_cliffhanger":
                    g1 = 37; // what__sad__02
                    g2 = 34; // no__head__01
                    g3 = 26; // rh_flick__02
                    break;
                case n"cv_r2_call_misty_01":
                    g1 = 22; // talk__neutral__08
                    g2 = 35; // nod__sad__01
                    break;
                case n"cv_r2_call_misty_02":
                    g1 = 28; // describe_down__01
                    g2 = 37; // what__sad__02
                    g3 = 26; // rh_flick__02
                    break;
                case n"cv_r2_alley_misty_warn":
                    g1 = 26; // rh_flick__02
                    g2 = 34; // no__head__01
                    break;
                case n"cv_r2_alley_misty_lucia_01":
                    g1 = 33; // yes__sad__02
                    break;
                case n"cv_r2_alley_misty_lucia_02":
                    g1 = 28; // describe_down__01
                    g2 = 37; // what__sad__02
                    g3 = 22; // talk__neutral__08
                    break;
                case n"cv_r2_alley_qa_missing_m":
                    g1 = 37; // what__sad__02
                    g2 = 28; // describe_down__01
                    g3 = 31; // yes__head__01
                    break;
                case n"cv_r2_alley_qa_watched_m":
                    g1 = 29; // describe_right__01
                    g2 = 34; // no__head__01
                    g3 = 25; // rh_flick__01
                    break;
                case n"cv_r2_alley_qa_chorus_m":
                    g1 = 23; // 2h_flick__03
                    g2 = 36; // shrug__neutral__01
                    g3 = 32; // yes__neutral__02
                    break;
                case n"cv_r2_alley_misty_rooftop":
                    g1 = 35; // nod__sad__01
                    g2 = 22; // talk__neutral__08
                    break;
                case n"cv_r2_roof_misty_intro":
                    g1 = 29; // describe_right__01
                    g2 = 31; // yes__head__01
                    break;
                case n"cv_r2_roof_misty_uv":
                    g1 = 28; // describe_down__01
                    g2 = 27; // describe_right__02
                    break;
                case n"cv_r2_debrief_m1":
                    g1 = 32; // yes__neutral__02
                    g2 = 23; // 2h_flick__03
                    t2 = 1.20;
                    i2 = false;
                    break;
                case n"cv_r2_debrief_m2":
                    g1 = 31; // yes__head__01
                    g2 = 22; // talk__neutral__08
                    t2 = 1.20;
                    i2 = false;
                    break;
                case n"cv_r2_roof_open_m1":
                    g1 = 40; // q001_04a shuffle__01 (5.97 s); secuencia nativa id=60 pasa sola a 48
                    break;
                case n"cv_r2_roof_open_m2":
                    g1 = 41; // put_l_card__01 (La Luna)
                    g2 = 42; // put_u_card__01 (El Colgado invertido)
                    g3 = 43; // put_r_card__01 (La Torre); tras 43 la secuencia id=60 pasa sola a 48
                    t2 = 4.35;
                    t3 = 8.75;
                    break;
                case n"cv_r2_roof_open_m3":
                    if this.m_roofReadingActive {
                        this.m_roofCardMoonDealt = true;
                        this.m_roofCardHangmanDealt = true;
                        this.m_roofCardTowerDealt = true;
                        this.ApplyRooftopTableState();
                    }
                    g1 = 44; // describe_cards__01 (3.17 s, espera suave a 43)
                    g2 = 49; // rh_flick__01 (3.63 s en cola tras 44)
                    t2 = 1.80;
                    i1 = false;
                    i2 = false;
                    break;
                case n"cv_r2_roof_chem_m":
                    g1 = 44; // describe_cards__01 (3.17 s)
                    g2 = 50; // rh_flick__03 (4.77 s en cola)
                    t2 = 1.20;
                    i2 = false;
                    break;
                case n"cv_r2_roof_cards_m":
                    g1 = 49; // rh_flick__01 (3.63 s)
                    g2 = 50; // rh_flick__03 (4.77 s en cola)
                    g3 = 44; // describe_cards__01 (3.17 s en cola)
                    t2 = 1.20;
                    t3 = 6.00;
                    i2 = false;
                    i3 = false;
                    break;
                case n"cv_r2_roof_promise_m":
                    g1 = 44; // describe_cards__01 (3.17 s)
                    g2 = 49; // rh_flick__01 (3.63 s en cola)
                    t2 = 1.20;
                    i2 = false;
                    break;
                case n"cv_a2_lucia_intro":
                case n"cv_a2_roof_lucia_greet":
                    g1 = 22; // talk__02
                    g2 = 27; // nod__respectful__01
                    break;
                case n"cv_a2_lucia_a1":
                case n"cv_a2_lucia_a2":
                    g1 = 23; // describe_front__01
                    g2 = 24; // stress_out__01
                    g3 = 22; // talk__02
                    break;
                case n"cv_a2_lucia_adv":
                    g1 = 25; // rh_flick__01
                    g2 = 27; // nod__respectful__01
                    break;
                case n"cv_a2_solis_intro":
                case n"cv_a2_solis_pact":
                    g1 = 31; // calm__01
                    g2 = 25; // rh_flick__01
                    break;
                case n"cv_a2_solis_a1":
                case n"cv_a2_solis_a2":
                case n"cv_a2_solis_a3":
                    g1 = 23; // describe_front__01
                    g2 = 26; // lecture__01
                    g3 = 22; // talk__02
                    break;
                case n"cv_a2_solis_combat":
                    g1 = 33; // stop__neutral__01
                    break;
                default:
                    g1 = 21;
                    break;
            }
        }
        this.m_bodyBeatToken += 1;
        this.ScheduleBodyBeat(0.06, g1, i1);
        if g2 > 0 && duration > 4.20 {
            let effT2: Float = (t2 > 0.00) ? t2 : (g3 > 0 ? (duration * 0.38) : (duration * 0.46));
            this.ScheduleBodyBeat(effT2, g2, i2);
        }
        if g3 > 0 && duration > 7.60 {
            let effT3: Float = (t3 > 0.00) ? t3 : (duration * 0.72);
            this.ScheduleBodyBeat(effT3, g3, i3);
        }
    }

    private final func GetActiveLipSyncBank() -> Int32 {
        let locSys: ref<LocalizationSystem> = LocalizationSystem.GetInstance(this.GetGameInstance());
        if IsDefined(locSys) {
            let lang: CName = locSys.GetVoiceLanguage();
            if Equals(lang, n"es-es") || Equals(lang, n"es-mx") {
                return 1;
            }
        }
        return 2;
    }

    private final func StartNpcLipSync(eventName: CName, speakerTag: CName, entityId: EntityID, duration: Float) -> Void {
        this.StopNpcLipSyncInternal(false);
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let isHoloMisty: Bool = Equals(speakerTag, n"holo_misty");
        let isMisty: Bool = Equals(speakerTag, n"misty");
        let isValdes: Bool = Equals(speakerTag, n"valdes");
        let isLucia: Bool = Equals(speakerTag, n"lucia");
        let isSolis: Bool = Equals(speakerTag, n"solis");
        if isHoloMisty || (!isMisty && !isValdes && !isLucia && !isSolis) || !IsDefined(player) || duration <= 0.15 {
            return;
        }
        let targetId: EntityID = entityId;
        if !EntityID.IsDefined(targetId) || Equals(targetId, player.GetEntityID()) {
            if isValdes && IsDefined(this.m_act01) {
                targetId = this.m_act01.GetValdesEntityID();
            } else if isLucia && IsDefined(this.m_act02) {
                targetId = this.m_act02.GetLuciaEntityID();
            } else if isSolis && IsDefined(this.m_act02) {
                targetId = this.m_act02.GetSolisEntityID();
            } else if isMisty && IsDefined(this.m_act00) {
                targetId = this.m_act00.GetMistyEntityID();
            }
        }
        if !EntityID.IsDefined(targetId) || Equals(targetId, player.GetEntityID()) {
            return;
        }

        this.m_lipSyncToken += 1;
        this.m_lipSyncEntityId = targetId;
        this.m_lipSyncSpeakerTag = speakerTag;
        this.m_lipSyncStepIdx = 0;
        this.m_lipSyncGestureIdx = 0;
        this.m_lipSyncLastLevel = -1;
        this.m_lipSyncRemaining = duration;
        this.m_lipSyncStartedAt = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_lipSyncEnvelope = "";

        let clipId: Int32 = this.ResolveNpcLipSyncClipId(speakerTag, eventName);
        this.m_lipSyncActiveClip = clipId;
        this.m_lipSyncSlot = (this.m_lipSyncSlot == 1) ? 2 : 1;

        let lookRole: Int32 = 0;
        if isValdes {
            lookRole = 1;
        } else if isLucia {
            lookRole = 2;
        } else if isSolis {
            lookRole = 3;
        }

        let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(game, targetId) as NPCPuppet;
        if IsDefined(npc) && !npc.IsDead() {
            this.ApplyMistyFacial(npc, 0, 0);
            if !isHoloMisty {
                this.ApplyNpcLookAt(lookRole, npc, player);
            }
            if clipId > 0 {
                this.ApplyCvLipSync(npc, this.m_lipSyncSlot, this.GetActiveLipSyncBank(), clipId, 1.00);
            }
            this.ScheduleNpcBodyChoreography(npc, speakerTag, eventName, duration);
        }

        let cb: ref<CrimsonVeilLipSyncCallback> = new CrimsonVeilLipSyncCallback();
        cb.system = this;
        cb.token = this.m_lipSyncToken;
        GameInstance.GetDelaySystem(game).DelayCallback(cb, 0.10, false);
    }

    public final func StopNpcLipSync() -> Void {
        this.StopNpcLipSyncInternal(true);
    }

    private final func HasNextStepForSpeaker(speakerTag: CName) -> Bool {
        let nextIdx: Int32 = this.m_currentSpeechIndex + 1;
        return this.m_isPlayingDialogueSequence && nextIdx >= 0 && nextIdx < ArraySize(this.m_speechSteps) && Equals(this.m_speechSteps[nextIdx].speakerTag, speakerTag);
    }

    private final func StopNpcLipSyncInternal(returnBodyToIdle: Bool) -> Void {
        this.m_lipSyncToken += 1;
        this.m_lipSyncRemaining = 0.00;
        this.m_lipSyncActiveClip = 0;
        this.m_lipSyncEnvelope = "";
        this.m_lipSyncLastLevel = -1;
        let isValdes: Bool = Equals(this.m_lipSyncSpeakerTag, n"valdes");
        let isLucia: Bool = Equals(this.m_lipSyncSpeakerTag, n"lucia");
        let isSolis: Bool = Equals(this.m_lipSyncSpeakerTag, n"solis");
        let isGate: Bool = Equals(this.m_lipSyncSpeakerTag, n"gatekeeper");
        let isHoloMisty: Bool = Equals(this.m_lipSyncSpeakerTag, n"holo_misty");
        let lookRole: Int32 = 0;
        if isValdes {
            lookRole = 1;
        } else if isLucia {
            lookRole = 2;
        } else if isSolis {
            lookRole = 3;
        } else if isGate {
            lookRole = 4;
        }
        let game: GameInstance = this.GetGameInstance();
        if returnBodyToIdle {
            if this.m_roofReadingActive {
                this.m_roofReadingActive = false;
                this.m_roofCardMoonDealt = true;
                this.m_roofCardHangmanDealt = true;
                this.m_roofCardTowerDealt = true;
            }
            this.m_mistyHoldingDeck = false;
            this.ApplyRooftopTableState();
        }
        let bank: Int32 = this.GetActiveLipSyncBank();
        if EntityID.IsDefined(this.m_lipSyncEntityId) {
            let npc: ref<NPCPuppet> = GameInstance.FindEntityByID(game, this.m_lipSyncEntityId) as NPCPuppet;
            if IsDefined(npc) && !npc.IsDead() {
                this.ApplyCvLipSync(npc, 0, bank, 0, 0.00);
                this.ApplyMistyFacial(npc, 0, 0);
                let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
                if IsDefined(player) && !isHoloMisty {
                    this.ApplyNpcLookAt(lookRole, npc, player);
                }
                if returnBodyToIdle {
                    npc.SetCvTarotHandProps(false, false, false, false);
                    this.TriggerNpcBodyGesture(npc, 4, true);
                }
            }
        }
        if returnBodyToIdle {
            this.m_lipSyncEntityId = new EntityID();
            this.m_lipSyncSpeakerTag = n"None";
        }
    }

    public final func OnLipSyncTick(token: Int32) -> Void {
        if token != this.m_lipSyncToken {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        if this.m_pausedByUiMenu {
            let pcb: ref<CrimsonVeilLipSyncCallback> = new CrimsonVeilLipSyncCallback();
            pcb.system = this;
            pcb.token = token;
            GameInstance.GetDelaySystem(game).DelayCallback(pcb, 0.12, false);
            return;
        }
        let npc: ref<NPCPuppet> = EntityID.IsDefined(this.m_lipSyncEntityId) ? (GameInstance.FindEntityByID(game, this.m_lipSyncEntityId) as NPCPuppet) : null;
        let simNow: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        let elapsed: Float = MaxF(0.00, simNow - this.m_lipSyncStartedAt);
        let npcDead: Bool = IsDefined(npc) && npc.IsDead();
        if elapsed >= (this.m_lipSyncRemaining - 0.05) || npcDead {
            let keepPose: Bool = !npcDead && this.HasNextStepForSpeaker(this.m_lipSyncSpeakerTag);
            this.StopNpcLipSyncInternal(!keepPose);
            return;
        }
        let cb: ref<CrimsonVeilLipSyncCallback> = new CrimsonVeilLipSyncCallback();
        cb.system = this;
        cb.token = token;
        GameInstance.GetDelaySystem(game).DelayCallback(cb, 0.10, false);
    }

    private final func DebugTestNpcLipSync(isValdes: Bool, clipId: Int32) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if !IsDefined(player) {
            return;
        }
        let npcId: EntityID = isValdes ? (IsDefined(this.m_act01) ? this.m_act01.GetValdesEntityID() : new EntityID()) : (IsDefined(this.m_act00) ? this.m_act00.GetMistyEntityID() : new EntityID());
        let npc: ref<NPCPuppet> = EntityID.IsDefined(npcId) ? (GameInstance.FindEntityByID(game, npcId) as NPCPuppet) : null;
        if !IsDefined(npc) || npc.IsDead() {
            return;
        }
        if clipId <= 0 {
            this.StopNpcLipSyncInternal(true);
            return;
        }
        this.m_lipSyncToken += 1;
        this.m_lipSyncEntityId = npcId;
        this.m_lipSyncSpeakerTag = isValdes ? n"valdes" : n"misty";
        this.m_lipSyncRemaining = 8.00;
        this.m_lipSyncStartedAt = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_lipSyncSlot = (this.m_lipSyncSlot == 1) ? 2 : 1;
        this.m_lipSyncActiveClip = clipId;
        this.ApplyMistyFacial(npc, 0, 0);
        this.ApplyNpcLookAt(isValdes ? 1 : 0, npc, player);
        this.ApplyCvLipSync(npc, this.m_lipSyncSlot, 1, clipId, 1.00);
        let cb: ref<CrimsonVeilLipSyncCallback> = new CrimsonVeilLipSyncCallback();
        cb.system = this;
        cb.token = this.m_lipSyncToken;
        GameInstance.GetDelaySystem(game).DelayCallback(cb, 0.10, false);
    }

    private final func DebugTestNpcGesture(isValdes: Bool, entryId: Int32) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let npcId: EntityID = isValdes ? (IsDefined(this.m_act01) ? this.m_act01.GetValdesEntityID() : new EntityID()) : (IsDefined(this.m_act00) ? this.m_act00.GetMistyEntityID() : new EntityID());
        let npc: ref<NPCPuppet> = EntityID.IsDefined(npcId) ? (GameInstance.FindEntityByID(game, npcId) as NPCPuppet) : null;
        if IsDefined(npc) && !npc.IsDead() {
            this.TriggerNpcBodyGesture(npc, entryId, true);
        }
    }

    public final func DebugTestMistyLipSync(clipId: Int32) -> Void {
        this.DebugTestNpcLipSync(false, clipId);
    }

    public final func DebugTestMistyGesture(entryId: Int32) -> Void {
        this.DebugTestNpcGesture(false, entryId);
    }

    public final func DebugTestValdesLipSync(clipId: Int32) -> Void {
        this.DebugTestNpcLipSync(true, clipId);
    }

    public final func DebugTestValdesGesture(entryId: Int32) -> Void {
        this.DebugTestNpcGesture(true, entryId);
    }

    // --- Guardas de Prólogo, Menús, Banner HUD y Audio ---

    public final func OnPlayerSpawnGraceEnded() -> Void {
        this.m_spawnGraceEnded = true;
    }

    public final func IsDialogActive() -> Bool = this.m_dialogActive;
    public final func IsOurDialogHubIdPublic(id: Int32) -> Bool = id <= -974110 && id >= -974190;
    public final func IsInteractionActive() -> Bool = this.m_interactionShown;
    public final func IsOurInteractionHubId(id: Int32) -> Bool = id == -975501;

    public final func IsInteractionGuardActive() -> Bool {
        return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) < this.m_interactionGuardUntil;
    }

    public final func IsInSystemOrPauseMenu() -> Bool {
        let sysHandler: wref<inkISystemRequestsHandler> = GameInstance.GetSystemRequestsHandler();
        if IsDefined(sysHandler) && (sysHandler.IsPreGame() || sysHandler.IsGamePaused()) {
            return true;
        }
        let uiSystemBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_System);
        return IsDefined(uiSystemBB) && uiSystemBB.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu);
    }

    public final func IsPhoneOverlayOpen() -> Bool {
        let comBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_ComDevice);
        if !IsDefined(comBB) {
            return false;
        }
        let comDef: ref<UI_ComDeviceDef> = GetAllBlackboardDefs().UI_ComDevice;
        return comBB.GetBool(comDef.isDisplayingMessage)
            || comBB.GetBool(comDef.ContactsActive)
            || comBB.GetBool(comDef.SmsMessengerActive);
    }

    public final func IsControllingDevice() -> Bool {
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if !IsDefined(player) {
            return false;
        }
        let tcs: ref<TakeOverControlSystem> = player.GetTakeOverControlSystem();
        return IsDefined(tcs) && tcs.IsDeviceControlled();
    }

    public final func IsUiBlockingWorldInput() -> Bool {
        return this.m_isTarotPopupOpen || this.IsInSystemOrPauseMenu() || this.IsPhoneOverlayOpen() || this.IsControllingDevice();
    }

    public final func IsNativeInteractionHubBlocking() -> Bool {
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if !IsDefined(uiBB) {
            return false;
        }
        let inter: InteractionChoiceHubData = FromVariant<InteractionChoiceHubData>(uiBB.GetVariant(GetAllBlackboardDefs().UIInteractions.InteractionChoiceHub));
        return inter.active && !this.IsOurInteractionHubId(inter.id);
    }

    public final func IsSessionActive(player: ref<PlayerPuppet>) -> Bool {
        return IsDefined(player) && !player.IsReplacer() && CrimsonVeilSessionService.IsSessionReady();
    }

    public final func IsGameplayReady(player: ref<PlayerPuppet>) -> Bool {
        return this.IsSessionActive(player) && !this.IsInSystemOrPauseMenu();
    }

    public final func IsInFullGameplayTier(player: ref<PlayerPuppet>) -> Bool {
        if !IsDefined(player) || !this.m_spawnGraceEnded {
            return false;
        }
        let psmBB: ref<IBlackboard> = player.GetPlayerStateMachineBlackboard();
        if !IsDefined(psmBB) {
            return false;
        }
        return psmBB.GetInt(GetAllBlackboardDefs().PlayerStateMachine.SceneTier) == EnumInt(GameplayTier.Tier1_FullGameplay);
    }

    public final func HasReachedNightCityAct1(player: ref<PlayerPuppet>) -> Bool {
        let game: GameInstance = this.GetGameInstance();
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        if IsDefined(qs) {
            if qs.GetFact(n"cv_force_start") > 0 || qs.GetFact(n"cv_r2_state") > 0 || qs.GetFact(n"cv_a1_state") > 0 || qs.GetFact(n"cv_a2_state") > 0 {
                return true;
            }
        }
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        if !IsDefined(jm) {
            return false;
        }
        let act2Open: Bool = IsDefined(qs) && qs.GetFact(n"q101_done") > 0;
        if !act2Open {
            let qRes: wref<JournalEntry> = jm.GetEntryByString("quests/main_quest/act_01/q101_resurrection", "gameJournalQuest");
            if IsDefined(qRes) && Equals(jm.GetEntryState(qRes), gameJournalEntryState.Succeeded) {
                act2Open = true;
            }
        }
        if !act2Open {
            let act2Paths: array<String> = [
                "quests/main_quest/act_01/q103_afterlife",
                "quests/main_quest/act_01/q104_av",
                "quests/main_quest/act_01/q105_lizzies",
                "quests/main_quest/act_01/q112_parade",
                "quests/main_quest/act_01/q115_afterlife"
            ];
            for qPath in act2Paths {
                let qAct2: wref<JournalEntry> = jm.GetEntryByString(qPath, "gameJournalQuest");
                if IsDefined(qAct2) {
                    let stAct2: gameJournalEntryState = jm.GetEntryState(qAct2);
                    if Equals(stAct2, gameJournalEntryState.Active) || Equals(stAct2, gameJournalEntryState.Succeeded) {
                        act2Open = true;
                        break;
                    }
                }
            }
        }
        if !act2Open || !IsDefined(player) {
            return false;
        }
        let statsSys: ref<StatsSystem> = GameInstance.GetStatsSystem(game);
        if !IsDefined(statsSys) {
            return false;
        }
        let playerLevel: Int32 = Max(1, RoundF(statsSys.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Level)));
        return playerLevel >= 10;
    }

    public final func ShowRelicBannerText(msg: String) -> Void {
        let screenMsg: SimpleScreenMessage;
        screenMsg.isShown = true;
        screenMsg.duration = 5.50;
        screenMsg.message = msg;
        screenMsg.isInstant = false;
        screenMsg.type = SimpleMessageType.Relic;
        let notifBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Notifications);
        if IsDefined(notifBB) {
            notifBB.SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(screenMsg), true);
        }
    }

    public final func ShowRelicBanner(key: CName, fallback: String) -> Void {
        this.ShowRelicBannerText(this.GetLoc(key, fallback));
    }

    public final func SyncAudiowareEngineState(fullSync: Bool) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let locSys: ref<LocalizationSystem> = LocalizationSystem.GetInstance(game);
        if fullSync && IsDefined(locSys) {
            locSys.QueueRequest(UpdateLocaleRequest.Create(n"VoiceOver"));
            locSys.QueueRequest(UpdateLocaleRequest.Create(n"Subtitles"));
            locSys.QueueRequest(UpdateGenderRequest.Create());
        }
        CrimsonVeilAudioBridge.SyncBackendState(game, fullSync);
    }

    public final func PlaySfx(sfxEvent: CName) -> Void {
        let game: GameInstance = this.GetGameInstance();
        this.SyncAudiowareEngineState(false);
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        CrimsonVeilAudioBridge.PlaySfx(game, sfxEvent, player);
    }

    // --- Subtítulos CRUID Paginados (UTF-8 <= 148 chars) y Secuencias de Voz ---

    public final func MakeSpeechStep(eventName: CName, speakerTag: CName, speakerName: CName, lineType: scnDialogLineType, fallbackDur: Float) -> ref<CrimsonVeilSpeechStep> {
        let step: ref<CrimsonVeilSpeechStep> = new CrimsonVeilSpeechStep();
        step.eventName = eventName;
        step.speakerTag = speakerTag;
        step.speakerName = speakerName;
        step.lineType = lineType;
        step.fallbackDuration = fallbackDur;
        return step;
    }

    private final func TrimSubtitleEdges(raw: String) -> String {
        let res: String = raw;
        let len: Int32 = UTF8StrLen(res);
        while len > 0 && Equals(UTF8StrLeft(res, 1), " ") {
            res = UTF8StrRight(res, len - 1);
            len = UTF8StrLen(res);
        }
        while len > 0 && Equals(UTF8StrRight(res, 1), " ") {
            res = UTF8StrLeft(res, len - 1);
            len = UTF8StrLen(res);
        }
        return res;
    }

    private final func PaginateSubtitleText(fullText: String, maxCharsPerPage: Int32) -> array<String> {
        let pages: array<String>;
        let rem: String = this.TrimSubtitleEdges(fullText);
        if Equals(rem, "") {
            return pages;
        }
        let cap: Int32 = Max(60, maxCharsPerPage);
        while UTF8StrLen(rem) > cap {
            let remLen: Int32 = UTF8StrLen(rem);
            let idealSplit: Int32 = remLen <= cap * 2 ? (remLen / 2) : (cap - 15);
            let searchStart: Int32 = Max(20, idealSplit - 48);
            let searchEnd: Int32 = Min(cap, remLen - 16);
            let bestSplit: Int32 = -1;
            let bestDist: Int32 = 9999;
            let i: Int32 = searchStart;
            while i <= searchEnd && i < remLen {
                if Equals(UTF8StrMid(rem, i, 1), " ") {
                    let dist: Int32 = Abs(i - idealSplit);
                    if dist < bestDist {
                        bestDist = dist;
                        bestSplit = i;
                    }
                }
                i += 1;
            }
            if bestSplit <= 0 || bestSplit >= remLen {
                bestSplit = cap;
            }
            let head: String = this.TrimSubtitleEdges(UTF8StrLeft(rem, bestSplit));
            let tail: String = this.TrimSubtitleEdges(UTF8StrRight(rem, remLen - bestSplit));
            if NotEquals(head, "") {
                ArrayPush(pages, head);
            }
            rem = tail;
        }
        if NotEquals(rem, "") {
            ArrayPush(pages, rem);
        }
        return pages;
    }

    private final func ResolveSubtitleText(eventName: CName) -> String {
        let fallback: String = "";
        switch eventName {
            case n"cv_p0_misty_esoterica_01":
                fallback = "Alguien dejó esa Luna manchada antes del alba, V. Espera a la noche y sube conmigo a la azotea.";
                break;
            case n"cv_p0_misty_rooftop_01":
                fallback = "Aquí arriba Night City respira distinto. Gracias por subir cuando el neón apaga el sol, V.";
                break;
            case n"cv_p0_misty_rooftop_02":
                fallback = "Eso no era tinta en La Luna: olía a cobre frío, líquido de diálisis y miedo disfrazado de rito.";
                break;
            case n"cv_p0_v_ask_chorus":
                fallback = "¿Quiénes son exactamente «El Coro Pálido»? ¿Cromados callejeros o una secta nueva?";
                break;
            case n"cv_p0_misty_ans_chorus":
                fallback = "Antiguos biosculptores Exotics y fugados de clínicas negras. Usan colmillos Vampyre y sangre sintética para creerse inmortales.";
                break;
            case n"cv_p0_v_ask_uv":
                fallback = "Espera... mis ópticas leyeron trazas de porfirina reactiva a UV. ¿De verdad les quema la luz?";
                break;
            case n"cv_p0_misty_ans_uv":
                fallback = "Es química rota, no magia. Su diálisis sucia arde bajo luz ultravioleta intensa; recuérdalo si se cruzan contigo.";
                break;
            case n"cv_p0_misty_tarot_forensic":
                fallback = "Frío y clínico, justo como tú. Rastrea los pozos petrolíferos de Northside y tráeme una muestra intacta de ese plasma.";
                break;
            case n"cv_p0_misty_tarot_symbolic":
                fallback = "Aún sabes leer lo que calla la ciudad. Sigue ese hilo carmesí hasta los Pozos Petrolíferos de Northside, pero no bajes la guardia.";
                break;
            case n"cv_p0_v_oilfields_arrive":
                fallback = "Pozos muertos, una bolsa de plasma entre velas y un foco UV industrial montado justo al lado. Toca vigilar las sombras.";
                break;
            case n"cv_p0_vampyre_ambush":
                fallback = "¡La noche pertenece al Coro, intruso! ¡Derrama tu sangre en el polvo o arrodíllate ante el Velo!";
                break;
            case n"cv_p0_v_uv_hint":
                fallback = "Maldición... ¡se están regenerando en la oscuridad! ¡Sobrecarga ese Emisor UV ahora mismo!";
                break;
            case n"cv_p0_v_sample_taken":
                fallback = "Vial de plasma sintético asegurado. Misty tiene que ver estos datos arriba en su azotea.";
                break;
            case n"cv_p0_misty_debrief_01":
                fallback = "Mira estas lecturas de porfirina... Es peor que superstición: alguien prueba el Proyecto NOX-9 en los márgenes de Watson.";
                break;
            case n"cv_p0_misty_debrief_02":
                fallback = "Quédate esta hoja y tu paga, V. Cuando las sombras vuelvan a cerrarse sobre los almacenes, volveré a llamarte.";
                break;
            case n"cv_a1_v_kabuki_arrive":
                fallback = "Descartes clínicos tirados junto al canal de Kabuki... Toca revisar la zona sin alertar a nadie todavía.";
                break;
            case n"cv_a1_v_clue_blood":
                fallback = "Un refrigerador portátil con sellos de Biotechnica raspados... Lleva estabilizadores de porfirina sintética.";
                break;
            case n"cv_a1_v_clue_tarot":
                fallback = "La Sacerdotisa invertida clavada entre cirios. En el reverso hay una licencia médica anulada en Little China.";
                break;
            case n"cv_a1_v_clue_relay":
                fallback = "El relé triangular sigue activo: apunta a un callejón escondido en Little China. Doctor Adrián Valdés.";
                break;
            case n"cv_a1_valdes_intro_01":
                fallback = "¡Silencio, baja la mano y escúchame! Si el Coro Pálido te hubiera enviado, ya estaría muerto... ¿Tú qué quieres?";
                break;
            case n"cv_a1_v_ask_nox9":
                fallback = "Vengo por el Proyecto NOX-9, doctor. Explícame qué mete esa gente en la sangre y cómo romper sus implantes.";
                break;
            case n"cv_a1_valdes_ans_nox9":
                fallback = "Fue un suero militar de Biotechnica para supervivencia en penumbra. En la calle lo corrompieron: regenera carne de noche, pero estalla bajo luz UV a 365 nm.";
                break;
            case n"cv_a1_v_ask_misty":
                fallback = "¿Y el teatro del Tarot? Están dejando cartas manchadas junto a la tienda de una amiga en Little China.";
                break;
            case n"cv_a1_valdes_ans_misty":
                fallback = "Eso no sé explicarlo con ciencia... En diálisis profunda dibujan Arcanos y oyen un coro desde un búnker en las Badlands. «La Cantora» cree que esa tienda resuena igual.";
                break;
            case n"cv_a1_valdes_give_trust":
                fallback = "Gracias por oírme antes de disparar. En el muelle oeste usan el santo y seña «La sombra bebe antes del alba». Úsalo y saca el manifiesto sin ruido.";
                break;
            case n"cv_a1_valdes_give_pressure":
                fallback = "¡Basta, te daré todo! Vigilan el muelle oeste con dos torres ultravioleta. Su contraseña es «La sombra bebe antes del alba». Déjame desaparecer después.";
                break;
            case n"cv_a1_v_valdes_depart":
                fallback = "Ya tengo su clave y el punto de descarga en el muelle oeste. Vamos a ver qué esconde el Coro Pálido.";
                break;
            case n"cv_a1_v_pier_arrive":
                fallback = "Puesto criogénico en el muelle y dos focos UV listos para barrer el cemento... puedo colarme con la clave o abrir fuego.";
                break;
            case n"cv_a1_gate_challenge":
                fallback = "Alto ahí, carne tibia. Nadie cruza el muelle criogénico de noche sin cantar el velo de La Cantora.";
                break;
            case n"cv_a1_v_gate_bluff":
                fallback = "La sombra bebe antes del alba. Me envía el doctor Valdés para revisar el manifiesto del relevo nocturno.";
                break;
            case n"cv_a1_gate_bluff_ok":
                fallback = "Que el frío te guarde, iniciado. El terminal del fondo sigue abierto para el relevo, pero no toques los tanques.";
                break;
            case n"cv_a1_gate_hostile":
                fallback = "¡Intruso en el embarcadero! ¡Sellad las válvulas y arrancadle hasta la última gota!";
                break;
            case n"cv_a1_v_manifest_taken":
                fallback = "Mierda... El manifiesto apunta a las Badlands y marca la tienda de Misty como «Nexo de Silencio». Tengo que avisarle ya.";
                break;
            case n"cv_a1_misty_debrief_stealth":
                fallback = "Sentí que volvías en calma, V. Lograste arrancarle sus secretos al Coro sin derramar más sangre en el muelle.";
                break;
            case n"cv_a1_misty_debrief_combat":
                fallback = "Vi el resplandor violeta recortar la niebla sobre el puerto, V. Me alivia tenerte de pie otra vez bajo mis faroles.";
                break;
            case n"cv_a1_misty_debrief_badlands":
                fallback = "Este manifiesto une a Biotechnica con las cartas de El Diablo y La Muerte. Toma esta pistola silenciada y tus edis para lo que viene.";
                break;
            case n"cv_a1_misty_cliffhanger":
                fallback = "Espera... los sueños del patio no hablan solo de química. Si «La Cantora» viene a por mi tienda, nos veremos en las Badlands.";
                break;
            case n"cv_r2_call_misty_01":
                fallback = "¿V? Gracias a Dios que coges. Necesito que vengas al callejón trasero de Esoterica en cuanto puedas.";
                break;
            case n"cv_r2_call_v_01":
                fallback = "¿Misty? Suenas asustada. ¿Ha pasado algo en la tienda?";
                break;
            case n"cv_r2_call_misty_02":
                fallback = "Varias amigas y vecinos del barrio llevan días desapareciendo sin dejar rastro, y siento que alguien me vigila. Esta mañana encontré un extraño altar delante de la puerta: media docena de cirios derretidos por la humedad y una sola carta del Tarot cubierta por una mancha oscura.";
                break;
            case n"cv_r2_call_v_02":
                fallback = "No dejes entrar a nadie y quédate donde pueda verte. Voy para Watson ahora mismo.";
                break;
            case n"cv_r2_alley_misty_warn":
                fallback = "No la toques todavía, V. Escanéala primero. La dejaron de noche, antes del alba, sin que nadie viera quién fue.";
                break;
            case n"cv_r2_alley_v_scan":
                fallback = "No es sangre normal, Misty. Es hemoglobina sintética mezclada con un estabilizador experimental, y tiene una traza altísima de porfirinas reactivas. Quien sangró sobre esta carta sufriría quemaduras internas graves si le diera el sol directo.";
                break;
            case n"cv_r2_alley_misty_lucia_01":
                fallback = "Es de Lucía.";
                break;
            case n"cv_r2_alley_v_lucia_01":
                fallback = "¿La chica del abrigo verde que a veces barre tu escaparate?";
                break;
            case n"cv_r2_alley_misty_lucia_02":
                fallback = "Sí. Mira la esquina inferior izquierda, donde alguien hizo dos muescas minúsculas con una uña. Se lo enseñé el mes pasado, cuando me dijo que tenía pesadillas y no podía dormir. Jugábamos a que cada Arcano era una palabra secreta. La Luna significa: «Estoy despierta en la oscuridad, pero no puedo salir a la luz». Lleva tres noches sin aparecer por su pensión de Kabuki.";
                break;
            case n"cv_r2_alley_v_candles":
                fallback = "Si alguien dejó esto aquí, no fue un simple secuestro de carroñeros. Los carroñeros no dejan velas ni cartas del Tarot. ¿Qué más sabes sobre las otras desapariciones?";
                break;
            case n"cv_r2_alley_qa_missing_v":
                fallback = "Dijiste por teléfono que había más desaparecidos antes que Lucía. ¿Quiénes son?";
                break;
            case n"cv_r2_alley_qa_missing_m":
                fallback = "Mateo, un técnico nocturno del muelle de Northside, desapareció tres días antes que Lucía. Empezó a evitar la luz del día y no volvió tras decir que exigiría su historial médico. Antes que él faltaron otros dos jóvenes del barrio.";
                break;
            case n"cv_r2_alley_qa_watched_v":
                fallback = "¿Por qué dices que alguien te está vigilando desde la calle?";
                break;
            case n"cv_r2_alley_qa_watched_m":
                fallback = "Dos madrugadas seguidas aparcó un furgón negro sin matrícula frente al callejón, con las luces apagadas. Y anoche alguien inutilizó las farolas de esta acera justo antes de dejar los cirios.";
                break;
            case n"cv_r2_alley_qa_chorus_v":
                fallback = "¿Lucía llegó a darte algún nombre o clínica antes de desaparecer?";
                break;
            case n"cv_r2_alley_qa_chorus_m":
                fallback = "Solo me dijo que aceptó un tratamiento nocturno gratuito en una clínica satélite para curarse los pulmones del smog. A la semana siguiente temía al amanecer y susurraba algo sobre El Coro Pálido.";
                break;
            case n"cv_r2_alley_misty_rooftop":
                fallback = "Sube conmigo a la azotea cuando anochezca del todo. Abajo hay demasiado ruido y demasiados ojos. A las diez te enseño todo lo que Lucía me contó antes de desaparecer.";
                break;
            case n"cv_r2_alley_v_rooftop":
                fallback = "De acuerdo. Quédate a cubierto dentro. Nos vemos en la azotea a las diez.";
                break;
            case n"cv_r2_roof_misty_intro":
                fallback = "Gracias por subir a tiempo, V. He extendido las cartas junto a los apuntes de Lucía: La Luna, El Ermitaño y La Torre. Si alguien se la llevó tras dejar esa señal, no está lejos de Watson.";
                break;
            case n"cv_r2_roof_misty_uv":
                fallback = "Mira bajo esta lámpara ultravioleta de trescientos sesenta y cinco nanómetros. En el reverso de La Luna hay un sello químico de trasvase que apunta a los depósitos petrolíferos de Northside.";
                break;
            case n"cv_r2_roof_v_depart":
                fallback = "Depósitos de Northside, de noche y sin testigos. Voy para allá a buscar a Lucía antes de que la muevan.";
                break;
            case n"cv_r2_oil_v_arrive":
                fallback = "Veo el santuario improvisado entre los tanques y un emisor ultravioleta cubriendo la entrada. Voy a apagar ese foco y limpiar el perímetro.";
                break;
            case n"cv_r2_oil_misty_radio":
                fallback = "V, detecto un pico eléctrico en tus ópticas. Rompe la caja del emisor si te cierran el paso y revisa las cajas médicas que dejaron junto al altar.";
                break;
            case n"cv_r2_oil_v_note":
                fallback = "Un vial clínico vacío de plasma NOX-9 y un recibo de transporte rasgado de esta misma madrugada: Sujeto L-14, Lucía Reyes, trasladarla antes del relevo del muelle. Sigue viva, Misty. Vuelvo a la azotea con las pruebas.";
                break;
            case n"cv_r2_debrief_m1":
                fallback = "¿Sigue viva? Gracias al cielo, V. Ver el código de su lote médico y ese recibo confirma que no llegamos tarde.";
                break;
            case n"cv_r2_debrief_v1":
                fallback = "Los secuestradores la sacaron antes del alba, pero dejaron atrás un cargamento de plasma NOX-9 y esta pistola modificada con cargador de luz fría. Quien fabrique ese compuesto nos llevará directo hasta Lucía y Mateo.";
                break;
            case n"cv_r2_debrief_m2":
                fallback = "Toma tus edis y guarda ese arma cerca. Quédate el archivo del códice actualizado y descansa un momento; en cuanto descifremos quién firma el lote NOX-9 iremos a por Lucía.";
                break;
            case n"cv_r2_roof_open_m1":
                fallback = "Gracias por venir a las diez, V. Aquí arriba la lluvia apaga el ruido de abajo y nadie escucha.";
                break;
            case n"cv_r2_roof_open_m2":
                fallback = "Lucía me pidió que le leyera estas cartas la última vez que subió: La Luna, El Colgado invertido y La Torre. En sus apuntes hablaba de El Coro Pálido, gente que se oculta de la luz cerca de Northside.";
                break;
            case n"cv_r2_roof_open_m3":
                fallback = "Me preguntó si uno puede entregar algo de sí mismo para no morir solo en esta ciudad... Ojalá hubiera entendido entonces que no me hablaba de una metáfora.";
                break;
            case n"cv_r2_roof_chem_v":
                fallback = "Misty, no es ningún hechizo ni un pacto de Tarot. Es química sucia: hemoglobina sintética y porfirinas reactivas que hierven bajo los rayos ultravioleta.";
                break;
            case n"cv_r2_roof_chem_m":
                fallback = "Lo sé, V... pero quienes aceptan esa sangre no solo buscan huir de la enfermedad. Buscan pertenecer a algo que no los descarte al amanecer, y ahí es donde esa secta los atrapa.";
                break;
            case n"cv_r2_roof_cards_v":
                fallback = "Dime cómo conectabas estos tres arcanos con sus cuadernos: La Luna, El Colgado invertido y La Torre.";
                break;
            case n"cv_r2_roof_cards_m":
                fallback = "La Luna es el secreto nocturno que Lucía ya guardaba en su piel. El Colgado invertido es la promesa de renacer pagando un sacrificio en silencio. Y La Torre... es la caída cuando esa falsa salvación se derrumba.";
                break;
            case n"cv_r2_roof_tower_v":
                fallback = "Espera, Misty, dale la vuelta a La Torre. La cera del borde tiene gravilla aceitosa y residuo petroquímico... esto viene directo de los depósitos abandonados de Northside.";
                break;
            case n"cv_r2_roof_promise_m":
                fallback = "Si te cruzas con ellos en Northside, recuerda la luz ultravioleta. Tráeme pruebas de que Lucía sigue viva, V... no dejes que se convierta en otra sombra más del Coro.";
                break;
            case n"cv_a1_r2_call_m1":
                fallback = "V, ¿tienes un segundo? Le pasé a Vik el código del lote NOX-9-K4 y el recibo de Lucía que sacaste de Northside. Un viejo contacto suyo cruzó esa fórmula con patentes retiradas de Biotechnica: el único hematólogo que diseñó y firmó ese compuesto es un tal doctor Adrián Valdés.";
                break;
            case n"cv_a1_r2_call_v1":
                fallback = "¿Y ese Valdés trabaja para El Coro Pálido o se esconde de ellos? Si firmó la fórmula del lote, sabrá quién se llevó a Lucía y a Mateo.";
                break;
            case n"cv_a1_r2_call_m2":
                fallback = "Justo hace unos minutos saltó un pulso de telemetría del mismo lote NOX-9-K4 junto a un embarcadero abandonado del Canal de Kabuki. Ve a revisar lo que hayan tirado allí: seguro que nos lleva directo hasta Valdés antes de que el Coro borre su rastro.";
                break;
            case n"cv_a1_r2_call_v2":
                fallback = "Voy para el Canal de Kabuki ahora mismo. Si Valdés sigue en Watson, lo voy a encontrar.";
                break;
            case n"cv_a1_r2_kabuki_arrive":
                fallback = "Embarcadero de desagüe en el Canal de Kabuki... Ahí están los descartes médicos, las velas y un relé todavía encendido. Vamos a revisar cada pista.";
                break;
            case n"cv_a1_r2_clue_cooler":
                fallback = "Un refrigerador de diálisis portátil con sellos de Biotechnica raspados. Dentro hay matraces vacíos del lote NOX-9-K4 y etiquetas de dosificación para el Sujeto L-14, Lucía Reyes, y el Sujeto M-09, Mateo. Esta es la misma fórmula de Valdés.";
                break;
            case n"cv_a1_r2_clue_tarot":
                fallback = "La Sacerdotisa invertida clavada entre cirios húmedos... y grapada al reverso está la licencia médica anulada del doctor Adrián Valdés. No es un altar cualquiera: El Coro Pálido la dejó aquí como amenaza para demostrarle que saben que sigue en Watson.";
                break;
            case n"cv_a1_r2_clue_relay":
                fallback = "Este relé de telemetría de Biotechnica sigue caliente y rebotando señal. Acaba de triangular el retorno hacia un callejón escondido en Little China. Ya tengo el escondite exacto del doctor Valdés.";
                break;
            case n"cv_a1_r2_valdes_intro":
                fallback = "¡Quieto, no des un paso más! Si te envía La Cantora para callarme, dispara de una vez y acaba con esto.";
                break;
            case n"cv_a1_r2_v_intro":
                fallback = "Baja el pulso, doctor Valdés. No vengo del Coro Pálido. Vengo por el lote NOX-9-K4 de Northside... y por Lucía Reyes y Mateo. Sabemos que tú firmaste esa fórmula.";
                break;
            case n"cv_a1_r2_v_ask_role":
                fallback = "Empieza por tu papel en todo esto. ¿Qué es exactamente el NOX-9 y por qué lleva tu firma de Biotechnica?";
                break;
            case n"cv_a1_r2_valdes_ans_role":
                fallback = "Diseñé el NOX-9 hace seis años para salvar a trabajadores con pulmones destrozados por el smog sin condenarlos a pagar implantes corporativos. Aumentaba el oxígeno en sangre y regeneraba tejido, pero acumulaba porfirinas letales: cualquier luz solar o ultravioleta de 365 nm te abrasa por dentro. Biotechnica enterró el proyecto y me echó a la calle. Arruinado, le vendí mis patentes y muestras a la doctora Helena Solís creyendo que terminaría la cura.";
                break;
            case n"cv_a1_r2_v_ask_sect":
                fallback = "¿Y cómo acabó tu suero médico en manos de una secta que deja cartas del Tarot y caza gente de noche?";
                break;
            case n"cv_a1_r2_valdes_ans_sect":
                fallback = "Helena Solís se hace llamar ahora La Cantora y convirtió mi fracaso en El Coro Pálido. Atraen a chicos desesperados como Lucía y Mateo con clínicas nocturnas gratuitas, los vuelven dependientes de diálisis semanales y usan el pánico al amanecer como jaula y liturgia. Yo... seguí fabricándoles estabilizadores durante meses por culpa y por miedo a que me mataran. Cuando descubrí que secuestraban a quien intentaba dejarlo, escapé aquí. Por eso dejaron La Sacerdotisa invertida en Kabuki: para recordarme que me vigilan.";
                break;
            case n"cv_a1_r2_v_ask_leads":
                fallback = "Si les preparabas estabilizadores, sabes adónde trasladaron a Lucía desde Northside y dónde tienen a Mateo.";
                break;
            case n"cv_a1_r2_valdes_ans_leads":
                fallback = "Todos los sujetos recién despertados y los registros de traslado pasan antes por su puesto criogénico del Muelle Oeste de Watson, custodiado por un centinela nocturno y dos torres ultravioleta. Desde ese terminal coordinan los envíos hacia el búnker central de Helena en las Badlands, donde dice haber purificado una segunda generación del suero sin porfirinas: el NOX-9B.";
                break;
            case n"cv_a1_r2_v_trust":
                fallback = "Aún puedes arreglar parte del daño, Adrián. Dame tus claves, las coordenadas del muelle y tus notas del NOX-9. Voy a sacar a Lucía y a Mateo de ahí.";
                break;
            case n"cv_a1_r2_valdes_give_trust":
                fallback = "Gracias por escucharme antes de juzgarme. Toma este pincho de la mesa: lleva la contraseña del relevo nocturno, «La sombra bebe antes del alba», las coordenadas del terminal criogénico del Muelle Oeste y mi expediente completo sobre el NOX-9 y el NOX-9B. Úsalo para entrar sin alertar a las torres si puedes.";
                break;
            case n"cv_a1_r2_v_pressure":
                fallback = "Tu arrepentimiento no va a sacar a Lucía de una cámara criogénica. Dame la clave del muelle y todo lo que tengas sobre Solís ahora mismo.";
                break;
            case n"cv_a1_r2_valdes_give_pressure":
                fallback = "¡Está bien, llévatelo todo! En ese pincho de la mesa tienes el santo y seña nocturno, «La sombra bebe antes del alba», las coordenadas del Muelle Oeste y mis archivos del NOX-9 y el NOX-9B. Solo déjame desaparecer antes de que el Coro baje por este callejón.";
                break;
            case n"cv_a1_r2_v_depart":
                fallback = "Pincho cifrado en mi poder: clave nocturna del Coro, coordenadas del Muelle Oeste de Watson y expediente completo de Valdés sobre Solís y el NOX-9B. Ya tenemos todo para golpear el puesto criogénico.";
                break;
            case n"cv_a1_r2_debrief_m1_stealth":
                fallback = "Has vuelto de una pieza, V... y sin dejar otro rastro de pólvora en el puerto. La contraseña de Valdés funcionó. Dime qué sacaste de ese terminal del Muelle Oeste.";
                break;
            case n"cv_a1_r2_debrief_m1_combat":
                fallback = "Vi los destellos violetas sobre el puerto desde aquí arriba, V. Me alegra tenerte de vuelta y a salvo. Dime qué sacaste de ese terminal del Muelle Oeste.";
                break;
            case n"cv_a1_r2_debrief_v1":
                fallback = "Ya tenemos el mapa completo, Misty. El doctor Adrián Valdés creó el NOX-9 hace seis años, pero la doctora Helena Solís —la que llaman La Cantora— le robó el proyecto para montar El Coro Pálido. El manifiesto del muelle confirma que sacaron a Lucía Reyes y a Mateo de Watson rumbo a un búnker clausurado de Biotechnica en las Badlands.";
                break;
            case n"cv_a1_r2_debrief_m2":
                fallback = "Entonces Lucía y Mateo siguen vivos, pero fuera de la ciudad... Espera, V: ¿qué es esta nota al final del manifiesto? Han marcado Misty's Esoterica como «Nexo de Silencio» y con vigilancia prioritaria. Saben que estamos tirando del hilo desde aquí.";
                break;
            case n"cv_a1_r2_debrief_v2":
                fallback = "Y todavía hay algo más peligroso. Según las notas de Valdés y los registros de carga, en ese búnker del desierto Solís está probando una segunda versión del suero llamada NOX-9B, sin porfirinas. Si consigue estabilizarlo, dejarán de arder con la luz ultravioleta y perderemos la única ventaja táctica que tenemos contra ellos.";
                break;
            case n"cv_a1_r2_debrief_m3":
                fallback = "No podemos dejar que terminen ese suero ni que nos encierren aquí. Voy a reforzar la tienda con Vik y a cruzar estas frecuencias del manifiesto para triangular la entrada exacta del búnker en las Badlands. Toma tus edis por lo que has hecho hoy, V. En cuanto descifremos la ruta, te llamaré para cruzar al desierto, rescatar a Lucía y a Mateo y detener a La Cantora de una vez por todas.";
                break;
            case n"cv_a1_r2_debrief_v3":
                fallback = "Mantén la persiana bajada y ten el móvil cerca, Misty. En cuanto tengas las coordenadas del búnker, nos vemos en las Badlands y acabamos con El Coro Pálido.";
                break;
            case n"cv_a2_call_m1":
                fallback = "V, ya tenemos las coordenadas. Vik y yo cruzamos las balizas del manifiesto del Muelle Oeste con los repetidores del sur.";
                break;
            case n"cv_a2_call_v1":
                fallback = "¿Dónde descargaron a Lucía? ¿Seguimos a tiempo antes de que estabilicen el NOX-9B?";
                break;
            case n"cv_a2_call_m2":
                fallback = "El convoy se detuvo por última vez en un punto de servicio de Biotechnica Flats antes de entrar al búnker clausurado de La Cantora. Ve allí y triangula el acceso.";
                break;
            case n"cv_a2_call_v2":
                fallback = "Salgo hacia Biotechnica Flats ahora mismo. Tú no abras la tienda hasta que te avise, Misty.";
                break;
            case n"cv_a2_flats_arrive":
                fallback = "Zona de servicio en mitad de Biotechnica Flats... Ahí está el equipo criogénico descartado del convoy. Veamos qué dejaron atrás.";
                break;
            case n"cv_a2_clue_pod":
                fallback = "Cápsula de traslado con código L-14, Lucía Reyes... Está abierta y limpia por dentro, y las pruebas de carga marcan lotes nuevos de NOX-9B.";
                break;
            case n"cv_a2_clue_mateo":
                fallback = "Una placa de técnico de Northside partida y otra carta de La Luna... Mateo M-09 intentó sabotear el convoy para ayudar a escapar a Lucía, y Helena Solís lo ejecutó aquí mismo.";
                break;
            case n"cv_a2_clue_relay":
                fallback = "Este repetidor de microondas aún conserva el enlace del búnker: un kilómetro al noreste, bajo la antigua estación geotérmica de Biotechnica. Vamos a por ellas.";
                break;
            case n"cv_a2_bunker_arrive":
                fallback = "La estación geotérmica de las Badlands... El Coro Pálido vigila la entrada exterior con otra torre UV. Habrá que abrirse paso hasta Lucía.";
                break;
            case n"cv_a2_lucia_intro":
                fallback = "¿V? ¡Sabía que Misty descifraría las dos muescas en la carta de La Luna! Creía que nadie saldría a buscarme tan lejos de Watson.";
                break;
            case n"cv_a2_v_lucia_intro":
                fallback = "Misty removió media ciudad para encontrarte, Lucía. Estás fuera de peligro por ahora, pero antes dime todo lo que pasa ahí abajo.";
                break;
            case n"cv_a2_v_lucia_q1":
                fallback = "Encontré la placa de Mateo en Biotechnica Flats. Dime la verdad sobre lo que ocurrió durante el traslado.";
                break;
            case n"cv_a2_lucia_a1":
                fallback = "Mateo descubrió que no nos estaban curando, sino convirtiéndonos en cobayas dependientes del suero. Cortó los cables criogénicos en mitad del desierto para que yo pudiera huir, pero Solís lo abatió delante de mí y borró su expediente.";
                break;
            case n"cv_a2_v_lucia_q2":
                fallback = "¿En qué punto está exactamente ese suero NOX-9B que prepara Helena Solís ahí abajo?";
                break;
            case n"cv_a2_lucia_a2":
                fallback = "Lo tiene al noventa y ocho por ciento en el biorreactor inferior. Si termina la síntesis, El Coro Pálido dejará de ser vulnerable a la luz ultravioleta. Además, quiere silenciar la tienda de Misty porque la considera un puente de conciencia con sus pacientes.";
                break;
            case n"cv_a2_v_lucia_adv":
                fallback = "Ponte a cubierto detrás del perímetro exterior y espera mi señal. Bajo ahora mismo a enfrentarme a La Cantora.";
                break;
            case n"cv_a2_lucia_adv":
                fallback = "Ten cuidado abajo, V: Solís tiene dos guardias y focos ultravioleta en la terraza del reactor. Si nos ves vivos en la azotea de Misty, por fin seremos libres.";
                break;
            case n"cv_a2_solis_intro":
                fallback = "Así que tú eres la sombra de Misty Olszewski. Pensé que Adrián Valdés enviaría a un asesino corporativo, no a alguien que aún cree en rescates románticos.";
                break;
            case n"cv_a2_v_solis_q1":
                fallback = "Valdés empezó el NOX-9 para curar pulmones, Solís. Tú lo convertiste en una secta y mataste a Mateo cuando intentó huir.";
                break;
            case n"cv_a2_solis_a1":
                fallback = "Biotechnica quería dejar morir a los pobres de Watson cuando no podían pagar implantes. Yo les di regeneración real y comunidad en la noche. Mateo rompió nuestro juramento de silencio y puso en riesgo a todo el Coro.";
                break;
            case n"cv_a2_v_solis_q2":
                fallback = "Explícame el NOX-9B. ¿De verdad quita las porfirinas o solo es otra correa química más cara?";
                break;
            case n"cv_a2_solis_a2":
                fallback = "El NOX-9B elimina la fototoxicidad a trescientos sesenta y cinco nanómetros y estabiliza la sangre sin depender de diálisis semanales. Quien controle esta fórmula podrá caminar al sol… o elegir a quién deja atrás en las sombras.";
                break;
            case n"cv_a2_v_solis_q3":
                fallback = "¿Y qué demonios pinta Misty Olszewski en tus manifiestos? ¿Por qué ordenaste vigilar Esoterica como Nexo de Silencio?";
                break;
            case n"cv_a2_solis_a3":
                fallback = "Porque Lucía usó sus cartas del Tarot para comunicarse fuera del Coro y porque esa tienda recuerda a mis acólitos la vida que abandonaron. Bajar de la torre empieza por cerrar todas las puertas del pasado.";
                break;
            case n"cv_a2_v_end_cure":
                fallback = "No vas a negociar con la sangre de nadie más, Solís. Me llevo intacta la fórmula del NOX-9B para Valdés y saco a Lucía de aquí hoy mismo.";
                break;
            case n"cv_a2_solis_combat":
                fallback = "¡Entonces arderás entre el acero del Coro Pálido! ¡Cerrad las compuertas del reactor y no dejéis que toque el núcleo!";
                break;
            case n"cv_a2_v_end_pact":
                fallback = "Hagamos un trato rápido y sucio: liberas a Lucía, entregas dosis de emergencia y borras Misty's Esoterica de tus redes para siempre. A cambio, sigo de largo.";
                break;
            case n"cv_a2_solis_pact":
                fallback = "Sabia elección en Night City. Watson queda fuera de nuestros registros y Lucía puede irse con su amiga. Pero no vuelvas a cruzar nuestra sombra.";
                break;
            case n"cv_a2_v_end_burn":
                fallback = "Esta cámara muere aquí contigo, Cantora. Voy a calcinar hasta la última probeta del NOX-9B y borrar El Coro Pálido del mapa.";
                break;
            case n"cv_a2_v_core_secured":
                fallback = "Fórmula depurada NOX-9B descargada y encriptada para Adrián Valdés y Misty. Hora de volver a Watson con Lucía.";
                break;
            case n"cv_a2_v_core_destroyed":
                fallback = "Biorreactor purgado y archivos reducidos a ceniza. Ya no fabricarán más cadenas químicas desde aquí. Volvamos con Misty.";
                break;
            case n"cv_a2_roof_lucia_greet":
                fallback = "No sé cómo darte las gracias, V. Volver a oír la lluvia de Little China sin temer al próximo amanecer parecía imposible hasta hoy.";
                break;
            case n"cv_a2_roof_misty_cure":
                fallback = "Vik ya está revisando tu fórmula del NOX-9B junto al doctor Valdés desde la distancia. Por primera vez, Lucía y los demás tienen esperanza real de volver a caminar bajo el sol.";
                break;
            case n"cv_a2_roof_misty_pact":
                fallback = "Lucía está a salvo bajo mi techo y Watson ha quedado fuera del alcance de Solís. Sé que el Coro seguirá oculto en otros distritos, pero hoy salvaste a quien podíamos salvar.";
                break;
            case n"cv_a2_roof_misty_burn":
                fallback = "Arrancaste ese laboratorio de raíz y nadie volverá a atrapar chicos desesperados bajo tierra. Tardaremos tiempo en limpiar el suero de la sangre de Lucía, pero al menos ya nadie la persigue.";
                break;
            case n"cv_a2_roof_misty_epilogue":
                fallback = "Cuando volvamos a abrir Esoterica mañana, La Luna sobre esa mesa ya no será una llamada de socorro en la oscuridad. Toma este revólver Alba Carmesí y tu paga, V: Mateo no murió en vano.";
                break;
            case n"cv_a2_roof_v_close":
                fallback = "Cuídate en el barrio, Lucía, y cierra bien cuando caiga la noche, Misty. Si El Coro Pálido vuelve a sacar cabeza en Night City, ya sabes qué número marcar.";
                break;
            default:
                fallback = "";
        }
        return this.GetLoc(eventName, fallback);
    }

    private final func CancelSpeechSequenceTimer() -> Void {
        if NotEquals(this.m_speechSeqDelayId, GetInvalidDelayID()) {
            GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_speechSeqDelayId);
            this.m_speechSeqDelayId = GetInvalidDelayID();
        }
        this.m_speechSeqRemaining = 0.00;
        this.m_speechSeqExpectedDur = 0.00;
    }

    private final func CancelSpeechSubtitleTimer() -> Void {
        if NotEquals(this.m_speechSubDelayId, GetInvalidDelayID()) {
            GameInstance.GetDelaySystem(this.GetGameInstance()).CancelCallback(this.m_speechSubDelayId);
            this.m_speechSubDelayId = GetInvalidDelayID();
        }
        this.m_speechSubRemaining = 0.00;
        this.m_speechSubExpectedDur = 0.00;
    }

    private final func EmitSpeechSubtitleDialogLine(cruid: CRUID, pageText: String, pageDur: Float) -> Void {
        let game: GameInstance = this.GetGameInstance();
        if !IsDefined(this.m_speechSubtitleSpeakerObj) {
            this.m_speechSubtitleSpeakerObj = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as GameObject;
        }
        if !IsDefined(this.m_speechSubtitleSpeakerObj) {
            return;
        }
        let line: scnDialogLineData;
        line.id = cruid;
        line.duration = MaxF(0.25, pageDur);
        line.isPersistent = false;
        line.speaker = this.m_speechSubtitleSpeakerObj;
        line.speakerName = this.m_speechSubtitleSpeakerName;
        line.text = pageText;
        line.type = this.m_speechSubtitleLineType;

        let lines: array<scnDialogLineData>;
        ArrayPush(lines, line);
        let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UIGameData);
        if IsDefined(board) {
            board.SetVariant(GetAllBlackboardDefs().UIGameData.ShowDialogLine, ToVariant(lines), true);
        }
    }

    public final func ReassertActiveSpeechSubtitleIfNeeded(token: Int32, expectedCruid: CRUID) -> Void {
        if token != this.m_speechSubtitleToken || this.m_pausedByUiMenu || !this.m_hasActiveSpeechSubtitle || NotEquals(this.m_activeSpeechSubtitleCruid, expectedCruid) {
            return;
        }
        if this.m_speechSubCurrentPageIdx >= 0 && this.m_speechSubCurrentPageIdx < ArraySize(this.m_speechSubtitlePages) {
            this.EmitSpeechSubtitleDialogLine(expectedCruid, this.m_speechSubtitlePages[this.m_speechSubCurrentPageIdx], MaxF(0.25, this.m_speechSubExpectedDur));
        }
    }

    private final func HideCurrentSpeechSubtitleElementOnly() -> Void {
        if !this.m_hasActiveSpeechSubtitle {
            return;
        }
        let board: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIGameData);
        if IsDefined(board) {
            let hideIds: array<CRUID>;
            ArrayPush(hideIds, this.m_activeSpeechSubtitleCruid);
            board.SetVariant(GetAllBlackboardDefs().UIGameData.HideDialogLine, ToVariant(hideIds), true);
        }
        this.m_hasActiveSpeechSubtitle = false;
    }

    public final func HideActiveSpeechStepSubtitle() -> Void {
        this.CancelSpeechSubtitleTimer();
        this.m_speechSubtitleToken += 1;
        this.m_speechSubCurrentPageIdx = -1;
        ArrayClear(this.m_speechSubtitlePages);
        ArrayClear(this.m_speechSubtitlePageDurs);
        this.HideCurrentSpeechSubtitleElementOnly();
    }

    public final func AdvanceSpeechSubtitlePage(token: Int32, pageIndex: Int32) -> Void {
        if token != this.m_speechSubtitleToken {
            return;
        }
        this.m_speechSubDelayId = GetInvalidDelayID();
        this.HideCurrentSpeechSubtitleElementOnly();
        if pageIndex >= ArraySize(this.m_speechSubtitlePages) {
            this.m_speechSubCurrentPageIdx = -1;
            ArrayClear(this.m_speechSubtitlePages);
            ArrayClear(this.m_speechSubtitlePageDurs);
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let pageDur: Float = (pageIndex < ArraySize(this.m_speechSubtitlePageDurs)) ? this.m_speechSubtitlePageDurs[pageIndex] : 3.00;
        let schedDelay: Float = MaxF(0.25, pageDur + 0.06);
        this.m_speechSubCurrentPageIdx = pageIndex;
        if this.m_pausedByUiMenu {
            this.m_speechSubRemaining = schedDelay;
            this.m_speechSubExpectedDur = schedDelay;
            return;
        }
        this.m_speechSubtitleSeq += 1ul;
        this.m_activeSpeechSubtitleCruid = CreateCRUID(9741100000ul + this.m_speechSubtitleSeq);
        this.m_hasActiveSpeechSubtitle = true;
        this.EmitSpeechSubtitleDialogLine(this.m_activeSpeechSubtitleCruid, this.m_speechSubtitlePages[pageIndex], pageDur);

        let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
        if IsDefined(ds) {
            if pageIndex == 0 {
                let rCb: ref<CrimsonVeilSpeechSubtitleReassertCallback> = new CrimsonVeilSpeechSubtitleReassertCallback();
                rCb.system = this;
                rCb.token = token;
                rCb.expectedCruid = this.m_activeSpeechSubtitleCruid;
                ds.DelayCallback(rCb, 0.08, false);
            }
            let subCb: ref<CrimsonVeilSpeechSubtitleCallback> = new CrimsonVeilSpeechSubtitleCallback();
            subCb.system = this;
            subCb.token = token;
            subCb.nextPageIndex = pageIndex + 1;
            this.m_speechSubExpectedDur = schedDelay;
            this.m_speechSubScheduledSimAt = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            this.m_speechSubRemaining = schedDelay;
            this.m_speechSubDelayId = ds.DelayCallback(subCb, schedDelay, false);
        }
    }

    private final func ShowSpeechStepSubtitle(step: ref<CrimsonVeilSpeechStep>, speakerEntity: EntityID, resolvedSpeaker: CName, player: ref<PlayerPuppet>, duration: Float) -> Void {
        this.HideActiveSpeechStepSubtitle();
        let subText: String = this.ResolveSubtitleText(step.eventName);
        if Equals(subText, "") || !IsDefined(player) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let speakerObj: wref<GameObject> = EntityID.IsDefined(speakerEntity) ? (GameInstance.FindEntityByID(game, speakerEntity) as GameObject) : null;
        if !IsDefined(speakerObj) {
            speakerObj = player;
        }
        let pages: array<String> = this.PaginateSubtitleText(subText, 144);
        let count: Int32 = ArraySize(pages);
        if count == 0 {
            return;
        }
        let totalDur: Float = MaxF(0.60, duration);
        let durs: array<Float>;
        if count == 1 {
            ArrayPush(durs, totalDur);
        } else {
            let totalChars: Int32 = 0;
            let k: Int32 = 0;
            while k < count {
                totalChars += Max(1, UTF8StrLen(pages[k]));
                k += 1;
            }
            let elapsed: Float = 0.00;
            k = 0;
            while k < count - 1 {
                let share: Float = totalDur * (Cast<Float>(Max(1, UTF8StrLen(pages[k]))) / Cast<Float>(Max(1, totalChars)));
                let clamped: Float = MaxF(1.00, MinF(share, totalDur - elapsed - Cast<Float>(count - 1 - k) * 0.90));
                ArrayPush(durs, clamped);
                elapsed += clamped;
                k += 1;
            }
            ArrayPush(durs, MaxF(0.90, totalDur - elapsed));
        }

        this.m_speechSubtitleToken += 1;
        this.m_speechSubtitlePages = pages;
        this.m_speechSubtitlePageDurs = durs;
        this.m_speechSubtitleSpeakerObj = speakerObj;
        this.m_speechSubtitleSpeakerName = NameToString(resolvedSpeaker);
        this.m_speechSubtitleLineType = scnDialogLineType.Regular;
        this.AdvanceSpeechSubtitlePage(this.m_speechSubtitleToken, 0);
    }

    public final func StopCurrentSpeechAudio() -> Void {
        this.StopCurrentSpeechAudioInternal(true);
    }

    private final func StopCurrentSpeechAudioInternal(returnBodyToIdle: Bool) -> Void {
        this.CancelSpeechSequenceTimer();
        this.HideActiveSpeechStepSubtitle();
        this.StopNpcLipSyncInternal(returnBodyToIdle);
        if IsNameValid(this.m_currentPlayingEvent) && NotEquals(this.m_currentPlayingEvent, n"None") {
            CrimsonVeilAudioBridge.StopSpeech(
                this.GetGameInstance(),
                this.m_currentPlayingBackend,
                this.m_currentPlayingEvent,
                this.m_currentPlayingVariant,
                this.m_currentPlayingEntity,
                this.m_currentPlayingSpeaker
            );
        }
        this.m_currentPlayingEvent = n"None";
        this.m_currentPlayingEntity = new EntityID();
        this.m_currentPlayingSpeaker = n"None";
        this.m_currentPlayingBackend = 0;
        this.m_currentPlayingVariant = n"None";
    }

    private final func SetSkipSpeechHintVisible(show: Bool) -> Void {
        if Equals(this.m_skipHintVisible, show) {
            return;
        }
        this.m_skipHintVisible = show;
        let data: InputHintData;
        data.action = n"Choice1";
        data.source = n"CrimsonVeil";
        data.localizedLabel = this.GetLoc(n"cv_hint_skip_line", "Skip line");
        data.queuePriority = 10;
        data.sortingPriority = 10;
        SendInputHintData(this.GetGameInstance(), show, data);
    }

    public final func IsSkippableSpeechPlaying() -> Bool {
        return this.m_isPlayingDialogueSequence && this.m_speechAllowManualSkip && !this.m_dialogActive;
    }

    public final func IsSpeechBlockingWorldInteraction() -> Bool {
        return this.m_isPlayingDialogueSequence && this.m_speechActionOnComplete != 0;
    }

    public final func InterruptAmbientFieldSpeech() -> Void {
        if !this.m_isPlayingDialogueSequence || this.m_speechActionOnComplete != 0 {
            return;
        }
        this.m_speechToken += 1;
        this.StopCurrentSpeechAudio();
        this.SetSkipSpeechHintVisible(false);
        this.m_isPlayingDialogueSequence = false;
        this.m_speechAllowManualSkip = false;
    }

    public final func SkipCurrentSpeechStep() -> Bool {
        if !this.m_isPlayingDialogueSequence || !this.m_speechAllowManualSkip {
            return false;
        }
        let game: GameInstance = this.GetGameInstance();
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        if now < this.m_speechSkipBlockedUntil || (now - this.m_speechStepStartedAt) < 0.45 {
            return true;
        }
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
            GameObject.PlaySoundEvent(player, n"ui_menu_hover");
        }
        this.StopCurrentSpeechAudio();
        this.m_speechToken += 1;
        this.m_interactionGuardUntil = now + 0.65;
        this.AdvanceSpeechSequence(this.m_speechToken, this.m_currentSpeechIndex + 1);
        return true;
    }

    public final func StartSpeechSequence(steps: array<ref<CrimsonVeilSpeechStep>>, actionOnComplete: Int32) -> Void {
        this.SyncAudiowareEngineState(false);
        this.m_speechToken += 1;
        this.m_speechSteps = steps;
        this.m_speechActionOnComplete = actionOnComplete;
        if actionOnComplete != 0 {
            this.m_pendingPostSpeechAction = 0;
        }
        this.m_isPlayingDialogueSequence = true;
        this.m_speechAllowManualSkip = actionOnComplete > 0;
        this.StopCurrentSpeechAudio();
        if !this.m_speechAllowManualSkip {
            this.SetSkipSpeechHintVisible(false);
        }
        this.HideDialogChoices();
        if actionOnComplete != 0 {
            this.HideWorldInteraction();
        }
        this.AdvanceSpeechSequence(this.m_speechToken, 0);
    }

    public final func AdvanceSpeechSequence(token: Int32, index: Int32) -> Void {
        if token != this.m_speechToken {
            return;
        }
        this.m_speechSeqDelayId = GetInvalidDelayID();
        this.m_speechSeqRemaining = 0.00;
        this.m_speechSeqExpectedDur = 0.00;
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if !IsDefined(player) {
            this.StopCurrentSpeechAudio();
            this.SetMistyCallSpeakingState(false);
            this.SetSkipSpeechHintVisible(false);
            this.m_isPlayingDialogueSequence = false;
            this.m_speechAllowManualSkip = false;
            return;
        }

        if index >= ArraySize(this.m_speechSteps) {
            this.m_currentPlayingEvent = n"None";
            this.SetMistyCallSpeakingState(false);
            this.StopNpcLipSync();
            this.SetSkipSpeechHintVisible(false);
            this.m_isPlayingDialogueSequence = false;
            this.m_speechAllowManualSkip = false;
            let completedAction: Int32 = this.m_speechActionOnComplete;
            this.m_speechActionOnComplete = 0;
            if completedAction != 0 {
                this.m_interactionGuardUntil = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + 0.65;
                if this.IsUiBlockingWorldInput() {
                    this.m_pendingPostSpeechAction = completedAction;
                    return;
                }
                if completedAction == 1 || completedAction == 101 || completedAction == 201 {
                    this.EndMistyIntroCall();
                }
                if completedAction >= 200 {
                    if IsDefined(this.m_act02) {
                        this.m_act02.OnPostSpeech(completedAction);
                    }
                } else if completedAction >= 100 {
                    if IsDefined(this.m_act01) {
                        this.m_act01.OnPostSpeech(completedAction);
                    }
                } else if IsDefined(this.m_act00) {
                    this.m_act00.OnPostSpeech(completedAction);
                }
            }
            return;
        }

        let step: ref<CrimsonVeilSpeechStep> = this.m_speechSteps[index];
        let speakerEntity: EntityID = player.GetEntityID();
        let resolvedSpeaker: CName = step.speakerName;
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if Equals(step.speakerTag, n"misty") && IsDefined(this.m_act00) {
            let mistyId: EntityID = this.m_act00.GetMistyEntityID();
            if EntityID.IsDefined(mistyId) && IsDefined(des) && des.IsSpawned(mistyId) {
                speakerEntity = mistyId;
            }
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_misty", "Misty Olszewski"));
        } else if Equals(step.speakerTag, n"valdes") {
            if IsDefined(this.m_act01) {
                let valdesId: EntityID = this.m_act01.GetValdesEntityID();
                if EntityID.IsDefined(valdesId) && IsDefined(des) && des.IsSpawned(valdesId) {
                    speakerEntity = valdesId;
                }
            }
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_valdes", "Dr. Adrián Valdés"));
        } else if Equals(step.speakerTag, n"lucia") {
            if IsDefined(this.m_act02) {
                let luciaId: EntityID = this.m_act02.GetLuciaEntityID();
                if EntityID.IsDefined(luciaId) && IsDefined(des) && des.IsSpawned(luciaId) {
                    speakerEntity = luciaId;
                }
            }
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_lucia", "Lucía Reyes"));
        } else if Equals(step.speakerTag, n"solis") {
            if IsDefined(this.m_act02) {
                let solisId: EntityID = this.m_act02.GetSolisEntityID();
                if EntityID.IsDefined(solisId) && IsDefined(des) && des.IsSpawned(solisId) {
                    speakerEntity = solisId;
                }
            }
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_solis", "Dra. Helena Solís"));
        } else if Equals(step.speakerTag, n"gatekeeper") {
            if IsDefined(this.m_act01) {
                let gateId: EntityID = this.m_act01.GetGatekeeperEntityID();
                if EntityID.IsDefined(gateId) && IsDefined(des) && des.IsSpawned(gateId) {
                    speakerEntity = gateId;
                }
            }
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_gatekeeper", "Centinela del Coro Pálido"));
        } else if Equals(step.speakerTag, n"holo_misty") || Equals(step.speakerTag, n"phone") {
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_misty", "Misty Olszewski"));
        } else if Equals(step.speakerTag, n"v_narr") || Equals(step.speakerTag, n"v") {
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_v", "V"));
        } else if Equals(step.speakerTag, n"vampyre") {
            resolvedSpeaker = StringToName(this.GetLoc(n"cv_spk_vampyre", "Acólito del Coro Pálido"));
        }

        let keepPoseForNext: Bool = (Equals(step.speakerTag, this.m_lipSyncSpeakerTag) && EntityID.IsDefined(this.m_lipSyncEntityId)) || (this.m_roofReadingActive && Equals(step.speakerTag, n"misty"));
        this.StopCurrentSpeechAudioInternal(!keepPoseForNext);
        this.m_currentSpeechIndex = index;
        let simNow: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_speechStepStartedAt = simNow;
        this.m_currentPlayingEvent = step.eventName;
        this.m_currentPlayingEntity = speakerEntity;
        this.m_currentPlayingSpeaker = resolvedSpeaker;

        let playedVariant: CName = n"None";
        let backendUsed: Int32 = CrimsonVeilAudioBridge.PlaySpeech(game, step.eventName, speakerEntity, resolvedSpeaker, player, playedVariant);
        this.m_currentPlayingBackend = backendUsed;
        this.m_currentPlayingVariant = playedVariant;
        let isMistyTalkingInCall: Bool = Equals(step.speakerTag, n"holo_misty") || Equals(step.speakerTag, n"phone");
        this.SetMistyCallSpeakingState(isMistyTalkingInCall);
        this.SetSkipSpeechHintVisible(this.m_speechAllowManualSkip && !this.IsPhoneOverlayOpen());

        let dur: Float = CrimsonVeilAudioBridge.ResolveSpeechDuration(game, step.eventName, speakerEntity, backendUsed, playedVariant, step.fallbackDuration);
        this.ShowSpeechStepSubtitle(step, speakerEntity, resolvedSpeaker, player, dur);
        let lipTargetId: EntityID = Equals(step.speakerTag, n"holo_misty") ? new EntityID() : speakerEntity;
        this.StartNpcLipSync(step.eventName, step.speakerTag, lipTargetId, dur);

        let waitDur: Float = MaxF(0.45, dur + ((index + 1 < ArraySize(this.m_speechSteps)) ? 0.55 : 0.35));
        if this.m_pausedByUiMenu {
            this.m_speechSeqRemaining = waitDur;
            this.m_speechSeqExpectedDur = waitDur;
            return;
        }
        let cb: ref<CrimsonVeilSequenceCallback> = new CrimsonVeilSequenceCallback();
        cb.system = this;
        cb.token = token;
        cb.nextIndex = index + 1;
        this.m_speechSeqExpectedDur = waitDur;
        this.m_speechSeqScheduledSimAt = simNow;
        this.m_speechSeqRemaining = waitDur;
        this.m_speechSeqDelayId = GameInstance.GetDelaySystem(game).DelayCallback(cb, waitDur, false);
    }

    protected cb func OnUiMenuChanged(inMenu: Bool) -> Bool {
        if Equals(this.m_pausedByUiMenu, inMenu) {
            return true;
        }
        this.m_pausedByUiMenu = inMenu;
        if !this.m_isPlayingDialogueSequence {
            return true;
        }
        let game: GameInstance = this.GetGameInstance();
        let ds: ref<DelaySystem> = GameInstance.GetDelaySystem(game);
        let simNow: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        if inMenu {
            if NotEquals(this.m_speechSeqDelayId, GetInvalidDelayID()) {
                let seqRem: Float = IsDefined(ds) ? ds.GetRemainingDelayTime(this.m_speechSeqDelayId) : 0.00;
                if seqRem <= 0.05 {
                    seqRem = MaxF(0.25, this.m_speechSeqExpectedDur - (simNow - this.m_speechSeqScheduledSimAt));
                }
                this.m_speechSeqRemaining = seqRem;
                if IsDefined(ds) {
                    ds.CancelCallback(this.m_speechSeqDelayId);
                }
                this.m_speechSeqDelayId = GetInvalidDelayID();
            }
            if NotEquals(this.m_speechSubDelayId, GetInvalidDelayID()) {
                let subRem: Float = IsDefined(ds) ? ds.GetRemainingDelayTime(this.m_speechSubDelayId) : 0.00;
                if subRem <= 0.05 {
                    subRem = MaxF(0.25, this.m_speechSubExpectedDur - (simNow - this.m_speechSubScheduledSimAt));
                }
                this.m_speechSubRemaining = subRem;
                if IsDefined(ds) {
                    ds.CancelCallback(this.m_speechSubDelayId);
                }
                this.m_speechSubDelayId = GetInvalidDelayID();
            }
            this.HideCurrentSpeechSubtitleElementOnly();
        } else {
            if Equals(this.m_speechSeqDelayId, GetInvalidDelayID()) && IsDefined(ds) {
                let resumeSeq: Float = MaxF(0.25, this.m_speechSeqRemaining > 0.05 ? this.m_speechSeqRemaining : 1.00);
                this.m_speechStepStartedAt = simNow - MaxF(0.00, this.m_speechSeqExpectedDur - resumeSeq);
                this.m_speechSeqScheduledSimAt = simNow;
                let cb: ref<CrimsonVeilSequenceCallback> = new CrimsonVeilSequenceCallback();
                cb.system = this;
                cb.token = this.m_speechToken;
                cb.nextIndex = this.m_currentSpeechIndex + 1;
                this.m_speechSeqDelayId = ds.DelayCallback(cb, resumeSeq, false);
            }
            if this.m_speechSubCurrentPageIdx >= 0 && this.m_speechSubCurrentPageIdx < ArraySize(this.m_speechSubtitlePages) && Equals(this.m_speechSubDelayId, GetInvalidDelayID()) && IsDefined(ds) {
                let resumeSub: Float = MaxF(0.25, this.m_speechSubRemaining > 0.05 ? this.m_speechSubRemaining : 1.00);
                this.m_speechSubtitleSeq += 1ul;
                this.m_activeSpeechSubtitleCruid = CreateCRUID(9741100000ul + this.m_speechSubtitleSeq);
                this.m_hasActiveSpeechSubtitle = true;
                this.EmitSpeechSubtitleDialogLine(this.m_activeSpeechSubtitleCruid, this.m_speechSubtitlePages[this.m_speechSubCurrentPageIdx], resumeSub);
                this.m_speechSubScheduledSimAt = simNow;
                this.m_speechSubExpectedDur = resumeSub;
                let subCb: ref<CrimsonVeilSpeechSubtitleCallback> = new CrimsonVeilSpeechSubtitleCallback();
                subCb.system = this;
                subCb.token = this.m_speechSubtitleToken;
                subCb.nextPageIndex = this.m_speechSubCurrentPageIdx + 1;
                this.m_speechSubDelayId = ds.DelayCallback(subCb, resumeSub, false);
            }
            this.SetSkipSpeechHintVisible(this.m_speechAllowManualSkip && !this.IsPhoneOverlayOpen());
        }
        return true;
    }

    // --- Cuadros de Diálogo Nativos e Interacciones [F] ---

    private final func NextDialogHubId() -> Int32 {
        this.m_dialogHubSeqId -= 1;
        if this.m_dialogHubSeqId < -974190 || this.m_dialogHubSeqId > -974110 {
            this.m_dialogHubSeqId = -974110;
        }
        return this.m_dialogHubSeqId;
    }

    public final func MakeDialogChoice(caption: String, isQuestYellow: Bool, disabled: Bool) -> ListChoiceData {
        let c: ListChoiceData;
        c.localizedName = caption;
        if disabled {
            ChoiceTypeWrapper.SetType(c.type, gameinteractionsChoiceType.Inactive);
        } else if isQuestYellow {
            ChoiceTypeWrapper.SetType(c.type, gameinteractionsChoiceType.QuestImportant);
        } else {
            ChoiceTypeWrapper.SetType(c.type, gameinteractionsChoiceType.Selected);
        }
        c.inputActionName = n"None";
        return c;
    }

    public final func PushDialogHub(ownerTag: CName, title: String, choices: array<ListChoiceData>, optionIds: array<Int32>) -> Void {
        let game: GameInstance = this.GetGameInstance();
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UIInteractions);
        if !IsDefined(uiBB) {
            return;
        }
        let hubDef: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
        let hubId: Int32 = this.NextDialogHubId();
        let hub: ListChoiceHubData;
        hub.id = hubId;
        hub.activityState = EVisualizerActivityState.Active;
        hub.flags = EVisualizerDefinitionFlags.None;
        hub.isPhoneLockActive = false;
        hub.title = title;
        hub.choices = choices;

        let container: DialogChoiceHubs;
        ArrayPush(container.choiceHubs, hub);

        let visInfo: VisualizersInfo;
        visInfo.activeVisId = hubId;
        ArrayPush(visInfo.visIds, hubId);

        let nowSim: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        this.m_dialogOpenedAt = nowSim;
        this.m_lastDialogReopenAt = nowSim;
        this.m_dialogConfirmArmed = false;
        this.m_dialogSelectedIdx = 0;
        this.m_dialogOptionIds = optionIds;
        this.m_dialogOptionCount = ArraySize(choices);
        this.m_dialogOwnerTag = ownerTag;
        this.m_cachedDialogHubs = container;
        this.m_dialogActive = true;

        uiBB.SetInt(hubDef.SelectedIndex, -1, false);
        uiBB.SetVariant(hubDef.DialogChoiceHubs, ToVariant(container), true);
        uiBB.SetInt(hubDef.ActiveChoiceHubID, hubId, true);
        uiBB.SetInt(hubDef.SelectedIndex, 0, true);
        uiBB.SetVariant(hubDef.VisualizersInfo, ToVariant(visInfo), true);

        if IsDefined(this.m_dialogWidgetCtrl) {
            this.m_dialogWidgetCtrl.CvSyncAndReveal(ToVariant(container), hubId, 0);
        }
    }

    public final func HideDialogChoices() -> Void {
        if !this.m_dialogActive {
            return;
        }
        this.m_dialogActive = false;
        this.m_dialogConfirmArmed = false;
        this.m_dialogOwnerTag = n"None";
        this.m_dialogOptionCount = 0;
        ArrayClear(this.m_dialogOptionIds);
        ArrayClear(this.m_cachedDialogHubs.choiceHubs);

        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if IsDefined(uiBB) {
            let hubDef: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
            let existing: DialogChoiceHubs = FromVariant<DialogChoiceHubs>(uiBB.GetVariant(hubDef.DialogChoiceHubs));
            let activeId: Int32 = uiBB.GetInt(hubDef.ActiveChoiceHubID);
            if (ArraySize(existing.choiceHubs) > 0 && this.IsOurDialogHubIdPublic(existing.choiceHubs[0].id)) || this.IsOurDialogHubIdPublic(activeId) {
                let empty: DialogChoiceHubs;
                let visInfo: VisualizersInfo;
                visInfo.activeVisId = -1;
                uiBB.SetVariant(hubDef.DialogChoiceHubs, ToVariant(empty), true);
                uiBB.SetInt(hubDef.ActiveChoiceHubID, -1, true);
                uiBB.SetInt(hubDef.SelectedIndex, -1, true);
                uiBB.SetVariant(hubDef.VisualizersInfo, ToVariant(visInfo), true);
            }
        }
        if IsDefined(this.m_dialogWidgetCtrl) {
            this.m_dialogWidgetCtrl.CvForceClose();
        }
    }

    public final func SelectDialogChoiceIndex(idx: Int32) -> Bool {
        if !this.m_dialogActive || idx < 0 || idx >= this.m_dialogOptionCount {
            return false;
        }
        this.m_dialogSelectedIdx = idx;
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if IsDefined(uiBB) {
            uiBB.SetInt(GetAllBlackboardDefs().UIInteractions.SelectedIndex, this.m_dialogSelectedIdx, true);
        }
        if IsDefined(this.m_dialogWidgetCtrl) {
            this.m_dialogWidgetCtrl.OnDialogsSelectIndex(this.m_dialogSelectedIdx);
            this.m_dialogWidgetCtrl.CvEnsureVisible();
        }
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
            GameObject.PlaySoundEvent(player, n"ui_menu_hover");
        }
        return true;
    }

    public final func MoveDialogSelection(delta: Int32) -> Bool {
        if !this.m_dialogActive || this.m_dialogOptionCount <= 1 {
            return false;
        }
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
        if (now - this.m_lastDialogNavAt) < 0.06 {
            return true;
        }
        this.m_lastDialogNavAt = now;
        let nextIdx: Int32 = this.m_dialogSelectedIdx + delta;
        if nextIdx < 0 {
            nextIdx = this.m_dialogOptionCount - 1;
        } else if nextIdx >= this.m_dialogOptionCount {
            nextIdx = 0;
        }
        return this.SelectDialogChoiceIndex(nextIdx);
    }

    private final func IsExternalDialogHubBlocking(existing: DialogChoiceHubs, uiBB: ref<IBlackboard>, hubDef: ref<UIInteractionsDef>) -> Bool {
        if ArraySize(existing.choiceHubs) == 0 {
            return false;
        }
        let firstHub: ListChoiceHubData = existing.choiceHubs[0];
        if this.IsOurDialogHubIdPublic(firstHub.id) {
            return false;
        }
        let activeId: Int32 = uiBB.GetInt(hubDef.ActiveChoiceHubID);
        return Equals(firstHub.activityState, EVisualizerActivityState.Active) && activeId == firstHub.id;
    }

    public final func ScheduleDelayedPostAction(actionId: Int32, delaySeconds: Float) -> Void {
        if actionId == 0 {
            return;
        }
        let cb: ref<CrimsonVeilDelayedActionCallback> = new CrimsonVeilDelayedActionCallback();
        cb.system = this;
        cb.actionId = actionId;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.05, delaySeconds), false);
    }

    public final func ExecuteDelayedPostAction(actionId: Int32) -> Void {
        if actionId == 0 {
            return;
        }
        if this.IsUiBlockingWorldInput() || this.m_isPlayingDialogueSequence {
            this.m_pendingPostSpeechAction = actionId;
            return;
        }
        if actionId >= 100 {
            if IsDefined(this.m_act01) {
                this.m_act01.OnPostSpeech(actionId);
            }
        } else if IsDefined(this.m_act00) {
            this.m_act00.OnPostSpeech(actionId);
        }
    }

    private final func EnsureActiveDialogHubVisible() -> Void {
        if !this.m_dialogActive || this.m_pausedByUiMenu || this.IsUiBlockingWorldInput() {
            return;
        }
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if !IsDefined(uiBB) {
            return;
        }
        let hubDef: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
        let existing: DialogChoiceHubs = FromVariant<DialogChoiceHubs>(uiBB.GetVariant(hubDef.DialogChoiceHubs));
        if this.IsExternalDialogHubBlocking(existing, uiBB, hubDef) {
            return;
        }
        let curHubId: Int32 = this.m_dialogHubSeqId;
        let hasOurHub: Bool = ArraySize(existing.choiceHubs) > 0 && existing.choiceHubs[0].id == curHubId;
        let activeOk: Bool = uiBB.GetInt(hubDef.ActiveChoiceHubID) == curHubId;
        let visuallyOk: Bool = !IsDefined(this.m_dialogWidgetCtrl) || this.m_dialogWidgetCtrl.CvIsVisuallyOpen();
        if hasOurHub && activeOk && visuallyOk {
            return;
        }
        if ArraySize(this.m_cachedDialogHubs.choiceHubs) > 0 && IsDefined(this.m_dialogWidgetCtrl) {
            if !hasOurHub || !activeOk {
                let visInfo: VisualizersInfo;
                visInfo.activeVisId = curHubId;
                ArrayPush(visInfo.visIds, curHubId);
                uiBB.SetVariant(hubDef.DialogChoiceHubs, ToVariant(this.m_cachedDialogHubs), false);
                uiBB.SetInt(hubDef.ActiveChoiceHubID, curHubId, false);
                uiBB.SetInt(hubDef.SelectedIndex, this.m_dialogSelectedIdx, false);
                uiBB.SetVariant(hubDef.VisualizersInfo, ToVariant(visInfo), false);
            }
            if !visuallyOk {
                this.m_dialogWidgetCtrl.CvSyncAndReveal(ToVariant(this.m_cachedDialogHubs), curHubId, this.m_dialogSelectedIdx);
            } else {
                this.m_dialogWidgetCtrl.CvEnsureVisible();
            }
        }
    }

    public final func OnDialogConfirmPressed() -> Void {
        if !this.m_dialogActive {
            return;
        }
        if IsDefined(this.m_dialogWidgetCtrl) && !this.m_dialogWidgetCtrl.CvIsVisuallyOpen() && ArraySize(this.m_cachedDialogHubs.choiceHubs) > 0 {
            this.m_dialogWidgetCtrl.CvSyncAndReveal(ToVariant(this.m_cachedDialogHubs), this.m_dialogHubSeqId, this.m_dialogSelectedIdx);
        }
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
        if (now - this.m_dialogOpenedAt) >= 0.16 {
            this.m_dialogConfirmArmed = true;
        }
    }

    public final func ConfirmSelectedDialogChoice() -> Bool {
        if !this.m_dialogActive || this.m_dialogSelectedIdx < 0 || this.m_dialogSelectedIdx >= ArraySize(this.m_dialogOptionIds) {
            return false;
        }
        let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
        if !this.m_dialogConfirmArmed || (now - this.m_dialogOpenedAt) < 0.16 {
            return true;
        }
        this.m_dialogConfirmArmed = false;
        this.m_speechSkipBlockedUntil = now + 0.55;
        let ownerTag: CName = this.m_dialogOwnerTag;
        let optionId: Int32 = this.m_dialogOptionIds[this.m_dialogSelectedIdx];
        this.HideDialogChoices();
        this.StopCurrentSpeechAudio();
        if IsDefined(this.m_act00) && this.m_act00.HandleDialogOption(ownerTag, optionId) {
            return true;
        }
        if IsDefined(this.m_act01) && this.m_act01.HandleDialogOption(ownerTag, optionId) {
            return true;
        }
        if IsDefined(this.m_act02) && this.m_act02.HandleDialogOption(ownerTag, optionId) {
            return true;
        }
        return false;
    }

    public final func ShowWorldInteraction(kind: Int32, titleKey: CName, titleFallback: String, actionKey: CName, actionFallback: String, isTalkIcon: Bool, opt forceOverride: Bool) -> Void {
        if this.IsInteractionGuardActive() {
            this.HideWorldInteraction();
            return;
        }
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if !IsDefined(uiBB) {
            return;
        }
        let hubDef: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
        let existing: InteractionChoiceHubData = FromVariant<InteractionChoiceHubData>(uiBB.GetVariant(hubDef.InteractionChoiceHub));
        if existing.active && !this.IsOurInteractionHubId(existing.id) && !forceOverride {
            this.m_interactionShown = false;
            return;
        }
        if this.m_interactionShown && existing.active && this.IsOurInteractionHubId(existing.id) && this.m_interactionKind == kind {
            return;
        }

        let choice: InteractionChoiceData;
        choice.inputAction = n"Choice1";
        choice.rawInputKey = EInputKey.IK_F;
        choice.isHoldAction = false;
        choice.localizedName = this.GetLoc(actionKey, actionFallback);
        ChoiceTypeWrapper.SetType(choice.type, gameinteractionsChoiceType.QuestImportant);
        let iconRecord: wref<ChoiceCaptionIconPart_Record>;
        if isTalkIcon {
            iconRecord = TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.TalkIcon");
        }
        if !IsDefined(iconRecord) {
            iconRecord = TweakDBInterface.GetChoiceCaptionIconPartRecord(t"ChoiceCaptionParts.UseIcon");
        }
        if IsDefined(iconRecord) {
            InteractionChoiceCaption.AddPartFromRecord(choice.captionParts, iconRecord);
        }

        let data: InteractionChoiceHubData;
        data.id = -975501;
        data.active = true;
        data.flags = EVisualizerDefinitionFlags.None;
        data.title = this.GetLoc(titleKey, titleFallback);
        ArrayPush(data.choices, choice);

        let visInfo: VisualizersInfo;
        visInfo.activeVisId = -975501;
        ArrayPush(visInfo.visIds, -975501);

        uiBB.SetVariant(hubDef.InteractionChoiceHub, ToVariant(data), true);
        uiBB.SetVariant(hubDef.VisualizersInfo, ToVariant(visInfo), true);
        this.m_interactionShown = true;
        this.m_interactionKind = kind;
    }

    public final func HideWorldInteraction() -> Void {
        if !this.m_interactionShown {
            return;
        }
        this.m_interactionShown = false;
        this.m_interactionKind = 0;
        let uiBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UIInteractions);
        if !IsDefined(uiBB) {
            return;
        }
        let hubDef: ref<UIInteractionsDef> = GetAllBlackboardDefs().UIInteractions;
        let existing: InteractionChoiceHubData = FromVariant<InteractionChoiceHubData>(uiBB.GetVariant(hubDef.InteractionChoiceHub));
        if this.IsOurInteractionHubId(existing.id) {
            let empty: InteractionChoiceHubData;
            empty.id = -975501;
            empty.active = false;
            let visInfo: VisualizersInfo;
            visInfo.activeVisId = -1;
            uiBB.SetVariant(hubDef.InteractionChoiceHub, ToVariant(empty), true);
            uiBB.SetVariant(hubDef.VisualizersInfo, ToVariant(visInfo), true);
        }
    }

    public final func TryHandleWorldInteractionInput() -> Bool {
        if !this.m_interactionShown || this.m_interactionKind <= 0 || this.IsSpeechBlockingWorldInteraction() || this.IsUiBlockingWorldInput() || this.IsInteractionGuardActive() {
            return false;
        }
        let kind: Int32 = this.m_interactionKind;
        this.HideWorldInteraction();
        this.InterruptAmbientFieldSpeech();
        if kind >= 200 {
            if IsDefined(this.m_act02) {
                return this.m_act02.HandleInteraction(kind);
            }
            return false;
        }
        if kind >= 100 {
            if IsDefined(this.m_act01) {
                return this.m_act01.HandleInteraction(kind);
            }
            return false;
        }
        if IsDefined(this.m_act00) {
            return this.m_act00.HandleInteraction(kind);
        }
        return false;
    }

    // --- Interfaz Interactiva Tarot & Códice (Shards en Diario) ---

    public final func OpenTarotSpreadPopup(readingMode: Bool) -> Void {
        if this.m_isTarotPopupOpen {
            return;
        }
        this.SyncCodexJournalShards();
        this.HideWorldInteraction();
        this.HideDialogChoices();
        this.SetSkipSpeechHintVisible(false);
        this.m_isTarotPopupOpen = true;
        if this.m_isPlayingDialogueSequence && !this.m_pausedByUiMenu {
            this.OnUiMenuChanged(true);
        }
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
            GameObject.PlaySoundEvent(player, n"ui_menu_hover");
        }
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(game);
        let initCard: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_r2_regent_card") : 1;
        let initLens: Int32 = IsDefined(qs) ? qs.GetFact(n"cv_r2_lens") : 1;
        if initCard <= 0 {
            initCard = 1;
        }
        if initLens <= 0 {
            initLens = 1;
        }
        let popup: ref<CrimsonTarotPopup> = new CrimsonTarotPopup();
        popup.Setup(this, readingMode, initCard, initLens);
        GameInstance.GetUISystem(game).QueueEvent(ShowCustomPopupEvent.Create(popup));
    }

    public final func OnTarotPopupClosed(confirmedReading: Bool, selectedCard: Int32, lensMode: Int32) -> Void {
        if !this.m_isTarotPopupOpen {
            return;
        }
        this.m_isTarotPopupOpen = false;
        this.m_interactionGuardUntil = MaxF(this.m_interactionGuardUntil, EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance())) + 0.55);
        if this.m_pausedByUiMenu && !this.IsInSystemOrPauseMenu() {
            this.OnUiMenuChanged(false);
        }
        if confirmedReading && IsDefined(this.m_act00) {
            this.m_act00.OnTarotReadingConfirmed(selectedCard, lensMode);
        }
    }

    public final func IsCodexShardUnlocked(shardIndex: Int32) -> Bool {
        let qs: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGameInstance());
        if !IsDefined(qs) {
            return shardIndex == 1;
        }
        let st: Int32 = qs.GetFact(n"cv_r2_state");
        if shardIndex == 1 {
            return st >= 15 || qs.GetFact(n"cv_r2_scanned") > 0;
        }
        if shardIndex == 2 {
            return st >= 15 || qs.GetFact(n"cv_r2_scanned") > 0;
        }
        if shardIndex == 3 {
            return st >= 20 || qs.GetFact(n"cv_r2_qa_missing") > 0 || qs.GetFact(n"cv_r2_qa_watched") > 0 || qs.GetFact(n"cv_r2_qa_chorus") > 0;
        }
        if shardIndex == 4 {
            return st >= 30 || qs.GetFact(n"cv_r2_tarot_done") > 0;
        }
        let a1St: Int32 = qs.GetFact(n"cv_a1_state");
        if shardIndex == 5 {
            return a1St >= 20 || (qs.GetFact(n"cv_a1_clue_blood") > 0 && qs.GetFact(n"cv_a1_clue_tarot") > 0 && qs.GetFact(n"cv_a1_clue_relay") > 0);
        }
        if shardIndex == 6 {
            return qs.GetFact(n"cv_a1_asked_role") > 0 || qs.GetFact(n"cv_a1_asked_sect") > 0 || a1St >= 30;
        }
        if shardIndex == 7 {
            return qs.GetFact(n"cv_a1_has_cipher") > 0 || a1St >= 30;
        }
        let a2St: Int32 = qs.GetFact(n"cv_a2_state");
        if shardIndex == 8 {
            return a2St >= 20 || qs.GetFact(n"cv_a2_clue_mateo") > 0;
        }
        if shardIndex == 9 {
            return a2St >= 30 || qs.GetFact(n"cv_a2_lucia_met") > 0;
        }
        if shardIndex == 10 {
            return a2St >= 60 || qs.GetFact(n"cv_a2_done") > 0;
        }
        return false;
    }

    public final func GetCodexShardText(shardIndex: Int32, out outTitle: String, out outBody: String) -> Void {
        if shardIndex == 1 {
            outTitle = this.GetLoc(n"cv_shard_r2_lucia_name", "Ficha Personal — Lucía Reyes y el código de La Luna");
            outBody = this.GetLoc(n"cv_shard_r2_lucia_text", "KABUKI // CALLEJÓN DE ESOTERICA");
        } else if shardIndex == 2 {
            outTitle = this.GetLoc(n"cv_shard_r2_porphyria_name", "Análisis Kiroshi — Hemoglobina Sintética y Porfirinas NOX-9");
            outBody = this.GetLoc(n"cv_shard_r2_porphyria_text", "LOTE NO REGISTRADO NOX-9");
        } else if shardIndex == 3 {
            outTitle = this.GetLoc(n"cv_shard_r2_missing_name", "Desapariciones en Watson — Mateo y vigilancia callejera");
            outBody = this.GetLoc(n"cv_shard_r2_missing_text", "NOTAS DE TESTIGO // MISTY OLSZEWSKI");
        } else if shardIndex == 4 {
            outTitle = this.GetLoc(n"cv_shard_r2_northside_name", "Informe de Campo — Depósitos de Northside y El Coro Pálido");
            outBody = this.GetLoc(n"cv_shard_r2_northside_text", "SANTUARIO DE NORTHSIDE // PISTA DEL PRÓLOGO");
        } else if shardIndex == 5 {
            outTitle = this.GetLoc(n"cv_shard_a1_kabuki_name", "Rastro de Kabuki — Lote NOX-9-K4 y amenaza a Valdés");
            outBody = this.GetLoc(n"cv_shard_a1_kabuki_text", "EMBARCADERO DEL CANAL DE KABUKI // RASTRO FORENSE");
        } else if shardIndex == 6 {
            outTitle = this.GetLoc(n"cv_shard_a1_valdes_name", "Testimonio de Valdés — NOX-9, Helena Solís y la secta");
            outBody = this.GetLoc(n"cv_shard_a1_valdes_text", "LITTLE CHINA // INTERROGATORIO AL DR. ADRIÁN VALDÉS");
        } else if shardIndex == 7 {
            outTitle = this.GetLoc(n"cv_shard_a1_pier_lead_name", "Pincho de Valdés — Muelle Oeste y pista NOX-9B");
            outBody = this.GetLoc(n"cv_shard_a1_pier_lead_text", "PINCHO CIFRADO ENTREGADO // PISTAS PARA AVANZAR");
        } else if shardIndex == 8 {
            outTitle = this.GetLoc(n"cv_shard_a2_flats_name", "Biotechnica Flats — El Sacrificio de Mateo (M-09)");
            outBody = this.GetLoc(n"cv_shard_a2_flats_text", "DESCARTE EN BIOTECHNICA FLATS // REGISTRO FORENSE");
        } else if shardIndex == 9 {
            outTitle = this.GetLoc(n"cv_shard_a2_lucia_solis_name", "Búnker de las Badlands — Lucía y la Dra. Helena Solís");
            outBody = this.GetLoc(n"cv_shard_a2_lucia_solis_text", "ESTACIÓN GEOTÉRMICA DE BIOTECHNICA // ACTO II");
        } else {
            outTitle = this.GetLoc(n"cv_shard_a2_epilogue_name", "Epílogo — Esoterica Vuelve a Abrir y La Luna");
            outBody = this.GetLoc(n"cv_shard_a2_epilogue_text", "MISTY'S ESOTERICA // CIERRE DE CAMPAÑA");
        }
    }

    public final func SyncCodexJournalShards() -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return;
        }
        let paths: array<String> = [
            "onscreens/crimson_veil_shards/cv_shard_r2_lucia",
            "onscreens/crimson_veil_shards/cv_shard_r2_porphyria",
            "onscreens/crimson_veil_shards/cv_shard_r2_missing",
            "onscreens/crimson_veil_shards/cv_shard_r2_northside",
            "onscreens/crimson_veil_shards/cv_shard_a1_kabuki",
            "onscreens/crimson_veil_shards/cv_shard_a1_valdes",
            "onscreens/crimson_veil_shards/cv_shard_a1_pier_lead",
            "onscreens/crimson_veil_shards/cv_shard_a2_flats",
            "onscreens/crimson_veil_shards/cv_shard_a2_lucia_solis",
            "onscreens/crimson_veil_shards/cv_shard_a2_epilogue"
        ];
        let i: Int32 = 1;
        while i <= 10 {
            if this.IsCodexShardUnlocked(i) {
                let p: String = paths[i - 1];
                let entry: wref<JournalEntry> = jm.GetEntryByString(p, "gameJournalOnscreen");
                if IsDefined(entry) && Equals(jm.GetEntryState(entry), gameJournalEntryState.Inactive) {
                    jm.ChangeEntryState(p, "gameJournalOnscreen", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
                }
            }
            i += 1;
        }
    }

    // --- Marcadores Amarillos en Mundo/Mapa y Diarios ---

    public final func TrackQuestObjective(objectivePath: String) -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) || Equals(objectivePath, "") {
            return;
        }
        let objEntry: wref<JournalEntry> = jm.GetEntryByString(objectivePath, "gameJournalQuestObjective");
        if IsDefined(objEntry) {
            jm.TrackEntry(objEntry);
        }
    }

    public final func DeactivateJournalPinList(pinPaths: array<String>) -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return;
        }
        for pp in pinPaths {
            let pinEntry: wref<JournalEntry> = jm.GetEntryByString(pp, "gameJournalQuestMapPin");
            if IsDefined(pinEntry) && Equals(jm.GetEntryState(pinEntry), gameJournalEntryState.Active) {
                jm.ChangeEntryState(pp, "gameJournalQuestMapPin", gameJournalEntryState.Inactive, JournalNotifyOption.DoNotNotify);
            }
        }
    }

    public final func ClearJournalPinsAndResetSync(pinPaths: array<String>) -> Void {
        this.DeactivateJournalPinList(pinPaths);
        this.m_journalPinSyncedTag = 0;
        this.m_journalPinRetryTicks = 0;
    }

    public final func HasActiveJournalQuestMappin(objectivePath: String) -> Bool {
        if Equals(objectivePath, "") {
            return false;
        }
        let game: GameInstance = this.GetGameInstance();
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(game);
        if !IsDefined(jm) || !IsDefined(ms) {
            return false;
        }
        let objEntry: wref<JournalEntry> = jm.GetEntryByString(objectivePath, "gameJournalQuestObjective");
        if !IsDefined(objEntry) {
            return false;
        }
        let positions: array<Vector3>;
        let hash: Uint32 = Cast<Uint32>(jm.GetEntryHash(objEntry));
        return ms.GetQuestMappinPositionsByObjective(hash, positions) && ArraySize(positions) > 0;
    }

    public final func ActivateObjectiveWithPin(
        stageTag: Int32,
        questPath: String,
        phasePath: String,
        objPath: String,
        pinPath: String,
        descPath: String,
        allPinPaths: array<String>,
        notifyObjective: Bool
    ) -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) || Equals(objPath, "") {
            return;
        }
        let qEntry: wref<JournalEntry> = jm.GetEntryByString(questPath, "gameJournalQuest");
        if IsDefined(qEntry) && NotEquals(jm.GetEntryState(qEntry), gameJournalEntryState.Active) {
            jm.ChangeEntryState(questPath, "gameJournalQuest", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        let pEntry: wref<JournalEntry> = jm.GetEntryByString(phasePath, "gameJournalQuestPhase");
        if IsDefined(pEntry) && NotEquals(jm.GetEntryState(pEntry), gameJournalEntryState.Active) {
            jm.ChangeEntryState(phasePath, "gameJournalQuestPhase", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }

        this.DeactivateJournalPinList(allPinPaths);

        if NotEquals(descPath, "") {
            jm.ChangeEntryState(descPath, "gameJournalQuestDescription", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }

        let shouldTrack: Bool = notifyObjective || !IsDefined(jm.GetTrackedEntry()) || this.IsCrimsonVeilQuestTrackedInJournal();
        let objEntry: wref<JournalEntry> = jm.GetEntryByString(objPath, "gameJournalQuestObjective");
        if IsDefined(objEntry) && Equals(jm.GetEntryState(objEntry), gameJournalEntryState.Active) {
            jm.ChangeEntryState(objPath, "gameJournalQuestObjective", gameJournalEntryState.Inactive, JournalNotifyOption.DoNotNotify);
        }
        if NotEquals(pinPath, "") {
            jm.ChangeEntryState(pinPath, "gameJournalQuestMapPin", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        jm.ChangeEntryState(objPath, "gameJournalQuestObjective", gameJournalEntryState.Active, notifyObjective ? JournalNotifyOption.Notify : JournalNotifyOption.DoNotNotify);

        if shouldTrack {
            this.TrackQuestObjective(objPath);
        }
        if this.HasActiveJournalQuestMappin(objPath) {
            this.ClearMappin();
        }
        this.m_journalPinSyncedTag = stageTag;
        if notifyObjective {
            this.m_journalPinRetryTicks = 0;
        }
    }

    public final func SyncObjectivePinLoop(
        stageTag: Int32,
        questPath: String,
        phasePath: String,
        objPath: String,
        pinPath: String,
        allPinPaths: array<String>
    ) -> Void {
        if stageTag <= 0 || Equals(objPath, "") {
            if this.m_journalPinSyncedTag != 0 {
                this.ClearJournalPinsAndResetSync(allPinPaths);
            }
            return;
        }
        if this.m_journalPinSyncedTag != stageTag {
            this.m_journalPinRetryTicks = 0;
            this.ActivateObjectiveWithPin(stageTag, questPath, phasePath, objPath, pinPath, "", allPinPaths, false);
            return;
        }
        if !this.HasActiveJournalQuestMappin(objPath) && this.m_journalPinRetryTicks < 18 {
            this.m_journalPinRetryTicks += 1;
            if this.m_journalPinRetryTicks == 6 || this.m_journalPinRetryTicks == 15 {
                this.ActivateObjectiveWithPin(stageTag, questPath, phasePath, objPath, pinPath, "", allPinPaths, false);
            }
        }
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if IsDefined(jm) && !IsDefined(jm.GetTrackedEntry()) {
            this.TrackQuestObjective(objPath);
        }
    }

    public final func UpdateFallbackMappin(
        stageTag: Int32,
        objPath: String,
        pinPos: Vector4,
        captionKey: CName,
        fallbackCaption: String
    ) -> Void {
        if this.HasActiveJournalQuestMappin(objPath) {
            this.ClearMappin();
            return;
        }
        this.UpdateDynamicMappin(stageTag, pinPos, captionKey, fallbackCaption);
    }

    public final func ActivateQuestObjective(questPath: String, phasePath: String, objPath: String, descPath: String, notifyObjective: Bool) -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) || Equals(objPath, "") {
            return;
        }
        let qEntry: wref<JournalEntry> = jm.GetEntryByString(questPath, "gameJournalQuest");
        if IsDefined(qEntry) && NotEquals(jm.GetEntryState(qEntry), gameJournalEntryState.Active) {
            jm.ChangeEntryState(questPath, "gameJournalQuest", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        let pEntry: wref<JournalEntry> = jm.GetEntryByString(phasePath, "gameJournalQuestPhase");
        if IsDefined(pEntry) && NotEquals(jm.GetEntryState(pEntry), gameJournalEntryState.Active) {
            jm.ChangeEntryState(phasePath, "gameJournalQuestPhase", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        if NotEquals(descPath, "") {
            jm.ChangeEntryState(descPath, "gameJournalQuestDescription", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        jm.ChangeEntryState(objPath, "gameJournalQuestObjective", gameJournalEntryState.Active, notifyObjective ? JournalNotifyOption.Notify : JournalNotifyOption.DoNotNotify);
        let objEntry: wref<JournalEntry> = jm.GetEntryByString(objPath, "gameJournalQuestObjective");
        if IsDefined(objEntry) && (notifyObjective || !IsDefined(jm.GetTrackedEntry()) || this.IsCrimsonVeilQuestTrackedInJournal()) {
            jm.TrackEntry(objEntry);
        }
    }

    public final func UpdateDynamicMappin(stageTag: Int32, pinPos: Vector4, captionKey: CName, fallbackCaption: String) -> Void {
        let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(this.GetGameInstance());
        if !IsDefined(ms) {
            return;
        }
        let nextDesc: String = this.GetLoc(captionKey, fallbackCaption);
        if this.m_hasMappin && this.m_mappinStageTag == stageTag && Equals(this.m_mappinDesc, nextDesc) {
            ms.SetMappinPosition(this.m_mappinId, pinPos);
            return;
        }
        this.ClearMappin();
        if stageTag >= 200 {
            this.m_mappinTitle = this.GetLoc(n"cv_quest_a2_title", "Velo Carmesí — Acto II: Liturgia de Ceniza");
        } else if stageTag >= 100 {
            this.m_mappinTitle = this.GetLoc(n"cv_quest_a1_title", "Velo Carmesí — Acto I: Réquiem de Porfirina");
        } else {
            this.m_mappinTitle = this.GetLoc(n"cv_quest_p0_title", "Velo Carmesí: Sangre bajo el Neón");
        }
        this.m_mappinDesc = nextDesc;

        let data: MappinData;
        data.mappinType = t"Mappins.CrimsonVeilQuestMappin";
        data.variant = gamedataMappinVariant.DefaultQuestVariant;
        data.active = true;
        data.visibleThroughWalls = true;
        data.debugCaption = this.m_mappinDesc;
        data.scriptData = new CrimsonVeilMappinData();
        this.m_isRegisteringMappin = true;
        this.m_mappinId = ms.RegisterMappin(data, pinPos);
        this.m_hasMappin = true;
        this.m_isRegisteringMappin = false;
        this.m_mappinStageTag = stageTag;
    }

    public final func ClearMappin() -> Void {
        this.m_activeMapPinCtrl = null;
        this.m_isRegisteringMappin = false;
        if !this.m_hasMappin {
            return;
        }
        let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(this.GetGameInstance());
        if IsDefined(ms) {
            if Equals(ms.GetManuallyTrackedMappinID(), this.m_mappinId) {
                ms.UntrackMappin();
            }
            ms.UnregisterMappin(this.m_mappinId);
        }
        this.m_hasMappin = false;
        this.m_mappinStageTag = -1;
    }

    public final func IsCrimsonVeilMappin(mappin: wref<IMappin>) -> Bool {
        if !IsDefined(mappin) {
            return false;
        }
        if IsDefined(mappin.GetScriptData() as CrimsonVeilMappinData) {
            return true;
        }
        if this.m_isRegisteringMappin && Equals(mappin.GetVariant(), gamedataMappinVariant.DefaultQuestVariant) {
            return true;
        }
        return this.m_hasMappin && Equals(mappin.GetNewMappinID(), this.m_mappinId);
    }

    public final func GetMappinTitle() -> String = this.m_mappinTitle;
    public final func GetMappinDesc() -> String = this.m_mappinDesc;

    public final func IsCrimsonVeilQuestTrackedInJournal() -> Bool {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return false;
        }
        let tracked: wref<JournalEntry> = jm.GetTrackedEntry();
        if !IsDefined(tracked) {
            return true;
        }
        let tid: String = tracked.GetId();
        return Equals(tid, "01_r2_alley")
            || Equals(tid, "02_r2_scan")
            || Equals(tid, "03_r2_rooftop")
            || Equals(tid, "04_r2_oilfields")
            || Equals(tid, "05_r2_evidence")
            || Equals(tid, "06_r2_debrief")
            || Equals(tid, "01_a1_kabuki_trace")
            || Equals(tid, "02_a1_valdes_hideout")
            || Equals(tid, "03_a1_waterfront_cryo")
            || Equals(tid, "04_a1_return_misty")
            || Equals(tid, "01_a2_flats_convoy")
            || Equals(tid, "02_a2_bunker_lucia")
            || Equals(tid, "02b_a2_enter_bunker")
            || Equals(tid, "02c_a2_sub1_seal_a")
            || Equals(tid, "02d_a2_sub1_uv_tower")
            || Equals(tid, "02e_a2_sub1_clear_hall")
            || Equals(tid, "02f_a2_sub1_level2_door")
            || Equals(tid, "03a_a2_sub2_uv_tower")
            || Equals(tid, "03b_a2_sub2_clear_hall")
            || Equals(tid, "03c_a2_solis_chamber")
            || Equals(tid, "04_a2_secure_core")
            || Equals(tid, "05_a2_sub2_extract")
            || Equals(tid, "06_a2_return_misty");
    }

    public final func SetActiveWorldMap(wm: wref<WorldMapMenuGameController>, ready: Bool) -> Void {
        this.m_activeWorldMap = wm;
        this.m_worldMapReady = ready;
        if !IsDefined(wm) {
            this.m_activeMapPinCtrl = null;
            return;
        }
        if ready && IsDefined(this.m_activeMapPinCtrl) {
            let cb: ref<CrimsonVeilWorldMapTrackCallback> = new CrimsonVeilWorldMapTrackCallback();
            cb.system = this;
            GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, 0.05, false);
        }
    }

    public final func NotifyWorldMapMappinReady(ctrl: ref<BaseWorldMapMappinController>) -> Void {
        this.m_activeMapPinCtrl = ctrl;
        if this.m_worldMapReady && IsDefined(this.m_activeWorldMap) {
            let cb: ref<CrimsonVeilWorldMapTrackCallback> = new CrimsonVeilWorldMapTrackCallback();
            cb.system = this;
            GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, 0.05, false);
        }
    }

    public final func OnDeferredWorldMapAutoTrack() -> Void {
        if IsDefined(this.m_activeWorldMap) && IsDefined(this.m_activeMapPinCtrl) && this.m_hasMappin && this.IsCrimsonVeilQuestTrackedInJournal() {
            this.m_activeWorldMap.CvTryAutoTrack(this.m_activeMapPinCtrl);
        }
    }

    // --- Controles CET de Estudio y Depuración ---

    public final func DebugTeleportEsoterica() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugGoToEsoterica();
        }
    }

    public final func DebugTeleportRooftopNight() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugGoToRooftopNight();
        }
    }

    public final func DebugTeleportOilfieldsNight() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugGoToOilfieldsNight();
        }
    }

    public final func DebugTeleportDebriefNight() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugGoToDebriefNight();
        }
    }

    public final func DebugResetPhase0() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugResetAll();
        }
    }

    public final func DebugTriggerAct1Call() -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugTriggerAct1Call();
        }
    }

    public final func DebugTeleportKabuki() -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugGoToKabuki();
        }
    }

    public final func DebugTeleportValdes() -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugGoToValdes();
        }
    }

    public final func DebugTeleportPier(isNight: Bool) -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugGoToPier(isNight);
        }
    }

    public final func DebugTeleportAct1Debrief() -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugGoToDebrief();
        }
    }

    public final func DebugResetAct1() -> Void {
        if IsDefined(this.m_act01) {
            this.m_act01.DebugResetAct1();
        }
    }

    public final func DebugTriggerAct2Call() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugTriggerAct2Call();
        }
    }

    public final func DebugTeleportAct2Flats() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugGoToFlats();
        }
    }

    public final func DebugTeleportAct2Bunker() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugGoToBunker();
        }
    }

    public final func DebugTeleportAct2Sub1() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugGoToSublevel1();
        }
    }

    public final func GetSub1DebugStatus() -> String {
        if IsDefined(this.m_act02) {
            return this.m_act02.GetSub1DebugStatus();
        }
        return "Act02 no inicializado";
    }

    public final func DebugTeleportAct2Sub2() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugGoToSublevel2();
        }
    }

    public final func GetSub2DebugStatus() -> String {
        if IsDefined(this.m_act02) {
            return this.m_act02.GetSub2DebugStatus();
        }
        return "Act02 no inicializado";
    }

    public final func DebugResetAct2() -> Void {
        if IsDefined(this.m_act02) {
            this.m_act02.DebugResetAct2();
        }
    }

    // --- Estudio de Grabación Holocall (.bk2): Iluminación de retrato, ocultación de mira y toma lip-sync ---

    public final func IsHoloRecordStudioActive() -> Bool = this.m_holoRecordStudioActive;

    public final func RegisterCrosshairController(ctrl: wref<gameuiCrosshairContainerController>) -> Void {
        this.m_crosshairCtrl = ctrl;
    }

    public final func RegisterPersistentDotController(ctrl: wref<CrosshairGameControllerPersistentDot>) -> Void {
        this.m_persistentDotCtrl = ctrl;
    }

    public final func EnsureStudioUnblurredAndLive() -> Void {
        let game: GameInstance = this.GetGameInstance();
        let uiSysBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_System);
        if IsDefined(uiSysBB) {
            uiSysBB.SetBool(GetAllBlackboardDefs().UI_System.CircularBlurEnabled, false);
            uiSysBB.SetFloat(GetAllBlackboardDefs().UI_System.CircularBlurBlendTime, 0.05);
        }
        let sysHandler: wref<inkISystemRequestsHandler> = GameInstance.GetSystemRequestsHandler();
        if IsDefined(sysHandler) && sysHandler.IsGamePaused() {
            sysHandler.UnpauseGame();
        }
    }

    private final func SetStudioCrosshairHidden(hidden: Bool) -> Void {
        if IsDefined(this.m_crosshairCtrl) {
            let rootW: wref<inkWidget> = this.m_crosshairCtrl.GetRootWidget();
            if IsDefined(rootW) {
                rootW.SetVisible(!hidden);
            }
        }
        if IsDefined(this.m_persistentDotCtrl) {
            let dotRoot: wref<inkWidget> = this.m_persistentDotCtrl.GetRootWidget();
            if IsDefined(dotRoot) {
                dotRoot.SetVisible(!hidden);
            }
        }
    }

    public final func StartHolocallRecordingStudio() -> Void {
        this.m_holoRecordStudioActive = true;
        this.m_holoRecordToken += 1;
        this.StopCurrentSpeechAudio();
        this.HideDialogChoices();
        this.HideWorldInteraction();
        this.SetSkipSpeechHintVisible(false);
        this.EnsureStudioUnblurredAndLive();
        this.ResetMistyWorkspotRetryState();
        this.SetStudioCrosshairHidden(true);

        let mistyYaw: Float = 0.00;
        if IsDefined(this.m_act00) {
            mistyYaw = this.m_act00.EnterHolocallRecordingStudio();
        }
        if EntityID.IsDefined(this.m_holoRecordLightsId) {
            this.DespawnStaticPropById(this.m_holoRecordLightsId);
            this.m_holoRecordLightsId = new EntityID();
        }
        let mistyPos: Vector4 = new Vector4(-1548.82, 1209.81, 57.00, 1.00);
        this.m_holoRecordLightsId = this.SpawnStaticProp(
            r"crimson_veil\\entities\\cv_holo_record_lights.ent",
            mistyPos,
            mistyYaw,
            n"CV_HoloRecordLights"
        );
    }

    public final func PlayHolocallRecordingLoop(delaySec: Float) -> Void {
        if !this.m_holoRecordStudioActive {
            this.StartHolocallRecordingStudio();
        }
        this.m_holoRecordToken += 1;
        let cb: ref<CrimsonVeilStudioLoopCallback> = new CrimsonVeilStudioLoopCallback();
        cb.system = this;
        cb.token = this.m_holoRecordToken;
        GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, MaxF(0.10, delaySec), false);
    }

    public final func ExecuteHolocallRecordingLoop(token: Int32) -> Void {
        if !this.m_holoRecordStudioActive || token != this.m_holoRecordToken || !IsDefined(this.m_act00) {
            return;
        }
        this.EnsureStudioUnblurredAndLive();
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        let mistyId: EntityID = this.m_act00.GetMistyEntityID();
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        let mistyReady: Bool = IsDefined(des) && EntityID.IsDefined(mistyId) && des.IsSpawned(mistyId);
        if this.IsInSystemOrPauseMenu() || !IsDefined(player) || !mistyReady {
            if IsDefined(player) {
                this.m_act00.EnsureStudioMistyReady(player);
            }
            let retryCb: ref<CrimsonVeilStudioLoopCallback> = new CrimsonVeilStudioLoopCallback();
            retryCb.system = this;
            retryCb.token = token;
            GameInstance.GetDelaySystem(game).DelayCallback(retryCb, 0.35, false);
            return;
        }
        this.m_act00.EnsureStudioMistyReady(player);
        this.StopCurrentSpeechAudio();
        this.SetStudioCrosshairHidden(true);
        let playedVariant: CName = n"None";
        let backendUsed: Int32 = CrimsonVeilAudioBridge.PlaySpeech(
            game,
            n"cv_r2_call_misty_02",
            mistyId,
            n"Misty Olszewski",
            player,
            playedVariant
        );
        this.m_currentPlayingEvent = n"cv_r2_call_misty_02";
        this.m_currentPlayingEntity = mistyId;
        this.m_currentPlayingSpeaker = n"Misty Olszewski";
        this.m_currentPlayingBackend = backendUsed;
        this.m_currentPlayingVariant = playedVariant;
        this.StartNpcLipSync(n"cv_r2_call_misty_02", n"misty", mistyId, 18.44);
    }

    public final func StopHolocallRecordingStudio() -> Void {
        this.m_holoRecordStudioActive = false;
        this.m_holoRecordToken += 1;
        this.StopCurrentSpeechAudio();
        if EntityID.IsDefined(this.m_holoRecordLightsId) {
            this.DespawnStaticPropById(this.m_holoRecordLightsId);
            this.m_holoRecordLightsId = new EntityID();
        }
        this.SetStudioCrosshairHidden(false);
    }

    // --- Holollamadas Nativas con Retrato de Misty (avatars1.inkatlas :: misty) ---

    public final func IsMistyVideocallActive() -> Bool {
        return this.m_holoCallActive && Equals(this.m_activeCallContact, n"cv_misty");
    }

    public final func RegisterPhoneAvatarController(ctrl: wref<HudPhoneAvatarController>) -> Void {
        this.m_phoneAvatarCtrl = ctrl;
    }

    public final func IsMistyCurrentlySpeakingInCall() -> Bool {
        return this.m_mistyCallSpeaking;
    }

    public final func SetMistyCallSpeakingState(isSpeaking: Bool) -> Void {
        this.m_mistyCallSpeaking = isSpeaking;
        if this.IsMistyVideocallActive() && IsDefined(this.m_phoneAvatarCtrl) {
            this.m_phoneAvatarCtrl.SetCvMistyHoloSpeaking(isSpeaking);
        }
    }

    public final func IsVanillaPhoneBusy() -> Bool {
        let game: GameInstance = this.GetGameInstance();
        let simNow: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
        if simNow < this.m_vanillaCallCooldownUntil {
            return true;
        }
        let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_ComDevice);
        if IsDefined(bb) {
            let info: PhoneCallInformation = FromVariant<PhoneCallInformation>(bb.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
            if IsNameValid(info.contactName) && NotEquals(info.contactName, n"cv_misty") {
                if Equals(info.callPhase, questPhoneCallPhase.IncomingCall) || Equals(info.callPhase, questPhoneCallPhase.StartCall) {
                    return true;
                }
            }
        }
        return false;
    }

    public final func ShouldDeferVanillaCall(request: ref<questTriggerCallRequest>) -> Bool {
        if this.m_flushingDeferredCalls || !IsDefined(request) {
            return false;
        }
        let contactName: CName;
        if IsNameValid(request.caller) && NotEquals(request.caller, n"player") && NotEquals(request.caller, n"Player") {
            contactName = request.caller;
        } else if IsNameValid(request.addressee) && NotEquals(request.addressee, n"player") && NotEquals(request.addressee, n"Player") {
            contactName = request.addressee;
        }
        if !IsNameValid(contactName) || Equals(contactName, n"cv_misty") {
            return false;
        }
        let game: GameInstance = this.GetGameInstance();
        if this.IsMistyVideocallActive() {
            if Equals(request.callPhase, questPhoneCallPhase.EndCall) || Equals(request.callPhase, questPhoneCallPhase.Undefined) {
                return true;
            }
            if Equals(request.callPhase, questPhoneCallPhase.IncomingCall) || Equals(request.callPhase, questPhoneCallPhase.StartCall) {
                let i: Int32 = 0;
                while i < ArraySize(this.m_deferredVanillaCalls) {
                    let ex: ref<questTriggerCallRequest> = this.m_deferredVanillaCalls[i];
                    if IsDefined(ex) && Equals(ex.caller, request.caller) && Equals(ex.addressee, request.addressee) && Equals(ex.callPhase, request.callPhase) {
                        return true;
                    }
                    i += 1;
                }
                let clone: ref<questTriggerCallRequest> = new questTriggerCallRequest();
                clone.caller = request.caller;
                clone.addressee = request.addressee;
                clone.callMode = request.callMode;
                clone.callPhase = request.callPhase;
                clone.isPlayerTriggered = request.isPlayerTriggered;
                clone.isRejectable = request.isRejectable;
                clone.showAvatar = request.showAvatar;
                clone.visuals = request.visuals;
                ArrayPush(this.m_deferredVanillaCalls, clone);
                return true;
            }
        }
        if Equals(request.callPhase, questPhoneCallPhase.EndCall) || Equals(request.callPhase, questPhoneCallPhase.Undefined) {
            this.m_vanillaCallCooldownUntil = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + 4.00;
            return false;
        }
        return false;
    }

    public final func FlushDeferredVanillaCalls() -> Void {
        if ArraySize(this.m_deferredVanillaCalls) == 0 {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        if this.IsMistyVideocallActive() || this.IsVanillaPhoneBusy() {
            let retryCb: ref<CrimsonVeilFlushDeferredCallsCallback> = new CrimsonVeilFlushDeferredCallsCallback();
            retryCb.system = this;
            GameInstance.GetDelaySystem(game).DelayCallback(retryCb, 2.00, false);
            return;
        }
        let req: ref<questTriggerCallRequest> = this.m_deferredVanillaCalls[0];
        ArrayErase(this.m_deferredVanillaCalls, 0);
        if IsDefined(req) {
            this.m_flushingDeferredCalls = true;
            GameInstance.GetScriptableSystemsContainer(game).QueueRequest(req);
            this.m_flushingDeferredCalls = false;
        }
        if ArraySize(this.m_deferredVanillaCalls) > 0 {
            let nextCb: ref<CrimsonVeilFlushDeferredCallsCallback> = new CrimsonVeilFlushDeferredCallsCallback();
            nextCb.system = this;
            GameInstance.GetDelaySystem(game).DelayCallback(nextCb, 4.00, false);
        }
    }

    public final func YieldMistyCallToVanilla() -> Void {
        let game: GameInstance = this.GetGameInstance();
        this.m_speechToken += 1;
        this.StopCurrentSpeechAudio();
        this.HideCurrentSpeechSubtitleElementOnly();
        this.m_isPlayingDialogueSequence = false;
        this.m_speechAllowManualSkip = false;
        this.m_speechActionOnComplete = 0;
        this.m_pendingPostSpeechAction = 0;
        this.m_activeCallPendingPickup = false;
        this.m_holoCallActive = false;
        this.m_activeCallContact = n"None";
        this.m_mistyCallSpeaking = false;
        if IsDefined(this.m_phoneAvatarCtrl) {
            this.m_phoneAvatarCtrl.HideCvMistyHoloFeed(true);
        }
        this.m_vanillaCallCooldownUntil = EngineTime.ToFloat(GameInstance.GetSimTime(game)) + 4.00;
        let prevScenario: Int32 = this.m_activeCallScenario;
        this.m_activeCallScenario = 0;
        if prevScenario == 3 {
            if IsDefined(this.m_act02) {
                this.m_act02.ResetPendingAct2CallForRetry();
            }
        } else if prevScenario == 2 {
            if IsDefined(this.m_act01) {
                this.m_act01.ResetPendingAct1CallForRetry();
            }
        } else if IsDefined(this.m_act00) {
            this.m_act00.ResetPendingPrologueCallForRetry();
        }
    }

    public final func StartMistyIntroCall() -> Void {
        this.StartMistyHoloCallScenario(1);
    }

    public final func StartMistyAct1Call() -> Void {
        this.StartMistyHoloCallScenario(2);
    }

    public final func StartMistyAct2Call() -> Void {
        this.StartMistyHoloCallScenario(3);
    }

    private final func StartMistyHoloCallScenario(scenarioId: Int32) -> Void {
        if this.m_holoCallActive {
            return;
        }
        if this.m_isPlayingDialogueSequence || this.IsVanillaPhoneBusy() {
            if scenarioId == 3 {
                if IsDefined(this.m_act02) {
                    this.m_act02.ResetPendingAct2CallForRetry();
                }
            } else if scenarioId == 2 {
                if IsDefined(this.m_act01) {
                    this.m_act01.ResetPendingAct1CallForRetry();
                }
            } else if IsDefined(this.m_act00) {
                this.m_act00.ResetPendingPrologueCallForRetry();
            }
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(game);
        if IsDefined(jm) {
            jm.ChangeEntryState("contacts/cv_misty", "gameJournalContact", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        }
        this.m_holoCallActive = true;
        this.m_mistyCallSpeaking = false;

        this.m_activeCallToken += 1;
        this.m_activeCallScenario = scenarioId;
        this.m_activeCallContact = n"cv_misty";
        this.m_activeCallPendingPickup = true;

        let req: ref<questTriggerCallRequest> = new questTriggerCallRequest();
        req.caller = n"cv_misty";
        req.addressee = n"player";
        req.callMode = questPhoneCallMode.Video;
        req.callPhase = questPhoneCallPhase.IncomingCall;
        req.isPlayerTriggered = false;
        req.isRejectable = false;
        req.showAvatar = true;
        req.visuals = questPhoneCallVisuals.Default;
        GameInstance.GetScriptableSystemsContainer(game).QueueRequest(req);

        let cb: ref<CrimsonVeilCallAnswerCallback> = new CrimsonVeilCallAnswerCallback();
        cb.system = this;
        cb.contactName = n"cv_misty";
        cb.callToken = this.m_activeCallToken;
        GameInstance.GetDelaySystem(game).DelayCallback(cb, 12.00, false);
    }

    public final func OnCustomCallPickedUp(contactName: CName, shouldBeRejected: Bool) -> Void {
        if !this.m_activeCallPendingPickup || NotEquals(contactName, this.m_activeCallContact) {
            return;
        }
        this.AnswerIncomingCallInternal(contactName, this.m_activeCallToken, shouldBeRejected);
    }

    public final func AnswerIncomingCallInternal(contactName: CName, token: Int32, rejected: Bool) -> Void {
        if !this.m_activeCallPendingPickup || token != this.m_activeCallToken || NotEquals(contactName, this.m_activeCallContact) {
            return;
        }
        let game: GameInstance = this.GetGameInstance();
        if !rejected && this.IsInSystemOrPauseMenu() {
            let deferCb: ref<CrimsonVeilCallAnswerCallback> = new CrimsonVeilCallAnswerCallback();
            deferCb.system = this;
            deferCb.contactName = contactName;
            deferCb.callToken = token;
            GameInstance.GetDelaySystem(game).DelayCallback(deferCb, 1.50, false);
            return;
        }
        this.m_activeCallPendingPickup = false;
        let scenarioId: Int32 = this.m_activeCallScenario;

        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if IsDefined(player) {
            GameObject.PlaySoundEvent(player, n"ui_phone_incoming_call_stop");
        }
        if rejected {
            this.EndMistyIntroCall();
            if scenarioId == 3 {
                if IsDefined(this.m_act02) {
                    this.m_act02.OnPostSpeech(201);
                }
            } else if scenarioId == 2 {
                if IsDefined(this.m_act01) {
                    this.m_act01.OnPostSpeech(101);
                }
            } else if IsDefined(this.m_act00) {
                this.m_act00.OnPostSpeech(1);
            }
            return;
        }

        let startReq: ref<questTriggerCallRequest> = new questTriggerCallRequest();
        startReq.caller = contactName;
        startReq.addressee = n"player";
        startReq.callMode = questPhoneCallMode.Video;
        startReq.callPhase = questPhoneCallPhase.StartCall;
        startReq.isPlayerTriggered = false;
        startReq.isRejectable = false;
        startReq.showAvatar = true;
        startReq.visuals = questPhoneCallVisuals.Default;
        GameInstance.GetScriptableSystemsContainer(game).QueueRequest(startReq);

        let steps: array<ref<CrimsonVeilSpeechStep>>;
        if scenarioId == 3 {
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a2_call_m1", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 8.36));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a2_call_v1", n"v_narr", n"V", scnDialogLineType.Regular, 5.34));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a2_call_m2", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 10.92));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a2_call_v2", n"v_narr", n"V", scnDialogLineType.Regular, 5.36));
            this.StartSpeechSequence(steps, 201);
        } else if scenarioId == 2 {
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a1_r2_call_m1", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 20.44));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a1_r2_call_v1", n"v_narr", n"V", scnDialogLineType.Regular, 8.37));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a1_r2_call_m2", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 17.01));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_a1_r2_call_v2", n"v_narr", n"V", scnDialogLineType.Regular, 5.24));
            this.StartSpeechSequence(steps, 101);
        } else {
            ArrayPush(steps, this.MakeSpeechStep(n"cv_r2_call_misty_01", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 6.93));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_r2_call_v_01", n"v_narr", n"V", scnDialogLineType.Regular, 4.02));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_r2_call_misty_02", n"holo_misty", n"Misty Olszewski", scnDialogLineType.Regular, 18.44));
            ArrayPush(steps, this.MakeSpeechStep(n"cv_r2_call_v_02", n"v_narr", n"V", scnDialogLineType.Regular, 4.68));
            this.StartSpeechSequence(steps, 1);
        }
    }

    public final func EndMistyIntroCall() -> Void {
        let game: GameInstance = this.GetGameInstance();
        this.m_activeCallPendingPickup = false;
        this.m_activeCallScenario = 0;
        this.m_holoCallActive = false;
        this.m_mistyCallSpeaking = false;
        if NotEquals(this.m_activeCallContact, n"cv_misty") {
            return;
        }
        let endReq: ref<questTriggerCallRequest> = new questTriggerCallRequest();
        endReq.caller = n"cv_misty";
        endReq.addressee = n"player";
        endReq.callMode = questPhoneCallMode.Video;
        endReq.callPhase = questPhoneCallPhase.EndCall;
        endReq.isPlayerTriggered = false;
        endReq.isRejectable = false;
        endReq.showAvatar = true;
        endReq.visuals = questPhoneCallVisuals.Default;
        GameInstance.GetScriptableSystemsContainer(game).QueueRequest(endReq);
        this.m_activeCallContact = n"None";
        if ArraySize(this.m_deferredVanillaCalls) > 0 {
            let flushCb: ref<CrimsonVeilFlushDeferredCallsCallback> = new CrimsonVeilFlushDeferredCallsCallback();
            flushCb.system = this;
            GameInstance.GetDelaySystem(game).DelayCallback(flushCb, 2.50, false);
        }
    }

    public final func AbortPrologueCallAndSpeech() -> Void {
        if this.m_activeCallScenario == 1 || this.m_speechActionOnComplete == 1 || this.m_pendingPostSpeechAction == 1 {
            let game: GameInstance = this.GetGameInstance();
            this.m_speechToken += 1;
            if NotEquals(this.m_speechSeqDelayId, GetInvalidDelayID()) {
                GameInstance.GetDelaySystem(game).CancelCallback(this.m_speechSeqDelayId);
                this.m_speechSeqDelayId = GetInvalidDelayID();
            }
            ArrayClear(this.m_speechSteps);
            this.m_speechActionOnComplete = 0;
            this.m_pendingPostSpeechAction = 0;
            this.m_isPlayingDialogueSequence = false;
            this.m_speechAllowManualSkip = false;
            this.StopCurrentSpeechAudio();
            this.SetSkipSpeechHintVisible(false);
            this.SetMistyCallSpeakingState(false);
            this.EndMistyIntroCall();
        }
    }

    public final func ActivateMistyCallRecapSms() -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return;
        }
        let msgEntry: wref<JournalEntry> = jm.GetEntryByString("contacts/cv_misty/conv_cv_misty/msg_r2_call_recap", "gameJournalPhoneMessage");
        if IsDefined(msgEntry) && Equals(jm.GetEntryState(msgEntry), gameJournalEntryState.Active) {
            return;
        }
        jm.ChangeEntryState("contacts/cv_misty", "gameJournalContact", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty", "gameJournalPhoneConversation", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty/msg_r2_call_recap", "gameJournalPhoneMessage", gameJournalEntryState.Active, JournalNotifyOption.Notify);
    }

    public final func ActivateMistyAct1CallRecapSms() -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return;
        }
        let msgEntry: wref<JournalEntry> = jm.GetEntryByString("contacts/cv_misty/conv_cv_misty/msg_a1_call_recap", "gameJournalPhoneMessage");
        if IsDefined(msgEntry) && Equals(jm.GetEntryState(msgEntry), gameJournalEntryState.Active) {
            return;
        }
        jm.ChangeEntryState("contacts/cv_misty", "gameJournalContact", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty", "gameJournalPhoneConversation", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty/msg_a1_call_recap", "gameJournalPhoneMessage", gameJournalEntryState.Active, JournalNotifyOption.Notify);
    }

    public final func ActivateMistyAct2CallRecapSms() -> Void {
        let jm: ref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
        if !IsDefined(jm) {
            return;
        }
        let msgEntry: wref<JournalEntry> = jm.GetEntryByString("contacts/cv_misty/conv_cv_misty/msg_a2_call_recap", "gameJournalPhoneMessage");
        if IsDefined(msgEntry) && Equals(jm.GetEntryState(msgEntry), gameJournalEntryState.Active) {
            return;
        }
        jm.ChangeEntryState("contacts/cv_misty", "gameJournalContact", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty", "gameJournalPhoneConversation", gameJournalEntryState.Active, JournalNotifyOption.DoNotNotify);
        jm.ChangeEntryState("contacts/cv_misty/conv_cv_misty/msg_a2_call_recap", "gameJournalPhoneMessage", gameJournalEntryState.Active, JournalNotifyOption.Notify);
    }

    public final func DebugTriggerIntroCall() -> Void {
        if IsDefined(this.m_act00) {
            this.m_act00.DebugTriggerIntroCall();
        }
    }

    // --- Bucle Principal ---

    public final func OnTick() -> Void {
        this.m_tickScheduled = false;
        let game: GameInstance = this.GetGameInstance();
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(game).GetLocalPlayerMainGameObject() as PlayerPuppet;

        if !this.IsSessionActive(player) {
            this.m_sessionReadyTicks = 0;
            this.SetSkipSpeechHintVisible(false);
            this.HideDialogChoices();
            this.HideWorldInteraction();
            this.ScheduleTick(0.45);
            return;
        }
        let uiSysBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_System);
        let isInUiMenu: Bool = (IsDefined(uiSysBB) && uiSysBB.GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)) || this.m_isTarotPopupOpen;
        this.m_pausedByUiMenu = isInUiMenu;
        if this.IsInSystemOrPauseMenu() || this.m_isTarotPopupOpen {
            this.SetSkipSpeechHintVisible(false);
            this.HideWorldInteraction();
            this.ScheduleTick(0.25);
            return;
        }

        let fullGameplay: Bool = this.IsInFullGameplayTier(player);
        if fullGameplay {
            if this.m_sessionReadyTicks < 100 {
                this.m_sessionReadyTicks += 1;
            }
            if this.m_sessionReadyTicks == 1 || this.m_sessionReadyTicks == 3 || this.m_sessionReadyTicks == 7 {
                this.SyncAudiowareEngineState(true);
            }
        }

        if this.IsPhoneOverlayOpen() || this.IsControllingDevice() {
            this.SetSkipSpeechHintVisible(false);
            this.HideDialogChoices();
            this.HideWorldInteraction();
        } else if this.m_isPlayingDialogueSequence && this.m_speechAllowManualSkip && !this.m_dialogActive {
            this.SetSkipSpeechHintVisible(true);
        }

        if this.IsMistyVideocallActive() && !this.m_activeCallPendingPickup && IsDefined(this.m_phoneAvatarCtrl) {
            this.m_phoneAvatarCtrl.EnsureCvMistyHoloVisible(this.m_mistyCallSpeaking);
        }

        if this.m_isPlayingDialogueSequence && !this.m_pausedByUiMenu {
            let simNow: Float = EngineTime.ToFloat(GameInstance.GetSimTime(game));
            if this.m_speechSeqExpectedDur > 0.00 && (simNow - this.m_speechStepStartedAt) > (this.m_speechSeqExpectedDur + 3.50) {
                this.m_speechToken += 1;
                this.AdvanceSpeechSequence(this.m_speechToken, this.m_currentSpeechIndex + 1);
            }
        }

        if fullGameplay && !this.IsPhoneOverlayOpen() && !this.IsControllingDevice() && !this.IsUiBlockingWorldInput() {
            if !this.m_isPlayingDialogueSequence && this.m_pendingPostSpeechAction != 0 {
                let pendingAct: Int32 = this.m_pendingPostSpeechAction;
                this.m_pendingPostSpeechAction = 0;
                if pendingAct == 1 || pendingAct == 101 || pendingAct == 201 {
                    this.EndMistyIntroCall();
                }
                if pendingAct >= 200 {
                    if IsDefined(this.m_act02) {
                        this.m_act02.OnPostSpeech(pendingAct);
                    }
                } else if pendingAct >= 100 {
                    if IsDefined(this.m_act01) {
                        this.m_act01.OnPostSpeech(pendingAct);
                    }
                } else if IsDefined(this.m_act00) {
                    this.m_act00.OnPostSpeech(pendingAct);
                }
            }
            this.EnsureActiveDialogHubVisible();
        }

        let nextDelay: Float = 0.70;
        if IsDefined(this.m_act00) {
            nextDelay = this.m_act00.Tick(player, fullGameplay);
        }
        if IsDefined(this.m_act01) {
            let act1Delay: Float = this.m_act01.Tick(player, fullGameplay);
            if act1Delay < nextDelay {
                nextDelay = act1Delay;
            }
        }
        if IsDefined(this.m_act02) {
            let act2Delay: Float = this.m_act02.Tick(player, fullGameplay);
            if act2Delay < nextDelay {
                nextDelay = act2Delay;
            }
        }
        this.ScheduleTick(nextDelay);
    }
}

// ---------------------------------------------------------------------------
// Entrada de Jugador Exclusiva para Menús e Interacción [F] de Velo Carmesí
// ---------------------------------------------------------------------------

public class CrimsonVeilInputListener extends IScriptable {
    public let m_player: wref<PlayerPuppet>;

    protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
        if !IsDefined(this.m_player) {
            return false;
        }
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(this.m_player.GetGame());
        if IsDefined(sys) && !sys.IsUiBlockingWorldInput() {
            let actionName: CName = ListenerAction.GetName(action);
            if sys.IsDialogActive() {
                if Equals(actionName, n"ChoiceScrollUp") || Equals(actionName, n"UI_MoveUp") || Equals(actionName, n"dpad_up") || Equals(actionName, n"UI_DPadUp") || Equals(actionName, n"up_button") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.MoveDialogSelection(-1);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"ChoiceScrollDown") || Equals(actionName, n"UI_MoveDown") || Equals(actionName, n"dpad_down") || Equals(actionName, n"UI_DPadDown") || Equals(actionName, n"down_button") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.MoveDialogSelection(1);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"Keyboard_1") || Equals(actionName, n"WeaponSlot1") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.SelectDialogChoiceIndex(0);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"Keyboard_2") || Equals(actionName, n"WeaponSlot2") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.SelectDialogChoiceIndex(1);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"Keyboard_3") || Equals(actionName, n"WeaponSlot3") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.SelectDialogChoiceIndex(2);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"Keyboard_4") || Equals(actionName, n"WeaponSlot4") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.SelectDialogChoiceIndex(3);
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if Equals(actionName, n"Choice1") || Equals(actionName, n"ChoiceApply") || Equals(actionName, n"UI_Apply") {
                    if Equals(actionName, n"Choice1") && sys.IsNativeInteractionHubBlocking() {
                        return false;
                    }
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.OnDialogConfirmPressed();
                    } else if ListenerAction.IsButtonJustReleased(action) {
                        sys.ConfirmSelectedDialogChoice();
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
            } else if sys.IsSkippableSpeechPlaying() {
                if Equals(actionName, n"SceneFastForward") || Equals(actionName, n"FastForward_Hold") || Equals(actionName, n"Choice1") || Equals(actionName, n"ChoiceApply") {
                    if ListenerAction.IsButtonJustPressed(action) {
                        sys.SkipCurrentSpeechStep();
                    }
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
            } else if sys.IsInteractionActive() && Equals(actionName, n"Choice1") {
                if ListenerAction.IsButtonJustPressed(action) {
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
                if ListenerAction.IsButtonJustReleased(action) && sys.TryHandleWorldInteractionInput() {
                    ListenerActionConsumer.Consume(consumer);
                    return true;
                }
            }
        }
        return false;
    }
}

@addField(PlayerPuppet)
private let m_cvInputListener: ref<CrimsonVeilInputListener>;

@addMethod(PlayerPuppet)
private final func SetCrimsonVeilInputListeners(attach: Bool) -> Void {
    if IsDefined(this.m_cvInputListener) {
        this.UnregisterInputListener(this.m_cvInputListener);
        this.m_cvInputListener.m_player = null;
        this.m_cvInputListener = null;
    }
    if !attach {
        return;
    }
    let actions: array<CName> = [
        n"Choice1", n"ChoiceApply", n"UI_Apply",
        n"ChoiceScrollUp", n"UI_MoveUp", n"dpad_up", n"UI_DPadUp", n"up_button",
        n"ChoiceScrollDown", n"UI_MoveDown", n"dpad_down", n"UI_DPadDown", n"down_button",
        n"Keyboard_1", n"Keyboard_2", n"Keyboard_3", n"Keyboard_4",
        n"WeaponSlot1", n"WeaponSlot2", n"WeaponSlot3", n"WeaponSlot4",
        n"SceneFastForward", n"FastForward_Hold"
    ];
    let listener: ref<CrimsonVeilInputListener> = new CrimsonVeilInputListener();
    listener.m_player = this;
    this.m_cvInputListener = listener;
    for act in actions {
        this.RegisterInputListener(listener, act);
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    let res: Bool = wrappedMethod();
    this.SetCrimsonVeilInputListeners(true);
    return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnMakePlayerVisibleAfterSpawn(evt: ref<EndGracePeriodAfterSpawn>) -> Bool {
    let res: Bool = wrappedMethod(evt);
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(this.GetGame());
    if IsDefined(sys) {
        sys.OnPlayerSpawnGraceEnded();
    }
    return res;
}

@wrapMethod(PlayerPuppet)
protected cb func OnDetach() -> Bool {
    this.SetCrimsonVeilInputListeners(false);
    return wrappedMethod();
}

// ---------------------------------------------------------------------------
// Marcadores Amarillos de Mapa y Minimapa (Aislados para Mappins de CrimsonVeil)
// ---------------------------------------------------------------------------

@addMethod(WorldMapMenuGameController)
public final func CvTryAutoTrack(ctrl: ref<BaseWorldMapMappinController>) -> Void {
    if !IsDefined(ctrl) || ctrl.IsTracked() || this.IsFastTravelEnabled() || this.IsDelamainTaxiEnabled() {
        return;
    }
    let ms: ref<MappinSystem> = GameInstance.GetMappinSystem(GetGameInstance());
    if IsDefined(ms) && !IsDefined(ms.GetMappin(ms.GetManuallyTrackedMappinID())) {
        let mappin: wref<IMappin> = ctrl.GetMappin();
        if IsDefined(mappin) && this.CanQuestTrackMappin(mappin) && !this.IsMappinQuestTracked(mappin) {
            this.UntrackCustomPositionMappin();
            this.TrackQuestMappin(ctrl);
        }
    }
}

@wrapMethod(WorldMapMenuGameController)
protected cb func OnInitialize() -> Bool {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) {
        sys.SetActiveWorldMap(this, false);
    }
    return wrappedMethod();
}

@wrapMethod(WorldMapMenuGameController)
protected cb func OnRemovePreloader(widget: wref<inkWidget>) -> Bool {
    let res: Bool = wrappedMethod(widget);
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) {
        sys.SetActiveWorldMap(this, true);
    }
    return res;
}

@wrapMethod(WorldMapMenuGameController)
protected cb func OnUninitialize() -> Bool {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) {
        sys.SetActiveWorldMap(null, false);
    }
    return wrappedMethod();
}

@addField(BaseWorldMapMappinController)
private let m_cvPinCache: Int32;

@addMethod(BaseWorldMapMappinController)
private final func IsCrimsonVeilOwnMappin() -> Bool {
    if this.m_cvPinCache != 0 {
        return this.m_cvPinCache == 2;
    }
    if this.IsExactlyA(n"WorldMapPlayerMappinController") {
        this.m_cvPinCache = 1;
        return false;
    }
    let mappin: wref<IMappin> = this.GetMappin();
    if !IsDefined(mappin) || NotEquals(mappin.GetVariant(), gamedataMappinVariant.DefaultQuestVariant) {
        this.m_cvPinCache = 1;
        return false;
    }
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsCrimsonVeilMappin(mappin) {
        this.m_cvPinCache = 2;
        return true;
    }
    this.m_cvPinCache = 1;
    return false;
}

@wrapMethod(BaseWorldMapMappinController)
protected cb func OnIntro() -> Bool {
    this.m_cvPinCache = 0;
    let res: Bool = wrappedMethod();
    if this.IsCrimsonVeilOwnMappin() {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if IsDefined(sys) {
            sys.NotifyWorldMapMappinReady(this);
        }
    }
    return res;
}

@wrapMethod(BaseWorldMapMappinController)
private final func GetDesiredOpacityAndInteractivity(out opacity: Float, out interactive: Bool) -> Void {
    wrappedMethod(opacity, interactive);
    if this.IsCrimsonVeilOwnMappin() {
        interactive = true;
        opacity = 1.00;
        this.isVisibleInFilterAndZoom = true;
    }
}

@wrapMethod(BaseWorldMapMappinController)
protected func ComputeRootState() -> CName {
    let st: CName = wrappedMethod();
    if this.IsCrimsonVeilOwnMappin() {
        return n"Quest";
    }
    return st;
}

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
    wrappedMethod(data, menu);
    let mappin: wref<IMappin> = Deref(data).mappin;
    if IsDefined(mappin) && Equals(mappin.GetVariant(), gamedataMappinVariant.DefaultQuestVariant) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if IsDefined(sys) && sys.IsCrimsonVeilMappin(mappin) {
            inkTextRef.SetText(this.m_titleText, sys.GetMappinTitle());
            inkTextRef.SetText(this.m_descText, sys.GetMappinDesc());
            inkWidgetRef.SetVisible(this.m_descText, true);
            this.GetRootWidget().SetState(n"Quest");
        }
    }
}

@wrapMethod(WorldMappinsContainerController)
public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    if IsDefined(mappin) && Equals(mappinVariant, gamedataMappinVariant.DefaultQuestVariant) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if IsDefined(sys) && sys.IsCrimsonVeilMappin(mappin) {
            return MappinUIProfile.Create(
                r"base\\gameplay\\gui\\widgets\\mappins\\quest\\default_mappin.inkwidget",
                t"MappinUISpawnProfile.Always",
                t"WorldMappinUIProfile.Quest"
            );
        }
    }
    return wrappedMethod(mappin, mappinVariant, customData);
}

@wrapMethod(MinimapContainerController)
public func CreateMappinUIProfile(mappin: wref<IMappin>, mappinVariant: gamedataMappinVariant, customData: ref<MappinControllerCustomData>) -> MappinUIProfile {
    if IsDefined(mappin) && Equals(mappinVariant, gamedataMappinVariant.DefaultQuestVariant) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if IsDefined(sys) && sys.IsCrimsonVeilMappin(mappin) {
            return MappinUIProfile.Create(
                r"base\\gameplay\\gui\\widgets\\minimap\\minimap_quest_mappin.inkwidget",
                t"MappinUISpawnProfile.Always",
                t"MinimapMappinUIProfile.Quest"
            );
        }
    }
    return wrappedMethod(mappin, mappinVariant, customData);
}

@wrapMethod(QuestMappinController)
protected cb func OnIntro() -> Bool {
    let res: Bool = wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsCrimsonVeilMappin(this.m_mappin) {
        this.SetIgnorePriority(true);
        this.OverrideClamp(true);
        this.OverrideClampX(true);
        this.OverrideClampY(true);
        this.SetRootVisible(!sys.IsUiBlockingWorldInput());
        inkWidgetRef.SetVisible(this.iconWidget, true);
        inkWidgetRef.SetOpacity(this.iconWidget, 1.00);
        this.GetRootWidget().SetState(n"Quest");
    }
    return res;
}

@wrapMethod(QuestMappinController)
protected cb func OnUpdate() -> Bool {
    let res: Bool = wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsCrimsonVeilMappin(this.m_mappin) {
        let showPin: Bool = !sys.IsUiBlockingWorldInput();
        this.SetIgnorePriority(true);
        this.OverrideClamp(true);
        this.OverrideClampX(true);
        this.OverrideClampY(true);
        this.SetRootVisible(showPin);
        inkWidgetRef.SetVisible(this.iconWidget, true);
        inkWidgetRef.SetOpacity(this.iconWidget, 1.00);
        this.GetRootWidget().SetState(n"Quest");
    }
    return res;
}

@wrapMethod(MinimapQuestMappinController)
protected func Intro() -> Void {
    wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsCrimsonVeilMappin(this.GetMappin()) {
        this.SetForceHide(false);
        this.SetForceShow(true);
        inkImageRef.SetTexturePart(this.iconWidget, MappinUIUtils.MappinToTexturePart(gamedataMappinVariant.DefaultQuestVariant));
        this.UpdateClamping();
        this.UpdateRootState();
    }
}

@wrapMethod(MinimapQuestMappinController)
protected func Update() -> Void {
    wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsCrimsonVeilMappin(this.GetMappin()) {
        this.SetForceHide(false);
        this.SetForceShow(true);
        this.UpdateClamping();
        this.UpdateRootState();
        this.UpdateAboveBelowVerticalRelation();
    }
}

// ---------------------------------------------------------------------------
// Control Seguro de Diálogos Nativos (Coexiste 100 % con DeadChannel / ChispaNC)
// ---------------------------------------------------------------------------

@addMethod(dialogWidgetGameController)
public final func CvEnsureVisible() -> Void {
    let root: wref<inkWidget> = this.GetRootWidget();
    if IsDefined(root) {
        root.SetVisible(true);
        root.SetOpacity(1.00);
        let parent: wref<inkWidget> = root.GetParentWidget();
        if IsDefined(parent) {
            parent.SetVisible(true);
            parent.SetOpacity(1.00);
        }
    }
}

@addMethod(dialogWidgetGameController)
public final func CvSyncAndReveal(hubsVar: Variant, hubId: Int32, selectedIdx: Int32) -> Void {
    this.OnDialogsData(hubsVar);
    this.OnDialogsActivateHub(hubId);
    this.OnDialogsSelectIndex(selectedIdx);
    this.CvEnsureVisible();
}

@addMethod(dialogWidgetGameController)
public final func CvForceClose() -> Void {
    let empty: DialogChoiceHubs;
    this.OnDialogsData(ToVariant(empty));
    this.OnDialogsActivateHub(-1);
    let root: wref<inkWidget> = this.GetRootWidget();
    if IsDefined(root) {
        root.SetVisible(false);
    }
}

@addMethod(dialogWidgetGameController)
public final func CvIsVisuallyOpen() -> Bool {
    let root: wref<inkWidget> = this.GetRootWidget();
    return this.m_AreDialogsOpen && IsDefined(root) && root.IsVisible() && root.GetOpacity() > 0.50;
}

@wrapMethod(InteractionUIBase)
protected cb func OnDialogsData(value: Variant) -> Bool {
    if IsDefined(this as dialogWidgetGameController) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if IsDefined(sys) && sys.IsDialogActive() {
            let incoming: DialogChoiceHubs = FromVariant<DialogChoiceHubs>(value);
            if ArraySize(incoming.choiceHubs) == 0 || !sys.IsOurDialogHubIdPublic(incoming.choiceHubs[0].id) {
                (this as dialogWidgetGameController).CvEnsureVisible();
                return true;
            }
        }
    }
    return wrappedMethod(value);
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsActivateHub(activeHubId: Int32) -> Bool {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsDialogActive() && !sys.IsOurDialogHubIdPublic(activeHubId) {
        this.CvEnsureVisible();
        return true;
    }
    return wrappedMethod(activeHubId);
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnDialogsSelectIndex(index: Int32) -> Bool {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsDialogActive() && index < 0 {
        return true;
    }
    return wrappedMethod(index);
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnInitialize() -> Bool {
    let res: Bool = wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) {
        sys.SetDialogWidgetController(this);
    }
    return res;
}

@wrapMethod(dialogWidgetGameController)
protected cb func OnUninitialize() -> Bool {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) {
        sys.SetDialogWidgetController(null);
    }
    return wrappedMethod();
}

@wrapMethod(dialogWidgetGameController)
protected func OnInteractionsChanged() -> Void {
    wrappedMethod();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    if IsDefined(sys) && sys.IsDialogActive() {
        this.CvEnsureVisible();
    }
}

@wrapMethod(DialogChoiceLogicController)
public final func AnimateSelection() -> Void {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
    let ourDlg: Bool = IsDefined(sys) && sys.IsDialogActive();
    if ourDlg {
        this.m_isPreserveSelectionFadeOut = false;
        let r: wref<inkWidget> = this.GetRootWidget();
        if IsDefined(r) {
            r.SetVisible(true);
            r.SetOpacity(1.00);
        }
        if this.m_isSelected && !this.m_prevIsSelected && IsDefined(this.m_InActiveTextRoot) {
            let curWipe: Float = this.m_InActiveTextRoot.GetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition");
            if curWipe > 0.90 {
                this.m_InActiveTextRoot.SetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition", 0.00);
            }
        }
    }
    wrappedMethod();
    if ourDlg && Equals(this.m_prevIsSelected, this.m_isSelected) {
        let targetWipe: Float = this.m_isSelected ? 1.00 : 0.00;
        if IsDefined(this.m_InActiveTextRoot) {
            this.m_InActiveTextRoot.SetEffectEnabled(inkEffectType.LinearWipe, n"LinearWipe_0", true);
            this.m_InActiveTextRoot.SetEffectParamValue(inkEffectType.LinearWipe, n"LinearWipe_0", n"transition", targetWipe);
        }
    }
}

@wrapMethod(ReactionManagerComponent)
protected cb func OnResetFacialEvent(evt: ref<ResetFacialEvent>) -> Bool {
    let owner: ref<GameObject> = this.GetOwner();
    if IsDefined(owner) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(owner.GetGame());
        if IsDefined(sys) && sys.IsActiveLipSyncEntity(owner.GetEntityID()) {
            return true;
        }
    }
    return wrappedMethod(evt);
}

@addMethod(SurveillanceCameraControllerPS)
public final func CvConfigureSecurityCamera() -> Void {
    this.SetPlayerTakeOverControl(true);
    this.SetDeviceState(EDeviceStatus.ON);
    this.m_shouldScannerShowStatus = true;
    this.m_shouldScannerShowNetwork = true;
}

@addMethod(SecurityTurretControllerPS)
public final func CvConfigureSecurityTurret(detectionActive: Bool) -> Void {
    this.SetPlayerTakeOverControl(true);
    this.SetDeviceState(EDeviceStatus.ON);
    this.m_shouldScannerShowStatus = true;
    this.m_shouldScannerShowNetwork = true;
    if detectionActive {
        this.ExecutePSAction(this.ActionQuestSetDetectionToTrue());
    } else {
        this.ExecutePSAction(this.ActionQuestSetDetectionToFalse());
    }
}

@addMethod(SecurityTurretControllerPS)
public final func CvDisableSecurityTurret() -> Void {
    this.ExecutePSAction(this.ActionQuestSetDetectionToFalse());
    this.ExecutePSAction(this.ActionQuestForceDisabled());
    this.SetBlockSecurityWakeUp(true);
}

@addMethod(ScriptedPuppet)
public final func CvDisableVanillaInteraction() -> Void {
    if IsDefined(this.m_interactionComponent) {
        this.m_interactionComponent.Toggle(false);
    }
    let ic: ref<IComponent> = this.FindComponentByName(n"interactions");
    if IsDefined(ic) {
        ic.Toggle(false);
    }
}

@wrapMethod(GameObject)
public final static func PlayVoiceOver(
    self: ref<GameObject>,
    voName: CName,
    debugInitialContext: CName,
    opt delay: Float,
    opt answeringEntityID: EntityID,
    opt canPlayInVehicle: Bool
) -> DelayID {
    if IsDefined(self) {
        let des: ref<DynamicEntitySystem> = GameInstance.GetDynamicEntitySystem();
        if IsDefined(des) && (des.IsTagged(self.GetEntityID(), n"CrimsonVeilNPC") || des.IsTagged(self.GetEntityID(), n"CV_MistyAlley") || des.IsTagged(self.GetEntityID(), n"CV_MistyHolocall")) {
            return GetInvalidDelayID();
        }
    }
    return wrappedMethod(self, voName, debugInitialContext, delay, answeringEntityID, canPlayInVehicle);
}

@addMethod(NPCPuppet)
public final func SetCvTarotHandProps(showDeckLeft: Bool, showMoonRight: Bool, showHangmanRight: Bool, showTowerRight: Bool) -> Void {
    let cDeck: ref<IComponent> = this.FindComponentByName(n"cv_tarot_deck_left");
    if IsDefined(cDeck) {
        cDeck.Toggle(showDeckLeft);
    }
    let cMoon: ref<IComponent> = this.FindComponentByName(n"cv_tarot_card_moon");
    if IsDefined(cMoon) {
        cMoon.Toggle(showMoonRight);
    }
    let cHang: ref<IComponent> = this.FindComponentByName(n"cv_tarot_card_hangman");
    if IsDefined(cHang) {
        cHang.Toggle(showHangmanRight);
    }
    let cTower: ref<IComponent> = this.FindComponentByName(n"cv_tarot_card_tower");
    if IsDefined(cTower) {
        cTower.Toggle(showTowerRight);
    }
}

@addMethod(Entity)
public final func SetCvRooftopTableState(showDeck: Bool, showMoon: Bool, showHangman: Bool, showTower: Bool) -> Void {
    let cDeck: ref<IComponent> = this.FindComponentByName(n"cv_roof_card_deck");
    if IsDefined(cDeck) {
        cDeck.Toggle(showDeck);
    }
    let cMoon: ref<IComponent> = this.FindComponentByName(n"cv_roof_card_moon");
    if IsDefined(cMoon) {
        cMoon.Toggle(showMoon);
    }
    let cHang: ref<IComponent> = this.FindComponentByName(n"cv_roof_card_hangman");
    if IsDefined(cHang) {
        cHang.Toggle(showHangman);
    }
    let cTower: ref<IComponent> = this.FindComponentByName(n"cv_roof_card_tower");
    if IsDefined(cTower) {
        cTower.Toggle(showTower);
    }
}

@addMethod(Entity)
public final func SetCvOilShrineEvidenceTaken(taken: Bool) -> Void {
    let vis: Bool = !taken;
    let cCase: ref<IComponent> = this.FindComponentByName(n"cv_shrine_med_case_a");
    if IsDefined(cCase) {
        cCase.Toggle(vis);
    }
    let cSlip: ref<IComponent> = this.FindComponentByName(n"cv_shrine_transfer_slip");
    if IsDefined(cSlip) {
        cSlip.Toggle(vis);
    }
    let cGlow: ref<IComponent> = this.FindComponentByName(n"cv_shrine_med_glow");
    if IsDefined(cGlow) {
        cGlow.Toggle(vis);
    }
}

@addMethod(Entity)
public final func SetCvUvEmitterVisualState(flashActive: Bool, readyGlow: Bool) -> Void {
    let cFlash: ref<IComponent> = this.FindComponentByName(n"cv_uv_overload_flash");
    if IsDefined(cFlash) {
        cFlash.Toggle(flashActive);
    }
    let cCore: ref<IComponent> = this.FindComponentByName(n"cv_uv_core_cyan");
    if IsDefined(cCore) {
        cCore.Toggle(readyGlow);
    }
}

@addMethod(Entity)
public final func SetCvKabukiRelayTaken(taken: Bool) -> Void {
    let vis: Bool = !taken;
    let cShard: ref<IComponent> = this.FindComponentByName(n"cv_a1_relay_shard");
    if IsDefined(cShard) {
        cShard.Toggle(vis);
    }
    let cCyan: ref<IComponent> = this.FindComponentByName(n"cv_a1_relay_cyan");
    if IsDefined(cCyan) {
        cCyan.Toggle(vis);
    }
}

@addMethod(Entity)
public final func SetCvValdesDeskCipherTaken(taken: Bool) -> Void {
    let vis: Bool = !taken;
    let cCipher: ref<IComponent> = this.FindComponentByName(n"cv_a1_vdesk_cipher");
    if IsDefined(cCipher) {
        cCipher.Toggle(vis);
    }
    let cCyan: ref<IComponent> = this.FindComponentByName(n"cv_a1_vdesk_cyan");
    if IsDefined(cCyan) {
        cCyan.Toggle(vis);
    }
}

@addField(HudPhoneAvatarController)
private let m_cvMistyHoloFeed: wref<inkCanvas>;

@addField(HudPhoneAvatarController)
private let m_cvMistyHoloVideo: wref<inkVideo>;

@addField(HudPhoneAvatarController)
private let m_cvMistyHoloVideoIsTalk: Int32;

@addMethod(HudPhoneAvatarController)
public final func HideCvMistyHoloFeed(hideRoot: Bool) -> Void {
    if IsDefined(this.m_cvMistyHoloVideo) {
        if this.m_cvMistyHoloVideo.IsPlayingVideo() {
            this.m_cvMistyHoloVideo.Stop();
        }
        this.m_cvMistyHoloVideo.SetVisible(false);
    }
    this.m_cvMistyHoloVideoIsTalk = 0;
    if hideRoot && IsDefined(this.m_cvMistyHoloFeed) {
        this.m_cvMistyHoloFeed.SetVisible(false);
    }
}

@addMethod(HudPhoneAvatarController)
public final func SetCvMistyHoloSpeaking(isSpeaking: Bool) -> Void {
    if IsDefined(this.m_cvMistyHoloFeed) {
        this.m_cvMistyHoloFeed.SetVisible(true);
    }
    if !IsDefined(this.m_cvMistyHoloVideo) {
        return;
    }
    let desiredMode: Int32 = isSpeaking ? 2 : 1;
    let desiredPath: ResRef = isSpeaking ? r"crimson_veil\\movies\\cv_misty_holocall.bk2" : r"crimson_veil\\movies\\cv_misty_holocall_idle.bk2";
    this.m_cvMistyHoloVideo.SetVisible(true);
    if this.m_cvMistyHoloVideoIsTalk != desiredMode || !this.m_cvMistyHoloVideo.IsPlayingVideo() {
        if this.m_cvMistyHoloVideo.IsPlayingVideo() {
            this.m_cvMistyHoloVideo.Stop();
        }
        this.m_cvMistyHoloVideo.SetVideoPath(desiredPath);
        this.m_cvMistyHoloVideo.SetLoop(true);
        this.m_cvMistyHoloVideo.Play();
        this.m_cvMistyHoloVideoIsTalk = desiredMode;
    } else if this.m_cvMistyHoloVideo.IsPaused() {
        this.m_cvMistyHoloVideo.Resume();
    }
}

@addMethod(HudPhoneAvatarController)
public final func EnsureCvMistyHoloVisible(isSpeaking: Bool) -> Void {
    if IsDefined(this.m_cvMistyHoloFeed) {
        let needShow: Bool = !this.m_cvMistyHoloFeed.IsVisible();
        if IsDefined(this.m_cvMistyHoloVideo) && (!this.m_cvMistyHoloVideo.IsVisible() || !this.m_cvMistyHoloVideo.IsPlayingVideo()) {
            needShow = true;
        }
        if needShow {
            this.m_cvMistyHoloFeed.SetVisible(true);
            this.SetCvMistyHoloSpeaking(isSpeaking);
        }
    }
}

@wrapMethod(HudPhoneAvatarController)
protected cb func OnStateChanged(widget: wref<inkWidget>, oldState: CName, newState: CName) -> Bool {
    let res: Bool = wrappedMethod(widget, oldState, newState);
    let currentState: EHudPhoneVisibility = this.GetStateFromName(newState);
    if Equals(currentState, EHudPhoneVisibility.Hiding) || Equals(currentState, EHudPhoneVisibility.Invisible) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(GetGameInstance());
        if !IsDefined(sys) || !sys.IsMistyVideocallActive() || Equals(currentState, EHudPhoneVisibility.Invisible) {
            this.HideCvMistyHoloFeed(true);
        }
    }
    return res;
}

@wrapMethod(HudPhoneAvatarController)
private final func RefreshView(avatarID: TweakDBID, const contactName: script_ref<String>, mode: EHudAvatarMode) -> Void {
    wrappedMethod(avatarID, contactName, mode);

    let game: GameInstance = GetGameInstance();
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(game);
    if IsDefined(sys) {
        sys.RegisterPhoneAvatarController(this);
    }
    let isMistyContact: Bool = false;
    let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_ComDevice);
    if IsDefined(bb) {
        let callInfo: PhoneCallInformation = FromVariant<PhoneCallInformation>(bb.GetVariant(GetAllBlackboardDefs().UI_ComDevice.PhoneCallInformation));
        isMistyContact = Equals(callInfo.contactName, n"cv_misty") || (!IsNameValid(callInfo.contactName) && IsDefined(sys) && sys.IsMistyVideocallActive());
    } else if IsDefined(sys) && sys.IsMistyVideocallActive() {
        isMistyContact = true;
    }
    let showMistyFeed: Bool = IsDefined(sys) && sys.IsMistyVideocallActive() && isMistyContact && (Equals(mode, EHudAvatarMode.Holocall) || Equals(mode, EHudAvatarMode.Connecting));

    if showMistyFeed {
        inkWidgetRef.SetVisible(this.m_HolocallRenderTexture, false);
        if !IsDefined(this.m_cvMistyHoloFeed) {
            let parent: wref<inkCompoundWidget> = inkWidgetRef.Get(this.m_HolocallHolder) as inkCompoundWidget;
            if !IsDefined(parent) {
                parent = this.GetRootCompoundWidget();
            }
            if IsDefined(parent) {
                let feed: ref<inkCanvas> = new inkCanvas();
                feed.SetName(n"CvMistyHoloFeed");
                feed.SetHAlign(inkEHorizontalAlign.Left);
                feed.SetVAlign(inkEVerticalAlign.Top);
                feed.SetSize(440.0, 440.0);
                feed.Reparent(parent);

                let bg: ref<inkRectangle> = new inkRectangle();
                bg.SetAnchor(inkEAnchor.Fill);
                bg.SetTintColor(new HDRColor(0.05, 0.02, 0.04, 0.92));
                bg.Reparent(feed);

                let topBar: ref<inkRectangle> = new inkRectangle();
                topBar.SetAnchor(inkEAnchor.TopCenter);
                topBar.SetAnchorPoint(new Vector2(0.50, 0.00));
                topBar.SetMargin(new inkMargin(0.0, 14.0, 0.0, 0.0));
                topBar.SetSize(396.0, 3.0);
                topBar.SetTintColor(new HDRColor(0.95, 0.28, 0.38, 0.88));
                topBar.Reparent(feed);

                let header: ref<inkText> = new inkText();
                header.SetName(n"CvHoloHeader");
                header.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
                header.SetFontStyle(n"Semi-Bold");
                header.SetFontSize(20);
                header.SetAnchor(inkEAnchor.TopCenter);
                header.SetAnchorPoint(new Vector2(0.50, 0.00));
                header.SetHorizontalAlignment(textHorizontalAlignment.Center);
                header.SetMargin(new inkMargin(0.0, 22.0, 0.0, 0.0));
                header.SetTintColor(new HDRColor(0.32, 0.94, 1.00, 0.92));
                header.SetText("WATSON // ESOTERICA");
                header.Reparent(feed);

                let portrait: ref<inkImage> = new inkImage();
                portrait.SetName(n"CvMistyPortrait");
                portrait.SetAnchor(inkEAnchor.Centered);
                portrait.SetAnchorPoint(new Vector2(0.50, 0.50));
                portrait.SetMargin(new inkMargin(0.0, 2.0, 0.0, 0.0));
                portrait.SetSize(348.0, 348.0);
                portrait.SetTintColor(new HDRColor(1.00, 1.00, 1.00, 1.00));
                portrait.SetAtlasResource(r"base\\gameplay\\gui\\common\\icons\\avatars\\avatars1.inkatlas");
                portrait.SetTexturePart(n"misty");
                portrait.Reparent(feed);

                let video: ref<inkVideo> = new inkVideo();
                video.SetName(n"CvMistyHoloVideo");
                video.SetAnchor(inkEAnchor.Centered);
                video.SetAnchorPoint(new Vector2(0.50, 0.50));
                video.SetMargin(new inkMargin(0.0, 2.0, 0.0, 0.0));
                video.SetSize(348.0, 348.0);
                video.SetFitToContent(false);
                video.SetTintColor(new HDRColor(1.00, 1.00, 1.00, 1.00));
                video.SetLoop(true);
                video.SetSyncToAudio(false);
                video.ForceVideoFrameRate(true);
                video.SetVisible(false);
                video.Reparent(feed);
                this.m_cvMistyHoloVideo = video;

                let footer: ref<inkText> = new inkText();
                footer.SetName(n"CvHoloFooter");
                footer.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
                footer.SetFontStyle(n"Bold");
                footer.SetFontSize(22);
                footer.SetAnchor(inkEAnchor.BottomCenter);
                footer.SetAnchorPoint(new Vector2(0.50, 1.00));
                footer.SetHorizontalAlignment(textHorizontalAlignment.Center);
                footer.SetMargin(new inkMargin(0.0, 0.0, 0.0, 14.0));
                footer.SetTintColor(new HDRColor(0.96, 0.82, 0.56, 0.95));
                footer.SetText("MISTY OLSZEWSKI");
                footer.Reparent(feed);

                this.m_cvMistyHoloFeed = feed;
                this.m_cvMistyHoloVideoIsTalk = 0;
            }
        }
        if IsDefined(this.m_cvMistyHoloFeed) {
            this.m_cvMistyHoloFeed.SetVisible(true);
        }
        if Equals(mode, EHudAvatarMode.Holocall) {
            this.SetCvMistyHoloSpeaking(sys.IsMistyCurrentlySpeakingInCall());
        } else {
            this.HideCvMistyHoloFeed(false);
        }
    } else {
        this.HideCvMistyHoloFeed(true);
    }
}

@wrapMethod(PhoneSystem)
private final func OnTriggerCall(request: ref<questTriggerCallRequest>) -> Void {
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(this.GetGameInstance());
    if IsDefined(sys) && sys.ShouldDeferVanillaCall(request) {
        return;
    }
    wrappedMethod(request);
}

@wrapMethod(PhoneSystem)
private final func OnPickupPhone(request: ref<PickupPhoneRequest>) -> Void {
    wrappedMethod(request);
    let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(this.GetGameInstance());
    if !IsDefined(sys) {
        return;
    }
    if Equals(request.CallInformation.contactName, n"cv_misty") {
        sys.OnCustomCallPickedUp(request.CallInformation.contactName, request.shouldBeRejected);
    } else if sys.IsMistyVideocallActive() {
        sys.YieldMistyCallToVanilla();
    }
}

@wrapMethod(gameuiCrosshairContainerController)
protected cb func OnInitialize() -> Bool {
    let ok: Bool = wrappedMethod();
    let player: ref<GameObject> = this.GetPlayerControlledObject();
    if IsDefined(player) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(player.GetGame());
        if IsDefined(sys) {
            sys.RegisterCrosshairController(this);
            if sys.IsHoloRecordStudioActive() {
                let rootW: wref<inkWidget> = this.GetRootWidget();
                if IsDefined(rootW) {
                    rootW.SetVisible(false);
                }
            }
        }
    }
    return ok;
}

@wrapMethod(CrosshairGameControllerPersistentDot)
protected cb func OnInitialize() -> Bool {
    let ok: Bool = wrappedMethod();
    let player: ref<GameObject> = this.GetPlayerControlledObject();
    if IsDefined(player) {
        let sys: ref<CrimsonVeilSystem> = CrimsonVeilSystem.GetInstance(player.GetGame());
        if IsDefined(sys) {
            sys.RegisterPersistentDotController(this);
            if sys.IsHoloRecordStudioActive() {
                let rootW: wref<inkWidget> = this.GetRootWidget();
                if IsDefined(rootW) {
                    rootW.SetVisible(false);
                }
            }
        }
    }
    return ok;
}
