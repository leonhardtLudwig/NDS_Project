function res = sim_friedkin_johnsen(W, Lambda, u, x0, K, varargin)
%SIM_FRIEDKIN_JOHNSEN Simulate the Friedkin-Johnsen model with prejudices.
%
%   res = SIM_FRIEDKIN_JOHNSEN(W, Lambda, u, x0, K) iterates
%
%       x(k+1) = Lambda*W*x(k) + (I - Lambda)*u,     k = 0, ..., K-1
%
%   returning K+1 samples at times 0..K.
%
%   W      : row-stochastic influence matrix, or a network struct (net.W)
%   Lambda : susceptibilities in [0,1] -- scalar, n-vector, or diagonal
%            matrix; use FJ_LAMBDA for the standard presets
%   u      : prejudices, n-by-1 or n-by-d
%   x0     : initial opinions (pass u to follow Friedkin's own convention
%            that prejudices are the initial opinions)
%   K      : number of steps
%
%   Name-value options
%       'Predict'  also compute the theoretical limit (default true)
%
%   WHY THIS MODEL IS DIFFERENT
%       The update is AFFINE, not linear. The homogeneous part Lambda*W is
%       SUBSTOCHASTIC, so 1 is no longer invariant and the consensus manifold
%       disappears from the dynamics. When every agent is P-dependent,
%       rho(Lambda*W) < 1 and the system is exponentially stable with a
%       unique attracting equilibrium x(inf) = V u, where the total-influence
%       matrix V = (I - Lambda*W)^{-1}(I - Lambda) is ROW-STOCHASTIC.
%
%       So MORE STABILITY MEANS LESS AGREEMENT: the eigenvalue that was
%       pinned at 1, carrying the consensus mode, is pushed strictly inside
%       the unit disc, and with it the possibility of unanimity. Because V is
%       row-stochastic, final opinions stay inside the convex hull of the
%       prejudices -- disagreement is persistent but BOUNDED.
%
%   SPECIAL CASES
%       Lambda = I            reduces exactly to French-DeGroot
%       lambda_i = 0          agent i is totally stubborn, x_i(k) = u_i for k >= 1
%       0 < lambda_i < 1      agent i listens AND re-injects its prejudice at
%                             every step -- partial stubbornness, the object
%                             that pure averaging models cannot express
%
%   Example (reproduces Fig. 6 of the tutorial)
%       [net, u, x0] = make_example_fj4();
%       lambda = fj_lambda(net, 'classic');
%       res = sim_friedkin_johnsen(net, lambda, u, x0, 12);
%       plot_opinions(res, 'Prejudice', u);
%
%   See also FJ_LAMBDA, FJ_MATRICES, PREDICT_LIMIT_FJ, SIM_DEGROOT.

    narginchk(5, Inf);

    [W, net] = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');
    lambda = diagonal_parameter(Lambda, n, 'Lambda', 0, 1);
    [X0, d] = prepare_state(x0, n, 'x0');
    U = match_input_dimension(u, n, d, 'u');

    validateattributes(K, {'numeric'}, ...
        {'scalar', 'integer', 'nonnegative'}, mfilename, 'K', 5);
    K = double(K);

    opts = parse_options(struct('Predict', true), varargin, mfilename);

    anchorTerm = (1 - lambda) .* U;        % = (I - Lambda) * U

    traj = zeros(n, d, K + 1);
    traj(:, :, 1) = X0;
    X = X0;
    for k = 1:K
        X = lambda .* (W * X) + anchorTerm;
        traj(:, :, k + 1) = X;
    end

    [xinf, predictInfo] = safe_predict(opts.Predict, ...
        @predict_limit_fj, W, lambda, U, X0);

    params = struct('W', W, 'lambda', lambda, 'u', U, 'K', K, ...
        'predict', predictInfo);
    res = pack_result('fj', 0:K, traj, xinf, params, net);
end
