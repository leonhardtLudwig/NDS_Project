"""Influence centrality c_j(alpha) of all six agents, W = A(1/2), Lambda = alpha I, u = x(0)."""
import sys, numpy as np, matplotlib
matplotlib.use('pdf')
import matplotlib.pyplot as plt
try:
    plt.rcParams.update({'text.usetex': True, 'font.family': 'serif'})
    fig = plt.figure(); fig.text(0.5, 0.5, r'$c_1(\alpha)$'); fig.savefig('/tmp/_t.pdf'); plt.close(fig)
except Exception as e:
    print('no usetex', e)
    plt.rcParams.update({'text.usetex': False, 'font.family': 'serif', 'mathtext.fontset': 'cm'})
out = sys.argv[1]
n = 6
def A(net, t):
    W = np.zeros((n, n))
    for i in range(n):
        if net == 'cyc': W[i, (i + 1) % n] = 1
        else: W[i, (i + 1) % n] = .5; W[i, (i - 1) % n] = .5
    W[0] = (1 - t) * W[0]; W[0, 0] += t
    return W
al = np.linspace(0, 0.995, 400)
col = ['k', (0.85, 0.325, 0.098), (0.929, 0.694, 0.125), (0.494, 0.184, 0.556), (0.466, 0.674, 0.188), (0.301, 0.745, 0.933)]
fig, axs = plt.subplots(1, 2, figsize=(6.4, 2.45), sharey=True)
for ax, net, title in zip(axs, ['cyc', 'ring'], ['directed cycle', 'bidirectional ring']):
    W = A(net, .5)
    C = np.array([((1 - a) * np.linalg.inv(np.eye(n) - a * W)).sum(0) / n for a in al])
    for j in range(1, n):
        ls = '-'
        if net == 'ring' and j in (4, 5): ls = (0, (4, 3))
        ax.plot(al, C[:, j], color=col[j], lw=1.8 if j == 1 else 1.3, ls=ls, label=r'$c_{%d}(\alpha)$' % (j + 1))
    for y, s in [(1/7, '--'), (1/6, ':')]:
        ax.axhline(y, color='0.45', lw=0.8, ls=s)
    ax.text(0.02, 1/7 - 0.0028, r'$w_2 = \dots = w_6 = 1/7$', fontsize=8, color='0.3')
    ax.text(0.92, 1/6 + 0.0008, r'$1/6$', fontsize=8, color='0.3')
    ax.set_title(title, fontsize=10)
    ax.set_xlim(0, 1); ax.set_ylim(0.134, 0.1695)
    ax.set_xlabel(r'susceptibility $\alpha$ \ ($\Lambda = \alpha I$)' if plt.rcParams['text.usetex'] else r'susceptibility $\alpha$  ($\Lambda = \alpha I$)', fontsize=9)
    ax.tick_params(labelsize=8)
    ax.grid(False)
axs[0].set_ylabel('influence centrality', fontsize=9)
axs[1].set_title(r'bidirectional ring: $c_6 = c_2$, $c_5 = c_3$ (dashed)', fontsize=10)
h, l = axs[0].get_legend_handles_labels()
fig.legend(h, l, loc='upper center', ncol=5, fontsize=8.5, frameon=False, bbox_to_anchor=(0.5, 1.02))
fig.tight_layout(rect=(0, 0, 1, 0.92))
fig.savefig(out)
print('saved', out)
