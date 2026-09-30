function X = sim_abelson(A, x0, t)
%SIM_ABELSON Abelson opinion dynamics (continuous-time Laplacian flow).
%
%   X = SIM_ABELSON(A, x0, t) integrates
%
%       xdot(t) = -L x(t),      L = laplacian(A)                       (M2.1)
%
%   equivalently  xdot_i = sum_j a_ij (x_j - x_i),  and returns the n-by-K
%   trajectory sampled at the times in t, with x0 the state at t(1).
%
%   A is the RAW non-negative weight matrix and need NOT be row-stochastic:
%   its row sums are free and set how fast each agent is pulled.
%
%   THEORY
%       The solution is exactly x(t) = exp(-L t) x(0), which is how it is
%       computed here -- no step size, no solver tolerance.
%
%       Unlike the discrete-time model this one ALWAYS converges: L is a
%       singular M-matrix, so its only imaginary-axis eigenvalue is 0. The
%       periodicity that makes French-DeGroot oscillate is an artefact of
%       synchronous discrete updating and simply does not arise here.
%       Consensus holds exactly when the graph is rooted.
%
%   Example
%       A = ring_graph(6);
%       X = sim_abelson(A, (1:6)', linspace(0, 30, 200));
%       plot_opinions(X, linspace(0, 30, 200))
%
%   See also LAPLACIAN, SIM_TAYLOR, SIM_DEGROOT.

    narginchk(3, 3);
    n = check_square(A, 'A');
    x0 = check_state(x0, n);
    t  = t(:).';

    L = laplacian(A);
    X = zeros(n, numel(t));

    for k = 1:numel(t)
        X(:, k) = expm(-L * (t(k) - t(1))) * x0;   % <-- x(t) = exp(-Lt) x(0)
    end
end
