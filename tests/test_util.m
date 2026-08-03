function cases = test_util()
%TEST_UTIL Unit tests for the shared validation and plumbing utilities.
%
%   These are the foundations every other layer depends on, so they are
%   tested for their FAILURE behaviour as much as their success behaviour: a
%   validator that accepts bad input is worse than no validator at all.

    cases = { ...
        'validate_square_matrix accepts and rejects correctly', @check_square; ...
        'validate_nonnegative_matrix rejects negatives',        @check_nonneg; ...
        'validate_row_stochastic rejects unnormalised rows',    @check_rowstoch; ...
        'is_row_stochastic reports the deviation',              @check_isrowstoch; ...
        'prepare_state canonicalises every accepted shape',     @check_prepare_state; ...
        'prepare_state rejects a wrong number of rows',         @check_prepare_state_bad; ...
        'match_input_dimension broadcasts a single column',     @check_match_input; ...
        'is_uniform_grid detects uniform and non-uniform',      @check_uniform_grid; ...
        'parse_options merges and rejects unknown names',       @check_parse_options; ...
        'diagonal_parameter accepts scalar/vector/diagonal',    @check_diag_param; ...
        'diagonal_parameter enforces its bounds',               @check_diag_param_bounds; ...
        'validate_time_vector rejects a decreasing vector',     @check_time_vector; ...
        'pack_result squeezes scalar opinions',                 @check_pack_result; ...
        'safe_predict swallows a failing predictor',            @check_safe_predict};
end

% -------------------------------------------------------------------------
function check_square()
    assert(validate_square_matrix(eye(3), 'M') == 3);
    assert_throws(@() validate_square_matrix(ones(2, 3), 'M'), 'NDS:validate:notSquare');
    assert_throws(@() validate_square_matrix([1 NaN; 0 1], 'M'), 'NDS:validate:notFinite');
    assert_throws(@() validate_square_matrix('abc', 'M'), 'NDS:validate:notRealNumeric');
    assert_throws(@() validate_square_matrix([], 'M'), 'NDS:validate:emptyMatrix');
    assert(validate_square_matrix([], 'M', true) == 0);
end

% -------------------------------------------------------------------------
function check_nonneg()
    assert(validate_nonnegative_matrix([0 1; 2 0], 'A') == 2);
    assert_throws(@() validate_nonnegative_matrix([0 -1; 1 0], 'A'), ...
        'NDS:validate:negativeEntry');
end

% -------------------------------------------------------------------------
function check_rowstoch()
    assert(validate_row_stochastic([0.5 0.5; 1 0], 'W') == 2);
    assert_throws(@() validate_row_stochastic([0.5 0.4; 1 0], 'W'), ...
        'NDS:validate:notRowStochastic');
end

% -------------------------------------------------------------------------
function check_isrowstoch()
    [tf, dev] = is_row_stochastic([0.5 0.5; 0.5 0.5]);
    assert(tf && dev < 1e-15);
    [tf, dev] = is_row_stochastic([0.5 0.4; 0.5 0.5]);
    assert(~tf);
    assert_close(dev, 0.1, 1e-12, 'deviation');
end

% -------------------------------------------------------------------------
function check_prepare_state()
    [X, d] = prepare_state([1; 2; 3], 3);
    assert_close(X, [1; 2; 3], 0, 'column vector'); assert(d == 1);

    [X, d] = prepare_state([1 2 3], 3);
    assert_close(X, [1; 2; 3], 0, 'row vector transposed'); assert(d == 1);

    [X, d] = prepare_state(7, 4);
    assert_close(X, 7 * ones(4, 1), 0, 'scalar replicated'); assert(d == 1);

    [X, d] = prepare_state([1 2; 3 4; 5 6], 3);
    assert(d == 2 && isequal(size(X), [3 2]));
end

% -------------------------------------------------------------------------
function check_prepare_state_bad()
    assert_throws(@() prepare_state([1; 2], 3), 'NDS:validate:sizeMismatch');
    assert_throws(@() prepare_state([1; Inf; 3], 3), 'NDS:validate:notFinite');
end

