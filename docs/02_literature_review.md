# Literature Review — Primary Sources, Datasets, and Consolidation of the Theoretical Foundation

**Phase 2 deliverable. No MATLAB code, no model implementation, no pseudocode.**
Companion to [`01_technical_analysis.md`](01_technical_analysis.md), whose structure is retained.

---

## 0. Executive summary

Four new papers were added to the repository. Read in full, they turn out to divide cleanly into **two
pairs**, and neither pair is what the brief anticipated:

| Paper | What it actually is | Role in this project |
|---|---|---|
| **Krackhardt (1987)**, *Cognitive Social Structures*, Social Networks 9:109–134 | Primary source for the **Krackhardt advice network dataset** + a theory of *perceived* networks | **Closes our #1 blocker.** Contains the actual 21×21 matrix. |
| **Sims & Gilles (2014)**, *Critical Nodes in Directed Networks* | Theory of **middlemen / brokerage** in digraphs + an application to Krackhardt | Independent **validation table** for the dataset; a third centrality axis |
| **Sampson (1968)**, *A Novitiate in a Period of Change* (dissertation, 598 pp.) | Primary source for the **Sampson monastery dataset** + the ethnography | Provenance, interpretation, and important caveats — **but not machine-readable data** |
| **Talaga, Stella, Swanson & Teixeira (2023)**, *Polarization and multiscale structural balance in signed networks* | **Structural Balance Theory**: degree of balance, frustration index, SBT-aware clustering | Rigorous tooling for the *community-structure* open question; bridge to Part II |

### The single most important outcome

**The Krackhardt advice network has been recovered, transcribed, and independently cross-validated.**
Krackhardt's Appendix A (journal p. 129) prints the LAS matrix as 21 rows of 21 binary digits. I
transcribed it and checked it against the in-degree and out-degree columns published in Sims & Gilles'
Table 4 — **all 21 in-degrees and all 21 out-degrees match exactly** (129 arcs, zero diagonal). The
matrix is reproduced in §7 and saved to `data/krackhardt_advice_LAS.txt`.

A structural check of that matrix confirms every claim Bullo makes about it and answers a question left
open in the previous phase (details and numbers in §4.1).

### A scoping correction, stated once

The brief described the uploads as *"the original papers introducing or developing many of the models and
concepts we will study"* and expected them to resolve the previously-flagged theoretical questions. That is
true for the **datasets** and for **structural balance**, but it is not true for the **models**. None of
the four papers concerns French–DeGroot, Abelson, Taylor, or Friedkin–Johnsen. None contains a convergence
theorem, a stability result, or anything about stubbornness.

Consequently the theoretical open items from Phase 1 — convergence rates, the grounded Laplacian, the
Taylor `Γu` discrepancy, identification of `W`/`Λ`/`u` from data — are **all still open** (§5). This is not
a problem for the project; it just means the *empirical/structural* foundation is now much stronger than
the *dynamical* one. §5.3 lists the six papers that would close the remaining gaps if you want to upload
a second batch.

---

## 1. Paper-by-paper analysis

### 1.1 Krackhardt (1987) — *Cognitive Social Structures*

**Purpose.** The paper is a response to a methodological controversy. Bernard, Killworth and Sailer (BKS)
had shown across many studies that what people *report* about their interactions does not match what they
are *observed* to do — informants misremember, and they misremember systematically. The standard reading
was that self-report network data is unreliable.

**Contribution.** Krackhardt reframes the problem instead of trying to fix it. He proposes collecting the
**Cognitive Social Structure (CSS)**: a three-dimensional `N × N × N` array
```
R(i, j, k) = perceiver k's belief about whether the tie i → j exists
```
Every respondent reports their perception of the *entire* network, not just their own ties. The paper then
defines three ways to reduce this cube to a tractable 2-D matrix:

