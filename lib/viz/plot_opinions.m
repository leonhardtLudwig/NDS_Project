function h = plot_opinions(res, varargin)
%PLOT_OPINIONS Trajectories of every agent's opinion over time.
%
%   h = PLOT_OPINIONS(res) plots the opinion of each agent against time for a
%   result structure produced by any of the four simulators, and returns the
%   line handles. Discrete-time models are drawn as stairs, continuous-time
%   models as smooth curves, so the two are visually distinguishable.
%
%   Name-value options
%       'Axes'       axes to draw into (default: a new figure)
%       'Prejudice'  n-vector of prejudices u; drawn as faint dashed
%                    horizontal lines so that convergence into their convex
%                    hull is visible at a glance
%       'Limit'      show the predicted limit as markers on the right edge
%                    (default true when res.xinf is finite)
%       'Highlight'  indices of agents to draw with a thicker line, e.g. the
%                    stubborn ones
%       'Labels'     agent labels (default from res.net, else 1..n)
%       'Legend'     true | false | 'auto' (default 'auto': shown for n <= 12)
%       'Dimension'  which opinion dimension to plot when d > 1 (default 1)
%       'Title'      figure title (default derived from the model name)
%
%   Example
%       [net, u, x0] = make_example_fj4();
%       res = sim_friedkin_johnsen(net, fj_lambda(net,'classic'), u, x0, 12);
%       plot_opinions(res, 'Prejudice', u, 'Highlight', 3);
%
%   See also PLOT_CONVERGENCE, PLOT_NETWORK, PLOT_ALPHA_SWEEP.

    validate_result(res);

    opts = parse_options(struct( ...
        'Axes',      [], ...
        'Prejudice', [], ...
        'Limit',     [], ...
        'Highlight', [], ...
        'Labels',    [], ...
        'Legend',    'auto', ...
        'Dimension', 1, ...
        'Title',     ''), varargin, mfilename);

    n = res.n;
    X = select_dimension(res, opts.Dimension);
    t = res.t;
    labels = resolve_labels(res, opts.Labels, n);

    ax = resolve_axes(opts.Axes);
    hold(ax, 'on');
    grid(ax, 'on');

    colors = lines(max(n, 1));
    isDiscrete = any(strcmp(res.model, {'degroot', 'fj'}));

    highlight = false(n, 1);
    if ~isempty(opts.Highlight)
        validateattributes(opts.Highlight, {'numeric'}, ...
            {'vector', 'integer', '>=', 1, '<=', n}, mfilename, 'Highlight');
        highlight(opts.Highlight) = true;
    end

    % Prejudice reference lines first, so the trajectories draw on top.
    if ~isempty(opts.Prejudice)
        uVec = prepare_state(opts.Prejudice, n, 'Prejudice');
        uVec = uVec(:, min(opts.Dimension, size(uVec, 2)));
        for ii = 1:n
            plot(ax, [t(1), t(end)], [uVec(ii), uVec(ii)], ':', ...
                'Color', [colors(ii, :), 0.45], 'LineWidth', 0.75, ...
                'HandleVisibility', 'off');
        end
    end

    h = gobjects(n, 1);
    for ii = 1:n
        if highlight(ii)
            lw = 2.6;
        else
            lw = 1.4;
        end
        if isDiscrete
            h(ii) = plot(ax, t, X(ii, :), '-o', ...
                'Color', colors(ii, :), 'LineWidth', lw);
        else
            h(ii) = plot(ax, t, X(ii, :), '-', ...
                'Color', colors(ii, :), 'LineWidth', lw);
        end
    end

    if show_limit(res, opts.Limit)
        xinf = res.xinf(:, min(opts.Dimension, size(res.xinf, 2)));
        for ii = 1:n
            plot(ax, t(end), xinf(ii), 'o', ...
                'MarkerSize', 5, 'MarkerEdgeColor', colors(ii, :), ...
                'MarkerFaceColor', 'w', 'LineWidth', 1.2, ...
                'HandleVisibility', 'off');
        end
    end

    if isDiscrete
        xlabel(ax, 'step k');
    else
        xlabel(ax, 'time t');
    end
    ylabel(ax, 'opinion');
    title(ax, resolve_title(res, opts.Title));
    xlim(ax, [t(1), max(t(end), t(1) + eps)]);

    if want_legend(opts.Legend, n)
        legend(ax, h, labels, 'Location', 'best', 'Interpreter', 'none');
    end
    hold(ax, 'off');

    if nargout == 0
        clear h;
    end
end

% -------------------------------------------------------------------------
function X = select_dimension(res, dimIndex)
    validateattributes(dimIndex, {'numeric'}, ...
        {'scalar', 'integer', '>=', 1}, mfilename, 'Dimension');
    if res.d == 1
        X = res.X;
    else
        if dimIndex > res.d
            error('NDS:plotOpinions:badDimension', ...
                'Dimension %d requested but the opinions have dimension %d.', ...
                dimIndex, res.d);
        end
        X = reshape(res.X(:, dimIndex, :), res.n, []);
    end
end

% -------------------------------------------------------------------------
function tf = show_limit(res, requested)
    if isempty(requested)
        tf = all(isfinite(res.xinf(:)));
    else
        tf = logical(requested) && all(isfinite(res.xinf(:)));
    end
end

% -------------------------------------------------------------------------
function tf = want_legend(setting, n)
    if ischar(setting) || isstring(setting)
        validatestring(setting, {'auto'}, mfilename, 'Legend');
        tf = (n <= 12);
    else
        tf = logical(setting);
    end
end

% -------------------------------------------------------------------------
function labels = resolve_labels(res, userLabels, n)
    if ~isempty(userLabels)
        labels = cellstr(userLabels);
    elseif ~isempty(res.net) && isfield(res.net, 'labels')
        labels = res.net.labels;
    else
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    end
    labels = labels(:);
    if numel(labels) ~= n
        error('NDS:plotOpinions:labelCount', ...
            'Expected %d labels, got %d.', n, numel(labels));
    end
end

% -------------------------------------------------------------------------
function str = resolve_title(res, userTitle)
    if ~isempty(userTitle)
        str = char(userTitle);
        return;
    end
    names = struct('degroot', 'French-DeGroot', 'abelson', 'Abelson', ...
        'taylor', 'Taylor', 'fj', 'Friedkin-Johnsen');
    if isfield(names, res.model)
        str = names.(res.model);
    else
        str = res.model;
    end
    if ~isempty(res.net) && isfield(res.net, 'name')
        str = sprintf('%s  --  %s', str, res.net.name);
    end
end

% -------------------------------------------------------------------------
function validate_result(res)
    required = {'model', 't', 'X', 'n', 'd', 'xinf'};
    if ~isstruct(res) || ~isscalar(res) || ~all(isfield(res, required))
        error('NDS:plotOpinions:badResult', ...
            ['Input must be a result structure returned by one of the SIM_* ' ...
             'functions (missing one of: %s).'], strjoin(required, ', '));
    end
end
