#import "../theme.typ": *

#part-opener(
  "Epilogue & Archive",
  "Esoterica's Shutters",
  "Little China Rooftop & Archival Appendix",
  "“When we raise Esoterica's shutters tomorrow, The Moon on this table won't be an SOS anymore.”",
  none,
)

#chapter-head("Epilogue", "Beneath Clean Rain", "WATSON // ESOTERICA ROOFTOP · 22:01")

#prose-lead("B")[ack on Little China’s sixth-floor terrace, the rain sounded different—lighter against the yellow awnings, no longer masking footsteps in the alley below.]

Behind the Tarot table stood Misty—and right beside her, beneath the golden circuit silhouette on the wall, stood *Lucía Reyes*, whole and breathing easy for the first time in weeks. The Moon, The Inverted Hanged Man, and The Tower still lay spaced neatly across the dark wood between two burning candles, though their weight in the room had changed completely.

#cinema-plate(
  "/assets/frames/plate_21_epilogue_reunion.jpg",
  "FIG. 21 // EPILOGUE · MISTY & LUCÍA REYES",
  "Reunited on Esoterica's Little China rooftop, Lucía Reyes and Misty Olszewski close the campaign beside the Tarot table.",
)

#dialogue-block("Lucía Reyes", "I don't know how to thank you, V. Hearing Little China rain without dreading the next sunrise felt impossible until today.")
#dialogue-block("Misty Olszewski", "Vik is already reviewing your NOX-9B formula with Dr. Valdés over encrypted comms. For the first time, Lucía and the others have a real shot at walking in daylight again.")

For _Ending A — The Second Serum_, that quiet promise mattered more than any corporate patent. Valdés finally had a chance to repair what Biotechnica buried; Viktor had clean molecular charts to flush free-floating porphyrins from Lucía’s blood; and Mateo M-09 would not vanish into Night City’s nameless dust.

Misty slid two final tokens across the table—`4,000` Eddies and _Crimson Dawn_, a heavy _Burya_ revolver tuned with thermal-incandescent rounds.

#dialogue-block("Misty Olszewski", "When we raise Esoterica's shutters tomorrow, The Moon on this table won't be an SOS anymore. Take this Crimson Dawn revolver and your Eddies, V—Mateo didn't die for nothing.")
#dialogue-block("V", "Look after yourself in Kabuki, Lucía—and bolt the door at nightfall, Misty. If The Pale Chorus ever raises its head again, you know my holo.")

Below them, Little China kept breathing through the neon drizzle—no longer waiting for black vans with dead headlights.

#section-break()

#forensic-dossier(
  "CODEX // CV-SHARD-A2-EPILOGUE",
  "Misty's Esoterica — Campaign Closure Ledger",
  [
    - *Survivor Recovery:* Lucía Reyes (Subject L-14) returned safely to Little China under Misty Olszewski's and Viktor Vektor's medical supervision.\
    - *Serum Disposition:* Purified NOX-9B synthesis delivered encrypted to Dr. Adrián Valdés and Viktor for clinical porphyrin clearance.\
    - *Memorial Record:* Mateo (Subject M-09) logged in Watson memory—his desert sabotage at Biotechnica Flats made Lucía's extraction possible.\
    - *Symbolic Status:* _The Moon_ now marks survival rather than a cry in the dark.
  ],
)

#pull-quote(
  "In Night City, most people vanish between shift changes and nobody bothers asking why. Tonight, one storefront in Little China kept its promise.",
  "Watson Field Archive // Epilogue",
)

#pagebreak()

#chapter-head("Archival Appendix", "Paths Not Taken & Recovered Hardware", "CODEX // ALTERNATE TIMELINES & ICONIC ARSENAL")

#prose-lead("W")[hile the campaign chronicled in this volume follows V’s compassionate stand with Dr. Valdés, stealth infiltration at the West Pier, and _The Second Serum_ victory in Studio NOX-9B, Night City’s branching crossroads preserved two darker resolutions inside the NOX-9B core.]

#v(2mm)

