# Velo Carmesí — Biblia Literaria Completa (v0.5.0)

> **Propósito del documento:** Fuente única de verdad narrativa para el reinicio estructural de *Crimson Veil* (`v0.5.0+`). Todo diálogo, pista forense, entrada del códice y objetivo de misión nace de esta historia para garantizar claridad absoluta, coherencia dramática y cero dependencias externas (100 % Cyberpunk 2077 Base Game `2.x`).

---

## 1. Reparto Principal y Facción

| Personaje | Rol Narrativo | Voz / Presencia | Motivo y Conflicto |
| :--- | :--- | :--- | :--- |
| **V** | Mercenario/a en Watson; antiguo contacto cercano de Misty y Jackie | `v_fem` / `v_male` (ES/EN) | Empieza por lealtad personal hacia Misty; descubre una red biomédica clandestina que convierte la necesidad clínica en depredación nocturna. |
| **Misty Olszewski** | Dueña de *Esoterica*; guía moral, vínculo emocional con el barrio | `misty` (voz propia original, sin clonar CDPR) | Siente que el barrio desaparece poco a poco y nadie pregunta. Aprende que sus lecturas del Tarot eran usadas como código de auxilio por Lucía. |
| **Lucía Reyes** | Vecina de Kabuki (23 años, abrigo verde gastado); barre el escaparate de *Esoterica* | Hilo conductor vivo en Prólogo y Acto I | Recibe transfusiones experimentales del programa **NOX-9** tras un accidente respiratorio crónico; queda fotosensible y atrapada en la red del **Coro Pálido**. |
| **Mateo** | Técnico nocturno del muelle de Northside (desaparecido días antes) | Mencionado en el altar y registros médicos | Primera pista clara de que los casos no son aislados: desapareció tres noches antes que Lucía tras intentar robar su propio historial de dosis. |
| **Dr. Adrián Valdés** | Antiguo investigador hematológico expulsado de BioTechnica | `valdes` | Creador del compuesto **NOX-9** (hemoglobina sintética + estabilizador experimental con acumulación de porfirinas reactivas). Cree estar salvando desahuciados, pero oculta su fracaso tras un culto de silencio. |
| **Dra. Helena Solís («La Cantora»)** | Directora operativa del **Coro Pálido** | Antagonista principal (Actos I–II) | Convirtió la terapia experimental de Valdés en un protocolo de selección y reclutamiento forzado: quienes sobreviven a la fotosensibilidad quedan vinculados por dependencia química al suero de mantenimiento. |

---

## 2. Prólogo — *La Luna Manchada* (Implementado en `v0.5.0`)

### Escena 1: La llamada (Holollamada entrante automática en Watson)
Nada más estabilizarse V en la ciudad, suena su comunicador con una llamada urgente de **Misty Olszewski**. No es una charla casual: Misty habla bajo, nerviosa, explicando que **varias amigas y conocidos del barrio han desaparecido** en las últimas semanas, que **ella misma se siente vigilada** desde el callejón trasero de *Esoterica* y que esa misma mañana ha encontrado **un extraño altar frente a la entrada**: media docena de **cirios de cera derretida por la humedad** y **una única carta del Tarot cubierta por una mancha oscura**. Le suplica a V que se reúna con ella allí antes de que alguien borre el rastro.

### Escena 2: El altar del callejón (Llegada y advertencia)
V acude a la puerta trasera de *Esoterica* en Watson. Misty le espera junto al altar improvisado de seis cirios húmedos y la carta solitaria. Le advierte de inmediato:
> *«No la toques todavía. Escanéala primero. La dejaron de noche, antes del alba, sin que nadie viera quién fue.»*

### Escena 3: Escaneo Kiroshi y la verdad de la mancha
V activa las ópticas Kiroshi sobre la carta manchada y obtiene la lectura bioquímica:
> *«No es sangre normal, Misty. Es hemoglobina sintética mezclada con un estabilizador experimental… y tiene una traza altísima de porfirinas reactivas. Quien sangró sobre esta carta sufriría quemaduras internas graves si le diera el sol directo.»*

Misty cierra los ojos un instante; al abrirlos confirma su peor sospecha:
> *«Es de Lucía.»*  
> *«¿La chica del abrigo verde que a veces barre tu escaparate?»*  
> *«Sí —susurra Misty, señalando dos muescas minúsculas hechas con una uña en la esquina inferior izquierda—. Se lo enseñé el mes pasado, cuando me dijo que tenía pesadillas y no podía dormir. Jugábamos a que cada Arcano era una palabra secreta. La Luna significa: “Estoy despierta en la oscuridad, pero no puedo salir a la luz”. Lleva tres noches sin aparecer por su pensión de Kabuki.»*

V observa los cirios apagados: los carroñeros no dejan velas ni cartas marcadas con código personal.

### Escena 4: Ronda de investigación en el callejón (Preguntas opcionales + cita nocturna)
Antes de subir a la azotea, V puede interrogar a Misty sobre todo lo que sabe para situar el caso con total claridad:
1. **Otros desaparecidos:** Misty explica el caso de **Mateo**, un técnico del muelle de Northside desaparecido días antes de Lucía tras empezar a evitar las calles iluminadas, y de otros dos jóvenes sin familia cercana.
2. **La vigilancia sobre Misty:** Explica que un furgón negro sin matrícula estuvo dos madrugadas en la esquina opuesta y que alguien apagó las farolas del callejón justo antes de aparecer los cirios.
3. **Lo que Lucía contó sobre «El Coro Pálido»:** Lucía mencionó haber firmado un «tratamiento gratuito de noche» en una clínica satélite porque sus pulmones no aguantaban el smog industrial; desde entonces tenía fiebre fría y miedo al amanecer.

