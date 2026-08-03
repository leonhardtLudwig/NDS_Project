function [W, info] = row_normalize(A, varargin)
%ROW_NORMALIZE Scale the rows of a non-negative matrix to sum to one.
%
%   W = ROW_NORMALIZE(A) divides every row of A by its sum, producing the
%   row-stochastic influence matrix used by the French-DeGroot and
%   Friedkin-Johnsen models.
%
%   [W, info] = ROW_NORMALIZE(...) also returns diagnostics:
%       info.zeroRows   indices of rows of A that summed to zero
%       info.policy     the policy applied to those rows
%       info.rowSums    the original row sums
%
%   Name-value options
%       'ZeroRowPolicy'  How to treat an agent that accords weight to nobody
%                        (an all-zero row, i.e. an isolated or source node):
%           'selfloop' (default) set W(i,i) = 1. The agent keeps its opinion
%                      forever. NOTE: this CREATES A STUBBORN AGENT and
%                      therefore changes the dynamics -- it is a modelling
%                      decision, not a neutral fix, which is why it is
%                      recorded in info and warned about.
%           'error'    raise an error instead, so the caller must decide.
%           'keep'     leave the row as zeros. The result is then only
%                      sub-stochastic and must not be passed to models that
%                      require row-stochasticity.
%
%       'Warn'           Emit a warning when zero rows are patched
%                        (default true).
%
%   Real binary datasets such as Krackhardt's advice network normalise
%   cleanly because every actor names at least one contact; synthetic and
%   filtered networks often do not.
%
%   See also NET_FROM_MATRIX, IS_ROW_STOCHASTIC.

    n = validate_nonnegative_matrix(A, 'A');

    opts = parse_options(struct( ...
        'ZeroRowPolicy', 'selfloop', ...
        'Warn',          true), varargin, mfilename);

    policy = validatestring(opts.ZeroRowPolicy, {'selfloop', 'error', 'keep'}, ...
        mfilename, 'ZeroRowPolicy');

    rowSums = sum(A, 2);
    zeroRows = find(rowSums <= 0);

    W = A;

    if ~isempty(zeroRows)
        switch policy
            case 'error'
                error('NDS:rowNormalize:zeroRow', ...
                    ['Rows %s of A sum to zero: these agents accord weight to ' ...
                     'nobody. Choose a ZeroRowPolicy (''selfloop'' or ''keep'') ' ...
                     'or fix the data.'], mat2str(zeroRows(:).'));
            case 'selfloop'
                if opts.Warn
                    warning('NDS:rowNormalize:zeroRowPatched', ...
                        ['Rows %s of A summed to zero and were given a self-loop. ' ...
                         'Those agents are now STUBBORN (their opinion never changes).'], ...
                        mat2str(zeroRows(:).'));
                end
                rowSums(zeroRows) = 1;
                for k = 1:numel(zeroRows)
                    W(zeroRows(k), zeroRows(k)) = 1;
                end
            case 'keep'
                rowSums(zeroRows) = 1;   % avoid 0/0; the row stays all zeros
        end
    end

    nonZero = rowSums > 0;
    W(nonZero, :) = W(nonZero, :) ./ rowSums(nonZero);

    info = struct( ...
        'zeroRows', zeroRows(:).', ...
        'policy',   policy, ...
        'rowSums',  sum(A, 2).');

    if n == 0
        W = zeros(0, 0);
    end
end