#forensic-dossier(
  "BRANCH // ENDING B — PACT IN THE SHADOWS",
  "Alternate Resolution: Pragmatic Truce in Studio NOX-9B",
  [
    *Decision Point:* Choosing deterrence over open bloodshed—forcing Dr. Helena Solís into a strict non-aggression truce.\
    *Terms:* Solís immediately releases Lucía Reyes alongside clean emergency stabilizer doses and permanently scrubs Misty's Esoterica and Watson from every Pale Chorus ledger.\
    *Epilogue Consequence:* Lucía walks home safely without a final shootout, yet Solís survives beneath the desert. Misty accepts the rescue with quiet sorrow, knowing other districts beyond Watson will continue paying the Chorus's price.
  ],
)

#forensic-dossier(
  "BRANCH // ENDING C — BLOOD DAWN",
  "Alternate Resolution: Total Purge of the Bioreactor",
  [
    *Decision Point:* Refusing to trust anyone—even Dr. Valdés—with purified NOX-9B.\
    *Outcome:* After defeating Solís and her honor guard, V triggers a catastrophic core purge that incinerates every vial, server rack, and synthesis chart of NOX-9B inside Sublevel -2.\
    *Epilogue Consequence:* The Pale Chorus's desert engine is uprooted forever and nobody hunts Lucía again, yet without purified NOX-9B she must remain months away from direct sunlight while Viktor and Misty search for alternative blood therapies.
  ],
)

#pagebreak()

#text(font: font-sans, size: 8.5pt, tracking: 1.6pt, weight: "bold", fill: crimson)[RECOVERED ICONIC ARSENAL]
#v(2mm)
#line(length: 100%, stroke: 0.5pt + hairline)
#v(3mm)

#let weapon-card(tier, title, base-model, stats, lore) = {
  block(
    breakable: false,
    width: 100%,
    fill: ivory-card,
    stroke: (left: 2.2pt + crimson, rest: 0.4pt + hairline),
    inset: 4mm,
    radius: 1pt,
  )[
    #grid(
      columns: (1fr, auto),
      align(left, text(font: font-sans, size: 9.5pt, weight: "bold", fill: ink)[#title #h(2mm) #text(font: font-mono, size: 7.5pt, fill: ink-muted, "// " + base-model)]),
      align(right, text(font: font-mono, size: 7.2pt, weight: "bold", fill: gold)[#upper(tier)]),
    )
    #v(1.2mm)
    #text(font: font-mono, size: 7.8pt, fill: crimson)[#stats]
    #v(1.2mm)
    #par(first-line-indent: 0em, leading: 0.58em)[
      #text(font: font-serif, size: 9pt, fill: ink)[#lore]
    ]
  ]
  v(2mm)
}

#weapon-card(
  "Epic · Prologue",
  "Pale Fang",
  "Modified Neurotoxin Knife",
  "+28 Chemical/Neurotoxin Damage · +18% Crit Chance · +25% Crit Damage",
  "Recovered from the Northside oilfield shrine crates and re-weighted by V for silent close-quarters eliminations against regenerative Pale Chorus acolytes."
)

#weapon-card(
  "Epic · Act I",
  "Silent Veil",
  "Suppressed Nue Pistol",
  "+35 Chemical/Toxin Damage · +22% Crit Chance · +35% Headshot Multiplier · Faster Reload",
  "Gifted by Misty upon closing Act I's West Pier manifest—custom-fitted with cold-light ammunition engineered to disrupt synthetic hemoglobin."
)

#weapon-card(
  "Legendary · Act II",
  "Crimson Dawn",
  "Thermal-Incandescent Burya Revolver",
  "+40 Thermal Damage · +25% Crit Chance · +40% Headshot Multiplier",
  "Presented beside The Moon card at the close of the campaign in memory of Mateo M-09—high-caliber thermal rounds built to purge porphyrin contagion."
)

#v(1fr)
#align(center)[
  #line(length: 36mm, stroke: 0.6pt + gold)
  #v(2.5mm)
  #text(font: font-serif, size: 8.5pt, style: "italic", fill: ink-muted)[
    End of File · Crimson Veil: Blood Beneath the Neon · Night City Archive
  ]
]
