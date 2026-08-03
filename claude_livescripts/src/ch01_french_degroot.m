%% The French-DeGroot model
% The discrete-time averaging model
%
%   x(k+1) = W x(k),   W row-stochastic
%
% Each agent replaces its opinion by a weighted average of what it observes.

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

%% Analytic ground truth
% The three-agent example of the tutorial (Fig. 4) has an exactly known
% social power vector, p = [2/7, 3/7, 2/7]'. Any implementation that cannot
% reproduce it is wrong.

net = make_example_french3();
p = social_power(net);
fprintf('social power    : %s\n', mat2str(round(p.', 6)));
fprintf('analytic value  : %s\n', mat2str(round([2/7 3/7 2/7], 6)));

x0 = [3; -1; 5];
res = sim_degroot(net, x0, 30);
fprintf('predicted limit : %.6f\n', res.xinf(1));
fprintf('p''*x(0)         : %.6f\n', p.' * x0);

figure; plot_opinions(res);

%% Convergence is not the same as consensus
% Two distinct questions, decided entirely by the GRAPH and not by the
% weights. The directed ring is the counterexample that separates them: it is
% strongly connected, so every node is a root, but it is PERIODIC and the
% opinions rotate forever.

ring = make_ring(6);
graph_report(ring.W);

resRing = sim_degroot(ring, (1:6).', 24);
figure; plot_opinions(resRing, 'Title', 'Directed ring: strongly connected but periodic');

fprintf('\nlimit recorded? %d  (NaN means no limit exists)\n', all(isfinite(resRing.xinf)));
fprintf('x(0) vs x(6):   %s  vs  %s\n', ...
    mat2str(resRing.X(:,1).'), mat2str(resRing.X(:,7).'));

%% A single self-loop repairs it
% Positive self-weights force aperiodicity, so Corollary 13 applies:
% convergence is automatic and consensus follows from rootedness alone.

lazy = make_ring(6, 'SelfWeight', 0.25);
resLazy = sim_degroot(lazy, (1:6).', 60);
figure; plot_opinions(resLazy, 'Title', 'Lazy ring: doubly stochastic, so average consensus');
fprintf('limit = %.6f, average of x(0) = %.6f\n', resLazy.xinf(1), mean(1:6));

%% The conserved quantity
% Because p'W = p', the weighted average p'x(k) never changes. This is the
% sharpest numerical check available for an averaging implementation.

resCheck = sim_degroot(net, x0, 40);
invariant = p.' * resCheck.X;
figure;
plot(resCheck.t, invariant, 'LineWidth', 1.6); grid on;
xlabel('step k'); ylabel('p^T x(k)');
title(sprintf('Conserved: drift over 40 steps = %.2e', max(abs(invariant - invariant(1)))));

%% Social power on real data
% On Krackhardt's advice network the model reaches consensus, and social
% power identifies who determines it. Four managers -- 6, 13, 16 and 17 --
% have EXACTLY zero power: nobody seeks their advice, so their opinions are
% forgotten entirely.

kr = load_krackhardt();
pk = social_power(kr);
[sorted, order] = sort(pk, 'descend');

fprintf('\nrank  manager  social power\n');
for k = 1:6
    fprintf('%4d  %7s  %12.4f\n', k, kr.labels{order(k)}, sorted(k));
end
fprintf('zero power: %s\n', mat2str(find(pk < 1e-12).'));

figure;
plot_influence_bars(pk, 'Labels', kr.labels, 'Sort', 'descend', ...
    'Title', 'Krackhardt advice network: French-DeGroot social power');

figure;
plot_network(kr, 'NodeValue', pk, 'NodeSize', pk, 'Direction', 'influence', ...
    'Title', 'Node colour and size = social power');

%% Social power is not degree
% The most-consulted manager is not the most influential: influence is a
% spectral quantity, not a local count.

inDegree = sum(kr.A, 1).';
[~, byDegree] = max(inDegree);
[~, byPower]  = max(pk);
fprintf('highest in-degree : manager %d\n', byDegree);
fprintf('highest power     : manager %d\n', byPower);

figure;
scatter(inDegree, pk, 50, 'filled'); grid on;
text(inDegree + 0.3, pk, kr.labels, 'FontSize', 8);
xlabel('in-degree (times consulted)'); ylabel('social power');
title('Structural degree does not determine dynamic influence');
