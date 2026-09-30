function X = sim_friedkin_johnsen(W, lambda, u, x0, K)
%SIM_FRIEDKIN_JOHNSEN Friedkin-Johnsen opinion dynamics.
%
%   X = SIM_FRIEDKIN_JOHNSEN(W, lambda, u, x0, K) iterates
%
%       x(k+1) = Lambda W x(k) + (I - Lambda) u                        (M4.1)
%
%   with Lambda = diag(lambda), and returns the n-by-(K+1) trajectory whose
%   column k+1 is x(k).
%
%       lambda  n-vector of susceptibilities, lambda_i in [0,1]
%       u       n-vector of prejudices
%
%   Equivalently, agent i obeys
%
%       x_i(k+1) = lambda_i * sum_j w_ij x_j(k) + (1 - lambda_i) u_i,
%
%   so 1 - lambda_i measures how tightly agent i is anchored to its prejudice.
%
%   SPECIAL CASES
%       lambda_i = 1 for all i   reduces exactly to French-DeGroot
%       lambda_i = 0             agent i is totally stubborn, x_i(k) = u_i
%       0 < lambda_i < 1         agent i listens AND re-injects its prejudice
%                                at every step -- partial stubbornness, the
%                                behaviour pure averaging cannot express
%
%   WHY IT DIFFERS FROM AVERAGING
%       The update is AFFINE, not linear. The homogeneous part Lambda*W is
%       SUBSTOCHASTIC, so the consensus direction 1 is no longer invariant
%       and the consensus manifold leaves the dynamics altogether. When every
%       agent is reached by a prejudice, rho(Lambda W) < 1 and there is a
%       unique globally attracting equilibrium FJ_EQUILIBRIUM(W, lambda, u).
%
%       So MORE STABILITY MEANS LESS AGREEMENT: the eigenvalue pinned at 1,
%       which carried the consensus mode, is pushed strictly inside the unit
%       disc, and unanimity goes with it.
%
%   Example
%       W = [0.220 0.120 0.360 0.300
%            0.147 0.215 0.344 0.294
%            0     0     1     0
%            0.090 0.178 0.446 0.286];
%       u = [-1; -0.2; 0.6; 1];
%       X = sim_friedkin_johnsen(W, 1 - diag(W), u, u, 15);
%
%   See also FJ_EQUILIBRIUM, TOTAL_INFLUENCE, SIM_DEGROOT.

    narginchk(5, 5);
    n      = check_square(W, 'W');
    lambda = check_vector(lambda, n, 'lambda');
    u      = check_vector(u, n, 'u');
    x0     = check_state(x0, n);

    if ~is_row_stochastic(W)
        error('NDS:sim_friedkin_johnsen:notStochastic', ...
            'W must be row-stochastic. Use W = row_stochastic(A).');
    end
    if any(lambda < 0) || any(lambda > 1)
        error('NDS:sim_friedkin_johnsen:badLambda', ...
            'lambda must lie in [0,1].');
    end

    anchor = (1 - lambda) .* u;          % the constant term (I - Lambda) u
    X = zeros(n, K + 1);
    X(:, 1) = x0;

    for k = 1:K
        x0 = lambda .* (W * x0) + anchor;    % <-- x(k+1) = LWx(k) + (I-L)u
        X(:, k + 1) = x0;
    end
end
