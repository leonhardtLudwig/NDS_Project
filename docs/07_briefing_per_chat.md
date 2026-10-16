# Progetto NDS — documento di contesto

**Come usare questo file.** Incollalo (o caricalo) all'inizio di una nuova chat con Claude. Contiene
tutto il necessario: non servono altri allegati. Se carichi anche il tutorial di Proskurnikov &
Tempo, tanto meglio, ma non è indispensabile: gli enunciati che servono sono riportati qui
testualmente.

**Cosa la chat NON può fare:** non ha accesso ai file del progetto, non può eseguire MATLAB, non può
vedere le slide. Tutti i numeri citati qui sono già stati verificati; se servono numeri nuovi vanno
calcolati a parte.

---

## 1. Il progetto in due righe

Progetto da 3 CFU per il corso *Network Dynamical Systems* (prof. Giacomo Baggio, Padova).
Tema: **la stubbornness nei modelli di opinion dynamics**, confrontando due modelli.
Deliverable: **un report di circa 20 pagine**.

### Vincoli fissati in un incontro col prof. il 18/09/2026

- **Solo due modelli: French-Harary-DeGroot (FDG) e Friedkin–Johnsen (FJ).** Abelson e Taylor vanno
  solo nominati in un elenco iniziale dei modelli in letteratura, senza trattazione.
- **Fuori scope:** containment control (il prof.: interessante, ma è applicazione da mobile robotics,
  non da reti sociali), FJ multidimensionale, versione gossip della Part II.
- **Due aspetti da studiare in entrambi i modelli: stubbornness e social power**, con un confronto
  finale fra i due modelli su questi aspetti.
- La parte FDG va tenuta **molto stringata**: è materiale già svolto a lezione, va solo richiamato e
  riletto in chiave reti sociali. Uno o due esempi al massimo.
- La parte FJ è **la parte nuova**: va presentata e soprattutto **capita**.
- Il codice è solo lo strumento; i risultati numerici vanno dentro il report.
- Il prof. legge il report prima della discussione e poi chiede chiarimenti sulle parti non chiare.
- Scadenza: febbraio 2027.

### Criterio di valutazione — citazione testuale del prof.

> «Apprezzo molto di più il focalizzarsi ed aver compreso bene poche singole cose rispetto a fare una
> trattazione molto esaustiva ma superficiale.»

> «I risultati che riporterà deve capirli, perché questa è la cosa più importante. Non dico capire la
> proof riga per riga, ma almeno avere un'intuizione del perché.»

> «La cosa più importante è che io devo capire che lei ha capito quello che sta presentando.»

**Conseguenza operativa:** ogni risultato nel report dev'essere spiegabile a voce, con l'intuizione.
Se non è spiegabile, va tolto. Non aggiungere materiale per fare volume.

---

## 2. Notazione e convenzioni

### I due modelli

**French-Harary-DeGroot** (così si chiama nelle slide del corso):

```
x(k+1) = A x(k),        A row-stochastic
```

**Friedkin–Johnsen:**

```
x(k+1) = Λ W x(k) + (I − Λ) u
x_i(k+1) = λ_i · Σ_j w_ij x_j(k) + (1 − λ_i) u_i
```

- `W` — matrice row-stochastic delle influenze sociali.
- `Λ = diag(λ_1, …, λ_n)`, `0 ≤ λ_i ≤ 1` — le **susceptibilities** (apertura all'influenza sociale).
- `u` — le **prejudices**: opinioni preesistenti, ingresso costante, non parte dello stato. Nella
  teoria FJ originale si pone `u = x(0)`; il tutorial le tiene indipendenti (§6).
- `1 − λ_i` — il peso dell'ancoraggio, riapplicato **ad ogni passo** (nel tutorial:
  «susceptibilities' complements»; l'agente è «anchored» alla propria prejudice).
- La riga *i* di `ΛW` somma a `λ_i`. Con `Λ ≠ I` (ipotesi del tutorial in §6.1) `ΛW` è quindi
  row-substochastic anche nel senso delle slide (almeno una riga < 1).

