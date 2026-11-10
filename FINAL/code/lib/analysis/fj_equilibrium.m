function xinf = fj_equilibrium(W, lambda, u)
%FJ_EQUILIBRIUM Equilibrium of the Friedkin-Johnsen model.
%
%   xinf = FJ_EQUILIBRIUM(W, lambda, u) returns the unique fixed point of
%
%       x = Lambda W x + (I - Lambda) u
%
%   namely  x(inf) = V u  with  V = TOTAL_INFLUENCE(W, lambda).
%
%   The limit does not depend on x(0): when every agent is reached by a
%   prejudice, the group forgets where it started and remembers only what
%   anchors it.
%
%   Example
%       W = [0.5 0.5; 0.5 0.5];
%       fj_equilibrium(W, [0.25; 0.75], [1; 0])
%
%   See also TOTAL_INFLUENCE, SIM_FRIEDKIN_JOHNSEN, TAYLOR_EQUILIBRIUM.

    n = check_square(W, 'W');
    u = check_vector(u, n, 'u');

    xinf = total_influence(W, lambda) * u;
end
