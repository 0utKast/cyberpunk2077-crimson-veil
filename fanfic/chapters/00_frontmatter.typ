#import "../theme.typ": *

// Page 2: Title & Colophon Spread
#v(24mm)
#align(center)[
  #text(font: font-sans, size: 8pt, tracking: 3pt, weight: "semibold", fill: crimson)[
    NIGHT CITY ARCHIVE · COLLECTOR'S COMPANION EDITION
  ]
  #v(5mm)
  #text(font: font-display, size: 32pt, weight: "bold", tracking: 1.5pt, fill: ink)[
    CRIMSON VEIL
  ]
  #v(1.5mm)
  #text(font: font-serif, size: 13.5pt, style: "italic", fill: gold)[
    Blood Beneath the Neon
  ]
  #v(6mm)
  #line(length: 44mm, stroke: 0.9pt + crimson)
  #v(6mm)
  #par(first-line-indent: 0em, justify: false)[
    #text(font: font-serif, size: 9.8pt, fill: ink-muted)[
      A narrative companion novella, forensic Codex, and visual chronicle of the complete _Crimson Veil_ campaign (_Cyberpunk 2077_), adapted from the Night City field recordings in Watson, Northside, and the Biotechnica Badlands.
    ]
  ]
]

#v(1fr)
#line(length: 100%, stroke: 0.5pt + hairline)
#v(3mm)
#par(first-line-indent: 0em, justify: false, leading: 0.60em)[
  #text(font: font-sans, size: 7.5pt, fill: ink-muted)[
    *Original Mod Expansion & Story Design:* 0utKast \
    *Edition Scope:* Prologue (_The Stained Moon_), Act I (_Pulse of Batch NOX-9_), Act II (_Liturgy of Ash_ — Path A: _The Second Serum_), Epilogue, Interleaved Kiroshi Forensic Dossiers, and Archival Appendix (_Paths Not Taken_). \
    *Visual Plate Architecture:* 21 curated 4K UHD campaign captures paired with 5 bespoke cyberpunk-esoteric collector's plates rendered offline in Typst. \
    *Permissions:* Published under Open Modding Policy for companions, lore readers, and community preservation. Night City and _Cyberpunk 2077_ lore belong to CD PROJEKT RED and R. Talsorian Games.
  ]
]

#pagebreak()

// Page 3: Contents & Dramatis Personae
#chapter-head("Front Matter", "Contents & Dramatis Personae", "FILE // CV-ARCHIVE-2077-EN")

#block(
  fill: ivory-card,
  stroke: (left: 2pt + gold, rest: 0.4pt + hairline),
  inset: 4.5mm,
  width: 100%,
)[
  #text(font: font-sans, size: 8pt, tracking: 1.5pt, weight: "bold", fill: crimson)[CAMPAIGN CHRONICLE]
  #v(2.5mm)
  #set text(font: font-serif, size: 9.5pt, fill: ink)
  #grid(
    columns: (auto, 1fr),
    row-gutter: 2.5mm,
    column-gutter: 5mm,
    text(font: font-mono, size: 8pt, weight: "bold", fill: crimson)[PART I], [*Prologue — The Stained Moon* \ #text(size: 8.5pt, style: "italic", fill: ink-muted)[The Midnight Holocall · Six Candles in Little China · The Rooftop Spread · Northside Oilfields]],
    text(font: font-mono, size: 8pt, weight: "bold", fill: crimson)[PART II], [*Act I — Pulse of Batch NOX-9* \ #text(size: 8.5pt, style: "italic", fill: ink-muted)[Kabuki Canal Trace · Little China Confession · Silence at the West Pier · Nexus of Silence]],
    text(font: font-mono, size: 8pt, weight: "bold", fill: crimson)[PART III], [*Act II — Liturgy of Ash* \ #text(size: 8.5pt, style: "italic", fill: ink-muted)[Biotechnica Flats & Mateo's Sacrifice · Beneath the Geothermal Plant · Studio NOX-9B]],
    text(font: font-mono, size: 8pt, weight: "bold", fill: crimson)[EPILOGUE], [*Morning After the Rain & Archival Appendix* \ #text(size: 8.5pt, style: "italic", fill: ink-muted)[Esoterica Reopens · Paths Not Taken (_Pact in the Shadows_, _Blood Dawn_) · Iconic Arsenal]],
  )
]

#v(4mm)
#text(font: font-sans, size: 8.5pt, tracking: 1.8pt, weight: "bold", fill: ink)[DRAMATIS PERSONAE]
#v(2mm)
#line(length: 100%, stroke: 0.5pt + hairline)
#v(2.5mm)

#let cast-entry(name, role, desc) = {
  par(first-line-indent: 0em, spacing: 0.55em, leading: 0.60em)[
    #text(font: font-sans, size: 8.8pt, weight: "bold", fill: crimson)[#name] #h(1.5mm) #text(font: font-mono, size: 7.4pt, fill: ink-muted, "// " + role) \
    #text(font: font-serif, size: 9.4pt, fill: ink)[#desc]
  ]
}

#cast-entry(
  "V",
  "Mercenary Solo · Watson",
  "Chrome-wired, unsentimental on the clock, and fiercely loyal to the handful of people in Little China who still keep a light on for her. Drawn in by an act of friendship, V becomes the scalpel cutting through a biomedical cult."
)
#cast-entry(
  "Misty Olszewski",
  "Proprietor of Esoterica · Spiritual Anchor",
  "Reader of Night City's hidden currents. Misty discovers too late that her quiet neighborhood girls were being lured into nocturnal clinics—and that Lucía turned Misty's own Tarot lessons into an SOS written in blood."
)
#cast-entry(
  "Lucía Reyes (Subject L-14)",
  "Kabuki Resident · Age 23",
  "The girl in the green coat who swept Esoterica's storefront for spare Eddies and kindness. Driven by smog-damaged lungs to accept free night-shift treatments, she becomes the living thread pulling V from Watson into the desert."
)
#cast-entry(
  "Mateo (Subject M-09)",
  "Northside Dock Technician · Missing / Executed",
  "Vanished three nights before Lucía after demanding his medical dosage ledger. Though V never meets him alive, Mateo's final act of sabotage in Biotechnica Flats ensures Lucía survives long enough to be found."
)
#cast-entry(
  "Dr. Adrián Valdés",
  "Ex-Biotechnica Hematologist",
  "Creator of the NOX-9 pulmonary trauma compound six years before the events of 2077. Fired when lethal porphyrin phototoxicity doomed the trials, he sold his patents to Dr. Helena Solís—only to watch charity curdle into predation."
)
#cast-entry(
  "Dr. Helena Solís (“The Cantor”)",
  "Former Clinical Director · Architect of The Pale Chorus",
  "Cold, clinical, and unnervingly persuasive. Solís reframed chemical daylight blindness as nocturnal salvation, transforming desperate Watson workers into an underground hierarchy funded by black-clinic serum dependency."
)

#pagebreak()
