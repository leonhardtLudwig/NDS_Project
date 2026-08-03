function net = make_complete(n, varargin)
%MAKE_COMPLETE All-to-all network -- the topology-free control case.
%
%   net = MAKE_COMPLETE(n) builds the uniform complete network in which every
%   agent gives equal weight 1/n to everyone including itself.
%
%   Name-value options
%       'IncludeSelf'  true (default) weight 1/n on all n agents
%                      false          weight 1/(n-1) on the others only
%
%   Why this network matters
%       With 'IncludeSelf' true the French-DeGroot model reaches consensus in
%       a SINGLE step, and social power is uniform. That makes this network
%       the ideal control case: it removes topology as a variable, so any
%       disagreement observed in the Friedkin-Johnsen model must come from
%       the susceptibility matrix Lambda alone.
%
%       With 'IncludeSelf' false and n = 2 the network is the 2-cycle and is
%       periodic; for n >= 3 it is aperiodic.
%
%   See also MAKE_RING, MAKE_STAR, MAKE_TWO_COMMUNITIES.

    validateattributes(n, {'numeric'}, ...
        {'scalar', 'integer', '>=', 2}, mfilename, 'n', 1);

    opts = parse_options(struct('IncludeSelf', true), varargin, mfilename);
    validateattributes(opts.IncludeSelf, {'logical', 'numeric'}, ...
        {'scalar', 'binary'}, mfilename, 'IncludeSelf');

    if opts.IncludeSelf
        A = ones(n) / n;
        tag = 'withself';
    else
        A = (ones(n) - eye(n)) / (n - 1);
        tag = 'noself';
    end

    net = net_from_matrix(A, ...
        'Name', sprintf('complete-%s-n%d', tag, n), ...
        'Coords', layout_polygon(n), ...
        'Meta', struct( ...
            'source', 'synthetic', ...
            'notes',  sprintf('complete graph, self-weight included: %d', opts.IncludeSelf)));
end
