function opts = name_value(defaults, args)
%NAME_VALUE Merge name-value arguments into a struct of defaults.
%
%   opts = NAME_VALUE(defaults, args) takes a struct of default option values
%   and a cell array of name-value pairs (typically VARARGIN), and returns the
%   merged options. Names are matched case-insensitively; an unknown name
%   raises an error listing the valid ones.
%
%   Used only by the plotting functions, which need a handful of options to
%   make a figure self-explanatory. It performs no mathematics.
%
%   See also PLOT_GRAPH, PLOT_OPINIONS.

    opts = defaults;
    valid = fieldnames(defaults);

    if mod(numel(args), 2) ~= 0
        error('NDS:name_value:oddArguments', ...
            'Options must be given as name-value pairs.');
    end

    for k = 1:2:numel(args)
        idx = find(strcmpi(args{k}, valid), 1);
        if isempty(idx)
            error('NDS:name_value:unknownOption', ...
                'Unknown option "%s". Valid options: %s.', ...
                char(string(args{k})), strjoin(valid', ', '));
        end
        opts.(valid{idx}) = args{k + 1};
    end
end
