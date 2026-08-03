function cases = test_graphs()
%TEST_GRAPHS Unit tests for the network builders and the network structure.

    cases = { ...
        'net_from_matrix builds a consistent structure',     @check_net_struct; ...
        'row_normalize handles zero rows by policy',         @check_zero_rows; ...
        'layout_polygon places nodes on a circle',           @check_layout; ...
        'make_ring directed is a permutation matrix',        @check_ring_directed; ...
        'make_ring symmetric is doubly stochastic',          @check_ring_symmetric; ...
        'make_star hub-source makes the hub stubborn',       @check_star; ...
        'make_path makes agent 1 the only source',           @check_path; ...
        'make_complete reaches consensus in one step',       @check_complete; ...
        'make_two_communities splits when beta = 0',         @check_two_communities; ...
        'builders reject invalid arguments',                 @check_builder_validation};
end

% -------------------------------------------------------------------------
function check_net_struct()
    A = [0 1 0; 0 0 2; 3 0 0];
    net = net_from_matrix(A, 'Name', 'demo');
    assert(net.n == 3 && strcmp(net.name, 'demo'));
    assert_close(net.A, A, 0, 'raw weights preserved');
    assert(is_row_stochastic(net.W), 'W is row-stochastic');
    assert_close(net.L, diag(sum(A, 2)) - A, 0, 'Laplacian');
    assert_close(net.L * ones(3, 1), zeros(3, 1), 1e-14, 'L*1 = 0');
    assert(numel(net.labels) == 3 && isequal(size(net.coords), [3 2]));
    assert(isfield(net.meta, 'convention'), 'provenance recorded');
end

% -------------------------------------------------------------------------
function check_zero_rows()
    A = [0 1; 0 0];

    [W, info] = row_normalize(A, 'Warn', false);
    assert_close(W, [0 1; 0 1], 0, 'selfloop policy');
    assert(isequal(info.zeroRows, 2) && strcmp(info.policy, 'selfloop'));

    W = row_normalize(A, 'ZeroRowPolicy', 'keep', 'Warn', false);
    assert_close(W, [0 1; 0 0], 0, 'keep policy');

    threw = false;
    try
        row_normalize(A, 'ZeroRowPolicy', 'error');
    catch err
        threw = strcmp(err.identifier, 'NDS:rowNormalize:zeroRow');
    end
    assert(threw, 'error policy must throw');
end

% -------------------------------------------------------------------------
function check_layout()
    c = layout_polygon(4, 2);
    assert_close(sqrt(sum(c.^2, 2)), 2 * ones(4, 1), 1e-12, 'radius');
    assert_close(c(1, :), [0 2], 1e-12, 'node 1 at the top');
    assert(isequal(size(layout_polygon(1)), [1 2]));
    assert(isequal(size(layout_polygon(0)), [0 2]));
end

% -------------------------------------------------------------------------
function check_ring_directed()
    net = make_ring(5);
    W = net.W;
    assert(is_row_stochastic(W), 'row-stochastic');
    assert_close(sum(W, 1).', ones(5, 1), 1e-14, 'doubly stochastic');
    assert(all(W(:) == 0 | W(:) == 1), 'permutation matrix');
    assert_close(W(1, 5), 1, 0, 'agent 1 listens to agent 5');

    rep = graph_report(W);
    assert(rep.isIrreducible, 'strongly connected');
    assert(rep.periods == 5, 'period equals n');
    assert(~rep.isConvergent, 'a periodic ring does not converge');

    % A self-weight makes it aperiodic and hence convergent.
    lazy = make_ring(5, 'SelfWeight', 0.3);
    repLazy = graph_report(lazy.W);
    assert(repLazy.reachesConsensus, 'lazy ring reaches consensus');
end

% -------------------------------------------------------------------------
function check_ring_symmetric()
    even = make_ring(6, 'Type', 'symmetric');
    assert_close(sum(even.W, 1).', ones(6, 1), 1e-14, 'doubly stochastic');
    repEven = graph_report(even.W);
    assert(repEven.periods == 2, 'even symmetric ring has period 2');

    odd = make_ring(7, 'Type', 'symmetric');
    repOdd = graph_report(odd.W);
    assert(repOdd.periods == 1, 'odd symmetric ring is aperiodic');
    assert(repOdd.reachesConsensus, 'odd symmetric ring reaches consensus');
end

% -------------------------------------------------------------------------
function check_star()
    net = make_star(5, 'Type', 'hub-source', 'Hub', 2);
    assert_close(net.W(2, 2), 1, 0, 'hub is stubborn');
    assert_close(sum(net.W(:, 2)), 5, 1e-14, 'everyone listens to the hub');

    p = social_power(net.W);
    expected = zeros(5, 1); expected(2) = 1;
    assert_close(p, expected, 1e-12, 'all social power at the hub');

    bidir = make_star(4, 'Type', 'bidirectional');
    rep = graph_report(bidir.W);
    assert(rep.isIrreducible && rep.periods == 2, ...
        'bidirectional star without self-weight is periodic');
end

% -------------------------------------------------------------------------
function check_path()
    net = make_path(4);
    rep = graph_report(net.W);
    assert(rep.isRooted, 'rooted');
    assert(~rep.isIrreducible, 'not strongly connected');
    assert(isequal(rep.roots, 1), 'agent 1 is the unique root');
    assert(rep.reachesConsensus, 'consensus at the source');

    p = social_power(net.W);
    assert_close(p, [1; 0; 0; 0], 1e-12, 'social power concentrated at the source');
end

% -------------------------------------------------------------------------
function check_complete()
    net = make_complete(5);
    res = sim_degroot(net, (1:5).', 3);
    assert_close(res.X(:, 2), mean(1:5) * ones(5, 1), 1e-13, ...
        'consensus after a single step');
    p = social_power(net.W);
    assert_close(p, ones(5, 1) / 5, 1e-12, 'uniform social power');
end

% -------------------------------------------------------------------------
function check_two_communities()
    split = make_two_communities(3, 0);
    rep = graph_report(split.W);
    assert(numel(rep.closedComponents) == 2, 'two closed components when beta = 0');
    assert(~rep.isRooted, 'not rooted');
    assert(rep.isConvergent, 'still convergent (block consensus)');

    joined = make_two_communities(3, 0.2);
    repJoined = graph_report(joined.W);
    assert(repJoined.reachesConsensus, 'a bridge restores consensus');
    assert(numel(joined.meta.community) == 6, 'community labels recorded');
end

% -------------------------------------------------------------------------
function check_builder_validation()
    ids = { ...
        @() make_ring(1),                          'MATLAB:make_ring:expectedGreaterEqual'; ...
        @() make_star(4, 'Hub', 9),                'MATLAB:make_star:notLessEqual'; ...
        @() make_two_communities(3, -1),           'MATLAB:make_two_communities:expectedNonnegative'};
    for k = 1:size(ids, 1)
        threw = false;
        try
            ids{k, 1}();
        catch
            threw = true;      % identifier text varies across releases
        end
        assert(threw, 'builder %d should have rejected its argument', k);
    end
end
