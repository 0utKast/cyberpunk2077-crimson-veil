// Crimson Veil: Blood Beneath the Neon — Luxury Illustrated Editorial Theme (Typst 0.15.2)
// 100% offline self-contained design (no external registry dependencies).

#let obsidian     = rgb("#0D0B10")
#let obsidian-mid = rgb("#16131C")
#let ivory        = rgb("#FAF6F0")
#let ivory-card   = rgb("#F2ECE2")
#let ink          = rgb("#1D1A21")
#let ink-muted    = rgb("#585060")
#let crimson      = rgb("#8B1E2D")
#let crimson-lit  = rgb("#C22B42")
#let uv-violet    = rgb("#5B3A8C")
#let uv-glow      = rgb("#8C62D4")
#let gold         = rgb("#A67C37")
#let gold-bright  = rgb("#CFA65C")
#let hairline     = rgb("#D8CFC2")

#let font-serif   = ("Palatino Linotype", "Georgia")
#let font-display = ("Oswald", "Montserrat")
#let font-sans    = ("Montserrat", "Segoe UI")
#let font-mono    = ("Consolas", "Segoe UI")

#let in-frontmatter = state("cv-frontmatter", false)
#let current-act    = state("cv-act", "CRIMSON VEIL")

#let apply-doc-typography(body) = {
  set page(
    width: 170mm,
    height: 240mm,
    margin: (inside: 21mm, outside: 18mm, top: 20mm, bottom: 20mm),
    fill: ivory,
    header-ascent: 7mm,
    footer-descent: 7mm,
    header: context {
      let pn = counter(page).get().first()
      if pn <= 2 { return none }
      let is-even = calc.even(pn)
      set text(font: font-sans, size: 7.2pt, tracking: 1.4pt, fill: ink-muted)
      set par(first-line-indent: 0em)
      if is-even {
        grid(
          columns: (1fr, auto),
          align(left, upper[#smallcaps[Crimson Veil: Blood Beneath the Neon]]),
          align(right, text(fill: crimson, weight: "semibold", "//")),
        )
      } else {
        let act-label = current-act.get()
        grid(
          columns: (auto, 1fr),
          align(left, text(fill: crimson, weight: "semibold", "//")),
          align(right, upper[#act-label]),
        )
      }
      v(-3.5pt)
      line(length: 100%, stroke: 0.4pt + hairline)
    },
    footer: context {
      let pn = counter(page).get().first()
      if pn <= 2 { return none }
      set text(font: font-sans, size: 8pt, tracking: 1pt, fill: ink-muted)
      set par(first-line-indent: 0em)
      line(length: 100%, stroke: 0.35pt + hairline)
      v(2pt)
      if calc.even(pn) {
        align(left, text(weight: "semibold", fill: ink)[#pn])
      } else {
        align(right, text(weight: "semibold", fill: ink)[#pn])
      }
    },
  )
  set text(
    font: font-serif,
    size: 10.1pt,
    fill: ink,
    lang: "en",
  )
  set par(
    leading: 0.66em,
    spacing: 0.74em,
    justify: true,
    first-line-indent: 1.1em,
  )
  body
}

#let full-bleed-cover(cover-image-path) = {
  page(
    width: 170mm,
    height: 240mm,
    margin: 0mm,
    fill: obsidian,
    header: none,
    footer: none,
  )[
    #set par(first-line-indent: 0em)
    #box(width: 170mm, height: 240mm, clip: true)[
      #place(top + left, image(cover-image-path, width: 170mm, height: 240mm, fit: "cover"))
      #place(
        top + left,
        rect(
          width: 170mm,
          height: 112mm,
          fill: gradient.linear(
            (obsidian.transparentize(8%), 0%),
            (obsidian.transparentize(24%), 62%),
            (obsidian.transparentize(100%), 100%),
            angle: 90deg,
          ),
        ),
      )
      #place(
        bottom + left,
        rect(
          width: 170mm,
          height: 44mm,
          fill: gradient.linear(
            (obsidian.transparentize(100%), 0%),
            (obsidian.transparentize(14%), 55%),
            (obsidian.transparentize(4%), 100%),
            angle: 90deg,
          ),
        ),
      )
      #place(top + left, dx: 12mm, dy: 12mm)[
        #rect(width: 146mm, height: 216mm, stroke: 0.7pt + gold.transparentize(45%), fill: none)
      ]
      #place(top + left, dx: 13.5mm, dy: 13.5mm)[
        #rect(width: 143mm, height: 213mm, stroke: 0.35pt + crimson-lit.transparentize(55%), fill: none)
      ]
      #place(top + center, dy: 25mm)[
        #block(width: 138mm)[
          #align(center)[
            #text(font: font-sans, size: 7.4pt, tracking: 2.3pt, weight: "semibold", fill: gold-bright)[
              COLLECTOR'S ILLUSTRATED EDITION · NIGHT CITY ARCHIVE
            ]
            #v(5.5mm)
            #line(length: 48mm, stroke: 0.8pt + crimson-lit)
            #v(5mm)
            #text(font: font-display, size: 42pt, weight: "bold", tracking: 2.5pt, fill: rgb("#FAF6F0"))[
              CRIMSON VEIL
            ]
            #v(1.5mm)
            #text(font: font-serif, size: 14.5pt, style: "italic", tracking: 0.8pt, fill: gold-bright)[
              Blood Beneath the Neon
            ]
            #v(5mm)
            #line(length: 48mm, stroke: 0.8pt + crimson-lit)
            #v(4.5mm)
            #text(font: font-sans, size: 7.8pt, tracking: 1.7pt, fill: rgb("#D7CEDC"))[
              THE STAINED MOON · PULSE OF BATCH NOX-9 · LITURGY OF ASH
            ]
          ]
        ]
      ]
      #place(bottom + center, dy: -15.5mm)[
        #align(center)[
          #text(font: font-sans, size: 8.2pt, tracking: 2pt, weight: "medium", fill: rgb("#EFE8DC"))[
            AN ILLUSTRATED CYBERPUNK 2077 COMPANION NOVELLA
          ]
          #v(2mm)
          #text(font: font-serif, size: 8.8pt, style: "italic", fill: gold-bright)[
            Based on the Campaign Expansion by 0utKast · Visual Archive Edition
          ]
        ]
      ]
    ]
  ]
}

