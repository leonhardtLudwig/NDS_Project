# Roadmap del progetto

**Aggiornata:** 10 ottobre 2026 (allineata a `07_briefing_per_chat.md`, al tutorial e alle slide)

Fonti di questo documento:
- [`04_incontro_2026-09-18.md`](04_incontro_2026-09-18.md) — le indicazioni del prof. Baggio.
- [`06_slide_corso.md`](06_slide_corso.md) — contenuto delle slide, note a mano comprese.
- Proskurnikov & Tempo, *Tutorial Part I* (il «Paper» in `FINAL/material /`).

**Numerazione.** Il tutorial numera: **Theorem 21**, **Corollary 22**, **Corollary 23**,
**Lemma 24**. Nel notebook `ch04_fj_v3` gli stessi risultati sono chiamati Theorem 4.1,
Corollary 4.1, Corollary 4.2, Lemma 4.1. Qui si usa la numerazione del tutorial; nel report conviene
scegliere una delle due e dichiararla.

---

## Dove lavoro

Cartella `FINAL/`.

- `report/` — scheletro LaTeX (file ancora vuoti): `main.tex` + `intro/`, `fdg/`, `fj/`,
  `conclusion/`. Le sei sezioni qui sotto ci stanno così: §1 → intro, §2–3 → fdg, §4–5 → fj,
  §6 → conclusion.
- `material /` — libro di Bullo (integrazione), Paper, slide del corso.

---

## Cosa devo fare, in breve

1. Analizzare **French-Harary-DeGroot** (FDG) — già visto a lezione, quindi solo richiamo.
2. Analizzare **Friedkin–Johnsen** (FJ) — non visto a lezione, qui serve studiare.
3. Studiare **stubbornness** e **social power** in tutti e due.
4. Confrontare i due modelli su questi due aspetti.

Questo è esattamente quello che ha chiesto Baggio: due modelli, un aspetto ripreso in entrambi,
confronto finale.

---

## Cosa c'è già nelle slide e cosa no

**Già visto a lezione** — nel report basta richiamarlo, senza dimostrazioni:
matrici row-stochastic e **row-substochastic**; Perron–Frobenius; forma di Jordan; grafi
irriducibili, primitivi, aperiodici; **condensation digraph** e **sink**; nodi **globally
reachable**; teorema del **consenso asintotico** e teorema del **disagreement asintotico**.

**Non visto a lezione** — va spiegato: il modello di Friedkin–Johnsen; `Λ` e il vettore delle
**prejudices** `u`; agenti **prejudiced**, **P-dependent** e **P-independent**; il nome *social
power* e la *influence centrality*.

**Però c'è meno materiale nuovo di quanto sembri.** Tre cose che sembrano del tutorial sono già
nelle slide:
- la **social power** è il vettore `w` del teorema del consenso: `lim Aᵏ = 1ₙwᵀ`, con `wᵢ > 0` se e
  solo se *i* è globally reachable. Manca solo il nome.
- la condizione di stabilità del FJ è il **lemma sulle matrici row-substochastic** (R5 sotto).
- la formula dell'equilibrio del FJ è il **teorema del disagreement** (R6 sotto).

---

## L'idea del report in quattro frasi

- Nel FDG ogni aggiornamento è una media, quindi la dispersione può solo ridursi: sotto le ipotesi
  del teorema del consenso si finisce a `(wᵀx(0))·1`.
- Se un agente si dà più peso (self-loop) diventa più testardo: la convergenza può essere
  ripristinata, e lui guadagna social power.
- Il FJ aggiunge un ingresso costante `u`, le prejudices, che non fa parte dello stato. Così il
  disaccordo persiste anche su un grafo fortemente connesso.
- Confrontando i due modelli si vede quanta influenza dà la testardaggine, e che la risposta non è
  la stessa nei due casi.

---

## Struttura del report

| § | Contenuto | Pagine |
|---|---|---|
| 1 | Introduzione + elenco dei modelli in letteratura (Abelson e Taylor solo nominati) | 2 |
| 2 | FDG: richiamo dei risultati, senza dimostrazioni | 2 |
| 3 | Stubbornness e social power nel FDG | 4 |
| 4 | FJ: il modello e i risultati teorici | 5 |
| 5 | Stubbornness e social power nel FJ | 4 |
| 6 | Confronto e conclusioni | 3 |

Le due sezioni su cui si gioca il voto sono la **4** (materiale che Baggio non ha svolto a lezione) e
la **6** (dove sta il confronto che ha chiesto).

