function h = agent_proxies(ax, col, n)
%AGENT_PROXIES One invisible line per agent, carrying that agent's style.
%
%   h = AGENT_PROXIES(ax, col, n) plots n lines of NaN on the axes ax, with
%   EXACTLY the style PLOT_AGENT_TRAJECTORIES gives to each agent (agent 1
%   black, thick, with dots; the others thin and coloured), and returns their
%   handles.
%
%   They plot NaN, so they change neither the axes nor its limits. They exist
%   only to be the handles a legend is built from: a legend built on them
%   cannot pick up a reference line, a marker drawn apart or a curve of
%   another panel by mistake.
%
%   See also AGENT_LEGEND, PLOT_AGENT_TRAJECTORIES.

    hold(ax, 'on');
    h = gobjects(n,1);
    for i = 1:n
        if i == 1
            h(i) = plot(ax, NaN, NaN, '-o', 'Color', col(i,:), 'LineWidth', 1.8, ...
                'MarkerSize', 3, 'MarkerFaceColor', col(i,:));
        else
            h(i) = plot(ax, NaN, NaN, '-', 'Color', col(i,:), 'LineWidth', 1.0);
        end
    end
    hold(ax, 'off');
end
