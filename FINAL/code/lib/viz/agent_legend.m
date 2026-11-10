function lgd = agent_legend(tl, ax, col, n, sym, hExtra, labExtra)
%AGENT_LEGEND One legend for a whole tiled layout, one entry per agent.
%
%   lgd = AGENT_LEGEND(tl, ax, col, n) puts a single legend on the east tile
%   of the tiled layout tl, with one entry per agent labelled $x_1$ ... $x_n$
%   and built from AGENT_PROXIES, so that every entry carries the style of
%   its own curve.
%
%   lgd = AGENT_LEGEND(tl, ax, col, n, sym) uses sym instead of 'x' for the
%   symbol of the plotted quantity ('\delta', ...). If sym is a cell array it
%   is taken as the list of labels itself, for layouts whose rows plot
%   different quantities.
%
%   lgd = AGENT_LEGEND(tl, ax, col, n, sym, hExtra, labExtra) appends further
%   entries after the agents; hExtra must be a handle whose style is the one
%   to show, for instance a dashed reference line.
%
%   ax is the axes the proxy lines are drawn on; any axes of the layout does.
%
%   See also AGENT_PROXIES, PLOT_AGENT_TRAJECTORIES.

    if nargin < 5, sym = 'x'; end
    if iscell(sym)
        lab = sym;
    else
        lab = arrayfun(@(i) sprintf('$%s_%d$', sym, i), 1:n, 'UniformOutput', false);
    end
    h = agent_proxies(ax, col, n);
    if nargin >= 7 && ~isempty(hExtra)
        h   = [h; hExtra(:)];
        lab = [lab, reshape(labExtra, 1, [])];
    end
    lgd = legend(h, lab, 'Interpreter', 'latex');
    lgd.Layout.Tile = 'east';
end
