function summary = run_all_tests(varargin)
%RUN_ALL_TESTS Execute the whole test suite and report the outcome.
%
%   RUN_ALL_TESTS() discovers every test_*.m file in the tests folder, runs
%   all the cases each declares, prints a per-case report and raises an error
%   if anything failed -- so that
%
%       matlab -batch "setup_paths; run_all_tests"
%
%   returns a non-zero exit status on failure and can be used in CI.
%
%   summary = RUN_ALL_TESTS() returns a struct with fields total, passed,
%   failed and failures (a struct array of name and message).
%
%   Name-value options
%       'Filter'  substring; only test files whose name contains it are run
%       'Verbose' print each passing case as well as each failure (default true)
%
%   TEST FILE CONTRACT
%       A test file is a function taking no arguments and returning an
%       N-by-2 cell array: column 1 a descriptive name, column 2 a handle to
%       a local function that takes no arguments and throws on failure.
%
%   See also ASSERT_CLOSE.

    opts = parse_options(struct( ...
        'Filter',  '', ...
        'Verbose', true), varargin, mfilename);

    testsDir = fileparts(mfilename('fullpath'));
    files = dir(fullfile(testsDir, 'test_*.m'));
    names = sort({files.name});

    if ~isempty(opts.Filter)
        names = names(contains(names, opts.Filter));
    end

    summary = struct('total', 0, 'passed', 0, 'failed', 0, ...
        'failures', struct('name', {}, 'message', {}));

    fprintf('\n=== NDS opinion-dynamics test suite ===\n');

    for f = 1:numel(names)
        [~, fileStem] = fileparts(names{f});
        fprintf('\n%s\n', fileStem);

        try
            cases = feval(fileStem);
        catch err
            fprintf('  !! could not load test file: %s\n', err.message);
            summary.total = summary.total + 1;
            summary.failed = summary.failed + 1;
            summary.failures(end+1) = struct( ...
                'name', fileStem, 'message', err.message);
            continue;
        end

        if ~iscell(cases) || size(cases, 2) ~= 2
            error('NDS:runAllTests:badContract', ...
                '%s must return an N-by-2 cell array of {name, handle}.', fileStem);
        end

        for c = 1:size(cases, 1)
            caseName = cases{c, 1};
            caseFcn  = cases{c, 2};
            summary.total = summary.total + 1;
            try
                caseFcn();
                summary.passed = summary.passed + 1;
                if opts.Verbose
                    fprintf('  [pass] %s\n', caseName);
                end
            catch err
                summary.failed = summary.failed + 1;
                summary.failures(end+1) = struct( ...
                    'name', sprintf('%s / %s', fileStem, caseName), ...
                    'message', err.message);
                fprintf('  [FAIL] %s\n         %s\n', caseName, err.message);
            end
        end
    end

    fprintf('\n---------------------------------------\n');
    fprintf('%d tests, %d passed, %d failed\n', ...
        summary.total, summary.passed, summary.failed);

    if summary.failed > 0
        fprintf('\nFailures:\n');
        for k = 1:numel(summary.failures)
            fprintf('  - %s\n      %s\n', ...
                summary.failures(k).name, summary.failures(k).message);
        end
        fprintf('\n');
        error('NDS:runAllTests:failures', ...
            '%d of %d tests failed.', summary.failed, summary.total);
    end

    fprintf('All tests passed.\n\n');

    if nargout == 0
        clear summary;
    end
end
