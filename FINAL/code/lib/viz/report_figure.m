function fig = report_figure(wcm, hcm)
%REPORT_FIGURE Figure sized in centimetres, with the typography of the report.
%
%   fig = REPORT_FIGURE(wcm, hcm) opens a white figure wcm by hcm
%   centimetres, with 9 pt text and LaTeX tick labels, and a paper size equal
%   to the figure size, so that the exported .eps needs no rescaling when it
%   is included in the report at \textwidth.
%
%   The figure is VISIBLE, so it appears in the live script. The script that
%   generates the figures of the report keeps it invisible instead; that is
%   the only difference, and it does not affect the exported file.
%
%   Example
%       fig = report_figure(16, 10);
%
%   See also SAVE_EPS, PLOT_AGENT_TRAJECTORIES, FINISH_AXES.

    fig = figure('Units', 'centimeters', ...
        'Position', [2, 2, wcm, hcm], 'Color', 'w');
    set(fig, 'DefaultAxesFontSize', 9, 'DefaultTextFontSize', 9, ...
             'DefaultLegendFontSize', 9, 'DefaultAxesTickLabelInterpreter', 'latex');
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0, 0, wcm, hcm];
    fig.PaperSize = [wcm, hcm];
end
