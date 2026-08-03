%% The Friedkin-Johnsen model
%
%   x(k+1) = Lambda W x(k) + (I - Lambda) u
%
% The discrete-time model with prejudices, and the only one of the four with
% substantial empirical validation.

% Bootstrap: walk up from this file until setup_paths.m is found, then put
% the library on the path. This works whether you are running the .m source
% or the generated .mlx, from any folder.
projectDir = fileparts(mfilename('fullpath'));
while ~isfile(fullfile(projectDir, 'setup_paths.m')) && ...
        ~strcmp(projectDir, fileparts(projectDir))
    projectDir = fileparts(projectDir);
end
addpath(projectDir);
setup_paths;

%% Reproducing Figure 6 of the tutorial
% The influence matrix is the empirically identified one of Friedkin &
% Johnsen (1999), reprinted as Eq. (24). Three susceptibility matrices give
% the three panels. Agent 3 is stubborn in every case, since row 3 of W is e_3.

[net, u, x0] = make_example_fj4();
disp(net.W)

presets = { ...
    fj_lambda(net, 'identity'),         '(a) \Lambda = I: consensus'; ...
    fj_lambda(net, 'classic'),          '(b) \Lambda = I - diag(W): cleavage'; ...
    fj_lambda(net, 'stubborn', [2 3]),  '(c) \Lambda = diag(1,0,0,1)'};

figure;
tl = tiledlayout(3, 1);
for k = 1:3
    r = sim_friedkin_johnsen(net, presets{k, 1}, u, x0, 12);
    plot_opinions(r, 'Axes', nexttile(tl), 'Prejudice', u, ...
        'Title', presets{k, 2}, 'Legend', k == 1);
    fprintf('%-34s limit = %s\n', presets{k, 2}, mat2str(round(r.xinf.', 4)));
end
title(tl, 'Friedkin-Johnsen: reproduction of Fig. 6');

%% Reading the three panels
% (a) Lambda = I removes the anchoring term entirely, so the model IS
%     French-DeGroot and the group converges on agent 3's opinion.
% (b) Friedkin's own coupling lambda_i = 1 - w_ii keeps every agent partly
%     tied to its prejudice. All three free agents move towards agent 3, but
%     a visible cleavage remains -- forever.
% (c) With agents 2 and 3 both stubborn, agents 1 and 4 settle at distinct
%     but very close opinions strictly between the two anchors.

resB = sim_friedkin_johnsen(net, presets{2,1}, u, x0, 60);
resC = sim_friedkin_johnsen(net, presets{3,1}, u, x0, 60);
fprintf('\n(b) residual spread : %.4f\n', max(resB.xinf) - min(resB.xinf));
fprintf('(c) agents 1 and 4  : %.4f and %.4f (difference %.4f)\n', ...
    resC.xinf(1), resC.xinf(4), abs(resC.xinf(1) - resC.xinf(4)));

%% The total-influence matrix V
% x(inf) = V u with V = (I - Lambda W)^{-1} (I - Lambda), and V is
% ROW-STOCHASTIC. The rank of the limit operator is what separates consensus
% from cleavage:
%
%   French-DeGroot   lim W^k = 1 p'   RANK ONE     -> consensus
%   Friedkin-Johnsen x(inf) = V u,  V FULL RANK    -> personal signatures

out = fj_matrices(net.W, presets{2, 1});
disp(round(out.V, 4))
fprintf('row-stochastic : %d\n', out.isRowStochasticV);
fprintf('rho(Lambda W)  : %.6f\n', out.rho);
fprintf('rank(V)        : %d of %d\n', out.rankV, net.n);
fprintf('singular values: %s\n', mat2str(round(out.svdV.', 4)));

%% Exact analytic checks
% Two 2x2 cases from Bullo, Lectures on Network Systems, exercise E5.24(v),
% with exactly known answers. They make the rank point with no numerics at all.

W2 = [0.5 0.5; 0.5 0.5];
o1 = fj_matrices(W2, [0.5; 1]);
o2 = fj_matrices(W2, [0.25; 0.75]);

fprintf('\nLambda = diag(1/2, 1)   -> V = %s, rank %d  (consensus at agent 1''s prejudice)\n', ...
    mat2str(o1.V), o1.rankV);
fprintf('Lambda = diag(1/4, 3/4) -> V = %s, rank %d  (persistent disagreement)\n', ...
    mat2str(round(o2.V, 6)), o2.rankV);

%% Influence centrality and PageRank
% Friedkin's influence centrality c = V'*1/n generalises social power to the
% non-consensus case. With Lambda = alpha*I it converges to French's social
% power as alpha -> 1 (Lemma 24), and it reproduces PageRank with
% alpha = 1 - m and uniform prejudice -- teleportation and prejudice are the
% same mathematical device.

ring = make_ring(7, 'SelfWeight', 0.25);
p = social_power(ring);

fprintf('\n alpha    ||c_alpha - p||_inf\n');
for a = [0.5 0.9 0.99 0.999]
    c = fj_matrices(ring.W, a, 'Warn', false).c;
    fprintf('%6.3f    %.3e\n', a, norm(c - p, Inf));
end

m = 0.15;                                   % Google's damping
cPR = fj_matrices(ring.W, 1 - m, 'Warn', false).c;
fprintf('\nPageRank (m = 0.15) = %s\n', mat2str(round(cPR.', 4)));

%% Stubborn-agent placement
% Which agent should be anchored to move the group most? Make each agent
% totally stubborn in turn and measure the shift in the group mean.

kr = load_krackhardt();
lambdaBase = 0.8 * ones(kr.n, 1);
uBase = zeros(kr.n, 1);

baseline = fj_matrices(kr.W, lambdaBase, 'Warn', false).V * uBase;
shift = zeros(kr.n, 1);
for i = 1:kr.n
    lam = lambdaBase; lam(i) = 0;
    uu = uBase;       uu(i) = 1;            % the anchored agent pushes towards 1
    xi = fj_matrices(kr.W, lam, 'Warn', false).V * uu;
    shift(i) = mean(xi) - mean(baseline);
end

pk = social_power(kr);
figure;
plot_influence_bars([shift, pk], 'Labels', kr.labels, 'Normalize', true, ...
    'SeriesNames', {'shift in group mean', 'social power'}, 'Sort', 'descend', ...
    'Title', 'Which agent moves the group most when anchored?');

fprintf('\ncorrelation(shift, social power) = %.4f\n', pearson_correlation(shift, pk));
[~, best] = max(shift);
fprintf('most effective anchor: manager %d (social power rank %d)\n', ...
    best, find(sort(pk, 'descend') == pk(best), 1));
