function cases = test_analysis()
%TEST_ANALYSIS Unit tests for the structural and algebraic analysis layer.

    cases = { ...
        'strongly_connected_components on a known digraph', @check_scc; ...
        'graph_period on cycles and self-loops',            @check_period; ...
        'graph_report classifies the standard cases',       @check_report; ...
        'social_power matches the analytic french3 value',  @check_social_power; ...
        'social_power is zero outside the closed component',@check_social_power_zeros; ...
        'social power is conserved by the dynamics',        @check_conserved; ...
        'laplacian_power solves p''L = 0',                  @check_laplacian_power; ...
        'p_dependence classifies anchored reachability',    @check_p_dependence; ...
        'fj_matrices reproduces Bullo E5.24(v) exactly',    @check_fj_bullo; ...
        'fj_matrices V is row-stochastic and non-negative', @check_fj_stochastic; ...
        'taylor_matrices detects the Hurwitz condition',    @check_taylor_matrices};
end

% -------------------------------------------------------------------------
function check_scc()
    % 1 -> 2 -> 3 -> 1 (a cycle), 3 -> 4, 4 isolated sink.
    A = zeros(4);
    A(1, 2) = 1; A(2, 3) = 1; A(3, 1) = 1; A(3, 4) = 1;
    [comp, nComp, members] = strongly_connected_components(A);
    assert(nComp == 2, 'two components');
    assert(comp(1) == comp(2) && comp(2) == comp(3), 'cycle is one component');
    assert(comp(4) ~= comp(1), 'node 4 is separate');
    sizes = sort(cellfun(@numel, members));
    assert(isequal(sizes(:).', [1 3]), 'component sizes');

    [~, nEmpty] = strongly_connected_components(zeros(0));
    assert(nEmpty == 0, 'empty graph handled');
end

% -------------------------------------------------------------------------
function check_period()
    cycle = zeros(4);
    for ii = 1:4
        cycle(ii, mod(ii, 4) + 1) = 1;
    end
    assert(graph_period(cycle) == 4, 'directed 4-cycle has period 4');

    withLoop = cycle;
    withLoop(1, 1) = 1;
    assert(graph_period(withLoop) == 1, 'a self-loop forces aperiodicity');

    acyclic = zeros(2); acyclic(1, 2) = 1;
    assert(graph_period(acyclic, 1) == 0, 'single node without a cycle');
end

% -------------------------------------------------------------------------
function check_report()
    periodic = make_ring(4);
    rep = graph_report(periodic.W);
    assert(~rep.isConvergent && rep.isRooted, 'periodic but rooted');

    % Blocks of size >= 3 are complete graphs, hence aperiodic: the model
    % converges to BLOCK consensus even though it is not rooted.
    blocks = make_two_communities(3, 0);
    repBlocks = graph_report(blocks.W);
    assert(repBlocks.isConvergent && ~repBlocks.isRooted, 'convergent block case');

    % Blocks of size 2 are 2-CYCLES, so each closed component has period 2 and
    % the model oscillates. Community structure alone does not imply
    % convergence -- the components must also be aperiodic.
    tiny = make_two_communities(2, 0);
    repTiny = graph_report(tiny.W);
    assert(all(repTiny.periods == 2), 'size-2 blocks are 2-cycles');
    assert(~repTiny.isConvergent, 'periodic blocks do not converge');

    good = make_ring(4, 'SelfWeight', 0.5);
    assert(graph_report(good.W).reachesConsensus, 'lazy ring reaches consensus');

    % Accepts a network struct as well as a bare matrix.
    assert(isequal(graph_report(good).nComponents, graph_report(good.W).nComponents));
end

% -------------------------------------------------------------------------
function check_social_power()
    net = make_example_french3();
    [p, info] = social_power(net);
    assert_close(p, [2/7; 3/7; 2/7], 1e-12, 'analytic social power');
    assert(info.isConsensus && info.residual < 1e-12);
end

% -------------------------------------------------------------------------
function check_social_power_zeros()
    net = make_path(4);
    p = social_power(net.W);
    assert_close(p, [1; 0; 0; 0], 1e-12, 'only the source has power');
end

% -------------------------------------------------------------------------
function check_conserved()
    % p'x(k) is invariant under x(k+1) = W x(k) because p'W = p'.
    net = make_example_french3();
    p = social_power(net);
    x0 = [3; -1; 5];
    res = sim_degroot(net, x0, 25);
    values = p.' * res.X;
    assert_close(values, values(1) * ones(1, numel(values)), 1e-12, ...
        'p''x(k) conserved (discrete)');

    % The same holds for the Abelson flow, where p'L = 0.
    q = laplacian_power(net.A);
    resA = sim_abelson(net, x0, linspace(0, 10, 40));
    valuesA = q.' * resA.X;
    assert_close(valuesA, valuesA(1) * ones(1, numel(valuesA)), 1e-11, ...
        'p''x(t) conserved (continuous)');
end

% -------------------------------------------------------------------------
function check_laplacian_power()
    net = make_example_french3();
    [p, info] = laplacian_power(net.A);
    assert(info.isConsensus);
    assert_close(p.' * net.L, zeros(1, 3), 1e-12, 'p''L = 0');
    assert_close(sum(p), 1, 1e-14, 'normalised');
end

% -------------------------------------------------------------------------
function check_p_dependence()
    % Chain 1 <- 2 <- 3 in listening terms: 3 listens to 2, 2 listens to 1.
    W = [1 0 0; 1 0 0; 0 1 0];
    W = row_normalize(W, 'Warn', false);

    [mask, info] = p_dependence(W, 1);
    assert(all(mask), 'the head anchors the whole chain');
    assert(info.allDependent);

    [mask, info] = p_dependence(W, 3);
    assert(isequal(info.pDependent, 3), 'only agent 3 depends on agent 3');
    assert(isequal(info.pIndependent, [1 2]));
    assert(~info.allDependent);

    % A logical mask is accepted too.
    maskLogical = p_dependence(W, logical([0 0 1]));
    assert(isequal(maskLogical, mask));
end

% -------------------------------------------------------------------------
function check_fj_bullo()
    % Exact values derived from Bullo, Lectures on Network Systems, E5.24(v).
    W = [0.5 0.5; 0.5 0.5];

    out1 = fj_matrices(W, [0.5; 1]);
    assert_close(out1.V, [1 0; 1 0], 1e-12, 'Bullo case 1');
    assert(out1.rankV == 1, 'rank one means consensus');

    out2 = fj_matrices(W, [0.25; 0.75]);
    assert_close(out2.V, [15/16 1/16; 9/16 7/16], 1e-12, 'Bullo case 2');
    assert(out2.rankV == 2, 'full rank means persistent disagreement');
end

% -------------------------------------------------------------------------
function check_fj_stochastic()
    net = make_ring(6, 'SelfWeight', 0.2);
    out = fj_matrices(net.W, 0.7);
    assert(out.isStable && out.rho < 1);
    assert(out.isRowStochasticV, 'V must be row-stochastic');
    assert(all(out.V(:) >= -1e-12), 'V must be non-negative');
    assert_close(sum(out.c), 1, 1e-12, 'influence centrality sums to 1');
end

% -------------------------------------------------------------------------
function check_taylor_matrices()
    net = make_ring(4, 'SelfWeight', 0.1);

    unanchored = taylor_matrices(net.A, 0);
    assert(~unanchored.isHurwitz, 'no anchors means marginal stability');
    assert_close(unanchored.minRealPart, 0, 1e-10, 'a zero eigenvalue');

    anchored = taylor_matrices(net.A, [1 0 0 0]);
    assert(anchored.isHurwitz, 'one anchor reaching everyone gives stability');
    assert(anchored.minRealPart > 0);
end
