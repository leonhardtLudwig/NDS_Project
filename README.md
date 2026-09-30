# Opinion Dynamics in Social Networks

A small MATLAB library supporting a study of four classical opinion-formation models —
**French–DeGroot**, **Abelson**, **Taylor** and **Friedkin–Johnsen** — following Proskurnikov &
Tempo, *A tutorial on modeling and analysis of dynamic social networks, Part I*.

## Design philosophy

The library exists to support a **theoretical exposition**, not to be a framework. Every function is
small, does one thing, and takes the mathematical object itself as its argument:

> **Matrices in, matrices out.** If the theory defines an influence matrix `W`, then `W` appears
> explicitly in the code. Nothing is hidden inside a wrapper object.

So a notebook section reads the way the mathematics does:

```matlab
W = [1/2 1/2   0                    % the influence matrix, Example 1.3
     1/3 1/3 1/3
       0 1/2 1/2];

plot_graph(W)                        % the sociogram
p = social_power(W)                  % solve  p' = p'W,  p'1 = 1   ->  [2/7 3/7 2/7]

x0 = [3; -1; 5];
X  = sim_degroot(W, x0, 30);         % x(k+1) = W x(k)
plot_opinions(X)

p' * x0                              % the consensus value predicted by theory
```

## Quick start

```bash
matlab -batch "setup_paths; run_all_tests"
```

In the MATLAB desktop, from the project root: `setup_paths` once per session.

## The API

**`lib/matrices`** — build the matrices the models act on

| | |
|---|---|
| `row_stochastic(A)` | `W = D⁻¹A` |
| `laplacian(A)` | `L = diag(A·1) − A` |
| `is_row_stochastic(W)` | predicate |
| `ring_graph(n[,s])` `star_graph(n[,type])` `path_graph(n)` `complete_graph(n)` `two_communities(n1,n2,β)` | standard topologies, returned as plain adjacency matrices |

**`lib/models`** — one function per update equation, returning the trajectory matrix

| | |
|---|---|
| `X = sim_degroot(W, x0, K)` | `x(k+1) = W x(k)` |
| `X = sim_abelson(A, x0, t)` | `ẋ = −L x` |
| `X = sim_taylor(A, gamma, u, x0, t)` | `ẋ = −(L+Γ)x + Γu` |
| `X = sim_friedkin_johnsen(W, lambda, u, x0, K)` | `x(k+1) = ΛWx(k) + (I−Λ)u` |

`X` is `n × (K+1)` for the discrete models and `n × numel(t)` for the continuous ones; column `k+1`
is `x(k)`. Pass an `n × m` initial condition to `sim_degroot` for vector opinions.

**`lib/analysis`** — each function is one formula

| | |
|---|---|
| `social_power(W)` | `p' = p'W`, `p'1 = 1` |
| `limit_matrix(W)` | `W^∞ = lim Wᵏ` |
| `total_influence(W, lambda)` | `V = (I − ΛW)⁻¹(I − Λ)` |
| `fj_equilibrium(W, lambda, u)` | `x(∞) = Vu` |
| `taylor_equilibrium(A, gamma, u)` | `(L+Γ)x = Γu` |
| `graph_summary(A)` | components, closedness, periods, rootedness, consensus |
| `strong_components(A)`, `graph_period(A[,nodes])` | the pieces `graph_summary` is built from |
| `prejudice_reach(A, anchored)` | which agents a prejudice reaches |

**`lib/data`** — `load_krackhardt`, `load_sampson`, `example_french3`, `example_fj4`,
`krackhardt_benchmarks`. Loaders return the **raw matrix**, so the modelling choice stays in the
notebook:

```matlab
[S, names] = load_sampson();         % the signed matrix, -3..+3
W = row_stochastic(max(S, 0));       % "positive pole", written out where it can be read
```

**`lib/viz`** — `plot_graph`, `plot_opinions`, `plot_convergence`, `plot_spectrum`, `plot_bars`.
All take matrices and draw into the current axes, so they compose with `subplot` and `tiledlayout`.

Every figure is built to be **self-explanatory**, because in a notebook with ten matrices and ten
graphs the reader must never have to guess which is which:

