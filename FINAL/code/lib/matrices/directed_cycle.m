function A = directed_cycle(n)
%DIRECTED_CYCLE Row-stochastic influence matrix of the directed cycle.
%
%   A = DIRECTED_CYCLE(n) returns the n-by-n matrix with
%
%       a_{i,i+1} = 1       (indices modulo n)
%
%   so agent i listens to agent i+1 only, and nobody has a self-loop. The
%   matrix is already row-stochastic.
%
%   DIRECTION CONVENTION
%       a_ij > 0 means "agent i is influenced by agent j", so row i lists
%       whom agent i listens to and the rows sum to one. This is the
%       convention of the report. RING_GRAPH of the course library uses the
%       opposite direction (agent i listens to agent i-1), so it is NOT a
%       drop-in replacement: its output is the transpose of this one.
%
%   The graph is strongly connected and of period n, so the FDG model on it
%   never settles: all n eigenvalues lie on the unit circle.
%
%   Example
%       directed_cycle(3)
%
%   See also BIDIRECTIONAL_RING, SELF_WEIGHT, SIM_DEGROOT.

    A = zeros(n);
    for i = 1:n
        A(i, mod(i, n) + 1) = 1;
    end
end
