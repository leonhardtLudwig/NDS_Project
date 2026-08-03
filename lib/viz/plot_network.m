function h = plot_network(net, varargin)
%PLOT_NETWORK Draw an influence network with node colouring and sizing.
%
%   h = PLOT_NETWORK(net) draws the network and returns the GraphPlot handle.
%
%   Name-value options
%       'Axes'       axes to draw into (default: a new figure)
%       'NodeValue'  n-vector mapped to node colour through the colormap,
%                    e.g. final opinions or social power
%       'NodeSize'   n-vector mapped to marker size, e.g. influence centrality
%       'Direction'  'listening' (default) draws i -> j when i listens to j
%                    'influence' draws arrows along the flow of influence,
%                                matching the figures of Proskurnikov & Tempo
%       'EdgeWeights' true (default) scales line width by weight
%       'Labels'     node labels (default net.labels)
%       'Colorbar'   show a colorbar for NodeValue (default true)
%       'Title'      figure title (default net.name)
%
%   DIRECTION MATTERS
%       The two conventions describe the SAME matrix and differ only in which
%       way the arrows point. 'listening' is the project's internal
%       convention and is what every analysis function operates on;
%       'influence' is the one used in the tutorial's figures. The option
%       exists so that a figure can be matched to a published one without
%       ever transposing the data.
%
%   Example
%       net = load_krackhardt();
%       plot_network(net, 'NodeValue', social_power(net), 'Direction', 'influence');
%
%   See also PLOT_OPINIONS, PLOT_INFLUENCE_BARS, NET_FROM_MATRIX.

    if ~isstruct(net) || ~all(isfield(net, {'W', 'n', 'coords', 'labels'}))
        error('NDS:plotNetwork:badNetwork', ...
            'Input must be a network structure built by NET_FROM_MATRIX.');
    end

    opts = parse_options(struct( ...
        'Axes',        [], ...
        'NodeValue',   [], ...
        'NodeSize',    [], ...
        'Direction',   'listening', ...
        'EdgeWeights', true, ...
        'Labels',      [], ...
        'Colorbar',    true, ...
        'Title',       ''), varargin, mfilename);

    direction = validatestring(opts.Direction, {'listening', 'influence'}, ...
        mfilename, 'Direction');

    n = net.n;
    W = net.W;
    coords = net.coords;

    if strcmp(direction, 'influence')
        W = W.';
        coords = net.coords;    % positions are unchanged; only arrows flip
    end

    if isempty(opts.Labels)
        labels = net.labels;
    else
        labels = cellstr(opts.Labels);
    end
    labels = labels(:);
    if numel(labels) ~= n
        error('NDS:plotNetwork:labelCount', ...
            'Expected %d labels, got %d.', n, numel(labels));
    end

    ax = resolve_axes(opts.Axes);

    G = digraph(W, labels, 'omitselfloops');
    h = plot(ax, G, 'XData', coords(:, 1), 'YData', coords(:, 2), ...
        'ArrowSize', 9, 'NodeFontSize', 8);

    if opts.EdgeWeights && G.numedges > 0
        w = G.Edges.Weight;
        span = max(w) - min(w);
        if span > 0
            h.LineWidth = 0.5 + 2.5 * (w - min(w)) / span;
        end
    end

    if ~isempty(opts.NodeValue)
        v = validate_node_vector(opts.NodeValue, n, 'NodeValue');
        h.NodeCData = v;
        colormap(ax, parula);
        if opts.Colorbar
            colorbar(ax);
        end
    end

    if ~isempty(opts.NodeSize)
        s = validate_node_vector(opts.NodeSize, n, 'NodeSize');
        span = max(s) - min(s);
        if span > 0
            h.MarkerSize = 4 + 12 * (s - min(s)) / span;
        else
            h.MarkerSize = 6;
        end
    end

    if isempty(opts.Title)
        titleText = sprintf('%s  (%s graph)', net.name, direction);
    else
        titleText = char(opts.Title);
    end
    title(ax, titleText, 'Interpreter', 'none');
    axis(ax, 'equal');
    axis(ax, 'off');

    if nargout == 0
        clear h;
    end
end

% -------------------------------------------------------------------------
function v = validate_node_vector(v, n, name)
    validateattributes(v, {'numeric'}, ...
        {'vector', 'numel', n, 'real', 'finite'}, mfilename, name);
    v = double(v(:));
end
