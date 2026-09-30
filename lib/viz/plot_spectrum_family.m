function T = plot_spectrum_family(Ms, values, domain, varargin)
%PLOT_SPECTRUM_FAMILY Spectra of a one-parameter family of matrices, on one plot.
%
%   PLOT_SPECTRUM_FAMILY(Ms, values) overlays the spectra of the matrices in
%   the cell array Ms on a single unit-circle plot, colouring each spectrum
%   according to the matching entry of values. It answers the question a
%   sequence of separate spectrum plots answers badly: WHERE DO THE
%   EIGENVALUES GO as the parameter is turned.
%
%   PLOT_SPECTRUM_FAMILY(Ms, values, 'continuous') draws the imaginary axis
%   instead of the unit circle.
%
%   T = PLOT_SPECTRUM_FAMILY(...) also returns one stacked table with a row
%   per distinct eigenvalue of every member:
%
%       value | lambda | Re | Im | modulus | multiplicity
%
%   Name-value options
%       'Title'      override the automatic title      ([] auto, '' none)
%       'Subtitle'   override the automatic subtitle   ([] auto, '' none)
%       'Label'      name of the parameter, used for the legend entries and
%                    the colourbar (default 'parameter')
%       'Tolerance'  clustering tolerance, passed straight to PLOT_EIGENVALUES
%       'Key'        'auto' (default) | 'legend' | 'colorbar'. 'auto' uses a
%                    legend for at most 8 members, where naming each one is
%                    readable, and a colourbar beyond that. Ignored by the
%                    real view, where the vertical axis already names them.
%       'Rows'       'value' (default) | 'index'. Real view only: whether a
%                    member's row sits at its parameter value or at its
%                    position in the list. Use 'index' for a geometric sweep
%                    such as alpha = 0, 0.1, 1, 10, where placing rows at the
%                    values crushes the small ones together and the members
%                    being compared overlap.
%       'View'       'auto' (default) | 'complex' | 'real'
%                    'complex' plots the spectra in the complex plane, one
%                    colour per member. 'real' gives each member its own row
%                    and plots the eigenvalues along the horizontal axis.
%                    'auto' picks 'real' when every eigenvalue of every member
%                    is real, and 'complex' otherwise.
%
%   WHY THE REAL VIEW EXISTS
%       A reversible or symmetric chain has a REAL spectrum. Drawn in the
%       complex plane every one of its eigenvalues lands on the line Im = 0,
%       so the whole vertical dimension is empty and the members of the family
%       are stacked on top of each other on a single line. Giving each member
%       its own row uses that dimension to separate them, and the progression
%       becomes readable row by row.
%
%   MULTIPLICITIES ARE NOT LOST
%       Each member is clustered by PLOT_EIGENVALUES itself, called with
%       'Plot', false, so the multiplicity of every eigenvalue is computed by
%       exactly the same rule as in the single-matrix plot. As there, the
%       marker area grows with the multiplicity and any repeated eigenvalue is
%       annotated "xk".
%
%   Example
%       N  = 6;
%       Ms = arrayfun(@(m) row_stochastic(ring_graph(N) + ...
%                diag([ones(m,1); zeros(N-m,1)])), 0:6, 'UniformOutput', false);
%       plot_spectrum_family(Ms, 0:6, 'Label', 'self-loops')
%
%   See also PLOT_EIGENVALUES, PLOT_SPECTRUM.

    if nargin < 3 || isempty(domain)
        domain = 'discrete';
    end
    domain = validatestring(domain, {'discrete','continuous'}, mfilename, 'domain', 3);

    if ~iscell(Ms)
        error('NDS:plot_spectrum_family:notCell', ...
            'Ms must be a cell array of matrices, one per parameter value.');
    end
    values = values(:);
    if numel(values) ~= numel(Ms)
        error('NDS:plot_spectrum_family:sizeMismatch', ...
            'values has %d entries but Ms has %d matrices.', numel(values), numel(Ms));
    end

    opts = name_value(struct( ...
        'Title',     [], ...
        'Subtitle',  [], ...
        'Label',     'parameter', ...
        'Tolerance', [], ...
        'Key',       'auto', ...
        'Rows',      'value', ...
        'View',      'auto'), varargin);

    s = numel(Ms);

    % --- one clustered table per member, by the single-matrix rule --------
    parts = cell(s, 1);
    for k = 1:s
        Tk = plot_eigenvalues(Ms{k}, domain, 'Plot', false, 'Tolerance', opts.Tolerance);
        parts{k} = addvars(Tk, repmat(values(k), height(Tk), 1), ...
            'Before', 1, 'NewVariableNames', 'value');
    end
    T = vertcat(parts{:});

    % --- draw ------------------------------------------------------------
    view = validatestring(opts.View, {'auto','complex','real'});
    if strcmp(view, 'auto')
        if max(abs(imag(T.lambda))) <= 1e-12
            view = 'real';
        else
            view = 'complex';
        end
    end

    ax = prepare_axes();
    hold(ax, 'on');

    if strcmp(view, 'real')
        rows = validatestring(opts.Rows, {'value','index'});
        if strcmp(rows, 'index')
            draw_real(ax, parts, (1:s).', domain, opts, values);
        else
            draw_real(ax, parts, values, domain, opts, values);
        end
        finish(ax, opts, T, values, domain, inputname(1));
        if nargout == 0, clear T; end
        return;
    end

    allEigenvalues = T.lambda;
    switch domain
        case 'discrete'
            a = linspace(0, 2*pi, 400);
            plot(ax, cos(a), sin(a), '--', 'Color', [.45 .45 .45], ...
                'LineWidth', 1, 'HandleVisibility', 'off');
        case 'continuous'
            yl = max(1, 1.25 * max(abs(imag(allEigenvalues))));
            plot(ax, [0 0], [-yl yl], '--', 'Color', [.45 .45 .45], ...
                'LineWidth', 1, 'HandleVisibility', 'off');
    end

    rgb = ramp(s);
    span = max(1, max(abs(allEigenvalues)));

    for k = 1:s
        Tk = parts{k};
        scatter(ax, Tk.Re, Tk.Im, 45 + 45 * (Tk.multiplicity - 1), ...
            'MarkerFaceColor', rgb(k,:), 'MarkerEdgeColor', 'k', ...
            'MarkerFaceAlpha', 0.85, 'LineWidth', 0.5, ...
            'DisplayName', sprintf('%s = %g', opts.Label, values(k)));

        repeated = find(Tk.multiplicity > 1).';
        for j = repeated
            text(ax, Tk.Re(j) + 0.06*span, Tk.Im(j) + 0.06*span, ...
                sprintf('x%d', Tk.multiplicity(j)), ...
                'FontWeight', 'bold', 'FontSize', 9, 'Color', rgb(k,:));
        end
    end

    grid(ax, 'on');
    axis(ax, 'equal');
    xlabel(ax, 'Real');
    ylabel(ax, 'Im');

    switch resolve_key(opts.Key, s)
        case 'legend'
            legend(ax, 'Location', 'eastoutside', 'Interpreter', 'none');
        case 'colorbar'
            colormap(ax, rgb);
            % Pad by half the SPACING between values, not by a fixed 0.5. For
            % an integer sweep the two agree; for a fractional one such as
            % lambda = 0 ... 1 the fixed pad would label the bar -0.5 to 1.5.
            if numel(values) > 1
                pad = (max(values) - min(values)) / (2 * (numel(values) - 1));
            else
                pad = 0.5;
            end
            clim(ax, [min(values) - pad, max(values) + pad]);
            c = colorbar(ax);
            c.Label.String = opts.Label;
    end

    finish(ax, opts, T, values, domain, inputname(1));

    if nargout == 0
        clear T;
    end
end

% -------------------------------------------------------------------------
function draw_real(ax, parts, values, domain, opts, tickLabels)
%DRAW_REAL One row per member, eigenvalues along the horizontal axis.
%
%   values gives the vertical position of each row and tickLabels the text
%   printed against it; they differ when 'Rows' is 'index'.

    s = numel(parts);
    rgb = ramp(s);
    pad = 0.6;
    yl = [min(values) - pad*range_or_one(values), max(values) + pad*range_or_one(values)];

    switch domain
        case 'discrete'
            for b = [-1 1]
                plot(ax, [b b], yl, '--', 'Color', [.45 .45 .45], ...
                    'LineWidth', 1, 'HandleVisibility', 'off');
            end
        case 'continuous'
            plot(ax, [0 0], yl, '--', 'Color', [.45 .45 .45], ...
                'LineWidth', 1, 'HandleVisibility', 'off');
    end

    step = range_or_one(values);
    for k = 1:s
        Tk = parts{k};
        y = values(k) * ones(height(Tk), 1);
        scatter(ax, Tk.Re, y, 50 + 50 * (Tk.multiplicity - 1), ...
            'MarkerFaceColor', rgb(k,:), 'MarkerEdgeColor', 'k', ...
            'MarkerFaceAlpha', 0.9, 'LineWidth', 0.5, 'HandleVisibility', 'off');

        for j = find(Tk.multiplicity > 1).'
            text(ax, Tk.Re(j), values(k) + 0.22*step, sprintf('x%d', Tk.multiplicity(j)), ...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
                'FontSize', 9, 'Color', rgb(k,:));
        end
    end

    grid(ax, 'on');
    ylim(ax, yl);

    % Keep the stability markers off the very edge, or the reference line at
    % -1 is drawn under the axis box and cannot be seen.
    edges = [cellfun(@(t) min(t.Re), parts).', cellfun(@(t) max(t.Re), parts).'];
    switch domain
        case 'discrete',   edges = [edges, -1, 1];
        case 'continuous', edges = [edges, 0];
    end
    xlim(ax, [min(edges) - 0.08, max(edges) + 0.08]);

    set(ax, 'YTick', values, 'YTickLabel', compose('%g', tickLabels));
    xlabel(ax, '\lambda   (the spectrum is real)');
    ylabel(ax, opts.Label);
end

% -------------------------------------------------------------------------
function r = range_or_one(values)
    r = max(values) - min(values);
    if r <= 0, r = 1; else, r = r / max(1, numel(values) - 1); end
end

% -------------------------------------------------------------------------
function finish(ax, opts, T, values, domain, autoName)
    if isempty(autoName), autoName = 'spectrum family'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, caption(T, values, domain, opts.Label)));
    hold(ax, 'off');
