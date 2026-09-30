# Library redesign — what changed and how to update the notebooks

**2026-08-06.** The supporting functions were rewritten around one rule: *the mathematical object is
the argument*. Wrapper structs (`net`, `res`) are gone, so the matrices from the theory now appear
explicitly in the notebook. See `README.md` for the full API.

Only `ch00_preliminaries` and `ch01_fdg` contain calls that need updating; the other notebooks are
still scaffolding.

## `ch01_fdg`, section 1.3 (Dual Markov chain and social power)

```matlab
% ---- before ----                          % ---- after ----
net = make_example_french3();               W = [1/2 1/2   0
p   = social_power(net);                         1/3 1/3 1/3
                                                   0 1/2 1/2];
x0  = [3; -1; 5];
res = sim_degroot(net, x0, 30);             p  = social_power(W);       % p' = p'W, p'1 = 1
res.xinf(1)                                 x0 = [3; -1; 5];
figure; plot_opinions(res);                 X  = sim_degroot(W, x0, 30);% x(k+1) = Wx(k)
                                            X(1, end)                   % the reached limit
                                            figure; plot_opinions(X);
```

The theoretical limit is no longer a field of a result struct — write it as the formula it is:

```matlab
p' * x0                 % consensus value
limit_matrix(W) * x0    % works also when there is no consensus, only block agreement
```

`W` can still be obtained as `example_french3()` if you prefer not to retype it; the function returns
the bare matrix and its help text records the citation and the analytic answer `[2/7 3/7 2/7]`.

To draw the graph of section 1.3:

```matlab
plot_graph(W)                                  % arrows = "listens to"
plot_graph(W', {'1','2','3'}, social_power(W))  % arrows = flow of influence, nodes coloured by power
```

## `ch00_preliminaries`

```matlab
% ---- before ----                     % ---- after ----
net = make_example_french3();          W = example_french3();
disp(net.W)                            disp(W)
disp(net.meta.convention)              % the convention now lives in the README and in
                                       % the help text of net-free functions:
                                       %   W(i,j) > 0  means agent i accords weight to agent j
```

## Renamed or removed

| was | now |
|---|---|
| `net_from_matrix`, the whole `net` struct | gone — pass the matrix |
| the `res` struct returned by `sim_*` | gone — `sim_*` returns the trajectory matrix `X` |
| `make_ring(n)` … (returned nets) | `ring_graph(n)` … (return adjacency matrices) |
| `make_example_french3` / `make_example_fj4` | `example_french3` / `example_fj4` (return `W`, and `[W,u]`) |
| `graph_report` | `graph_summary` (same idea, plain fields) |
| `predict_limit_degroot` | `limit_matrix(W) * x0`, or `social_power(W)' * x0` |
| `predict_limit_fj` | `fj_equilibrium(W, lambda, u)` |
| `predict_limit_taylor` | `taylor_equilibrium(A, gamma, u)` |
| `fj_matrices(...).V` | `total_influence(W, lambda)` |
| `p_dependence` | `prejudice_reach` |
| `plot_network(net)` | `plot_graph(A[, names, nodeValue])` |
| `plot_opinions(res)` | `plot_opinions(X[, t, names])` |
| `plot_influence_bars` | `plot_bars` |
| `fj_lambda(W,'classic')` | `1 - diag(W)` — short enough to write out |
| `taylor_reduce(B,s)` | `gamma = sum(B,2); u = (B*s)./gamma` — likewise |
| `parse_options`, `pack_result`, `prepare_state`, `safe_predict`, `network_matrix`, `diagonal_parameter`, `match_input_dimension` | removed (plumbing) |
| `tools/build_livescripts`, `tools/run_livescripts` | removed — the notebooks are now authored directly as `.mlx` |

The previous library is recoverable in full from git (commit `3081c93`).

## Visualization

Reworked so that every figure identifies itself. The signatures are

```matlab
plot_graph(A, labels, Name, Value, ...)        % 'Weights' 'Format' 'NodeValue'
                                               % 'NodeName' 'Layout' 'SelfLoops'
plot_opinions(X, t, Name, Value, ...)           % 'Labels' 'Limit' 'Prejudice'
plot_convergence(X, t, Name, Value, ...)       % 'Rate'
plot_spectrum(M, domain, Name, Value, ...)
plot_bars(V, labels, Name, Value, ...)         % 'Series' 'Sort' 'Values'
                                               % 'Format' 'YLabel'
```

All five additionally take `'Title'` and `'Subtitle'`: `[]` (default) keeps the automatic text, a
string replaces it, `''` removes it. Or set them by hand with `title` / `subtitle` after the call.

with `t` and `labels` accepting `[]`. Titles default to the caller's variable name, edge weights and
self-loops are drawn by default, and captions report the numbers that decide the behaviour. A
typical call in a notebook:

```matlab
plot_opinions(X, [], 'Limit', social_power(W)' * x0 * ones(3,1))
```

Note `plot_opinions` takes **one** positional context argument (`t`) like the others; agent names
moved to the `'Labels'` option, and the old `'Model'` option is gone -- use `'Subtitle'`.

## Note

`docs/01_technical_analysis.md` §8 describes the *original* architecture and is now out of date on
that one point. The analysis in §§1–7 and §§9–12 is unaffected.
