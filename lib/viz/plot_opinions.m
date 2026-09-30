function h = plot_opinions(X, t, varargin)
%PLOT_OPINIONS Plot opinion trajectories, annotated with their final values.
%
%   PLOT_OPINIONS(X) plots each row of the n-by-K trajectory X against the
%   step index, titles the figure with the name of the variable passed in,
%   and puts each agent's FINAL OPINION in the legend, so the outcome can be
%   read off the figure instead of inferred from it.
%
%   PLOT_OPINIONS(X, t) plots against the time vector t -- use this for the
%   continuous-time models, passing the same t given to the simulator. Pass []
%   to keep the step index.
%
%   PLOT_OPINIONS(X, t, Name, Value, ...) accepts
%
%       'Labels'     agent names for the legend
%       'Title'      override the automatic title (see below)
%       'Subtitle'   override the automatic subtitle (see below)
%       'Limit'      n-vector of theoretically predicted final opinions,
%                    drawn as dashed reference lines. Use it to show that
%                    theory and simulation agree.
%       'Prejudice'  n-vector of prejudices u, drawn as faint dotted lines,
%                    so that convergence into their convex hull is visible
%
%   h = PLOT_OPINIONS(...) returns the line handles.
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
%       The title names the variable; the subtitle states the number of
%       agents, the horizon, and the final spread max_i x_i - min_i x_i --
%       which is the number that distinguishes consensus from cleavage. A
%       spread of 0 means the group agreed; anything else is persistent
%       disagreement, and the legend shows exactly where each agent ended up.
%
%   Example
%       W = [1/2 1/2 0; 1/3 1/3 1/3; 0 1/2 1/2];
%       X = sim_degroot(W, [3; -1; 5], 30);
%       plot_opinions(X)
%       plot_opinions(X, [], 'Limit', social_power(W)' * [3; -1; 5] * ones(3,1))
%       plot_opinions(X, [], 'Title', 'Example 1.3', 'Subtitle', 'x(k+1) = Wx(k)')
%
%   See also PLOT_CONVERGENCE, PLOT_GRAPH, SIM_DEGROOT.

    if ndims(X) == 3
        error('NDS:plot_opinions:vectorOpinions', ...
            ['X holds vector-valued opinions. Plot one component at a time, ' ...
             'e.g. plot_opinions(squeeze(X(:,1,:))).']);
    end

    [n, K] = size(X);
    if nargin < 2, t = []; end

    opts = name_value(struct( ...
        'Labels',    [], ...
        'Title',     [], ...
        'Subtitle',  [], ...
        'Limit',     [], ...
        'Prejudice', []), varargin);
    labels = opts.Labels;

    if isempty(t)
        t = 0:K-1;
        xName = 'step k';
    else
        t = t(:).';
        xName = 'time t';
    end
    if isempty(labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    end
    labels = cellstr(labels);

    ax = prepare_axes();
    colors = lines(max(n, 7));
    hold(ax, 'on');

    % --- prejudices first, so the trajectories draw on top ---------------
    if ~isempty(opts.Prejudice)
        u = opts.Prejudice(:);
        for i = 1:n
            plot(ax, [t(1) t(end)], [u(i) u(i)], ':', ...
                'Color', [colors(i,:) 0.5], 'LineWidth', 0.8, ...
                'HandleVisibility', 'off');
        end
    end

    % --- predicted limits ------------------------------------------------
    if ~isempty(opts.Limit)
        xinf = opts.Limit(:);
        for i = 1:n
            plot(ax, [t(1) t(end)], [xinf(i) xinf(i)], '--', ...
                'Color', [colors(i,:) 0.7], 'LineWidth', 1.0, ...
                'HandleVisibility', 'off');
        end
    end

    % --- the trajectories ------------------------------------------------
    h = gobjects(n, 1);
    for i = 1:n
        h(i) = plot(ax, t, X(i,:), '-', 'Color', colors(i,:), 'LineWidth', 1.6);
    end

    grid(ax, 'on');
    xlabel(ax, xName);
    ylabel(ax, 'opinion  x_i');
    xlim(ax, [min(t) max(t)]);

    % --- the legend carries the final value ------------------------------
    if n <= 12
        entries = arrayfun(@(i) sprintf('%s  ->  %.4g', labels{i}, X(i,end)), ...
            (1:n).', 'UniformOutput', false);
        legend(ax, h, entries, 'Location', 'eastoutside', 'Interpreter', 'none');
    end

    % --- a title that identifies the run ---------------------------------
    autoName = inputname(1);
    if isempty(autoName), autoName = 'opinion trajectories'; end

    spread = max(X(:,end)) - min(X(:,end));
    info = sprintf('%d agents, %d samples, final spread = %.3g', n, K, spread);
    if ~isempty(opts.Limit)
        info = [info, '   (dashed = predicted limit)'];
    end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, info));

    hold(ax, 'off');
    if nargout == 0, clear h; end
end
