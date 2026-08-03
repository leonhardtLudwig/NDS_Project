function opts = parse_options(defaults, args, fname)
%PARSE_OPTIONS Merge name-value arguments into a struct of defaults.
%
%   opts = PARSE_OPTIONS(defaults, args, fname) takes a struct of default
%   option values, a cell array of name-value pairs (typically VARARGIN) and
%   the caller's name, and returns the merged options.
%
%   Option names are matched case-insensitively. An unknown name raises an
%   error that lists the valid options, which is far more useful during
%   interactive work than silently ignoring a typo.
%
%   Example
%       function y = myfun(x, varargin)
%           opts = parse_options(struct('Scale', 1), varargin, mfilename);
%
%   See also INPUTPARSER.

    narginchk(2, 3);
    if nargin < 3 || isempty(fname)
        fname = 'function';
    end

    if ~isstruct(defaults) || ~isscalar(defaults)
        error('NDS:parseOptions:badDefaults', ...
            'defaults must be a scalar struct.');
    end
    if ~iscell(args)
        error('NDS:parseOptions:badArgs', ...
            'Name-value arguments must be supplied as a cell array.');
    end
    if mod(numel(args), 2) ~= 0
        error('NDS:parseOptions:oddArguments', ...
            ['%s expects name-value pairs, but received an odd number of ' ...
             'optional arguments (%d).'], fname, numel(args));
    end

    opts = defaults;
    validNames = fieldnames(defaults);

    for k = 1:2:numel(args)
        name = args{k};
        if ~(ischar(name) || (isstring(name) && isscalar(name)))
            error('NDS:parseOptions:badName', ...
                '%s: option name in position %d must be a string.', fname, k);
        end
        name = char(name);

        idx = find(strcmpi(name, validNames), 1);
        if isempty(idx)
            error('NDS:parseOptions:unknownOption', ...
                '%s: unknown option "%s". Valid options are: %s.', ...
                fname, name, strjoin(validNames', ', '));
        end

        opts.(validNames{idx}) = args{k + 1};
    end
end
