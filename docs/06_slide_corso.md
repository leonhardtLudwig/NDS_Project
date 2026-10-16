# Contenuto delle slide del corso (con le note a mano)

Estratto da `FINAL/material /slides/`. Le pagine sono state renderizzate in immagini e lette a vista,
perché l'estrazione testuale non rende la scrittura a mano.

> Legenda: il testo normale è **della slide**; quello marcato *[nota]* è **scritto a mano da me**.

---

## Deck 1 — DT averaging systems (14 pagine) ← **il più importante**

### Argomenti dichiarati
- DT averaging systems: recap ed esempi
- Preliminari sulle matrici **sottostocastiche**
- Sistemi che raggiungono il **consenso asintotico**
- Sistemi che raggiungono il **disagreement asintotico**

### Il modello
Il modello si chiama **French-Harary-DeGroot** (non solo French–DeGroot).
`xᵢ(k+1) = Σⱼ aᵢⱼ xⱼ(k)`, `Σⱼ aᵢⱼ = 1` ⟺ `x(k+1) = A x(k)`, A row-stochastic.
`(i,j) ∈ E` se **i è influenzato da j**. `xᵢ` = opinione di i su un certo tema.

Tre esiti possibili per `lim Aᵏ x(0)`: non esiste (non converge) · `= α1` (consenso asintotico) ·
`= v ≠ α1` (disagreement asintotico).

### Matrici sottostocastiche
**Def:** `A ≥ 0` è row-substochastic se `A·1 ≤ 1` e ∃i con `eᵢᵀA·1 < 1`.

**Lemma (Convergent row-substochastic matrices):** A è convergente ⟺ G contiene cammini diretti da
ogni nodo con out-degree (pesato) 1 a un nodo con out-degree (pesato) strettamente < 1.
*[nota: «convergente» qui vuol dire `lim Aᵏ = 0`]*

**Corollario:** A row-substochastic + G fortemente connesso ⟹ A convergente.

*[nota: dimostrazione completa a mano. Si definisce `Sₕ := {i ∈ V | eᵢᵀAʰ1 < 1}` e si provano tre
fatti: ① `Sₕ ⊆ Sₕ₊₁`; ② se i ha un out-neighbor in `Sₕ` allora `i ∈ Sₕ₊₁`; ③ ∃h̄ con `Sₕ̄ = V`.
Poi si pone `γ = maxᵢ Σⱼ [Aʰ̄]ᵢⱼ < 1` e si scrive `k = qh̄ + r`, da cui `Aᵏ1 ≤ γᵠ1 → 0`.]*

