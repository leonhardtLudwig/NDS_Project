function A = star_graph(n, type)
%STAR_GRAPH Adjacency matrix of a star network with hub node 1.
%
%   A = STAR_GRAPH(n) returns the n-by-n matrix in which every leaf listens
%   to the hub and the hub listens only to itself, so the hub is a STUBBORN
%   ROOT: the whole group converges to the hub's initial opinion and all the
%   social power sits on node 1.
%
%   A = STAR_GRAPH(n, 'bidirectional') also lets the hub listen uniformly to
%   all the leaves. The graph is then strongly connected but PERIODIC with
%   period 2, so opinions oscillate.
%
%   See also RING_GRAPH, PATH_GRAPH, COMPLETE_GRAPH.

    if nargin < 2, type = 'hub-source'; end

    leaves = 2:n;
    A = zeros(n);
    A(leaves, 1) = 1;

    switch validatestring(type, {'hub-source', 'bidirectional'})
        case 'hub-source'
            A(1, 1) = 1;
        case 'bidirectional'
            A(1, leaves) = 1;
    end
end