Casi limite: `λ_i = 1` per ogni `i` (cioè `Λ = I`) ⟹ il modello **è** FDG. `λ_i = 0` ⟹
`x_i(k) = u_i` per ogni `k ≥ 1`.
**Refuso del tutorial:** subito dopo l'Eq. (20) (§6) c'è scritto «in the case Λ = 0 the model (20)
turns into the French-DeGroot model (2)». È `Λ = I`, come dice lo stesso tutorial in §6.1 e §6.3.

### Terminologia del tutorial (va usata questa)

- Agente **prejudiced** se `λ_i < 1`.
- Nel FJ: agente **stubborn** se `λ_i = 0` **e** `u_i = x_i(0)`. Attenzione: `λ_i = 0` da solo
  **non** basta — l'agente è costante, ma non necessariamente al valore da cui è partito.
- Nel FDG (Definition 16, §3.6): agente **stubborn** ⟺ `a_ii = 1`. Il peso `a_ii` è il
  **self-weight** (nel tutorial «self-influence weight», «self-weights»; con `a_ii = 0` l'agente è
  «open-minded»). Un agente con `0 < a_ii < 1` **non** è stubborn. «"Partially" stubborn» (tutorial,
  fine §4.3) va usato solo come termine informale.
- Agente **P-dependent** se è prejudiced oppure è influenzato da un agente prejudiced.
  Altrimenti **P-independent**.
- Parsegov et al. usano una terminologia diversa (footnote 17 del tutorial): loro chiamano
  *stubborn* i prejudiced, *totally stubborn* gli stubborn, e *oblivious* i P-independent.
  **Nel report conviene seguire il tutorial e non mescolare.**
- `V = (I − ΛW)^{-1}(I − Λ)` è la matrice che manda le prejudices nelle opinioni finali:
  `x(∞) = V u`. **Vale solo se tutti gli agenti sono P-dependent** (Corollary 22). Con agenti
  P-independent il tutorial usa un'altra `V`, di dimensione r×n (Theorem 21, Eq. (23)).
- **Influence centrality** (tutorial §6.2): `c = n^{-1} Vᵀ 1`. Il tutorial la definisce per il
  modello asintoticamente stabile con `u = x(0)`: allora `c_i` è il peso medio dell'opinione iniziale
  di *i* nelle opinioni finali.
- **Social power** (FDG): il vettore `w` con `wᵀA = wᵀ`, `1ᵀw = 1`. Nelle slide è il `w` del teorema
  del consenso (il nome «social power» non compare); nel tutorial è `p_∞` (Definition 15, §3.5).

### ⚠️ Trappola sulla direzione degli archi

Le due fonti disegnano le frecce in verso opposto, **con la stessa matrice**:

- **Tutorial (Proskurnikov & Tempo), §3.2, testuale:** *«An arc (j, i) exists if agent j's opinion is
  displayed to agent i, or j "has power over" i.»* Le frecce seguono il **flusso dell'influenza**.
  In generale (Definition 2, §2.2): arco `(i, j)` ⟺ `a_ji > 0`.
- **Bullo, *Lectures on Network Systems*:** «i seeks advice from j» ⟺ `a_ij > 0`. Frecce verso chi si
  ascolta.
- **Slide del corso (deck DT):** «(i,j) ∈ E if i is influenced by j». Stessa convenzione di Bullo.
- **Convenzione del progetto (uguale a slide e Bullo):** `W(i,j) > 0` significa che l'agente *i* dà
  peso all'opinione di *j*. La riga *i* elenca chi *i* ascolta.

Conseguenza concreta sulla definizione di P-dependent. Il tutorial scrive testualmente:
*«Agent i is P-dependent if it is prejudiced or influenced by some prejudiced agent j, that is, **a
walk from j to i** in the graph G[W] exists.»* Nella convenzione del progetto lo stesso fatto si
scrive come un cammino **da i a j**. La condizione sulla matrice è identica in entrambi i casi:
`(W^p)_{ij} > 0` per qualche `p`, con *j* prejudiced. **Dichiarare la convenzione una volta nel
report e poi non cambiarla.**

