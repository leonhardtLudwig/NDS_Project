function make_fj_figures()
%MAKE_FJ_FIGURES  Simulations and figures for Section 3.2 of the report.
%
%   Friedkin-Johnsen opinion dynamics
%
%       x(k+1) = Lambda W x(k) + (I - Lambda) u,      Lambda = diag(lambda_i)
%
%   compared with the French-Harary-DeGroot model x(k+1) = A x(k).
%   Edge convention: a_ij > 0 (w_ij > 0) means "agent i is influenced by agent j",
%   so row i lists whom agent i listens to and the rows sum to one.
%
%   Networks of Figure 1 of the report (n = 6, no self-loops):
%       directed cycle        a_{i,i+1} = 1
%       bidirectional ring    a_{i,i-1} = a_{i,i+1} = 1/2
%   A(t) is the self-weight modification of Chapter 2 (eq:self-weight): row 1 of A is
%   replaced by (1-t) a_1' + t e_1', every other row left unchanged.
%
%   V = (I - Lambda W)^{-1} (I - Lambda),   influence centrality c = V' 1 / n.
%
%   Writes eight .eps files in this folder and prints the numerical checks.
%   Self-contained: base MATLAB only, no toolboxes.

    here = fileparts(mfilename('fullpath'));
    if isempty(here), here = pwd; end
    if ~isfolder(here), mkdir(here); end

    n  = 6;
    x0 = [0; 0.2; 0.4; 0.6; 0.8; 1];
    Wcyc  = cycle_matrix(n);
    Wring = ring_matrix(n);
    nets  = {'directed cycle', Wcyc; 'bidirectional ring', Wring};

    % same colour per agent in every figure; agent 1 is black and marked with dots
    agentColour = lines(n);
    agentColour(1,:) = [0 0 0];

    files = cell(10,1);
    pass  = true;
    tol   = 1e-3;
    log   = {};                     % check lines, printed at the end

    % =================================================================
    % Figure 0 - ADDED (2026-10-28): the stubborn agent of the FDG model becomes the
    % common prejudice of the two agents that listen to it (our rewriting).
    %   (a) FDG on 6 agents, bidirectional ring with t = 1, agent 1 stubborn;
    %   (b) FJ on agents 2..6 only, W' = the ring rows restricted to 2..6 and
    %       renormalised, lambda_2 = lambda_6 = 1/2, u_2 = u_6 = x_1(0).
    % =================================================================
    Kr  = 40;
    idx = 2:n;                                  % agents 2..6, in this order
    Xr  = sim_fdg(self_weight(Wring, 1), x0, Kr);
    m   = n - 1;
    Wr  = zeros(m);                             % W' of the reduced FJ model
    Wr(1,2)   = 1;                              % agent 2 listens to agent 3 only
    Wr(m,m-1) = 1;                              % agent 6 listens to agent 5 only
    for i = 2:m-1, Wr(i,i-1) = 0.5;  Wr(i,i+1) = 0.5;  end
    lamR = [0.5; ones(m-2,1); 0.5];             % lambda_2 = lambda_6 = 1/2
    uR   = zeros(m,1);  uR(1) = x0(1);  uR(m) = x0(1);   % u_2 = u_6 = x_1(0)
    Xq   = sim_fj(Wr, lamR, uR, x0(idx), Kr);
    Xq6  = NaN(n, Kr+1);  Xq6(idx,:) = Xq;      % agent 1 absent: drawn as NaN
    fig = new_figure(16, 7);
    tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    ax  = nexttile(tl);
    draw_traj(ax, Xr, Kr, agentColour, n);
    title(ax, 'FDG, 6 agents, agent~1 stubborn', 'Interpreter', 'latex', ...
        'FontWeight', 'normal');
    ylim(ax, [-0.05, 1.05]);
    ax = nexttile(tl);
    ref = yline(ax, x0(1), '--', 'Color', [0 0 0], 'LineWidth', 0.9);
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold(ax, 'on');
    draw_traj(ax, Xq6, Kr, agentColour, n);
    hold(ax, 'off');
    title(ax, 'FJ, agents $2, \dots, 6$', 'Interpreter', 'latex', ...
        'FontWeight', 'normal');
    ylim(ax, [-0.05, 1.05]);
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    hold(ax, 'on');
    hRef = plot(ax, NaN, NaN, '--', 'Color', [0 0 0], 'LineWidth', 0.9);
    hold(ax, 'off');
    lgd = shared_legend(tl, ax, agentColour, n, 'x', hRef, ...
        {'prejudice $u_2 = u_6 = x_1(0)$'});
    lgd.Layout.Tile = 'south';                  % the long entry does not fit on the east
    lgd.Orientation = 'horizontal';
    lgd.NumColumns  = 4;                        % two rows, so the box stays inside 16 cm
    files{1} = export(fig, here, 'fj_stub_reduction');
    dRed = max(abs(Xr(idx,:) - Xq), [], 'all');
    log{end+1} = sprintf('0. bidirectional ring, max_k max_i |x_FDG - x_FJ| over agents 2..6 : %.3e', dRed);
    pass = check(pass, dRed < 1e-12, '     MISMATCH, expected below 1e-12');
    rhoR = max(abs(eig(diag(lamR)*Wr)));
    log{end+1} = sprintf('0. W'' rows sum to 1 : %.2e | rho(Lambda W'') = %.4f  (expected 0.8660)', ...
        max(abs(sum(Wr,2) - 1)), rhoR);
    pass = check(pass, max(abs(sum(Wr,2) - 1)) < 1e-12, '     MISMATCH, W'' is not row-stochastic');
    pass = check(pass, abs(rhoR - sqrt(3)/2) < 1e-4, '     MISMATCH, expected sqrt(3)/2 = 0.8660');
    XrL = sim_fdg(self_weight(Wring, 1), x0, 4000);
    XqL = sim_fj(Wr, lamR, uR, x0(idx), 4000);
    log{end+1} = sprintf('0. limits : max |x_FDG(inf) - x_1(0)| = %.3e | max |x_FJ(inf) - x_1(0)| = %.3e', ...
        max(abs(XrL(:,end) - x0(1))), max(abs(XqL(:,end) - x0(1))));
    pass = check(pass, max(abs(XrL(:,end) - x0(1))) < tol && max(abs(XqL(:,end) - x0(1))) < tol, ...
        '     MISMATCH, expected both limits equal to x_1(0)');

    % =================================================================
    % Figure 1 - stubborn agent: FDG with A(1) equals FJ with lambda_1 = 0
    % =================================================================
    Ks = [10, 40];                                  % cycle, ring
    lamStub = [0; ones(n-1,1)];                     % lambda_1 = 0, lambda_i = 1
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    d1  = 0;
    for r = 1:2
        W = nets{r,2};  K = Ks(r);
        Xf = sim_fdg(self_weight(W, 1), x0, K);     % FDG, agent 1 stubborn
        Xj = sim_fj(W, lamStub, x0, x0, K);         % FJ, lambda_1 = 0, u = x(0)
        d1 = max(d1, max(abs(Xf - Xj), [], 'all'));
        for col = 1:2
            ax = nexttile(tl);
            if col == 1, X = Xf; ttl = sprintf('%s, FDG with $A(1)$', nets{r,1});
            else,        X = Xj; ttl = sprintf('%s, FJ with $\\lambda_1 = 0$', nets{r,1});
            end
            draw_traj(ax, X, K, agentColour, n);
            title(ax, ttl, 'Interpreter', 'latex', 'FontWeight', 'normal');
            ylim(ax, [-0.05, 1.05]);
        end
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n);
    files{2} = export(fig, here, 'fj_stubborn_equivalence');
    log{end+1} = sprintf('1. max |x_FDG - x_FJ| over both networks : %.3e', d1);
    pass = check(pass, d1 < 1e-12, '     MISMATCH, expected below 1e-12');

    % =================================================================
    % Figure 2 - the same two models started from x_1(0) = 0.5
    % =================================================================
    x0p = x0;  x0p(1) = 0.5;                        % u is left unchanged: u_1 = 0
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    Xp  = cell(2,2);
    for r = 1:2
        W = nets{r,2};  K = Ks(r);
        Xp{r,1} = sim_fdg(self_weight(W, 1), x0p, K);
        Xp{r,2} = sim_fj(W, lamStub, x0, x0p, K);
        for col = 1:2
            ax = nexttile(tl);
            if col == 1, ttl = sprintf('%s, FDG with $A(1)$', nets{r,1});
            else,        ttl = sprintf('%s, FJ with $\\lambda_1 = 0$', nets{r,1});
            end
            draw_traj(ax, Xp{r,col}, K, agentColour, n);
            title(ax, ttl, 'Interpreter', 'latex', 'FontWeight', 'normal');
            ylim(ax, [-0.05, 1.05]);
        end
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n);
    files{3} = export(fig, here, 'fj_stubborn_perturbation');
    for r = 1:2
        Lf = sim_fdg(self_weight(nets{r,2}, 1), x0p, 2000);
        Lj = sim_fj(nets{r,2}, lamStub, x0, x0p, 2000);
        df = max(abs(Lf(:,end) - 0.5));
        dj = max(abs(Lj(:,end) - 0));
        log{end+1} = sprintf('2. %-19s FDG limit vs 0.5*1_6 : %.3e | FJ limit vs 0 : %.3e', ...
            nets{r,1}, df, dj);
        pass = check(pass, df < tol && dj < tol, '     MISMATCH, expected below 1e-3');
    end

    % =================================================================
    % Figure 3 - the error e(k) between the two initial conditions
    % =================================================================
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    e6  = NaN;
    for mdl = 1:2                                   % rows: FDG, FJ
        for r = 1:2                                 % columns: cycle, ring
            W = nets{r,2};  K = Ks(r);
            if mdl == 1
                E = sim_fdg(self_weight(W,1), x0p, K) - sim_fdg(self_weight(W,1), x0, K);
                ttl = sprintf('FDG with $A(1)$, %s', nets{r,1});
            else
                E = sim_fj(W, lamStub, x0, x0p, K) - sim_fj(W, lamStub, x0, x0, K);
                ttl = sprintf('FJ with $\\lambda_1 = 0$, %s', nets{r,1});
                if r == 1, e6 = max(abs(E(:, 7:end)), [], 'all'); end   % k >= 6
            end
            ax = nexttile(tl);
            yline(ax, 0, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
            hold(ax, 'on');
            draw_traj(ax, E, K, agentColour, n);
            hold(ax, 'off');
            title(ax, ttl, 'Interpreter', 'latex', 'FontWeight', 'normal');
            ylim(ax, [-0.05, 0.55]);
        end
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$\delta_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n, '\delta');
    files{4} = export(fig, here, 'fj_error');
    log{end+1} = sprintf('3. FJ directed cycle, max |delta(k)| for k >= 6 : %.3e', e6);
    pass = check(pass, e6 == 0, '     MISMATCH, expected exactly 0');

    % =================================================================
    % Figure 3b - distance from the limit e(k) against residual delta(k), FJ only
    % =================================================================
    fig = new_figure(16, 11);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    dId = 0;  d6 = NaN;
    for row = 1:2                                   % rows: e(k), delta(k)
        for r = 1:2                                 % columns: cycle, ring
            W = nets{r,2};  K = Ks(r);
            xinf = fj_limit(W, lamStub, x0);        % V u, equal to zero here
            Xo = sim_fj(W, lamStub, x0, x0,  K);    % original trajectory x(k)
            Xt = sim_fj(W, lamStub, x0, x0p, K);    % perturbed trajectory xt(k)
            Ep = Xt - xinf;                         % e(k)   = xt(k) - x(inf)
            De = Xt - Xo;                           % delta(k) = xt(k) - x(k)
            if row == 1
                Y = Ep;  ttl = {nets{r,1}; 'distance from the limit, $e(k)$'};
            else
                Y = De;  ttl = {nets{r,1}; 'residual of the perturbation, $\delta(k)$'};
            end
            ax = nexttile(tl);
            yline(ax, 0, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5);
            hold(ax, 'on');
            draw_traj(ax, Y, K, agentColour, n);
            hold(ax, 'off');
            title(ax, ttl, 'Interpreter', 'latex', 'FontWeight', 'normal');
            ylim(ax, [-0.05, 1.05]);
            if row == 1
                Eo  = Xo - xinf;                    % e_orig(k) = x(k) - x(inf)
                dId = max(dId, max(abs(De - (Ep - Eo)), [], 'all'));
                log{end+1} = sprintf('3b. %-19s max |x(inf)| = %.3e | e(0) = [%s] | delta(0) = [%s]', ...
                    nets{r,1}, max(abs(xinf)), ...
                    strjoin(compose('%.1f', Ep(:,1).'), ' '), ...
                    strjoin(compose('%.1f', De(:,1).'), ' '));
                pass = check(pass, max(abs(xinf)) < 1e-12, ...
                    '     MISMATCH, expected x(inf) = V u = 0');
                pass = check(pass, max(abs(Ep(:,1) - [0.5;0.2;0.4;0.6;0.8;1])) < 1e-12, ...
                    '     MISMATCH, expected e(0) = (0.5, 0.2, 0.4, 0.6, 0.8, 1)');
                pass = check(pass, max(abs(De(:,1) - [0.5;0;0;0;0;0])) < 1e-12, ...
                    '     MISMATCH, expected delta(0) = (0.5, 0, 0, 0, 0, 0)');
                if r == 1, d6 = max(abs(De(:, 7:end)), [], 'all'); end
            end
        end
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$e_i(k)$ (top), $\delta_i(k)$ (bottom)', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n, ...
        arrayfun(@(i) sprintf('agent $%d$', i), 1:n, 'UniformOutput', false));
    files{5} = export(fig, here, 'fj_delta_vs_error');
    log{end+1} = sprintf('3b. max |delta(k) - (e_pert(k) - e_orig(k))| over both networks : %.3e', dId);
    pass = check(pass, dId < 1e-12, '     MISMATCH, expected below 1e-12');
    log{end+1} = sprintf('3b. directed cycle      max |delta(k)| for k >= 6 : %.3e', d6);
    pass = check(pass, d6 == 0, '     MISMATCH, expected exactly 0');

    % =================================================================
    % Figure 4 - one prejudiced agent, attachment 1 - lambda_1 = 1/2
    % =================================================================
    % REVISED (2026-10-29): only the attachment 1/2 is kept, the one that can be compared
    % with the middle column of Figure fdg-conv; the two extreme values need no panel
    % (0 is the FDG model of Figure fdg-conv, 1 is Figure fj-stub-equivalence).  The
    % heading above was "Figure 4 - one prejudiced agent, three values of the attachment".
    % Was:
    %     att = [0, 0.5, 1];                              % attachment 1 - lambda_1
    %     Kp  = 40;
    %     aFDG = social_power(self_weight(Wcyc, 0.5)).' * x0;     % FDG consensus at t = 1/2
    %     fig = new_figure(16, 10);
    %     tl  = tiledlayout(fig, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
    %     steps = zeros(1,2);
    %     for r = 1:2
    %         W = nets{r,2};
    %         for c = 1:3
    %             lam = ones(n,1);  lam(1) = 1 - att(c);
    %             X   = sim_fj(W, lam, x0, x0, Kp);
    %             ax  = nexttile(tl);
    %             if c == 2
    %                 ref = yline(ax, aFDG, '--', 'FDG, $t = 1/2$', ...
    %                     'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, ...
    %                     'Interpreter', 'latex', 'LabelHorizontalAlignment', 'right', ...
    %                     'LabelVerticalAlignment', 'top');
    %                 ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    %                 hold(ax, 'on');
    %                 Xl = sim_fj(W, lam, x0, x0, 400);
    %                 kk = find(max(abs(Xl), [], 1) < tol, 1) - 1;
    %                 if isempty(kk), kk = NaN; end
    %                 steps(r) = kk;
    %             end
    %             draw_traj(ax, X, Kp, agentColour, n);
    %             hold(ax, 'off');
    %             title(ax, sprintf('%s, $1-\\lambda_1 = %s$', nets{r,1}, tex_frac(att(c))), ...
    %                 'Interpreter', 'latex', 'FontWeight', 'normal');
    %             ylim(ax, [-0.05, 1.05]);
    %         end
    %     end
    % REVISED (2026-10-30): the figure becomes the fair comparison FDG/FJ at the same
    % weight 1/2 on agent 1, laid out like Figure 5: columns = models, rows = networks.
    % The dashed reference line is no longer needed, since the FDG model is now drawn,
    % and the limits are marked by triangles as in Figure 5.  Was:
    %     Kp  = 40;
    %     aFDG = social_power(self_weight(Wcyc, 0.5)).' * x0;     % FDG consensus at t = 1/2
    %     fig = new_figure(16, 6);
    %     tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    %     steps = zeros(1,2);
    %     for r = 1:2
    %         W   = nets{r,2};
    %         lam = ones(n,1);  lam(1) = 0.5;             % attachment 1 - lambda_1 = 1/2
    %         X   = sim_fj(W, lam, x0, x0, Kp);
    %         ax  = nexttile(tl);
    %         ref = yline(ax, aFDG, '--', 'FDG, $t = 1/2$', ...
    %             'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, ...
    %             'Interpreter', 'latex', 'LabelHorizontalAlignment', 'right', ...
    %             'LabelVerticalAlignment', 'top');
    %         ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    %         hold(ax, 'on');
    %         Xl = sim_fj(W, lam, x0, x0, 400);
    %         kk = find(max(abs(Xl), [], 1) < tol, 1) - 1;
    %         if isempty(kk), kk = NaN; end
    %         steps(r) = kk;
    %         draw_traj(ax, X, Kp, agentColour, n);
    %         hold(ax, 'off');
    %         title(ax, sprintf('%s, $1-\\lambda_1 = 1/2$', nets{r,1}), ...
    %             'Interpreter', 'latex', 'FontWeight', 'normal');
    %         ylim(ax, [-0.05, 1.05]);
    %     end
    Kp  = 60;
    aFDG = social_power(self_weight(Wcyc, 0.5)).' * x0;     % FDG consensus at t = 1/2
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    steps = zeros(1,2);
    Afdg2 = cell(2,1);                              % A(1/2), kept for the checks
    for r = 1:2
        W = nets{r,2};
        % left: the FDG model, the weight 1/2 going to the CURRENT opinion x_1(k)
        A  = self_weight(W, 0.5);  Afdg2{r} = A;
        Xf = sim_fdg(A, x0, Kp);
        ax = nexttile(tl);
        draw_traj(ax, Xf, Kp, agentColour, n);
        hold(ax, 'on');
        plot(ax, Kp, social_power(A).' * x0, '<', 'Color', [0 0 0], ...
            'MarkerFaceColor', [0 0 0], 'MarkerSize', 5, 'HandleVisibility', 'off');
        hold(ax, 'off');
        xlim(ax, [0, Kp + 1.5]);
        ylim(ax, [-0.05, 1.05]);
        title(ax, sprintf('%s, FDG, $t = 1/2$', nets{r,1}), ...
            'Interpreter', 'latex', 'FontWeight', 'normal');
        % right: the FJ model, the same weight going to the INITIAL opinion u_1 = x_1(0)
        lam = ones(n,1);  lam(1) = 0.5;             % attachment 1 - lambda_1 = 1/2
        X   = sim_fj(W, lam, x0, x0, Kp);
        Xl  = sim_fj(W, lam, x0, x0, 400);
        kk  = find(max(abs(Xl), [], 1) < tol, 1) - 1;
        if isempty(kk), kk = NaN; end
        steps(r) = kk;
        ax = nexttile(tl);
        draw_traj(ax, X, Kp, agentColour, n);
        hold(ax, 'on');
        plot(ax, Kp, 0, '<', 'Color', [0 0 0], 'MarkerFaceColor', [0 0 0], ...
            'MarkerSize', 5, 'HandleVisibility', 'off');     % the limit is u_1 = 0
        hold(ax, 'off');
        xlim(ax, [0, Kp + 1.5]);
        ylim(ax, [-0.05, 1.05]);
        title(ax, sprintf('%s, FJ, $1-\\lambda_1 = 1/2$', nets{r,1}), ...
            'Interpreter', 'latex', 'FontWeight', 'normal');
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n);
    files{6} = export(fig, here, 'fj_one_prejudiced');
    for r = 1:2
        w = social_power(self_weight(nets{r,2}, 0.5));
        dw = max(abs(w - [2/7; repmat(1/7, n-1, 1)]));
        log{end+1} = sprintf('4. %-19s w(1/2) = [%s]  (max dev %.3e)', nets{r,1}, ...
            strjoin(compose('%.4f', w.'), ' '), dw);
        pass = check(pass, dw < tol, '     MISMATCH, expected (0.2857, 0.1429 x5)');
    end
    log{end+1} = sprintf('4. FDG consensus value at t = 1/2 : %.4f  (expected 0.4286)', aFDG);
    pass = check(pass, abs(aFDG - 3/7) < tol, '     MISMATCH, expected 0.4286');
    for r = 1:2
        lam = ones(n,1); lam(1) = 0.5;
        xi = fj_limit(nets{r,2}, lam, x0);
        log{end+1} = sprintf('4. %-19s FJ limit (middle column) : max |x(inf)| = %.3e | steps to 1e-3 : %d', ...
            nets{r,1}, max(abs(xi)), steps(r));
        pass = check(pass, max(abs(xi)) < tol, '     MISMATCH, expected limit 0');
    end
    pass = check(pass, steps(1) == 59, '     MISMATCH, expected 59 steps on the directed cycle');
    pass = check(pass, steps(2) == 83, '     MISMATCH, expected 83 steps on the bidirectional ring');
    % ADDED (2026-10-30): check on the FDG column, A(1/2).
    for r = 1:2
        Xf = sim_fdg(Afdg2{r}, x0, Kp);
        d60 = max(abs(Xf(:,end) - 3/7));
        log{end+1} = sprintf('4. %-19s FDG, max |x_i(%d) - 3/7| = %.4f', nets{r,1}, Kp, d60);
        pass = check(pass, d60 < 0.01, '     MISMATCH, expected within 0.01 of 0.4286 at k = 60');
    end

    % =================================================================
    % Figure 5 - every agent gives weight 0.2 to its own opinion: FDG against FJ
    % =================================================================
    % REVISED (2026-10-29): the figure becomes the fair comparison between the two models
    % at the same weight 0.2 (FDG self-weight a_ii against FJ attachment 1 - lambda_i),
    % so the two columns are the two models and the two rows the two networks.  The
    % heading above was "Figure 5 - every agent prejudiced".  Was:
    %     lamAll = 0.8 * ones(n,1);
    %     Ka = 25;
    %     fig = new_figure(16, 6);
    %     tl  = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    %     for r = 1:2
    %         W  = nets{r,2};
    %         X  = sim_fj(W, lamAll, x0, x0, Ka);
    %         xi = fj_limit(W, lamAll, x0);
    %         ax = nexttile(tl);
    %         draw_traj(ax, X, Ka, agentColour, n);
    %         hold(ax, 'on');
    %         for i = 1:n
    %             plot(ax, Ka, xi(i), '<', 'Color', agentColour(i,:), ...
    %                 'MarkerFaceColor', agentColour(i,:), 'MarkerSize', 5, ...
    %                 'HandleVisibility', 'off');
    %         end
    %         hold(ax, 'off');
    %         xlim(ax, [0, Ka + 1.5]);
    %         ylim(ax, [-0.05, 1.05]);
    %         title(ax, sprintf('%s, $\\lambda_i = 0.8$', nets{r,1}), ...
    %             'Interpreter', 'latex', 'FontWeight', 'normal');
    %     end
    lamAll = 0.8 * ones(n,1);                       % attachment 1 - lambda_i = 0.2
    Ka = 50;
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    Afdg = cell(2,1);                               % A = 0.2 I + 0.8 W, kept for the checks
    for r = 1:2
        W = nets{r,2};
        % left: the FDG model, the weight 0.2 going to the CURRENT opinion x_i(k)
        A  = 0.2 * eye(n) + 0.8 * W;  Afdg{r} = A;
        Xf = sim_fdg(A, x0, Ka);
        ax = nexttile(tl);
        draw_traj(ax, Xf, Ka, agentColour, n);
        hold(ax, 'on');
        plot(ax, Ka, mean(x0), '<', 'Color', [0 0 0], 'MarkerFaceColor', [0 0 0], ...
            'MarkerSize', 5, 'HandleVisibility', 'off');     % the average, one limit for all
        hold(ax, 'off');
        xlim(ax, [0, Ka + 1.5]);
        ylim(ax, [-0.05, 1.05]);
        title(ax, sprintf('%s, FDG, $a_{ii} = 0.2$', nets{r,1}), ...
            'Interpreter', 'latex', 'FontWeight', 'normal');
        % right: the FJ model, the same weight going to the INITIAL opinion u_i = x_i(0)
        X  = sim_fj(W, lamAll, x0, x0, Ka);
        xi = fj_limit(W, lamAll, x0);
        ax = nexttile(tl);
        draw_traj(ax, X, Ka, agentColour, n);
        hold(ax, 'on');
        for i = 1:n
            plot(ax, Ka, xi(i), '<', 'Color', agentColour(i,:), ...
                'MarkerFaceColor', agentColour(i,:), 'MarkerSize', 5, ...
                'HandleVisibility', 'off');
        end
        hold(ax, 'off');
        xlim(ax, [0, Ka + 1.5]);
        ylim(ax, [-0.05, 1.05]);
        title(ax, sprintf('%s, FJ, $1-\\lambda_i = 0.2$', nets{r,1}), ...
            'Interpreter', 'latex', 'FontWeight', 'normal');
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n);
    files{7} = export(fig, here, 'fj_all_prejudiced');
    expVu = {[0.374;0.467;0.534;0.567;0.559;0.499], [0.394;0.378;0.451;0.549;0.622;0.606]};
    expV1 = {[0.271 0.217 0.173 0.139 0.111 0.089], [0.344 0.180 0.106 0.085 0.106 0.180]};
    for r = 1:2
        V  = Vmat(nets{r,2}, lamAll);
        xi = V * x0;
        dv = max(abs(xi - expVu{r}));
        dr = max(abs(V(1,:) - expV1{r}));
        ds = max(abs(sum(V,2) - 1));
        log{end+1} = sprintf('5. %-19s V u = [%s]  (dev %.3e)', nets{r,1}, ...
            strjoin(compose('%.3f', xi.'), ' '), dv);
        log{end+1} = sprintf('5. %-19s row 1 of V = [%s]  (dev %.3e) | rows sum to 1 : %.2e', ...
            nets{r,1}, strjoin(compose('%.3f', V(1,:)), ' '), dr, ds);
        pass = check(pass, dv < tol && dr < tol && ds < 1e-12, '     MISMATCH');
    end
    % ADDED (2026-10-29): checks on the FDG column, A = 0.2 I + 0.8 W.
    for r = 1:2
        A  = Afdg{r};
        dA = max(max(abs(sum(A,2) - 1)), max(abs(sum(A,1) - 1)));
        Xf = sim_fdg(A, x0, Ka);
        d50 = max(abs(Xf(:,end) - mean(x0)));
        XfL = sim_fdg(A, x0, 4000);
        dinf = max(abs(XfL(:,end) - mean(x0)));
        log{end+1} = sprintf('5. %-19s A doubly-stochastic : %.2e | max |x_i(%d) - 0.5| = %.4f | A^4000 x0 vs 0.5 : %.3e', ...
            nets{r,1}, dA, Ka, d50, dinf);
        pass = check(pass, dA < 1e-12, '     MISMATCH, A is not doubly-stochastic');
        pass = check(pass, d50 < 0.02, '     MISMATCH, expected within 0.02 of 0.5 at k = 50');
        pass = check(pass, dinf < 1e-9, '     MISMATCH, expected A^4000 x0 = 0.5 within 1e-9');
    end

    % =================================================================
    % Figure 6 - auxiliary network, P-dependent and P-independent agents
    % =================================================================
    Wa = zeros(n);
    Wa(1,2) = 1; Wa(2,3) = 1; Wa(3,1) = 1;          % 1 -> 2 -> 3 -> 1
    Wa(4,5) = 1; Wa(5,6) = 1; Wa(6,1) = 1;          % 4 -> 5 -> 6 -> 1
    Wb = Wa;  Wb(2,:) = 0;  Wb(2,3) = 0.5;  Wb(2,1) = 0.5;   % extra edge 2 -> 1
    x0a = [0; 0.5; 1; 0.2; 0.9; 0.6];
    x0d = x0a;  x0d(2) = 1;
    Kx  = 40;
    % REVISED (2026-10-29): a fifth column holds u, so that in (d) only the initial
    % condition x(0) moves and the prejudices stay at x0a.  Was:
    %     cases = { '(a) agent 2 prejudiced',              Wa, 2, x0a; ...
    %               '(b) agent 5 prejudiced',              Wa, 5, x0a; ...
    %               '(c) edge $2 \to 1$, agent 5 prejudiced', Wb, 5, x0a; ...
    %               '(d) as (c) with $x_2(0) = 1$',        Wb, 5, x0d };
    % columns: title, W, prejudiced agent, x(0), u
    cases = { '(a) agent 2 prejudiced',              Wa, 2, x0a, x0a; ...
              '(b) agent 5 prejudiced',              Wa, 5, x0a, x0a; ...
              '(c) edge $2 \to 1$, agent 5 prejudiced', Wb, 5, x0a, x0a; ...
              '(d) as (c), $x_2(0) = 1$, $u$ unchanged', Wb, 5, x0d, x0a };
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    for q = 1:4
        W = cases{q,2};  p = cases{q,3};  xs = cases{q,4};  us = cases{q,5};
        lam = ones(n,1);  lam(p) = 0.5;
        % REVISED (2026-10-29): was "X = sim_fj(W, lam, xs, xs, Kx)", i.e. u = x(0) in
        % every case; now u is taken from the fifth column of CASES.
        X   = sim_fj(W, lam, us, xs, Kx);
        ax  = nexttile(tl);
        draw_traj(ax, X, Kx, agentColour, n);
        title(ax, cases{q,1}, 'Interpreter', 'latex', 'FontWeight', 'normal');
        ylim(ax, [-0.05, 1.05]);
    end
    xlabel(tl, '$k$', 'Interpreter', 'latex');
    ylabel(tl, '$x_i(k)$', 'Interpreter', 'latex');
    shared_legend(tl, ax, agentColour, n);
    files{8} = export(fig, here, 'fj_auxiliary');
    expLim = {0.5*ones(n,1), [], [0.4;0.4;0.4;0.65;0.65;0.4], [0.6;0.6;0.6;0.75;0.75;0.6]};
    for q = 1:4
        W = cases{q,2};  p = cases{q,3};  xs = cases{q,4};  us = cases{q,5};
        lam = ones(n,1);  lam(p) = 0.5;
        rho = max(abs(eig(diag(lam)*W)));
        % REVISED (2026-10-29): was "XL = sim_fj(W, lam, xs, xs, 4000)", as in the figure.
        XL  = sim_fj(W, lam, us, xs, 4000);
        conv = max(abs(XL(:,end) - XL(:,end-1))) < 1e-10;
        if isempty(expLim{q})
            log{end+1} = sprintf('6. %-38s rho(Lambda W) = %.4f | converges : %d', ...
                strip_tex(cases{q,1}), rho, conv);
            pass = check(pass, abs(rho - 1) < 1e-10 && ~conv, ...
                '     MISMATCH, expected rho = 1 and no convergence');
        else
            dl = max(abs(XL(:,end) - expLim{q}));
            log{end+1} = sprintf('6. %-38s limit = [%s]  (dev %.3e)', ...
                strip_tex(cases{q,1}), strjoin(compose('%.3f', XL(:,end).'), ' '), dl);
            pass = check(pass, dl < tol, '     MISMATCH');
        end
    end

    % =================================================================
    % Figure 7 - influence centrality against the attachment of agent 1
    % =================================================================
    ag = 0.01:0.01:1;                               % attachment of agent 1 (and t for FDG)
    C1 = zeros(2, numel(ag));  CX = zeros(2, numel(ag));
    Wp = zeros(1, numel(ag));  WX = zeros(1, numel(ag));
    for j = 1:numel(ag)
        for r = 1:2
            lam = 0.8*ones(n,1);  lam(1) = 1 - ag(j);
            c = centrality(nets{r,2}, lam);
            C1(r,j) = c(1);  CX(r,j) = c.' * x0;
        end
        w = social_power(self_weight(Wcyc, ag(j)));  % identical on the two networks
        Wp(j) = w(1);  WX(j) = w.' * x0;
    end
    fig = new_figure(16, 10);
    tl  = tiledlayout(fig, 2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
    mk1 = 1:5:numel(ag);  mk2 = 3:5:numel(ag);
    ax1 = nexttile(tl); hold(ax1, 'on');
    plot(ax1, ag, Wp, '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, ...
        'DisplayName', '$w_1(t)$, FDG');
    plot(ax1, ag, C1(1,:), '-o', 'Color', agentColour(1,:), 'LineWidth', 1.6, ...
        'MarkerSize', 4, 'MarkerIndices', mk1, 'DisplayName', '$c_1$, directed cycle');
    plot(ax1, ag, C1(2,:), '-x', 'Color', agentColour(1,:), 'LineWidth', 1.0, ...
        'MarkerSize', 6, 'MarkerIndices', mk2, 'DisplayName', '$c_1$, bidirectional ring');
    finish_axes(ax1, [0 1], [0 1.02]);
    ax1.XTickLabel = {};
    ylabel(ax1, 'influence centrality $c_1$', 'Interpreter', 'latex');
    legend(ax1, 'Interpreter', 'latex', 'Location', 'northwest');
    hold(ax1, 'off');
    ax2 = nexttile(tl); hold(ax2, 'on');
    plot(ax2, ag, WX, '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.75, ...
        'DisplayName', '$w(t)^\top x(0)$, FDG');
    plot(ax2, ag, CX(1,:), '-o', 'Color', agentColour(1,:), 'LineWidth', 1.6, ...
        'MarkerSize', 4, 'MarkerIndices', mk1, 'DisplayName', '$c^\top x(0)$, directed cycle');
    plot(ax2, ag, CX(2,:), '-x', 'Color', agentColour(1,:), 'LineWidth', 1.0, ...
        'MarkerSize', 6, 'MarkerIndices', mk2, 'DisplayName', '$c^\top x(0)$, bidirectional ring');
    finish_axes(ax2, [0 1], [0 0.6]);
    xlabel(ax2, 'attachment $1-\lambda_1$ of agent 1 (FJ), self-weight $t$ (FDG)', ...
        'Interpreter', 'latex');
    ylabel(ax2, 'mean final opinion', 'Interpreter', 'latex');
    legend(ax2, 'Interpreter', 'latex', 'Location', 'southwest');
    hold(ax2, 'off');
    files{9} = export(fig, here, 'fj_influence_centrality');
    for av = [0.2, 0.5, 1.0]
        cc = zeros(1,2);
        for r = 1:2
            lam = 0.8*ones(n,1); lam(1) = 1 - av;
            c = centrality(nets{r,2}, lam);
            cc(r) = c(1);
            if av == 0.2
                du = max(abs(c - 1/n));
                pass = check(pass, du < tol, '     MISMATCH, expected c = 1/6 for all agents');
            end
        end
        log{end+1} = sprintf('7. attachment %.1f : c_1 = %.3f (cycle), %.3f (ring)', ...
            av, cc(1), cc(2));
    end
    for r = 1:2
        lam = 0.8*ones(n,1); lam(1) = 0.8;
        log{end+1} = sprintf('7. %-19s attachment 0.2, c = [%s]', nets{r,1}, ...
            strjoin(compose('%.4f', centrality(nets{r,2}, lam).'), ' '));
    end
    e05 = [0.368, 0.328];  e10 = [0.615, 0.485];
    for r = 1:2
        lam = 0.8*ones(n,1); lam(1) = 0.5;  c5 = centrality(nets{r,2}, lam);
        lam(1) = 0;                          c0 = centrality(nets{r,2}, lam);
        pass = check(pass, abs(c5(1)-e05(r)) < tol, sprintf('     MISMATCH at attachment 0.5, %s', nets{r,1}));
        pass = check(pass, abs(c0(1)-e10(r)) < tol, sprintf('     MISMATCH at attachment 1, %s', nets{r,1}));
    end

    % =================================================================
    % Figure 8 - Lemma 24: c_alpha tends to the social power
    % =================================================================
    al = 0:0.005:0.995;
    Cl = zeros(4, numel(al));                       % c1 cyc, c2 cyc, c1 ring, c2 ring
    Wh = {self_weight(Wcyc, 0.5), self_weight(Wring, 0.5)};
    for j = 1:numel(al)
        for r = 1:2
            c = centrality(Wh{r}, al(j)*ones(n,1));
            Cl(2*r-1, j) = c(1);  Cl(2*r, j) = c(2);
        end
    end
    wh = social_power(Wh{1});
    fig = new_figure(16, 7);
    ax  = axes(fig); hold(ax, 'on');
    mkA = 1:10:numel(al);  mkB = 5:10:numel(al);
    ref = yline(ax, wh(1), '--', '$w_1 = 0.2857$', 'Color', [0.45 0.45 0.45], ...
        'LineWidth', 0.75, 'Interpreter', 'latex', ...
        'LabelHorizontalAlignment', 'center', 'LabelVerticalAlignment', 'top');
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    ref = yline(ax, wh(2), '--', '$w_2 = 0.1429$', 'Color', [0.45 0.45 0.45], ...
        'LineWidth', 0.75, 'Interpreter', 'latex', ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    ref = yline(ax, 1/n, ':', '$1/6$', 'Color', [0.45 0.45 0.45], ...
        'LineWidth', 0.75, 'Interpreter', 'latex', ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    ref.Annotation.LegendInformation.IconDisplayStyle = 'off';
    plot(ax, al, Cl(1,:), '-o', 'Color', agentColour(1,:), 'LineWidth', 1.6, ...
        'MarkerSize', 4, 'MarkerIndices', mkA, 'DisplayName', '$c_1$, directed cycle');
    plot(ax, al, Cl(3,:), '-x', 'Color', agentColour(1,:), 'LineWidth', 1.0, ...
        'MarkerSize', 6, 'MarkerIndices', mkB, 'DisplayName', '$c_1$, bidirectional ring');
    plot(ax, al, Cl(2,:), '-o', 'Color', agentColour(2,:), 'LineWidth', 1.6, ...
        'MarkerSize', 4, 'MarkerIndices', mkA, 'DisplayName', '$c_2$, directed cycle');
    plot(ax, al, Cl(4,:), '-x', 'Color', agentColour(2,:), 'LineWidth', 1.0, ...
        'MarkerSize', 6, 'MarkerIndices', mkB, 'DisplayName', '$c_2$, bidirectional ring');
    finish_axes(ax, [0 1], [0.10 0.35]);
    xlabel(ax, 'susceptibility $\alpha$ ($\Lambda = \alpha I$)', 'Interpreter', 'latex');
    ylabel(ax, 'influence centrality', 'Interpreter', 'latex');
    legend(ax, 'Interpreter', 'latex', 'Location', 'northwest');
    hold(ax, 'off');
    files{10} = export(fig, here, 'fj_lemma24');
    c0 = centrality(Wh{1}, zeros(n,1));
    log{end+1} = sprintf('8. c(0) = [%s]  (dev from 1/6 : %.3e)', ...
        strjoin(compose('%.4f', c0.'), ' '), max(abs(c0 - 1/n)));
    pass = check(pass, max(abs(c0 - 1/n)) < tol, '     MISMATCH, expected 1/6 for all agents');
    dend = max(abs([Cl(1,end) Cl(3,end)] - wh(1)));
    dend = max(dend, max(abs([Cl(2,end) Cl(4,end)] - wh(2))));
    log{end+1} = sprintf('8. alpha = 0.995 : max dev of c_1, c_2 from w_1, w_2 : %.4f', dend);
    pass = check(pass, dend < 0.005, '     MISMATCH, expected within 0.005');
    log{end+1} = sprintf('8. minimum of c_2 on the directed cycle : %.3f', min(Cl(2,:)));
    pass = check(pass, abs(min(Cl(2,:)) - 0.137) < 2e-3, '     MISMATCH, expected about 0.137');

    % =================================================================
    print_checks(files, log, pass);
end

% =====================================================================
function A = cycle_matrix(n)
    A = zeros(n);
    for i = 1:n, A(i, mod(i,n)+1) = 1; end
end

function A = ring_matrix(n)
    A = zeros(n);
    for i = 1:n
        A(i, mod(i-2,n)+1) = 0.5;
        A(i, mod(i,  n)+1) = 0.5;
    end
end

function A = self_weight(A, t)
%SELF_WEIGHT  Row 1 of A becomes (1-t) a_1' + t e_1' (eq:self-weight of Chapter 2).
    A(1,:) = (1-t) * A(1,:);
    A(1,1) = A(1,1) + t;
end

function X = sim_fdg(A, x0, K)
    X = zeros(numel(x0), K+1);  X(:,1) = x0;
    for k = 1:K, X(:,k+1) = A * X(:,k); end
end

function X = sim_fj(W, lam, u, x0, K)
    L = diag(lam);  M = L*W;  b = (eye(numel(x0)) - L) * u;
    X = zeros(numel(x0), K+1);  X(:,1) = x0;
    for k = 1:K, X(:,k+1) = M * X(:,k) + b; end
end

function V = Vmat(W, lam)
    L = diag(lam);
    V = (eye(size(W,1)) - L*W) \ (eye(size(W,1)) - L);
end

function xi = fj_limit(W, lam, u)
    xi = Vmat(W, lam) * u;
end

function c = centrality(W, lam)
    V = Vmat(W, lam);
    c = V.' * ones(size(W,1),1) / size(W,1);
end

function w = social_power(A)
    [V, D] = eig(A.');
    [~, j] = min(abs(diag(D) - 1));
    w = real(V(:,j));  w = w / sum(w);
end

% ---------------------------------------------------------------------
function h = draw_traj(ax, X, K, col, n)
%DRAW_TRAJ  One line per agent; agent 1 is black and marked with dots.
    hold(ax, 'on');
    h = gobjects(n,1);
    step = max(1, round((K+1)/10));
    for i = 1:n
        if i == 1
            h(i) = plot(ax, 0:K, X(i,:), '-o', 'Color', col(i,:), 'LineWidth', 1.8, ...
                'MarkerSize', 3, 'MarkerFaceColor', col(i,:), 'MarkerIndices', 1:step:K+1);
        else
            h(i) = plot(ax, 0:K, X(i,:), '-', 'Color', col(i,:), 'LineWidth', 1.0);
        end
    end
    finish_axes(ax, [0 K], []);
    hold(ax, 'off');
end

function finish_axes(ax, xl, yl)
    grid(ax, 'on');  ax.GridAlpha = 0.15;
    if ~isempty(xl), xlim(ax, xl); end
    if ~isempty(yl), ylim(ax, yl); end
end

function lgd = shared_legend(tl, ax, col, n, sym, hExtra, labExtra)
%SHARED_LEGEND  One legend for the whole layout, built from the proxy lines of
%   AGENT_PROXIES, so that every entry carries the style of its own agent and no other
%   object (a reference line, a marker drawn apart, a curve of another panel) can ever
%   be picked up by legend().
%   sym is the symbol of the plotted quantity ('x', '\delta', ...) or, when the rows
%   plot different quantities, the cell array of the labels themselves.
    if nargin < 5, sym = 'x'; end
    if iscell(sym)
        lab = sym;
    else
        lab = arrayfun(@(i) sprintf('$%s_%d$', sym, i), 1:n, 'UniformOutput', false);
    end
    h = agent_proxies(ax, col, n);
    % ADDED (2026-10-28): optional extra entries (e.g. a reference line), appended after
    % the agents; hExtra must be a handle whose style is the one to show in the legend.
    if nargin >= 7 && ~isempty(hExtra)
        h   = [h; hExtra(:)];
        lab = [lab, reshape(labExtra, 1, [])];
    end
    lgd = legend(h, lab, 'Interpreter', 'latex');
    lgd.Layout.Tile = 'east';
end

function h = agent_proxies(ax, col, n)
%AGENT_PROXIES  One invisible line per agent, with EXACTLY the style DRAW_TRAJ gives to
%   that agent's curve (agent 1 black, thick, with dots; the others thin and coloured).
%   They plot NaN, so they change neither the axes nor its limits, and they exist only
%   to be the handles the legend is built from.
    hold(ax, 'on');
    h = gobjects(n,1);
    for i = 1:n
        if i == 1
            h(i) = plot(ax, NaN, NaN, '-o', 'Color', col(i,:), 'LineWidth', 1.8, ...
                'MarkerSize', 3, 'MarkerFaceColor', col(i,:));
        else
            h(i) = plot(ax, NaN, NaN, '-', 'Color', col(i,:), 'LineWidth', 1.0);
        end
    end
    hold(ax, 'off');
end

function s = tex_frac(v)
    if abs(v - 0.5) < eps, s = '1/2'; else, s = sprintf('%g', v); end
end

function s = strip_tex(s)
    s = strrep(strrep(s, '$', ''), '\to', '->');
end

function fig = new_figure(wcm, hcm)
    fig = figure('Visible', 'off', 'Units', 'centimeters', ...
        'Position', [2, 2, wcm, hcm], 'Color', 'w');
    set(fig, 'DefaultAxesFontSize', 9, 'DefaultTextFontSize', 9, ...
             'DefaultLegendFontSize', 9, 'DefaultAxesTickLabelInterpreter', 'latex');
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0, 0, wcm, hcm];
    fig.PaperSize = [wcm, hcm];
end

function f = export(fig, here, name)
    f = fullfile(here, [name '.eps']);
    print(fig, f, '-depsc');
    close(fig);
end

function pass = check(pass, ok, msg)
    if ~ok
        fprintf('%s\n', msg);
        pass = false;
    end
end

function print_checks(files, log, pass)
    fprintf('\n================ NUMERICAL CHECKS ================\n');
    fprintf('files written:\n');
    for i = 1:numel(files), fprintf('  %s\n', files{i}); end
    fprintf('\n');
    for i = 1:numel(log), fprintf('%s\n', log{i}); end
    fprintf('\n%s\n', repmat('=', 1, 50));
    if pass
        fprintf('ALL CHECKS PASSED\n\n');
    else
        fprintf('SOME CHECKS FAILED - see the MISMATCH lines above\n\n');
    end
end
