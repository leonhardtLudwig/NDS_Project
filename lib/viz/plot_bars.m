function h = plot_bars(values, labels, varargin)
%PLOT_BARS Bar chart of node measures, with the values printed on the bars.
%
%   PLOT_BARS(v) draws the n-vector v as a bar chart, prints each value above
%   its bar, and titles the figure with the name of the variable passed in.
%
%   PLOT_BARS(V, labels) draws the columns of an n-by-s matrix as grouped
%   series and labels the agents. Pass [] to keep 1..n.
%
%   PLOT_BARS(V, labels, Name, Value, ...) accepts
%
%       'Title'    override the automatic title (see below)
%       'Subtitle' override the automatic subtitle (see below)
%       'Series'   s names for the legend
%       'Sort'     'none' (default) | 'descend' | 'ascend', ordering the
%                  agents by the first series
%       'Values'   'auto' (default) | true | false -- print the numeric value
%                  above each bar. 'auto' prints them when there are at most
%                  15 bars in total.
%       'Format'   number format for those labels (default '%.3g')
%       'YLabel'   y-axis label (default 'value')
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
%   Use it to compare measures that are often assumed to agree and do not --
%   social power against betweenness against brokerage, for instance. Scale
%   the columns yourself (e.g. V ./ sum(V)) when they live on different scales.
%
%   Example
%       [A, names] = load_krackhardt();
%       p = social_power(row_stochastic(A));
%       plot_bars(p, names, 'Sort', 'descend', 'YLabel', 'social power')
%
%   See also PLOT_GRAPH, SOCIAL_POWER, KRACKHARDT_BENCHMARKS.

    if isrow(values), values = values(:); end
    [n, s] = size(values);
    if nargin < 2, labels = []; end

    opts = name_value(struct( ...
        'Title',  [], ...
        'Subtitle', [], ...
        'Series', [], ...
        'Sort',   'none', ...
        'Values', 'auto', ...
        'Format', '%.3g', ...
        'YLabel', 'value'), varargin);

    if isempty(labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    end
    labels = cellstr(labels);
    labels = labels(:);

    sortMode = validatestring(opts.Sort, {'none', 'descend', 'ascend'});
    if ~strcmp(sortMode, 'none')
        [~, order] = sort(values(:,1), sortMode);
        values = values(order, :);
        labels = labels(order);
    end

    ax = prepare_axes();
    h = bar(ax, values);
    grid(ax, 'on');
    set(ax, 'XTick', 1:n, 'XTickLabel', labels, 'TickLabelInterpreter', 'none');
    if n > 20
        set(ax, 'XTickLabelRotation', 90);
    end
    ylabel(ax, opts.YLabel);

    % --- the numbers, printed where they can be read ---------------------
    if resolve_values(opts.Values, n * s)
        hold(ax, 'on');
        for k = 1:s
            text(ax, h(k).XEndPoints, h(k).YEndPoints, ...
                compose(opts.Format, values(:,k).'), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8);
        end
        hold(ax, 'off');
        ylim(ax, [min(0, 1.15*min(values(:))), 1.15 * max(values(:))]);
    end

    if ~isempty(opts.Series)
        series = cellstr(opts.Series);
        for k = 1:numel(h)
            h(k).DisplayName = series{k};
        end
        legend(ax, 'Location', 'best', 'Interpreter', 'none');
    end

    autoName = inputname(1);
    if isempty(autoName), autoName = 'node measure'; end
    info = sprintf('%d agents', n);
    if ~strcmp(sortMode, 'none')
        info = [info, sprintf(', sorted %s', sortMode)];
    end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, info));

    if nargout == 0, clear h; end
end

% -------------------------------------------------------------------------
function tf = resolve_values(setting, numBars)
    if ischar(setting) || isstring(setting)
        validatestring(setting, {'auto'});
        tf = numBars <= 15;
    else
        tf = logical(setting);
    end
end
