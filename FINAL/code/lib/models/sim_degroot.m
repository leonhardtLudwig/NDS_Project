function X = sim_degroot(W, x0, K)
%SIM_DEGROOT French-DeGroot opinion dynamics.
%
%   X = SIM_DEGROOT(W, x0, K) iterates the averaging model
%
%       x(k+1) = W x(k),        k = 0, 1, ..., K-1                     (M1.1)
%
%   for a row-stochastic influence matrix W, and returns the trajectory as an
%   n-by-(K+1) matrix whose column k+1 is x(k).
%
%   x0 may be an n-vector (scalar opinions) or an n-by-m matrix, in which
%   case every column evolves independently and X is n-by-m-by-(K+1); this is
%   the vector-opinion form X(k+1) = W X(k) of (M1.2).
%
%   THEORY
%       W row-stochastic makes each update a CONVEX COMBINATION, so the
%       convex hull of the opinions can only shrink: the model is Lyapunov
%       stable but never asymptotically stable, since W always has the
%       eigenvalue 1.
%
%       Convergence and consensus are decided by the GRAPH, not the weights.
%       Use GRAPH_SUMMARY(W) before simulating: the model converges iff every
%       closed strong component is aperiodic, and reaches consensus iff the
%       graph is additionally rooted.
%
%   Example
%       W  = [1/2 1/2 0; 1/3 1/3 1/3; 0 1/2 1/2];
%       X  = sim_degroot(W, [3; -1; 5], 30);
%       plot_opinions(X)
%
%   See also SIM_FRIEDKIN_JOHNSEN, SOCIAL_POWER, LIMIT_MATRIX, GRAPH_SUMMARY.

    narginchk(3, 3);
    n = check_square(W, 'W');
    if ~is_row_stochastic(W)
        error('NDS:sim_degroot:notStochastic', ...
            'W must be row-stochastic. Use W = row_stochastic(A).');
    end
    x0 = check_state(x0, n);

    X = zeros(size(x0, 1), size(x0, 2), K + 1);
    X(:, :, 1) = x0;

    for k = 1:K
        x0 = W * x0;                  % <-- the model: x(k+1) = W x(k)
        X(:, :, k + 1) = x0;
    end

    if size(X, 2) == 1
        X = reshape(X, n, K + 1);
    end
end
