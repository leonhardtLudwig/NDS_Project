function finish_axes(ax, xl, yl)
%FINISH_AXES Grid and axis limits shared by the figures of the report.
%
%   FINISH_AXES(ax, xl, yl) switches on a light grid (GridAlpha 0.15) and
%   applies the limits xl and yl. An empty limit is left to MATLAB.
%
%   See also PLOT_AGENT_TRAJECTORIES, REPORT_FIGURE.

    grid(ax, 'on');  ax.GridAlpha = 0.15;
    if ~isempty(xl), xlim(ax, xl); end
    if ~isempty(yl), ylim(ax, yl); end
end