### Stessi oggetti, nomi diversi (tutorial ↔ slide)

Oltre al verso degli archi, alcune cose hanno nomi o definizioni diverse nelle due fonti:

| Tutorial | Slide del corso |
|---|---|
| French-DeGroot model, matrice `W` | French-Harary-DeGroot model, matrice `A` |
| *substochastic* (Definition 11): ogni riga somma a ≤ 1, **stocastiche comprese** | *row-substochastic*: ogni riga ≤ 1 **e almeno una < 1** |
| *regular* (esiste `lim W^k`) | *semi-convergent* |
| *fully regular* (`W^∞ = 1ₙp_∞ᵀ`) | (A2) del teorema del consenso (`lim A^k = 1ₙwᵀ`) |
| *Schur stable* | *convergent (or Schur stable)* |
| *closed strong component* | *sink* di `C(G)` |
| *root node*; grafo *quasi-strongly connected* | *globally reachable node*; `G` ne contiene uno |
| agente stubborn = *source node* con `w_ii = 1` | nodo con `a_ii = 1`, che da solo forma un sink di `C(G)` |

Nel report va dichiarata una sola definizione di (row-)substochastic, e i termini del tutorial
vanno tradotti in quelli scelti per il report quando se ne cita un enunciato.

### Refusi e incoerenze del tutorial (da non copiare)

- §6, subito dopo l'Eq. (20): «Λ = 0» invece di `Λ = I` (vedi sopra, «Casi limite»).
- Theorem 21: la `V` dell'Eq. (23) è r×n, quella della Corollary 22 è n×n; inoltre la notazione
  mescola pedici (`x_1`, `x_2`, `u_1` nelle Eq. (21)–(22)) e apici (`x¹`, `x²`, `u¹` nella (23)).
- Eq. (18), Theorem 18 (Taylor, fuori scope): manca il segno meno davanti a `L¹²`. L'Eq. (15),
  invece, è stampata correttamente: `ẋ = −(L[A] + Γ)x + Γu`.

---

## 3. Cosa è già stato svolto a lezione

Verificato leggendo le slide del corso. **Questo materiale va solo richiamato, senza dimostrazioni.**

Coperto: matrici row-stochastic e **row-substochastic**; Perron–Frobenius; forma di Jordan; grafi
irriducibili, primitivi, aperiodici; **condensation digraph** `C(G)` e **sink**; nodi **globally
reachable**; teorema del consenso asintotico; teorema del disagreement asintotico.

Non coperto, quindi da spiegare: il modello FJ; `Λ` e `u`; agenti prejudiced / P-dependent /
P-independent; il *nome* social power; la influence centrality.

### I tre enunciati delle slide che contano

**Lemma (Convergent row-substochastic matrices).** Sia `G` un weighted digraph con matrice di
adiacenza `A` row-substochastic. Allora `A` è convergente (cioè `lim A^k = 0`) **se e solo se** `G`
contiene cammini diretti da ogni nodo con out-degree (pesato) 1 a un nodo con out-degree (pesato)
strettamente minore di 1.
*Corollario:* `A` row-substochastic + `G` fortemente connesso ⟹ `A` convergente.

**Teorema (Consensus in DT averaging systems).** `A` row-stochastic. Sono equivalenti: (A1)
l'autovalore 1 è semplice e gli altri hanno `|μ| < 1`; (A2) `A` è semi-convergente e
`lim A^k = 1ₙwᵀ` con `w ≥ 0`, `1ᵀw = 1`, `wᵀA = wᵀ`; (A3) `G` contiene un nodo globally reachable e
il sottografo dei globally reachable è aperiodico. Allora `w_i > 0` ⟺ *i* è globally reachable, e
`lim x(k) = (wᵀx(0))·1ₙ`.

