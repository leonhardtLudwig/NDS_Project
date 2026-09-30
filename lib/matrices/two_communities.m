function A = two_communities(n1, n2, beta)
%TWO_COMMUNITIES Two dense blocks joined by a weak bridge.
%
%   A = TWO_COMMUNITIES(n1, n2, beta) returns the adjacency matrix of two
%   complete blocks of sizes n1 and n2 (no self-loops, weight 1), connected
%   by a single bidirectional bridge of weight beta between the last node of
%   the first block and the first node of the second.
%
%   This is the minimal structure separating consensus from cleavage:
%
%       beta = 0   two CLOSED strong components. The graph is not rooted, so
%                  the model converges to BLOCK consensus: each community
%                  agrees internally and the two disagree forever.
%       beta > 0   rootedness is restored and consensus returns, but with a
%                  TIMESCALE SEPARATION -- fast within blocks, slow between.
%
%   NOTE: blocks of size 2 are 2-cycles and therefore PERIODIC. Use blocks of
%   size 3 or more if you want the block-consensus case to converge.
%
%   See also RING_GRAPH, COMPLETE_GRAPH.

    n = n1 + n2;
    A = zeros(n);
    b1 = 1:n1;
    b2 = n1 + (1:n2);

    A(b1, b1) = ones(n1) - eye(n1);
    A(b2, b2) = ones(n2) - eye(n2);

    A(n1, n1+1) = beta;
    A(n1+1, n1) = beta;
end
