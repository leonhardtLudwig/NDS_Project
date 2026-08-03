# Opinion Dynamics in Social Networks

A MATLAB library and set of Live Scripts implementing and comparing four classical models of
opinion formation: **French–DeGroot**, **Abelson**, **Taylor** and **Friedkin–Johnsen**.

The project follows Proskurnikov & Tempo, *A tutorial on modeling and analysis of dynamic social
networks, Part I* (Annual Reviews in Control 43, 2017), with a particular focus on **stubbornness**
and on what the Friedkin–Johnsen model captures that pure averaging cannot.

## Quick start

```bash
matlab -batch "setup_paths; run_all_tests"
```

In the MATLAB desktop, from the project root:

```matlab
setup_paths;                 % once per session
open(fullfile('livescripts','ch00_preliminaries.mlx'))
```

A first taste:

```matlab
setup_paths;
[net, u, x0] = make_example_fj4();          % Friedkin & Johnsen's 4-agent network
lambda = fj_lambda(net, 'classic');          % susceptibility = 1 - diag(W)
res = sim_friedkin_johnsen(net, lambda, u, x0, 15);
plot_opinions(res, 'Prejudice', u, 'Highlight', 3);
```

## The four models

|  | **No anchoring** (linear, marginally stable) | **With anchoring** (affine, exponentially stable) |
|---|---|---|
| **Discrete time** | French–DeGroot `x⁺ = Wx` | Friedkin–Johnsen `x⁺ = ΛWx + (I−Λ)u` |
| **Continuous time** | Abelson `ẋ = −Lx` | Taylor `ẋ = −(L+Γ)x + Γu` |

Moving down the table is time discretisation: it only removes the periodicity obstruction.
Moving right is anchoring: the governing M-matrix goes from singular to nonsingular, marginal
stability becomes exponential, and the limit operator goes from **rank one** (consensus) to
**full rank** (persistent disagreement).

## Layout

```
setup_paths.m            put the library on the MATLAB path
lib/
  util/                  validation, option parsing, result packing
  graphs/                network construction, generators, dataset loaders
  analysis/              strong components, periodicity, social power, V and Γ matrices
  models/                the four simulators
  predict/               closed-form limits, used to check every simulation
  viz/                   plotting
livescripts/             ch00..ch06 Live Scripts (.mlx)
  src/                   their .m sources -- edit these
tests/                   65-case test suite
tools/                   build/run helpers for the notebooks
data/                    datasets, with provenance in data/README.md
docs/                    the written analysis
figures/                 generated output
```

## The direction convention

Fixed once, everywhere:

> **`W(i,j) > 0` means agent *i* accords weight to agent *j*.** Row *i* lists whom agent *i*
> listens to, which is why the **rows** sum to one.

`digraph(W)` is the *listening* graph; `digraph(W')` is the *influence* graph, matching the arrows
in Proskurnikov & Tempo. **The matrix is the same in both books — only the drawn arrows differ.**
This is the single most common source of silent errors in this literature, so `plot_network` takes
a `'Direction'` option rather than ever transposing the data.

## Conventions in the code

- Every simulator returns the **same result structure** (`res.model`, `res.t`, `res.X`, `res.xinf`,
  `res.params`, `res.net`), so comparison and plotting code is model-agnostic.
- Every simulator also reports the **theoretically predicted limit**, so *theory predicts,
  simulation confirms* is the default workflow rather than an extra step.
- Networks carry their **provenance** in `net.meta` — source, relation, time point, aggregation,
  normalisation. This is not bookkeeping: the Krackhardt network depends on which cognitive
  aggregation was used, and the Sampson network on which relation and wave were selected.
- Opinions are stored internally as `n × d × K` and squeezed to `n × K` for the scalar case, so
  vector-valued opinions can be enabled later without rewriting the models.
- **Base MATLAB only** — no toolboxes. (`pearson_correlation` wraps `corrcoef` for exactly this
  reason: `corr` belongs to the Statistics Toolbox.)

## Validation

The suite runs 65 cases in five files. Beyond ordinary unit tests it locks the library to results
that exist independently of this codebase:

| Fixture | Source |
|---|---|
| social power = `[2/7, 3/7, 2/7]` | tutorial Example 1 / Fig. 4 |
| Figure 6(a)(b)(c) reproduced | tutorial Fig. 6 (Friedkin & Johnsen 1999 data) |
| `V = [1 0; 1 0]` and `V = [15/16 1/16; 9/16 7/16]` | Bullo, *Lectures on Network Systems*, E5.24(v) |
| all 42 Krackhardt degree constraints | Sims & Gilles (2014), Table 4 |

`tests/test_crossmodel.m` additionally verifies the theoretical relationships numerically — FJ with
Λ = I *is* French–DeGroot, FJ equals DeGroot on the augmented stubborn graph, sampling the Abelson
flow yields a DeGroot model (Lemma 17), `V_α → 1p'` as `α → 1` (Lemma 24), and Taylor and FJ agree
when `λᵢ = 1/(1+γᵢ)`.

```bash
matlab -batch "setup_paths; run_all_tests"          # 65 tests
matlab -batch "setup_paths; run_livescripts"        # notebooks as integration tests
```

## Notebooks

`livescripts/src/*.m` are the **source of truth**: readable, diffable, and runnable as ordinary
scripts. The `.mlx` files one level up are generated from them:

```matlab
build_livescripts('Force', true);
```

Edit the `.m` and rebuild — editing the `.mlx` directly loses the change on the next build.

Two MATLAB constraints shape this layout, and both were hit during development:
- filenames start with `ch` because MATLAB cannot run a script whose name begins with a digit;
- source and generated output live in **different folders** because a `.mlx` takes precedence over
  a same-named `.m`, which would make the source unrunnable.

| Notebook | Contents |
|---|---|
| `ch00_preliminaries` | conventions, graph structure, the standard topologies, spectra |
| `ch01_french_degroot` | consensus vs convergence, social power, Krackhardt |
| `ch02_abelson` | Laplacian flow, sampling, Euler step size, the diversity puzzle |
| `ch03_taylor` | sources and prejudices, P-dependence, grounded Laplacian, containment |
| `ch04_stubbornness` | the four notions, why averaging cannot express it, the α-sweep |
| `ch05_friedkin_johnsen` | Fig. 6 reproduction, `V` and its rank, PageRank, anchor placement |
| `ch06_comparative` | the 2×2 table, equivalences, cleavage mechanisms, three-way importance |

## Data

`data/krackhardt_advice_LAS.txt` — 21 managers, recovered from Krackhardt (1987) Appendix A p. 129
and cross-validated against Sims & Gilles (2014) Table 4. See `data/README.md` for provenance and
for why the Sampson matrices must **not** be extracted from the dissertation PDF.

## Documentation

- `docs/01_technical_analysis.md` — model-by-model analysis and the implementation roadmap
- `docs/02_literature_review.md` — primary sources, datasets, and what they settle

## Requirements

MATLAB R2019b or later (developed and verified on R2025b). No toolboxes.