**Teorema (Disagreement in DT averaging systems).** `A` row-stochastic, `C(G)` con `n_s ≥ 2` sink.
Equivalenti: (A1) l'autovalore 1 è semi-semplice con molteplicità `n_s`, gli altri `|μ| < 1`; (A2)
`A` semi-convergente; (A3) ogni sink di `C(G)` è aperiodico. Allora `lim x(k) = v ≠ α1ₙ`.
Nell'esempio svolto a lezione, `A = [[A₁₁, 0, 0], [0, A₂₂, 0], [A₃₁, A₃₂, A₃₃]]`: due sink
(`A₁₁`, `A₂₂` primitive) e un blocco non-sink `A₃₃` (row-substochastic e convergente). Il limite del
blocco non-sink è una **combinazione convessa** dei valori di consenso dei sink:
`x₃(∞) = (I − A₃₃)^{-1}A₃₁1 · w₁ᵀx₁(0) + (I − A₃₃)^{-1}A₃₂1 · w₂ᵀx₂(0)`.
I pesi sono due **vettori**, uno per sink, e sommano al vettore di uni:
`(I − A₃₃)^{-1}A₃₁1 + (I − A₃₃)^{-1}A₃₂1 = 1`.

### La "Rosetta stone"

L'ultima slide del deck DT è una tabella riassuntiva, `A` row-stochastic:

| | condizione | grafo | esito |
|---|---|---|---|
| ① | A primitiva | fort. connesso e aperiodico | consenso |
| ② | A irriducibile non primitiva | fort. connesso e periodico | non converge |
| ③ | 1 semplice e strettamente dominante, A non primitiva | `C(G)` ha 1 sink aperiodico | consenso |
| ④ | 1 semi-semplice non semplice, str. dominante | `C(G)` ha ≥ 2 sink aperiodici | **disagreement** |
| ⑤ | altrimenti | — | non converge |

È lo schema del prof. Conviene organizzarci sopra la sezione FDG del report, perché poi **il FJ ci
si innesta come caso ④**.

---

## 4. I risultati del tutorial (enunciati testuali)

Numerazione del tutorial. (Nei notebook del progetto gli stessi risultati sono chiamati Theorem 4.1,
Corollary 4.1, Corollary 4.2, Lemma 4.1 — scegliere una numerazione e dichiararla.)

> **Theorem 21.** Let the community have `r ≥ 1` P-dependent agents and `n − r ≥ 0` P-independent
> ones. Then, the subsystem (21) is asymptotically stable, i.e. `Λ¹¹W¹¹` is Schur stable
> `ρ(Λ¹¹W¹¹) < 1`. The model (20) is convergent if and only if `r = n` or (22) is convergent, i.e.
> `W²²` is regular. In this case `x¹(∞) = V[u¹; x²(∞)]`, `V ≜ (I_r − Λ¹¹W¹¹)^{-1}[I_r − Λ¹¹  Λ¹¹W¹²]`
> (23). The matrix `V` is stochastic, i.e. the final opinion of any agent is a convex combination of
> the prejudices and final opinions of P-independent agents.

Qui gli agenti sono ordinati con i P-dependent per primi: (21) è
`x₁(k+1) = Λ¹¹[W¹¹x₁(k) + W¹²x₂(k)] + (I − Λ¹¹)u₁` e (22) è `x₂(k+1) = W²²x₂(k)`, cioè i
P-independent seguono un FDG. La `V` di (23) è r×n e coincide con la `V` della Corollary 22 solo se
`r = n`.

> **Corollary 22.** The Friedkin-Johnsen model (20) is asymptotically stable **if and only if all
> agents are P-dependent**. Then, `V = (I − ΛW)^{-1}(I − Λ)`. This holds, in particular, if `Λ < Iₙ`
> or `Λ ≠ Iₙ` and `G[W]` is strongly connected (`W` is irreducible).

