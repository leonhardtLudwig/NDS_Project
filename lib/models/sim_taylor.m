function res = sim_taylor(A, Gamma, u, x0, t, varargin)
%SIM_TAYLOR Simulate the continuous-time Taylor model with prejudices.
%
%   res = SIM_TAYLOR(A, Gamma, u, x0, t) integrates
%
%       xdot(t) = -(L[A] + Gamma) x(t) + Gamma u,     L[A] = diag(A*1) - A
%
%   on the sample times t, with x0 the state at t(1).
%
%   A      : raw non-negative weights, or a network struct (net.A is used)
%   Gamma  : prejudice rates -- scalar, n-vector, or n-by-n diagonal matrix
%   u      : prejudices, n-by-1 or n-by-d (use TAYLOR_REDUCE to obtain
%            Gamma and u from a persuasibility matrix B and sources s)
%   x0     : initial opinions
%   t      : sample times
%
%   Name-value options
%       'Predict'  also compute the theoretical limit (default true)
%
%   NOTE ON THE INPUT TERM
%       The tutorial prints the matrix form as xdot = -(L + Gamma) x + u
%       (Eq. 15), but consistency with Eq. (14) and with the limit formula of
%       Theorem 18 -- which contains Gamma^11 -- requires the input to be
%       Gamma*u. THIS FUNCTION IMPLEMENTS Gamma*u. An agent with gamma_i = 0
%       is then correctly unaffected by its nominal prejudice.
%
%   MODEL
%       Taylor added external communication sources (mass media,
%       institutions, static leaders) to the Abelson model. The anchoring
%       term turns the SINGULAR M-matrix L into the NONSINGULAR M-matrix
%       L + Gamma exactly when every agent is P-dependent, and the system
%       becomes exponentially stable with a unique equilibrium
%       x* = (L + Gamma) \ (Gamma u) -- a convex combination of the
%       prejudices (Theorem 18, Corollary 19).
%
%       With vector opinions and static leaders this is the classical
%       CONTAINMENT CONTROL problem: all agents converge into the convex hull
%       of the leader positions (Theorem 20).
%
%   IMPLEMENTATION
%       The affine flow is propagated exactly using the augmented matrix
%
%           Maug = [ -(L+Gamma)   Gamma*u ;  0   0 ],
%
%       whose exponential advances [x; I_d] in one shot. This handles the
%       singular case (some agents P-independent) without special-casing,
%       which a direct x* + expm(-Mt)(x0 - x*) formula could not.
%
%   Example
%       net = make_path(6);
%       res = sim_taylor(net, [1 0 0 0 0 1], [-1 0 0 0 0 1]', zeros(6,1), ...
%                        linspace(0, 15, 200));
%
%   See also SIM_ABELSON, SIM_FRIEDKIN_JOHNSEN, TAYLOR_REDUCE, TAYLOR_MATRICES.

    narginchk(5, Inf);

    [A, net] = network_matrix(A, 'A');
    n = validate_nonnegative_matrix(A, 'A');
    gamma = diagonal_parameter(Gamma, n, 'Gamma', 0, Inf);
    [X0, d] = prepare_state(x0, n, 'x0');
    U = match_input_dimension(u, n, d, 'u');
    t = validate_time_vector(t);

    opts = parse_options(struct('Predict', true), varargin, mfilename);

    L = diag(sum(A, 2)) - A;
    M = L + diag(gamma);
    B = gamma .* U;                        % = diag(gamma) * U

    K = numel(t);
    traj = zeros(n, d, K);

    % Augmented system: d/dt [X; I_d] = [-M B; 0 0] [X; I_d].
    Maug = [-M, B; zeros(d, n + d)];
    Xaug0 = [X0; eye(d)];

    [uniform, dt] = is_uniform_grid(t);
    if uniform && K > 1
        step = expm(Maug * dt);
        Xaug = Xaug0;
        traj(:, :, 1) = Xaug(1:n, :);
        for k = 2:K
            Xaug = step * Xaug;
            traj(:, :, k) = Xaug(1:n, :);
        end
    else
        for k = 1:K
            Xaug = expm(Maug * (t(k) - t(1))) * Xaug0;
            traj(:, :, k) = Xaug(1:n, :);
        end
    end

    [xinf, predictInfo] = safe_predict(opts.Predict, ...
        @predict_limit_taylor, A, gamma, U, X0);

    params = struct('A', A, 'gamma', gamma, 'u', U, 'L', L, 'M', M, ...
        'uniformGrid', uniform, 'predict', predictInfo);
    res = pack_result('taylor', t, traj, xinf, params, net);
end
