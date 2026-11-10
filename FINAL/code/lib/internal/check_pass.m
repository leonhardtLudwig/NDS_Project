function pass = check_pass(pass, ok, msg)
%CHECK_PASS Accumulate the outcome of a numerical check.
%
%   pass = CHECK_PASS(pass, ok, msg) returns pass unchanged when ok is true.
%   When ok is false it prints msg and returns false, so that a single
%   variable carries the verdict of a whole sequence of checks:
%
%       pass = true;
%       pass = check_pass(pass, abs(x - 1) < 1e-9, '  MISMATCH, expected 1');
%
%   The message is printed as it is, so it should already carry its own
%   indentation.

    if ~ok
        fprintf('%s\n', msg);
        pass = false;
    end
end