> **Corollary 23.** The model (20) converges if and only if `A = ΛW` is regular, i.e. the limit
> `lim A^k` exists.

> **Lemma 24.** Let `W` be a fully regular matrix and `p∞` stand for the vector of French's social
> power, corresponding to the model (2). Then, `p∞ = lim_{α→1−0} c_α`.

Qui `c_α` è la influence centrality del FJ con `Λ = αIₙ`, `α ∈ (0, 1)`.

**Due osservazioni del tutorial da non perdere:**

- Corollary 23 **non è banale**: il tutorial nota che in generale, per `x(k+1) = Ax(k) + Bu`, la
  regolarità di `A` non basta a garantire la convergenza, e porta il controesempio `A = B = I`.
  Osserva anche che il risultato è enunciato in Friedkin & Johnsen (1999) e in Friedkin (2015)
  *senza dimostrazione rigorosa*.
- **Footnote 21.** Il FJ con `λ_i = 0` per gli agenti stubborn è *equivalente* a un FDG con agenti
  stubborn, eppure il primo è asintoticamente stabile e il secondo no. Spiegazione del tutorial:
  cambiando `x(0)` in (20) il vettore `u` resta costante, mentre nel modello originale la prejudice
  fa parte del vettore di stato, il che distrugge la stabilità asintotica.

Il tutorial descrive anche (§6.3) il FJ come un FDG **augmented** con `n` agenti **virtual** stubborn
ancorati alle prejudices, e (footnote 9) osserva che nel FDG gli agenti stubborn corrispondono a
**absorbing states** della catena di Markov duale.

---

## 5. Risultati ricavati nel progetto

Tutti verificati numericamente in MATLAB. **Vanno distinti in due tipi**, perché non sono la stessa
cosa.

### 5a. Ricavati e verificati

**R1 — formula esatta per l'effetto della stubbornness sulla social power (FDG).**
Se la riga dell'agente *i* diventa `(1−t)·a_iᵀ + t·e_iᵀ` (cioè l'agente mette peso `t` su se stesso e
`1−t` su quello che ascoltava prima), allora, detto `π` il vettore di social power di partenza:

```
p_i(t) = π_i / [π_i + (1−t)(1−π_i)]
p_j(t) = (1−t)·π_j / [π_i + (1−t)(1−π_i)]      per j ≠ i
```

Equivalentemente, il rapporto `p_i/(1−p_i)` viene moltiplicato per esattamente `1/(1−t)`.
Gli altri agenti mantengono fra loro le stesse proporzioni. **La formula non dipende dal grafo**: la
topologia entra solo attraverso `π_i`. Per `t → 1` si ha `p_i → 1`.
*Verificato: errore massimo 4.4e-16.*
*Derivazione (cinque righe):* ansatz `q_j = c·π_j` per `j ≠ i` e `q_i = c·π_i/(1−t)`; sostituendo in
`qᵀA(t) = qᵀ`, per `j ≠ i` il fattore `(1−t)` della riga *i* si cancella con `1/(1−t)`; per `j = i`
si ottiene `q_i(1−t)(1−a_ii) = c·π_i(1−a_ii)`.

**R2 — la stubbornness uniforme non sposta l'influenza.**
Con `A(t) = (1−t)A + tI`, cioè tutti più testardi nella stessa proporzione, `π` non cambia:
`πᵀA(t) = (1−t)πᵀ + tπᵀ = πᵀ`. Cambia solo la velocità di convergenza, perché gli autovalori vengono
mappati con `μ ↦ (1−t)μ + t`. **Conta la stubbornness relativa, non quella assoluta.**
*Attenzione:* su un grafo non regolare, aggiungere la stessa costante alla diagonale della matrice
di adiacenza **non** è questa parametrizzazione, e `π` in quel caso cambia.

