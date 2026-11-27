// Velo Carmesí / Crimson Veil — Interfaz Interactiva de Tirada de Tarot y Códice (Codeware InGamePopup)
// Estética Gótico-Noir (Obsidiana + Oro Viejo + Carmesí)
module CrimsonVeil

import Codeware.UI.*

public class CrimsonTarotPopup extends InGamePopup {
    private let m_sys: wref<CrimsonVeilSystem>;
    private let m_readingMode: Bool;
    private let m_activeTab: Int32; // 0 = Tirada de 3 Arcanos, 1 = Códice de Campo
    private let m_selectedCard: Int32; // 1 = La Luna, 2 = El Colgado Invertido, 3 = La Torre
    private let m_lensMode: Int32; // 1 = Forense (Razón), 2 = Simbólico (Misty)
    private let m_selectedShard: Int32; // 1..6
    private let m_inputArmed: Bool;
    private let m_notifiedClose: Bool;

    private let m_tabSpreadBg: wref<inkRectangle>;
    private let m_tabCodexBg: wref<inkRectangle>;
    private let m_spreadPane: wref<inkCanvas>;
    private let m_codexPane: wref<inkCanvas>;

    private let m_lensBtnBg: wref<inkRectangle>;
    private let m_lensBtnText: wref<inkText>;
    private let m_confirmBtnBg: wref<inkRectangle>;
    private let m_confirmBtnText: wref<inkText>;
    private let m_closeBtnBg: wref<inkRectangle>;

    private let m_cardRims: array<wref<inkRectangle>>;
    private let m_cardBgs: array<wref<inkRectangle>>;
    private let m_cardTitles: array<wref<inkText>>;
    private let m_cardTags: array<wref<inkText>>;
    private let m_detailTitle: wref<inkText>;
    private let m_detailTag: wref<inkText>;
    private let m_detailBody: wref<inkText>;

    private let m_shardRowRims: array<wref<inkRectangle>>;
    private let m_shardRowBgs: array<wref<inkRectangle>>;
    private let m_shardRowTexts: array<wref<inkText>>;
    private let m_shardTitle: wref<inkText>;
    private let m_shardBody: wref<inkText>;

    public final func Setup(sys: ref<CrimsonVeilSystem>, readingMode: Bool, initialCard: Int32, initialLens: Int32) -> Void {
        this.m_sys = sys;
        this.m_readingMode = readingMode;
        this.m_activeTab = readingMode ? 0 : 1;
        this.m_selectedCard = (initialCard >= 1 && initialCard <= 3) ? initialCard : 1;
        this.m_lensMode = (initialLens == 2) ? 2 : 1;
        this.m_selectedShard = 1;
        this.m_inputArmed = false;
        this.m_notifiedClose = false;
    }

    public func UseCursor() -> Bool {
        return true;
    }

    private final func Loc(key: CName, fallback: String) -> String {
        if IsDefined(this.m_sys) {
            return this.m_sys.GetLoc(key, fallback);
        }
        return fallback;
    }

    protected func CreateVignette() -> Void {
        let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
        if !IsDefined(root) {
            return;
        }
        let backdrop: ref<inkRectangle> = new inkRectangle();
        backdrop.SetName(n"cv_tarot_backdrop");
        backdrop.SetAnchor(inkEAnchor.Fill);
        backdrop.SetTintColor(new HDRColor(0.015, 0.008, 0.012, 0.88));
        backdrop.Reparent(root);
    }

