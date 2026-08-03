function cases = test_models()
%TEST_MODELS Unit tests for the four simulators and their limit predictors.
%
%   The recurring pattern is "theory predicts, simulation confirms": each
%   model is run to steady state and compared against the closed-form limit
%   computed independently by the corresponding PREDICT_LIMIT_* function.

    cases = { ...
        'sim_degroot matches its predicted limit',        @check_degroot; ...
        'sim_degroot refuses to predict a periodic graph',@check_degroot_periodic; ...
        'sim_abelson matches its predicted limit',        @check_abelson; ...
        'sim_abelson converges where DeGroot oscillates', @check_abelson_ring; ...
        'sim_taylor matches its predicted limit',         @check_taylor; ...
        'sim_taylor limit lies in the prejudice hull',    @check_taylor_hull; ...
        'sim_friedkin_johnsen matches its limit',         @check_fj; ...
        'FJ block case with P-independent agents',        @check_fj_blocks; ...
        'taylor_reduce collapses sources correctly',      @check_taylor_reduce; ...
        'fj_lambda presets behave as documented',         @check_fj_lambda; ...
        'simulators accept nets, matrices and shapes',    @check_interfaces; ...
        'vector opinions evolve componentwise',           @check_vector_opinions};
end

% -------------------------------------------------------------------------
function check_degroot()
    net = make_example_french3();
    res = sim_degroot(net, [3; -1; 5], 60);
    assert_close(res.X(:, end), res.xinf, 1e-9, 'simulation reaches the predicted limit');
    p = social_power(net);
    assert_close(res.xinf, repmat(p.' * [3; -1; 5], 3, 1), 1e-12, 'consensus value');
    assert(isequal(res.t, 0:60) && size(res.X, 2) == 61, 'K+1 samples');
end

% -------------------------------------------------------------------------
function check_degroot_periodic()
    net = make_ring(4);
    threw = false;
    try
        predict_limit_degroot(net.W, (1:4).');
    catch err
        threw = strcmp(err.identifier, 'NDS:predictDegroot:notConvergent');
    end
    assert(threw, 'a periodic graph has no limit');

    % The simulator must still return the trajectory, with xinf = NaN.
    res = sim_degroot(net, (1:4).', 8);
    assert(all(isnan(res.xinf)), 'no limit recorded');
    assert_close(res.X(:, 5), res.X(:, 1), 1e-12, 'period 4 returns to the start');
end

% -------------------------------------------------------------------------
function check_abelson()
    net = make_example_french3();
    res = sim_abelson(net, [3; -1; 5], linspace(0, 40, 200));
    assert_close(res.X(:, end), res.xinf, 1e-8, 'flow reaches the predicted limit');

    % Non-uniform grids take the other code path and must agree.
    tNon = [0 0.3 1.1 2.7 6.0 40];
    resNon = sim_abelson(net, [3; -1; 5], tNon);
    resUni = sim_abelson(net, [3; -1; 5], linspace(0, 40, 4001));
    assert_close(resNon.X(:, end), resUni.X(:, end), 1e-10, 'grid paths agree');
end

% -------------------------------------------------------------------------
function check_abelson_ring()
    % The directed ring is periodic, so French-DeGroot oscillates forever;
    % the continuous-time model on the same graph always converges.
    net = make_ring(6);
    res = sim_abelson(net, (1:6).', linspace(0, 60, 200));
    assert_close(res.X(:, end), 3.5 * ones(6, 1), 1e-6, ...
        'ring is doubly stochastic, so the limit is the average');
end

% -------------------------------------------------------------------------
function check_taylor()
    net = make_ring(5, 'SelfWeight', 0.2);
    gamma = [1; 0; 0; 0; 0.5];
    u = [-2; 0; 0; 0; 3];

    % The slowest mode decays like exp(-minRealPart * t), so derive the
    % horizon from the spectrum instead of guessing it. This also documents
    % that the smallest eigenvalue of the grounded Laplacian IS the rate.
    tm = taylor_matrices(net.A, gamma);
    assert(tm.isHurwitz, 'every agent is P-dependent here');
    T = 30 / tm.minRealPart;

    res = sim_taylor(net, gamma, u, zeros(5, 1), linspace(0, T, 600));
    assert_close(res.X(:, end), res.xinf, 1e-9, 'flow reaches the predicted limit');

    % With every agent P-dependent the limit is independent of x0.
    other = sim_taylor(net, gamma, u, 10 * ones(5, 1), linspace(0, T, 600));
    assert_close(other.xinf, res.xinf, 1e-10, 'limit independent of x0');
    assert_close(other.X(:, end), res.X(:, end), 1e-8, ...
        'both trajectories reach the same equilibrium');
end

% -------------------------------------------------------------------------
function check_taylor_hull()
    net = make_ring(6, 'SelfWeight', 0.1);
    gamma = [2; 0; 0; 0; 0; 2];
    u = [-1; 0; 0; 0; 0; 1];
    res = sim_taylor(net, gamma, u, zeros(6, 1), linspace(0, 80, 300));
    anchored = [u(1), u(6)];
    assert(all(res.xinf >= min(anchored) - 1e-9) && ...
           all(res.xinf <= max(anchored) + 1e-9), ...
        'final opinions lie inside the convex hull of the prejudices');
end

% -------------------------------------------------------------------------
function check_fj()
    [net, u, x0] = make_example_fj4();
    lambda = fj_lambda(net, 'classic');
    res = sim_friedkin_johnsen(net, lambda, u, x0, 80);
    assert_close(res.X(:, end), res.xinf, 1e-10, 'iteration reaches the predicted limit');

    out = fj_matrices(net.W, lambda);
    assert_close(res.xinf, out.V * u, 1e-12, 'limit equals V*u');
    assert(out.rankV > 1, 'persistent disagreement means V is not rank one');
end

% -------------------------------------------------------------------------
function check_fj_blocks()
    % Agents 1-2 form a closed averaging pair that no anchor can reach, so
    % they are P-INDEPENDENT; agent 3 listens to them and is anchored.
    W = [0.5 0.5 0; 0.5 0.5 0; 0 0.5 0.5];
    lambda = [1; 1; 0.5];
    u = [0; 0; 10];
    x0 = [4; 8; 0];

    [xinf, info] = predict_limit_fj(W, lambda, u, x0);
    assert(strcmp(info.mode, 'blocks'), 'block decomposition used');
    assert(isequal(info.pIndependent, [1 2]) && isequal(info.pDependent, 3));
    assert_close(xinf(1:2), [6; 6], 1e-12, 'the closed pair averages to 6');

    res = sim_friedkin_johnsen(W, lambda, u, x0, 200);
    assert_close(res.X(:, end), xinf, 1e-9, 'simulation confirms the block limit');
end

% -------------------------------------------------------------------------
function check_taylor_reduce()
    B = [1 3; 0 0; 2 2];
    s = [10; 20];
    [gamma, u] = taylor_reduce(B, s);
    assert_close(gamma, [4; 0; 4], 1e-14, 'total exposure');
    assert_close(u, [(1*10 + 3*20)/4; 0; (2*10 + 2*20)/4], 1e-14, 'weighted prejudice');
end

% -------------------------------------------------------------------------
function check_fj_lambda()
    [net, ~, ~] = make_example_fj4();

    assert_close(fj_lambda(net, 'identity'), ones(4, 1), 0, 'identity preset');
    assert_close(fj_lambda(net, 'classic'), 1 - diag(net.W), 1e-14, 'classic preset');
    assert_close(fj_lambda(net, 'uniform', 0.4), 0.4 * ones(4, 1), 1e-14, 'uniform preset');

    lam = fj_lambda(net, 'stubborn', [2 3]);
    assert_close(lam, [1; 0; 0; 1], 0, 'stubborn preset');

    % Agent 3 has w_33 = 1, so the classic coupling makes it totally stubborn.
    assert_close(fj_lambda(net, 'classic'), [0.78; 0.785; 0; 0.714], 1e-12, ...
        'classic coupling identifies the stubborn agent');
end

% -------------------------------------------------------------------------
function check_interfaces()
    net = make_example_french3();

    fromNet = sim_degroot(net, [1; 0; -1], 10);
    fromMat = sim_degroot(net.W, [1; 0; -1], 10);
    assert_close(fromNet.X, fromMat.X, 0, 'struct and matrix inputs agree');
    assert(~isempty(fromNet.net) && isempty(fromMat.net), 'provenance kept only for structs');

    rowInput = sim_degroot(net, [1 0 -1], 10);
    assert_close(rowInput.X, fromMat.X, 0, 'row vector accepted');

    scalarInput = sim_degroot(net, 2, 5);
    assert_close(scalarInput.X(:, end), 2 * ones(3, 1), 1e-12, 'scalar replicated');

    noPredict = sim_degroot(net, [1; 0; -1], 5, 'Predict', false);
    assert(all(isnan(noPredict.xinf)), 'prediction can be switched off');
end

% -------------------------------------------------------------------------
function check_vector_opinions()
    % Each opinion dimension must evolve independently of the others.
    net = make_example_french3();
    X0 = [1 10; 0 -5; -1 3];

    resVec = sim_degroot(net, X0, 20);
    assert(resVec.d == 2 && isequal(size(resVec.X), [3 2 21]));

    for c = 1:2
        resScalar = sim_degroot(net, X0(:, c), 20);
        slice = reshape(resVec.X(:, c, :), 3, []);
        assert_close(slice, resScalar.X, 1e-14, 'dimension %d evolves independently', c);
    end
end
