function A = path_graph(n)
%PATH_GRAPH Adjacency matrix of a directed chain.
%
%   A = PATH_GRAPH(n) returns the n-by-n matrix in which agent i listens to
%   agent i-1, and agent 1 listens only to itself.
%
%   This is the smallest network that is ROOTED but NOT strongly connected.
%   Agent 1 reaches everybody and nobody reaches agent 1, so the group
%   converges to x_1(0) and every other initial opinion is forgotten.
%
%   See also RING_GRAPH, STAR_GRAPH, TWO_COMMUNITIES.

    A = zeros(n);
    A(1, 1) = 1;
    for i = 2:n
        A(i, i-1) = 1;
    end
end
