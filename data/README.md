# Datasets — provenance

## `krackhardt_advice_LAS.txt` — Krackhardt's advice network (21 managers)

**Source.** David Krackhardt (1987), "Cognitive Social Structures", *Social Networks* 9(2):109–134,
**Appendix A, p. 129**, the matrix labelled `LAS=`. Scanned PDF in the repo root
(`1987-cognitive-social-structures.pdf`, PDF page 21). Transcribed 2026-08-02.

**What it is.** 21 managers in a ~100-employee manufacturing firm. Krackhardt collected a *Cognitive Social
Structure*: every manager reported their perception of the whole advice network, giving a 21×21×21 array
`R(i,j,k)` = perceiver `k`'s belief that `i` seeks advice from `j`. The **LAS** (Locally Aggregated
Structure) reduces this cube using only the two people involved in each tie — Krackhardt gives an
intersection rule `R(i,j,i) ∩ R(i,j,j)` and a union rule `R(i,j,i) ∪ R(i,j,j)`; the printed LAS matrix is
the one Sims & Gilles (2014) use, describing it as the most objective available measure.

**Format.** 21 lines × 21 space-separated binary values. Zero diagonal, 129 arcs.

**Direction convention.** `M(i,j) = 1` means **manager `i` seeks advice from manager `j`**, i.e. *`i`
accords weight to `j`*. This is the "listening graph" orientation and matches the project convention for
`W`. Row-normalise directly — **no transpose**. (Stated explicitly in Sims & Gilles 2014, §5.2; consistent
with Bullo, *Lectures on Network Systems*, Fig. 5.5.)

**Validation.** Cross-checked against Table 4 of Sims & Gilles (2014), "Critical Nodes in Directed
Networks" (`Critical_Nodes_In_Directed_Networks.pdf` in the repo root). All 21 in-degrees and all 21
out-degrees match exactly.

- out-degrees (advisors sought, = row sums): `4 2 9 7 10 1 6 7 9 5 3 1 6 4 9 4 5 12 10 7 8`
- in-degrees (times consulted, = column sums): `12 18 3 6 3 0 11 1 4 8 9 3 0 10 3 0 0 15 2 6 15`
- total arcs: 129

*Note:* matching the degree sequence is strong evidence but not proof of a character-perfect transcription.
A one-off cross-check against a canonical machine-readable copy (UCINET / `igraphdata`) is recommended
before this becomes load-bearing.

**Known structural properties** (verified from this file):

- 5 strongly connected components: `{6}`, `{13}`, `{16}`, `{17}`, and one giant SCC of 17 nodes.
- Exactly one **closed** strong component (the giant one) ⟹ the graph is **rooted**; that component is
  **aperiodic** (period 1) ⟹ French–DeGroot reaches **consensus**.
- The row-stochastic normalisation is **reducible** but has a **simple, strictly dominant** eigenvalue 1.
- Every row is non-empty (out-degree ≥ 1), so row-normalisation needs no zero-row handling and creates
  no artificial stubborn agents.
- Managers **6, 13, 16, 17** have social power exactly **zero** (nobody seeks their advice).

**Other matrices available in the same Appendix A** (not yet transcribed): the **Consensus** structure and
**three individual slices**. See `docs/02_literature_review.md` §6.1 for the proposed aggregation-
sensitivity experiment.

---

## `sampson_affective_T4_signed.txt` — Sampson's monastery (18 novices)

**Source.** Samuel F. Sampson (1968), *A Novitiate in a Period of Change: An Experimental and Case
Study of Social Relationships*, PhD thesis, Cornell University — **APPENDIX, Table D₁₃, "Affective
Matrix, T₄", p. 469** (PDF page 492 of `sampson1968.pdf` in the repo root). Transcribed 2026-08-03.

> **Correction to an earlier note in this file.** A previous version stated that the dissertation
> contained only hand-drawn sociograms and that the data had to be downloaded. That was wrong. The
> sociograms (Chapter V, Figures I–XXI, pp. 323–380) are the *main-text* presentation; the
> **Appendix, pp. 423–552, contains the numeric matrices**, which neither the List of Tables nor the
> List of Illustrations indexes.

**What is in the Appendix.** Twelve matrices, D₅–D₁₆: four relations × three waves, one per page.

| Table | Relation | Wave | Page |
|---|---|---|---|
| D₅ D₆ D₇ D₈ | affective, esteem, influence, sanction | T₂ | 461–464 |
| D₉ D₁₀ D₁₁ D₁₂ | affective, esteem, influence, sanction | T₃ | 465–468 |
| **D₁₃** D₁₄ D₁₅ D₁₆ | **affective**, esteem, influence, sanction | T₄ | **469**–472 |

D₅, D₁₁, D₁₃ and D₁₅ were verified directly; the rest follow the same one-per-page pattern and should
be spot-checked if ever transcribed. PDF page = printed page + 23.

