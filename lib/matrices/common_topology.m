function A = common_topology(name, n)
%COMMON_TOPOLOGY Adjacency matrix from the family of test graphs shared by all chapters.
%
%   A = COMMON_TOPOLOGY(name) returns the n-by-n adjacency matrix of one of
%   the reference topologies, with n = 6 by default.
%
%   A = COMMON_TOPOLOGY(name, n) uses n nodes.
%
%   Names
%       'cycle'       directed ring                      irreducible, period n
%       'cycle-self'  directed ring, self-loop on node 1  primitive
%       'line'        directed chain, source at node 1    reducible, one root
%       'star'        bidirectional star, hub node 1      irreducible, period 2
%       'star-out'    hub listens to all the leaves       zero out-degrees
%       'two-blocks'  two disjoint complete blocks        two closed components
%
%   All chapters draw their examples from this family, so that the same graph
%   can be compared across the four models. The builders already in
%   lib/matrices are reused wherever one exists; only 'star-out' is defined
%   here, because it is the one topology with rows that are entirely zero.
%
%   CONVENTION
%       A(i,j) > 0 means agent i accords weight to agent j: row i lists whom
%       agent i listens to.
%
%   NOTE ON 'star-out'
%       Its leaves have out-degree 0, so D_out is singular and the
%       row-stochastic matrix W = D_out^{-1} A does not exist. Build the
%       discrete-time matrix with the Perron rule P = I - eps*L instead,
%       eps <= 1/max_i d_out(i).
%
%   Example
%       A = common_topology('cycle');
%       W = row_stochastic(A);
%
%   See also RING_GRAPH, STAR_GRAPH, PATH_GRAPH, TWO_COMMUNITIES, ROW_STOCHASTIC.

    if nargin < 2 || isempty(n)
        n = 6;
    end
    validateattributes(n, {'numeric'}, {'scalar','integer','>=',2}, mfilename, 'n', 2);

    switch validatestring(name, ...
            {'cycle','cycle-self','line','star','star-out','two-blocks'}, mfilename, 'name', 1)

        case 'cycle'
            A = ring_graph(n);

        case 'cycle-self'
            A = ring_graph(n);
            A(1,1) = 1;                       % one self-loop is enough for aperiodicity

        case 'line'
            A = path_graph(n);                % node 1 is the source, and the only root

        case 'star'
            A = star_graph(n, 'bidirectional');

        case 'star-out'
            A = zeros(n);
            A(1, 2:n) = 1;                    % the hub listens, the leaves do not

        case 'two-blocks'
            if mod(n, 2) ~= 0
                error('NDS:common_topology:oddN', ...
                    '''two-blocks'' needs an even number of nodes (got %d).', n);
            end
            A = two_communities(n/2, n/2, 0);
    end
end
