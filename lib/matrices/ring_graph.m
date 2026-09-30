function A = ring_graph(n, selfWeight)
%RING_GRAPH Adjacency matrix of a directed ring.
%
%   A = RING_GRAPH(n) returns the n-by-n matrix of the directed cycle in
%   which agent i listens only to agent i-1 (and agent 1 to agent n).
%
%   A = RING_GRAPH(n, s) additionally gives every agent self-weight s, so
%   that A(i,i) = s and A(i,i-1) = 1 - s.
%
%   WHY THIS GRAPH MATTERS
%       With s = 0, A is a PERMUTATION matrix: strongly connected, doubly
%       stochastic, but PERIODIC with period n. The French-DeGroot model then
%       never converges -- the opinion vector rotates forever. It is the
%       counterexample showing that strong connectivity alone is not enough
%       for consensus.
%
%       Any s > 0 creates self-loops, making the graph aperiodic, so the model
%       converges -- and being doubly stochastic, it converges to the plain
%       average of the initial opinions.
%
%   See also STAR_GRAPH, PATH_GRAPH, COMPLETE_GRAPH, TWO_COMMUNITIES.

    if nargin < 2, selfWeight = 0; end

    A = zeros(n);
    predecessor = [n, 1:n-1];
    for i = 1:n
        A(i, predecessor(i)) = 1 - selfWeight;
    end
    A = A + selfWeight * eye(n);
end