**Format.** 18 lines × 18 space-separated **signed** integers. Row *i* = novice *i*'s nominations.
Zero diagonal (self-nomination excluded).

**Direction convention.** `S(i,j) ≠ 0` means **novice *i* nominated novice *j***, i.e. *i* accords
weight to *j* — the project convention for `W`. Row-normalise directly, **no transpose**.

**Coding.** Ranked choices carrying a sign: **+3/+2/+1** for the first, second and third *most* liked;
**−3/−2/−1** for the first, second and third *least* liked. Sampson's Novice Questionnaire (p. 316)
asks for three ranked choices in each direction, with a fourth allowed in case of ties. These are
**ranks, not intensities** — any cardinal use is a modelling assumption, which is why
`load_sampson` exposes it as the `'Weights'` option.

**Actors** (Sampson's original IDs, not 1–18): 18 John Bosco · 19 Gregory · 20 Basil · 24 Peter ·
25 Bonaventure · 26 Berthold · 30 Mark · 32 Victor · 33 Ambrose · 34 Romuald · 35 Louis · 36 Winfrid ·
37 Amand · 38 Hugh · 39 Boniface · 40 Albert · 41 Elias · 42 Simplicius.

**Validation.** The dissertation prints the (+), (−) and (T) column totals beneath the table — 54
checksum constraints, **all satisfied**, and re-run on every `load_sampson` call:

- positive column totals: `12 13 7 12 10 3 6 6 5 0 4 9 4 3 3 2 4 8`
- negative column totals: `3 17 13 18 0 9 5 10 0 3 0 1 4 2 0 1 7 1`

Every row whose choice pattern departed from the canonical `{+1,+2,+3}/{−1,−2,−3}` was additionally
re-read at high magnification. Derived counts also agree: 56 positive arcs (18 × 3 plus 2 tie-extras)
and total positive weight 111 (18 × 6 plus 3).

**Known irregularities — genuine, not transcription errors:**
- **Basil, Berthold, Romuald** give a fourth, tied choice on one pole (allowed by the instrument).
- **Bonaventure, Romuald, Winfrid** name nobody they liked least. Sampson (footnote 23, p. 316) notes
  that the community's ideology of brotherly love made admitting dislike tantamount to confessing
  inadequacy, so these refusals are substantively meaningful rather than missing data.

**Structure of the positive pole** (verified): 2 strong components — `{Romuald}` and the other 17;
rooted and aperiodic, so French–DeGroot reaches consensus. **Romuald has social power exactly zero**:
nobody nominates him among those they like (his positive column total is 0).

**Caveats to state in any write-up:**
1. **Partly retrospective.** The questionnaire asks respondents to think back and answer as they felt
   at an earlier time, so T₂/T₃/T₄ are not independent longitudinal measurements.
2. **Euphemistic negative pole.** The negatives are "liked least", not "disliked" — *weak* negatives.

### Cross-checking against the distributed version — OUTSTANDING

The plan called for an independent check against the machine-readable copy. **R is not installed on
this machine, so this step has not been run.** It is the one piece of the acquisition plan still open.

`SAMPLK3` and `SAMPDLK` in the standard distributions are the positive and negative parts of this same
Table D₁₃, so `SAMPLK3 - SAMPDLK` should reproduce the file exactly. To check:

```r
remotes::install_github("schochastics/networkdata")   # MIT licence
library(networkdata); library(igraph)
# inspect names(sampson) to identify the liking / disliking networks, then:
S <- as.matrix(as_adjacency_matrix(sampson[[i]], attr = "weight")) -
     as.matrix(as_adjacency_matrix(sampson[[j]], attr = "weight"))
write.table(S, "sampson_check.txt", row.names = FALSE, col.names = FALSE)
```

Then diff against `sampson_affective_T4_signed.txt`. **Resolve any discrepancy in favour of the
dissertation**, which is the primary source and carries its own checksums.

**Verified sources** (checked 2026-08-03):

| Purpose | URL |
|---|---|
| Permanent, citable archive | https://doi.org/10.5281/zenodo.7189928 (`networkdata-0.1.14.zip`, CC-BY 4.0) |
| R package | https://github.com/schochastics/networkdata (MIT) |
| Direct data file | https://github.com/schochastics/networkdata/blob/master/data/sampson.rda |
| Canonical description | https://sites.google.com/site/ucinetsoftware/datasets/sampson-monastery |
| Faction labels (binary nets) | CRAN `ergm`: `data(samplk)` — https://rdrr.io/cran/ergm/man/samplk.html |

**Dead — do not cite:** `http://vlado.fmf.uni-lj.si/pub/networks/data/esna/sampson.htm` (Pajek/ESNA,
cited by Talaga et al. 2023) refuses connections.

**Not included:** the faction labels (Young Turks / Loyal Opposition / Outcasts / Waverers). They are
available as the `group` vertex attribute in `ergm::samplk`; they are deliberately **not** hard-coded
here, because the assignment of the borderline novices varies across sources and has not been verified
against a primary source in this session.