end

% -------------------------------------------------------------------------
function rgb = ramp(s)
%RAMP Sequential blue-to-red colours, matching the palette used elsewhere.

    cold = [0.10 0.25 0.60];
    warm = [0.85 0.20 0.15];
    if s == 1
        rgb = cold;
        return;
    end
    t = linspace(0, 1, s).';
    rgb = (1 - t) * cold + t * warm;
end

% -------------------------------------------------------------------------
function key = resolve_key(setting, s)
    key = validatestring(setting, {'auto','legend','colorbar'});
    if strcmp(key, 'auto')
        if s <= 8
            key = 'legend';
        else
            key = 'colorbar';
        end
    end
end

% -------------------------------------------------------------------------
function txt = caption(T, values, domain, label)
%CAPTION What changes across the family, in numbers.

    switch domain
        case 'discrete'
            onCircle = arrayfun(@(v) ...
                sum(T.multiplicity(T.value == v & abs(T.modulus - 1) < 1e-8)), values);
            first = sprintf('%d matrices, %s from %g to %g', ...
                numel(values), label, values(1), values(end));
            second = sprintf('eigenvalues on the unit circle: %s', mat2str(onCircle.'));
        case 'continuous'
            atAxis = arrayfun(@(v) ...
                sum(T.multiplicity(T.value == v & abs(T.Re) < 1e-8)), values);
            first = sprintf('%d matrices, %s from %g to %g', ...
                numel(values), label, values(1), values(end));
            second = sprintf('eigenvalues on the imaginary axis: %s', mat2str(atAxis.'));
    end
    txt = {first, second};
end