---

## Cosa va in ogni sezione

### §2 — FDG, richiamo
- Il modello `x(k+1) = A x(k)`, `A` row-stochastic. A lezione si chiama **French-Harary-DeGroot**.
- Organizzare la sezione sulla **Rosetta stone** delle slide, cioè la tabella dei cinque casi:
  ① A primitiva → consenso; ② A irriducibile non primitiva → non converge; ③ `C(G)` con un sink
  aperiodico → consenso; ④ `C(G)` con ≥ 2 sink aperiodici → disagreement; ⑤ resto → non converge.
  È lo schema di Baggio, e nella §4 il FJ ci si innesta come caso ④.
- **Social power:** il `w` del teorema del consenso (nel tutorial `p_∞`, Definition 15 e §3.5).
  `wᵀA = wᵀ`, `1ᵀw = 1`, e il valore di consenso è `wᵀx(0)`. Nota dalle slide: dipende solo dalle
  condizioni iniziali dei nodi globally reachable.

### §3 — Stubbornness e social power nel FDG
- La testardaggine si modella con il self-loop `aᵢᵢ`, il *self-weight*: è il modo più semplice di
  tenerne conto (parole di Baggio). Stubborn in senso stretto solo con `aᵢᵢ = 1` (Definition 16).
- **Sulla convergenza:** su un ciclo diretto, aggiungere self-loop lo rende aperiodico e lo fa
  convergere; prima era il caso ② della Rosetta stone. Baggio ha indicato questo come un punto da
  stressare.
- **Sull'influenza:** se un solo agente si dà più peso, la sua social power cresce secondo una
  formula esatta (R1). Se lo fanno tutti nello stesso modo, la social power non cambia (R2).

### §4 — FJ, la parte da studiare
- Il modello `x(k+1) = ΛW x(k) + (I−Λ)u`. `Λ = diag(λᵢ)` sono le **susceptibilities**, `u` sono le
  **prejudices**. Agente *i* **prejudiced** se `λᵢ < 1`; **stubborn** se `λᵢ = 0` e `uᵢ = xᵢ(0)`.
  Refuso del tutorial subito dopo l'Eq. (20): «Λ = 0» va letto `Λ = I` (caso FDG).
- `ΛW` è **row-substochastic**: le sue righe sommano esattamente a `λᵢ` (con `Λ ≠ I`, ipotesi del
  tutorial in §6.1, anche nel senso delle slide: almeno una riga < 1). Questo è il punto da cui
  discende tutto il resto.
- **R5 — collegamento col corso.** Nel lemma delle slide sulle matrici row-substochastic,
  «out-degree 1» significa `λᵢ = 1`, cioè agente non prejudiced, e «out-degree < 1» significa agente
  prejudiced. Quindi il lemma del corso è la **Corollary 22** del tutorial. Il corollario delle
  slide («row-substochastic + G fortemente connesso ⟹ convergente») è «`Λ ≠ I` e `W` irriducibile ⟹
  asintoticamente stabile». Lo dice anche il tutorial subito dopo la Corollary 22 («criterion of
  Schur stability for substochastic matrices»).
- **R6 — secondo collegamento col corso** (supponendo tutti gli agenti P-dependent). Il tutorial
  (§6.3) descrive il FJ come un FDG **augmented** con `n` agenti **virtual** stubborn ancorati alle
  prejudices. In quel grafo i sink sono gli `n` nodi virtuali, quindi siamo nel teorema del
  **disagreement** delle slide (caso ④). Nell'esempio delle slide i pesi sono i vettori
  `(I−A₃₃)⁻¹A₃ₖ1`, uno per sink; qui ogni sink è un solo nodo, `A₃₃ = ΛW` e il blocco verso i sink è
  `I−Λ`, quindi quei vettori affiancati formano `V = (I−ΛW)⁻¹(I−Λ)`. Che sommino al vettore di uni è
  «`V` is stochastic» del **Theorem 21**.
- Gli altri risultati del tutorial: **Theorem 21**, **Corollary 23**, agenti **P-independent** (cosa
  succede senza l'ipotesi di R6: i P-independent seguono un FDG e possono formare sink in più, anche
  periodici).

### §5 — Stubbornness e social power nel FJ
- Effetto di `λ`: al calare di `λᵢ` l'agente *i* resta più ancorato alla propria prejudice.
- Uno o più agenti prejudiced, con prejudices uguali o diverse.
- Cosa succede quando una prejudice non raggiunge tutti: agenti **P-independent** (chiamati
  *oblivious* da Parsegov et al., footnote 17 del tutorial).
