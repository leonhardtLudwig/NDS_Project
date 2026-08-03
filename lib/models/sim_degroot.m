function res = sim_degroot(W, x0, K, varargin)
%SIM_DEGROOT Simulate the French-DeGroot averaging model.
%
%   res = SIM_DEGROOT(W, x0, K) iterates
%
%       x(k+1) = W x(k),        k = 0, 1, ..., K-1
%
%   for a row-stochastic influence matrix W, returning the standard result
%   structure with K+1 samples at times 0..K.
%
%   W may be a matrix or a network struct (net.W is used).
%   x0 may be a scalar, an n-vector, or an n-by-d matrix of vector opinions.
%
%   Name-value options
%       'Predict'  also compute the theoretical limit via
%                  PREDICT_LIMIT_DEGROOT (default true)
%
%   Result fields: see PACK_RESULT. res.xinf holds the predicted limit
%   (NaN when the model does not converge, e.g. on a periodic graph).
%
%   MODEL
%       Each agent replaces its opinion by a weighted average of the opinions
%       it observes. Because W is row-stochastic the update is a CONVEX
%       COMBINATION, so the convex hull of the opinions can only shrink: the
%       model is Lyapunov stable but never asymptotically stable, since W
%       always has the eigenvalue 1 with eigenvector 1.
%
%       Convergence and consensus are decided purely by the GRAPH, not by the
%       weights (Theorem 12): convergent iff every closed strong component is
%       aperiodic; consensual iff additionally the graph is rooted. Use
%       GRAPH_REPORT to check before simulating.
%
%   IMPLEMENTATION
%       The recursion is iterated directly rather than forming W^k, which
%       would be both slower and less accurate for large k.
%
%   Example
%       net = make_example_french3();
%       res = sim_degroot(net, [1; 0; -1], 30);
%       plot_opinions(res);
%
%   See also SIM_FRIEDKIN_JOHNSEN, PREDICT_LIMIT_DEGROOT, GRAPH_REPORT.

    narginchk(3, Inf);

    [W, net] = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');
    [X0, d] = prepare_state(x0, n, 'x0');

    validateattributes(K, {'numeric'}, ...
        {'scalar', 'integer', 'nonnegative'}, mfilename, 'K', 3);
    K = double(K);

    opts = parse_options(struct('Predict', true), varargin, mfilename);

    traj = zeros(n, d, K + 1);
    traj(:, :, 1) = X0;
    X = X0;
    for k = 1:K
        X = W * X;
        traj(:, :, k + 1) = X;
    end

    [xinf, predictInfo] = safe_predict(opts.Predict, ...
        @predict_limit_degroot, W, X0);

    params = struct('W', W, 'K', K, 'predict', predictInfo);
    res = pack_result('degroot', 0:K, traj, xinf, params, net);
end
