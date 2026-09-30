function cases = test_fixtures()
%TEST_FIXTURES Regression tests against published and analytic ground truth.
%
%   These lock the library to results that exist independently of this
%   codebase: worked examples from the tutorial, exercise answers from Bullo,
%   and the checksums published with the two empirical datasets. If one of
%   these fails, the library is wrong -- not the fixture.

    cases = { ...
        'french3 social power is 2/7, 3/7, 2/7',      @check_french3; ...
        'Bullo E5.24(v): exact V matrices',           @check_bullo; ...
        'tutorial Fig. 6(a): lambda = 1 -> consensus',@check_fig6a; ...
        'tutorial Fig. 6(b): classic coupling cleaves',@check_fig6b; ...
        'tutorial Fig. 6(c): two stubborn agents',    @check_fig6c; ...
        'Krackhardt loads, validates, and is rooted', @check_krackhardt; ...
        'Krackhardt zero-power managers',             @check_krackhardt_power; ...
        'Sampson loads and validates',                @check_sampson; ...
        'Sampson choice structure',                   @check_sampson_choices};
end

% -------------------------------------------------------------------------
function check_french3()
    assert_close(social_power(example_french3()), [2/7; 3/7; 2/7], 1e-12, 'analytic');
end

% -------------------------------------------------------------------------
function check_bullo()
    % Exact answers to Bullo, Lectures on Network Systems, exercise E5.24(v).
    W = [0.5 0.5; 0.5 0.5];

    V1 = total_influence(W, [0.5; 1]);
    assert_close(V1, [1 0; 1 0], 1e-12, 'case 1');
    assert(rank(V1) == 1, 'rank one means consensus at agent 1''s prejudice');

    V2 = total_influence(W, [0.25; 0.75]);
    assert_close(V2, [15/16 1/16; 9/16 7/16], 1e-12, 'case 2');
    assert(rank(V2) == 2, 'full rank means persistent disagreement');
end

% -------------------------------------------------------------------------
function check_fig6a()
    [W, u] = example_fj4();
    X = sim_friedkin_johnsen(W, ones(4, 1), u, u, 60);
    assert(max(X(:, end)) - min(X(:, end)) < 1e-6, 'lambda = 1 reaches consensus');
    % Agent 3 is a stubborn root, so the group converges to its opinion.
    assert_close(X(:, end), u(3) * ones(4, 1), 1e-6, 'consensus at agent 3');
    % ... and it must coincide with the pure French-DeGroot run.
    assert_close(X, sim_degroot(W, u, 60), 1e-14, 'identical to sim_degroot');
end

% -------------------------------------------------------------------------
function check_fig6b()
    [W, u] = example_fj4();
    lambda = 1 - diag(W);
    xinf = fj_equilibrium(W, lambda, u);

    assert_close(xinf(3), u(3), 1e-14, 'agent 3 stays at its prejudice');
    assert(max(xinf) - min(xinf) > 0.4, 'visible cleavage remains');

    others = [1 2 4];
    assert(all(abs(xinf(others) - u(3)) < abs(u(others) - u(3))), ...
        'the free agents move towards agent 3');
    assert(all(abs(xinf(others) - u(3)) > 1e-3), 'but never agree with it');
end

% -------------------------------------------------------------------------
function check_fig6c()
    [W, u] = example_fj4();
    lambda = [1; 0; 0; 1];
    xinf = fj_equilibrium(W, lambda, u);

    assert_close(xinf([2 3]), u([2 3]), 1e-12, 'agents 2 and 3 are stubborn');
    free = xinf([1 4]);
    assert(all(free > min(u([2 3]))) && all(free < max(u([2 3]))), ...
        'agents 1 and 4 settle strictly between the two anchors');
    assert(abs(free(1) - free(2)) < 0.05 && abs(free(1) - free(2)) > 0, ...
        'different yet very close');
end

% -------------------------------------------------------------------------
function check_krackhardt()
    [A, names] = load_krackhardt();     % checksum runs inside the loader
    assert(isequal(size(A), [21 21]) && numel(names) == 21);
    assert(all(ismember(A(:), [0 1])) && all(diag(A) == 0), 'binary, zero diagonal');
    assert(sum(A(:)) == 129, '129 arcs');

    s = graph_summary(A);
    assert(numel(s.components) == 5, 'five strong components');
    assert(s.rooted && s.consensus, 'rooted and aperiodic');
    assert(numel(s.roots) == 17, 'the closed component has 17 members');
end

% -------------------------------------------------------------------------
function check_krackhardt_power()
    A = load_krackhardt();
    p = social_power(row_stochastic(A));

    assert(isequal(find(p < 1e-12).', [6 13 16 17]), ...
        'managers nobody consults have exactly zero social power');

    [~, order] = sort(p, 'descend');
    assert(isequal(order(1:4).', [21 7 2 18]), 'ranking 21 > 7 > 2 > 18');
    assert_close(p(21), 0.2011, 5e-4, 'top value');

    % Social power is not in-degree: manager 2 is consulted most often.
    [~, byInDegree] = max(sum(A, 1));
    assert(byInDegree == 2 && order(1) == 21, ...
        'the most-consulted manager is not the most influential');

    % The published benchmarks must match the data file.
    T = krackhardt_benchmarks();
    assert(isequal(T.inDegree, sum(A, 1).') && isequal(T.outDegree, sum(A, 2)));
end

% -------------------------------------------------------------------------
function check_sampson()
    [S, names, ids] = load_sampson();   % checksum runs inside the loader
    assert(isequal(size(S), [18 18]) && numel(names) == 18);
    assert(all(diag(S) == 0) && all(abs(S(:)) <= 3), 'zero diagonal, ranks in -3..3');
    assert(isequal(ids.', [18 19 20 24 25 26 30 32 33 34 35 36 37 38 39 40 41 42]));

    % The poles partition the signed matrix exactly.
    assert_close(max(S, 0) - (-min(S, 0)), S, 0, 'positive minus negative rebuilds S');

    % Romuald is nominated by nobody, so he has zero social power.
    W = row_stochastic(max(S, 0));
    p = social_power(W);
    assert(p(10) < 1e-12 && strcmp(names{10}, 'Romuald'), ...
        'Romuald has zero social power');
end

% -------------------------------------------------------------------------
function check_sampson_choices()
    % Three ranked choices per pole, with a fourth allowed in case of ties,
    % and three novices who name nobody they like least. Documented features:
    % if a re-transcription breaks one, that is an error, not a discovery.
    [S, names] = load_sampson();

    fourChoices = {}; noNegative = {};
    for i = 1:18
        nPos = nnz(S(i, :) > 0);
        nNeg = nnz(S(i, :) < 0);
        assert(nPos >= 3 && nPos <= 4, '%s gives three or four positive choices', names{i});
        if nPos == 4 || nNeg == 4, fourChoices{end+1} = names{i}; end %#ok<AGROW>
        if nNeg == 0,              noNegative{end+1} = names{i}; end %#ok<AGROW>
    end

    assert(isequal(sort(fourChoices), {'Basil', 'Berthold', 'Romuald'}));
    assert(isequal(sort(noNegative), {'Bonaventure', 'Romuald', 'Winfrid'}));
end
