function summary = run_all_tests(filter)
%RUN_ALL_TESTS Execute the whole test suite and report the outcome.
%
%   RUN_ALL_TESTS() discovers every test_*.m file in the tests folder, runs
%   all the cases each declares, prints a report and raises an error if
%   anything failed -- so that
%
%       matlab -batch "setup_paths; run_all_tests"
%
%   returns a non-zero exit status on failure.
%
%   RUN_ALL_TESTS(filter) runs only the test files whose name contains the
%   given substring.
%
%   TEST FILE CONTRACT
%       A test file is a function taking no arguments and returning an
%       N-by-2 cell array: column 1 a descriptive name, column 2 a handle to
%       a local function that takes no arguments and throws on failure.
%
%   See also ASSERT_CLOSE.

    if nargin < 1, filter = ''; end

    testsDir = fileparts(mfilename('fullpath'));
    files = dir(fullfile(testsDir, 'test_*.m'));
    names = sort({files.name});
    if ~isempty(filter)
        names = names(contains(names, filter));
    end

    total = 0; passed = 0; failures = {};
    fprintf('\n=== NDS opinion-dynamics test suite ===\n');

    for f = 1:numel(names)
        [~, stem] = fileparts(names{f});
        fprintf('\n%s\n', stem);
        cases = feval(stem);
        for c = 1:size(cases, 1)
            total = total + 1;
            try
                cases{c, 2}();
                passed = passed + 1;
                fprintf('  [pass] %s\n', cases{c, 1});
            catch err
                failures{end+1} = sprintf('%s / %s: %s', ...
                    stem, cases{c, 1}, err.message); %#ok<AGROW>
                fprintf('  [FAIL] %s\n         %s\n', cases{c, 1}, err.message);
            end
        end
    end

    fprintf('\n---------------------------------------\n');
    fprintf('%d tests, %d passed, %d failed\n', total, passed, total - passed);

    summary = struct('total', total, 'passed', passed, ...
        'failed', total - passed, 'failures', {failures});

    if ~isempty(failures)
        error('NDS:runAllTests:failures', '%d of %d tests failed.', ...
            numel(failures), total);
    end
    fprintf('All tests passed.\n\n');

    if nargout == 0, clear summary; end
end
