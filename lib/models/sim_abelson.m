function res = sim_abelson(A, x0, t, varargin)
%SIM_ABELSON Simulate the continuous-time Abelson model (Laplacian flow).
%
%   res = SIM_ABELSON(A, x0, t) integrates
%
%       xdot(t) = -L[A] x(t),      L[A] = diag(A*1) - A
%
%   on the sample times t, with x0 the state at t(1).
%
%   A may be a matrix or a network struct (net.A is used -- the RAW weights,
%   NOT the row-stochastic ones). x0 may be a scalar, an n-vector or an
%   n-by-d matrix.
%
%   Name-value options
%       'Predict'  also compute the theoretical limit (default true)
%
%   MODEL
%       Each agent is pulled towards every agent it listens to:
%           xdot_i = sum_j a_ij (x_j - x_i).
%       Unlike French-DeGroot, A need NOT be row-stochastic: the row sums are
%       free and set how fast each agent is pulled.
%
%   KEY STRUCTURAL FACT
%       The Abelson model is ALWAYS convergent. L is a singular M-matrix, so
%       the zero eigenvalue is semisimple and every other eigenvalue has
%       strictly positive real part; there is no eigenvalue on the imaginary
%       axis other than 0. The periodicity obstruction that makes the
%       French-DeGroot model oscillate is an artefact of synchronous
%       discrete-time updating and simply does not exist here. Consensus is
%       reached exactly when the graph is rooted (Theorem 16).
%
%   IMPLEMENTATION
%       The flow is propagated with the matrix exponential rather than a
%       generic ODE solver: for a linear time-invariant system EXPM is exact
%       up to round-off and needs no step-size tuning. On a uniformly spaced
%       time vector the one-step propagator is computed ONCE and applied
%       repeatedly, which is both faster and more accurate than calling EXPM
%       at every sample.
%
%   Example
%       net = make_ring(6, 'Type', 'directed');
%       res = sim_abelson(net, (1:6)', linspace(0, 20, 200));
%       plot_opinions(res);   % converges, unlike the discrete-time ring
%
%   See also SIM_TAYLOR, SIM_DEGROOT, PREDICT_LIMIT_ABELSON, LAPLACIAN_POWER.

    narginchk(3, Inf);

    [A, net] = network_matrix(A, 'A');
    n = validate_nonnegative_matrix(A, 'A');
    [X0, d] = prepare_state(x0, n, 'x0');
    t = validate_time_vector(t);

    opts = parse_options(struct('Predict', true), varargin, mfilename);

    L = diag(sum(A, 2)) - A;
    K = numel(t);
    traj = zeros(n, d, K);

    [uniform, dt] = is_uniform_grid(t);
    if uniform && K > 1
        step = expm(-L * dt);
        X = X0;
        traj(:, :, 1) = X;
        for k = 2:K
            X = step * X;
            traj(:, :, k) = X;
        end
    else
        for k = 1:K
            traj(:, :, k) = expm(-L * (t(k) - t(1))) * X0;
        end
    end

    [xinf, predictInfo] = safe_predict(opts.Predict, ...
        @predict_limit_abelson, A, X0);

    params = struct('A', A, 'L', L, 'uniformGrid', uniform, 'predict', predictInfo);
    res = pack_result('abelson', t, traj, xinf, params, net);
end
