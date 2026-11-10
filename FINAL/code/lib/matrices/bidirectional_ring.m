function A = bidirectional_ring(n)
%BIDIRECTIONAL_RING Row-stochastic influence matrix of the bidirectional ring.
%
%   A = BIDIRECTIONAL_RING(n) returns the n-by-n matrix with
%
%       a_{i,i-1} = a_{i,i+1} = 1/2     (indices modulo n)
%
%   so agent i splits its attention equally between its two neighbours and
%   nobody has a self-loop. The matrix is already row-stochastic.
%
%   DIRECTION CONVENTION
%       a_ij > 0 means "agent i is influenced by agent j", so row i lists
%       whom agent i listens to and the rows sum to one. See DIRECTED_CYCLE.
%
%   The graph is strongly connected; for even n every cycle has even length,
%   so the period is 2 and the FDG model oscillates.
%
%   Example
%       bidirectional_ring(4)
%
%   See also DIRECTED_CYCLE, SELF_WEIGHT, SIM_DEGROOT.

    A = zeros(n);
    for i = 1:n
        A(i, mod(i - 2, n) + 1) = 0.5;
        A(i, mod(i,     n) + 1) = 0.5;
    end
end
