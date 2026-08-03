function h = plot_convergence(res, varargin)
%PLOT_CONVERGENCE Diagnostics showing how fast the opinions settle.
%
%   h = PLOT_CONVERGENCE(res) draws, on a logarithmic vertical axis, the
%   disagreement spread max(x) - min(x) and, when a predicted limit is
%   available, the distance ||x(t) - x(inf)||_inf. Returns the line handles.
%
%   Name-value options
%       'Axes'     axes to draw into
%       'Rate'     predicted asymptotic decay rate, drawn as a reference
%                  slope. For a discrete model pass |lambda_2| or rho(Lambda*W);
%                  for a continuous model pass the smallest positive real part
%                  of an eigenvalue.
%       'Dimension' opinion dimension to use when d > 1 (default 1)
%       'Title'    figure title
%
%   READING THE PLOT
%       A straight line on the log axis is exponential convergence, and its
%       slope is the spectral quantity governing the rate. A PLATEAU followed
%       by a second decay indicates a timescale separation -- the signature of
%       weakly coupled communities, where opinions agree quickly inside each
%       block and only slowly between blocks.
%
%       For a non-convergent (periodic) model the spread does not decay at
%       all, which is equally informative.
%
%   See also PLOT_OPINIONS, PLOT_SPECTRUM.

    if ~isstruct(res) || ~all(isfield(res, {'X', 't', 'n', 'd', 'xinf'}))
        error('NDS:plotConvergence:badResult', ...
            'Input must be a result structure returned by one of the SIM_* functions.');
    end

    opts = parse_options(struct( ...
        'Axes',      [], ...
        'Rate',      [], ...
        'Dimension', 1, ...
        'Title',     ''), varargin, mfilename);

    if res.d == 1
        X = res.X;
        xinf = res.xinf(:, 1);
    else
        X = reshape(res.X(:, opts.Dimension, :), res.n, []);
        xinf = res.xinf(:, opts.Dimension);
    end
    t = res.t;

    spread = max(X, [], 1) - min(X, [], 1);
    floorValue = eps;              % keep zeros plottable on a log axis

    ax = resolve_axes(opts.Axes);
    hold(ax, 'on');
    grid(ax, 'on');

    handles = gobjects(0, 1);
    handles(end+1, 1) = semilogy(ax, t, max(spread, floorValue), '-', ...
        'LineWidth', 1.6, 'DisplayName', 'spread  max(x) - min(x)');

    if all(isfinite(xinf))
        err = max(abs(X - xinf), [], 1);
        handles(end+1, 1) = semilogy(ax, t, max(err, floorValue), '--', ...
            'LineWidth', 1.6, 'DisplayName', '||x(t) - x(\infty)||_\infty');
    end

    if ~isempty(opts.Rate)
        validateattributes(opts.Rate, {'numeric'}, ...
            {'scalar', 'real', 'positive', 'finite'}, mfilename, 'Rate');
        reference = build_reference(res.model, t, opts.Rate, spread);
        handles(end+1, 1) = semilogy(ax, t, max(reference, floorValue), ':', ...
            'Color', [0.4 0.4 0.4], 'LineWidth', 1.4, ...
            'DisplayName', 'predicted rate');
    end

    set(ax, 'YScale', 'log');
    if any(strcmp(res.model, {'degroot', 'fj'}))
        xlabel(ax, 'step k');
    else
        xlabel(ax, 'time t');
    end
    ylabel(ax, 'disagreement');
    if isempty(opts.Title)
        title(ax, 'Convergence diagnostics');
    else
        title(ax, char(opts.Title));
    end
    legend(ax, handles, 'Location', 'best');
    hold(ax, 'off');

    h = handles;
    if nargout == 0
        clear h;
    end
end

% -------------------------------------------------------------------------
function reference = build_reference(model, t, rate, spread)
%BUILD_REFERENCE Reference decay curve anchored at the initial disagreement.

    anchor = max(spread(1), eps);
    elapsed = t - t(1);
    if any(strcmp(model, {'degroot', 'fj'}))
        reference = anchor * rate .^ elapsed;      % discrete: rate^k
    else
        reference = anchor * exp(-rate * elapsed); % continuous: exp(-rate*t)
    end
end