**R3 — `V` è una matrice di probabilità di assorbimento.**
Posto `A_aug = [[ΛW, I−Λ], [0, I]]` (il grafo augmented del tutorial §6.3), con tutti gli agenti
P-dependent il blocco in alto a destra di `lim A_aug^k` è esattamente `V`. Quindi `V_ij` è la
probabilità che la catena partita da *i* venga assorbita dalla prejudice *j*, e `c = n^{-1}Vᵀ1` è la
probabilità media di assorbimento verso ciascun ancoraggio. Nel FDG vale lo stesso **solo con agenti
stubborn**, quando ogni agente ne raggiunge almeno uno (Corollary 14): le colonne di `lim A^k`
relative agli stubborn sono probabilità di assorbimento (footnote 9: gli agenti stubborn sono
absorbing states). Senza agenti stubborn, invece, la social power (`w`, cioè `p_∞` del tutorial) è
la distribuzione stazionaria della catena duale (§3.5); il legame con l'assorbimento passa per il
Lemma 24 (`p_∞` come limite delle `c_α`).
*Verificato: 2.2e-16.*

**R4 — nel FJ l'effetto cresce molto meno che nel FDG.**
Facendo scendere `λ_i` (0.8 → 0.6 → 0.4 → 0.2 → 0.05) con gli altri agenti fermi a `λ = 0.8`, il
rapporto `c_i/(1−c_i)`, normalizzato al caso base `λ_i = 0.8`, cresce 1.00 → 1.66 → 2.13 → 2.49 →
2.70, mentre l'ancoraggio relativo `(1−λ_i)/(1−0.8)` cresce 1.00 → 2.00 → 3.00 → 4.00 → 4.75.
Inoltre le proporzioni fra gli altri agenti **non** si conservano (deviazione 8.6e-2, contro 1e-16
nel caso FDG di R1).
*Spiegazione:* nel FJ ogni agente ha la propria prejudice, quindi nessuna può assorbire tutto.
*Controprova:* togliendo la prejudice agli altri (`λ_j = 1`) si ritorna a `V = 1·e₁ᵀ`, cioè cattura
totale.
**Questa è un'osservazione numerica, non una formula: non esiste (ancora) una forma chiusa per
`c_i(λ_i)`.** Dichiararlo apertamente nel report.
*Da completare:* indicare quale `W` è stata usata per questi numeri.

### 5b. Collegamenti fra il materiale del corso e il tutorial

Non sono risultati nuovi: sono lo stesso teorema letto in due linguaggi. Sono però la cosa più utile
da mostrare, perché sono esattamente il *«dare una nuova veste a risultati del corso»* chiesto dal
prof.

**R5 — il lemma sulle row-substochastic è la Corollary 22.**
Le righe di `ΛW` sommano esattamente a `λ_i`, e con `Λ ≠ I` la matrice è row-substochastic anche
nel senso delle slide. Quindi, nel lemma visto a lezione, «nodo con out-degree 1» significa
`λ_i = 1`, cioè agente **non** prejudiced, e «nodo con out-degree < 1» significa agente
**prejudiced**. La condizione del lemma — *da ogni nodo con out-degree 1 parte un cammino verso un
nodo con out-degree < 1* — diventa *ogni agente non prejudiced raggiunge un agente prejudiced*, cioè
**tutti gli agenti sono P-dependent**. E il corollario delle slide («row-substochastic + fortemente
connesso ⟹ convergente») è il «`Λ ≠ Iₙ` e `W` irriducibile ⟹ asintoticamente stabile» della
Corollary 22. Il collegamento lo fa anche il tutorial, subito dopo la Corollary 22: «Corollary 22
may be transformed into a criterion of Schur stability for substochastic matrices».
*Verificato su 356 casi casuali:* la condizione del lemma calcolata sul grafo di `ΛW`, la condizione
«tutti P-dependent» e `ρ(ΛW) < 1` coincidono sempre. Sono tre calcoli indipendenti.

