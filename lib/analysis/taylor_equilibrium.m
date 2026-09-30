function xstar = taylor_equilibrium(A, gamma, u)
%TAYLOR_EQUILIBRIUM Equilibrium of the Taylor model.
%
%   xstar = TAYLOR_EQUILIBRIUM(A, gamma, u) solves the steady-state equation
%
%       (L + Gamma) x = Gamma u,      L = laplacian(A),  Gamma = diag(gamma)
%
%   and returns the unique equilibrium of the Taylor flow.
%
%   L + Gamma is a NONSINGULAR M-matrix exactly when every agent is reached
%   by a prejudice; the resulting map is stochastic, so the equilibrium is a
%   convex combination of the prejudices. If instead L + Gamma is singular,
%   some agents are untouched by any prejudice, the equilibrium depends on
%   x(0), and this function errors.
%
%   Example
%       A = ring_graph(6, 0.2);
%       taylor_equilibrium(A, [1 0 0 0 0 1], [-1 0 0 0 0 1]')
%
%   See also SIM_TAYLOR, FJ_EQUILIBRIUM, LAPLACIAN.

    n     = check_square(A, 'A');
    gamma = check_vector(gamma, n, 'gamma');
    u     = check_vector(u, n, 'u');

    M = laplacian(A) + diag(gamma);

    if min(real(eig(M))) <= 1e-12 * max(1, norm(M, Inf))
        error('NDS:taylor_equilibrium:singular', ...
            ['L + Gamma is singular, so some agents are never reached by a ' ...
             'prejudice and the equilibrium depends on x(0). Check ' ...
             'PREJUDICE_REACH(A, gamma > 0).']);
    end

    xstar = M \ (gamma .* u);
end
