function cases = test_analysis()
%TEST_ANALYSIS Tests for social power, limit operators and graph structure.

    cases = { ...
        'social_power solves p''W = p'', p''1 = 1',    @check_social_power; ...
        'social power is conserved by the dynamics',  @check_conserved; ...
        'limit_matrix: rank 1 vs block consensus',    @check_limit_matrix; ...
        'strong_components on a known digraph',       @check_scc; ...
        'graph_period on cycles and self-loops',      @check_period; ...
        'graph_summary classifies the standard cases',@check_summary; ...
        'prejudice_reach follows influence backwards',@check_reach};
end

% -------------------------------------------------------------------------
function check_social_power()
    W = example_french3();
    p = social_power(W);
    assert_close(p, [2/7; 3/7; 2/7], 1e-12, 'analytic value');
    assert_close(p.' * W, p.', 1e-12, 'p''W = p''');
    assert_close(sum(p), 1, 1e-14, 'normalised');

    % Doubly stochastic -> uniform social power -> average consensus.
    q = social_power(row_stochastic(ring_graph(5, 0.2)));
    assert_close(q, ones(5, 1) / 5, 1e-12, 'doubly stochastic gives 1/n');
end

% -------------------------------------------------------------------------
function check_conserved()
    % p'x(k) is invariant under x(k+1) = W x(k) because p'W = p'.
    W = example_french3();
    p = social_power(W);
    X = sim_degroot(W, [3; -1; 5], 25);
    invariant = p.' * X;
    assert_close(invariant, invariant(1) * ones(1, 26), 1e-12, 'p''x(k) conserved');
end

% -------------------------------------------------------------------------
function check_limit_matrix()
    W = example_french3();
    Winf = limit_matrix(W);
    assert(rank(Winf) == 1, 'consensus gives a rank-one limit');
    assert_close(Winf(1, :), social_power(W).', 1e-10, 'every row is p''');
    assert_close(sum(Winf, 2), ones(3, 1), 1e-12, 'row-stochastic');

    % Two closed components: the limit converges but is not rank one.
    B = row_stochastic(two_communities(3, 3, 0));
    Binf = limit_matrix(B);
    assert(rank(Binf) == 2, 'block consensus gives rank 2');
    assert_error(@() social_power(B), 'NDS:social_power:notUnique');
end

% -------------------------------------------------------------------------
function check_scc()
    % 1 -> 2 -> 3 -> 1 (a cycle), 3 -> 4, node 4 a sink.
    A = zeros(4);
    A(1,2) = 1; A(2,3) = 1; A(3,1) = 1; A(3,4) = 1;
    [comp, members] = strong_components(A);
    assert(numel(members) == 2, 'two components');
    assert(comp(1) == comp(2) && comp(2) == comp(3), 'the cycle is one component');
    assert(comp(4) ~= comp(1), 'node 4 is separate');
end

% -------------------------------------------------------------------------
function check_period()
    assert(graph_period(ring_graph(4)) == 4, 'directed 4-cycle');
    assert(graph_period(ring_graph(4, 0.5)) == 1, 'a self-loop forces aperiodicity');

    acyclic = zeros(2); acyclic(1,2) = 1;
    assert(graph_period(acyclic, 1) == 0, 'a single node with no cycle');
end

% -------------------------------------------------------------------------
function check_summary()
    periodic = graph_summary(ring_graph(4));
    assert(periodic.rooted && ~periodic.convergent, 'periodic but rooted');

    lazy = graph_summary(ring_graph(4, 0.5));
    assert(lazy.consensus, 'lazy ring reaches consensus');

    % Blocks of size 2 are 2-cycles, so community structure alone does not
    % imply convergence -- the components must also be aperiodic.
    tiny = graph_summary(two_communities(2, 2, 0));
    assert(all(tiny.periods == 2) && ~tiny.convergent, 'size-2 blocks oscillate');
end

% -------------------------------------------------------------------------
function check_reach()
    % Chain: 3 listens to 2, 2 listens to 1, 1 listens to itself.
    W = row_stochastic(path_graph(3));

    assert(all(prejudice_reach(W, 1)), 'the head anchors the whole chain');
    assert(isequal(prejudice_reach(W, 3).', [false false true]), ...
        'the tail anchors only itself');
    assert(isequal(prejudice_reach(W, logical([0 0 1])).', [false false true]), ...
        'a logical mask is accepted too');
end

% -------------------------------------------------------------------------
function assert_error(fcn, expectedId)
    try
        fcn();
    catch err
        assert(strcmp(err.identifier, expectedId), ...
            'expected %s, got %s', expectedId, err.identifier);
        return;
    end
    error('expected error %s but none was raised', expectedId);
end
