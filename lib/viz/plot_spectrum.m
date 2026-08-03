function h = plot_spectrum(M, varargin)
%PLOT_SPECTRUM Eigenvalues against the relevant stability boundary.
%
%   h = PLOT_SPECTRUM(M) plots the eigenvalues of M in the complex plane
%   together with the stability boundary of the appropriate time domain, and
%   returns the scatter handle.
%
%   Name-value options
%       'Domain'  'discrete'   (default) draws the UNIT CIRCLE
%                 'continuous'           draws the IMAGINARY AXIS
%       'Axes'    axes to draw into
%       'Title'   figure title
%
%   WHICH MATRIX TO PASS
%       discrete   : W (French-DeGroot) or Lambda*W (Friedkin-Johnsen)
%       continuous : -L (Abelson) or -(L + Gamma) (Taylor)
%       In every case, stability means "eigenvalues strictly inside the
%       boundary drawn".
%
%   WHY THIS FIGURE IS WORTH MAKING
%       It renders the convergence theorems visible in one picture.
%         * French-DeGroot always has an eigenvalue pinned at 1 -- marginal
%           stability, the consensus mode.
%         * A PERIODIC graph of period h shows h eigenvalues spread evenly
%           around the unit circle: that is exactly why opinions oscillate.
%         * Friedkin-Johnsen pulls every eigenvalue strictly inside the unit
%           disc. More stability, less agreement.
%         * Abelson always has a single eigenvalue at the origin and the rest
%           strictly in the left half-plane -- no imaginary-axis modes, hence
%           no periodicity obstruction in continuous time.
%
%   See also PLOT_CONVERGENCE, GRAPH_REPORT, FJ_MATRICES.

    validate_square_matrix(M, 'M');

    opts = parse_options(struct( ...
        'Domain', 'discrete', ...
        'Axes',   [], ...
        'Title',  ''), varargin, mfilename);

    domain = validatestring(opts.Domain, {'discrete', 'continuous'}, ...
        mfilename, 'Domain');

    ev = eig(M);
    ax = resolve_axes(opts.Axes);
    hold(ax, 'on');
    grid(ax, 'on');

    switch domain
        case 'discrete'
            theta = linspace(0, 2*pi, 400);
            plot(ax, cos(theta), sin(theta), '-', ...
                'Color', [0.6 0.6 0.6], 'LineWidth', 1, ...
                'DisplayName', 'unit circle');
            boundaryNote = 'stable inside the unit circle';
        case 'continuous'
            yl = max(1, 1.2 * max(abs(imag(ev))));
            plot(ax, [0 0], [-yl yl], '-', ...
                'Color', [0.6 0.6 0.6], 'LineWidth', 1, ...
                'DisplayName', 'imaginary axis');
            boundaryNote = 'stable in the left half-plane';
    end

    h = scatter(ax, real(ev), imag(ev), 46, 'filled', ...
        'MarkerFaceColor', [0.10 0.35 0.75], ...
        'MarkerEdgeColor', 'k', 'DisplayName', 'eigenvalues');

    xlabel(ax, 'Re \lambda');
    ylabel(ax, 'Im \lambda');
    if isempty(opts.Title)
        title(ax, sprintf('Spectrum (%s: %s)', domain, boundaryNote));
    else
        title(ax, char(opts.Title));
    end
    axis(ax, 'equal');
    legend(ax, 'Location', 'best');
    hold(ax, 'off');

    if nargout == 0
        clear h;
    end
end
