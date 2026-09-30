function h = plot_graph(A, labels, varargin)
%PLOT_GRAPH Draw an influence digraph so that its matrix can be read off it.
%
%   PLOT_GRAPH(A) draws the digraph of A with the NUMERIC WEIGHTS printed on
%   the edges, self-loops included, and titles the figure with the name of the
%   variable that was passed in. A reader can therefore check the picture
%   against the matrix defined just above it, without reconstructing anything
%   from edge thickness.
%
%   PLOT_GRAPH(A, labels) labels the nodes. Pass [] to keep 1..n.
%
%   PLOT_GRAPH(A, labels, Name, Value, ...) accepts
%
%       'Title'      override the automatic title (see below)
%       'Subtitle'   override the automatic subtitle (see below)
%       'Weights'    'auto' (default) | true | false -- print the numeric edge
%                    weights. 'auto' prints them for graphs of at most 40
%                    edges and says so in the subtitle when it does not.
%       'Format'     number format for the weights (default '%.3g')
%       'NodeValue'  n-vector mapped to node colour, e.g. social power
%       'NodeName'   label for the colourbar (default 'node value')
%       'Layout'     n-by-2 coordinates, or 'circle' (default) | 'line' | 'star'
%                    'star' places node 1 at the centre and the remaining
%                    nodes on a ring around it, so that a star topology
%                    looks like one. On a circle layout the hub sits on the
%                    ring with its leaves and the picture reads as a polygon.
%       'SelfLoops'  true (default) | false
%
%   h = PLOT_GRAPH(...) returns the GraphPlot handle for further tweaking,
%   e.g. h.MarkerSize = 10.
%
%   TITLES AND SUBTITLES
%       By default the title is the caller's variable name and the subtitle
%       describes the contents. Both are fully under your control:
%
%           'Title', 'Example 1.3'      your own title
%           'Subtitle', 'matrix W'      your own subtitle
%           'Title', ''                 no title
%           'Subtitle', ''              no subtitle
%
%       Passing [] (the default) keeps the automatic text. You can equally
%       ignore the options and call TITLE and SUBTITLE yourself afterwards.
%
%   WHAT THE FIGURE TELLS YOU BY ITSELF
%       The title carries the variable name, so ten matrices in a notebook
%       give ten distinguishable figures. The subtitle states the number of
%       agents, whether the matrix is row-stochastic, and -- because it is the
%       single most confusable convention in this literature -- what the
%       arrows mean.
%
%   SELF-LOOPS ARE DRAWN. w_ii is not decoration: it is the agent's openness,
%   it decides stubbornness (w_ii = 1) and it is what makes a graph aperiodic.
%   Hiding it would hide the mathematics.
%
%   To draw the arrows the other way, along the FLOW OF INFLUENCE as in the
%   figures of Proskurnikov & Tempo, transpose: PLOT_GRAPH(W').
%
%   Example
%       W = [1/2 1/2 0; 1/3 1/3 1/3; 0 1/2 1/2];
%       plot_graph(W, [], 'Layout', 'line')          % titled "W"
%       plot_graph(row_stochastic(star_graph(6, 'bidirectional')), [], 'Layout', 'star')
%       plot_graph(W, [], 'NodeValue', social_power(W), 'NodeName', 'social power')
%
%   See also PLOT_OPINIONS, PLOT_SPECTRUM, SOCIAL_POWER.

    n = check_square(A, 'A');
    if nargin < 2, labels = []; end

    opts = name_value(struct( ...
        'Title',     [], ...
        'Subtitle',  [], ...
        'Weights',   'auto', ...
        'Format',    '%.3g', ...
        'NodeValue', [], ...
        'NodeName',  'node value', ...
        'Layout',    'circle', ...
        'SelfLoops', true), varargin);

    if isempty(labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    end
    labels = cellstr(labels);

    ax = prepare_axes();

    % --- graph -----------------------------------------------------------
    if opts.SelfLoops
        G = digraph(A, labels);
    else
        G = digraph(A, labels, 'omitselfloops');
    end

    coords = graph_layout(opts.Layout, n);
    h = plot(ax, G, 'XData', coords(:,1), 'YData', coords(:,2), ...
        'ArrowSize', 11, 'NodeFontSize', 10, 'MarkerSize', 7, ...
        'EdgeColor', [0.35 0.55 0.80], 'NodeColor', [0.10 0.30 0.65]);

    % --- edge weights, the whole point of this function ------------------
    showWeights = resolve_weights(opts.Weights, G.numedges);
    if showWeights && G.numedges > 0
        h.EdgeLabel = compose(opts.Format, G.Edges.Weight);
        h.EdgeFontSize = 9;
    end

    % --- thickness as a secondary cue ------------------------------------
    if G.numedges > 0
        w = G.Edges.Weight;
        if max(w) > min(w)
            h.LineWidth = 0.5 + 2.5 * (w - min(w)) / (max(w) - min(w));
        else
            h.LineWidth = 1.2;
        end
    end

    % --- node colouring --------------------------------------------------
    if ~isempty(opts.NodeValue)
        v = opts.NodeValue(:);
        h.NodeCData = v;

        % A constant measure -- uniform social power, say -- would otherwise
        % make MATLAB auto-scale the colour axis over rounding noise, so the
        % colourbar would report a range of 1e-16 and the nodes would look
        % like a gradient when they are all equal.
        if max(v) - min(v) <= 1e-9 * max(1, max(abs(v)))
            top = max(v);
            if top <= 0, top = 1; end
            clim(ax, [min(0, min(v)), top]);
        end

        c = colorbar(ax);
        c.Label.String = opts.NodeName;
    end

    % --- a title that identifies the matrix ------------------------------
    autoName = inputname(1);
    if isempty(autoName), autoName = 'influence graph'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, subtitle_text(A, n, G.numedges, showWeights)));

    axis(ax, 'equal');
    axis(ax, 'off');

    if nargout == 0, clear h; end