### Consenso
**Thm (Consensus in DT averaging systems):** A row-stochastic. Equivalenti:
- **(A1)** l'autovalore 1 è semplice e tutti gli altri hanno `|μ| < 1`;
- **(A2)** A è semi-convergente e `lim Aᵏ = 1ₙwᵀ` con `w ≥ 0`, `1ᵀw = 1`, `wᵀA = wᵀ`;
- **(A3)** G contiene un nodo globally reachable e il sottografo dei nodi globally reachable è
  aperiodico. *[nota: se c'è un self-loop allora G è aperiodico]*

Se valgono, allora: **(i)** w è l'autovettore sinistro dominante e `wᵢ > 0` ⟺ i è globally
reachable; **(ii)** `lim x(k) = (wᵀx(0))·1ₙ`.

**Corollario:** A doppiamente stocastica + (A3) ⟹ `w = (1/n)1`, `lim x(k) = (1/n)Σxᵢ(0)·1`
*[nota: media dell'informazione]*

*[note mie: ① l'equivalenza (A2)⟺(A1) è già stata dimostrata (ultimo teorema del Modulo 1);
② l'insieme dei nodi globally reachable è fortemente connesso; ③ **in generale il valore di consenso
`wᵀx(0)` non dipende dalle condizioni iniziali di tutti i nodi, ma solo da quelle dei nodi globally
reachable**]*

*[dimostrazione (A2)⟺(A3) scritta a mano per intero. Usa la decomposizione a blocchi
`A = [[A₁₁, 0],[A₂₁, A₂₂]]` con `A₁₁` = sottografo dei globally reachable (primitiva) e `A₂₂`
sottostocastica; conclude `lim Aᵏ = 1ₙ[w₁ᵀ 0]`.]*

### Condensation digraph
**Def:** componente fortemente connessa; **Def:** `C(G)` collassa ogni componente in un nodo.
**Nota:** se G ha un nodo globally reachable allora `C(G)` ha un **unico sink**.
*[note: i self-loop non sono ammessi in `C(G)`; un singolo nodo, con o senza self-loop, è fortemente
connesso]*

### Disagreement
**Thm (Disagreement in DT averaging systems):** A row-stochastic, `C(G)` con `nₛ ≥ 2` sink.
Equivalenti:
- **(A1)** l'autovalore 1 è **semi-semplice con molteplicità `nₛ`**, gli altri `|μ| < 1`;
- **(A2)** A è semi-convergente;
- **(A3)** ogni sink di `C(G)` è aperiodico.

Allora `lim x(k) = v ≠ α1ₙ`. *[nota: disagreement]*

*[esempio svolto a mano, con due sink `G_{S1}`, `G_{S2}` e un blocco non-sink `G_{S3}`:*
```
A = [[A11, 0,   0  ],        A11ᵏ → 1 w1ᵀ
     [0,   A22, 0  ],        A22ᵏ → 1 w2ᵀ
     [A31, A32, A33]]        A33ᵏ → 0

A31ᵏ → (I−A33)⁻¹ A31 1 w1ᵀ         con  (I−A33)⁻¹A31·1 + (I−A33)⁻¹A32·1 = 1
A32ᵏ → (I−A33)⁻¹ A32 1 w2ᵀ
```
*e la conclusione, scritta a mano:* `[x₃(∞)]ᵢ = αᵢ w1ᵀx₁(0) + (1−αᵢ) w2ᵀx₂(0)`, `0 ≤ αᵢ ≤ 1`,
*«combinazione convessa dei valori di consenso di `G_{S1}` e `G_{S2}`»]*

### Rosetta stone (ultima pagina)
Tabella riassuntiva di tutti i casi, `A` row-stochastic:

| | condizione | grafo | esito |
|---|---|---|---|
| ① | A primitiva | G fort. conn. e aperiodico | consenso |
| ② | A irriducibile non primitiva | G fort. conn. e periodico | non converge |
| ③ | 1 semplice e str. dominante, A non primitiva | `C(G)` ha **1 sink aperiodico** | consenso |
| ④ | 1 semi-semplice non semplice, str. dominante | `C(G)` ha **≥ 2 sink aperiodici** | **disagreement** |
| ⑤ | altrimenti | — | non converge |

*[nota: G ha almeno un nodo globally reachable e il sottografo dei globally reachable è aperiodico]*

---

## Deck 2 — Elements of Matrix Theory (10 pagine)
Sistemi lineari DT e forma di Jordan · matrici stocastiche · **teoria di Perron–Frobenius** ·
applicazioni ai sistemi di averaging DT.

## Deck 3 — Elements of Graph Theory (24 pagine)
Grafi non orientati e orientati · walk e connettività · grafi pesati · matrice di adiacenza ·
caratterizzazione grafica delle matrici **irriducibili** e **primitive** · applicazioni ai sistemi
di averaging DT.

## Deck 4 — CT averaging systems (10 pagine)
Fuori dallo scope del progetto (abbiamo escluso Abelson e Taylor). Contiene una menzione di
sottostocastiche e di consenso in tempo continuo.

---

## Perché tutto questo conta per il report

1. La **social power** è già dimostrata a lezione, solo senza quel nome: è il `w` del teorema del
   consenso, e `lim Aᵏ = 1ₙwᵀ`. Nel report va solo battezzata e interpretata.
2. Il **lemma sulle sottostocastiche** è la condizione di stabilità del FJ (vedi R5 in roadmap).
3. Il **teorema del disagreement** con la sua formula a blocchi è la formula dell'equilibrio FJ
   (vedi R6 in roadmap).
4. La **Rosetta stone** è il modo giusto di organizzare la §2: è lo schema di Baggio, lui lo
   riconosce subito, e il FJ ci si innesta come caso ④.