#let part-opener(numeral, title, subtitle, epigraph, plate-image) = {
  current-act.update(upper(title))
  page(
    width: 170mm,
    height: 240mm,
    margin: 0mm,
    fill: obsidian,
    header: none,
    footer: none,
  )[
    #set par(first-line-indent: 0em)
    #box(width: 170mm, height: 240mm, clip: true)[
      #if plate-image != none {
        place(top + left, image(plate-image, width: 170mm, height: 240mm, fit: "cover"))
        place(
          top + left,
          rect(
            width: 170mm,
            height: 240mm,
            fill: gradient.linear(
              (obsidian.transparentize(18%), 0%),
              (obsidian.transparentize(12%), 52%),
              (obsidian.transparentize(4%), 100%),
              angle: 90deg,
            ),
          ),
        )
      }
      #place(top + left, dx: 13mm, dy: 13mm)[
        #rect(width: 144mm, height: 214mm, stroke: 0.6pt + gold.transparentize(50%), fill: none)
      ]
      #place(center + horizon)[
        #block(width: 122mm)[
          #align(center)[
            #text(font: font-sans, size: 9pt, tracking: 3.5pt, weight: "semibold", fill: gold-bright)[
              #upper(numeral)
            ]
            #v(4mm)
            #line(length: 42mm, stroke: 0.9pt + crimson-lit)
            #v(6mm)
            #text(font: font-display, size: 29pt, weight: "bold", tracking: 2pt, fill: rgb("#FAF6F0"))[
              #upper(title)
            ]
            #v(3mm)
            #text(font: font-serif, size: 12.5pt, style: "italic", fill: gold-bright)[
              #subtitle
            ]
            #v(7mm)
            #line(length: 34mm, stroke: 0.6pt + uv-glow)
            #v(8mm)
            #text(font: font-serif, size: 10pt, style: "italic", fill: rgb("#DFD7E6"))[
              #epigraph
            ]
          ]
        ]
      ]
    ]
  ]
}

#let chapter-head(number-label, title, meta) = {
  v(2mm)
  block(breakable: false, width: 100%)[
    #set par(first-line-indent: 0em, justify: false)
    #block(below: 2.2mm)[#text(font: font-sans, size: 7.8pt, tracking: 2.2pt, weight: "bold", fill: crimson)[
      #upper(number-label)
    ]]
    #text(font: font-display, size: 20pt, weight: "bold", tracking: 0.8pt, fill: ink)[
      #title
    ]
    #v(1.5mm)
    #grid(
      columns: (28mm, 1fr),
      gutter: 4mm,
      align(left + horizon, line(length: 28mm, stroke: 1.4pt + crimson)),
      align(left + horizon, text(font: font-mono, size: 7.5pt, tracking: 0.6pt, fill: ink-muted)[#meta]),
    )
    #v(4mm)
  ]
}

#let prose-lead(first-char, rest) = {
  par(first-line-indent: 0em)[
    #text(font: font-display, size: 17pt, weight: "bold", fill: crimson)[#first-char]#rest
  ]
}

#let dialogue-block(speaker, line-text) = {
  par(first-line-indent: 0em, leading: 0.65em, spacing: 0.65em)[
    #text(font: font-sans, size: 8pt, weight: "bold", tracking: 0.8pt, fill: crimson)[#upper(speaker): ]#text(font: font-serif, size: 10pt)[“#line-text”]
  ]
}

#let pull-quote(quote-text, attribution) = {
  v(2.5mm)
  block(breakable: false, width: 100%, inset: (left: 8mm, right: 6mm, top: 2.5mm, bottom: 2.5mm), stroke: (left: 1.8pt + crimson))[
    #par(first-line-indent: 0em)[
      #text(font: font-serif, size: 10.5pt, style: "italic", fill: ink)[“#quote-text”]
    ]
    #if attribution != none {
      v(1.2mm)
      align(right, text(font: font-sans, size: 7.5pt, tracking: 1.2pt, weight: "semibold", fill: ink-muted)[— #upper(attribution)])
    }
  ]
  v(2.5mm)
}

