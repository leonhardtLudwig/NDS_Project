function m = plot_stability_margin(Ms, labels, domain, varargin)
%PLOT_STABILITY_MARGIN Compare several systems by the one eigenvalue that decides stability.
%
%   PLOT_STABILITY_MARGIN(Ms, labels) draws, for each matrix in the cell array
%   Ms, the single spectral quantity that decides whether its dynamics is
%   asymptotically stable, against the stability boundary.
%
%       'continuous'   the SPECTRAL ABSCISSA max Re(lambda); the boundary is 0
%       'discrete'     the SPECTRAL RADIUS  max |lambda|;    the boundary is 1
%
%   PLOT_STABILITY_MARGIN(Ms, labels, domain) chooses the reading; 'discrete'
%   is the default, matching PLOT_EIGENVALUES.
%
%   m = PLOT_STABILITY_MARGIN(...) returns the vector of those quantities.
%
%   Name-value options
%       'Title'      override the automatic title      ([] auto, '' none)
%       'Subtitle'   override the automatic subtitle   ([] auto, '' none)
%       'Format'     number format for the printed values (default '%+.4f'
%                    for continuous, '%.4f' for discrete)
%
%   WHY THIS EXISTS
%       A full spectrum plot shows every eigenvalue at the same weight, but
%       stability is decided by one of them. When several systems are compared
%       the deciding eigenvalue is usually the hardest to see: on an axis
%       running from -4 to 0, an abscissa of -0.11 and one of exactly 0 are
%       the same pixel, even though the first system converges and the second
%       does not. This plot shows only that number, on a scale where its sign
%       is the most visible thing in the figure, with the stable side shaded.
%
%       Use it BESIDE a spectrum, not instead of one: the spectrum says where
%       the modes are, this says whether the system is stable at all.
%
%   Example
%       A = ring_graph(6) + ring_graph(6)';
%       Ms = {-(laplacian(A) + diag([0 0 1 0 0 0])), -laplacian(A)};
%       plot_stability_margin(Ms, {'anchored','Abelson'}, 'continuous')
%
%   See also PLOT_EIGENVALUES, PLOT_SPECTRUM_FAMILY, SIM_TAYLOR.

    if nargin < 3 || isempty(domain)
        domain = 'discrete';
    end
    domain = validatestring(domain, {'discrete','continuous'}, mfilename, 'domain', 3);

    if ~iscell(Ms)
        error('NDS:plot_stability_margin:notCell', ...
            'Ms must be a cell array of matrices, one per system.');
    end
    s = numel(Ms);

    if nargin < 2 || isempty(labels)
        labels = compose('system %d', (1:s).');
    end
    labels = cellstr(labels);
    if numel(labels) ~= s
        error('NDS:plot_stability_margin:sizeMismatch', ...
            '%d labels for %d systems.', numel(labels), s);
    end

    switch domain
        case 'continuous'
            defaultFormat = '%+.4f';
        case 'discrete'
            defaultFormat = '%.4f';
    end
    opts = name_value(struct('Title', [], 'Subtitle', [], ...
        'Format', defaultFormat), varargin);

    m = zeros(s, 1);
    for k = 1:s
        ev = eig(Ms{k});
        switch domain
            case 'continuous', m(k) = max(real(ev));
            case 'discrete',   m(k) = max(abs(ev));
        end
    end

    switch domain
        case 'continuous'
            boundary = 0;
            stableIs = 'left';
            axisName = 'spectral abscissa   max Re \lambda';
        case 'discrete'
            boundary = 1;
            stableIs = 'left';
            axisName = 'spectral radius   max |\lambda|';
    end

    ax = prepare_axes();
    hold(ax, 'on');

    stable = m < boundary - 1e-12;
    span   = max([abs(m - boundary); eps]);
    lo     = min([m; boundary]) - 0.35*span;
    hi     = max([m; boundary]) + 0.35*span;

    % the stable side, shaded, so that the sign is read from the picture
    fill(ax, [lo boundary boundary lo], [0.3 0.3 s+0.7 s+0.7], ...
        [0.20 0.45 0.75], 'FaceAlpha', 0.07, 'EdgeColor', 'none', ...
        'HandleVisibility', 'off');

    for k = 1:s
        if stable(k), col = [0.20 0.40 0.75]; else, col = [0.85 0.30 0.20]; end
        plot(ax, [boundary m(k)], [k k], '-', 'Color', col, 'LineWidth', 6);
        plot(ax, m(k), k, 'o', 'MarkerSize', 9, 'MarkerFaceColor', col, ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1);
        if m(k) <= boundary
            align = 'right';  off = -0.03*span;
        else
            align = 'left';   off =  0.03*span;
        end
        text(ax, m(k) + off, k, sprintf(opts.Format, m(k)), ...
            'HorizontalAlignment', align, 'FontSize', 10);
    end

    plot(ax, [boundary boundary], [0.3 s+0.7], '-', 'Color', [0.15 0.15 0.15], ...
        'LineWidth', 1.6, 'HandleVisibility', 'off');

    grid(ax, 'on');
    xlim(ax, [lo hi]);
    ylim(ax, [0.3, s+0.7]);
    set(ax, 'YTick', 1:s, 'YTickLabel', labels, 'TickLabelInterpreter', 'none');
    xlabel(ax, axisName);

    autoName = inputname(1);
    if isempty(autoName), autoName = 'stability margin'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
        pick_label(opts.Subtitle, sprintf( ...
            'boundary at %g, stable to the %s: %d of %d system(s) stable', ...
            boundary, stableIs, nnz(stable), s)));
    hold(ax, 'off');

    if nargout == 0, clear m; end
end
