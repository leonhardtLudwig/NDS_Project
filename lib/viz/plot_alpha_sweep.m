function [Xinf, alphas, h] = plot_alpha_sweep(W, u, alphas, varargin)
%PLOT_ALPHA_SWEEP Friedkin-Johnsen limits as susceptibility varies.
%
%   [Xinf, alphas, h] = PLOT_ALPHA_SWEEP(W, u, alphas) computes the
%   equilibrium of the Friedkin-Johnsen model with Lambda = alpha*I for every
%   alpha in the given vector, and draws the result as a heatmap of agents
%   against alpha.
%
%   W may be a matrix or a network struct; u is the prejudice vector.
%   alphas defaults to linspace(0, 0.995, 200) when passed as [].
%
%   Outputs
%       Xinf   : n-by-numel(alphas) matrix of limiting opinions
%       alphas : the sweep values actually used
%       h      : the image handle
%
%   Name-value options
%       'Axes'    axes to draw into
%       'Labels'  agent labels for the y axis
%       'Plot'    set false to compute without drawing (default true)
%       'Title'   figure title
%
%   WHAT THE FIGURE SHOWS
%       This is the single most instructive experiment in the project. The
%       family of total-influence matrices
%
%           V_alpha = (1 - alpha) (I - alpha W)^{-1}
%
%       interpolates continuously between the two extremes:
%           alpha -> 0   V -> I        every agent frozen at its prejudice
%           alpha -> 1   V -> 1 p'     consensus (French's social power)
%
%       So one picture contains the whole story of stubbornness: as agents
%       become more susceptible, the persistent disagreement of the
%       Friedkin-Johnsen model collapses continuously into the consensus of
%       French-DeGroot. The rate at which the curves merge is a quantitative
%       measure of how strongly the network resists cleavage.
%
%   NUMERICAL NOTE
%       (I - alpha W) becomes ill-conditioned as alpha approaches 1, so the
%       default sweep stops at 0.995. Values extremely close to 1 are
%       physically meaningless anyway: they describe agents with no
%       attachment to their prejudice at all, which is exactly the
%       French-DeGroot model.
%
%   See also FJ_MATRICES, SIM_FRIEDKIN_JOHNSEN, SOCIAL_POWER.

    narginchk(2, Inf);

    W = network_matrix(W, 'W');
    n = validate_row_stochastic(W, 'W');
    uVec = prepare_state(u, n, 'u');
    uVec = uVec(:, 1);

    if nargin < 3 || isempty(alphas)
        alphas = linspace(0, 0.995, 200);
    end
    validateattributes(alphas, {'numeric'}, ...
        {'vector', 'real', 'finite', '>=', 0, '<=', 1}, mfilename, 'alphas', 3);
    alphas = double(alphas(:).');

    opts = parse_options(struct( ...
        'Axes',   [], ...
        'Labels', [], ...
        'Plot',   true, ...
        'Title',  ''), varargin, mfilename);

    Xinf = NaN(n, numel(alphas));
    I = eye(n);
    for k = 1:numel(alphas)
        a = alphas(k);
        if a >= 1
            % Lambda = I is the French-DeGroot limit, not an FJ equilibrium.
            try
                Xinf(:, k) = predict_limit_degroot(W, uVec);
            catch
                Xinf(:, k) = NaN;
            end
        else
            Xinf(:, k) = (I - a * W) \ ((1 - a) * uVec);
        end
    end

    h = gobjects(0);
    if ~opts.Plot
        return;
    end

    if isempty(opts.Labels)
        labels = arrayfun(@(k) sprintf('%d', k), (1:n).', 'UniformOutput', false);
    else
        labels = cellstr(opts.Labels);
        labels = labels(:);
    end

    ax = resolve_axes(opts.Axes);
    h = imagesc(ax, alphas, 1:n, Xinf);
    set(ax, 'YDir', 'normal', 'YTick', 1:n, 'YTickLabel', labels, ...
        'TickLabelInterpreter', 'none');
    colormap(ax, parula);
    colorbar(ax);
    xlabel(ax, '\alpha   (susceptibility, \Lambda = \alpha I)');
    ylabel(ax, 'agent');
    if isempty(opts.Title)
        title(ax, ['Friedkin-Johnsen limit vs susceptibility:  ' ...
                   'frozen (\alpha \rightarrow 0) to consensus (\alpha \rightarrow 1)']);
    else
        title(ax, char(opts.Title));
    end

    if nargout == 0
        clear Xinf alphas h;
    end
end
