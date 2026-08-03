function cases = test_fixtures()
%TEST_FIXTURES Regression tests against published and analytic ground truth.
%
%   These lock the implementation to values that exist independently of this
%   codebase: worked examples from the tutorial, exercise answers from Bullo,
%   and the degree sequence published by Sims & Gilles. If one of these fails,
%   the library is wrong -- not the fixture.

    cases = { ...
        'french3 social power equals 2/7, 3/7, 2/7',        @check_french3; ...
        'Krackhardt data loads and validates',              @check_krackhardt_load; ...
        'Krackhardt structural properties',                 @check_krackhardt_structure; ...
        'Krackhardt social power and zero-power managers',  @check_krackhardt_power; ...
        'tutorial Fig. 6(a): Lambda = I reaches consensus', @check_fig6a; ...
        'tutorial Fig. 6(b): classic coupling cleaves',     @check_fig6b; ...
        'tutorial Fig. 6(c): two stubborn agents',          @check_fig6c; ...
        'Sampson data loads and validates',                 @check_sampson_load; ...
        'Sampson signed matrix is always preserved',        @check_sampson_signed; ...
        'Sampson choice structure matches the instrument',  @check_sampson_choices; ...
        'Sampson structural properties',                    @check_sampson_structure};
end

% -------------------------------------------------------------------------
function check_french3()
    net = make_example_french3();
    assert_close(social_power(net), [2/7; 3/7; 2/7], 1e-12, 'analytic value');
end

% -------------------------------------------------------------------------
function check_krackhardt_load()
    net = load_krackhardt();            % validation is on by default
    assert(net.n == 21);
    assert(all(ismember(net.A(:), [0 1])), 'binary');
    assert(all(diag(net.A) == 0), 'zero diagonal');
    assert_close(sum(net.A(:)), 129, 0, 'arc count');
    assert(isempty(net.meta.normalization.zeroRows), 'no zero rows to patch');
end