- La **influence centrality** `c = n⁻¹Vᵀ1` del tutorial (§6.2), che è l'analogo della social power.
  Il tutorial la definisce per il modello asintoticamente stabile con `u = x(0)`.

### §6 — Confronto
- Nel FDG la testardaggine si traduce in social power secondo la formula esatta R1.
- Nel FJ la direzione è la stessa, ma l'effetto cresce meno (R4).
- Le due misure sono collegate: `c_α → p∞` per `α → 1⁻`, con `Λ = αI` (**Lemma 24**).
- Lettura unificante (R3): nel FJ l'influenza è una probabilità di assorbimento verso le prejudices
  (gli stati assorbenti sono gli agenti virtual); nel FDG lo è solo quando ci sono agenti stubborn,
  che sono **absorbing states** (footnote 9 del tutorial). Senza stubborn la social power è la
  distribuzione stazionaria della catena duale (§3.5), e il Lemma 24 la ottiene come limite delle
  `c_α`.

---

## Risultati da presentare come propri

Distinguo due tipi, perché non sono la stessa cosa.

### Ricavati e verificati numericamente

- **R1.** Se la riga dell'agente *i* diventa `(1−t)aᵢᵀ + t·eᵢᵀ`, allora
  `pᵢ(t) = πᵢ / [πᵢ + (1−t)(1−πᵢ)]` e `pⱼ(t) = (1−t)πⱼ / [stesso denominatore]`. In termini di
  rapporto `pᵢ/(1−pᵢ)`, la testardaggine lo moltiplica per `1/(1−t)`. La formula **non dipende dal
  grafo**: questo entra solo attraverso `πᵢ`. *Verificato: errore massimo 4.4e-16.*
  Derivazione in cinque righe (ansatz `qⱼ = cπⱼ` per `j ≠ i`, `qᵢ = cπᵢ/(1−t)`, sostituito in
  `qᵀA(t) = qᵀ`).
- **R2.** Con `A(t) = (1−t)A + tI`, cioè tutti più testardi nella stessa proporzione, `π` non cambia.
  Conta la testardaggine **relativa**. *Attenzione:* su un grafo non regolare, aggiungere la stessa
  costante alla diagonale **non** è questa parametrizzazione e `π` cambia.
- **R3.** Con `A_aug = [[ΛW, I−Λ],[0, I]]` e tutti gli agenti P-dependent, il blocco in alto a destra
  di `lim A_augᵏ` è `V`. Quindi `Vᵢⱼ` è la probabilità che la catena partita da *i* venga assorbita
  dalla prejudice *j*.
  *Verificato: 2.2e-16.*
- **R4.** Facendo scendere `λᵢ` (0.8 → 0.6 → 0.4 → 0.2 → 0.05) con gli altri fermi a 0.8, il
  rapporto `cᵢ/(1−cᵢ)`, normalizzato al caso base, cresce molto meno dell'ancoraggio relativo
  `(1−λᵢ)/(1−0.8)` (1.00 → 1.66 → 2.13 → 2.49 → 2.70 contro 1.00 → 2.00 → 3.00 → 4.00 → 4.75), e le
  proporzioni fra gli altri agenti non si conservano (deviazione 8.6e-2, contro 1e-16 nel FDG).
  Spiegazione: nel FJ ogni agente ha la propria prejudice, quindi nessuna può assorbire tutto.
  Controprova: togliendo le prejudices agli altri (`λⱼ = 1`) si ritorna a `V = 1·e₁ᵀ`.
  *Questa è un'osservazione numerica, non una formula: non ho una forma chiusa per `cᵢ(λᵢ)`.*
  *Da completare:* indicare quale `W` è stata usata per questi numeri.

### Collegamenti fra il corso e il tutorial

Non sono risultati nuovi: sono lo stesso teorema letto in due linguaggi. È comunque la cosa più
utile da mostrare, perché è il *«dare una nuova veste a risultati del corso»* che ha chiesto Baggio.

- **R5.** Il lemma delle slide sulle matrici row-substochastic è la **Corollary 22** del tutorial.
  *Verificato su 356 casi casuali:* la condizione del lemma calcolata sul grafo di `ΛW`, la
  condizione «tutti gli agenti sono P-dependent» e `ρ(ΛW) < 1` coincidono sempre. Sono tre calcoli
  indipendenti, quindi la verifica ha contenuto.