- **the title is the caller's variable name** (via `inputname`), so `plot_graph(W_ring)` is titled
  `W_ring` — ten matrices give ten distinguishable figures, with no extra effort;
- **`plot_graph` prints the numeric edge weights** and draws **self-loops**, so the picture can be
  checked against the matrix defined just above it. `w_ii` is not decoration: it decides
  stubbornness and aperiodicity. Weights are auto-suppressed past 40 edges, and the caption says so;
- **captions state the facts that matter**: agents/edges/row-stochastic and the arrow convention for
  graphs; final spread for trajectories; spectral radius, second-largest modulus and *the period*
  for spectra — a periodic graph's caption reads `PERIODIC (period 5): opinions oscillate`;
- **`plot_opinions` puts each agent's final value in the legend** (`1 -> 1.857`) and can overlay the
  theoretically predicted limit as dashed lines, so "theory predicts, simulation confirms" is
  visible rather than asserted;
- **`plot_bars` prints the values on the bars.**

Every plot function **resets the axes before drawing** (unless you have issued `hold on`), so
consecutive calls in a notebook never overlay — a graph followed by a trajectory plot gives two
clean figures, not one corrupted one.

**Titles and subtitles are yours whenever you want them.** Every plot function follows one
convention:

```matlab
plot_graph(W)                                                      % automatic
plot_graph(W, [], 'Title', 'Example 1.3', 'Subtitle', 'matrix W')  % your own
plot_graph(W, [], 'Title', '',            'Subtitle', '')          % none at all

plot_opinions(X)                                                   % same everywhere
plot_opinions(X, [], 'Title', 'Example 1.3', 'Subtitle', 'x(k+1) = Wx(k)')
```

`[]` (the default) keeps the automatic text, a string replaces it, `''` removes it. You can equally
ignore the options and call `title(...)` / `subtitle(...)` yourself after the plot.

See each function's help for the full option list.

**`lib/internal`** — three input checks and `project_root`. No mathematics.

## Conventions

> **`W(i,j) > 0` means agent *i* accords weight to agent *j*.** Row *i* lists whom *i* listens to,
> which is why the **rows** sum to one.

`digraph(W)` is the *listening* graph; `digraph(W')` points along the *flow of influence*, matching
the figures in Proskurnikov & Tempo. **The matrix is the same in both books — only the arrows
differ.** `plot_graph(W')` is all it takes to switch.

Base MATLAB only — no toolboxes.

## Validation

55 tests. Beyond ordinary unit tests they lock the library to results that exist independently of it:

| Fixture | Source |
|---|---|
| social power `[2/7, 3/7, 2/7]` | tutorial Example 1.3 / Fig. 4 |
| Figure 6(a)(b)(c) | tutorial Fig. 6 (Friedkin & Johnsen 1999 data) |
| `V = [1 0; 1 0]`, `V = [15/16 1/16; 9/16 7/16]` | Bullo, *Lectures on Network Systems*, E5.24(v) |
| 42 Krackhardt degree constraints | Sims & Gilles (2014), Table 4 |
| 54 Sampson column totals | Sampson (1968), Table D₁₃, p. 469 |

`tests/test_crossmodel.m` additionally verifies the theoretical relationships numerically — FJ with
Λ = I *is* French–DeGroot, FJ equals DeGroot on the augmented stubborn graph, sampling the Abelson
flow yields a DeGroot model, `V_α → 1p'` as `α → 1`, and Taylor and FJ agree when `λᵢ = 1/(1+γᵢ)`.

## Layout

```
setup_paths.m       put the library on the path
lib/                matrices · models · analysis · data · viz · internal   (39 functions)
livescripts/        working notebooks — authored directly, not generated
claude_livescripts/ earlier draft notebooks, kept as references
tests/              55 cases
data/               datasets, with provenance in data/README.md
docs/               written analysis
```

## Documentation

- `docs/01_technical_analysis.md` — model-by-model analysis and roadmap
- `docs/02_literature_review.md` — primary sources and datasets
- `data/README.md` — dataset provenance and checksums

## Requirements

MATLAB R2020b or later (developed and verified on R2025b). No toolboxes.
R2020b is required only for `subtitle`, used to caption every figure.
