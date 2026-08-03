# Opinion Dynamics in Social Networks — Technical Analysis and Project Roadmap

**Phase 1 deliverable: conceptual and implementation roadmap. No MATLAB code is written in this phase.**

---

## 0. Context

The objective is to implement and analyse four classical opinion-dynamics models in MATLAB —
**French–DeGroot**, **Abelson**, **Taylor**, and **Friedkin–Johnsen** — combining rigorous theory with
simulation. The guiding source is the tutorial by Proskurnikov & Tempo (Part I), with the professor's
specific instruction to go beyond plain averaging dynamics and focus on **stubbornness**, especially the
Friedkin–Johnsen (FJ) model: what new behaviours it captures, and what theory exists.

Before any code is written, this document establishes: (i) what each model is and why it exists,
(ii) what is actually proved about each, (iii) how they connect as an intellectual progression,
(iv) a clean MATLAB architecture, (v) a defensible set of test networks, (vi) a dedicated treatment of
stubbornness, and (vii) the report structure.

**Decisions taken (confirmed with the user):**

| Decision | Choice |
|---|---|
| Deliverable format | `.mlx` Live Scripts (narrative + math + plots) on top of a plain `.m` function library |
| Language | English throughout — code, comments, figures, report |
| Existing `Prove/` folder | **Left untouched and unused.** New library built clean from scratch. |
| Opinion dimension | **Scalar** for all theory and comparison; APIs designed so vector opinions drop in later without rewriting |

> **Status:** Phase 1 (this document) is complete and approved. Phase 2 — the literature review of the
> primary sources and datasets — is in [`02_literature_review.md`](02_literature_review.md). Sections
> below carry inline **UPDATE (Phase 2)** notes where that reading changed the facts. The overall structure
> proposed here is unchanged.

**Sources read for this analysis** (all present in the repo):
- `1-s2.0-S1367578817300172-mainext.pdf` — Proskurnikov & Tempo, *A tutorial on modeling and analysis of dynamic social networks. Part I*, Annual Reviews in Control 43 (2017) 65–79. **Primary source.** Includes the 2021 **Corrigendum** bound at the end (see §12.1).
- `1-s2.0-S1367578818300142-main.pdf` — Part II (2018): time-varying graphs, bounded confidence, gossip, Altafini. Used to place Part I in context and to source future-reading pointers.
- `Novel_Multidimensional_Models_of_Opinion_Dynamics_in_Social_Networks.pdf` — Parsegov, Proskurnikov, Tempo & Friedkin, IEEE TAC 62(5), 2017. Multidimensional FJ with topic coupling.
- `LecturesNetworkSystems-FB.pdf` — Bullo, *Lectures on Network Systems*, ed. 1.7. Contains the **Krackhardt advice network** (Fig. 5.5) and a fully worked FJ exercise (E5.24) — used below as validation material.

Throughout, statements are tagged **[T]** if they come directly from the tutorial, and **[L]** if they come
from the broader literature and are only mentioned in passing (or not at all) by the tutorial.

---

## 1. Preliminaries: the mathematical toolbox shared by all four models

Everything in this project rests on four pillars. Understanding *why* these are the right tools makes all
four models feel like one theory rather than four unrelated constructions.

### 1.1 Digraphs and the direction convention (critical)

A weighted digraph is `G = (V, E, A)` with `V = {1..n}` and `A ≥ 0`. **[T]** The tutorial uses the
*multi-agent* convention: arc `(i,j) ∈ E` corresponds to the entry `a_ji > 0` — i.e. the arrow points
**along the flow of influence**, from influencer `i` to influenced `j`, while the weight lives in row `j`.
Bullo's book uses the opposite drawing convention: an edge `(i,j)` means "*i* seeks advice from *j*", which
corresponds to `a_ij > 0`.

**The matrix is the same in both books; only the arrow direction in the picture differs.** In both,
**row `i` of the matrix lists whom agent `i` listens to**. This is the single most dangerous source of
silent bugs in this project (see §12.2). The project will fix the convention:

