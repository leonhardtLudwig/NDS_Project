function h = plot_spectrum(M, domain, varargin)
%PLOT_SPECTRUM Plot eigenvalues against the relevant stability boundary.
%
%   PLOT_SPECTRUM(M) plots the eigenvalues of M with the UNIT CIRCLE drawn --
%   the boundary for the discrete-time models -- titles the figure with the
%   name of the variable passed in, and reports the spectral radius and the
%   second-largest modulus in the subtitle -- the two numbers that decide
%   whether, and how fast, the model converges.
%
%   PLOT_SPECTRUM(M, 'continuous') draws the IMAGINARY AXIS instead.
%
%   PLOT_SPECTRUM(M, domain, Name, Value, ...) accepts 'Title' and 'Subtitle'.
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
%   WHICH MATRIX TO PASS
%       discrete    W  (French-DeGroot)   or  diag(lambda)*W  (Friedkin-Johnsen)
%       continuous  -laplacian(A)         or  -(L + diag(gamma))  (Taylor)
%
%   WHAT THE FIGURE TELLS YOU BY ITSELF
%       French-DeGroot always has an eigenvalue pinned at 1 -- marginal
%       stability, carrying the consensus mode -- and the subtitle reports
%       the second-largest modulus, which is the convergence rate. A PERIODIC graph of period
%       h shows h eigenvalues spread evenly on the unit circle, and the
%       subtitle says how many lie on it: that count IS the period, and it is
%       exactly why the opinions oscillate. Friedkin-Johnsen pulls every
%       eigenvalue strictly inside: more stability, less agreement.
%
%   Example
%       W = row_stochastic(ring_graph(6));
%       plot_spectrum(W)                      % 6 eigenvalues on the circle
%       plot_spectrum(-laplacian(ring_graph(6)), 'continuous')
%
%   See also PLOT_CONVERGENCE, GRAPH_SUMMARY, TOTAL_INFLUENCE.

    if nargin < 2 || isempty(domain), domain = 'discrete'; end
    opts = name_value(struct('Title', [], 'Subtitle', []), varargin);

    ev = eig(M);
    domain = validatestring(domain, {'discrete', 'continuous'});

    ax = prepare_axes();
    hold(ax, 'on');
    switch domain
        case 'discrete'
            a = linspace(0, 2*pi, 400);
            plot(ax, cos(a), sin(a), '-', 'Color', [.6 .6 .6], ...
                'DisplayName', 'unit circle');
        case 'continuous'
            yl = max(1, 1.2 * max(abs(imag(ev))));
            plot(ax, [0 0], [-yl yl], '-', 'Color', [.6 .6 .6], ...
                'DisplayName', 'imaginary axis');
    end

    h = plot(ax, real(ev), imag(ev), 'o', 'MarkerSize', 8, ...
        'MarkerFaceColor', [0.10 0.35 0.75], 'MarkerEdgeColor', 'k', ...
        'DisplayName', 'eigenvalues');

    grid(ax, 'on');
    axis(ax, 'equal');
    xlabel(ax, 'Re \lambda');
    ylabel(ax, 'Im \lambda');
    legend(ax, 'Location', 'best');

    autoName = inputname(1);
    if isempty(autoName), autoName = 'spectrum'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, spectrum_text(ev, domain)));

    hold(ax, 'off');
    if nargout == 0, clear h; end
end

% -------------------------------------------------------------------------
function s = spectrum_text(ev, domain)
%SPECTRUM_TEXT State the numbers that decide stability.

    switch domain
        case 'discrete'
            modulus = sort(abs(ev), 'descend');
            onCircle = sum(abs(modulus - 1) < 1e-8);
            if numel(modulus) >= 2
                second = modulus(2);
            else
                second = NaN;
            end
            s = {sprintf('spectral radius = %.4g,   2nd largest modulus = %.4g', ...
                    modulus(1), second), ...
                 sprintf('%d eigenvalue(s) on the unit circle', onCircle)};
            if onCircle > 1
                s{2} = [s{2}, sprintf('  ->  PERIODIC (period %d): opinions oscillate', onCircle)];
            end
        case 'continuous'
            re = sort(real(ev));
            atZero = sum(abs(re) < 1e-10);
            positive = re(re > 1e-10);
            if isempty(positive)
                slowest = NaN;
            else
                slowest = min(positive);
            end
            s = {sprintf('max Re = %.4g,   slowest decay = %.4g', max(re), slowest), ...
                 sprintf('%d eigenvalue(s) at the origin', atZero)};
    end
end
