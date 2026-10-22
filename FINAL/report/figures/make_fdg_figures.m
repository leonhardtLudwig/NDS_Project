function make_fdg_figures()
%MAKE_FDG_FIGURES  Simulations and figures for Section 2.2 of the report.
%
%   French-Harary-DeGroot opinion dynamics
%
%       x(k+1) = A x(k),        A row-stochastic
%
%   Edge convention: a_ij > 0 means "agent i is influenced by agent j", so
%   row i lists whom agent i listens to and the rows sum to one.
%
%   Two networks on n = 6 agents, neither with self-loops:
%       directed cycle        a_{i,i+1} = 1
%       bidirectional ring    a_{i,i-1} = a_{i,i+1} = 1/2
%
%   Agent 1 is given a self-weight t by replacing ONLY its row by
%
%       a_1(t)' = (1 - t) a_1' + t e_1'
%
%   so t = 0 is the original network and t = 1 makes agent 1 stubborn.
%
%   Produces fdg_convergence.eps (opinion trajectories) and fdg_social_power.eps
%   (two stacked panels: social power on top, resulting consensus value below)
%   in this folder, and prints the numerical checks to the command window.
%
%   Self-contained: base MATLAB only, no toolboxes.

    here = fileparts(mfilename('fullpath'));
    if isempty(here), here = pwd; end
    if ~isfolder(here), mkdir(here); end

    n   = 6;
    agentColour = lines(n);            % same colour per agent in every figure
    Acyc  = cycle_matrix(n);
    Aring = ring_matrix(n);

    % ------------------------------------------------------------------
    % Figure 1 - trajectories
    % ------------------------------------------------------------------
    x0 = [0; 0.2; 0.4; 0.6; 0.8; 1];
    K  = 40;
    ts = [0, 0.5, 1];
    nets = {'Directed cycle', Acyc; 'Bidirectional ring', Aring};

    fig1 = new_figure(16, 10);
    tl = tiledlayout(fig1, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    h = gobjects(n, 1);
    for r = 1:2
        for c = 1:3
            ax = nexttile(tl);
            hold(ax, 'on');
            X = simulate(self_weight(nets{r,2}, ts(c)), x0, K);
            for i = 1:n
                if i == 1                       % agent 1 is highlighted
                    h(i) = plot(ax, 0:K, X(i,:), '-o', 'Color', agentColour(i,:), ...
                        'LineWidth', 1.8, 'MarkerSize', 3, ...
                        'MarkerFaceColor', agentColour(i,:), 'MarkerIndices', 1:4:K+1);
                else
                    h(i) = plot(ax, 0:K, X(i,:), '-', 'Color', agentColour(i,:), ...
                        'LineWidth', 1.0);
                end
            end
            grid(ax, 'on');
            ax.GridAlpha = 0.15;
            ylim(ax, [-0.05, 1.05]);
            xlim(ax, [0, K]);
            title(ax, sprintf('%s, $t = %s$', nets{r,1}, tex_frac(ts(c))), ...
                'Interpreter', 'latex', 'FontWeight', 'normal');
            hold(ax, 'off');
        end
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    lgd = legend(h, arrayfun(@(i) sprintf('$x_%d$', i), 1:n, 'UniformOutput', false), ...
        'Interpreter', 'latex');
    lgd.Layout.Tile = 'east';
    f1 = fullfile(here, 'fdg_convergence.eps');
    save_eps(fig1, f1);

    % ------------------------------------------------------------------
    % Figure 2 - social power of agent 1, and the resulting consensus value
    % ------------------------------------------------------------------
    tg = 0.01:0.01:1;                   % t = 0 excluded: no consensus there
    Wc = zeros(n, numel(tg));
    Wr = zeros(n, numel(tg));
    for j = 1:numel(tg)
        Wc(:,j) = social_power(self_weight(Acyc,  tg(j)));
        Wr(:,j) = social_power(self_weight(Aring, tg(j)));
    end
    alphaC = x0.' * Wc;                 % consensus value alpha(t) = w(t)' x(0)
    alphaR = x0.' * Wr;

    fig2 = new_figure(16, 10);
    tl2 = tiledlayout(fig2, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    c1  = agentColour(1,:);  c2 = agentColour(2,:);
    cA  = [0.20 0.20 0.20];             % one quantity, two networks: markers separate them
    mkC = 1:5:numel(tg);                % markers every 5th point, offset between the two
    mkR = 3:5:numel(tg);                % networks so both stay visible where they overlap

    % --- top panel: social power ---------------------------------------
    ax1 = nexttile(tl2);
    hold(ax1, 'on');
    plot(ax1, tg, Wc(1,:), '-o', 'Color', c1, 'LineWidth', 1.6, 'MarkerSize', 4, ...
        'MarkerIndices', mkC, 'DisplayName', '$w_1$, directed cycle');
    plot(ax1, tg, Wr(1,:), '-x', 'Color', c1, 'LineWidth', 1.0, 'MarkerSize', 6, ...
        'MarkerIndices', mkR, 'DisplayName', '$w_1$, bidirectional ring');
    plot(ax1, tg, Wc(2,:), '-o', 'Color', c2, 'LineWidth', 1.6, 'MarkerSize', 4, ...
        'MarkerIndices', mkC, 'DisplayName', '$w_2$, directed cycle');
    plot(ax1, tg, Wr(2,:), '-x', 'Color', c2, 'LineWidth', 1.0, 'MarkerSize', 6, ...
        'MarkerIndices', mkR, 'DisplayName', '$w_2$, bidirectional ring');
    grid(ax1, 'on');
    ax1.GridAlpha = 0.15;
    xlim(ax1, [0, 1]);
    ylim(ax1, [0, 1.05]);
    ax1.XTickLabel = {};                % horizontal axis shared with the panel below
    ylabel(ax1, 'social power', 'Interpreter', 'latex');
    legend(ax1, 'Interpreter', 'latex', 'Location', 'northwest');
    hold(ax1, 'off');

    % --- bottom panel: consensus value ----------------------------------
    ax2 = nexttile(tl2);
    hold(ax2, 'on');
    ref = yline(ax2, mean(x0), '--', 'average of $x(0)$', ...
        'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, 'Interpreter', 'latex', ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    ref = yline(ax2, x0(1), '--', '$x_1(0)$', ...
        'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, 'Interpreter', 'latex', ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    plot(ax2, tg, alphaC, '-o', 'Color', cA, 'LineWidth', 1.6, 'MarkerSize', 4, ...
        'MarkerIndices', mkC, 'DisplayName', 'directed cycle');
    plot(ax2, tg, alphaR, '-x', 'Color', cA, 'LineWidth', 1.0, 'MarkerSize', 6, ...
        'MarkerIndices', mkR, 'DisplayName', 'bidirectional ring');
    grid(ax2, 'on');
    ax2.GridAlpha = 0.15;
    xlim(ax2, [0, 1]);
    ylim(ax2, [-0.08, 0.62]);
    xlabel(ax2, 'self-weight $t$ of agent 1', 'Interpreter', 'latex');
    ylabel(ax2, 'consensus value', 'Interpreter', 'latex');
    legend(ax2, 'Interpreter', 'latex', 'Location', 'northeast');
    hold(ax2, 'off');

    f2 = fullfile(here, 'fdg_social_power.eps');
    save_eps(fig2, f2);

    % ------------------------------------------------------------------
    % Numerical checks
    % ------------------------------------------------------------------
    fprintf('\n================ NUMERICAL CHECKS ================\n');
    fprintf('files written:\n  %s\n  %s\n', f1, f2);
    tol  = 1e-3;
    pass = true;

    % --- check 1: eigenvalues --------------------------------------------
    fprintf('\n--- 1. eigenvalues of A(t), sorted ---\n');
    expected = { ...
        'directed', 0.0, exp(2i*pi*(0:5)/6).'; ...
        'directed', 0.5, [1; -0.823; -0.373+0.759i; -0.373-0.759i; 0.535+0.751i; 0.535-0.751i]; ...
        'directed', 1.0, [1; 0; 0; 0; 0; 0]; ...
        'ring',     0.0, [1; 0.5; 0.5; -0.5; -0.5; -1]; ...
        'ring',     0.5, [1; 0.623; 0.5; -0.223; -0.5; -0.901]; ...
        'ring',     1.0, [1; 0.866; 0.5; 0; -0.5; -0.866]};
    for r = 1:size(expected,1)
        if strcmp(expected{r,1}, 'directed'), A0 = Acyc; else, A0 = Aring; end
        ev  = sort_eig(eig(self_weight(A0, expected{r,2})));
        exv = sort_eig(expected{r,3});
        d   = max(abs(ev - exv));
        pass = pass && (d <= tol);
        fprintf('  %-9s t = %.1f : %s\n', expected{r,1}, expected{r,2}, fmt_eig(ev));
        if d > tol
            fprintf('      MISMATCH, expected %s   (max diff %.2e)\n', fmt_eig(exv), d);
        end
    end

    % --- check 2: social power at t = 0.5 and t = 1 -----------------------
    fprintf('\n--- 2. social power w(t) ---\n');
    for tv = [0.5, 1.0]
        for r = 1:2
            if r == 1, nm = 'directed'; A0 = Acyc; else, nm = 'ring'; A0 = Aring; end
            w = social_power(self_weight(A0, tv));
            if tv == 0.5
                exw = [2/7; repmat(1/7, n-1, 1)];
            else
                exw = [1; zeros(n-1,1)];
            end
            d = max(abs(w - exw));
            pass = pass && (d <= tol);
            fprintf('  %-9s t = %.1f : w = [%s]\n', nm, tv, ...
                strjoin(compose('%.4f', w.'), ' '));
            if d > tol
                fprintf('      MISMATCH, expected [%s]   (max diff %.2e)\n', ...
                    strjoin(compose('%.4f', exw.'), ' '), d);
            end
        end
    end

    % --- check 3: consensus time, directed cycle at t = 1 -----------------
    fprintf('\n--- 3. directed cycle, t = 1: first k with spread < 1e-12 ---\n');
    Xs = simulate(self_weight(Acyc, 1), x0, K);
    kk = find(max(Xs,[],1) - min(Xs,[],1) < 1e-12, 1) - 1;   % column 1 is k = 0
    if isempty(kk)
        fprintf('  never reached within k = %d   MISMATCH, expected k = 5\n', K);
        pass = false;
    else
        fprintf('  k = %d\n', kk);
        if kk ~= 5
            fprintf('      MISMATCH, expected k = 5\n');
            pass = false;
        end
    end

    % --- check 4: the two networks give the same social power -------------
    fprintf('\n--- 4. max |w_cycle(t) - w_ring(t)| over the grid ---\n');
    dmax = max(abs(Wc - Wr), [], 'all');
    fprintf('  %.3e\n', dmax);
    if dmax > 1e-10
        fprintf('      MISMATCH, expected numerically zero\n');
        pass = false;
    end

    % --- check 5: consensus value at selected t ---------------------------
    fprintf('\n--- 5. consensus value alpha(t) = w(t)^T x(0) ---\n');
    for tv = [0.01, 0.5, 1.0]
        ac = x0.' * social_power(self_weight(Acyc,  tv));
        ar = x0.' * social_power(self_weight(Aring, tv));
        if tv == 0.01
            exa = 0.5;    tolA = 5e-3;   % w is near uniform here, not exactly uniform
        elseif tv == 0.5
            exa = 3/7;    tolA = tol;
        else
            exa = x0(1);  tolA = tol;
        end
        fprintf('  t = %.2f : directed %.4f   ring %.4f   (expected about %.4f)\n', ...
            tv, ac, ar, exa);
        if max(abs([ac, ar] - exa)) > tolA
            fprintf('      MISMATCH, expected about %.4f within %.1e\n', exa, tolA);
            pass = false;
        end
    end

    % --- check 6: the dynamics really reach alpha(t) ----------------------
    fprintf('\n--- 6. dynamics vs alpha(t): max |x(2000) - alpha(t) 1_6| ---\n');
    for tv = [0.25, 0.5, 0.75]
        for r = 1:2
            if r == 1, nm = 'directed'; A0 = Acyc; else, nm = 'ring'; A0 = Aring; end
            At = self_weight(A0, tv);
            a  = x0.' * social_power(At);
            Xl = simulate(At, x0, 2000);
            d  = max(abs(Xl(:,end) - a));
            fprintf('  %-9s t = %.2f : %.3e\n', nm, tv, d);
            if d > 1e-10
                fprintf('      MISMATCH, expected below 1e-10\n');
                pass = false;
            end
        end
    end

    % --- check 7: the two networks give the same consensus value ----------
    fprintf('\n--- 7. max |alpha_cycle(t) - alpha_ring(t)| over the grid ---\n');
    damax = max(abs(alphaC - alphaR));
    fprintf('  %.3e\n', damax);
    if damax > 1e-10
        fprintf('      MISMATCH, expected numerically zero\n');
        pass = false;
    end

    fprintf('\n%s\n', repmat('=', 1, 50));
    if pass
        fprintf('ALL CHECKS PASSED\n\n');
    else
        fprintf('SOME CHECKS FAILED - see the MISMATCH lines above\n\n');
    end
end

% =====================================================================
function A = cycle_matrix(n)
%CYCLE_MATRIX  Directed cycle: agent i is influenced only by agent i+1.
    A = zeros(n);
    for i = 1:n
        A(i, mod(i, n) + 1) = 1;
    end
end

% ---------------------------------------------------------------------
function A = ring_matrix(n)
%RING_MATRIX  Bidirectional ring: agent i is influenced by i-1 and i+1.
    A = zeros(n);
    for i = 1:n
        A(i, mod(i - 2, n) + 1) = 0.5;
        A(i, mod(i,     n) + 1) = 0.5;
    end
end

% ---------------------------------------------------------------------
function A = self_weight(A, t)
%SELF_WEIGHT  Give agent 1 a self-weight t, leaving every other row alone.
    A(1,:) = (1 - t) * A(1,:);
    A(1,1) = A(1,1) + t;
end

% ---------------------------------------------------------------------
function X = simulate(A, x0, K)
%SIMULATE  x(k+1) = A x(k); column k+1 of X is x(k).
    X = zeros(numel(x0), K + 1);
    X(:,1) = x0;
    for k = 1:K
        X(:,k+1) = A * X(:,k);
    end
end

% ---------------------------------------------------------------------
function w = social_power(A)
%SOCIAL_POWER  Left eigenvector of A for the eigenvalue 1, normalised to sum 1.
    [V, D] = eig(A.');
    [~, j] = min(abs(diag(D) - 1));
    w = real(V(:,j));
    w = w / sum(w);
end

% ---------------------------------------------------------------------
function e = sort_eig(e)
%SORT_EIG  Deterministic ordering: real part descending, then imaginary part.
    e = e(:);
    [~, idx] = sortrows([-round(real(e), 6), -round(imag(e), 6)]);
    e = e(idx);
end

% ---------------------------------------------------------------------
function s = fmt_eig(e)
%FMT_EIG  Eigenvalue list to 4 decimals, real ones printed without "+0i".
    parts = cell(1, numel(e));
    for k = 1:numel(e)
        if abs(imag(e(k))) < 1e-10
            parts{k} = sprintf('%.4f', real(e(k)));
        else
            parts{k} = sprintf('%.4f%+.4fi', real(e(k)), imag(e(k)));
        end
    end
    s = strjoin(parts, '  ');
end

% ---------------------------------------------------------------------
function s = tex_frac(t)
%TEX_FRAC  Nice LaTeX for the three values of t used in the titles.
    if abs(t - 0.5) < eps
        s = '1/2';
    else
        s = sprintf('%g', t);
    end
end

% ---------------------------------------------------------------------
function fig = new_figure(wcm, hcm)
%NEW_FIGURE  Invisible figure of the given size in centimetres, 9 pt text.
    fig = figure('Visible', 'off', 'Units', 'centimeters', ...
        'Position', [2, 2, wcm, hcm], 'Color', 'w');
    set(fig, 'DefaultAxesFontSize', 9, 'DefaultTextFontSize', 9, ...
             'DefaultLegendFontSize', 9, 'DefaultAxesTickLabelInterpreter', 'latex');
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0, 0, wcm, hcm];
    fig.PaperSize = [wcm, hcm];
end

% ---------------------------------------------------------------------
function save_eps(fig, file)
%SAVE_EPS  Vector colour EPS, with a fallback for older MATLAB releases.
    if exist('exportgraphics', 'file') == 2
        exportgraphics(fig, file, 'ContentType', 'vector');
    else
        print(fig, file, '-depsc', '-vector');
    end
end
