# Code delivered with the report

The MATLAB code behind the simulations and the figures of the report, in two live
scripts and the library they use. Everything the report shows is reproduced here, and
nothing else.

```
fdg_report.mlx    French-Harary-DeGroot: theory and the figures of Section 2.2
fj_report.mlx     Friedkin-Johnsen:      theory and the figures of Section 3.2
setup_paths.m          puts lib/ on the MATLAB path
lib/                   one function per file, no local functions in the live scripts
```

Each live script has two parts. **Part 1** states the theory, following Proskurnikov
and Tempo, and opens with the direction convention below. **Part 2** reproduces, figure
by figure, the simulations of the report: for each one it gives the section and the
caption it appears under, the code, and the numerical checks. A final cell prints
`ALL CHECKS PASSED` or `SOME CHECKS FAILED`.

## Running them

Open either file in MATLAB and run it. The first cell walks up to `setup_paths.m` and
puts `lib/` on the path, so the folder can sit anywhere. From the command line:

```matlab
run('fdg_report.mlx')
run('fj_report.mlx')
```

The figures stay on screen. To write them as `.eps` as well, set the two variables
before running:

```matlab
saveEps = true;  outDir = '/some/folder';  run('fdg_report.mlx')
```

Both scripts were run with MATLAB R2025b and use base MATLAB only, no toolboxes.

## Direction convention

Every matrix follows one rule:

```
W(i,j) > 0   means   AGENT i IS INFLUENCED BY AGENT j
```

Row `i` lists whom agent `i` listens to, which is why the rows are the objects that
sum to one. The arrows of the two books point in opposite directions: Proskurnikov and
Tempo draw them along the flow of influence, so a stubborn agent is a *source*; the
report and Part 2 use the convention above, so the same agent is a *sink*. The matrix
is the same either way; only the picture differs. `DIRECTED_CYCLE` and
`BIDIRECTIONAL_RING` build the two networks of Figure 1 of the report in this
convention.

## The library

| function | what it returns |
|---|---|
| **matrices** | |
| `directed_cycle(n)` | row-stochastic matrix of the directed cycle, `a_{i,i+1} = 1` |
| `bidirectional_ring(n)` | row-stochastic matrix of the ring, `a_{i,i±1} = 1/2` |
| `self_weight(A, t)` | row 1 of `A` replaced by `(1-t) a_1' + t e_1'` |
| `row_stochastic(A)` | `W = D^{-1} A`, the row-normalised matrix |
| `is_row_stochastic(W)` | predicate |
| **models** | |
| `sim_degroot(W, x0, K)` | trajectory of `x(k+1) = W x(k)` |
| `sim_friedkin_johnsen(W, lambda, u, x0, K)` | trajectory of `x(k+1) = ΛW x(k) + (I−Λ) u` |
| **analysis** | |
| `social_power(W)` | `p` solving `p' = p'W`, `p'1 = 1` |
| `total_influence(W, lambda)` | `V = (I − ΛW)^{-1} (I − Λ)` |
| `fj_equilibrium(W, lambda, u)` | `x(∞) = V u` |
| `influence_centrality(W, lambda)` | `c = V' 1 / n` |
| **viz** | |
| `report_figure(wcm, hcm)` | figure sized in centimetres, with the typography of the report |
| `plot_agent_trajectories(ax, X, K, col, n)` | one curve per agent, agent 1 highlighted |
| `agent_proxies(ax, col, n)` | invisible lines carrying each agent's style |
| `agent_legend(tl, ax, col, n, ...)` | one legend per layout, built on those lines |
| `save_eps(fig, file, method)` | colour EPS, `'vector'` or `'print'` |
| **internal** | |
| `finish_axes(ax, xl, yl)` | grid and axis limits shared by the figures |
| `sort_eigenvalues(e)` / `format_eigenvalues(e)` | deterministic order, printable form |
| `tex_fraction(t)` / `strip_tex(s)` | labels for titles, plain text for the console |
| `check_pass(pass, ok, msg)` | accumulates the verdict of the numerical checks |
| `check_square` / `check_state` / `check_vector` | argument validation |

`save_eps` takes the exporter as an argument because the two are not interchangeable:
the figures of Section 2.2 were produced with `exportgraphics` and those of Section 3.2
with `print -depsc`, and on one and the same figure the two write different files. Each
live script passes its own, so the `.eps` written here are the files the report
includes.
