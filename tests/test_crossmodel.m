function cases = test_crossmodel()
%TEST_CROSSMODEL Consistency tests linking the four models to each other.
%
%   These are simultaneously regression tests and NUMERICAL DEMONSTRATIONS of
%   the theoretical relationships: each corresponds to a specific result in
%   the tutorial, and together they are the evidence for the chapter on how
%   the models connect.

    cases = { ...
        'lambda = 1 makes FJ exactly French-DeGroot',      @check_fj_is_degroot; ...
        'FJ equals DeGroot on the augmented stubborn graph',@check_augmented; ...
        'sampling the Abelson flow gives a DeGroot model',  @check_sampling; ...
        'Euler step-size condition for (I - eps*L)',        @check_euler; ...
        'V_alpha -> 1p'' as alpha -> 1, and V_0 = I',       @check_valpha; ...
        'Taylor and FJ agree on matched parameters',        @check_taylor_fj; ...
        'DeGroot with stubborn agents equals FJ',           @check_stubborn; ...
        'continuous time removes the periodicity problem',  @check_periodicity};
end

% -------------------------------------------------------------------------
function check_fj_is_degroot()
    W = row_stochastic(ring_graph(6, 0.25));
    x0 = (1:6).';
    u = 100 * ones(6, 1);              % must be irrelevant when lambda = 1

    assert_close(sim_friedkin_johnsen(W, ones(6, 1), u, x0, 40), ...
                 sim_degroot(W, x0, 40), 1e-14, 'trajectories coincide');
end

% -------------------------------------------------------------------------
function check_augmented()
    % FJ is French-DeGroot on a graph with n extra virtual stubborn agents
    % anchored at the prejudices.
    W = row_stochastic(ring_graph(5, 0.3));
    n = 5;
    lambda = [0.2; 0.9; 1.0; 0.5; 0.75];
    u  = [-2; 1; 0; 4; -1];
    x0 = (1:5).';

    Waug = [lambda .* W, diag(1 - lambda); zeros(n), eye(n)];
    assert(is_row_stochastic(Waug), 'the augmented matrix is stochastic');

    Xaug = sim_degroot(Waug, [x0; u], 60);
    Xfj  = sim_friedkin_johnsen(W, lambda, u, x0, 60);
    assert_close(Xaug(1:n, :), Xfj, 1e-12, 'augmented DeGroot reproduces FJ');
end

% -------------------------------------------------------------------------
function check_sampling()
    % W_tau = exp(-tau L) is row-stochastic with a positive diagonal, so
    % sampling the Abelson flow yields an aperiodic French-DeGroot model --
    % which is why the continuous model can never oscillate.
    A = ring_graph(6);                 % periodic in discrete time!
    tau = 0.35;
    Wtau = expm(-laplacian(A) * tau);

    assert(is_row_stochastic(Wtau, 1e-12), 'W_tau is row-stochastic');
    assert(all(diag(Wtau) > 0), 'W_tau has a positive diagonal');

    K = 30;
    x0 = (1:6).';
    assert_close(sim_degroot(Wtau, x0, K), sim_abelson(A, x0, tau * (0:K)), ...
        1e-11, 'sampled flow equals the DeGroot iteration');
end

% -------------------------------------------------------------------------
function check_euler()
    % x(k+1) = (I - eps L) x(k) is row-stochastic exactly when
    % eps * max_i (row sum of A) <= 1.
    A = two_communities(4, 4, 0.5);
    L = laplacian(A);
    maxDegree = max(sum(A, 2));
    n = size(A, 1);

    assert(is_row_stochastic(eye(n) - (1/maxDegree) * L, 1e-12), ...
        'stochastic at the critical step size');

    tooBig = eye(n) - (1.5/maxDegree) * L;
    assert(~is_row_stochastic(tooBig, 1e-12) && any(tooBig(:) < 0), ...
        'negative weights appear beyond the bound');

    strict = eye(n) - (0.9/maxDegree) * L;
    assert(all(diag(strict) > 0), 'strictly below the bound the diagonal is positive');
    s = graph_summary(strict);
    assert(s.consensus, 'the Euler surrogate reaches consensus');
end

% -------------------------------------------------------------------------
function check_valpha()
    % V_alpha = (1-alpha)(I - alpha W)^{-1} interpolates between I and 1p'.
    W = row_stochastic(ring_graph(5, 0.3));
    p = social_power(W);

    assert_close(total_influence(W, 0), eye(5), 1e-14, 'V_0 = I');

    assert_close(total_influence(W, 0.99999), ones(5, 1) * p.', 5e-4, ...
        'V_alpha approaches the rank-one limit');

    errors = arrayfun(@(a) norm(total_influence(W, a) - ones(5,1) * p.', Inf), ...
        [0.9 0.99 0.999]);
    assert(all(diff(errors) < 0), 'the error shrinks as alpha increases');
end

% -------------------------------------------------------------------------
function check_taylor_fj()
    % For a row-stochastic A, dividing row i of (L + Gamma)x = Gamma u by
    % (1 + gamma_i) gives exactly the FJ equilibrium equation with
    % lambda_i = 1/(1 + gamma_i), so the two models must agree.
    W = row_stochastic(ring_graph(6, 0.2));
    gamma  = [1.5; 0; 0.25; 0; 0; 3];
    lambda = 1 ./ (1 + gamma);
    u = [-2; 0; 1; 0; 0; 5];

    assert_close(taylor_equilibrium(W, gamma, u), fj_equilibrium(W, lambda, u), ...
        1e-11, 'matched equilibria coincide');
end

% -------------------------------------------------------------------------
function check_stubborn()
    % French-DeGroot with stubborn agents (w_ii = 1) is the FJ model with
    % lambda_i = 0 and u_i = x_i(0) for those agents.
    W = [1 0 0 0; 0.25 0.25 0.25 0.25; 0 0 1 0; 0.2 0.3 0.2 0.3];
    x0 = [-1; 0; 1; 0.5];
    stubborn = [1 3];

    lambda = ones(4, 1); lambda(stubborn) = 0;
    u = zeros(4, 1);     u(stubborn) = x0(stubborn);

    Xdg = sim_degroot(W, x0, 200);
    Xfj = sim_friedkin_johnsen(W, lambda, u, x0, 200);
    assert_close(Xdg(:, end), Xfj(:, end), 1e-10, 'the two agree');
    assert_close(Xdg(stubborn, end), x0(stubborn), 1e-14, 'anchors never move');
end

% -------------------------------------------------------------------------
function check_periodicity()
    % Same graph, two time domains: discrete oscillates, continuous converges.
    A = ring_graph(6);
    x0 = (1:6).';

    Xd = sim_degroot(row_stochastic(A), x0, 60);
    spreadD = max(Xd, [], 1) - min(Xd, [], 1);
    assert(min(spreadD) > 1e-6, 'the discrete ring never settles');

    Xc = sim_abelson(A, x0, linspace(0, 80, 100));
    spreadC = max(Xc, [], 1) - min(Xc, [], 1);
    assert(spreadC(end) < 1e-6, 'the continuous ring does settle');
end