**R6 — il teorema del disagreement dà la formula dell'equilibrio FJ.**
Ipotesi: **tutti gli agenti P-dependent** (come nella Corollary 22). `A_aug` è row-stochastic e i
sink del suo condensation digraph sono gli `n` nodi virtuali, ognuno con il solo self-loop (quindi
aperiodico): si è nel caso ④ della Rosetta stone. Gli agenti reali formano il blocco non-sink, con
`A₃₃ = ΛW` e, verso i sink, il blocco `I − Λ`. Ogni sink è un solo nodo, quindi i vettori-peso
`(I − A₃₃)^{-1}A₃ₖ1` dell'esempio delle slide (uno per sink), messi uno accanto all'altro, formano
la matrice `(I − ΛW)^{-1}(I − Λ) = V`; il fatto che sommino al vettore di uni è il «`V` is
stochastic» del Theorem 21. I nodi virtuali degli agenti con `λ_j = 1` sono sink che nessuno
raggiunge: infatti la colonna `j` di `V` è nulla.
Senza l'ipotesi, le componenti chiuse fatte di soli agenti P-independent sono sink in più, che
possono anche essere periodici: è il caso trattato dal Theorem 21 e dalla Corollary 23.
*Nota sull'onestà della verifica:* la sostituzione dei blocchi è un'identità algebrica, quindi
verificarla numericamente non dimostra nulla. La verifica sostanziale è **R3**, che mostra che `V` è
davvero il blocco di assorbimento di quel grafo.

---

## 6. Struttura del report

Lo scheletro LaTeX esiste già: `main.tex` + cartelle `intro/`, `fdg/`, `fj/`, `conclusion/`
(file ancora vuoti).

| § | Contenuto | Pagine | Cartella |
|---|---|---|---|
| 1 | Introduzione + elenco dei modelli in letteratura (Abelson e Taylor solo nominati) | 2 | `intro/` |
| 2 | FDG: richiamo dei risultati, senza dimostrazioni | 2 | `fdg/` |
| 3 | Stubbornness e social power nel FDG | 4 | `fdg/` |
| 4 | FJ: il modello e i risultati teorici | 5 | `fj/` |
| 5 | Stubbornness e social power nel FJ | 4 | `fj/` |
| 6 | Confronto e conclusioni | 3 | `conclusion/` |

**Cosa va in ciascuna:**

- **§2** — organizzare sulla Rosetta stone. Definire la social power come il `w` del teorema del
  consenso, notando che `w_i > 0` ⟺ *i* globally reachable, e che il valore di consenso dipende solo
  dalle condizioni iniziali dei nodi globally reachable.
- **§3** — la stubbornness come self-weight `a_ii` (stubborn in senso stretto solo con `a_ii = 1`).
  Effetto sulla convergenza: su un ciclo diretto (caso ② della Rosetta stone) i self-loop lo rendono
  aperiodico e lo fanno convergere. Effetto sull'influenza: R1 e R2.
- **§4** — il modello FJ; `ΛW` row-substochastic; **R5**; **R6** (supponendo tutti gli agenti
  P-dependent); poi Theorem 21, Corollary 23, agenti P-independent, footnote 21.
- **§5** — effetto di `λ`; uno o più agenti prejudiced, con prejudices uguali o diverse; cosa succede
  quando una prejudice non raggiunge tutti; la influence centrality.
- **§6** — R1 contro R4; il ponte `c_α → p∞` (Lemma 24); R3 come lettura unificante: nel FJ
  l'influenza è una probabilità di assorbimento verso le prejudices; nel FDG lo è quando ci sono
  agenti stubborn (footnote 9), e in generale la social power è il limite delle `c_α` (Lemma 24).

Le §4 e §6 sono quelle su cui si gioca il voto: la prima perché non è materiale svolto a lezione, la
seconda perché contiene il confronto richiesto.

---

## 7. Le due reti usate negli esperimenti

**Rete principale: ciclo diretto a 6 nodi** (ogni agente ascolta il successivo), con self-loop quando
serve l'aperiodicità. Regge tutto il filo principale in entrambi i modelli. Scelta perché:
- senza self-loop è il caso ② della Rosetta stone (periodico, non converge), quindi mostra l'effetto
  della stubbornness sulla convergenza;
