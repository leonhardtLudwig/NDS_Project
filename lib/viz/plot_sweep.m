function h = plot_sweep(V, values, labels, varargin)
%PLOT_SWEEP Heatmap of a per-agent quantity as one parameter is swept.
%
%   PLOT_SWEEP(V, values) draws the n-by-s matrix V as a heatmap: one row per
%   agent, one column per parameter value, with the numbers printed in the
%   cells. Column k holds the quantity at values(k).
%
%   PLOT_SWEEP(V, values, labels) labels the agents. Pass [] to keep 1..n.
%
%   PLOT_SWEEP(V, values, labels, Name, Value, ...) accepts
%
%       'Title'     override the automatic title      ([] auto, '' none)
%       'Subtitle'  override the automatic subtitle   ([] auto, '' none)
%       'Label'     name of the swept parameter, used as the x label
%       'YLabel'    y-axis label (default 'agent')
%       'Name'      what the colours mean, used on the colourbar
%       'Values'    'auto' (default) | true | false -- print the number in
%                   each cell. 'auto' prints them for at most 70 cells.
%       'Format'    number format for those labels (default '%.3g')
%
%   WHY A HEATMAP AND NOT GROUPED BARS
%       A sweep produces n*s numbers. As grouped bars that is s bars per
%       agent, and the eye has to compare across groups; as a heatmap the
%       whole table is one picture and structure in it -- a block, a
%       staircase, a row that never changes -- is visible at a glance. Use
%       PLOT_BARS when there are a few series to compare bar by bar, and this
%       when a parameter is genuinely swept.
%
%   Example
%       N  = 6;
%       M  = arrayfun(@(m) row_stochastic(ring_graph(N) + ...
%                diag([ones(m,1); zeros(N-m,1)])), 0:N, 'UniformOutput', false);
%       P  = cell2mat(arrayfun(@(m) social_power(M{m+1}), 0:N, 'UniformOutput', false));
%       plot_sweep(P, 0:N, [], 'Label', 'number of self-loops m', 'Name', 'social power')
%
%   See also PLOT_BARS, PLOT_SPECTRUM_FAMILY, SOCIAL_POWER.

    [n, s] = size(V);
    if nargin < 3, labels = []; end

    values = values(:).';
    if numel(values) ~= s
        error('NDS:plot_sweep:sizeMismatch', ...
            'V has %d columns but values has %d entries.', s, numel(values));
    end

    opts = name_value(struct( ...
        'Title',    [], ...
        'Subtitle', [], ...
        'Label',    'parameter', ...
        'YLabel',   'agent', ...
        'Name',     'value', ...
        'Values',   'auto', ...
        'Format',   '%.3g'), varargin);

    if isempty(labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    end
    labels = cellstr(labels);

    ax = prepare_axes();
    h = imagesc(ax, values, 1:n, V);
    colormap(ax, shading_map());
    c = colorbar(ax);
    c.Label.String = opts.Name;

    set(ax, 'XTick', values, 'YTick', 1:n, 'YTickLabel', labels, ...
        'TickLabelInterpreter', 'none');
    xlabel(ax, opts.Label);
    ylabel(ax, opts.YLabel);

    % --- the numbers, in a colour that stays readable on every cell ------
    if resolve_values(opts.Values, n * s)
        lo = min(V(:));
        hi = max(V(:));
        for i = 1:n
            for k = 1:s
                if hi > lo && (V(i,k) - lo) / (hi - lo) > 0.6
                    ink = [1 1 1];          % white on the dark end
                else
                    ink = [0 0 0];
                end
                text(ax, values(k), i, sprintf(opts.Format, V(i,k)), ...
                    'HorizontalAlignment', 'center', 'FontSize', 8, 'Color', ink);
            end
        end
    end

    autoName = inputname(1);
    if isempty(autoName), autoName = 'sweep'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, ...
                        sprintf('%d agents, %s from %g to %g', ...
                            n, opts.Label, values(1), values(end))));

    if nargout == 0, clear h; end
end

% -------------------------------------------------------------------------
function map = shading_map()
%SHADING_MAP Light-to-dark blue, so that "more" reads as "darker".

    t = linspace(0, 1, 256).';
    pale = [0.97 0.98 1.00];
    deep = [0.06 0.20 0.50];
    map = (1 - t) * pale + t * deep;
end

% -------------------------------------------------------------------------
function tf = resolve_values(setting, numCells)
    if ischar(setting) || isstring(setting)
        validatestring(setting, {'auto'});
        tf = numCells <= 70;
    else
        tf = logical(setting);
    end
end