% -------------------------------------------------------------------------
function check_krackhardt_structure()
    net = load_krackhardt();
    rep = graph_report(net.W);

    assert(rep.nComponents == 5, 'five strong components');
    assert(isscalar(rep.closedComponents), 'exactly one closed component');
    assert(numel(rep.roots) == 17, 'the closed component has 17 members');
    assert(rep.isRooted && rep.reachesConsensus, 'rooted and aperiodic');
    assert(~rep.isIrreducible, 'reducible, as Bullo notes');

    singletons = sort(cellfun(@(m) m(1), rep.members(cellfun(@numel, rep.members) == 1)));
    assert(isequal(singletons(:).', [6 13 16 17]), ...
        'the singleton components are managers 6, 13, 16, 17');
end

% -------------------------------------------------------------------------
function check_krackhardt_power()
    net = load_krackhardt();
    p = social_power(net);

    assert_close(sum(p), 1, 1e-12, 'normalised');
    assert(all(p >= -1e-12), 'non-negative');

    zeroPower = find(p < 1e-12).';
    assert(isequal(zeroPower, [6 13 16 17]), ...
        'managers nobody consults have exactly zero social power');

    [~, order] = sort(p, 'descend');
    assert(isequal(order(1:4).', [21 7 2 18]), ...
        'social power ranking: 21 > 7 > 2 > 18');
    assert_close(p(21), 0.2011, 5e-4, 'top social power value');

    % Social power is NOT in-degree: manager 2 is consulted most often but
    % manager 21 is the most influential.
    [~, byInDegree] = max(sum(net.A, 1));
    assert(byInDegree == 2 && order(1) == 21, ...
        'the most-consulted manager is not the most influential');
end

% -------------------------------------------------------------------------
function check_fig6a()
    [net, u, x0] = make_example_fj4();
    res = sim_friedkin_johnsen(net, fj_lambda(net, 'identity'), u, x0, 60);
    spread = max(res.xinf) - min(res.xinf);
    assert(spread < 1e-6, 'Lambda = I reaches consensus');
    % Agent 3 is a stubborn root, so the group converges to its opinion.
    assert_close(res.xinf, u(3) * ones(4, 1), 1e-6, 'consensus at agent 3''s opinion');
end

% -------------------------------------------------------------------------
function check_fig6b()
    [net, u, x0] = make_example_fj4();
    res = sim_friedkin_johnsen(net, fj_lambda(net, 'classic'), u, x0, 80);

    assert_close(res.X(:, end), res.xinf, 1e-10, 'settles at the predicted limit');
    assert_close(res.xinf(3), u(3), 1e-14, 'agent 3 stays at its prejudice');

    spread = max(res.xinf) - min(res.xinf);
    assert(spread > 0.4, 'visible cleavage remains');

    % Everyone moves towards the stubborn agent but nobody reaches it.
    others = [1 2 4];
    assert(all(abs(res.xinf(others) - u(3)) < abs(u(others) - u(3))), ...
        'the free agents move towards agent 3');
    assert(all(abs(res.xinf(others) - u(3)) > 1e-3), 'but do not agree with it');
end

% -------------------------------------------------------------------------
function check_fig6c()
    [net, u, x0] = make_example_fj4();
    res = sim_friedkin_johnsen(net, fj_lambda(net, 'stubborn', [2 3]), u, x0, 80);

    assert_close(res.xinf([2 3]), u([2 3]), 1e-12, 'agents 2 and 3 are stubborn');

    free = res.xinf([1 4]);
    lo = min(u([2 3])); hi = max(u([2 3]));
    assert(all(free > lo) && all(free < hi), ...
        'agents 1 and 4 settle strictly between the two stubborn opinions');
    assert(abs(free(1) - free(2)) < 0.05, ...
        'their final opinions are different yet very close');
    assert(abs(free(1) - free(2)) > 0, 'but not identical');
end

% -------------------------------------------------------------------------
function check_sampson_load()
    % Validation against the published column totals is on by default, so a
    % successful load is itself the checksum test.
    [net, S] = load_sampson();

    assert(net.n == 18, '18 novices');
    assert(isequal(size(S), [18 18]), 'signed matrix is 18-by-18');
    assert(all(diag(S) == 0), 'self-nominations excluded');
    assert(all(abs(S(:)) <= 3), 'values are ranks in -3..3');
    assert(all(net.A(:) >= 0), 'the extracted network is non-negative');

    % The published totals, restated here independently of the loader.
    assert_close(sum(max(S, 0), 1), ...
        [12 13 7 12 10 3 6 6 5 0 4 9 4 3 3 2 4 8], 0, 'positive column totals');
    assert_close(-sum(min(S, 0), 1), ...
        [3 17 13 18 0 9 5 10 0 3 0 1 4 2 0 1 7 1], 0, 'negative column totals');

    % Sampson's original IDs are preserved for cross-referencing.
    assert(isequal(net.meta.ids.', ...
        [18 19 20 24 25 26 30 32 33 34 35 36 37 38 39 40 41 42]));
    assert(strcmp(net.labels{1}, 'John Bosco') && strcmp(net.labels{18}, 'Simplicius'));
end

% -------------------------------------------------------------------------
function check_sampson_signed()
    % Whichever pole is extracted, the full signed matrix must survive, so a
    % structural-balance extension never needs the data re-acquiring.
    [posNet, S1] = load_sampson('Sign', 'positive');
    [negNet, S2] = load_sampson('Sign', 'negative');

    assert_close(S1, S2, 0, 'the signed matrix does not depend on the option');
    assert_close(posNet.meta.signed, S1, 0, 'signed matrix carried in meta');
    assert_close(negNet.meta.signed, S1, 0, 'signed matrix carried in meta');

    % The two poles partition the signed matrix exactly.
    assert_close(posNet.A - negNet.A, S1, 0, 'positive minus negative rebuilds S');
    assert(all(posNet.A(:) >= 0) && all(negNet.A(:) >= 0), 'both poles non-negative');

    % Binary weights keep the support and drop the ranks.
    binNet = load_sampson('Weights', 'binary');
    assert(all(ismember(binNet.A(:), [0 1])), 'binary option gives a 0/1 matrix');
    assert_close(double(posNet.A > 0), binNet.A, 0, 'same support as the ranked version');
end

% -------------------------------------------------------------------------
function check_sampson_choices()
    % Sampson's instrument asks for three ranked choices on each pole, with a
    % fourth allowed in case of ties, and three novices declined to name
    % anyone they liked least. These are documented features of the data, so
    % pin them down: if a future re-transcription breaks one, that is an
    % error rather than a discovery.
    [net, S] = load_sampson();
    names = net.labels;

    fourChoices = {};
    noNegative  = {};
    for ii = 1:18
        nPos = nnz(S(ii, :) > 0);
        nNeg = nnz(S(ii, :) < 0);
        assert(nPos >= 3 && nPos <= 4, ...
            '%s must give three or four positive choices', names{ii});
        assert(nNeg <= 4, '%s gives at most four negative choices', names{ii});
        if nPos == 4 || nNeg == 4
            fourChoices{end+1} = names{ii}; %#ok<AGROW>
        end
        if nNeg == 0
            noNegative{end+1} = names{ii}; %#ok<AGROW>
        end
    end

    assert(isequal(sort(fourChoices), {'Basil', 'Berthold', 'Romuald'}), ...
        'exactly Basil, Berthold and Romuald use a fourth (tied) choice');
    assert(isequal(sort(noNegative), {'Bonaventure', 'Romuald', 'Winfrid'}), ...
        'exactly Bonaventure, Romuald and Winfrid name nobody they like least');
end

% -------------------------------------------------------------------------
function check_sampson_structure()
    % Record what the liking network actually looks like structurally, before
    % any modelling claim is made about it.
    net = load_sampson();
    rep = graph_report(net.W);

    assert(rep.n == 18);
    assert(all(sum(net.A, 2) > 0), 'every novice names someone they like');
    assert(isempty(net.meta.normalization.zeroRows), ...
        'no self-loops needed on the positive pole');

    % The negative pole is the interesting contrast: three empty rows there
    % DO get a self-loop, which silently makes those novices stubborn.
    negNet = load_sampson('Sign', 'negative');
    assert(numel(negNet.meta.normalization.zeroRows) == 3, ...
        'three novices give no negative nominations');

    % Structure is a fact to be reported, not asserted to be convenient.
    assert(islogical(rep.isRooted) && islogical(rep.reachesConsensus));
end
