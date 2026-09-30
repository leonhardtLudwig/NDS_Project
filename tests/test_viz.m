function cases = test_viz()
%TEST_VIZ Smoke tests for the plotting layer.
%
%   Figures are documentation, and documentation that silently stops working
%   is worse than none. These tests draw every plot into an invisible figure
%   and check the annotations that make it self-explanatory: the title, the
%   caption, and the numeric edge labels.

    cases = { ...
        'plot_graph labels the edges with their weights', @check_graph_weights; ...
        'plot_graph draws self-loops',                    @check_graph_selfloops; ...
        'plot_graph suppresses labels on a large graph',  @check_graph_large; ...
        'plot_graph titles itself with the variable name',@check_graph_title; ...
        'plot_opinions puts final values in the legend',  @check_opinions; ...
        'plot_spectrum reports the period',               @check_spectrum; ...
        'plot_convergence, plot_bars run',                @check_others; ...
        'consecutive plots do not overlay',               @check_no_overlay; ...
        'a colourbar does not leak to the next plot',     @check_colorbar_cleared; ...
        'a legend does not leak to the next plot',        @check_legend_cleared; ...
        'HOLD ON is still honoured',                      @check_hold; ...
        'titles and subtitles are fully overridable',      @check_labels};
end

% -------------------------------------------------------------------------
function check_graph_weights()
    W = [1/2 1/2 0; 1/3 1/3 1/3; 0 1/2 1/2];
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    h = plot_graph(W, [], 'Layout', 'line');
    assert(~isempty(h.EdgeLabel), 'edge weights must be printed');
    assert(numel(h.EdgeLabel) == 7, 'seven edges including three self-loops');
    assert(any(strcmp(h.EdgeLabel, '0.5')), 'the value 0.5 appears as a label');
    assert(isa(ax, 'matlab.graphics.axis.Axes'));
end

% -------------------------------------------------------------------------
function check_graph_selfloops()
    % w_ii decides stubbornness and aperiodicity, so it must be visible.
    W = [0.5 0.5; 0 1];
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_graph(W);
    assert(contains(ax.Subtitle.String{1}, '3 edges'), ...
        'both self-loops are counted');

    plot_graph(W, [], 'SelfLoops', false);
    assert(contains(ax.Subtitle.String{1}, '1 edges'), ...
        'self-loops can be switched off explicitly');
end

% -------------------------------------------------------------------------
function check_graph_large()
    A = load_krackhardt();
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    h = plot_graph(A);
    assert(isempty(h.EdgeLabel), '129 edges are too many to label');
    assert(contains(ax.Subtitle.String{1}, 'too many edges'), ...
        'the figure must say why the weights are missing');

    h2 = plot_graph(A, [], 'Weights', true);
    assert(~isempty(h2.EdgeLabel), 'labelling can still be forced');
end

% -------------------------------------------------------------------------
function check_graph_title()
    W_demo = example_french3();   % named, so INPUTNAME can find it
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_graph(W_demo);
    assert(strcmp(ax.Title.String, 'W_demo'), ...
        'the title must carry the caller''s variable name');

    plot_graph(W_demo, [], 'Title', 'Example 1.3');
    assert(strcmp(ax.Title.String, 'Example 1.3'), 'the title can be overridden');

    plot_graph(example_french3());
    assert(strcmp(ax.Title.String, 'influence graph'), ...
        'an expression falls back to a generic name');
end

