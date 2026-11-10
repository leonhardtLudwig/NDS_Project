function h = plot_agent_trajectories(ax, X, K, col, n)
%PLOT_AGENT_TRAJECTORIES One opinion curve per agent, agent 1 highlighted.
%
%   h = PLOT_AGENT_TRAJECTORIES(ax, X, K, col, n) draws the rows of the
%   n-by-(K+1) trajectory X against k = 0, ..., K on the axes ax, using
%   col(i,:) for agent i, and returns the n line handles.
%
%   Agent 1 is the agent the report follows, so it is drawn thick and marked
%   with about ten dots along the curve; the others are thin plain lines.
%   A row of X that is all NaN draws nothing, which is how an agent that has
%   been removed from the model keeps its colour free.
%
%   The axes get the grid and the x limits of FINISH_AXES; the caller sets
%   the y limits.
%
%   See also AGENT_LEGEND, AGENT_PROXIES, FINISH_AXES.

    hold(ax, 'on');
    h = gobjects(n,1);
    step = max(1, round((K+1)/10));
    for i = 1:n
        if i == 1
            h(i) = plot(ax, 0:K, X(i,:), '-o', 'Color', col(i,:), 'LineWidth', 1.8, ...
                'MarkerSize', 3, 'MarkerFaceColor', col(i,:), 'MarkerIndices', 1:step:K+1);
        else
            h(i) = plot(ax, 0:K, X(i,:), '-', 'Color', col(i,:), 'LineWidth', 1.0);
        end
    end
    finish_axes(ax, [0 K], []);
    hold(ax, 'off');
end