- la social power di partenza è uniforme (`1/6` per ciascuno), quindi ogni asimmetria finale viene
  solo dalla stubbornness;
- sullo stesso grafo, nel FJ basta un agente con `λ_i < 1` per avere stabilità asintotica
  (Corollary 22, caso fortemente connesso).

**Rete ausiliaria: lo stesso ciclo con un arco deviato** — l'agente 3 ascolta 1 invece di 4. Così
`{1,2,3}` diventa un sink e `{4,5,6}` vi confluisce; la social power è `[⅓ ⅓ ⅓ 0 0 0]`. Serve solo per
gli agenti P-independent: mettendo l'agente prejudiced dentro o fuori dal sink si ottengono i due
casi (tutti P-dependent / alcuni P-independent), quindi non serve una terza rete.

---

## 8. Stato del lavoro

**Fatto:** tutta l'esplorazione numerica (esistono notebook MATLAB su FDG, Abelson, Taylor, FJ e un
notebook dedicato alla stubbornness); i risultati R1–R6; la lettura delle slide; la roadmap.

**Da fare:** il report. **Non è stata scritta nessuna riga.**

**Ordine di lavoro deciso:**
1. Studiare la §4 — è la parte non svolta a lezione. Prima di questo non scrivere. Percorso scelto:
   modello → `ΛW` row-substochastic → R5 → R6 (tutti P-dependent) → Theorem 21, Corollary 23,
   P-independent → footnote 21.
2. Scrivere la §4.
3. Scrivere §2 e §3 (più rapide: richiamo più R1 e R2).
4. Scrivere la §5.
5. Scrivere la §6.
6. Scrivere la §1 per ultima.

Le figure si producono dopo il testo di ciascuna sezione, non prima.

---

## 9. Cosa chiedere alla nuova chat

Utile:
- aiuto a **scrivere** le sezioni del report (il testo LaTeX);
- aiuto a **chiarire l'intuizione** dietro i risultati, e a prepararsi alle domande del prof.;
- revisione di quello che scrivo, in particolare se un passaggio è spiegabile a voce oppure no;
- controllo che non stia rientrando materiale fuori scope.

Da evitare:
- chiedere di eseguire codice o rigenerare figure (la chat non può);
- chiedere di aggiungere modelli o argomenti: lo scopo è restare stretti su due modelli e due aspetti;
- riaprire la questione containment control, già esclusa dal prof.

**Lingua:** il progetto è in inglese (codice, commenti, figure, documentazione) e **anche il report
sarà in inglese** (deciso).

---

## 10. Checklist finale — cose da saper spiegare a voce

Se una di queste non è spiegabile senza leggere, va tolta dal report.

**FDG** (bastano enunciato e intuizione):
i cinque casi della Rosetta stone; cos'è `w` e perché il consenso vale `wᵀx(0)`; perché contano solo
i nodi globally reachable; perché un agente con `a_ii = 1` raggiunto da tutti si prende tutto il
consenso; R1 e R2.

**FJ** (qui serve capire davvero):
- perché `ΛW` row-substochastic rende possibile il disaccordo (`1` non è più autovettore);
- **R5**: perché il lemma sulle row-substochastic è la condizione di stabilità del FJ;
- **R6**: perché, con tutti gli agenti P-dependent, il FJ è il caso ④ della Rosetta stone;
- **Theorem 21**: perché il blocco P-dependent è sempre asintoticamente stabile, e perché `V`
  stochastic significa che il disaccordo è limitato;
- **Corollary 22**: stabilità asintotica ⟺ tutti P-dependent;
- **Corollary 23**: perché serve un risultato a parte, e il controesempio `A = B = I`;
- **Footnote 21**: perché il FJ è asintoticamente stabile pur essendo equivalente a un FDG che non
  lo è;
- R3 e R4.
