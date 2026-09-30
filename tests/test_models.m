function cases = test_models()
%TEST_MODELS Tests for the four simulators and their equilibria.
%
%   The recurring pattern is "theory predicts, simulation confirms": each
%   model is run to steady state and compared against the closed-form limit
%   computed independently.

    cases = { ...
        'sim_degroot reaches p''x(0)',                 @check_degroot; ...
        'sim_degroot oscillates on a periodic ring',   @check_degroot_periodic; ...
        'sim_degroot handles vector opinions',         @check_degroot_vector; ...
        'sim_abelson matches exp(-Lt)x(0)',            @check_abelson; ...
        'sim_abelson converges where DeGroot does not',@check_abelson_ring; ...
        'sim_taylor reaches taylor_equilibrium',       @check_taylor; ...
        'sim_taylor limit lies in the prejudice hull', @check_taylor_hull; ...
        'sim_friedkin_johnsen reaches V*u',            @check_fj; ...
        'total_influence V is row-stochastic',         @check_V_stochastic; ...
        'equilibria reject the unreachable case',      @check_unreachable};
end

% -------------------------------------------------------------------------
function check_degroot()
    W = example_french3();
    x0 = [3; -1; 5];
    X = sim_degroot(W, x0, 60);
    p = social_power(W);

    assert(isequal(size(X), [3 61]), 'n by K+1');
    assert_close(X(:, 1), x0, 0, 'first column is x(0)');
    assert_close(X(:, end), (p.' * x0) * ones(3, 1), 1e-9, 'consensus at p''x(0)');
    assert_close(X(:, end), limit_matrix(W) * x0, 1e-9, 'agrees with W^inf x(0)');
end

% -------------------------------------------------------------------------
function check_degroot_periodic()
    W = row_stochastic(ring_graph(4));
    X = sim_degroot(W, (1:4).', 8);
    assert_close(X(:, 5), X(:, 1), 1e-12, 'period 4 returns to the start');
    assert_error(@() limit_matrix(W), 'NDS:limit_matrix:noLimit');
end

% -------------------------------------------------------------------------
function check_degroot_vector()
    % Every opinion dimension must evolve independently of the others.
    W = example_french3();
    X0 = [1 10; 0 -5; -1 3];
    X = sim_degroot(W, X0, 20);
    assert(isequal(size(X), [3 2 21]), 'n by m by K+1');
    for c = 1:2
        scalarRun = sim_degroot(W, X0(:, c), 20);
        assert_close(squeeze(X(:, c, :)), scalarRun, 1e-14, 'column %d', c);
    end
end

% -------------------------------------------------------------------------
function check_abelson()
    A = example_french3();
    t = linspace(0, 12, 40);
    X = sim_abelson(A, [3; -1; 5], t);

    L = laplacian(A);
    for k = [1 10 40]
        assert_close(X(:, k), expm(-L * t(k)) * [3; -1; 5], 1e-12, ...
            'sample %d equals exp(-Lt)x(0)', k);
    end

    % Rooted graph -> consensus at p'x(0) with p the left null vector of L.
    p = null(L.'); p = p / sum(p);
    Xlong = sim_abelson(A, [3; -1; 5], [0 60]);
    assert_close(Xlong(:, end), (p.' * [3; -1; 5]) * ones(3, 1), 1e-8, 'limit');
end

% -------------------------------------------------------------------------
function check_abelson_ring()
    % The directed ring is periodic, so French-DeGroot oscillates forever;
    % the continuous-time model on the same graph always converges.
    A = ring_graph(6);
    X = sim_abelson(A, (1:6).', [0 80]);
    assert_close(X(:, end), 3.5 * ones(6, 1), 1e-8, ...
        'doubly stochastic, so the limit is the average');
end

% -------------------------------------------------------------------------
function check_taylor()
    A = ring_graph(5, 0.2);
    gamma = [1; 0; 0; 0; 0.5];
    u = [-2; 0; 0; 0; 3];

    xstar = taylor_equilibrium(A, gamma, u);
    M = laplacian(A) + diag(gamma);
    assert_close(M * xstar, gamma .* u, 1e-12, 'satisfies (L+G)x = Gu');

    % Integrate long enough for the slowest mode to die.
    T = 30 / min(real(eig(M)));
    X = sim_taylor(A, gamma, u, zeros(5, 1), linspace(0, T, 400));
    assert_close(X(:, end), xstar, 1e-9, 'flow reaches the equilibrium');

    % The limit does not depend on x(0).
    X2 = sim_taylor(A, gamma, u, 10 * ones(5, 1), linspace(0, T, 400));
    assert_close(X2(:, end), xstar, 1e-8, 'independent of x(0)');
end

% -------------------------------------------------------------------------
function check_taylor_hull()
    A = ring_graph(6, 0.1);
    gamma = [2; 0; 0; 0; 0; 2];
    u = [-1; 0; 0; 0; 0; 1];
    xstar = taylor_equilibrium(A, gamma, u);
    assert(all(xstar >= -1 - 1e-9) && all(xstar <= 1 + 1e-9), ...
        'final opinions lie inside the convex hull of the prejudices');
end

% -------------------------------------------------------------------------
function check_fj()
    [W, u] = example_fj4();
    lambda = 1 - diag(W);
    X = sim_friedkin_johnsen(W, lambda, u, u, 80);
    xinf = fj_equilibrium(W, lambda, u);

    assert(isequal(size(X), [4 81]), 'n by K+1');
    assert_close(X(:, end), xinf, 1e-10, 'iteration reaches V*u');
    assert_close(xinf, total_influence(W, lambda) * u, 1e-14, 'equals V*u');
end

% -------------------------------------------------------------------------
function check_V_stochastic()
    W = row_stochastic(ring_graph(6, 0.2));
    V = total_influence(W, 0.7);
    assert_close(sum(V, 2), ones(6, 1), 1e-12, 'V is row-stochastic');
    assert(all(V(:) >= -1e-12), 'V is non-negative');
    assert(rank(V) == 6, 'full rank means persistent disagreement');
end

% -------------------------------------------------------------------------
function check_unreachable()
    % Agents 1-2 form a closed averaging pair no prejudice can reach.
    W = [0.5 0.5 0; 0.5 0.5 0; 0 0.5 0.5];
    lambda = [1; 1; 0.5];
    reached = prejudice_reach(W, lambda < 1);
    assert(isequal(reached(:).', [false false true]), 'only agent 3 is reached');
    assert_error(@() total_influence(W, lambda), 'NDS:total_influence:notStable');

    A = [0 1 0; 1 0 0; 0 1 0];
    assert_error(@() taylor_equilibrium(A, [0; 0; 1], [0; 0; 1]), ...
        'NDS:taylor_equilibrium:singular');
end

% -------------------------------------------------------------------------
function assert_error(fcn, expectedId)
    try
        fcn();
    catch err
        assert(strcmp(err.identifier, expectedId), ...
            'expected %s, got %s', expectedId, err.identifier);
        return;
    end
    error('expected error %s but none was raised', expectedId);
end