% -------------------------------------------------------------------------
function check_match_input()
    U = match_input_dimension([1; 2], 2, 3, 'u');
    assert_close(U, [1 1 1; 2 2 2], 0, 'broadcast');
    assert_throws(@() match_input_dimension([1 2; 3 4], 2, 3, 'u'), ...
        'NDS:validate:inputDimensionMismatch');
end

% -------------------------------------------------------------------------
function check_uniform_grid()
    [tf, dt] = is_uniform_grid(0:0.25:2);
    assert(tf); assert_close(dt, 0.25, 1e-12, 'dt');
    [tf, dt] = is_uniform_grid([0 1 3]);
    assert(~tf && isnan(dt));
    assert(is_uniform_grid(5));
end

% -------------------------------------------------------------------------
function check_parse_options()
    opts = parse_options(struct('Alpha', 1, 'Beta', 2), {'beta', 9}, 'f');
    assert(opts.Alpha == 1 && opts.Beta == 9, 'case-insensitive merge');
    assert_throws(@() parse_options(struct('Alpha', 1), {'Gamma', 3}, 'f'), ...
        'NDS:parseOptions:unknownOption');
    assert_throws(@() parse_options(struct('Alpha', 1), {'Alpha'}, 'f'), ...
        'NDS:parseOptions:oddArguments');
end

% -------------------------------------------------------------------------
function check_diag_param()
    assert_close(diagonal_parameter(0.5, 3, 'L', 0, 1), 0.5 * ones(3, 1), 0, 'scalar');
    assert_close(diagonal_parameter([1; 0; 1], 3, 'L', 0, 1), [1; 0; 1], 0, 'vector');
    assert_close(diagonal_parameter(diag([1 0 1]), 3, 'L', 0, 1), [1; 0; 1], 0, 'diagonal');
    assert_close(diagonal_parameter([], 3, 'G', 0, Inf), zeros(3, 1), 0, 'empty');
end

% -------------------------------------------------------------------------
function check_diag_param_bounds()
    assert_throws(@() diagonal_parameter(1.5, 2, 'L', 0, 1), ...
        'NDS:diagonalParameter:outOfRange');
    assert_throws(@() diagonal_parameter([1 1; 1 1], 2, 'L', 0, 1), ...
        'NDS:diagonalParameter:notDiagonal');
end

% -------------------------------------------------------------------------
function check_time_vector()
    t = validate_time_vector([0 1 2]);
    assert(isrow(t));
    assert_throws(@() validate_time_vector([0 2 1]), 'NDS:validate:timeNotIncreasing');
end

% -------------------------------------------------------------------------
function check_pack_result()
    traj = zeros(3, 1, 5);
    res = pack_result('degroot', 0:4, traj, [], struct(), []);
    assert(isequal(size(res.X), [3 5]), 'scalar case squeezed');
    assert(res.d == 1 && res.n == 3);
    assert(all(isnan(res.xinf)), 'missing limit becomes NaN');

    traj2 = zeros(3, 2, 5);
    res2 = pack_result('fj', 0:4, traj2, [], struct(), []);
    assert(isequal(size(res2.X), [3 2 5]), 'vector case kept as 3-D');
    assert_throws(@() pack_result('fj', 0:3, traj2, [], struct(), []), ...
        'NDS:packResult:sizeMismatch');
end

% -------------------------------------------------------------------------
function check_safe_predict()
    [v, info] = safe_predict(true, @() error('boom'));
    assert(isempty(v) && strcmp(info.status, 'failed'));
    [v, info] = safe_predict(false, @() 42);
    assert(isempty(v) && strcmp(info.status, 'skipped'));
    [v, info] = safe_predict(true, @(x) 2 * x, 21);
    assert(v == 42 && strcmp(info.status, 'ok'));
end

% -------------------------------------------------------------------------
function assert_throws(fcn, expectedId)
%ASSERT_THROWS Fail unless fcn raises an error with the given identifier.
    try
        fcn();
    catch err
        if ~strcmp(err.identifier, expectedId)
            error('NDS:test:wrongError', ...
                'Expected error "%s" but got "%s" (%s).', ...
                expectedId, err.identifier, err.message);
        end
        return;
    end
    error('NDS:test:noError', 'Expected error "%s" but none was raised.', expectedId);
end
