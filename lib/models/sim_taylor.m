function X = sim_taylor(A, gamma, u, x0, t)
%SIM_TAYLOR Taylor opinion dynamics (Abelson with prejudices).
%
%   X = SIM_TAYLOR(A, gamma, u, x0, t) integrates
%
%       xdot(t) = -(L + Gamma) x(t) + Gamma u,   L = laplacian(A)      (M3.1)
%
%   with Gamma = diag(gamma), and returns the n-by-K trajectory sampled at
%   the times in t, with x0 the state at t(1).
%
%       gamma  n-vector of prejudice rates, gamma_i >= 0
%       u      n-vector of prejudices
%
%   Equivalently, agent i obeys
%
%       xdot_i = sum_j a_ij (x_j - x_i) + gamma_i (u_i - x_i).
%
%   NOTE ON THE INPUT TERM
%       The tutorial prints the matrix form as "xdot = -(L + Gamma) x + u"
%       (Eq. 15), but consistency with Eq. (14) and with the limit formula of
%       Theorem 18 -- which contains Gamma^11 -- requires the input to be
%       Gamma*u. This function implements Gamma*u, so an agent with
%       gamma_i = 0 is correctly unaffected by its nominal prejudice.
%
%   THEORY
%       Anchoring turns the SINGULAR M-matrix L into the NONSINGULAR
%       M-matrix L + Gamma whenever every agent is reached by a prejudice,
%       and the flow becomes exponentially stable with the equilibrium
%       TAYLOR_EQUILIBRIUM(A, gamma, u).
%
%   IMPLEMENTATION
%       The affine flow is propagated exactly by augmenting the state with a
%       constant 1, so that [x; 1] obeys a linear system and one matrix
%       exponential does the whole job:
%
%           d/dt [x; 1] = [-(L+Gamma)  Gamma*u ; 0  0] [x; 1].
%
%   Example
%       A = ring_graph(6, 0.2);
%       X = sim_taylor(A, [1 0 0 0 0 1], [-1 0 0 0 0 1]', zeros(6,1), 0:0.1:30);
%
%   See also TAYLOR_EQUILIBRIUM, SIM_ABELSON, SIM_FRIEDKIN_JOHNSEN.

    narginchk(5, 5);
    n     = check_square(A, 'A');
    gamma = check_vector(gamma, n, 'gamma');
    u     = check_vector(u, n, 'u');
    x0    = check_state(x0, n);
    t     = t(:).';

    if any(gamma < 0)
        error('NDS:sim_taylor:negativeGamma', 'gamma must be non-negative.');
    end

    M = laplacian(A) + diag(gamma);
    b = gamma .* u;                      % the input term Gamma*u

    Maug = [-M, b; zeros(1, n + 1)];
    X = zeros(n, numel(t));

    for k = 1:numel(t)
        z = expm(Maug * (t(k) - t(1))) * [x0; 1];
        X(:, k) = z(1:n);
    end
end
