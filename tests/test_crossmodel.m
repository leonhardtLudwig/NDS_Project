function cases = test_crossmodel()
%TEST_CROSSMODEL Consistency tests linking the four models to each other.
%
%   These are simultaneously unit tests and NUMERICAL DEMONSTRATIONS of the
%   theoretical relationships described in docs/01_technical_analysis.md.
%   Each one corresponds to a specific result in the tutorial, and together
%   they are the evidence base for the report's chapter on model connections.

    cases = { ...
        'FJ with Lambda = I is exactly French-DeGroot',        @check_fj_is_degroot; ...
        'FJ equals DeGroot on the augmented stubborn graph',   @check_augmented_graph; ...
        'sampling the Abelson flow gives a DeGroot model',     @check_sampling_lemma17; ...
        'expm and ode45 agree on the Abelson flow',            @check_expm_vs_ode; ...
        'Euler step-size condition for (I - eps*L)',           @check_euler_condition; ...
        'V_alpha -> 1*p'' as alpha -> 1 (Lemma 24)',           @check_valpha_limit; ...
        'V_0 = I: everyone frozen at their prejudice',         @check_valpha_zero; ...
        'Taylor and FJ agree on matched parameters',           @check_taylor_fj_match; ...
        'DeGroot with stubborn agents equals FJ',              @check_stubborn_equivalence; ...
        'continuous time removes the periodicity obstruction', @check_periodicity_is_discrete};
end

% -------------------------------------------------------------------------
function check_fj_is_degroot()
    net = make_ring(6, 'SelfWeight', 0.25);
    x0 = (1:6).';
    u  = 100 * ones(6, 1);              % must be irrelevant when Lambda = I

    resFJ = sim_friedkin_johnsen(net, ones(6, 1), u, x0, 40);
    resDG = sim_degroot(net, x0, 40);
    assert_close(resFJ.X, resDG.X, 1e-14, 'trajectories coincide');
    assert_close(resFJ.xinf, resDG.xinf, 1e-12, 'limits coincide');
end

% -------------------------------------------------------------------------
function check_augmented_graph()
    % FJ is French-DeGroot on a graph with n extra virtual stubborn agents
    % anchored at the prejudices:
    %     rows 1..n   : [lambda_i * W(i,:) , (1-lambda_i) * e_i]
    %     rows n+1..2n: self-loops
    net = make_ring(5, 'SelfWeight', 0.3);
    W = net.W;
    n = 5;
    lambda = [0.2; 0.9; 1.0; 0.5; 0.75];
    u  = [-2; 1; 0; 4; -1];
    x0 = [1; 2; 3; 4; 5];

    Waug = [lambda .* W, diag(1 - lambda); zeros(n), eye(n)];
    assert(is_row_stochastic(Waug, 1e-14), 'augmented matrix is row-stochastic');

    K = 60;
    resAug = sim_degroot(Waug, [x0; u], K, 'Predict', false);
    resFJ  = sim_friedkin_johnsen(W, lambda, u, x0, K);

    assert_close(resAug.X(1:n, :), resFJ.X, 1e-12, ...
        'augmented DeGroot reproduces the FJ trajectory');
end

% -------------------------------------------------------------------------
function check_sampling_lemma17()
    % Lemma 17: W_tau = expm(-tau*L) is row-stochastic with a positive
    % diagonal, so sampling the Abelson flow yields a French-DeGroot model
    % that automatically satisfies the aperiodicity condition.
    net = make_ring(6);                 % periodic in discrete time!
    L = net.L;
    tau = 0.35;
    Wtau = expm(-L * tau);

    assert(is_row_stochastic(Wtau, 1e-12), 'W_tau is row-stochastic');
    assert(all(diag(Wtau) > 0), 'W_tau has a positive diagonal');

    K = 30;
    x0 = (1:6).';
    resDG = sim_degroot(Wtau, x0, K, 'Predict', false);
    resAB = sim_abelson(net, x0, tau * (0:K));
    assert_close(resDG.X, resAB.X, 1e-11, 'sampled flow equals the DeGroot iteration');
end