#let cinema-plate(image-path, tag, caption, img-height: 67mm) = {
  v(2mm)
  block(breakable: false, width: 100%)[
    #set par(first-line-indent: 0em)
    #box(
      fill: obsidian,
      inset: 2mm,
      stroke: 0.6pt + gold.transparentize(35%),
      radius: 1.2pt,
      width: 100%,
    )[
      #align(center, image(image-path, width: 100%, height: img-height, fit: "contain"))
      #v(1.4mm)
      #grid(
        columns: (auto, 1fr),
        gutter: 3.5mm,
        align(left + top, text(font: font-mono, size: 6.9pt, weight: "bold", fill: gold-bright)[#tag]),
        align(left + top, text(font: font-sans, size: 7.4pt, fill: rgb("#E6DFD6"))[#caption]),
      )
    ]
  ]
  v(2mm)
}

#let forensic-dossier(code, title, body) = {
  v(2mm)
  block(
    breakable: false,
    width: 100%,
    fill: obsidian-mid,
    stroke: (left: 2.6pt + crimson-lit, rest: 0.4pt + uv-violet),
    inset: (x: 4.5mm, y: 3.5mm),
    radius: 1pt,
  )[
    #set par(first-line-indent: 0em)
    #grid(
      columns: (1fr, auto),
      align(left, text(font: font-mono, size: 7pt, tracking: 1.2pt, weight: "bold", fill: uv-glow)[#upper(code)]),
      align(right, text(font: font-mono, size: 6.8pt, fill: gold-bright, "KIROSHI // CODEX VERIFIED")),
    )
    #v(1.2mm)
    #text(font: font-sans, size: 9pt, weight: "bold", tracking: 0.5pt, fill: rgb("#FAF6F0"))[#title]
    #v(1.2mm)
    #line(length: 100%, stroke: 0.35pt + uv-violet.transparentize(40%))
    #v(1.6mm)
    #set text(font: font-mono, size: 7.8pt, fill: rgb("#DDD6E4"))
    #set par(leading: 0.56em, spacing: 0.48em, justify: false, first-line-indent: 0em)
    #body
  ]
  v(2mm)
}

#let tarot-plate(numeral, card-title, tag, image-path, misty-reading, forensic-reading) = {
  page(
    width: 170mm,
    height: 240mm,
    margin: (inside: 16mm, outside: 16mm, top: 15mm, bottom: 15mm),
    fill: obsidian,
    header: none,
    footer: none,
  )[
    #set par(first-line-indent: 0em)
    #block(width: 100%, height: 100%)[
      #align(center)[
        #text(font: font-sans, size: 7.8pt, tracking: 3pt, weight: "semibold", fill: gold-bright)[
          ARCANA CODEX · #upper(numeral)
        ]
        #v(1.5mm)
        #text(font: font-display, size: 22pt, weight: "bold", tracking: 1.6pt, fill: rgb("#FAF6F0"))[
          #upper(card-title)
        ]
        #v(1mm)
        #text(font: font-mono, size: 7.5pt, tracking: 1.1pt, fill: crimson-lit)[
          #upper(tag)
        ]
        #v(4mm)
        #box(stroke: 0.7pt + gold.transparentize(40%), inset: 1.2mm, fill: obsidian)[
          #image(image-path, height: 124mm, fit: "contain")
        ]
      ]
      #v(4.5mm)
      #grid(
        columns: (1fr, 1fr),
        gutter: 5mm,
        box(
          fill: obsidian-mid,
          stroke: 0.45pt + gold.transparentize(45%),
          inset: 3.5mm,
          width: 100%,
        )[
          #text(font: font-sans, size: 7.2pt, tracking: 1.2pt, weight: "bold", fill: gold-bright)[MISTY'S READING]
          #v(1.5mm)
          #par(first-line-indent: 0em, justify: false, leading: 0.62em)[
            #text(font: font-serif, size: 8.6pt, style: "italic", fill: rgb("#EAE2D6"))[#misty-reading]
          ]
        ],
        box(
          fill: obsidian-mid,
          stroke: 0.45pt + uv-glow.transparentize(40%),
          inset: 3.5mm,
          width: 100%,
        )[
          #text(font: font-mono, size: 7.2pt, tracking: 1.1pt, weight: "bold", fill: uv-glow)[KIROSHI FORENSIC AUDIT]
          #v(1.5mm)
          #par(first-line-indent: 0em, justify: false, leading: 0.60em)[
            #text(font: font-mono, size: 7.7pt, fill: rgb("#D8D0E5"))[#forensic-reading]
          ]
        ],
      )
    ]
  ]
}

#let section-break() = {
  v(2mm)
  align(center)[
    #text(font: font-sans, size: 8pt, tracking: 4pt, fill: crimson)[✦  ✦  ✦]
  ]
  v(2mm)
}
