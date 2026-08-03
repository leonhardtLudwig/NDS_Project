function net = net_from_matrix(A, varargin)
%NET_FROM_MATRIX Build the canonical network structure from raw weights.
%
%   net = NET_FROM_MATRIX(A) wraps a non-negative weight matrix A into the
%   structure used throughout this project.
%
%   DIRECTION CONVENTION (project-wide, fixed once here)
%       A(i,j) > 0 means AGENT i ACCORDS WEIGHT TO AGENT j.
%       Equivalently: row i lists whom agent i listens to.
%       digraph(A)  is the "listening graph"  (arrow i -> j = i listens to j)
%       digraph(A') is the "influence graph"  (arrow along the flow of influence,
%                   matching the figures in Proskurnikov & Tempo)
%   Both conventions describe the same matrix; only the drawn arrows differ.
%
%   Output fields
%       net.name   : short identifier used in figure titles
%       net.n      : number of agents
%       net.labels : n-by-1 cell array of agent labels
%       net.A      : raw non-negative weights, exactly as supplied
%       net.W      : row-stochastic normalisation of A
%       net.L      : Laplacian of A, L = diag(A*1) - A
%       net.coords : n-by-2 layout used by PLOT_NETWORK
%       net.meta   : provenance struct (see below)
%
%   Both A and W are kept deliberately. The Abelson and Taylor models use the
%   RAW weights A, whose row sums set the speed at which each agent is pulled
%   towards its neighbours; silently normalising them would discard real
%   information. The French-DeGroot and Friedkin-Johnsen models require the
%   row-stochastic W.
%
%   Name-value options
%       'Name'          char, default 'network'
%       'Labels'        cellstr or string array of length n; default '1'..'n'
%       'Coords'        n-by-2 layout; default LAYOUT_POLYGON(n)
%       'Meta'          struct merged into net.meta
%       'ZeroRowPolicy' forwarded to ROW_NORMALIZE (default 'selfloop')
%       'Warn'          forwarded to ROW_NORMALIZE (default true)
%
%   net.meta records source, relation, timepoint, aggregation, normalisation
%   and free-form notes. Filling these in is not optional bookkeeping: the
%   Krackhardt network depends on which cognitive aggregation was used, and
%   the Sampson network depends on which relation and wave were selected.
%
%   See also ROW_NORMALIZE, GRAPH_REPORT, PLOT_NETWORK.

    n = validate_nonnegative_matrix(A, 'A');

    opts = parse_options(struct( ...
        'Name',          'network', ...
        'Labels',        [], ...
        'Coords',        [], ...
        'Meta',          struct(), ...
        'ZeroRowPolicy', 'selfloop', ...
        'Warn',          true), varargin, mfilename);

    % --- labels ----------------------------------------------------------
    if isempty(opts.Labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    else
        labels = cellstr(opts.Labels);
        labels = labels(:);
        if numel(labels) ~= n
            error('NDS:netFromMatrix:labelCount', ...
                'Labels must have %d entries to match the %d agents (got %d).', ...
                n, n, numel(labels));
        end
    end

    % --- layout ----------------------------------------------------------
    if isempty(opts.Coords)
        coords = layout_polygon(n);
    else
        coords = opts.Coords;
        validateattributes(coords, {'numeric'}, ...
            {'2d', 'ncols', 2, 'nrows', n, 'real', 'finite'}, ...
            mfilename, 'Coords');
    end

    % --- normalisation ---------------------------------------------------
    [W, normInfo] = row_normalize(A, ...
        'ZeroRowPolicy', opts.ZeroRowPolicy, 'Warn', opts.Warn);

    % --- provenance ------------------------------------------------------
    meta = struct( ...
        'source',        '', ...
        'relation',      '', ...
        'timepoint',     '', ...
        'aggregation',   '', ...
        'convention',    'A(i,j)>0 : agent i accords weight to agent j (row i = who i listens to)', ...
        'normalization', normInfo, ...
        'notes',         '');

    if ~isempty(opts.Meta)
        if ~isstruct(opts.Meta) || ~isscalar(opts.Meta)
            error('NDS:netFromMatrix:badMeta', 'Meta must be a scalar struct.');
        end
        userFields = fieldnames(opts.Meta);
        for k = 1:numel(userFields)
            meta.(userFields{k}) = opts.Meta.(userFields{k});
        end
    end

    % --- assemble --------------------------------------------------------
    net = struct();
    net.name   = char(opts.Name);
    net.n      = n;
    net.labels = labels;
    net.A      = A;
    net.W      = W;
    net.L      = diag(sum(A, 2)) - A;
    net.coords = coords;
    net.meta   = meta;
end