% -------------------------------------------------------------------------
function check_expm_vs_ode()
    net = make_two_communities(3, 0.15);
    L = net.L;
    x0 = (1:net.n).';
    tspan = linspace(0, 12, 60);

    resExpm = sim_abelson(net, x0, tspan);

    odeOpts = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
    [~, Y] = ode45(@(~, x) -L * x, tspan, x0, odeOpts);

    assert_close(resExpm.X, Y.', 1e-7, 'expm agrees with an independent integrator');
end

% -------------------------------------------------------------------------
function check_euler_condition()
    % The explicit Euler discretisation x(k+1) = (I - eps*L) x(k) is
    % row-stochastic exactly when eps * max_i (row sum of A) <= 1.
    net = make_two_communities(4, 0.5);
    L = net.L;
    maxDegree = max(sum(net.A, 2));

    epsOk = 1 / maxDegree;
    assert(is_row_stochastic(eye(net.n) - epsOk * L, 1e-12), ...
        'row-stochastic at the critical step size');

    epsTooBig = 1.5 / maxDegree;
    Wbad = eye(net.n) - epsTooBig * L;
    assert(~is_row_stochastic(Wbad, 1e-12), ...
        'no longer stochastic beyond the critical step size');
    assert(any(Wbad(:) < 0), 'negative weights appear');

    % Strictly below the bound the diagonal is positive, hence aperiodic.
    epsStrict = 0.9 / maxDegree;
    Wgood = eye(net.n) - epsStrict * L;
    assert(all(diag(Wgood) > 0));
    assert(graph_report(Wgood).reachesConsensus, 'Euler surrogate reaches consensus');
end

% -------------------------------------------------------------------------
function check_valpha_limit()
    % Lemma 24: with Lambda = alpha*I, V_alpha -> 1*p' as alpha -> 1.
    net = make_ring(5, 'SelfWeight', 0.3);
    p = social_power(net);

    out = fj_matrices(net.W, 0.99999);
    assert_close(out.V, ones(5, 1) * p.', 5e-4, 'V_alpha approaches the rank-one limit');

    % The approach is monotone in the sense that the error keeps shrinking.
    errors = arrayfun(@(a) norm(fj_matrices(net.W, a, 'Warn', false).V ...
        - ones(5, 1) * p.', Inf), [0.9, 0.99, 0.999]);
    assert(all(diff(errors) < 0), 'error decreases as alpha increases');
end

% -------------------------------------------------------------------------
function check_valpha_zero()
    net = make_ring(5, 'SelfWeight', 0.3);
    out = fj_matrices(net.W, 0);
    assert_close(out.V, eye(5), 1e-14, 'V_0 = I');
    assert(out.rankV == 5, 'full rank: nobody moves');
end

% -------------------------------------------------------------------------
function check_taylor_fj_match()
    % For a row-stochastic A, dividing row i of (L + Gamma) x = Gamma u by
    % (1 + gamma_i) gives exactly the FJ equilibrium equation with
    % lambda_i = 1 / (1 + gamma_i). The two models must therefore agree.
    net = make_ring(6, 'SelfWeight', 0.2);
    A = net.W;                          % already row-stochastic
    gamma = [1.5; 0; 0.25; 0; 0; 3];
    lambda = 1 ./ (1 + gamma);
    u  = [-2; 0; 1; 0; 0; 5];
    x0 = zeros(6, 1);

    xTaylor = predict_limit_taylor(A, gamma, u, x0);
    xFJ     = predict_limit_fj(A, lambda, u, x0);
    assert_close(xTaylor, xFJ, 1e-11, 'matched Taylor and FJ equilibria coincide');
end

% -------------------------------------------------------------------------
function check_stubborn_equivalence()
    % French-DeGroot with stubborn agents (w_ii = 1) is the FJ model with
    % lambda_i = 0 and u_i = x_i(0) for those agents, lambda_i = 1 otherwise.
    W = [1 0 0 0; 0.25 0.25 0.25 0.25; 0 0 1 0; 0.2 0.3 0.2 0.3];
    assert(is_row_stochastic(W), 'fixture is row-stochastic');
    x0 = [-1; 0; 1; 0.5];

    stubborn = [1 3];
    lambda = ones(4, 1); lambda(stubborn) = 0;
    u = zeros(4, 1);     u(stubborn) = x0(stubborn);

    resDG = sim_degroot(W, x0, 200);
    resFJ = sim_friedkin_johnsen(W, lambda, u, x0, 200);
    assert_close(resDG.X(:, end), resFJ.X(:, end), 1e-10, ...
        'stubborn DeGroot equals the equivalent FJ model');

    % The limit is dictated entirely by the stubborn agents.
    assert_close(resDG.X(stubborn, end), x0(stubborn), 1e-14, 'anchors never move');
end

% -------------------------------------------------------------------------
function check_periodicity_is_discrete()
    % Same graph, two time domains: discrete oscillates, continuous converges.
    net = make_ring(6);
    x0 = (1:6).';

    resDG = sim_degroot(net, x0, 60);
    spreadDG = max(resDG.X, [], 1) - min(resDG.X, [], 1);
    assert(min(spreadDG) > 1e-6, 'the discrete ring never settles');

    resAB = sim_abelson(net, x0, linspace(0, 80, 200));
    spreadAB = max(resAB.X, [], 1) - min(resAB.X, [], 1);
    assert(spreadAB(end) < 1e-6, 'the continuous ring does settle');
end
