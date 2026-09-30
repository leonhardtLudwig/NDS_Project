function h = plot_convergence(X, t, varargin)
%PLOT_CONVERGENCE Plot the disagreement spread, annotated with its rate.
%
%   PLOT_CONVERGENCE(X) plots max_i x_i - min_i x_i on a log vertical axis,
%   titles the figure with the name of the variable passed in, and states the
%   final spread and the measured decay rate in the subtitle.
%
%   PLOT_CONVERGENCE(X, t) plots against the time vector t. Pass [] to keep
%   the step index.
%
%   PLOT_CONVERGENCE(X, t, Name, Value, ...) accepts
%
%       'Title'    override the automatic title (see below)
%       'Subtitle' override the automatic subtitle (see below)
%       'Rate'   theoretically predicted rate, drawn as a reference slope.
%                For a discrete model pass |lambda_2| or rho(Lambda W); for a
%                continuous model the smallest positive real part of an
%                eigenvalue of L. The figure then shows whether the observed
%                decay matches the predicted one.
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
%   READING THE PLOT
%       A straight line is exponential convergence, and its slope is the
%       spectral quantity governing the rate. A PLATEAU followed by a second
%       decay is a timescale separation -- the signature of weakly coupled
%       communities. A spread that does not decay means the model is not
%       convergent, which is equally informative and is stated in the
%       subtitle.
%
%   Example
%       W = row_stochastic(two_communities(4, 4, 0.02));
%       X = sim_degroot(W, (1:8)', 400);
%       lam = sort(abs(eig(W)), 'descend');
%       plot_convergence(X, [], 'Rate', lam(2))
%
%   See also PLOT_OPINIONS, PLOT_SPECTRUM.

    [~, K] = size(X);
    if nargin < 2, t = []; end

    opts = name_value(struct('Title', [], 'Subtitle', [], 'Rate', []), varargin);

    if isempty(t)
        t = 0:K-1;
        xName = 'step k';
        discrete = true;
    else
        t = t(:).';
        xName = 'time t';
        discrete = false;
    end

    spread = max(X, [], 1) - min(X, [], 1);
    floorValue = eps;

    ax = prepare_axes();
    hold(ax, 'on');
    h = semilogy(ax, t, max(spread, floorValue), '-', 'LineWidth', 1.8, ...
        'DisplayName', 'observed spread');

    if ~isempty(opts.Rate)
        elapsed = t - t(1);
        if discrete
            reference = spread(1) * opts.Rate .^ elapsed;
        else
            reference = spread(1) * exp(-opts.Rate * elapsed);
        end
        semilogy(ax, t, max(reference, floorValue), '--', ...
            'Color', [0.4 0.4 0.4], 'LineWidth', 1.4, ...
            'DisplayName', sprintf('predicted rate %.4g', opts.Rate));
        legend(ax, 'Location', 'best');
    end

    set(ax, 'YScale', 'log');
    grid(ax, 'on');
    xlabel(ax, xName);
    ylabel(ax, 'max_i x_i - min_i x_i');

    autoName = inputname(1);
    if isempty(autoName), autoName = 'convergence'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, rate_text(spread, discrete)));

    hold(ax, 'off');
    if nargout == 0, clear h; end
end

% -------------------------------------------------------------------------
function s = rate_text(spread, discrete)
%RATE_TEXT State the final spread and the empirical decay rate.

    final = spread(end);

    if final > 0.5 * spread(1)
        s = sprintf('final spread = %.3g   |   NOT converging', final);
        return;
    end

    % Estimate the geometric ratio over the last decade of decay.
    usable = find(spread > 1e3 * eps);
    if numel(usable) >= 4
        last = usable(max(1, round(0.6*numel(usable))):end);
        ratio = (spread(last(end)) / spread(last(1))) ^ (1 / (numel(last) - 1));
        if discrete
            s = sprintf('final spread = %.3g   |   measured rate ~ %.4g per step', ...
                final, ratio);
        else
            s = sprintf('final spread = %.3g   |   measured decay ~ %.4g per sample', ...
                final, ratio);
        end
    else
        s = sprintf('final spread = %.3g', final);
    end
end