Misty le pide entonces el siguiente paso claro:
> *«Sube conmigo a la azotea cuando anochezca del todo. Abajo hay demasiado ruido y demasiados ojos. A las diez te enseño todo lo que Lucía me contó antes de desaparecer.»*

### Escena 5: La azotea de *Esoterica* (22:00) y la pista UV 365 nm
Ya en la azotea, bajo la lluvia de neón de Watson, Misty extiende tres Arcanos sobre la mesa ritual: **La Luna**, **El Ermitaño** y **La Torre**, trazando el mapa emocional y práctico del secuestro. Al contrastar la carta manchada con la lámpara UV portátil (`365 nm`) de Misty aparece una marca invisible de almacén industrial de Northside.

### Escena 6: Incursión en los campos petrolíferos de Northside
V acude de noche al santuario provisional montado en los depósitos de Northside. Allí vigilan varios centinelas del Coro Pálido protegidos bajo un **emisor UV experimental** y torretas ligeras. Al sobrecargar el emisor UV y neutralizar la escolta, V registra la mesa de carga y recupera:
- Un **vial vacío de plasma NOX-9** con lote clínico trazable.
- Un **recibo de transporte rasgado** con fecha de esa madrugada: *«Sujeto L-14 (Lucía Reyes). Trasladarla antes del relevo del muelle.»*

### Escena 7: Regreso a la azotea (Cierre del Prólogo)
V regresa junto a Misty y le entrega las pruebas. Lucía **sigue viva**, pero el convoy nocturno ya partió hacia las instalaciones de contención de **La Cantora**. El Prólogo concluye con el tablero abierto, la recompensa inicial entregada (**+1.200 €$**, **+500 XP**, pistola icónica **«Colmillo Pálido»** recuperada del alijo del santuario) y el objetivo inequívoco para el Acto I: seguir el rastro del lote **NOX-9** hasta el doctor **Adrián Valdés** y rescatar a Lucía antes del siguiente ciclo de dosificación.

---

## 3. Acto I — *El Pulso del Lote NOX-9* (Siguiente fase)
1. **Rastreo del lote farmacéutico:** Con el código del vial recuperado en Northside, V localiza al **Dr. Adrián Valdés** en una consulta clandestina de Heywood/Santo Domingo (ubicación nueva e inédita, lejos de clínicas repetidas).
2. **El dilema de Valdés:** Valdés confiesa que diseñó el estabilizador hematológico para tratar hipoxias irreversibles sin depender de cibernética corporativa, pero las porfirinas reactivas causaron fototoxicidad extrema. Al quedarse sin fondos, **Helena Solís («La Cantora»)** compró sus patentes y transformó el ensayo clínico en una orden clandestina que secuestra pacientes vulnerables y utiliza el miedo a la luz solar como jaula.
3. **Localización del punto de relevo:** Valdés entrega la frecuencia de baliza del bloque de almacenamiento refrigerado donde el Coro Pálido mantiene a los recién «despertados», incluida **Lucía Reyes** y las notas de campo sobre **Mateo**.

---

## 4. Acto II — *Liturgia de Ceniza* (Clímax)
1. **Infiltración en el santuario subterráneo:** V se infiltra en el antiguo nodo frigorífico convertido en capilla clínica de **La Cantora**. Debe neutralizar los proyectores de luz negra y acceder al pabellón de aislamiento.
2. **Encuentro con Lucía:** Lucía está debilitada por la abstinencia del estabilizador, pero consciente; reconoce el código de **La Luna** que V trae de parte de Misty y aporta el registro maestro del último suero estabilizador de segunda generación (**NOX-9B**), oculto en la cámara central de **La Cantora**.
3. **Confrontación con Helena Solís («La Cantora»):** La Cantora no se ve como una traficante sino como la arquitecta de una nueva supervivencia nocturna. Antes o después del enfrentamiento táctico, el jugador decide el destino del laboratorio, del suero **NOX-9B** y de Valdés.

---

## 5. Desenlaces Posibles (Acto II -> Finales)

### Final A — *El Segundo Suero* (Rescate pleno y salvación clínica)
V derrota a **La Cantora**, recupera intacta la fórmula depurada **NOX-9B** y obliga o convence a **Valdés** de sintetizar la versión sin acumulación de porfirinas bajo la vigilancia de Misty. Lucía y los supervivientes recuperan progresivamente su tolerancia a la luz diurna.

### Final B — *Pacto en la Penumbra* (Acuerdo pragmático)
V negocia un alto el fuego con **La Cantora** a cambio de la liberación inmediata de **Lucía** y la promesa de no volver a actuar sobre Watson. El Coro Pálido sobrevive en las sombras de Night City como red cerrada; Misty acepta el rescate, pero lamenta que otros barrios sigan pagando el precio.

### Final C — *Alba de Sangre* (Destrucción total)
V destruye las cámaras UV, los servidores y las reservas de estabilizador para erradicar al Coro Pálido de raíz. **Lucía** es rescatada con vida, aunque deberá permanecer meses protegida de la luz solar directa mientras Misty busca ayuda médica alternativa fuera de Watson.

---

## 6. Epílogo — *Tres Meses Después*
Una mañana limpia después de la lluvia, el escaparate de *Esoterica* vuelve a estar abierto. Dependiendo del desenlace elegido, Misty deja un mensaje final y una última lectura simbólica del Tarot para V: **La Luna** ya no es una llamada de socorro en la oscuridad, sino el recordatorio de quienes sobrevivieron a la noche más larga de Watson.