1. **Slices** — `R(·, ·, k)`: the whole network as seen by person `k`. (Fig. 3 of the paper shows person
   15's slice.)
2. **Locally Aggregated Structure (LAS)** — uses only the two people involved in the tie:
   - *intersection rule*: `R'(i,j) = R(i,j,i) ∩ R(i,j,j)` (both parties agree the tie exists)
   - *union rule*: `R'(i,j) = R(i,j,i) ∪ R(i,j,j)` (either party says so)
3. **Consensus Structure (CS)** — `R'(i,j) = f(R(i,j,1), …, R(i,j,N))`, in practice a threshold on the mean
   across *all* perceivers.

**Data.** 21 managers in a ~100-employee manufacturing firm. Appendix A (p. 129) prints the **LAS matrix**,
the **Consensus matrix**, and **three individual slices**, all 21×21 binary.

**Philosophical stance and why it matters to us.** Krackhardt explicitly declines to ground the data in
observed behaviour, invoking W. I. Thomas: perceptions are consequential whether or not they map onto
behaviour. For opinion dynamics this is not a footnote — it is a *justification*. The influence matrix `W`
in French–DeGroot and Friedkin–Johnsen is supposed to encode who *accords weight* to whom. That is a
cognitive quantity. A perceived-influence network is arguably the *right* object, not a noisy proxy for a
behavioural one.

**Fit with the project.** Supplies the empirical network for the French–DeGroot social-power chapter and
the Friedkin–Johnsen anchor-placement experiments. Also introduces a modelling degree of freedom we had
not identified (§6.1).

---

### 1.2 Sims & Gilles (2014) — *Critical Nodes in Directed Networks*

**Purpose.** To extend the notion of a *critical node* ("middleman", "broker") from undirected to directed
networks, and to argue that standard centrality measures fail to identify such nodes.

**Contributions.**

- **Middlemen.** Node `h` is an `(i,j)`-middleman if it lies on *every* walk from `i` to `j`. In undirected
  networks this reduces to the classical singleton cut set; in digraphs it does not, because removing `h`
  breaks the `i → j` flow without necessarily breaking `j → i`. Hence the refinement:
  - **strong middleman** — removing it splits the network into ≥ 2 weakly connected components;
  - **weak middleman** — removing it breaks directed connectivity but leaves the network weakly connected.
  *Weak middlemen exist only in directed networks* (Corollary 2.6).
- **Contestability.** Node `i` is *contested* by a set `C` if that set can collectively cover everything `i`
  intermediates. **Theorem 3.5 (duality):** an intermediary is a middleman **if and only if** it is
  uncontested. This is the paper's main theoretical result and it is elegant — brokerage power is exactly
  the absence of competition.
- **Middleman power measure.** `b_i` counts *third-party* disconnections caused by removing `i`,
  compensating for `i`'s own connectivity; `ν_i = b_i / B` normalises it to `[0,1]`. A distance-weighted
  variant `ν*` discounts brokerage between far-apart pairs.
- **Negative result on centrality.** Example 4.1 constructs a network where *non-middlemen have strictly
  higher betweenness, closeness, degree, PageRank and Bonacich centrality than the actual middlemen.*
  Centrality and brokerage are genuinely different quantities.

**Empirical application.** Florentine marriage network, and — critically for us — **Krackhardt's advice
network**, using *"the LAS matrix from p. 129"* (their footnote 6), chosen "as it seems to be the most
objective measure". Their Table 4 reports, for all 21 managers: in-degree, out-degree, Bonacich centrality,
betweenness, `ν`, and `ν*`. They identify **managers 4 and 15 as weak middlemen and manager 21 as a strong
middleman**, with node 15 the most powerful broker — while node 18 dominates the classical centralities and
is not a middleman at all.

**Fit with the project.** Two roles. First, **Table 4 is a validation fixture** — it let me verify the
transcription of the LAS matrix without any circularity. Second, it supplies a **third, independent notion
of node importance** to compare against French–DeGroot social power (§4.1), which turns our comparative
chapter from a replication into an actual finding.

---

### 1.3 Sampson (1968) — *A Novitiate in a Period of Change*

**Purpose.** A 598-page Cornell PhD dissertation: an ethnographic and experimental study of a New England
monastery ("St. Anthony's", Order of Mystical Union) over roughly twelve months in the mid-1960s, during
which the community fractured and most members left or were expelled.

**Structure and data.** The relevant material is Chapter V, *The Changing Socio-Cultural Structure*
(pp. 244 ff.), specifically *The Changing Structure of Inmate Social Relationships* (p. 314 ff.).
Sampson distinguishes **four classes of social relationship**, and gives a matrix for each at each time
point (all as *Figures*, listed in the front matter's List of Illustrations, not the List of Tables):

| Relation | T₋₁ | T₁ | T₂ | T₃ | T₄ | T₅ |
|---|---|---|---|---|---|---|
| Affective (liking) | 332 | 323 | 345 | 358 | 359 | 377 |
| Esteem | 333 | 324 | 346 | 362 | 363 | 378 |
| Influence | 334 | 325 | 347 | 365 | 366 | 379 |
| Sanction (praise/blame) | 335 | 326 | 348 | 368 | 369 | 380 |

plus a cumulative matrix with first- and second-choice influence at T₄ (p. 370).

**The measurement instrument** (Novice Questionnaire, p. 316) asks each respondent, for each relation and
each time point, to name **three ranked choices in each direction** — "liked the most / 2nd / 3rd" and
"liked the least / 2nd / 3rd". *This is the origin of the −3…+3 edge weights* used in every modern version
of the dataset: rank 1 → ±3, rank 2 → ±2, rank 3 → ±1.

**Two caveats that only the primary source reveals, and both matter:**

1. **The time series is partly retrospective.** The questionnaire instructs respondents to *think back* to
   an earlier month and answer as they felt *then*. Several "time points" are therefore reconstructed from
   a single administration, not independent longitudinal measurements. Anyone treating T₁…T₅ as a
   trajectory of a dynamical process is making a strong and undocumented assumption.
2. **The negative pole is a euphemism.** Sampson's footnote 23 explains that "disliked" was deliberately
   avoided because the community's ideology of loving one's brothers made admitting dislike tantamount to
   confessing personal inadequacy — so the instrument asks who was "liked *least*". Negative ties are
   therefore *weak* negatives, which is a real caveat for structural-balance interpretations that read them
   as hostility.

**Critical practical finding.** The matrices in the dissertation are **hand-drawn sociograms**, not numeric
tables: nodes are circles positioned on a vertical net-score axis (+14 to −14), solid arrows for positive
choices, dashed for negative, members identified by ID number, with a "departed" list at the side. They are
**not a usable data source** — extracting them would mean reading arrows off a scan, and the rank weights
are not recoverable from the drawing at all.

**Conclusion for the project.** Use the dissertation for **provenance, interpretation, faction narrative
and caveats**; take the **numbers** from the standard machine-readable encoding (§4.2).

---

### 1.4 Talaga, Stella, Swanson & Teixeira (2023) — *Polarization and multiscale structural balance*

**Purpose.** To make Structural Balance Theory (SBT) computationally practical and multiscale.

**Background it supplies (Methods §4.1) — the core of SBT:**
- **Strong balance** (Cartwright & Harary 1956): a signed graph is balanced iff every semicycle is positive.
  **Structure theorem:** balanced ⟺ the vertices split into **two** groups with positive ties inside and
  negative ties between.
- **Weak balance** (Davis 1967): no semicycle contains *exactly one* negative edge. **Structure theorem:**
  weakly balanced ⟺ the vertices split into **b ≥ 2** groups with the same property.
- **Semipaths/semicycles** generalise these to digraphs by allowing each directed edge to be traversed
  either way but only once — so asymmetric dyads generate no 2-semicycles, while reciprocated ones do.

**Contribution.** Counting cycles is prohibitive, so DoB (degree of balance) is approximated by closed
**semiwalks** via powers of the adjacency matrix. The authors' **Multiscale Semiwalk Balance (MSB)**
introduces a resolution parameter `β` (an "inverse temperature") that enforces a **Locality Principle** —
shorter cycles get non-decreasing weight — fixing the known tendency of walk-based measures (Estrada &
Benzi) to underestimate balance by over-weighting long cycles. They also define the **frustration index**
`F(B)` — the share of absolute edge weight that is "wrong" for a given partition (negative within-group +
positive between-group) — as the objective criterion for partition quality, and derive node-level and
pair-level DoB scores enabling SBT-aware clustering.

**Sampson re-analysis (§2.3).** Applied to the five-wave signed Sampson networks, MSB finds partitions with
**lower frustration than the accepted "ground truth"** three-faction split. Substantively: Basil was with
the Young Turks at t=2 before being rejected; Amand is consistently an Outcast rather than Loyal
Opposition; and most strikingly **John Bosco, one of the two Young Turk leaders, had drifted into the
Outcasts by t=4** — offering an explanation for why the Young Turks lost and the Loyal Opposition survived.
The Gregory ↔ John Bosco tie is asymmetric at t=4 (Gregory→Bosco positive, Bosco→Gregory negative).

**Data provenance (Methods §4.7.5).** Five signed, directed, weighted networks, weights −3…3, taken from
the version used by Doreian & Mrvar (1996), accessed from the Pajek/ESNA collection at
`http://vlado.fmf.uni-lj.si/pub/networks/data/esna/sampson.htm`; code and packaged data at
`https://github.com/sztal/msb`.

**Fit with the project.** Three roles: (i) it is the **data trail** for Sampson; (ii) it gives a
**principled, quantitative partition** of the monastery to compare our opinion-dynamics clustering against;
(iii) it is the natural **theoretical bridge to Part II** (Altafini, signed networks, bipartite consensus).

---

## 2. Relationships among the papers

```
        DATASETS                                  ANALYSIS OF THOSE DATASETS
   ┌──────────────────┐                         ┌────────────────────────────┐
   │ Krackhardt 1987  │ ──── supplies data ───▶ │ Sims & Gilles 2014         │
   │ advice network   │ ◀─── validates ──────── │ middleman power, Table 4   │
   │ (LAS, CS, slices)│                         └────────────────────────────┘
   └──────────────────┘
   ┌──────────────────┐                         ┌────────────────────────────┐
   │ Sampson 1968     │ ──── supplies data ───▶ │ Talaga et al. 2023         │
   │ monastery,       │      (via Pajek/ESNA    │ structural balance, MSB,   │
   │ 4 relations×5 t  │       re-encoding)      │ frustration, clustering    │
   └──────────────────┘                         └────────────────────────────┘
```

The pairing is exact: each pair consists of **one 1960s–80s primary sociological source** and **one modern
formal/computational analysis of it**. Two further structural parallels are worth naming:

1. **Both modern papers argue that the obvious measure is the wrong measure.** Sims & Gilles show
   betweenness/Bonacich fail to identify brokers; Talaga et al. show the accepted "ground truth" partition
   of Sampson is not balance-optimal, and that naïve walk-based DoB under-reports balance. Our project makes
   the same kind of argument in a third register — that dynamically generated social power is not
   structural centrality.
2. **Both primary sources warn that the network is a construct, not a fact.** Krackhardt: the network
   depends on *whose perception* you aggregate and *how*. Sampson: the ties depend on a euphemistic
   instrument and partly on retrospective recall. Neither dataset is "the" network.

**Connection to the tutorial (Proskurnikov & Tempo, Part I).** The link is real but indirect. The tutorial
cites Krackhardt only in passing (via Bullo's Fig. 5.5) and does not cite Sampson at all. What the new
papers supply is precisely what the tutorial's **concluding section names as an open problem**: the
relation between opinion behaviour and the **community/module structure** of the influence graph. Talaga et
al. give a rigorous definition of that structure (frustration-minimising partitions) and Sampson gives a
network that actually has one. Sims & Gilles, meanwhile, sit alongside the tutorial's §3.5 discussion of
social power as centrality — offering a competing notion of node importance that the tutorial does not
consider.

---

## 3. What becomes clearer after reading the primary sources

1. **"The Krackhardt advice network" is not one network.** It is a family — LAS-intersection, LAS-union,
   Consensus-at-threshold-τ, and 21 individual slices. Bullo's Fig. 5.5 and Sims & Gilles both use LAS
   without dwelling on the choice. Since French–DeGroot social power is a *spectral* quantity, it may be
   sensitive to this choice. That is a modelling degree of freedom we did not know we had.
2. **The −3…+3 Sampson weights are ranks, not intensities.** They come from a forced three-choice
   sociometric instrument. Treating them as cardinal influence weights (i.e. row-normalising them) imposes a
   linear rank-to-weight mapping that is a modelling assumption, not data.
3. **Structural balance is about *signed* ties and therefore genuinely outside our four models.** All four
   models (French–DeGroot, Abelson, Taylor, Friedkin–Johnsen) require `A ≥ 0`. This confirms — from the
   primary literature rather than by inference — that the Sampson signed data belongs to Altafini/Part II,
   and that using it here requires restricting to a positive relation, exactly as planned.
4. **Brokerage ≠ centrality ≠ influence.** Sims & Gilles prove the first inequality; our computation on the
   same matrix (§4.1) demonstrates the second and third empirically.
5. **The perceived network is the theoretically correct object for opinion dynamics.** Krackhardt's
   W. I. Thomas argument supplies a justification for using self-report influence data in a model of
   *accorded weight* that we could not have made from the tutorial alone.

---

## 4. Audit: which Phase-1 open items are now closed

### 4.1 CLOSED — Krackhardt data provenance, structure, and social power

This was flagged in Phase 1 §13 as the one item that could block implementation. It is fully resolved.

**The matrix.** Recovered from Appendix A, p. 129 (§7 below). Cross-validated against Sims & Gilles Table 4:
all 21 in-degrees and all 21 out-degrees match, 129 arcs, zero diagonal.

> *Caveat, stated honestly:* matching all 42 degree constraints is strong evidence but not proof of a
> character-perfect transcription (degree sequences do not uniquely determine a matrix). Confidence is high;
> a cross-check against a canonical machine-readable copy is still worth doing once, and is listed in §6.3.

**Structural analysis** (verification of the dataset's properties for this report — not model implementation):

- **5 strongly connected components**: `{6}`, `{13}`, `{16}`, `{17}`, and one giant SCC of 17 nodes
  `{1,2,3,4,5,7,8,9,10,11,12,14,15,18,19,20,21}`.
- **Exactly one closed strong component** (the giant one) ⟹ the graph is **rooted**.
- That component is **aperiodic** (period 1).
- Therefore, by Theorem 12 of the tutorial, **French–DeGroot reaches consensus** on this network — and the
  matrix is **reducible with a simple, strictly dominant eigenvalue 1**. This confirms Bullo's Fig. 5.5
  caption exactly, from the primary data.
- **Every manager has out-degree ≥ 1**, so row-normalisation is clean: no empty rows, hence **no artificial
  self-loops and no accidentally-created stubborn agents**. This closes Phase-1 pitfall #7 for this dataset.

**Social power** `p_∞` (left Perron vector of the row-normalised LAS):

| Rank | Manager | `p_∞` | | Rank | Manager | `p_∞` |
|---|---|---|---|---|---|---|
| 1 | **21** | 0.2011 | | 12 | 10 | 0.0235 |
| 2 | **7** | 0.1430 | | 13 | 15 | 0.0148 |
| 3 | **2** | 0.1322 | | 14 | 9 | 0.0147 |
| 4 | **18** | 0.1057 | | 15 | 8 | 0.0074 |
| 5 | 14 | 0.0715 | | 16 | 5 | 0.0018 |
| 6 | 11 | 0.0532 | | 17 | 19 | 0.0018 |
| 7 | 4 | 0.0516 | | 18–21 | **6, 13, 16, 17** | **0.0000** |
| 8 | 12 | 0.0506 | | | | |
| 9 | 1 | 0.0477 | | | | |
| 10 | 20 | 0.0407 | | | | |
| 11 | 3 | 0.0387 | | | | |

**Phase-1 prediction confirmed.** The plan predicted that "some managers have zero social power (they are
not globally reachable)". They are **managers 6, 13, 16 and 17** — precisely the four singleton SCCs, the
four managers nobody seeks advice from. Their initial opinions are *completely forgotten* by the group.

**A genuine new finding for the comparative chapter.** Three notions of node importance, computed on the
*same* 21×21 matrix, disagree sharply:

| Notion | Source | Top nodes |
|---|---|---|
| **DeGroot social power** `p_∞` | this analysis | **21** (0.201), 7, 2, 18 |
| **Betweenness / Bonacich centrality** | Sims & Gilles Table 4 | **18** (BC 0.231, Bonacich 1.745) |
| **Middleman power** `ν` | Sims & Gilles Table 4 | **15** (0.161), 21 (0.147), 4 (0.090) |

Manager **15 is the network's most powerful broker but ranks 13th of 21 in social power** (0.0148) — he
controls what flows between others without being someone others take advice *from*. Manager **18 dominates
classical centrality but is neither the top influencer nor a middleman at all.** Manager **21 is the only
node strong on both influence and brokerage.** Managers 6, 13, 16, 17 are zero on all three.

This is exactly the kind of result the comparative chapter needed: *dynamically generated influence,
structural centrality, and brokerage power are three different things, and a real organisation shows all
three coming apart.* Sims & Gilles prove centrality ≠ brokerage; we can add the opinion-dynamics axis and
publish the three-way scatter.

### 4.2 CLOSED — Sampson data provenance and the "which relation, which slice" question

Phase 1 flagged: *"you must pick one positive relation and one time slice and document the choice."*
The primary source now lets us be precise:

- **Relations**: exactly four — *affective* (liking), *esteem*, *influence*, *sanction* (praise/blame).
  Each is measured with signed ranked choices in both directions.
- **Time points**: T₋₁, T₁, …, T₅ in the dissertation; the standard distributed dataset has **five waves**.
  The 18-member group exists at T₂–T₄; T₁ has fewer members (with a "departed" list), and only 7 remain at T₅.
- **Weights**: −3…+3, from three ranked choices in each direction.
- **Machine-readable source**: Pajek/ESNA collection (`vlado.fmf.uni-lj.si/.../esna/sampson.htm`), the
  Doreian & Mrvar (1996) encoding; also packaged in `github.com/sztal/msb`. **The dissertation itself is not
  usable as a data source** — its matrices are hand-drawn sociograms (§1.3).

**Recommended choice, now evidence-based:** use the **positive part of the affective (liking) relation at
T₄**, restricted to the 18-member group.
- *Why affective:* it is the relation Sampson leads with and the one on which the faction structure is
  defined in the literature.
- *Why T₄:* it is the last pre-collapse observation, where the community structure is sharpest — Talaga et
  al. find maximum degree of balance at t=4, and it is the wave on which the "ground truth" and MSB
  partitions differ most informatively.
- *Why the positive part only:* all four of our models require non-negative weights.

**Two caveats to record in the report** (both discovered only in the primary source): the retrospective
recall issue and the euphemistic negative pole (§1.3).

### 4.3 CLOSED — the direction convention, for this dataset

Phase 1 pitfall #1 flagged the clash between the tutorial's arrow convention and Bullo's. Sims & Gilles
state it unambiguously for the Krackhardt data: *an arc from `i` to `j` means manager `i` has sought advice
from manager `j`*. That is the **listening-graph** convention — identical to the project convention
`W(i,j) > 0` ⟺ *i accords weight to j*. So the transcribed LAS matrix can be row-normalised directly,
**with no transpose**. Verified: normalising in this orientation reproduces both Bullo's structural claims
and a social-power vector consistent with Sims & Gilles' degree data.

### 4.4 PARTIALLY CLOSED — community structure and opinion behaviour

The tutorial's own stated open problem. The new papers do not solve it, but Talaga et al. make it
**tractable** by supplying: a rigorous definition of the target structure (frustration-minimising
partition), an efficient computational route (semiwalk-based DoB), node-level balance scores, and a
concrete, published partition of Sampson to compare against. Phase 1 nominated this as the project's most
likely original contribution; it is now considerably better equipped.

---

## 5. What remains open, and why

### 5.1 Still open — theory of the four models

None of these was touched by the uploads, because none of the uploads is about opinion dynamics.

| Open item (Phase 1 ref.) | Status | Why still open |
|---|---|---|
| **Taylor Eq. (15) vs (18): is the input `u` or `Γu`?** (§4.1, §11.2) | **Open** | Requires Taylor (1968) itself. My reading — that `Γu` is correct because Theorem 18's limit formula contains `Γ¹¹` — stands and is internally consistent, but is an inference from the tutorial, not a check against the source. |
| **Convergence rates** — SLEM, spectral gap, Cheeger (§12.2) | **Open** | Needs Olshevsky & Tsitsiklis (2011), Cao–Morse–Anderson (2008b). |
| **Grounded Laplacian** `λ_min(L¹¹+Γ¹¹)` (§12.2) | **Open** | Needs Pirani & Sundaram (2016). |
| **Forest/tree combinatorics of `p_∞`** (§12.2) | **Open** | Needs Chebotarev & Agaev. |
| **Game-theoretic / electrical readings of FJ** (§12.2) | **Open** | Needs Bindel–Kleinberg–Oren (2011), Ghaderi & Srikant (2014). |
| **Identification of `W`, `Λ`, `u` from data** (§12.4) | **Open** | Needs Friedkin & Johnsen (1999/2011). This is the big one: FJ is the only empirically validated model of the four, and we have read *none* of the validation literature. |
| **Anchor/leader placement as a control problem** (§12.4) | **Open, but better equipped** | No paper addresses it directly — but Sims & Gilles' `ν` is now a concrete *candidate heuristic* for where to place stubborn agents (§6.2). |
| **Corrigendum scope** (§12.1) | **Open (internal task)** | Re-read of Part I; no external source needed. |

### 5.2 Still open — data

- **Independent verification of the transcribed LAS matrix** against a canonical machine-readable copy
  (§6.3). High confidence, but worth one cross-check.
- **Obtaining the Sampson matrices.** Provenance is established; the files themselves are not in the repo.

### 5.3 If you want to close the theory gaps, these are the six papers to upload

In descending order of value to this project:

1. **Friedkin & Johnsen (1999)**, *Social influence networks and opinion change*, Advances in Group
   Processes 16:1–29 — the primary FJ source, the empirical validation, and the `λᵢ = 1 − wᵢᵢ` coupling.
2. **Taylor (1968)**, *Towards a mathematical theory of influence and attitude change*, Human Relations
   21:121–139 — settles the `Γu` question definitively.
3. **DeGroot (1974)**, *Reaching a consensus*, JASA 69:118–121 — three pages, the primary source.
4. **French (1956)**, *A formal theory of social power*, Psychological Review 63:181–194 — the origin of
   social power, and the reason the whole field exists.
5. **Abelson (1964)**, *Mathematical models of the distribution of attitudes under controversy* — the
   diversity puzzle in the author's own words.
6. **Bindel, Kleinberg & Oren (2011)**, *How bad is forming your own opinion?* — the game-theoretic reading
   of FJ and the price of anarchy.

(Friedkin & Johnsen's 2011 book *Social Influence Network Theory* would substitute for (1) with more depth.)

---

## 6. New questions and opportunities raised by these papers

### 6.1 NEW: the CSS aggregation choice is a modelling degree of freedom

We had assumed "the Krackhardt advice network" was a single object. It is not. Krackhardt's Appendix A
gives us, for free, **LAS**, **Consensus**, and **three individual slices** — five different 21×21 matrices
purporting to describe the same social reality.

**Proposed experiment (small, cheap, novel).** Compute French–DeGroot social power `p_∞` under each
aggregation and compare the rankings. Questions it answers: Is social power robust to how the perception
cube is reduced? Do the four zero-power managers stay at zero? Does any individual's *perception* of the
network (a slice) imply a wildly different power structure than the consensus? Krackhardt reports that the
only predictor of whether a person's slice matches the consensus is their own in-degree — the *fewer*
people they think approach them, the more accurate they are. Whether that translates into accurate
perception of *influence* is, as far as I can tell, an open question.

This costs one extra matrix per aggregation and yields a genuinely new result. **Recommended as an optional
subsection of the comparative chapter.**

### 6.2 NEW: middleman power as an anchor-placement heuristic

Phase 1 posed: *given a budget, which agents should be made stubborn to steer the group?* Sims & Gilles
supply a plausible answer nobody appears to have tested: **place stubborn agents at uncontested
intermediaries (middlemen)**. The intuition is strong — a middleman lies on *every* path between some pair,
so anchoring it should maximally distort the flow of opinion.

But our own numbers suggest it will **fail**, and interestingly so: manager 15 is the top middleman yet has
social power 0.0148. A middleman controls *transmission*; social power measures *being listened to*. The
FJ total-influence matrix `V` should reveal which one predicts the shift in the group's final opinion when
that agent is anchored.

**Proposed experiment.** For each manager `i`, make `i` totally stubborn (`λᵢ = 0`) and record the induced
shift in the group mean `‖x(∞) − x_baseline(∞)‖`. Regress that against (a) `p_∞`, (b) betweenness/Bonacich,
(c) `ν`. **Prediction:** social power wins, brokerage does poorly. If so, that is a clean, defensible,
original result — and it directly serves the professor's stubbornness brief.

### 6.3 NEW: verify the transcription once

Cross-check the §7 matrix against a canonical machine-readable copy of Krackhardt's advice LAS (e.g. the
UCINET/`igraphdata` distributions) before it becomes load-bearing. If a discrepancy appears, the degree
sequence in Sims & Gilles Table 4 is the tiebreaker.

---

## 7. The recovered Krackhardt advice network (LAS)

Source: Krackhardt (1987), Appendix A, p. 129. Convention: **row `i` = the managers whose advice manager
`i` seeks** = `W(i,j) > 0` in the project convention. 21 nodes, 129 arcs, zero diagonal.
Saved to [`../data/krackhardt_advice_LAS.txt`](../data/krackhardt_advice_LAS.txt).

```
0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1
0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 1 0 0 0 0 1 0 1 1 1 0 0 1 0 0 0 1 0 0 1
1 1 0 0 0 0 0 1 0 1 1 0 0 0 0 0 0 1 0 0 1
1 1 0 0 0 0 1 0 0 1 1 0 0 1 0 0 0 1 1 1 1
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
0 1 0 0 0 0 0 0 0 0 1 1 0 1 0 0 0 1 0 0 1
0 1 0 1 0 0 1 0 0 1 1 0 0 0 0 0 0 1 0 0 1
1 1 0 0 0 0 1 0 0 1 1 1 0 1 0 0 0 1 0 0 1
0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0
1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 1 0 0 1 0 0 0 1 0 0 0 0 1 0 0 0 1 0 0 0
0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 1
1 1 0 0 1 0 0 0 1 0 0 0 0 1 0 0 0 1 1 1 1
1 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0
1 1 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1
1 1 1 1 0 0 1 0 1 1 1 0 0 1 1 0 0 0 0 1 1
1 1 0 0 1 0 1 0 0 1 1 0 0 1 1 0 0 1 0 1 0
1 1 0 0 0 0 0 0 0 0 1 0 0 1 1 0 0 1 0 0 1
0 1 1 1 0 0 1 0 0 0 0 1 0 1 0 0 0 1 0 1 0
```

**Validation fixtures** (from Sims & Gilles Table 4 — use these as unit tests):
- out-degrees: `4 2 9 7 10 1 6 7 9 5 3 1 6 4 9 4 5 12 10 7 8`
- in-degrees: `12 18 3 6 3 0 11 1 4 8 9 3 0 10 3 0 0 15 2 6 15`
- middlemen: 4 (weak), 15 (weak), 21 (strong); all others `ν = 0`
- highest betweenness and Bonacich: node 18

---

## 8. Roadmap updates

**The Phase-1 structure stands unchanged.** The chapter ordering, the 2×2 model table, the stubbornness
chapter placed before Taylor, the MATLAB architecture, and the network scenarios are all confirmed rather
than challenged by this reading. The following are **additions and refinements**, not restructurings.

### 8.1 Changes to the simulation scenarios (Phase 1 §9)

| Item | Change |
|---|---|
| **Krackhardt** | Promoted from "optional, data not in repo" to **primary real-data scenario, data in hand**. Add the four zero-power managers and the three-way importance comparison as expected results. |
| **Sampson** | Scope now fixed: **positive part of the affective relation at T₄, 18-member group**, from the Pajek/ESNA encoding. Signed version explicitly deferred to Part II. Document both primary-source caveats. |
| **CSS aggregations** | **New optional scenario** (§6.1): LAS vs Consensus vs slices, same 21 managers. |
| Ring, star, path, two-community, complete, tiny fixtures | Unchanged. |

### 8.2 Additions to the comparative chapter (Phase 1 §10, ch. 11)

Two new subsections, both data-driven and both with published benchmarks:
1. **Three-way node-importance comparison** on Krackhardt: `p_∞` vs betweenness/Bonacich vs middleman power
   `ν`, with the Sims & Gilles table as ground truth for the latter two (§4.1).
2. **Anchor-placement experiment**: which measure predicts the effect of making an agent stubborn (§6.2).

### 8.3 Additions to future work (Phase 1 §12.3)

Structural Balance Theory joins the Part II reading list as a **first-class item** rather than a passing
mention, with Talaga et al. (2023) as the modern entry point and Cartwright & Harary (1956) / Davis (1967)
as the classical structure theorems. The Sampson signed data is the natural testbed, and the frustration
index gives an objective way to compare an Altafini-style bipartite-consensus outcome against a
balance-optimal partition.

### 8.4 New implementation considerations

1. **Data layer needs a provenance field.** Each network must record: source paper, aggregation rule
   (LAS-intersection / consensus-threshold / raw), relation, time point, direction convention, and
   normalisation applied. The Phase-1 `net.meta` field covers this — it is now clearly *necessary*, not
   decorative.
2. **Krackhardt needs no zero-row handling.** Every manager has out-degree ≥ 1. Keep the guard in
   `row_normalize.m` for other datasets, but this one is clean.
3. **Sampson will need signed→positive extraction and rank→weight mapping**, both as explicit, logged,
   switchable steps. The rank-to-weight map (3/2/1 vs any other monotone choice) is a modelling assumption
   and should be a parameter, not a constant.
4. **Expect a reducible `W` for Krackhardt.** Four nodes sit outside the closed SCC. Any code path that
   assumes irreducibility (e.g. taking `eigs` and expecting a strictly positive left eigenvector) will
   silently mislead. The social-power routine must handle exact zeros — this is a genuine test case, not an
   edge case.

---

## 9. Bottom line

- The **empirical foundation is now solid**: the Krackhardt network is in hand and cross-validated, its
  structural properties are confirmed against Bullo, and the Sampson data trail is fully documented with
  two caveats that only the dissertation reveals.
- The project gained **two concrete, original experiments** (three-way importance comparison; anchor
  placement) and one optional novel one (CSS aggregation sensitivity), all with published benchmarks.
- The **dynamical-theory gaps from Phase 1 are all still open**, because none of these papers is about
  opinion dynamics. §5.3 lists the six papers that would close them — of which **Friedkin & Johnsen (1999)
  and Taylor (1968) are the two that matter most**, since the first is the primary source for the model at
  the centre of the project and the second settles a concrete discrepancy in our reading of the tutorial.
- **No change to the project structure is warranted** by this reading. It is confirmed and better equipped.
