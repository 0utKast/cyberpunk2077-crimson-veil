-- Velo Carmesí / Crimson Veil — Panel CET de Depuración y Estudio (v0.9.0 Prólogo + Acto I + Acto II)

local CrimsonVeilUI = {
    overlayOpen = false,
    showPanel = false,
    pendingStudioShoot = false,
    captureLabel = "Escena",
    lastCapture = "",
    captureCount = 0,
    statusText = "Panel listo (Velo Carmesí v0.9.0 - Prólogo + Acto I pulido + Acto II: Liturgia de Ceniza).",
}

local function captureCurrentPosition(tag)
    local player = Game and Game.GetPlayer and Game.GetPlayer() or nil
    if not player then
        CrimsonVeilUI.statusText = "Error: jugador no cargado para capturar posición."
        return
    end
    local p = player:GetWorldPosition()
    local yaw = player:GetWorldYaw()
    local timeStr = "--:--"
    local okTime, gt = pcall(function()
        return Game.GetTimeSystem():GetGameTime()
    end)
    if okTime and gt and GameTime and GameTime.Hours and GameTime.Minutes then
        timeStr = string.format("%02d:%02d", GameTime.Hours(gt), GameTime.Minutes(gt))
    end
    local vecStr = string.format("new Vector4(%.2f, %.2f, %.2f, 1.00)", p.x, p.y, p.z)
    local entry = string.format("[%s] [%s] pos=(%.2f, %.2f, %.2f) yaw=%.1f hora=%s | %s", os.date("%Y-%m-%d %H:%M:%S"), tag or "Escena", p.x, p.y, p.z, yaw, timeStr, vecStr)
    local f = io.open("captured_coords.txt", "a")
    if f then
        f:write(entry .. "\n")
        f:close()
    end
    pcall(function()
        ImGui.SetClipboardText(entry)
    end)
    print("[CrimsonVeil][CAPTURE] " .. entry)
    CrimsonVeilUI.captureCount = CrimsonVeilUI.captureCount + 1
    CrimsonVeilUI.lastCapture = entry
    CrimsonVeilUI.statusText = string.format("Posición capturada (%s) en captured_coords.txt y portapapeles (#%d).", tag or "Escena", CrimsonVeilUI.captureCount)
end

registerHotkey("cv_capture_pos", "Capturar Posición Aquí (Velo Carmesí)", function()
    captureCurrentPosition("Hotkey")
end)

local function withSystem(fn)
    if not Game or not Game.GetScriptableSystemsContainer then
        CrimsonVeilUI.statusText = "Error: Juego aún no inicializado."
        return
    end
    local sys = Game.GetScriptableSystemsContainer():Get("CrimsonVeil.CrimsonVeilSystem")
    if not sys then
        CrimsonVeilUI.statusText = "Error: CrimsonVeil.CrimsonVeilSystem no cargado."
        return
    end
    fn(sys)
end

registerHotkey("cv_toggle_panel", "Mostrar/Ocultar panel de Estudio Velo Carmesí", function()
    CrimsonVeilUI.showPanel = not CrimsonVeilUI.showPanel
end)

registerHotkey("cv_studio_action", "Estudio Holocall: Iniciar Actuación de Misty", function()
    withSystem(function(sys)
        sys:EnsureStudioUnblurredAndLive()
        sys:PlayHolocallRecordingLoop(0.5)
        CrimsonVeilUI.statusText = "Actuación iniciada por hotkey."
    end)
end)

registerForEvent("onInit", function()
    print("[CrimsonVeil] Panel CET v0.9.0 inicializado (panel único activo).")
end)

registerForEvent("onOverlayOpen", function()
    CrimsonVeilUI.overlayOpen = true
end)

registerForEvent("onOverlayClose", function()
    CrimsonVeilUI.overlayOpen = false
    if CrimsonVeilUI.pendingStudioShoot then
        CrimsonVeilUI.pendingStudioShoot = false
        withSystem(function(sys)
            sys:EnsureStudioUnblurredAndLive()
            sys:PlayHolocallRecordingLoop(1.5)
        end)
    end
end)

