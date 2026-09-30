function cases = test_matrices()
%TEST_MATRICES Tests for the matrix-construction layer.

    cases = { ...
        'row_stochastic normalises rows',              @check_row_stochastic; ...
        'row_stochastic patches empty rows loudly',    @check_zero_row; ...
        'laplacian satisfies L*1 = 0',                 @check_laplacian; ...
        'ring_graph is a permutation when s = 0',      @check_ring; ...
        'star_graph makes the hub a stubborn root',    @check_star; ...
        'path_graph is rooted but not strong',         @check_path; ...
        'complete_graph agrees in one step',           @check_complete; ...
        'two_communities splits when beta = 0',        @check_two_communities; ...
        'bad input is rejected',                       @check_validation};
end

% -------------------------------------------------------------------------
function check_row_stochastic()
    A = [0 1 0; 1 0 1; 0 2 0];
    W = row_stochastic(A);
    assert_close(sum(W, 2), ones(3, 1), 1e-15, 'rows sum to 1');
    assert_close(W(2, :), [0.5 0 0.5], 1e-15, 'weights split proportionally');
    assert(is_row_stochastic(W));
end

% -------------------------------------------------------------------------
function check_zero_row()
    A = [0 1; 0 0];
    w = warning('off', 'NDS:row_stochastic:zeroRow');
    restore = onCleanup(@() warning(w));
    W = row_stochastic(A);
    assert_close(W, [0 1; 0 1], 0, 'empty row becomes a self-loop');
end

% -------------------------------------------------------------------------
function check_laplacian()
    A = [0 1 0; 1 0 2; 0 1 0];
    L = laplacian(A);
    assert_close(L * ones(3, 1), zeros(3, 1), 1e-14, 'L*1 = 0');
    assert_close(diag(L), sum(A, 2), 0, 'diagonal holds the row sums');
    assert_close(L(1, 2), -A(1, 2), 0, 'off-diagonal is -a_ij');
end

% -------------------------------------------------------------------------
function check_ring()
    A = ring_graph(5);
    assert(all(A(:) == 0 | A(:) == 1), 'permutation matrix');
    assert_close(A(1, 5), 1, 0, 'agent 1 listens to agent 5');
    assert_close(sum(A, 1).', ones(5, 1), 0, 'doubly stochastic');
    assert(graph_period(A) == 5, 'period equals n');

    lazy = ring_graph(5, 0.3);
    assert(graph_period(lazy) == 1, 'a self-weight makes it aperiodic');
end

% -------------------------------------------------------------------------
function check_star()
    A = star_graph(5);
    assert_close(A(1, :), [1 0 0 0 0], 0, 'hub listens only to itself');
    p = social_power(row_stochastic(A));
    assert_close(p, [1; 0; 0; 0; 0], 1e-12, 'all power at the hub');

    B = star_graph(4, 'bidirectional');
    assert(graph_period(B) == 2, 'bidirectional star is periodic');
end

% -------------------------------------------------------------------------
function check_path()
    A = path_graph(4);
    s = graph_summary(A);
    assert(s.rooted && s.consensus, 'rooted and aperiodic');
    assert(numel(s.components) == 4, 'four singleton components');
    assert_close(social_power(row_stochastic(A)), [1; 0; 0; 0], 1e-12, ...
        'the source dictates the limit');
end

% -------------------------------------------------------------------------
function check_complete()
    W = row_stochastic(complete_graph(5));
    X = sim_degroot(W, (1:5).', 3);
    assert_close(X(:, 2), mean(1:5) * ones(5, 1), 1e-13, 'consensus in one step');
end

% -------------------------------------------------------------------------
function check_two_communities()
    split = graph_summary(two_communities(3, 3, 0));
    assert(numel(split.closed) == 2, 'two closed components when beta = 0');
    assert(~split.rooted && split.convergent, 'block consensus');

    joined = graph_summary(two_communities(3, 3, 0.2));
    assert(joined.consensus, 'a bridge restores consensus');
end

% -------------------------------------------------------------------------
function check_validation()
    assert_error(@() row_stochastic([0 -1; 1 0]), 'NDS:row_stochastic:badInput');
    assert_error(@() laplacian(ones(2, 3)),       'NDS:laplacian:badInput');
    assert_error(@() social_power([1 1; 0 1]),    'NDS:social_power:notStochastic');
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