- **R6.** Il teorema del disagreement delle slide, applicato al grafo augmented del tutorial (§6.3)
  con tutti gli agenti P-dependent, dà la formula dell'equilibrio del FJ. La verifica sostanziale è
  R3, che mostra che `V` è davvero il blocco di assorbimento di quel grafo; la sostituzione dei
  blocchi (`A₃₃ = ΛW`, blocco verso i sink `= I−Λ`) è poi un'identità algebrica.

---

## Cose che devo saper spiegare a voce

Se non so spiegare una di queste, quella cosa non entra nel report.

**FDG** — bastano enunciato e intuizione, è materiale del corso
- I cinque casi della Rosetta stone.
- Cos'è `w` e perché il consenso vale `wᵀx(0)`, e perché contano solo i nodi globally reachable.
- Perché un agente con `aᵢᵢ = 1` raggiunto da tutti si prende tutto il consenso.
- R1 e R2.

**FJ** — qui serve capire davvero
- Perché `ΛW` row-substochastic rende possibile il disaccordo: `1` non è più autovettore.
- **R5:** perché il lemma sulle row-substochastic è la condizione di stabilità del FJ. Le righe di
  `ΛW` sommano a `λᵢ`, quindi i nodi con out-degree < 1 sono esattamente gli agenti prejudiced, e la
  condizione del lemma è «ogni agente non prejudiced raggiunge un agente prejudiced».
- **R6:** perché, con tutti gli agenti P-dependent, il FJ è il caso ④ della Rosetta stone. Nel grafo
  augmented i sink sono gli `n` nodi virtuali (le prejudices), quindi `nₛ ≥ 2` e si è nel
  disagreement; l'equilibrio è la combinazione convessa dei valori dei sink.
- **Theorem 21:** perché il blocco degli agenti P-dependent è sempre asintoticamente stabile, e
  perché `V` row-stochastic significa che il disaccordo è limitato.
- **Corollary 22:** stabilità asintotica ⟺ tutti gli agenti sono P-dependent.
- **Corollary 23:** perché serve un risultato a parte per la convergenza — il tutorial osserva che
  in generale, per `x(k+1) = Ax(k) + Bu`, la regolarità di `A` non basta, e dà il controesempio
  `A = B = I`.
- **Footnote 21** del tutorial: perché il FJ è asintoticamente stabile anche se è equivalente a un
  FDG che non lo è — cambiando `x(0)` il vettore `u` resta fermo, mentre nel FDG la prejudice fa
  parte dello stato.
- R3 e R4.

---

## Reti usate

Due in tutto il report.

- **Ciclo diretto a 6 nodi**, con self-loop quando serve l'aperiodicità. Regge tutto il filo
  principale, in entrambi i modelli.
- **Lo stesso ciclo con un arco deviato:** l'agente 3 ascolta 1 invece di 4. `{1,2,3}` diventa un
  sink e `{4,5,6}` vi confluisce. Serve solo per gli agenti P-independent: mettendo l'agente
  prejudiced dentro o fuori dal sink si ottengono i due casi, quindi non serve una terza rete.

---

## Fuori scope

Abelson, Taylor, containment control, FJ multidimensionale, modello gossip della Part II.
Di Abelson e Taylor resta una riga a testa nell'elenco della §1 (indicazione esplicita di Baggio).

---

## In che ordine lavorare

1. **Studiare la §4.** È la parte non svolta a lezione. Rileggere la §6 del tutorial finché i punti
   della checklist FJ non sono chiari. Prima di questo non scrivere. Percorso scelto: modello →
   `ΛW` row-substochastic → R5 → R6 (tutti P-dependent) → Theorem 21, Corollary 23, P-independent →
   footnote 21.
2. **Scrivere la §4.**
3. **Scrivere §2 e §3.** Più rapide: richiamo delle slide più R1 e R2.
4. **Scrivere la §5.**
5. **Scrivere la §6.**
6. **Scrivere la §1** per ultima.

Le figure si fanno dopo il testo di ogni sezione.

---

## Consegna

Report di ~20 pagine, in inglese, che è il deliverable principale. Presentazione di supporto
(facoltativa). Il codice è lo strumento: i risultati numerici vanno nel report. Baggio legge il
report prima della discussione e poi chiede chiarimenti sulle parti non chiare.
Scadenza: febbraio 2027.