% -------------------------------------------------------------------------
function check_opinions()
    W = example_french3();
    x0 = [3; -1; 5];
    X_run = sim_degroot(W, x0, 20);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_opinions(X_run, [], 'Limit', (social_power(W).' * x0) * ones(3, 1));

    assert(strcmp(ax.Title.String, 'X_run'), 'titled with the variable name');
    entries = ax.Legend.String;
    assert(numel(entries) == 3, 'one legend entry per agent');
    assert(contains(entries{1}, '->'), 'the legend carries the final value');
    assert(contains(entries{1}, '1.857'), 'and that value is correct');
    assert(contains(ax.Subtitle.String, 'final spread'), 'the caption reports the spread');
end

% -------------------------------------------------------------------------
function check_spectrum()
    W_cycle = row_stochastic(ring_graph(5));
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_spectrum(W_cycle);
    caption = strjoin(cellstr(ax.Subtitle.String), ' ');
    assert(contains(caption, 'PERIODIC'), 'a periodic graph must say so');
    assert(contains(caption, 'period 5'), 'and state the period');

    plot_spectrum(-laplacian(ring_graph(5)), 'continuous');
    caption = strjoin(cellstr(ax.Subtitle.String), ' ');
    assert(contains(caption, 'origin'), 'the continuous caption reports the zero eigenvalue');
end

% -------------------------------------------------------------------------
function check_others()
    W = row_stochastic(two_communities(3, 3, 0.05));
    X = sim_degroot(W, (1:6).', 200);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    lam = sort(abs(eig(W)), 'descend');
    plot_convergence(X, [], 'Rate', lam(2));
    assert(contains(strjoin(cellstr(ax.Subtitle.String), ' '), 'final spread'));

    p = social_power(W);
    plot_bars(p, [], 'Sort', 'descend', 'YLabel', 'social power');
    assert(strcmp(ax.YLabel.String, 'social power'));
    assert(contains(strjoin(cellstr(ax.Subtitle.String), ' '), 'sorted descend'));
end

% -------------------------------------------------------------------------
function check_no_overlay()
    % REGRESSION. plot_graph ends with AXIS OFF and AXIS EQUAL. Without a full
    % reset the next plot inherits both and draws on top of the graph -- which
    % is exactly what happens in a Live Script, where consecutive cells share
    % the current figure.
    W = example_french3();
    X = sim_degroot(W, [3; -1; 5], 30);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_graph(W, [], 'Layout', 'line');
    plot_opinions(X);

    assert(numel(ax.Children) == 3, ...
        'only the three trajectories may remain, got %d children', numel(ax.Children));
    assert(strcmp(ax.Visible, 'on'), 'the axis must be visible again after plot_graph');
    assert(~isequal(ax.DataAspectRatio, [1 1 1]), ...
        'the equal aspect ratio of plot_graph must not persist');

    % ... and the other way round.
    plot_graph(W, [], 'Layout', 'line');
    assert(strcmp(ax.Visible, 'off'), 'plot_graph turns the axis off again');
    assert(isempty(ax.Legend), 'the trajectory legend must not survive');
end

% -------------------------------------------------------------------------
function check_colorbar_cleared()
    W = example_french3();
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_graph(W, [], 'NodeValue', social_power(W));
    assert(~isempty(findall(f, 'Type', 'ColorBar')), 'the colourbar was created');

    plot_bars(social_power(W));
    assert(isempty(findall(f, 'Type', 'ColorBar')), ...
        'the colourbar must not survive into the next plot');
    assert(isa(ax, 'matlab.graphics.axis.Axes'));
end

% -------------------------------------------------------------------------
function check_legend_cleared()
    W = example_french3();
    X = sim_degroot(W, [3; -1; 5], 10);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_opinions(X);
    assert(~isempty(ax.Legend), 'the legend was created');

    plot_convergence(X);
    assert(isempty(ax.Legend), 'the legend must not survive into the next plot');
end

% -------------------------------------------------------------------------
function check_hold()
    % A deliberate overlay must still work.
    W = example_french3();
    X1 = sim_degroot(W, [3; -1; 5], 10);
    X2 = sim_degroot(W, [0; 0; 6], 10);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_opinions(X1);
    hold(ax, 'on');
    plot_opinions(X2);
    assert(numel(ax.Children) == 6, ...
        'HOLD ON must accumulate both runs, got %d children', numel(ax.Children));
end

% -------------------------------------------------------------------------
function check_labels()
    % [] keeps the automatic text, a string replaces it, '' removes it.
    W_demo = example_french3();
    X_demo = sim_degroot(W_demo, [3; -1; 5], 10);
    [f, ax] = quiet_figure();
    restore = onCleanup(@() close(f));

    plot_graph(W_demo);
    assert(strcmp(ax.Title.String, 'W_demo'), 'automatic title');
    assert(~isempty(ax.Subtitle.String), 'automatic subtitle');

    plot_graph(W_demo, [], 'Title', 'Example 1.3', 'Subtitle', 'the matrix W');
    assert(strcmp(ax.Title.String, 'Example 1.3'), 'title replaced');
    assert(strcmp(ax.Subtitle.String, 'the matrix W'), 'subtitle replaced');

    plot_graph(W_demo, [], 'Title', '', 'Subtitle', '');
    assert(isempty(ax.Title.String), 'title suppressed');
    assert(isempty(ax.Subtitle.String), 'subtitle suppressed');

    % Same convention in every plotting function.
    plot_opinions(X_demo, [], 'Title', 'run A', 'Subtitle', '');
    assert(strcmp(ax.Title.String, 'run A') && isempty(ax.Subtitle.String));

    plot_opinions(X_demo, [], 'Labels', {'a','b','c'});
    assert(contains(ax.Legend.String{1}, 'a'), 'Labels is now a name-value option');

    plot_spectrum(W_demo, 'discrete', 'Subtitle', 'my caption');
    assert(strcmp(ax.Subtitle.String, 'my caption'));

    plot_convergence(X_demo, [], 'Title', 'decay');
    assert(strcmp(ax.Title.String, 'decay'));

    plot_bars(social_power(W_demo), [], 'Title', '', 'Subtitle', 'powers');
    assert(isempty(ax.Title.String) && strcmp(ax.Subtitle.String, 'powers'));

    % Setting them by hand afterwards must work too.
    plot_graph(W_demo);
    title(ax, 'set by hand'); subtitle(ax, 'also by hand');
    assert(strcmp(ax.Title.String, 'set by hand'));
    assert(strcmp(ax.Subtitle.String, 'also by hand'));
end

% -------------------------------------------------------------------------
function [f, ax] = quiet_figure()
%QUIET_FIGURE An invisible figure, so the suite runs headless.
    f = figure('Visible', 'off');
    ax = axes(f);
end