> **Convention (project-wide).** `W(i,j) > 0` means *agent `i` assigns weight to agent `j`'s opinion*.
> Rows sum to 1. In MATLAB, `digraph(W)` is the **listening graph** (arrow `i → j` = "i listens to j"),
> and `digraph(W')` is the **influence graph** (arrow = flow of influence, matching the tutorial's figures).

Key structural notions **[T]**:
- **Root node**: a node connected by walks to all others (in the influence graph) — a universal influencer.
  Bullo's equivalent term is *globally reachable node*.
- **Quasi-strongly connected (rooted)** = at least one root exists = the graph has a directed spanning tree.
- **Strongly connected component (SCC)**; an SCC is **closed** if it receives no influence from outside.
  In the listening graph, *closed SCCs are exactly the sinks of the condensation digraph* — this is the
  computational recipe.
- A graph is **rooted iff it has exactly one closed SCC**, and then that component contains all roots.
- **Period** of a strong graph = gcd of all cycle lengths; **aperiodic** if that gcd is 1. Any self-loop
  forces aperiodicity.

### 1.2 Nonnegative matrices, Perron–Frobenius, stochasticity

**[T]** Perron–Frobenius: `ρ(A)` is an eigenvalue of any nonnegative `A` with a nonnegative eigenvector; if
`A` is irreducible, `ρ(A)` is simple and the eigenvector is strictly positive. Irreducibility of `A` ⟺
`G[A]` strongly connected.

**[T]** For an irreducible `A` with `h` eigenvalues of maximal modulus, those eigenvalues are simple and are
the `h`-th roots of `ρ(A)^h`; `h` is exactly the graph's period. Hence **primitive ⟺ irreducible and
aperiodic**, and primitivity means `A^k > 0` entrywise for large `k`.

`A` **row-stochastic** ⟹ `A·1 = 1`, so `ρ(A) = 1`. `A` **substochastic** ⟹ `ρ(A) ≤ 1`; an *irreducible*
substochastic matrix is either stochastic or **Schur stable** (`ρ < 1`). **[T]** This dichotomy is the
engine behind every stability result for Taylor and FJ.

### 1.3 M-matrices and the Laplacian — the unifying thread

**[T]** `Z` is an **M-matrix** if `Z = sI − A` with `A ≥ 0`, `s ≥ ρ(A)`. Two facts do almost all the work:
- **Corollary 6**: an M-matrix has a real eigenvalue `λ₀ = s − ρ(A) ≥ 0` (semisimple), and every other
  eigenvalue satisfies `Re λ > λ₀`. So `Z` is nonsingular iff `s > ρ(A)`.
- **Lemma 7**: a *nonsingular* M-matrix has a **nonnegative inverse**.

The Laplacian `L[A] = diag(A·1) − A` is a **singular** M-matrix, with `L·1 = 0`. **[T] Lemma 8**:
`0` is an algebraically simple eigenvalue of `L[A]` ⟺ `ker L[A] = span{1}` ⟺ `G[A]` is rooted.

> **This is the single most important structural insight of the whole project.** All four models are
> governed by an M-matrix, and the *singular vs. nonsingular* dichotomy is exactly the *consensus vs.
> persistent disagreement* dichotomy:
>
> | Model | Governing matrix | Type | Consequence |
> |---|---|---|---|
> | French–DeGroot | `I − W` | singular M-matrix | eigenvalue 1 on the unit circle → marginal stability, consensus manifold |
> | Abelson | `L[A]` | singular M-matrix | eigenvalue 0 → marginal stability, consensus manifold |
> | Taylor | `L[A] + Γ` | nonsingular M-matrix (when all agents are anchored) | Hurwitz → unique equilibrium |
> | Friedkin–Johnsen | `I − ΛW` | nonsingular M-matrix (when all agents are anchored) | Schur → unique equilibrium |
>
> And Lemma 7 (nonnegative inverse) is precisely what makes the limit operators `M` (Taylor) and
> `V` (FJ) **row-stochastic**, i.e. what guarantees that final opinions are *convex combinations* of
> prejudices rather than arbitrary numbers. Persistent disagreement is bounded, not divergent.

---

## 2. Model 1 — French–DeGroot

### 2.1 Overview

**Historical context.** John R. P. French (1956), a social psychologist, was not chasing consensus — he was
after a quantitative theory of **social power** (French & Raven, 1959). He drew a digraph in which an arc
`j → i` meant "*j* has power over *i*", and had each agent replace its opinion by the **plain average** of
the opinions displayed to it (so in French's original model all nonzero weights in a row are equal and every
node has a self-loop). Harary (1959) supplied the rigorous convergence criterion French had stated without
proof. **DeGroot (1974)** independently generalised the update to an arbitrary row-stochastic weight matrix
and vector-valued opinions, motivated by *statistical* consensus: `n` experts pooling subjective probability
distributions. DeGroot's contribution was to make the procedure **decentralised** — no agent needs global
information — replacing the centralised Eisenberg–Gale convex program with simple repeated weighted
averaging. **[T]**

**Intuition.** Each agent is a naïve Bayesian-free averager: at every round it discards its own reasoning
and adopts a weighted mean of what it hears (including, possibly, its own current opinion).

**Assumptions.** Fixed group of `n ≥ 2` agents; fixed influence weights; synchronous updates; opinions are
real; `W` is row-stochastic (`w_ij ≥ 0`, rows sum to 1). Row-stochasticity encodes "each agent distributes a
fixed budget of trust".

**Formulation (discrete time).**
```
x(k+1) = W x(k),      k = 0,1,2,…        (scalar opinions, x ∈ R^n)
X(k+1) = W X(k)                          (vector opinions, X ∈ R^{n×m}, rows = agents)
```
Each column of `X` evolves independently — the multidimensional model adds nothing dynamically; this is why
scalar analysis suffices. **[T]**

**Relation to consensus dynamics.** This *is* the canonical discrete-time consensus protocol. Modern
multi-agent control rediscovered it in the 2000s (Jadbabaie–Lin–Morse; Ren–Beard; Moreau).

### 2.2 Theoretical properties

**Non-expansiveness.** A direct computation shows `min_i x_i(k)` is non-decreasing and `max_i x_i(k)` is
non-increasing. **[T]** Conceptually: `W` row-stochastic means `x(k+1)` is a **convex combination** of the
entries of `x(k)`, so the *convex hull* of the opinions is a nested, shrinking family of intervals. The
"spread" `V(x) = max_i x_i − min_i x_i` is a natural Lyapunov-like function (non-increasing, though not
strictly decreasing in general). Consequence: the system is always **Lyapunov stable but never
asymptotically stable** — `W` always has eigenvalue `1`.

**Two distinct questions** — do not conflate them **[T]**:
- **Convergence** (Def. 14): `lim W^k` exists. `W` is then called *regular*.
- **Consensus**: the limit exists *and* all components are equal. `W` is *fully regular* (= SIA in the
  multi-agent literature).

**Algebraic criteria [T] (Lemma 9).**
- Convergent ⟺ `λ = 1` is the **only** eigenvalue on the unit circle.
- Consensus ⟺ additionally that eigenvalue is **simple** (eigenspace `= span{1}`).

Failure of the first condition means other unit-modulus eigenvalues exist ⟹ **undamped oscillation** for
almost every initial condition. Failure of only the second means the limit exists but is not consensus:
opinions split into blocks.

**Graph-theoretic criteria [T] (Theorem 12, DeMarzo–Vayanos–Zwiebel / Jackson).**
- Convergent ⟺ **all closed SCCs are aperiodic**.
- Consensus ⟺ the graph is **rooted** (quasi-strongly connected) **and** its unique closed SCC is aperiodic.

**Corollary 13 [T].** If every agent has positive self-weight `w_ii > 0`, convergence is automatic
(self-loops kill periodicity), and **consensus ⟺ rooted**. Note carefully: rootedness alone is *not*
sufficient without aperiodicity — this is exactly what the directed ring will demonstrate numerically (§10.1).

**Why aperiodicity is the discrete-time-only obstruction.** In a period-`h` strong graph, `W^k` cyclically
permutes `h` "phases" of the state; the dynamics is a rotation composed with contraction along the remaining
directions, and it never settles. This obstruction **disappears entirely in continuous time** (§3) — one of
the cleanest structural contrasts in the project.

**Limit and social power [T].** When consensus holds, `W^k → 1 p_∞ᵀ`, a **rank-one** limit, and
`x(∞) = (p_∞ᵀ x(0)) 1`. Here `p_∞ ≥ 0`, `p_∞ᵀ W = p_∞ᵀ`, `p_∞ᵀ 1 = 1` — the **left dominant (Perron)
eigenvector**. `p_∞,i` is agent `i`'s **social power**: the weight its initial opinion carries in the group's
final position.

**Invariant [L, standard].** `p_∞ᵀ x(k)` is **conserved for all `k`** (since `p_∞ᵀ W = p_∞ᵀ`). This is an
excellent numerical unit test and rarely stated explicitly in tutorials. For a **doubly stochastic** `W`,
`p_∞ = 1/n` and the model achieves **average consensus** — the invariant is the plain mean.

**Duality with Markov chains [T].** `p(k+1) = p(k) W` is the forward Kolmogorov equation of a Markov chain
with transition matrix `W`. Then:
- closed SCCs ↔ **essential (recurrent) classes**; non-closed nodes ↔ **inessential/transient states**;
- convergence of `W^k` ↔ the chain always reaches a stationary distribution (all essential classes aperiodic);
- consensus ↔ **ergodicity/regularity** (unique aperiodic essential class);
- stubborn agents ↔ **absorbing states**, and the whole chain is *absorbing*;
- social power `p_∞` ↔ **stationary distribution**.

This duality is the reason the same theorems appear in Seneta, Gantmacher, Kemeny–Snell and in the
multi-agent literature.

**Centrality interpretation [T].** `p_∞` is a centrality measure closely related to **eigenvector
centrality** (Bonacich): eigenvector centrality is the left Perron vector of the raw binary adjacency matrix,
while social power is that of the *row-normalised* matrix. The conceptual novelty French introduced is that
this centrality is **generated by a dynamic process**, not postulated as a graph statistic — and it comes with
a distributed algorithm to compute it.

**Stubborn agents [T] (Def. 16).** `w_ii = 1` ⟹ `x_i(k) ≡ x_i(0)`: a **source node**. With one stubborn root,
the whole group converges to that agent's opinion. With `s ≥ 2` stubborn agents, consensus is impossible;
but if together they reach everyone, the model still **converges** (Cor. 14) and the limit is entirely
determined by the stubborn agents' opinions — everyone else's initial condition is *forgotten* (the
corresponding columns of `W^∞` are zero).

**Not in the tutorial, worth reading [L]:** convergence **rate**. The transient decays like `|λ₂|^k`, where
`λ₂` is the second-largest eigenvalue modulus (SLEM); the spectral gap `1 − |λ₂|` controls mixing, and for
reversible chains it is bounded via **Cheeger/conductance**. Sharp bounds: Olshevsky & Tsitsiklis (2011),
Cao–Morse–Anderson (2008b). Mentioned only in passing by the tutorial's conclusion.

### 2.3 What makes it interesting
Consensus/averaging; non-Bayesian social learning (Golub–Jackson "wisdom of crowds", Jadbabaie et al.);
Markov-chain duality; social power as *dynamically generated centrality*; the first rigorous bridge between
Social Network Analysis and systems theory. Its **limitation is the point of the whole project**: on any
reasonable (rooted, aperiodic) network it *always* predicts unanimity — which is empirically false.

---

## 3. Model 2 — Abelson

### 3.1 Overview

**Historical context.** Robert Abelson (1964, 1967), a mathematical psychologist, proposed the
**continuous-time counterpart** of French–DeGroot and — more importantly — formulated the field's defining
open problem. **[T]**

**Derivation and intuition [T].** Rewrite the French–DeGroot update as an increment:
```
x_i(k+1) − x_i(k) = Σ_{j≠i} w_ij [ x_j(k) − x_i(k) ]
```
Every term is a *pull* of agent `i` toward agent `j`, scaled by trust. This matches the dyadic experimental
finding that two people in discussion move toward each other. Letting the time between interactions become
infinitesimal:
```
ẋ_i(t) = Σ_{j≠i} a_ij ( x_j(t) − x_i(t) )        ⟺        ẋ(t) = − L[A] x(t)
```
The `a_ij ≥ 0` are **infinitesimal influence weights** or **"contact rates"**. Crucially, `A` need **not** be
row-stochastic — the row sums are free, they set the *speed* at which each agent is pulled. This is a genuine
relaxation compared to French–DeGroot.

Abelson also proposed a **nonlinear** version `ẋ_i = Σ a_ij g(x_i,x_j)(x_j − x_i)`, with a coupling function
`g : R×R → (0,1]`. **[T]**

**Relation to consensus dynamics.** `ẋ = −Lx` is the **Laplacian flow**, rediscovered as the canonical
continuous-time consensus protocol (Olfati-Saber & Murray 2004; Ren & Beard 2005) and the linear core of
flocking/alignment models. **[T]**

### 3.2 Theoretical properties

**Always convergent [T] (Corollary 15).** `L` is a singular M-matrix: the zero eigenvalue is semisimple and
*every* other eigenvalue has `Re λ > 0`. Hence `e^{−Lt}` converges to `P^∞`, the spectral projection onto
`ker L` along `range L`. **There is no periodicity obstruction in continuous time.** The oscillation mode
that plagues French–DeGroot is a pure artefact of synchronous discrete updating — a point worth making
loudly in the report, because it is *the* structural difference between the two models.

**Consensus [T] (Theorem 16).** Consensus ⟺ `G[A]` is **rooted**. Then
```
lim x(t) = (p_∞ᵀ x(0)) 1,      p_∞ᵀ L[A] = 0,  p_∞ ≥ 0,  p_∞ᵀ 1 = 1.
```
`p_∞` is the **left null vector of the Laplacian** — the continuous-time social power. `p_∞ᵀ x(t)` is again a
conserved quantity (unit test). If the graph is not rooted, `P^∞` is a projection onto a higher-dimensional
kernel: the group settles into **blocks** — one consensus value per closed SCC, with the remaining agents
landing at convex combinations. That is *clustering by topology*.

**Historical accuracy [T].** Abelson himself proved `ker L = span{1} ⟺` "compact" (his term for rooted), but
only for **diagonalisable** Laplacians. The missing piece — algebraic simplicity of the zero eigenvalue —
was completed by Ren & Beard (2005); the strongly connected case by Olfati-Saber & Murray (2004). The
tutorial also notes that Abelson's claim that the *nonlinear* model reaches consensus for any `g ∈ (0,1]` is
**false as stated**; it holds for *continuous* `g` (Lin–Francis–Maggiore 2007; Münz et al. 2011).

**Bridge to discrete time [T] (Lemma 17).** For any `A ≥ 0` and `τ > 0`, `W_τ = e^{−τ L[A]}` is
**row-stochastic with strictly positive diagonal**. So sampling the Abelson flow produces a French–DeGroot
model that automatically satisfies Corollary 13 — which is *why* the sampled system can never oscillate. This
is a beautiful, directly implementable link and should be an explicit numerical experiment (§10.4).

**Not in the tutorial, implementation-critical [L].** The other discretisation is the **explicit Euler**
scheme `x(k+1) = (I − εL) x(k)`. `I − εL` is row-stochastic **iff `ε · max_i (Σ_j a_ij) ≤ 1`**, and has
positive diagonal iff the inequality is strict. Violating it breaks stochasticity and can destabilise the
simulation. This is standard (Olfati-Saber–Murray; Bullo) and makes an excellent cautionary demo.

**Not in the tutorial [L].** Convergence rate = `min{Re λ : λ ≠ 0 eigenvalue of L}`. For undirected graphs
this is the **algebraic connectivity / Fiedler value** `λ₂(L)`, with the whole spectral-graph-theory
machinery attached.

### 3.3 What makes it interesting — and an important corrective

**The community cleavage problem / Abelson's diversity puzzle [T].** Abelson observed that universal
agreement is the ubiquitous outcome of a very broad class of models, and asked what one must assume in order
to reproduce the *bimodal* outcomes that empirical community studies actually report. Friedkin later named
this the **community cleavage problem**. It is the organising question of the entire tutorial, and it should
be the organising question of the report.

> **Corrective — read this before writing the Abelson section.** It is tempting to file Abelson under
> "polarization, persistent disagreement, community splitting". The *linear* Abelson model does **not**
> produce polarization on a rooted graph — it provably reaches consensus. Persistent disagreement arises
> only when rootedness fails, i.e. when the network has **two or more closed SCCs** — which is a topological
> accident (the group is effectively two groups), not a behavioural mechanism.
>
> **Abelson's role in the project is to pose the puzzle, not to solve it.** The solutions are:
> (i) **stubbornness/prejudice** → Taylor and Friedkin–Johnsen (this project);
> (ii) **bounded confidence** → Hegselmann–Krause, Deffuant–Weisbuch (Part II);
> (iii) **antagonistic/negative ties** → Altafini (Part II).
> Framing it this way makes the whole report coherent: §Abelson asks the question, §Taylor and §FJ answer it.

---

## 4. Model 3 — Taylor

### 4.1 Overview

**Historical context.** Taylor (1968) extended Abelson by adding **external communication sources** — mass
media, institutions, information the group does not generate itself. **[T]** The tutorial's striking
observation is that Taylor's model **anticipated by four decades** the multi-agent literature on
**containment control**.

**Formulation [T].** `n` agents with opinions `x_i`, and `m ≥ 1` static sources `s_1..s_m`:
```
ẋ_i = Σ_{j=1..n} a_ij (x_j − x_i)  +  Σ_{k=1..m} b_ik (s_k − x_i)
```
`B = (b_ik) ≥ 0` are Taylor's **persuasibility constants**. Agents with `b_i· = 0` are free of external
influence.

**Reduction [T].** Setting `γ_i = Σ_k b_ik` and `u_i = γ_i^{-1} Σ_k b_ik s_k` (and `u_i = 0` if `γ_i = 0`),
the model collapses to a per-agent **prejudice**:
```
ẋ_i = Σ_j a_ij (x_j − x_i) + γ_i (u_i − x_i)
```

> **⚠ Notational trap in the paper.** The tutorial writes the matrix form as `ẋ = −(L[A] + Γ)x + u`
> (Eq. 15). Consistency with Eq. (14) and with the limit formula in Theorem 18 (which contains `Γ¹¹`)
> requires
> ```
> ẋ = −( L[A] + Γ ) x + Γ u ,      Γ = diag(γ_1,…,γ_n)
> ```
> i.e. the `u` of Eq. (15) is the `Γu` of Eq. (14). **Implement the version with `Γu`.** Flag this in the
> report; it is exactly the sort of thing that produces a wrong steady state and hours of debugging.

**Definition 17 [T].** Agent `i` is **prejudiced** if `γ_i > 0`. A prejudiced agent that is also closed to
interpersonal influence (`a_ij = 0 ∀j`) converges to its prejudice, `x_i(t) → u_i`, with `γ_i` setting the
rate; if additionally `u_i = x_i(0)` it is **totally stubborn**. But the concept is much broader: a
prejudiced agent may be simultaneously anchored *and* socially influenced.

### 4.2 Theoretical properties

**Structural decomposition [T].** Agent `i` is **P-dependent** if it is prejudiced, or if some prejudiced
agent `j` reaches it by a walk in `G[A]`; otherwise **P-independent**. In the project's listening-graph
convention this reads cleanly: *`i` is P-dependent iff `i` can reach some anchored agent in `digraph(A)`*.
After renumbering, the system block-decomposes into a P-dependent block (`1..r`) driven by the prejudices
and a P-independent block (`r+1..n`) that is a **pure Abelson model** — the external information simply
never reaches those agents.

**Theorem 18 [T].**
- The P-dependent block is **asymptotically stable**: `−(L¹¹ + Γ¹¹)` is **Hurwitz**. Proof idea: `L¹¹ + Γ¹¹`
  is an M-matrix (Lemma 5); a nonnegative left eigenvector for `λ₀ = 0` would have to vanish at every
  prejudiced agent and then, by propagating along walks, vanish everywhere — contradiction. Hence `λ₀ > 0`.
- The limit is `x¹(∞) = M [uᵀ, x²(∞)ᵀ]ᵀ` with `M = (L¹¹+Γ¹¹)^{-1}[Γ¹¹, −L¹²]`, and **`M` is row-stochastic**
  (nonnegativity from Lemma 7; unit row sums because `x ≡ 1` is an equilibrium when `u = 1`).

**Corollary 19 [T].** The system is asymptotically stable ⟺ **every agent is P-dependent**, i.e. every agent
is influenced — directly or through a chain — by at least one communication source.

> **The graph condition has flipped.** For consensus (FD/Abelson) you need *one node that reaches everyone*.
> For asymptotic stability (Taylor/FJ) you need *the anchor set to reach everyone*. Same reachability
> machinery, dual roles. This pairing is one of the most illuminating things to state in the report.

`L¹¹ + Γ¹¹` is a **grounded Laplacian** [L]; its smallest eigenvalue governs the convergence rate and is
studied in Pirani & Sundaram (2016) — cited but not developed by the tutorial.

**Containment control [T] (Theorem 20).** With `d`-dimensional states, agents = mobile robots, sources =
**static leaders** at positions `s_1..s_k`, the three statements are equivalent: (1) Hurwitz stability;
(2) every agent is P-dependent; (3) all agents converge **into the convex hull** `S = conv{s_1..s_k}`, for
*any* leader positions and *any* initial conditions. Proof by scalarisation: project along an arbitrary
direction `v` and apply the scalar result. Extensions: dynamic leaders, time-varying graphs, arbitrary
closed convex target sets ("target aggregation"), links to distributed optimisation.

### 4.3 What makes it interesting
Introduces **exogenous information** (media, institutions, propaganda) and hence a genuine *control input*.
It is the first model in the sequence where disagreement is a **generic**, structurally robust outcome rather
than a topological accident. It supplies the leader/follower and containment vocabulary, and it opens
control-theoretic questions the tutorial does not pursue: *which* agents should be persuaded, and how
strongly, to steer the group — i.e. **actuator/leader selection** and optimal influence allocation [L].

---

## 5. Model 4 — Friedkin–Johnsen

### 5.1 Overview

**Historical context.** The tutorial makes a pointed observation: **no discrete-time counterpart of Taylor's
model existed until the 1990s**, when Noah Friedkin and Eugene Johnsen (1990, 1997, 1999) introduced it from
within sociology, embedded in *Social Influence Network Theory*. **[T]** Unlike essentially every other model
in the field, FJ has been **experimentally validated** on small and medium groups (Friedkin & Johnsen 1999,
2011; Childress & Friedkin 2012). That empirical grounding is the strongest single argument for making it the
centrepiece of this project.

**Formulation [T].**
```
x(k+1) = Λ W x(k) + (I − Λ) u ,      Λ = diag(λ_1,…,λ_n),  λ_i ∈ [0,1]
```
- `W` — row-stochastic influence matrix, as in French–DeGroot.
- `λ_i` — **susceptibility** of agent `i` to social influence.
- `1 − λ_i` — **attachment / anchorage** to the prejudice `u_i`.
- `u` — constant vector of **prejudices**.

Special cases:
- `Λ = I` ⟹ exactly French–DeGroot.
- `λ_i = 0` ⟹ `x_i(k) ≡ u_i` for all `k ≥ 1` — **totally stubborn**; if `u_i = x_i(0)`, the agent never moves.
- `0 < λ_i < 1` ⟹ **partially stubborn / prejudiced** — the genuinely new object.

**Two modelling conventions [T] — make this a switch in the code.**
Friedkin & Johnsen's own theory assumes `u = x(0)` (prejudices are the initial opinions, formed by the
group's history) *and* the **coupling condition** `λ_i = 1 − w_ii` (anchorage equals self-weight). The
tutorial deliberately **decouples** these, allowing `u` and `x(0)` to be independent and `Λ` and `W` to be
independent, because prejudices may come from media rather than from history. The project must support both
modes, defaulting to the decoupled one and offering `'classic'` presets.

### 5.2 Theoretical properties

**The affine structure is the whole point.** FJ is not a linear map — it is **affine**. The homogeneous part
`ΛW` is **substochastic** (`ΛW·1 = Λ·1 ≤ 1`, strict wherever `λ_i < 1`). Therefore `span{1}` is **no longer
invariant**: the consensus manifold has been removed from the dynamics.

**Theorem 21 [T].** With the same P-dependent / P-independent split (using `G[W]`):
- `Λ¹¹W¹¹` is **Schur stable**, `ρ(Λ¹¹W¹¹) < 1`. Proof mirrors Taylor's: a unit-modulus left eigenvector must
  vanish at prejudiced agents and propagate to zero everywhere.
- P-independent agents obey a pure French–DeGroot model with stochastic `W²²`.
- The model converges ⟺ `r = n` **or** `W²²` is regular.
- `x¹(∞) = V [uᵀ, x²(∞)ᵀ]ᵀ` with `V = (I − Λ¹¹W¹¹)^{-1}[I − Λ¹¹, Λ¹¹W¹²]`, and **`V` is row-stochastic**.

**Corollary 22 [T].** Asymptotic stability ⟺ **all agents P-dependent**, and then
```
V = (I − ΛW)^{-1} (I − Λ)          ("total influence" / control matrix)
x(∞) = V u
```
Sufficient conditions: `Λ < I`, or `Λ ≠ I` with `W` irreducible.

**Corollary 23 and a subtle point [T].** Convergence ⟺ `ΛW` is regular. This is *not* automatic for affine
systems: `x(k+1) = Ax(k) + Bu` with `A` regular can diverge (`A = B = I`). The result is stated without proof
in Friedkin & Johnsen (1999); the rigorous version is in Parsegov et al. (2017). Worth flagging as an example
of the tutorial adding rigour to a sociology result.

**The algebraic signature of disagreement.**
```
French–DeGroot:  lim W^k = 1 p_∞ᵀ     →  RANK ONE     →  consensus
Friedkin–Johnsen: x(∞) = V u,  V row-stochastic, generically FULL RANK → each agent keeps a personal signature of its own prejudice
```
Both limit operators are row-stochastic; **the rank is what distinguishes consensus from cleavage.** This is
the crispest one-line summary of the whole project and should appear in the report and be verified
numerically (`rank(V)`, singular values of `V`).

**Influence centrality [T].** Generalising French's social power to the non-consensus case, Friedkin defines
```
c = n^{-1} Vᵀ 1 ,        mean final opinion  x̄(∞) = cᵀ x(0)   (when u = x(0))
```
`c` is the **mean weight** of agent `i`'s initial opinion across all agents' final opinions. `cᵀ1 = 1`.

**Lemma 24 [T] — the continuous bridge back to French–DeGroot.** With `Λ = αI`,
```
V_α = (1 − α)(I − αW)^{-1}  →  W^∞ = 1 p_∞ᵀ   as  α → 1⁻ ,      hence  c_α → p_∞ .
```
And `V_0 = I` (everyone frozen at their prejudice). **The family `{V_α}_{α∈[0,1)}` interpolates continuously
between "nobody moves" and "everybody agrees".** This one-parameter sweep is the single most instructive
numerical experiment in the project (§10.4).

**PageRank [T].** Random surfing with **teleportation** probability `m`:
`p(k+1) = (1−m) p(k) W + (m/n) 1ᵀ` is *exactly the dual of FJ with `Λ = (1−m) I`* and uniform prejudice.
So `PageRank = c_{1−m}`, a special case of Friedkin's influence centrality (Google used `m = 0.15`).
Teleportation exists precisely because real web graphs are not fully regular — the same mathematical fix
sociology calls "prejudice". A genuinely memorable connection.

**Game-theoretic interpretation [T]** (Bindel–Kleinberg–Oren; Ghaderi–Srikant). With
```
J_i(x_i) = λ_i Σ_j w_ij (x_j − x_i)²  +  (1 − λ_i)(x_i − u_i)²
```
the FJ update is exactly each agent's **best response** holding others fixed, and `x(∞)` is the **Nash
equilibrium**. It does **not** minimise the social cost `Σ_i J_i`; the ratio is a **price of anarchy**.
There is also an **electrical-network** reading: opinions = node potentials in a resistive network where each
prejudiced agent is tied to a voltage source through a resistor — the best intuition pump available for
stubbornness [L].

**Equivalences [T].**
- FJ ≡ French–DeGroot on an **augmented graph** with `n` extra virtual stubborn agents anchored at `u`.
- French–DeGroot *with stubborn agents* ≡ FJ with `λ_i = 0, u_i = x_i(0)` for stubborn `i` and `λ_i = 1,
  u_i = 0` otherwise.
- Apparent paradox **[T, footnote 21]**: FD is only neutrally stable, yet the equivalent FJ is
  asymptotically stable. Resolution: in FJ, `u` is an **exogenous constant input**, not part of the state.
  Moving the prejudice out of the state vector is what buys asymptotic stability. Excellent didactic point.

**Extensions [T + Parsegov et al.].** Multidimensional `X(k+1) = ΛWX(k) + (I−Λ)U`; with **interdependent
topics** via a stochastic `d×d` coupling matrix `C`: `X(k+1) = ΛWX(k)C + (I−Λ)U` — **stability conditions are
unchanged**. Also heterogeneous per-agent `C_i` (belief systems), and asynchronous **gossip** versions
(Frasca–Ravazzi–Tempo–Ishii). These are the natural "if there is time" extensions.

---

## 6. Connections among the models — the evolution

### 6.1 The 2×2 table

|  | **No anchoring** (linear, marginally stable) | **With anchoring** (affine, asymptotically stable) |
|---|---|---|
| **Discrete time** | **French–DeGroot** `x⁺ = Wx` | **Friedkin–Johnsen** `x⁺ = ΛWx + (I−Λ)u` |
| **Continuous time** | **Abelson** `ẋ = −Lx` | **Taylor** `ẋ = −(L+Γ)x + Γu` |

- **Vertical axis** = time discretisation. `W_τ = e^{−τL}` (exact, Lemma 17) or `I − εL` (Euler, needs
  `ε·max_i d_i < 1`). Going continuous **removes the periodicity obstruction**; nothing else changes.
- **Horizontal axis** = anchoring. Add `Γ` (continuous) or `I − Λ` (discrete). The governing M-matrix goes
  from **singular to nonsingular**; the consensus manifold `span{1}` stops being invariant; marginal
  stability becomes **exponential** stability; the limit operator goes from **rank one** to **full rank**.
- **The historical gap** the tutorial highlights: the discrete/anchored cell stayed empty from 1968 to 1990.
  Taylor had the continuous-time answer decades before Friedkin & Johnsen wrote the discrete one — and FJ,
  arriving from sociology rather than control, is the one that got validated on data.

### 6.2 What stays the same
- **Nonnegative matrix theory**: Perron–Frobenius, irreducibility, primitivity.
- **M-matrix theory**: Corollary 6 (spectrum location) + Lemma 7 (nonnegative inverse). Lemma 7 is what makes
  `V`, `M`, and `W^∞` all **row-stochastic** — hence all four models keep opinions inside a convex hull of
  either initial opinions or prejudices. **No model here can produce runaway extremism**; opinions never
  leave the convex hull of the inputs. Worth stating explicitly — it delimits what this family *cannot* do
  and motivates Part II's Altafini model, where negative ties break exactly this property.
- **Reachability on the condensation digraph** is the universal structural test; only the *role* changes
  (root reaching everyone ↔ anchor set reaching everyone).
- **Left eigenvectors / null vectors** always carry the influence/centrality information:
  `p_∞ᵀW = p_∞ᵀ` (FD), `p_∞ᵀL = 0` (Abelson), `c = n^{-1}Vᵀ1` (FJ).

### 6.3 What is new at each step

| Step | New assumption | New behaviour |
|---|---|---|
| French → DeGroot | arbitrary stochastic `W`, vector opinions | decentralised pooling; social power as centrality |
| DeGroot → Abelson | continuous time; row sums free | no oscillation; the **diversity puzzle** is posed |
| Abelson → Taylor | exogenous sources `B`, `s` | generic persistent disagreement; leaders; **containment** |
| Taylor → FJ | discrete time + susceptibility `Λ`; `u = x(0)` option | **empirical validation**; influence centrality; PageRank; game/Nash reading |

### 6.4 Convergence-rate summary (mostly [L] — recommend as a report subsection)

| Model | Asymptotic rate |
|---|---|
| French–DeGroot | `\|λ₂(W)\|` (SLEM); spectral gap `1 − \|λ₂\|` |
| Abelson | `min{Re λ : λ ≠ 0, λ ∈ spec L}`; for undirected = Fiedler value `λ₂(L)` |
| Taylor | `λ_min(L¹¹ + Γ¹¹)` — smallest eigenvalue of the **grounded Laplacian** |
| Friedkin–Johnsen | `ρ(ΛW) < 1` |

---

## 7. Stubbornness — the core of the project

This section deserves the most care; it is the professor's explicit focus.

### 7.1 Four notions that are routinely conflated — fix a glossary first

| # | Notion | Formalisation | Behaviour |
|---|---|---|---|
| 1 | **Total stubbornness / zealot / radical** | `w_ii = 1` (FD); `λ_i = 0` (FJ); `γ_i>0, a_ij≡0` (Taylor). A **source node**. | Opinion constant. Absorbing state of the dual chain. |
| 2 | **Prejudice / partial stubbornness** | `0 < λ_i < 1` (FJ); `γ_i > 0` (Taylor) | Agent **listens and still re-injects `u_i` at every step**. The genuinely new object. |
| 3 | **Self-confidence / inertia** | `w_ii` large but `< 1` | **NOT stubbornness.** Slows convergence; does not prevent consensus. |
| 4 | **Structural insulation** | agent lies in a closed SCC that receives no outside influence | Unaffected by outsiders, but not necessarily constant. |

> **Terminology warning [T, footnote 17].** Parsegov et al. (2017) use *different* names: their "stubborn" =
> the tutorial's *prejudiced* (notion 2); their "totally stubborn" = the tutorial's *stubborn* (notion 1);
> their "oblivious" = the tutorial's *P-independent*. Since both papers are in this repo, the report **must**
> open the stubbornness chapter with an explicit glossary or the reader will be lost.

Note also that notion 3 (inertia) is what a naïve "make the agent more stubborn by moving weight to the
diagonal" implementation actually produces. It is a legitimate modelling device, but it only becomes
stubbornness **in the limit** `w_ii → 1`. Making that distinction explicit — inertia changes the *rate*,
prejudice changes the *equilibrium* — is one of the clearest teaching points available.

### 7.2 Why averaging models provably cannot capture it

Three equivalent arguments, worth giving all three because each illuminates a different facet:

1. **Convexity / geometric.** A row-stochastic update maps `x` to a point in `conv{x_1..x_n}`. The convex
   hull is nested and non-increasing. On a rooted, aperiodic graph the hull **contracts to a point**. There
   is *no* choice of nonnegative weights summing to one that keeps a strongly connected aperiodic group
   apart. Disagreement can only come from cutting the graph.
2. **Algebraic / invariant-subspace.** `W·1 = 1` always. The consensus manifold `span{1}` is an invariant
   set of *every* row-stochastic model, and it is attractive whenever the graph is rooted and aperiodic.
   To escape it you must destroy either row-stochasticity or connectivity.
3. **Spectral.** `ρ(W) = 1` is always attained with eigenvector `1`. The dynamics is at best marginally
   stable, and its limit operator `W^∞ = 1p_∞ᵀ` is **rank one** — it *cannot* encode individual differences.

**Conclusion:** in the French–DeGroot/Abelson world, persistent disagreement is a *topological accident*
(multiple closed SCCs = the group is really several groups), never a *behavioural property* of individuals.
That is empirically unsatisfying, and it is exactly Abelson's puzzle.

### 7.3 How Friedkin–Johnsen changes the dynamics

FJ makes the map **affine** rather than linear:
```
x(k+1) = ΛW x(k) + (I − Λ) u
```
Consequences, in order of importance:

1. **`ΛW` is substochastic, not stochastic.** `ΛW·1 = Λ·1 ≠ 1`. The consensus manifold is gone.
2. **`ρ(ΛW) < 1`** whenever every agent is P-dependent (Cor. 22). The system is **exponentially stable** with
   a **unique globally attracting equilibrium**, and — remarkably — **more stability means less agreement.**
   The eigenvalue that was pinned at 1, carrying the consensus mode, has been pushed strictly inside the unit
   disc, and with it the possibility of unanimity.
3. **The equilibrium is `x(∞) = V u`, with `V = (I − ΛW)^{-1}(I − Λ)` row-stochastic.** Because `V` is
   row-stochastic, every final opinion lies in `conv{u_1..u_n}`: **disagreement is persistent but bounded.**
   This is the containment property, and it is why FJ produces *cleavage*, not divergence.
4. **`V` is generically full rank**, so each agent retains a personal, permanent trace of its own prejudice.
   Contrast the rank-one `W^∞`.
5. **Memory of the initial condition changes meaning.** With `u` independent of `x(0)`, the limit is
   completely independent of `x(0)` — the group forgets where it started and remembers only what anchors it.
   With `u = x(0)` (Friedkin's own convention), `V` becomes a genuine social-influence operator generalising
   `W^∞`, and `c = n^{-1}Vᵀ1` generalises social power.

### 7.4 Qualitative behaviours that appear (and are worth simulating)

- **Persistent disagreement / community cleavage** on a strongly connected, aperiodic graph — impossible
  under FD.
- **Clustering around stubborn leaders**: with two totally stubborn agents at `±1`, everyone else spreads
  along the interval according to their *relative* graph distance to the two anchors — the electrical
  analogy makes this exact (potentials in a resistor network between two voltage sources).
- **Extreme sensitivity to anchor placement**: a single stubborn agent at a high-centrality node can drag the
  entire group; the same agent at a peripheral node changes almost nothing. Directly measurable via `V` and
  `c` — an excellent experiment on the Krackhardt network.
- **The `α`-sweep transition**: `Λ = αI`, `α: 0 → 1`. `V_α` moves continuously from `I` (frozen at
  prejudices) to `1p_∞ᵀ` (consensus). The spread `max−min` of `x(∞)` is a monotone-ish order parameter for
  cleavage. One figure, whole story.
- **Consensus can still occur** in FJ — but only for special structures. Bullo's E5.24(v) case 1 (below)
  gives `V = [1 0; 1 0]`: a single anchored agent plus a fully open one ⟹ consensus **at the stubborn
  agent's prejudice**. Good counterexample against "FJ always disagrees".
- **PageRank behaviour**: FJ with uniform `Λ = αI` and uniform `u` is literally the damped random surfer.

### 7.5 Analogues in the other models

| Model | Total stubbornness | Partial stubbornness |
|---|---|---|
| French–DeGroot | ✅ `w_ii = 1` (source node / absorbing state) | ❌ **not expressible** |
| Abelson | ✅ `a_ij = 0 ∀j` (source node) | ❌ not expressible |
| Taylor | ✅ `γ_i > 0`, `a_ij ≡ 0`, `u_i = x_i(0)` | ✅ `γ_i > 0` — the continuous-time analogue of `1 − λ_i` |
| Friedkin–Johnsen | ✅ `λ_i = 0` | ✅ `0 < λ_i < 1` — **the model's raison d'être** |

Taylor and FJ are, in this precise sense, **the same idea in the two time domains** — and Taylor got there
first. The comparison `Γ ↔ (I−Λ)/Λ`-style correspondence, checked numerically by comparing steady states
of `−(L+Γ)x + Γu = 0` with `(I − ΛW)x = (I−Λ)u` on matched parameters, is a rewarding exercise.

---

## 8. MATLAB implementation plan (design only — no code in this phase)

### 8.1 Repository layout

```
NDS_Project/
├── setup_paths.m                 % add lib/ and data/ to the path
├── lib/
│   ├── graphs/
│   │   ├── net_from_matrix.m     % build the canonical network struct
│   │   ├── make_ring.m  make_star.m  make_path.m  make_two_communities.m  make_complete.m
│   │   ├── load_krackhardt.m  load_sampson.m
│   │   ├── row_normalize.m       % handles all-zero rows -> self-loop; warns
│   │   └── layout_polygon.m      % deterministic node coordinates for plotting
│   ├── analysis/
│   │   ├── graph_report.m        % SCCs, condensation, closed SCCs, rootedness, period, aperiodicity
│   │   ├── graph_period.m        % gcd-of-cycles via BFS levels (robust); spectral cross-check
│   │   ├── social_power.m        % left Perron vector of W  (FD)
│   │   ├── laplacian_power.m     % left null vector of L    (Abelson)
│   │   ├── fj_matrices.m         % V, influence centrality c, rho(Lambda*W), rank(V)
│   │   ├── taylor_matrices.m     % Hurwitz check, equilibrium, grounded-Laplacian eigenvalue
│   │   └── p_dependence.m        % P-dependent / P-independent classification (shared by Taylor & FJ)
│   ├── models/
│   │   ├── sim_degroot.m
│   │   ├── sim_abelson.m
│   │   ├── sim_taylor.m
│   │   └── sim_friedkin_johnsen.m
│   ├── predict/
│   │   └── predict_limit_*.m     % closed-form steady states, per model
│   └── viz/
│       ├── plot_opinions.m       % trajectories, prejudice lines, stubborn agents highlighted
│       ├── plot_network.m        % digraph plot; node colour = opinion, size = influence
│       ├── plot_spectrum.m       % eigenvalues + unit circle (DT) / imaginary axis (CT)
│       ├── plot_convergence.m    % semilogy spread(k) and ||x(k)-x(inf)||
│       ├── plot_influence_bars.m
│       └── plot_alpha_sweep.m    % FJ: x(inf) vs alpha heatmap
├── data/                         % Krackhardt, Sampson (+ provenance README)
├── livescripts/
│   ├── 00_preliminaries.mlx  01_french_degroot.mlx  02_abelson.mlx
│   ├── 03_taylor.mlx  04_stubbornness.mlx  05_friedkin_johnsen.mlx
│   └── 06_comparative.mlx
├── tests/                        % matlab.unittest or assert-based scripts
└── figures/                      % exported figures for the report
```

`Prove/` is **left untouched and is not used** by the new library.

### 8.2 Canonical data structures

**Network struct** (built once, reused by every model):
```
net.name, net.n, net.labels
net.A        % raw nonnegative weights (row i = who i listens to)  -- used by Abelson/Taylor
net.W        % row-stochastic normalisation of A                   -- used by FD/FJ
net.L        % L = diag(A*ones) - A
net.coords   % n x 2 layout for plotting
net.meta     % source, direction convention, normalisation choice, notes
```
Keeping **both** `A` and `W` is deliberate: Abelson/Taylor do **not** require row-stochasticity (row sums set
the speeds), whereas FD/FJ do. Silently normalising `A` for Abelson would throw away real information —
a modelling decision that must be explicit and recorded in `net.meta`.

**Result struct** (identical shape for all four models, so comparison code is model-agnostic):
```
res.model    % 'degroot' | 'abelson' | 'taylor' | 'fj'
res.t        % 1 x K time vector (k = 0..K-1 for DT, actual times for CT)
res.X        % n x K  (scalar opinions)  -- see note on vector opinions below
res.xinf     % closed-form predicted limit (NaN if none)
res.params   % struct of everything needed to reproduce
res.net      % the network struct used
```

**Vector-opinion readiness (scalar for now, per the user's decision).** Standardise on `n × d × K`
internally with `d = 1` squeezed on output, so that adding vector opinions later is a change of one
`squeeze`/`reshape` layer rather than a rewrite. Every simulator's core loop is written as a matrix product
`X = W*X` which is already dimension-agnostic.

### 8.3 Per-model specification

**French–DeGroot**
- Inputs: `W` (row-stochastic, validated), `x0` (n×1), `K`.
- Update: `x = W*x`. Never form `W^k` for large `k`; iterate.
- Predicted limit: if consensus, `xinf = (p_∞ᵀ x0)·1` with `p_∞` from `null(W'-eye(n))` normalised to sum 1
  (cross-check with `eigs(W',1)`). If convergent but not consensus, compute `W^∞` by iterating to tolerance,
  or block-wise from the condensation.
- Diagnostics: eigenvalues on the unit circle; `|λ₂|`; conserved quantity `p_∞ᵀ x(k)`.

**Abelson**
- Inputs: `A` (nonnegative, **not** normalised), `x0`, time grid `t`.
- Primary integrator: **`expm`** — `X(:,k) = expm(-L*t(k))*x0`. Exact, no step-size tuning, cheap for the
  network sizes here (`n ≤ 21`). Precompute the eigendecomposition or use `expm` on a fixed step and iterate.
- Secondary: `ode45` (or `ode15s` if weights are heterogeneous → stiff) as an independent cross-check.
- Predicted limit: `p_∞` from `null(L')`, normalised; `xinf = (p_∞ᵀ x0)·1` when rooted; otherwise the
  spectral projection `P^∞` computed as `expm(-L*T)` for large `T` and validated against the block structure.
- Extra experiment: Euler `x⁺ = (I − εL)x` with a slider on `ε`, showing (a) agreement with `expm` for small
  `ε`, (b) loss of row-stochasticity and instability past `ε = 1/max_i d_i`.

**Taylor**
- Inputs: `A`, and either `(B, s)` or the reduced `(Γ, u)`. Provide `taylor_reduce(B,s) → (Γ,u)`.
- Dynamics: `ẋ = −(L + Γ)x + Γu` — **note the `Γu`, per §4.1**.
- Integrator: `expm` on the augmented affine system, or `ode45`; both easy since the system is LTI. Exact
  closed form when Hurwitz: `x(t) = e^{-(L+Γ)t}(x0 − x*) + x*`, `x* = (L+Γ)\(Γu)`.
- Predicted limit: `x* = (L+Γ)\(Γ*u)` if all agents P-dependent; otherwise use the block decomposition
  (`p_dependence.m` returns the permutation).
- Diagnostics: `max(real(eig(-(L+Γ))))` < 0; verify `M` is row-stochastic.
- 2D containment demo (deferred; scalar core first): leaders as fixed points, `convhull` of the leader set,
  agents converging inside it.

**Friedkin–Johnsen**
- Inputs: `W`, `Λ` (or a `lambda` vector), `u`, `x0`, `K`.
- Presets for `Λ`: `'identity'` (→ FD), `'classic'` (`Λ = I − diag(W)`), `'uniform'` (`Λ = αI`),
  `'explicit'`. Preset for `u`: `'x0'` (Friedkin's convention) or explicit vector.
- Update: `x = Lambda*W*x + (I−Lambda)*u`.
- Predicted limit: `V = (eye(n) − Lambda*W) \ (eye(n) − Lambda)` — **use backslash, never `inv`** — then
  `xinf = V*u`. Assert `V` row-stochastic and `V ≥ 0`.
- Diagnostics: `ρ(ΛW)`; `rank(V)` and `svd(V)`; influence centrality `c = V'*ones(n,1)/n`; `cond(I − ΛW)`
  with a warning as `α → 1` (see §12.6).

### 8.4 Simulation workflow (one uniform pipeline)

```
1. build network        -> net = make_*(...) / load_*(...)
2. structural analysis  -> graph_report(net)   [SCCs, closed SCCs, rooted?, period, aperiodic?]
3. predict              -> theoretical limit + convergence-rate estimate, BEFORE simulating
4. simulate             -> res = sim_<model>(...)
5. verify               -> assert(norm(res.X(:,end) - res.xinf) < tol)   <-- theory checks simulation
6. visualise            -> trajectories, network, spectrum, convergence, influence bars
7. record               -> save figure + a one-line summary row into a comparison table
```

Step 3-before-step-4 is the discipline that turns this from "plotting curves" into a piece of research: the
theory *predicts*, the simulation *confirms*, and any mismatch is a bug or a misunderstood hypothesis.

### 8.5 Cross-model consistency tests (unit tests **and** numerical proofs of the theory)

These double as the report's "connections between models" evidence:

| Test | Asserts |
|---|---|
| `sim_fj(W, Λ=I, u, x0) == sim_degroot(W, x0)` | FD is the `Λ = I` case |
| `sim_fj` on the augmented graph with `n` virtual stubborn agents `== sim_fj(W,Λ,u,x0)` | the augmentation equivalence |
| `sim_degroot(expm(-τL), x0, K) ≈ sim_abelson(A, x0, τ·(0:K-1))` | Lemma 17 (sampling) |
| `sim_abelson` via `expm` vs `ode45` | integrator independence |
| `(I−εL)` row-stochastic ⟺ `ε·max_i d_i ≤ 1` | Euler step-size condition |
| `V_α → 1p_∞ᵀ` as `α → 1⁻`; `V_0 = I` | Lemma 24 |
| `p_∞ᵀ x(k)` constant in `k` (FD); `p_∞ᵀ x(t)` constant (Abelson) | the conserved functional |
| `V` and `M` row-stochastic and nonnegative | Lemma 7 / Theorems 18, 21 |
| Steady states of Taylor and FJ agree on matched `(Γ, Λ)` | Taylor ↔ FJ correspondence |
| Bullo E5.24(v) exact values (below) | analytic ground truth |
| Tutorial Fig. 4 example: `p_∞ = (2/7, 3/7, 2/7)` | analytic ground truth |
| Tutorial Fig. 6 (`W` from Eq. 24, three `Λ`) reproduced | **published-figure reproduction** |

**Exact hand-checkable FJ values** (derived from Bullo E5.24(v); use as hard-coded test fixtures):
- `W = [1/2 1/2; 1/2 1/2]`, `Λ = diag(1/2, 1)` ⟹ `V = [1 0; 1 0]` — **rank 1 ⟹ consensus**, at agent 1's
  prejudice.
- `W = [1/2 1/2; 1/2 1/2]`, `Λ = diag(1/4, 3/4)` ⟹ `V = [15/16 1/16; 9/16 7/16]` — **rank 2 ⟹ persistent
  disagreement**.

Two 2×2 matrices that make the rank-one-vs-full-rank point exactly, with no numerics. Put them in the report.

### 8.6 Visualisation catalogue

1. **Opinion trajectories** `x_i` vs `k`/`t`. Colour by faction or by `λ_i`; dashed horizontal lines at
   `u_i`; stubborn agents drawn thick. This is the workhorse figure and mirrors the tutorial's Fig. 6.
2. **Network plot** (`plot(digraph(...))` with fixed `XData/YData`): node fill = current/final opinion
   (diverging colormap), node size = social power / influence centrality, edge width = weight. Animatable.
3. **Spectrum plot**: eigenvalues in the complex plane with the unit circle (FD/FJ) or the imaginary axis
   (Abelson/Taylor) overlaid. One figure that makes every convergence theorem *visible* — periodicity shows
   up as evenly spaced points on the unit circle; FJ's stability shows up as everything pulled inside.
4. **Convergence diagnostics**: `semilogy` of spread `max−min` and of `‖x(k) − x(∞)‖`, with the predicted
   slope (`|λ₂|`, `ρ(ΛW)`, `Re λ₂(L)`) overlaid as a reference line.
5. **Influence bar chart**: `p_∞` (FD) and `c` (FJ) side by side; scatter against in-degree and eigenvector
   centrality to show they are *not* the same thing.
6. **FJ `α`-sweep heatmap**: `x_i(∞)` (rows = agents) vs `α ∈ (0,1)` — the consensus↔frozen transition.
7. **Final-opinion histogram / kernel density**: shows **bimodality** directly. This is the figure that
   literally answers Abelson's puzzle and belongs in the comparative chapter.
8. *(Deferred, vector opinions)* 2D containment plot for Taylor: leaders, `convhull`, agent trajectories.

---

## 9. Simulation scenarios — assessment of the proposed networks

### 9.1 Verdict on the four proposed

**① Directed ring without self-loops — KEEP, it is the sharpest example in the set.**
Be precise about *which* ring, because there are three and they behave differently:
- **Pure directed cycle** (`w_{i,i-1} = 1`): `W` is a permutation matrix. Strongly connected, **period `n`**,
  doubly stochastic. **Never converges** — the opinion vector rotates forever. This is the textbook
  demonstration that *strong connectivity is not sufficient*: it isolates aperiodicity as an independent
  hypothesis (Lemma 11 / Theorem 12).
- **Symmetric ring**, each agent averaging its two neighbours, no self-loop: **period 2 when `n` is even**
  (bipartite) ⟹ oscillation; **aperiodic when `n` is odd** ⟹ average consensus. Convergence depends on the
  **parity of `n`** — a memorable, easily demonstrated fact.
- **Lazy ring** (add self-loops): always converges; doubly stochastic ⟹ **average consensus**.

  Best use: the **discrete-vs-continuous contrast**. Run the same ring under French–DeGroot (oscillates) and
  under Abelson (converges, always). Nothing else in the project makes the "periodicity is a discrete-time
  artefact" point so cleanly. Bonus: the circulant Laplacian has closed-form eigenvalues `1 − e^{2πik/n}`, so
  the convergence rate can be predicted analytically and checked — good for a rate subsection.

**② Star network — KEEP, and use it as the influence/stubbornness laboratory.**
Direction is everything:
- **Leaves listen to the hub only**: the hub is a source ⟹ a stubborn root ⟹ consensus at the hub's opinion;
  `p_∞ = e_hub`. Maximal centralisation.
- **Bidirectional star, no self-loops**: strongly connected but **period 2** ⟹ oscillation. Another crisp
  periodicity case, and one students never expect.
- **With self-loops**: converges; `p_∞` computable in closed form and heavily concentrated on the hub.

  Best use: (a) social power / centrality (FD); (b) **stubborn-agent placement** (FJ) — stubborn hub vs.
  stubborn leaf produces dramatically different `V` and `c`. This is the cleanest possible illustration of
  §7.4's sensitivity point.

**③ Krackhardt Advice Network — KEEP. Strongest real-data choice, and already in your library.**
21 managers in a manufacturing firm; directed binary "who seeks advice from whom" (Krackhardt, 1987); it is
**Figure 5.5 of `LecturesNetworkSystems-FB.pdf`**, with Bullo's note that it is **reducible but has an
aperiodic subgraph of globally reachable nodes** — so `1` is a **simple, strictly dominant** eigenvalue and
the averaging system reaches consensus, with social power visualised as node shading.
- Why interesting: real, empirically observed, and it exhibits exactly the non-trivial case — **rooted but
  not strongly connected**. Some managers have **zero social power** (they are not globally reachable) — an
  interpretable, striking result you cannot get from a toy graph.
- Best for: French–DeGroot social power; FJ influence centrality on real data; the stubborn-placement
  experiment (rank managers by `Δ` in group mean opinion when made stubborn).
- Caveats to document: the raw data are **binary**, so row-normalisation implicitly assumes each manager
  splits trust equally among advisors (`w_ij = 1/outdeg(i)`) — that is a *modelling choice*, and it should
  be stated. Also, **watch the direction convention** (Bullo's edge `(i,j)` = "i seeks advice from j" = the
  project's `W(i,j) > 0`, so **no transpose needed** under the project convention — but verify against the
  published social-power ranking before trusting it).

> **UPDATE (Phase 2 — resolved).** The data is now **in hand and cross-validated**: recovered from
> Krackhardt (1987) Appendix A, p. 129, saved to `data/krackhardt_advice_LAS.txt`, and checked against
> Sims & Gilles (2014) Table 4 (all 42 degree constraints match). The direction convention is confirmed —
> **no transpose**. Verified properties: 5 SCCs, exactly one closed and aperiodic ⟹ rooted ⟹ consensus;
> reducible with simple dominant eigenvalue 1; every row non-empty (no zero-row handling needed);
> **managers 6, 13, 16, 17 have social power exactly zero**. See `02_literature_review.md` §4.1 and §7.
> Two new experiments attach to this dataset: the **three-way importance comparison** (social power vs.
> betweenness/Bonacich vs. middleman power) and **anchor placement** (§6.2 there). Note also that
> "the Krackhardt network" is an *aggregation choice* — Appendix A also prints the Consensus structure and
> three individual slices, enabling an optional sensitivity study.

**④ Sampson Monastery — KEEP, with an explicit caveat and a narrowed scope.**
18 novices in a New England monastery (Sampson, 1968); sociometric rankings on **four relations**
(affect/esteem, influence, praise, and their negatives) at **three time points**, with a well-known split
into factions (Young Turks / Loyal Opposition / Outcasts).
- Why interesting: the only dataset here with **genuine community structure**, and it therefore speaks
  directly to the **open problem the tutorial itself names in its conclusion** — the relation between opinion
  behaviour and the community/module structure of the graph.
- **Caveat:** its fame comes from **signed** relations and **structural balance**, which is the subject of
  Part II (Altafini). All four models in this project require **nonnegative** weights. You must therefore
  pick one positive relation and one time slice (recommended: *liking/esteem*, time T3, "top-3 choices"
  version) and **document the choice explicitly**. The signed version should be flagged as a natural Part II
  extension, not silently dropped.
- Best for: Abelson block-consensus when the positive graph is not rooted; FJ cleavage that follows faction
  lines; the community-structure open question.

> **UPDATE (Phase 2 — scope now fixed, data still to obtain).** The primary source confirms **four
> relations** (affective, esteem, influence, sanction) × **five waves**, weights **−3…+3** derived from
> three ranked choices in each direction. **Decision: use the positive part of the affective relation at
> T₄, 18-member group** — the last pre-collapse wave, where the faction structure is sharpest.
> **Do not extract from `sampson1968.pdf`**: its matrices are hand-drawn sociograms, not numeric tables.
> Take the data from the Pajek/ESNA encoding (see `data/README.md`). Two caveats discovered only in the
> dissertation and to be stated in the report: the waves are **partly retrospective recall**, and the
> negative pole is the euphemism "liked least", not "disliked". Talaga et al. (2023) supply a
> frustration-minimising partition to compare our clustering against.

### 9.2 Networks that should be added — and why

I would add four, in this priority order. The first two I consider **necessary**, not optional.

**(a) Tiny analytic fixtures (`n = 2, 3, 4`) — NECESSARY, build these first.**
Nothing validates an implementation like a case with a known exact answer.
- The tutorial's Fig. 4 French example (`n = 3`), whose social power is exactly `p_∞ = (2/7, 3/7, 2/7)`.
- The **Friedkin–Johnsen `n = 4` matrix (Eq. 24)** with `u = x(0) = [−1, −0.2, 0.6, 1]ᵀ` and the three
  susceptibility matrices `Λ = I`, `Λ = I − diag(W)`, `Λ = diag(1,0,0,1)`, which reproduce the tutorial's
  **Fig. 6(a)(b)(c)**: consensus, visible cleavage, and two stubborn agents with the rest trapped between
  them. **Reproducing a published figure is the single strongest validation available** — make it the first
  milestone.
- Bullo's two 2×2 FJ cases with exact `V` (§8.5).

**(b) Two weakly coupled communities ("two-cluster" / caveman graph) — NECESSARY.**
Two dense blocks joined by one or two thin bridges, with a tunable coupling strength `β`.
- Why: it is the **minimal structure that separates consensus from cleavage**, and the *only* way to exhibit
  the community cleavage problem in the averaging models. With `β = 0` you get two closed SCCs ⟹ block
  consensus (Abelson/FD); with `β > 0` you get consensus but with a **timescale separation** (fast within
  blocks, slow between) — visible as a plateau in the trajectory plot and as a small `|λ₂|` gap.
- Payoff: sweeping `β` and, separately, sweeping FJ's `α`, shows that **stubbornness and weak coupling
  produce visually similar cleavage but are mathematically different** (transient plateau vs. genuine
  equilibrium disagreement). That distinction is a genuinely interesting result to report and is exactly the
  kind of thing a comparative study should surface.

**(c) Directed path / chain — cheap and instructive.**
The minimal *rooted but not strongly connected* graph. The source dictates the outcome; `p_∞ = e_1`;
convergence is slow (`O(n²)` mixing). Excellent for the "influence propagates but does not return" intuition
and as a Taylor/FJ testbed (anchor at the head vs. the tail ⟹ completely different `V`).

**(d) Complete graph — control case.**
Everything converges in one step under uniform weights. Useful precisely because it **removes topology as a
variable**, isolating the effect of `Λ` alone. Recommended as the baseline in the FJ chapter.

*(Optional, if time allows: Erdős–Rényi random digraphs with a sweep on edge probability, to get statistics
on rootedness and convergence rate rather than anecdotes. Good for a quantitative appendix; not essential.)*

### 9.3 Scenario × model coverage matrix

| Network | FD | Abelson | Taylor | FJ | Primary point it makes |
|---|:--:|:--:|:--:|:--:|---|
| Tiny fixtures (n=2,3,4) | ✅ | ✅ | ✅ | ✅ | **validation against exact/published results** |
| Directed cycle | ✅ | ✅ | ○ | ○ | periodicity; discrete vs. continuous |
| Symmetric ring (n even/odd) | ✅ | ✅ | ○ | ○ | aperiodicity depends on parity; average consensus |
| Star | ✅ | ○ | ✅ | ✅ | centralisation; social power; anchor placement |
| Directed path | ✅ | ✅ | ✅ | ✅ | rooted ≠ strongly connected; slow mixing |
| Two communities | ✅ | ✅ | ✅ | ✅ | **cleavage: topological vs. behavioural** |
| Complete graph | ✅ | ○ | ○ | ✅ | isolates the effect of `Λ` |
| Krackhardt (n=21) | ✅ | ✅ | ✅ | ✅ | **real data**; zero-power nodes; stubborn placement |
| Sampson (n=18) | ✅ | ✅ | ○ | ✅ | **community structure**; faction-aligned cleavage |

---

## 10. Proposed report / project structure

Your draft ordering is good; I propose **one substantive change** and one reframing.

**Change: move "Stubbornness" *before* Taylor, not between Taylor and FJ.** In your draft (…6. Taylor,
7. Stubbornness, 8. FJ), Taylor is presented *before* stubbornness is defined — but Taylor's `γ_i` **is**
partial stubbornness. The reader meets the mechanism before the concept. Putting the theory chapter first
makes both Taylor and FJ read as *answers* to a question already posed.

**Reframing: state Abelson's diversity puzzle as the report's driving question at the very start**, and make
every subsequent chapter an attempt to answer it. This turns a survey into an argument.

```
 1. Introduction and motivation
    — the community cleavage problem stated up front as the driving question
 2. Preliminaries
    2.1 Digraphs, reachability, SCCs, condensation, roots, periodicity
    2.2 Nonnegative matrices: Perron-Frobenius, irreducibility, primitivity
    2.3 Stochastic and substochastic matrices
    2.4 M-matrices, Lemma 7, the Laplacian    <-- flagged as the unifying tool
    2.5 Notation and the DIRECTION CONVENTION (fixed once, used everywhere)
 3. French-DeGroot
    history / model / convergence vs consensus / graph criteria /
    Markov duality / social power and centrality / stubborn agents as sources
 4. Abelson
    continuous-time limit / always convergent / rootedness criterion /
    sampling bridge (Lemma 17) and Euler / THE DIVERSITY PUZZLE stated formally
 5. Stubbornness: theory                       <-- MOVED UP; the pivot of the report
    5.1 Glossary: four notions, with the cross-paper terminology warning
    5.2 Three proofs that averaging cannot produce persistent disagreement
    5.3 What must be broken: affine dynamics and substochasticity
 6. Taylor — the continuous-time answer
    sources and persuasibility / reduction to prejudices / P-dependence /
    grounded Laplacian and Hurwitz stability / containment control and leaders
 7. Friedkin-Johnsen — the discrete-time answer
    model and the two conventions / Schur stability / V and its row-stochasticity /
    rank-one vs full-rank / influence centrality / PageRank / game-theoretic reading /
    empirical validation
 8. A unified view
    the 2x2 table / M-matrix thread / limits and equivalences /
    convergence rates / what this model family CANNOT do
 9. MATLAB architecture
    data structures / API / numerical choices / testing strategy
10. Simulation campaign
    10.1 Validation against exact and published results
    10.2 Synthetic topologies (ring, star, path, two communities, complete)
    10.3 Real networks (Krackhardt, Sampson)
    10.4 The stubbornness experiments (alpha-sweep, anchor placement, Taylor<->FJ)
11. Comparative analysis and discussion
12. Open questions and future work (Part II and beyond)
13. Conclusions
```

Chapters 1–8 map onto `livescripts/00–06`; chapters 9–11 onto `06_comparative.mlx` plus the figures folder.

---

## 11. Pitfalls to anticipate

1. **Direction convention (the big one).** Tutorial arrows = influence flow (`arc (i,j) ⟺ a_ji > 0`); Bullo's
   arrows = "seeks advice from" (`a_ij > 0`). The **matrix is the same**; only the picture flips. Fix the
   convention once (§1.1), write it in `net.meta`, and add an assertion helper. Every reachability
   computation (roots, closed SCCs, P-dependence) must be done in the *stated* graph, and reversing it
   silently gives plausible-looking but wrong answers.
2. **Taylor Eq. (15) vs. (18).** The paper's matrix form omits `Γ`; the correct input term is `Γu` (§4.1).
3. **Terminology collision** between the tutorial and Parsegov et al. (§7.1) — both PDFs are in the repo.
4. **Assuming Abelson polarises.** It does not, on a rooted graph (§3.3).
5. **Assuming strong connectivity ⟹ consensus in discrete time.** Aperiodicity is an *independent*
   hypothesis; the directed cycle is the counterexample.
6. **Numerical conditioning.** `(I − ΛW)` becomes ill-conditioned as `α → 1⁻`. Always `\`, never `inv`;
   monitor `cond` and warn. Similarly, near-zero rows in real data.
7. **Row normalisation of real data** destroys information and imposes `w_ij = 1/outdeg(i)`. Handle all-zero
   rows (isolated nodes) by setting `w_ii = 1` — and note that this *creates a stubborn agent*, which changes
   the dynamics. Never do it silently.
8. **Euler step size** for Abelson/Taylor: `ε·max_i (Σ_j a_ij) < 1`, else stochasticity and stability fail.
9. **Detecting periodicity numerically** is tolerance-sensitive. Prefer the graph-theoretic gcd-of-cycles
   computation, and use the spectral count only as a cross-check.
10. **`u = x(0)` vs. independent `u`** completely changes the interpretation of `V` (social-influence
    operator vs. a map from external prejudices). Make it an explicit, logged option.
11. **Sampson data**: multiple relations, multiple time points, signed. Document exactly which slice is used
    and why; do not average across relations without justification.
12. **Reproducibility**: `rng(seed)` for any randomised topology; save `res.params` with every figure.

---

## 12. Open questions and recommended future reading

### 12.1 Corrections to the source itself
- **Corrigendum (Annual Reviews in Control 52, 2021, p. 602)**, bound at the end of the Part I PDF: the
  statements of **Lemma 2** and **Corollary 6** are missing the hypothesis that a **strictly positive
  Perron eigenvector** exists (`Av = ρ(A)v`, `v > 0`). Other results are unaffected — Lemma 8 and Lemma 9
  follow by applying them to matrices that do satisfy it. **Cite the corrigendum in the preliminaries
  chapter**; noticing it is itself worth a remark in the report.

### 12.2 Results the tutorial mentions only in passing — recommended reading
- **Convergence rates.** Olshevsky & Tsitsiklis (2011); Cao, Morse & Anderson (2008b); Ghaderi & Srikant
  (2014). SLEM, spectral gap, Cheeger bounds.
- **Grounded Laplacians.** Pirani & Sundaram (2016), *On the smallest eigenvalue of grounded Laplacian
  matrices* — the sharp rate for Taylor/FJ.
- **Forest/tree theory of the Laplacian.** Chebotarev & Agaev (2002, 2014) — the combinatorial formula for
  `P^∞` and for `p_∞` (Markov chain tree theorem), which explains *why* social power has the value it has.
- **Game-theoretic and electrical readings of FJ.** Bindel, Kleinberg & Oren (2011) — price of anarchy;
  Ghaderi & Srikant (2014) — resistive-network interpretation. Both give strong intuition for stubbornness.
- **Social power and PageRank.** Friedkin (1991); Friedkin & Johnsen (2014); Ishii & Tempo (2014).

### 12.3 Natural extensions (Part II and beyond)
- **Time-varying graphs**: joint/uniform connectivity, products of SIA matrices (Part II §3).
- **Bounded confidence**: Hegselmann–Krause and Deffuant–Weisbuch (Part II §4) — the *second* answer to
  Abelson's puzzle, producing clustering endogenously from opinion-dependent topology.
- **Antagonistic interactions**: Altafini (2012, 2013), structural balance, **bipartite consensus /
  polarization** (Part II §6). This is where the Sampson signed data belongs, and it is the only mechanism
  in the family that can push opinions *outside* the initial convex hull.
- **Reflected appraisal / DeGroot–Friedkin**: Friedkin, Jia & Bullo (2016) — social power *evolving* across a
  sequence of issues.
- **Multidimensional FJ with topic coupling** `C`: Parsegov et al. (2017), already in the repo.
- **Gossip / asynchronous randomised FJ**: Frasca, Ravazzi, Tempo & Ishii.

### 12.4 Genuinely open questions worth stating in the conclusions
- **The tutorial's own stated open problem**: the relation between opinion behaviour and the **community /
  module structure** of the influence graph. Directly addressable with the two-community and Sampson
  scenarios — a legitimate, small original contribution for this project.
- **Identification**: how are `W`, `Λ` and `u` estimated from data? The tutorial notes that experimental
  validation across the field is scarce (FJ being the exception). What data would be needed?
- **Control-theoretic question**: given a budget, *which* agents should be made stubborn / which should be
  targeted by media, to steer the group mean to a target? (Leader/actuator selection; not covered by the
  tutorial, and a natural extension of Taylor's containment reading.)
- **Scalability**: convergence-rate scaling and algorithmic testing of the graph conditions on large graphs.

---

## 13. Verification plan for this phase

Since this phase produces analysis, not code, "verification" means checking the analysis against the sources
before implementation begins:

1. Re-read Part I §§3–6 with this document side by side and confirm every theorem number cited here
   (Lemmas 2, 5, 7–11, 17, 24; Theorems 3, 12, 16, 18, 20, 21; Corollaries 4, 6, 13–15, 19, 22, 23).
2. Confirm the Taylor `Γu` reading (§4.1) by checking Eq. (14) → Eq. (15) → Eq. (18) consistency directly in
   the PDF, and note the discrepancy in the report.
3. Confirm the direction convention by re-reading Def. 2 in Part I and the Fig. 5.5 caption in Bullo.
4. Confirm the corrigendum's scope (Lemma 2 and Corollary 6 only).
5. ~~Locate and record provenance for the Krackhardt and Sampson data files~~ — **DONE (Phase 2).**
   Krackhardt recovered, cross-validated and committed to `data/`; Sampson provenance documented and the
   slice to use decided (still to be downloaded). See `data/README.md` and `02_literature_review.md`.

**First implementation milestone once this plan is approved:** reproduce the tutorial's **Fig. 6** (the
`n = 4` Friedkin–Johnsen example with three susceptibility matrices) and the Bullo `2×2` exact `V` values.
If those match, the core of the library is correct and everything else is scaling up.