    protected func CreateContainer() -> Void {
        let root: ref<inkCompoundWidget> = this.GetRootCompoundWidget();
        if !IsDefined(root) {
            return;
        }

        let container: ref<inkCanvas> = new inkCanvas();
        container.SetName(n"cv_tarot_container");
        container.SetAnchor(inkEAnchor.Centered);
        container.SetAnchorPoint(new Vector2(0.50, 0.50));
        container.SetSize(3040.0, 1720.0);
        container.SetInteractive(true);
        container.Reparent(root);

        this.m_container = container;
        this.SetContainerWidget(container);

        // Marco exterior carmesí y oro viejo
        let outerRim: ref<inkRectangle> = new inkRectangle();
        outerRim.SetAnchor(inkEAnchor.Fill);
        outerRim.SetTintColor(new HDRColor(0.72, 0.14, 0.22, 0.92));
        outerRim.Reparent(container);

        let outerBody: ref<inkRectangle> = new inkRectangle();
        outerBody.SetAnchor(inkEAnchor.Fill);
        outerBody.SetMargin(new inkMargin(4.0, 4.0, 4.0, 4.0));
        outerBody.SetTintColor(new HDRColor(0.020, 0.014, 0.022, 0.99));
        outerBody.Reparent(container);

        let goldRim: ref<inkRectangle> = new inkRectangle();
        goldRim.SetAnchor(inkEAnchor.Fill);
        goldRim.SetMargin(new inkMargin(18.0, 18.0, 18.0, 18.0));
        goldRim.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.65));
        goldRim.Reparent(container);

        let innerCanvas: ref<inkCanvas> = new inkCanvas();
        innerCanvas.SetName(n"cv_tarot_inner");
        innerCanvas.SetAnchor(inkEAnchor.Fill);
        innerCanvas.SetMargin(new inkMargin(21.0, 21.0, 21.0, 21.0));
        innerCanvas.Reparent(container);

        let innerBg: ref<inkRectangle> = new inkRectangle();
        innerBg.SetAnchor(inkEAnchor.Fill);
        innerBg.SetTintColor(new HDRColor(0.014, 0.010, 0.016, 0.99));
        innerBg.Reparent(innerCanvas);

        // Cabecera superior
        let headerCanvas: ref<inkCanvas> = new inkCanvas();
        headerCanvas.SetAnchor(inkEAnchor.TopFillHorizontaly);
        headerCanvas.SetSize(2998.0, 152.0);
        headerCanvas.Reparent(innerCanvas);

        let headerBg: ref<inkRectangle> = new inkRectangle();
        headerBg.SetAnchor(inkEAnchor.Fill);
        headerBg.SetTintColor(new HDRColor(0.055, 0.016, 0.026, 0.84));
        headerBg.Reparent(headerCanvas);

        let titleText: ref<inkText> = new inkText();
        titleText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        titleText.SetFontStyle(n"Bold");
        titleText.SetFontSize(48);
        titleText.SetAnchor(inkEAnchor.TopLeft);
        titleText.SetMargin(new inkMargin(40.0, 22.0, 0.0, 0.0));
        titleText.SetTintColor(new HDRColor(0.95, 0.78, 0.36, 1.0));
        titleText.SetText(this.Loc(n"cv_ui_title", "VELO CARMESÍ // TIRADA DE ARCANOS Y CÓDICE"));
        titleText.Reparent(headerCanvas);

        let subText: ref<inkText> = new inkText();
        subText.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        subText.SetFontStyle(n"Medium");
        subText.SetFontSize(28);
        subText.SetAnchor(inkEAnchor.TopLeft);
        subText.SetMargin(new inkMargin(40.0, 88.0, 0.0, 0.0));
        subText.SetTintColor(new HDRColor(0.86, 0.30, 0.38, 0.95));
        subText.SetText(this.Loc(n"cv_ui_subtitle", "SIMBOLISMO ESOTÉRICO FRENTE A HEMATOLOGÍA CLANDESTINA · AZOTEA DE MISTY"));
        subText.Reparent(headerCanvas);

        // Botones de pestaña arriba a la derecha
        let tabRow: ref<inkHorizontalPanel> = new inkHorizontalPanel();
        tabRow.SetAnchor(inkEAnchor.TopRight);
        tabRow.SetAnchorPoint(new Vector2(1.0, 0.0));
        tabRow.SetFitToContent(true);
        tabRow.SetMargin(new inkMargin(0.0, 38.0, 40.0, 0.0));
        tabRow.SetChildMargin(new inkMargin(18.0, 0.0, 0.0, 0.0));
        tabRow.Reparent(headerCanvas);

        let tmpSpreadLbl: wref<inkText>;
        this.m_tabSpreadBg = this.CreateActionButton(
            tabRow,
            n"cv_tab_spread",
            this.Loc(n"cv_ui_tab_spread", "TIRADA DE ARCANOS"),
            410.0,
            new HDRColor(0.95, 0.78, 0.36, 1.0),
            tmpSpreadLbl
        );
        let tmpCodexLbl: wref<inkText>;
        this.m_tabCodexBg = this.CreateActionButton(
            tabRow,
            n"cv_tab_codex",
            this.Loc(n"cv_ui_tab_codex", "CÓDICE DE CAMPO [PINCHOS]"),
            510.0,
            new HDRColor(0.92, 0.36, 0.44, 1.0),
            tmpCodexLbl
        );

        let headerRule: ref<inkRectangle> = new inkRectangle();
        headerRule.SetAnchor(inkEAnchor.TopFillHorizontaly);
        headerRule.SetMargin(new inkMargin(0.0, 152.0, 0.0, 0.0));
        headerRule.SetSize(2998.0, 3.0);
        headerRule.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.80));
        headerRule.Reparent(innerCanvas);

        // Contenido principal
        let contentArea: ref<inkCanvas> = new inkCanvas();
        contentArea.SetAnchor(inkEAnchor.TopFillHorizontaly);
        contentArea.SetMargin(new inkMargin(0.0, 158.0, 0.0, 0.0));
        contentArea.SetSize(2998.0, 1372.0);
        contentArea.Reparent(innerCanvas);

        this.BuildSpreadPane(contentArea);
        this.BuildCodexPane(contentArea);

        // Pie de página con conmutador de Enfoque y Confirmación
        let footerRule: ref<inkRectangle> = new inkRectangle();
        footerRule.SetAnchor(inkEAnchor.TopFillHorizontaly);
        footerRule.SetMargin(new inkMargin(0.0, 1534.0, 0.0, 0.0));
        footerRule.SetSize(2998.0, 3.0);
        footerRule.SetTintColor(new HDRColor(0.72, 0.14, 0.22, 0.72));
        footerRule.Reparent(innerCanvas);

        let footerCanvas: ref<inkCanvas> = new inkCanvas();
        footerCanvas.SetAnchor(inkEAnchor.BottomFillHorizontaly);
        footerCanvas.SetSize(2998.0, 140.0);
        footerCanvas.Reparent(innerCanvas);

        let footerBg: ref<inkRectangle> = new inkRectangle();
        footerBg.SetAnchor(inkEAnchor.Fill);
        footerBg.SetTintColor(new HDRColor(0.036, 0.012, 0.020, 0.85));
        footerBg.Reparent(footerCanvas);

        let footerLeft: ref<inkHorizontalPanel> = new inkHorizontalPanel();
        footerLeft.SetAnchor(inkEAnchor.CenterLeft);
        footerLeft.SetAnchorPoint(new Vector2(0.0, 0.5));
        footerLeft.SetFitToContent(true);
        footerLeft.SetMargin(new inkMargin(40.0, 0.0, 0.0, 0.0));
        footerLeft.SetChildMargin(new inkMargin(0.0, 0.0, 18.0, 0.0));
        footerLeft.Reparent(footerCanvas);

        this.m_lensBtnBg = this.CreateActionButton(
            footerLeft,
            n"cv_btn_lens",
            this.Loc(n"cv_ui_lens_forensic", "ENFOQUE: FORENSE [RAZÓN]"),
            580.0,
            new HDRColor(0.38, 0.86, 0.96, 1.0),
            this.m_lensBtnText
        );

        let footerRight: ref<inkHorizontalPanel> = new inkHorizontalPanel();
        footerRight.SetAnchor(inkEAnchor.CenterRight);
        footerRight.SetAnchorPoint(new Vector2(1.0, 0.5));
        footerRight.SetFitToContent(true);
        footerRight.SetMargin(new inkMargin(0.0, 0.0, 40.0, 0.0));
        footerRight.SetChildMargin(new inkMargin(18.0, 0.0, 0.0, 0.0));
        footerRight.Reparent(footerCanvas);

        this.m_confirmBtnBg = this.CreateActionButton(
            footerRight,
            n"cv_btn_confirm",
            this.m_readingMode
                ? this.Loc(n"cv_ui_confirm", "CONFIRMAR TIRADA Y RASTREAR EL ALTAR")
                : this.Loc(n"cv_ui_close", "CERRAR [ESC]"),
            this.m_readingMode ? 730.0 : 340.0,
            new HDRColor(0.98, 0.80, 0.30, 1.0),
            this.m_confirmBtnText
        );
        if this.m_readingMode {
            let tmpCloseLbl: wref<inkText>;
            this.m_closeBtnBg = this.CreateActionButton(
                footerRight,
                n"cv_btn_close",
                this.Loc(n"cv_ui_close", "CERRAR [ESC]"),
                280.0,
                new HDRColor(0.86, 0.42, 0.46, 1.0),
                tmpCloseLbl
            );
        }
    }

    private final func BuildSpreadPane(parent: ref<inkCanvas>) -> Void {
        let pane: ref<inkCanvas> = new inkCanvas();
        pane.SetName(n"cv_spread_pane");
        pane.SetAnchor(inkEAnchor.Fill);
        pane.Reparent(parent);
        this.m_spreadPane = pane;

        let cardsRow: ref<inkHorizontalPanel> = new inkHorizontalPanel();
        cardsRow.SetAnchor(inkEAnchor.TopLeft);
        cardsRow.SetFitToContent(true);
        cardsRow.SetMargin(new inkMargin(123.0, 40.0, 123.0, 0.0));
        cardsRow.SetChildMargin(new inkMargin(0.0, 0.0, 56.0, 0.0));
        cardsRow.Reparent(pane);

        ArrayClear(this.m_cardRims);
        ArrayClear(this.m_cardBgs);
        ArrayClear(this.m_cardTitles);
        ArrayClear(this.m_cardTags);

        let idx: Int32 = 1;
        while idx <= 3 {
            let cardBtn: ref<inkCanvas> = new inkCanvas();
            cardBtn.SetName(StringToName("cv_card_" + IntToString(idx)));
            cardBtn.SetSize(880.0, 580.0);
            cardBtn.SetInteractive(true);
            cardBtn.RegisterToCallback(n"OnRelease", this, n"OnCardRelease");
            cardBtn.Reparent(cardsRow);

            let rim: ref<inkRectangle> = new inkRectangle();
            rim.SetAnchor(inkEAnchor.Fill);
            rim.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.65));
            rim.Reparent(cardBtn);
            ArrayPush(this.m_cardRims, rim);

            let bg: ref<inkRectangle> = new inkRectangle();
            bg.SetAnchor(inkEAnchor.Fill);
            bg.SetMargin(new inkMargin(4.0, 4.0, 4.0, 4.0));
            bg.SetTintColor(new HDRColor(0.036, 0.016, 0.028, 0.96));
            bg.Reparent(cardBtn);
            ArrayPush(this.m_cardBgs, bg);

            // Marco e ilustración oficial del Arcano desde base\gameplay\gui\fullscreen\tarot\atlas_tarotbig*.inkatlas
            let cardArtFrame: ref<inkRectangle> = new inkRectangle();
            cardArtFrame.SetAnchor(inkEAnchor.TopCenter);
            cardArtFrame.SetAnchorPoint(new Vector2(0.5, 0.0));
            cardArtFrame.SetMargin(new inkMargin(0.0, 22.0, 0.0, 0.0));
            cardArtFrame.SetSize(218.0, 373.0);
            cardArtFrame.SetTintColor(new HDRColor(0.07, 0.05, 0.09, 0.96));
            cardArtFrame.Reparent(cardBtn);

            let cardArt: ref<inkImage> = new inkImage();
            cardArt.SetAnchor(inkEAnchor.TopCenter);
            cardArt.SetAnchorPoint(new Vector2(0.5, 0.0));
            cardArt.SetRenderTransformPivot(new Vector2(0.5, 0.5));
            cardArt.SetMargin(new inkMargin(0.0, 26.0, 0.0, 0.0));
            cardArt.SetSize(210.0, 365.0);
            cardArt.SetTintColor(new HDRColor(1.0, 1.0, 1.0, 1.0));
            if idx == 1 {
                cardArt.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\tarot\\atlas_tarotbig9.inkatlas");
                cardArt.SetTexturePart(n"tarot_moonBIG");
            } else if idx == 2 {
                cardArt.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\tarot\\atlas_tarotbig4.inkatlas");
                cardArt.SetTexturePart(n"tarot_hangmanBIG");
                cardArt.SetRotation(180.0);
            } else {
                cardArt.SetAtlasResource(r"base\\gameplay\\gui\\fullscreen\\tarot\\atlas_tarotbig11.inkatlas");
                cardArt.SetTexturePart(n"tarot_towerBIG");
            }
            cardArt.Reparent(cardBtn);

            let cTitle: ref<inkText> = new inkText();
            cTitle.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
            cTitle.SetFontStyle(n"Bold");
            cTitle.SetFontSize(38);
            cTitle.SetAnchor(inkEAnchor.TopLeft);
            cTitle.SetMargin(new inkMargin(32.0, 412.0, 32.0, 0.0));
            cTitle.SetTintColor(new HDRColor(0.96, 0.88, 0.72, 1.0));
            cTitle.Reparent(cardBtn);
            ArrayPush(this.m_cardTitles, cTitle);

            let cTag: ref<inkText> = new inkText();
            cTag.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
            cTag.SetFontStyle(n"Medium");
            cTag.SetFontSize(28);
            cTag.SetAnchor(inkEAnchor.TopLeft);
            cTag.SetMargin(new inkMargin(32.0, 476.0, 32.0, 0.0));
            cTag.SetTintColor(new HDRColor(0.88, 0.34, 0.42, 0.95));
            cTag.Reparent(cardBtn);
            ArrayPush(this.m_cardTags, cTag);

            idx += 1;
        }

        // Panel inferior de lectura detallada del Arcano seleccionado
        let detailFrame: ref<inkCanvas> = new inkCanvas();
        detailFrame.SetAnchor(inkEAnchor.TopLeft);
        detailFrame.SetMargin(new inkMargin(76.0, 668.0, 76.0, 0.0));
        detailFrame.SetSize(2846.0, 656.0);
        detailFrame.Reparent(pane);

        let detailRim: ref<inkRectangle> = new inkRectangle();
        detailRim.SetAnchor(inkEAnchor.Fill);
        detailRim.SetTintColor(new HDRColor(0.76, 0.22, 0.30, 0.72));
        detailRim.Reparent(detailFrame);

        let detailBg: ref<inkRectangle> = new inkRectangle();
        detailBg.SetAnchor(inkEAnchor.Fill);
        detailBg.SetMargin(new inkMargin(3.0, 3.0, 3.0, 3.0));
        detailBg.SetTintColor(new HDRColor(0.022, 0.012, 0.020, 0.96));
        detailBg.Reparent(detailFrame);

        let dTitle: ref<inkText> = new inkText();
        dTitle.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dTitle.SetFontStyle(n"Bold");
        dTitle.SetFontSize(48);
        dTitle.SetAnchor(inkEAnchor.TopLeft);
        dTitle.SetMargin(new inkMargin(44.0, 34.0, 44.0, 0.0));
        dTitle.SetTintColor(new HDRColor(0.95, 0.78, 0.36, 1.0));
        dTitle.Reparent(detailFrame);
        this.m_detailTitle = dTitle;

        let dTag: ref<inkText> = new inkText();
        dTag.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dTag.SetFontStyle(n"Semi-Bold");
        dTag.SetFontSize(32);
        dTag.SetAnchor(inkEAnchor.TopRight);
        dTag.SetAnchorPoint(new Vector2(1.0, 0.0));
        dTag.SetHorizontalAlignment(textHorizontalAlignment.Right);
        dTag.SetMargin(new inkMargin(44.0, 42.0, 44.0, 0.0));
        dTag.SetTintColor(new HDRColor(0.38, 0.86, 0.96, 1.0));
        dTag.Reparent(detailFrame);
        this.m_detailTag = dTag;

        let dRule: ref<inkRectangle> = new inkRectangle();
        dRule.SetAnchor(inkEAnchor.TopLeft);
        dRule.SetMargin(new inkMargin(44.0, 112.0, 44.0, 0.0));
        dRule.SetSize(2758.0, 2.0);
        dRule.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.50));
        dRule.Reparent(detailFrame);

        let dBody: ref<inkText> = new inkText();
        dBody.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        dBody.SetFontStyle(n"Medium");
        dBody.SetFontSize(44);
        dBody.SetAnchor(inkEAnchor.TopLeft);
        dBody.SetMargin(new inkMargin(44.0, 140.0, 44.0, 36.0));
        dBody.SetSize(2758.0, 480.0);
        dBody.SetWrapping(true, 2740.0, textWrappingPolicy.Default);
        dBody.SetTintColor(new HDRColor(0.95, 0.92, 0.88, 1.0));
        dBody.Reparent(detailFrame);
        this.m_detailBody = dBody;
    }

    private final func BuildCodexPane(parent: ref<inkCanvas>) -> Void {
        let pane: ref<inkCanvas> = new inkCanvas();
        pane.SetName(n"cv_codex_pane");
        pane.SetAnchor(inkEAnchor.Fill);
        pane.Reparent(parent);
        this.m_codexPane = pane;

        let leftCol: ref<inkVerticalPanel> = new inkVerticalPanel();
        leftCol.SetAnchor(inkEAnchor.TopLeft);
        leftCol.SetMargin(new inkMargin(48.0, 36.0, 0.0, 0.0));
        leftCol.SetSize(960.0, 1296.0);
        leftCol.SetChildMargin(new inkMargin(0.0, 0.0, 0.0, 12.0));
        leftCol.Reparent(pane);

        ArrayClear(this.m_shardRowRims);
        ArrayClear(this.m_shardRowBgs);
        ArrayClear(this.m_shardRowTexts);

        let s: Int32 = 1;
        while s <= 10 {
            let rowCanvas: ref<inkCanvas> = new inkCanvas();
            rowCanvas.SetName(StringToName("cv_shard_" + IntToString(s)));
            rowCanvas.SetSize(940.0, 112.0);
            rowCanvas.SetInteractive(true);
            rowCanvas.RegisterToCallback(n"OnRelease", this, n"OnShardRelease");
            rowCanvas.Reparent(leftCol);

            let bg: ref<inkRectangle> = new inkRectangle();
            bg.SetAnchor(inkEAnchor.Fill);
            bg.SetTintColor(new HDRColor(0.04, 0.016, 0.024, 0.88));
            bg.Reparent(rowCanvas);
            ArrayPush(this.m_shardRowBgs, bg);

            let rowRim: ref<inkRectangle> = new inkRectangle();
            rowRim.SetAnchor(inkEAnchor.TopLeft);
            rowRim.SetSize(8.0, 112.0);
            rowRim.SetTintColor(new HDRColor(0.45, 0.16, 0.22, 0.65));
            rowRim.Reparent(rowCanvas);
            ArrayPush(this.m_shardRowRims, rowRim);

            let lbl: ref<inkText> = new inkText();
            lbl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
            lbl.SetFontStyle(n"Semi-Bold");
            lbl.SetFontSize(26);
            lbl.SetAnchor(inkEAnchor.CenterLeft);
            lbl.SetAnchorPoint(new Vector2(0.0, 0.5));
            lbl.SetMargin(new inkMargin(34.0, 0.0, 26.0, 0.0));
            lbl.SetWrapping(true, 880.0, textWrappingPolicy.Default);
            lbl.SetTintColor(new HDRColor(0.96, 0.89, 0.76, 1.0));
            lbl.Reparent(rowCanvas);
            ArrayPush(this.m_shardRowTexts, lbl);
            s += 1;
        }

        let rightFrame: ref<inkCanvas> = new inkCanvas();
        rightFrame.SetAnchor(inkEAnchor.TopLeft);
        rightFrame.SetMargin(new inkMargin(1042.0, 36.0, 48.0, 0.0));
        rightFrame.SetSize(1908.0, 1296.0);
        rightFrame.Reparent(pane);

        let rRim: ref<inkRectangle> = new inkRectangle();
        rRim.SetAnchor(inkEAnchor.Fill);
        rRim.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.65));
        rRim.Reparent(rightFrame);

        let rBg: ref<inkRectangle> = new inkRectangle();
        rBg.SetAnchor(inkEAnchor.Fill);
        rBg.SetMargin(new inkMargin(3.0, 3.0, 3.0, 3.0));
        rBg.SetTintColor(new HDRColor(0.020, 0.012, 0.018, 0.97));
        rBg.Reparent(rightFrame);

        let sTitle: ref<inkText> = new inkText();
        sTitle.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        sTitle.SetFontStyle(n"Bold");
        sTitle.SetFontSize(52);
        sTitle.SetAnchor(inkEAnchor.TopLeft);
        sTitle.SetMargin(new inkMargin(48.0, 38.0, 48.0, 0.0));
        sTitle.SetWrapping(true, 1812.0, textWrappingPolicy.Default);
        sTitle.SetTintColor(new HDRColor(0.95, 0.78, 0.36, 1.0));
        sTitle.Reparent(rightFrame);
        this.m_shardTitle = sTitle;

        let sRule: ref<inkRectangle> = new inkRectangle();
        sRule.SetAnchor(inkEAnchor.TopLeft);
        sRule.SetMargin(new inkMargin(48.0, 198.0, 48.0, 0.0));
        sRule.SetSize(1812.0, 2.0);
        sRule.SetTintColor(new HDRColor(0.84, 0.66, 0.28, 0.55));
        sRule.Reparent(rightFrame);

        let sBody: ref<inkText> = new inkText();
        sBody.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        sBody.SetFontStyle(n"Medium");
        sBody.SetFontSize(46);
        sBody.SetAnchor(inkEAnchor.TopLeft);
        sBody.SetMargin(new inkMargin(48.0, 228.0, 48.0, 40.0));
        sBody.SetSize(1812.0, 1028.0);
        sBody.SetWrapping(true, 1810.0, textWrappingPolicy.Default);
        sBody.SetTintColor(new HDRColor(0.95, 0.92, 0.88, 1.0));
        sBody.Reparent(rightFrame);
        this.m_shardBody = sBody;
    }

    private final func CreateActionButton(
        parent: ref<inkHorizontalPanel>,
        btnName: CName,
        labelText: String,
        width: Float,
        textColor: HDRColor,
        out outLabel: wref<inkText>
    ) -> wref<inkRectangle> {
        let btnCanvas: ref<inkCanvas> = new inkCanvas();
        btnCanvas.SetName(btnName);
        btnCanvas.SetSize(width, 74.0);
        btnCanvas.SetInteractive(true);
        btnCanvas.RegisterToCallback(n"OnRelease", this, n"OnActionButtonRelease");
        btnCanvas.Reparent(parent);

        let rim: ref<inkRectangle> = new inkRectangle();
        rim.SetAnchor(inkEAnchor.Fill);
        rim.SetTintColor(new HDRColor(textColor.Red, textColor.Green, textColor.Blue, 0.75));
        rim.Reparent(btnCanvas);

        let bg: ref<inkRectangle> = new inkRectangle();
        bg.SetAnchor(inkEAnchor.Fill);
        bg.SetMargin(new inkMargin(2.0, 2.0, 2.0, 2.0));
        bg.SetTintColor(new HDRColor(0.045, 0.014, 0.024, 0.94));
        bg.Reparent(btnCanvas);

        let txt: ref<inkText> = new inkText();
        txt.SetName(n"cv_btn_label");
        txt.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
        txt.SetFontStyle(n"Bold");
        txt.SetFontSize(28);
        txt.SetAnchor(inkEAnchor.Centered);
        txt.SetAnchorPoint(new Vector2(0.5, 0.5));
        txt.SetHorizontalAlignment(textHorizontalAlignment.Center);
        txt.SetTintColor(textColor);
        txt.SetText(labelText);
        txt.Reparent(btnCanvas);
        outLabel = txt;
        return bg;
    }

    protected cb func OnInitialize() {
        super.OnInitialize();
        this.RefreshDisplay();
    }

    protected cb func OnShown() {
        super.OnShown();
        this.m_inputArmed = true;
    }

    protected cb func OnHidden() {
        super.OnHidden();
        this.NotifySystemClosed(false);
    }

    protected cb func OnDetach() {
        this.NotifySystemClosed(false);
        super.OnDetach();
    }

    private final func NotifySystemClosed(confirmedReading: Bool) -> Void {
        if !this.m_notifiedClose {
            this.m_notifiedClose = true;
            if IsDefined(this.m_sys) {
                this.m_sys.OnTarotPopupClosed(confirmedReading, this.m_selectedCard, this.m_lensMode);
            }
        }
    }

    protected cb func OnGlobalReleaseInput(evt: ref<inkPointerEvent>) -> Bool {
        if !this.IsTopPopup() || !this.m_inputArmed || evt.IsHandled() {
            return false;
        }
        if evt.IsAction(n"cancel") || evt.IsAction(n"close_popup") || evt.IsAction(n"OpenPauseMenu") {
            this.PlaySound(n"Button", n"OnPress");
            this.Close();
            evt.Handle();
            return true;
        }
        if evt.IsAction(n"popup_moveUp") || evt.IsAction(n"UI_MoveUp") || evt.IsAction(n"up_button") {
            if this.m_activeTab == 1 {
                this.m_selectedShard = this.m_selectedShard <= 1 ? 7 : (this.m_selectedShard - 1);
                this.PlaySound(n"Button", n"OnHover");
                this.RefreshDisplay();
            }
            evt.Handle();
            return true;
        }
        if evt.IsAction(n"popup_moveDown") || evt.IsAction(n"UI_MoveDown") || evt.IsAction(n"down_button") {
            if this.m_activeTab == 1 {
                this.m_selectedShard = this.m_selectedShard >= 7 ? 1 : (this.m_selectedShard + 1);
                this.PlaySound(n"Button", n"OnHover");
                this.RefreshDisplay();
            }
            evt.Handle();
            return true;
        }
        if evt.IsAction(n"popup_prior") || evt.IsAction(n"prior_menu") || evt.IsAction(n"popup_next") || evt.IsAction(n"next_menu") {
            this.m_activeTab = this.m_activeTab == 0 ? 1 : 0;
            this.PlaySound(n"Button", n"OnPress");
            this.RefreshDisplay();
            evt.Handle();
            return true;
        }
        if evt.IsAction(n"popup_moveLeft") || evt.IsAction(n"left_button") || evt.IsAction(n"UI_MoveLeft") {
            if this.m_activeTab == 0 {
                this.SelectCard(this.m_selectedCard <= 1 ? 3 : (this.m_selectedCard - 1));
            }
            evt.Handle();
            return true;
        }
        if evt.IsAction(n"popup_moveRight") || evt.IsAction(n"right_button") || evt.IsAction(n"UI_MoveRight") {
            if this.m_activeTab == 0 {
                this.SelectCard(this.m_selectedCard >= 3 ? 1 : (this.m_selectedCard + 1));
            }
            evt.Handle();
            return true;
        }
        return false;
    }

    private final func SelectCard(cardId: Int32) -> Void {
        this.m_selectedCard = cardId;
        if IsDefined(this.m_sys) {
            this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
        }
        this.RefreshDisplay();
    }

    private final func ConfirmAndClose() -> Void {
        this.PlaySound(n"Button", n"OnPress");
        this.NotifySystemClosed(this.m_readingMode);
        this.Close();
    }

    protected cb func OnCardRelease(evt: ref<inkPointerEvent>) -> Bool {
        if !evt.IsAction(n"click") {
            return false;
        }
        let target: wref<inkWidget> = evt.GetCurrentTarget();
        if !IsDefined(target) {
            return false;
        }
        let wName: CName = target.GetName();
        let idx: Int32 = 1;
        while idx <= 3 {
            if Equals(wName, StringToName("cv_card_" + IntToString(idx))) {
                this.SelectCard(idx);
                evt.Handle();
                return true;
            }
            idx += 1;
        }
        return false;
    }

    protected cb func OnShardRelease(evt: ref<inkPointerEvent>) -> Bool {
        if !evt.IsAction(n"click") {
            return false;
        }
        let target: wref<inkWidget> = evt.GetCurrentTarget();
        if !IsDefined(target) {
            return false;
        }
        let wName: CName = target.GetName();
        let s: Int32 = 1;
        while s <= 10 {
            if Equals(wName, StringToName("cv_shard_" + IntToString(s))) {
                this.m_selectedShard = s;
                this.PlaySound(n"Button", n"OnPress");
                this.RefreshDisplay();
                evt.Handle();
                return true;
            }
            s += 1;
        }
        return false;
    }

    protected cb func OnActionButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
        if !evt.IsAction(n"click") {
            return false;
        }
        let target: wref<inkWidget> = evt.GetCurrentTarget();
        if !IsDefined(target) {
            return false;
        }
        let wName: CName = target.GetName();
        if Equals(wName, n"cv_tab_spread") {
            this.m_activeTab = 0;
            this.PlaySound(n"Button", n"OnPress");
            this.RefreshDisplay();
            evt.Handle();
            return true;
        }
        if Equals(wName, n"cv_tab_codex") {
            this.m_activeTab = 1;
            this.PlaySound(n"Button", n"OnPress");
            this.RefreshDisplay();
            evt.Handle();
            return true;
        }
        if Equals(wName, n"cv_btn_lens") {
            this.m_lensMode = (this.m_lensMode == 1) ? 2 : 1;
            if IsDefined(this.m_sys) {
                this.m_sys.PlaySfx(n"cv_sfx_tarot_flip");
            }
            this.RefreshDisplay();
            evt.Handle();
            return true;
        }
        if Equals(wName, n"cv_btn_confirm") {
            this.ConfirmAndClose();
            evt.Handle();
            return true;
        }
        if Equals(wName, n"cv_btn_close") {
            this.PlaySound(n"Button", n"OnPress");
            this.Close();
            evt.Handle();
            return true;
        }
        return false;
    }

    private final func GetCardStrings(cardId: Int32, out titleOut: String, out tagOut: String, out bodyOut: String) -> Void {
        let isForensic: Bool = this.m_lensMode == 1;
        if cardId == 1 {
            titleOut = this.Loc(n"cv_card1_name", "I · LA LUNA");
            tagOut = this.Loc(n"cv_card1_tag", "SECRETO NOCTURNO Y PORFIRINAS");
            bodyOut = isForensic
                ? this.Loc(n"cv_card1_forensic", "LECTURA FORENSE: Hemoglobina sintética y traza extrema de porfirinas reactivas. Quien sangró sobre La Luna sufriría quemaduras internas graves bajo el sol directo.")
                : this.Loc(n"cv_card1_symbolic", "LECTURA DE MISTY: Dos muescas de uña en la esquina inferior izquierda — «Estoy despierta en la oscuridad, pero no puedo salir a la luz». Lucía guardaba ya ese secreto en su piel.");
        } else if cardId == 2 {
            titleOut = this.Loc(n"cv_card2_name", "II · EL COLGADO INVERTIDO");
            tagOut = this.Loc(n"cv_card2_tag", "PROMESA DE RENACER Y DIÁLISIS");
            bodyOut = isForensic
                ? this.Loc(n"cv_card2_forensic", "LECTURA FORENSE: Supuestas clínicas nocturnas ofrecen terapias respiratorias que sustituyen sangre por diálisis NOX-9 para atrapar a los pacientes tras el anochecer.")
                : this.Loc(n"cv_card2_symbolic", "LECTURA DE MISTY: El Colgado invertido es el falso voto de renacer pagando un sacrificio en silencio: buscan pertenecer a algo que no los descarte al amanecer.");
        } else {
            titleOut = this.Loc(n"cv_card3_name", "III · LA TORRE");
            tagOut = this.Loc(n"cv_card3_tag", "RESIDUO PETROQUÍMICO · NORTHSIDE");
            bodyOut = isForensic
                ? this.Loc(n"cv_card3_forensic", "LECTURA FORENSE: La cera en el borde de La Torre atrapó gravilla aceitosa y residuo petroquímico de los depósitos abandonados de Northside. Su sangre hierve bajo luz UV a 365 nm.")
                : this.Loc(n"cv_card3_symbolic", "LECTURA DE MISTY: La Torre es la caída inevitable cuando esa falsa salvación se derrumba. Bajo la luz ultravioleta, la sombra del Coro Pálido no puede sostenerse.");
        }
    }

    private final func RefreshDisplay() -> Void {
        let showSpread: Bool = this.m_activeTab == 0;
        if IsDefined(this.m_spreadPane) {
            this.m_spreadPane.SetVisible(showSpread);
        }
        if IsDefined(this.m_codexPane) {
            this.m_codexPane.SetVisible(!showSpread);
        }
        if IsDefined(this.m_tabSpreadBg) {
            this.m_tabSpreadBg.SetTintColor(showSpread ? new HDRColor(0.18, 0.05, 0.08, 0.96) : new HDRColor(0.04, 0.015, 0.022, 0.85));
        }
        if IsDefined(this.m_tabCodexBg) {
            this.m_tabCodexBg.SetTintColor(!showSpread ? new HDRColor(0.18, 0.05, 0.08, 0.96) : new HDRColor(0.04, 0.015, 0.022, 0.85));
        }
        if IsDefined(this.m_lensBtnText) {
            this.m_lensBtnText.SetText(
                this.m_lensMode == 1
                    ? this.Loc(n"cv_ui_lens_forensic", "ENFOQUE: FORENSE [RAZÓN]")
                    : this.Loc(n"cv_ui_lens_symbolic", "ENFOQUE: SIMBÓLICO [MISTY]")
            );
        }

        let i: Int32 = 1;
        while i <= 3 {
            let idx: Int32 = i - 1;
            let cTitle: String = "";
            let cTag: String = "";
            let cBody: String = "";
            this.GetCardStrings(i, cTitle, cTag, cBody);
            let isSel: Bool = i == this.m_selectedCard;
            if idx < ArraySize(this.m_cardTitles) && IsDefined(this.m_cardTitles[idx]) {
                this.m_cardTitles[idx].SetText(cTitle);
            }
            if idx < ArraySize(this.m_cardTags) && IsDefined(this.m_cardTags[idx]) {
                this.m_cardTags[idx].SetText(cTag);
            }
            if idx < ArraySize(this.m_cardRims) && IsDefined(this.m_cardRims[idx]) {
                this.m_cardRims[idx].SetTintColor(isSel ? new HDRColor(0.98, 0.82, 0.34, 1.0) : new HDRColor(0.50, 0.22, 0.28, 0.65));
            }
            if idx < ArraySize(this.m_cardBgs) && IsDefined(this.m_cardBgs[idx]) {
                this.m_cardBgs[idx].SetTintColor(isSel ? new HDRColor(0.10, 0.030, 0.048, 0.98) : new HDRColor(0.032, 0.014, 0.024, 0.92));
            }
            i += 1;
        }

        let selTitle: String = "";
        let selTag: String = "";
        let selBody: String = "";
        this.GetCardStrings(this.m_selectedCard, selTitle, selTag, selBody);
        if IsDefined(this.m_detailTitle) {
            this.m_detailTitle.SetText(selTitle);
        }
        if IsDefined(this.m_detailTag) {
            this.m_detailTag.SetText(
                this.m_lensMode == 1
                    ? this.Loc(n"cv_ui_lens_forensic", "ENFOQUE: FORENSE [RAZÓN]")
                    : this.Loc(n"cv_ui_lens_symbolic", "ENFOQUE: SIMBÓLICO [MISTY]")
            );
        }
        if IsDefined(this.m_detailBody) {
            this.m_detailBody.SetText(selBody);
        }

        // Códice de Campo (Shards 1..10)
        let s: Int32 = 1;
        while s <= 10 {
            let sIdx: Int32 = s - 1;
            let unlocked: Bool = IsDefined(this.m_sys) && this.m_sys.IsCodexShardUnlocked(s);
            let sTitleStr: String = "";
            let sBodyStr: String = "";
            if IsDefined(this.m_sys) {
                this.m_sys.GetCodexShardText(s, sTitleStr, sBodyStr);
            }
            let isRowSel: Bool = s == this.m_selectedShard;
            if sIdx < ArraySize(this.m_shardRowRims) && IsDefined(this.m_shardRowRims[sIdx]) {
                this.m_shardRowRims[sIdx].SetTintColor(isRowSel ? new HDRColor(0.98, 0.82, 0.34, 1.0) : new HDRColor(0.45, 0.16, 0.22, 0.65));
            }
            if sIdx < ArraySize(this.m_shardRowBgs) && IsDefined(this.m_shardRowBgs[sIdx]) {
                this.m_shardRowBgs[sIdx].SetTintColor(isRowSel ? new HDRColor(0.16, 0.045, 0.07, 0.96) : new HDRColor(0.04, 0.016, 0.024, 0.88));
            }
            if sIdx < ArraySize(this.m_shardRowTexts) && IsDefined(this.m_shardRowTexts[sIdx]) {
                let numLabel: String = (s < 10) ? ("0" + IntToString(s)) : IntToString(s);
                let sealedTag: String = this.Loc(n"cv_ui_locked_shard_row", "[SELLADO]");
                this.m_shardRowTexts[sIdx].SetText(unlocked ? sTitleStr : (numLabel + " // " + sealedTag));
            }
            if isRowSel {
                if IsDefined(this.m_shardTitle) {
                    this.m_shardTitle.SetText(unlocked ? sTitleStr : this.Loc(n"cv_ui_locked_shard_title", "EXPEDIENTE SELLADO"));
                }
                if IsDefined(this.m_shardBody) {
                    this.m_shardBody.SetText(unlocked ? sBodyStr : this.Loc(n"cv_ui_locked_shard", "[EXPEDIENTE SELLADO] Avanza en la investigación de Velo Carmesí para descifrarlo."));
                }
            }
            s += 1;
        }
    }
}
