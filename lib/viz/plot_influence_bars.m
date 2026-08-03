function h = plot_influence_bars(values, varargin)
%PLOT_INFLUENCE_BARS Bar chart comparing node-importance measures.
%
%   h = PLOT_INFLUENCE_BARS(values) draws an n-by-1 vector as a bar chart.
%
%   h = PLOT_INFLUENCE_BARS(values) with an n-by-s matrix draws s grouped
%   series, which is the intended use: comparing measures that are often
%   assumed to agree and in fact do not.
%
%   Name-value options
%       'Labels'       n agent labels for the x axis
%       'SeriesNames'  s names for the legend
%       'Normalize'    scale each series to sum to 1 before plotting
%                      (default false). Use it when comparing measures on
%                      different scales, e.g. social power against
%                      betweenness centrality.
%       'Sort'         'none' (default) | 'descend' | 'ascend', ordering the
%                      agents by the FIRST series
%       'Highlight'    indices to mark with a star above the bar
%       'Axes'         axes to draw into
%       'Title'        figure title
%
%   MOTIVATION
%       On Krackhardt's advice network, French-DeGroot social power,
%       betweenness/Bonacich centrality and middleman (brokerage) power give
%       sharply different rankings: the strongest broker is only 13th in
%       social power, and the most central manager is not a broker at all.
%       Plotting them side by side is the clearest way to show that
%       dynamically generated influence, structural centrality and brokerage
%       are three different things.
%
%   See also PLOT_NETWORK, SOCIAL_POWER, FJ_MATRICES.

    validateattributes(values, {'numeric'}, ...
        {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'values', 1);

    if isrow(values)
        values = values(:);
    end
    [n, s] = size(values);

    opts = parse_options(struct( ...
        'Labels',      [], ...
        'SeriesNames', [], ...
        'Normalize',   false, ...
        'Sort',        'none', ...
        'Highlight',   [], ...
        'Axes',        [], ...
        'Title',       ''), varargin, mfilename);

    sortMode = validatestring(opts.Sort, {'none', 'descend', 'ascend'}, ...
        mfilename, 'Sort');

    if opts.Normalize
        totals = sum(abs(values), 1);
        totals(totals == 0) = 1;
        values = values ./ totals;
    end

    if isempty(opts.Labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    else
        labels = cellstr(opts.Labels);
        labels = labels(:);
        if numel(labels) ~= n
            error('NDS:plotInfluenceBars:labelCount', ...
                'Expected %d labels, got %d.', n, numel(labels));
        end
    end

    order = (1:n).';
    if ~strcmp(sortMode, 'none')
        [~, order] = sort(values(:, 1), sortMode);
        values = values(order, :);
        labels = labels(order);
    end

    ax = resolve_axes(opts.Axes);
    h = bar(ax, values);
    grid(ax, 'on');

    set(ax, 'XTick', 1:n, 'XTickLabel', labels, 'TickLabelInterpreter', 'none');
    if n > 20
        set(ax, 'XTickLabelRotation', 90);
    end

    if ~isempty(opts.SeriesNames)
        names = cellstr(opts.SeriesNames);
        if numel(names) ~= s
            error('NDS:plotInfluenceBars:seriesCount', ...
                'Expected %d series names, got %d.', s, numel(names));
        end
        for k = 1:s
            h(k).DisplayName = names{k};
        end
        legend(ax, 'Location', 'best', 'Interpreter', 'none');
    end

    if ~isempty(opts.Highlight)
        validateattributes(opts.Highlight, {'numeric'}, ...
            {'vector', 'integer', '>=', 1, '<=', n}, mfilename, 'Highlight');
        marked = ismember(order, opts.Highlight(:));
        positions = find(marked).';
        if ~isempty(positions)
            hold(ax, 'on');
            yTop = max(values(positions, :), [], 2).';
            offset = 0.04 * max(abs(values(:)));
            plot(ax, positions, yTop + offset, 'p', ...
                'MarkerSize', 10, 'MarkerFaceColor', [0.85 0.33 0.10], ...
                'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
            hold(ax, 'off');
        end
    end

    ylabel(ax, 'importance');
    if isempty(opts.Title)
        title(ax, 'Node importance');
    else
        title(ax, char(opts.Title));
    end

    if nargout == 0
        clear h;
    end
end