registerForEvent("onDraw", function()
    if not CrimsonVeilUI.overlayOpen or not CrimsonVeilUI.showPanel then
        return
    end

    local cond = ImGuiCond and ImGuiCond.FirstUseEver or 4
    ImGui.SetNextWindowPos(60, 60, cond)
    local open, keepOpen = ImGui.Begin("Velo Carmesí / Crimson Veil - Estudio (v0.9.0)", CrimsonVeilUI.showPanel, ImGuiWindowFlags.AlwaysAutoResize)
    if keepOpen == false then
        CrimsonVeilUI.showPanel = false
    end
    if open then
        ImGui.Text("v0.9.0 - Prólogo + Acto I + Acto II: Liturgia de Ceniza (Biotechnica Flats & Búnker Badlands)")
        if Game and Game.GetQuestsSystem then
            local qs = Game.GetQuestsSystem()
            local st = qs:GetFactStr("cv_r2_state")
            local done = qs:GetFactStr("cv_r2_done")
            local a1st = qs:GetFactStr("cv_a1_state")
            local a2st = qs:GetFactStr("cv_a2_state")
            local a2end = qs:GetFactStr("cv_a2_ending")
            local a2done = qs:GetFactStr("cv_a2_done")
            local b1 = qs:GetFactStr("cv_a1_clue_blood")
            local b2 = qs:GetFactStr("cv_a1_clue_tarot")
            local b3 = qs:GetFactStr("cv_a1_clue_relay")
            local qR = qs:GetFactStr("cv_a1_asked_role")
            local qS = qs:GetFactStr("cv_a1_asked_sect")
            local qL = qs:GetFactStr("cv_a1_asked_leads")
            local cph = qs:GetFactStr("cv_a1_has_cipher")
            ImGui.Text(string.format("Prólogo=%d (%d) | Acto I=%d | Pistas=[%d/%d/%d] Valdés=[%d/%d/%d] Pincho=%d | Acto II=%d (Final=%d Done=%d)", st, done, a1st, b1, b2, b3, qR, qS, qL, cph, a2st, a2end, a2done))
        end
        ImGui.Separator()
        if ImGui.Button(">>> PRUEBA DIRECTA: NIVEL 1 (SUBNIVEL -1 · INICIO LIMPIO) <<<") then
            withSystem(function(sys)
                sys:DebugTeleportAct2Sub1()
                CrimsonVeilUI.statusText = "Prueba Nivel 1 iniciada: Subnivel -1 limpio (1/3 Sello Alfa)."
            end)
        end
        local sub1Ok, sub1Txt = pcall(function()
            if Game and Game.GetPlayer and Game.GetPlayer() and Game.GetScriptableSystemsContainer then
                local sys = Game.GetScriptableSystemsContainer():Get("CrimsonVeil.CrimsonVeilSystem")
                if sys then
                    return sys:GetSub1DebugStatus()
                end
            end
            return "Sub1: esperando partida cargada"
        end)
        ImGui.Text(sub1Ok and tostring(sub1Txt) or "Sub1: error leyendo estado")
        if ImGui.Button(">>> PRUEBA DIRECTA: NIVEL 2 (SUBNIVEL -2 · INICIO LIMPIO) <<<") then
            withSystem(function(sys)
                sys:DebugTeleportAct2Sub2()
                CrimsonVeilUI.statusText = "Prueba Nivel 2 iniciada: Subnivel -2 limpio (1/5 Emisor UV)."
            end)
        end
        local sub2Ok, sub2Txt = pcall(function()
            if Game and Game.GetPlayer and Game.GetPlayer() and Game.GetScriptableSystemsContainer then
                local sys = Game.GetScriptableSystemsContainer():Get("CrimsonVeil.CrimsonVeilSystem")
                if sys then
                    return sys:GetSub2DebugStatus()
                end
            end
            return "Sub2: esperando partida cargada"
        end)
        ImGui.Text(sub2Ok and tostring(sub2Txt) or "Sub2: error leyendo estado")
        ImGui.Separator()
        ImGui.Text("Atajos del Prólogo (Watson y Northside):")

        if ImGui.Button("Lanzar Llamada de Misty") then
            withSystem(function(sys)
                sys:DebugTriggerIntroCall()
                CrimsonVeilUI.statusText = "Llamada entrante de Misty lanzada."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Callejón de Esoterica") then
            withSystem(function(sys)
                sys:DebugTeleportEsoterica()
                CrimsonVeilUI.statusText = "Teletransportado al callejón trasero de Esoterica."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Azotea de Misty (22:00)") then
            withSystem(function(sys)
                sys:DebugTeleportRooftopNight()
                CrimsonVeilUI.statusText = "Teletransportado a la azotea de Misty (22:00)."
            end)
        end

        if ImGui.Button("TP: Depósitos de Northside") then
            withSystem(function(sys)
                sys:DebugTeleportOilfieldsNight()
                CrimsonVeilUI.statusText = "Teletransportado a los Depósitos de Northside (noche)."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Debrief Azotea (Final)") then
            withSystem(function(sys)
                sys:DebugTeleportDebriefNight()
                CrimsonVeilUI.statusText = "Teletransportado a la azotea listo para el cierre del Prólogo (etapa 50)."
            end)
        end
        if ImGui.Button("Abrir Tarot / Códice UI") then
            withSystem(function(sys)
                sys:OpenTarotSpreadPopup(true)
                CrimsonVeilUI.statusText = "Popup interactivo de Tarot y Códice abierto."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Reiniciar Prólogo") then
            withSystem(function(sys)
                sys:DebugResetPhase0()
                CrimsonVeilUI.statusText = "Prólogo reiniciado desde la llamada inicial."
            end)
        end

        ImGui.Separator()
        ImGui.Text("Atajos del Acto I (El Pulso del Lote NOX-9):")
        if ImGui.Button("Acto I: Llamada de Misty") then
            withSystem(function(sys)
                sys:DebugTriggerAct1Call()
                CrimsonVeilUI.statusText = "Holollamada puente de Acto I (Misty -> lote NOX-9-K4 y Valdés) lanzada."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Canal de Kabuki (3 Pistas)") then
            withSystem(function(sys)
                sys:DebugTeleportKabuki()
                CrimsonVeilUI.statusText = "Teletransportado al embarcadero de Kabuki frente a las 3 pistas forenses."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Dr. Valdés (Little China Norte)") then
            withSystem(function(sys)
                sys:DebugTeleportValdes()
                CrimsonVeilUI.statusText = "Teletransportado a Little China Norte (Dr. Adrián Valdés)."
            end)
        end
        if ImGui.Button("TP: Muelle Oeste (Noche)") then
            withSystem(function(sys)
                sys:DebugTeleportPier(true)
                CrimsonVeilUI.statusText = "Teletransportado a Northside Docks Oeste (modo nocturno)."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Muelle Oeste (Día)") then
            withSystem(function(sys)
                sys:DebugTeleportPier(false)
                CrimsonVeilUI.statusText = "Teletransportado a Northside Docks Oeste (modo diurno)."
            end)
        end
        if ImGui.Button("TP: Azotea (Cierre Acto I)") then
            withSystem(function(sys)
                sys:DebugTeleportAct1Debrief()
                CrimsonVeilUI.statusText = "Teletransportado a la azotea de Misty para el cierre del Acto I."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Reiniciar Acto I") then
            withSystem(function(sys)
                sys:DebugResetAct1()
                CrimsonVeilUI.statusText = "Acto I reiniciado desde la llamada puente de Misty."
            end)
        end

        ImGui.Separator()
        ImGui.Text("Atajos del Acto II (Liturgia de Ceniza - Badlands):")
        if ImGui.Button("Acto II: Llamada de Misty") then
            withSystem(function(sys)
                sys:DebugTriggerAct2Call()
                CrimsonVeilUI.statusText = "Holollamada puente de Acto II (Misty -> Biotechnica Flats) lanzada."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Convoy Flats (3 Pistas)") then
            withSystem(function(sys)
                sys:DebugTeleportAct2Flats()
                CrimsonVeilUI.statusText = "Teletransportado al convoy abatido de Biotechnica Flats (3 pistas)."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("TP: Búnker & Lucía") then
            withSystem(function(sys)
                sys:DebugTeleportAct2Bunker()
                CrimsonVeilUI.statusText = "Teletransportado al acceso del búnker de Biotechnica (Lucía Reyes)."
            end)
        end
        if ImGui.Button("TP: Nivel 1 (Subnivel -1)") then
            withSystem(function(sys)
                sys:DebugTeleportAct2Sub1()
                CrimsonVeilUI.statusText = "Teletransportado al Subnivel -1 (Nivel 1 limpio)."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Reiniciar Acto II") then
            withSystem(function(sys)
                sys:DebugResetAct2()
                CrimsonVeilUI.statusText = "Acto II reiniciado desde la llamada puente de Misty."
            end)
        end

        ImGui.Separator()
        ImGui.Text("Pruebas en vivo: Lip-Sync JALI 30 FPS y Gestos (Misty)")
        if ImGui.Button("Misty JALI (#18 - Lucía)") then
            withSystem(function(sys)
                sys:DebugTestMistyLipSync(18)
                CrimsonVeilUI.statusText = "JALI Lip-Sync Clip 18 activado en Misty."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Misty Gesto (#25)") then
            withSystem(function(sys)
                sys:DebugTestMistyGesture(25)
                CrimsonVeilUI.statusText = "Gesto rh_flick__01 (#25) enviado a Misty."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("Parar Facial") then
            withSystem(function(sys)
                sys:DebugTestMistyLipSync(0)
                CrimsonVeilUI.statusText = "Test facial JALI detenido (vuelta a reposo)."
            end)
        end

        ImGui.Separator()
        ImGui.Text("Estudio de Grabación Holocall (para vídeo .bk2):")
        if ImGui.Button("[1] Preparar Estudio de Misty") then
            CrimsonVeilUI.pendingStudioShoot = false
            withSystem(function(sys)
                sys:StartHolocallRecordingStudio()
                CrimsonVeilUI.statusText = "Estudio listo: cierra CET para encuadrar con nitidez (sin pausa ni desenfoque)."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("[2] Armar Actuación (arranca al cerrar CET)") then
            withSystem(function(sys)
                if not sys:IsHoloRecordStudioActive() then
                    sys:StartHolocallRecordingStudio()
                else
                    sys:EnsureStudioUnblurredAndLive()
                end
                CrimsonVeilUI.pendingStudioShoot = true
                CrimsonVeilUI.statusText = "ARMADO: cierra el overlay CET y Misty empezará a hablar 1.5 s después."
            end)
        end
        ImGui.SameLine()
        if ImGui.Button("[3] Salir del Estudio") then
            CrimsonVeilUI.pendingStudioShoot = false
            withSystem(function(sys)
                sys:StopHolocallRecordingStudio()
                CrimsonVeilUI.statusText = "Estudio de grabación cerrado y HUD restaurado."
            end)
        end

        ImGui.Separator()
        ImGui.Text("Captura de Coordenadas en Vivo (guarda en captured_coords.txt + portapapeles):")
        if ImGui.Button("Capturar Posición Aquí (NPC)") then
            captureCurrentPosition("NPC")
        end
        ImGui.SameLine()
        if ImGui.Button("+ Mesa / Prop") then
            captureCurrentPosition("Prop")
        end
        ImGui.SameLine()
        if ImGui.Button("+ Llegada / TP") then
            captureCurrentPosition("Llegada")
        end
        ImGui.SameLine()
        if ImGui.Button("+ Idea / Trama") then
            captureCurrentPosition("Idea")
        end
        if CrimsonVeilUI.lastCapture ~= "" then
            ImGui.TextWrapped("Última captura: " .. CrimsonVeilUI.lastCapture)
        end

        ImGui.Separator()
        ImGui.Text(CrimsonVeilUI.statusText)
    end
    ImGui.End()
end)