end

% -------------------------------------------------------------------------
function tf = resolve_weights(setting, numEdges)
    if ischar(setting) || isstring(setting)
        validatestring(setting, {'auto'});
        tf = numEdges <= 40;
    else
        tf = logical(setting);
    end
end

% -------------------------------------------------------------------------
function s = subtitle_text(A, n, numEdges, showWeights)
%SUBTITLE_TEXT One line stating what the reader is looking at.

    if is_row_stochastic(A)
        kind = 'row-stochastic';
    else
        kind = 'raw weights';
    end

    first = sprintf('%d agents, %d edges, %s', n, numEdges, kind);
    if ~showWeights
        first = [first, '  (too many edges to label)'];
    end
    s = {first, 'arrow i -> j : i accords weight to j'};
end

% -------------------------------------------------------------------------
function coords = graph_layout(layout, n)
%GRAPH_LAYOUT Node positions: explicit coordinates, a circle, or a line.

    if isnumeric(layout)
        if ~isequal(size(layout), [n 2])
            error('NDS:plot_graph:badLayout', ...
                'Layout must be an %d-by-2 matrix of coordinates.', n);
        end
        coords = layout;
        return;
    end

    switch validatestring(layout, {'circle', 'line', 'star'})
        case 'circle'
            theta = pi/2 - (0:n-1).' * 2*pi/n;   % node 1 at the top, clockwise
            coords = [cos(theta), sin(theta)];
        case 'line'
            coords = [(0:n-1).', zeros(n, 1)];
        case 'star'
            % Node 1 is the hub and goes in the middle; the leaves ring it.
            % Putting the hub on the ring with its own leaves, as 'circle'
            % does, makes a star look like a polygon: the one node that is
            % structurally different is drawn exactly like the others.
            theta = pi/2 - (0:n-2).' * 2*pi/(n-1);
            coords = [0, 0; cos(theta), sin(theta)];
    end
end
