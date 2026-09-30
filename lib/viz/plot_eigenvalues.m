function T = plot_eigenvalues(M, domain, varargin)
%PLOT_EIGENVALUES Spectrum plot in which repeated eigenvalues stay visible.
%
%   PLOT_EIGENVALUES(M) plots the eigenvalues of M against the unit circle,
%   the stability boundary of the discrete-time models.
%
%   PLOT_EIGENVALUES(M, 'continuous') draws the imaginary axis instead.
%
%   T = PLOT_EIGENVALUES(...) also returns a table with one row per DISTINCT
%   eigenvalue: its value, real and imaginary parts, modulus and algebraic
%   multiplicity. The table can be displayed on its own, so the multiplicities
%   are available as numbers and not only as a picture.
%
%   Name-value options
%       'Title'      override the automatic title      ([] auto, '' none)
%       'Subtitle'   override the automatic subtitle   ([] auto, '' none)
%       'Tolerance'  clustering tolerance; eigenvalues closer than this are
%                    treated as one. Default 1e-8 * max(1, rho(M)), which
%                    scales with the matrix instead of assuming O(1) entries.
%       'Abscissa'   continuous view only: mark the SPECTRAL ABSCISSA, the
%                    rightmost real part max Re(lambda), with a vertical line
%                    and state its distance from the imaginary axis. That
%                    distance is the stability margin: transients decay like
%                    exp(-margin * t), and the flow is asymptotically stable
%                    exactly when the line lies strictly left of the axis.
%                    Default false.
%       'Plot'       false returns the table without drawing anything, so the
%                    multiplicities can be collected in a loop without
%                    leaving a trail of figures. Default true.
%
%   WHY THIS EXISTS
%       A plain scatter of EIG(M) draws repeated eigenvalues on top of each
%       other, so a semisimple eigenvalue of multiplicity 4 is indistinguish-
%       able from a simple one. That hides exactly what decides the behaviour:
%       whether the eigenvalue 1 is simple (consensus) or repeated
%       (disagreement, one value per closed component).
%
%       Here numerically coincident eigenvalues are clustered, the marker area
%       grows with the multiplicity, and any cluster of multiplicity greater
%       than one is annotated "xk". A glance is enough to see that more than
%       one eigenvalue sits at that point.
%
%   Example
%       W = row_stochastic(common_topology('two-blocks'));
%       T = plot_eigenvalues(W)        % shows 1 with multiplicity 2
%
%   See also PLOT_SPECTRUM, GRAPH_SUMMARY, EIG.

    if nargin < 2 || isempty(domain)
        domain = 'discrete';
    end
    domain = validatestring(domain, {'discrete','continuous'}, mfilename, 'domain', 2);

    opts = name_value(struct('Title', [], 'Subtitle', [], 'Tolerance', [], ...
        'Abscissa', false, 'Plot', true), varargin);

    ev  = eig(M);
    rho = max(abs(ev));
    if isempty(opts.Tolerance)
        tol = 1e-8 * max(1, rho);
    else
        tol = opts.Tolerance;
    end

    [value, multiplicity] = cluster_eigenvalues(ev, tol);

    T = table(value, real(value), imag(value), abs(value), multiplicity, ...
        'VariableNames', {'lambda','Re','Im','modulus','multiplicity'});

    if ~opts.Plot                       % table only: no stray figure in a loop
        return;
    end

    % --- draw -----------------------------------------------------------
    ax = prepare_axes();
    hold(ax, 'on');

    switch domain
        case 'discrete'
            a = linspace(0, 2*pi, 400);
            fill(ax, cos(a), sin(a), [0.2 0.4 0.8], 'FaceAlpha', 0.05, ...
                'EdgeColor', [.45 .45 .45], 'LineStyle', '--', 'LineWidth', 1);
        case 'continuous'
            yl = max(1, 1.25 * max(abs(imag(ev))));
            plot(ax, [0 0], [-yl yl], '--', 'Color', [.45 .45 .45], 'LineWidth', 1);
    end

    % Marker area grows with multiplicity, so a repeated eigenvalue is bigger
    % as well as labelled: two independent cues for the same fact.
    area = 60 + 55 * (multiplicity - 1);
    scatter(ax, real(value), imag(value), area, ...
        'MarkerFaceColor', [0.85 0.20 0.15], 'MarkerEdgeColor', 'k', ...
        'MarkerFaceAlpha', 0.75, 'LineWidth', 1);

    span = max(1, max(abs(ev)));
    for k = 1:numel(value)
        if multiplicity(k) > 1
            text(ax, real(value(k)) + 0.075*span, imag(value(k)) + 0.075*span, ...
                sprintf('x%d', multiplicity(k)), ...
                'FontWeight', 'bold', 'FontSize', 10, 'Color', [0.60 0.10 0.05]);
        end
    end

    if opts.Abscissa && strcmp(domain, 'continuous')
        a = max(real(ev));
        if abs(a) <= 1e-9 * max(1, rho)
            a = 0;                      % on the axis: report it as such, not as 1e-16
        end
        yl = max(1, 1.25 * max(abs(imag(ev))));
        plot(ax, [a a], [-yl yl], ':', 'Color', [0.85 0.20 0.15], 'LineWidth', 2);
        if a < 0
            note = sprintf('abscissa %.4g,  margin %.4g', a, -a);
        else
            note = sprintf('abscissa %.4g,  no margin', a);
        end
        % anchored to the LEFT of the data, so a long note cannot run off the
        % right-hand edge next to the imaginary axis
        text(ax, min(real(ev)), yl, note, 'Color', [0.60 0.10 0.05], ...
            'FontWeight', 'bold', 'FontSize', 9, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    end

    grid(ax, 'on');
    axis(ax, 'equal');

    % In the continuous view the stability boundary is the imaginary axis and
    % the eigenvalue 0 sits ON it, at the right-hand edge of the data. Its
    % multiplicity label would then be drawn outside the axes. The discrete
    % view needs no such padding: the unit circle already provides it.
    if strcmp(domain, 'continuous') && any(multiplicity > 1)
        xl = xlim(ax);
        xlim(ax, [xl(1) - 0.05*span, xl(2) + 0.18*span]);
    end

    xlabel(ax, 'Real');
    ylabel(ax, 'Im');

    autoName = inputname(1);
    if isempty(autoName), autoName = 'spectrum'; end
    figure_title(ax, pick_label(opts.Title, autoName), ...
                     pick_label(opts.Subtitle, caption(value, multiplicity, domain, rho, tol)));
    hold(ax, 'off');

    if nargout == 0
        clear T;
    end
end

% -------------------------------------------------------------------------
function [value, multiplicity] = cluster_eigenvalues(ev, tol)
%CLUSTER_EIGENVALUES Merge eigenvalues that coincide to within tol.
%
%   Each cluster is represented by the mean of its members, which is the
%   numerically sensible representative: EIG returns a repeated eigenvalue as
%   a tight cloud rather than as identical values.

    ev = ev(:);
    assigned = false(numel(ev), 1);
    value = zeros(0,1);
    multiplicity = zeros(0,1);

    while ~all(assigned)
        seed = find(~assigned, 1);
        near = ~assigned & abs(ev - ev(seed)) <= tol;
        value(end+1,1) = mean(ev(near));            %#ok<AGROW>
        multiplicity(end+1,1) = nnz(near);          %#ok<AGROW>
        assigned = assigned | near;
    end

    [~, order] = sortrows([-abs(value), -real(value), -imag(value)]);
    value = value(order);
    multiplicity = multiplicity(order);
end

% -------------------------------------------------------------------------
function s = caption(value, multiplicity, domain, rho, tol)
%CAPTION State the numbers that decide the behaviour.

    repeated = nnz(multiplicity > 1);
    switch domain
        case 'discrete'
            onCircle = sum(multiplicity(abs(abs(value) - 1) <= 1e-8 * max(1, rho)));
            first = sprintf('rho = %.4g,   %d distinct eigenvalue(s),   %d on the unit circle', ...
                rho, numel(value), onCircle);
        case 'continuous'
            atZero = sum(multiplicity(abs(real(value)) <= 1e-8 * max(1, rho)));
            first = sprintf('max Re = %.4g,   %d distinct eigenvalue(s),   %d on the imaginary axis', ...
                max(real(value)), numel(value), atZero);
    end

    if repeated == 0
        second = sprintf('all simple   (clustering tolerance %.1e)', tol);
    else
        second = sprintf('%d repeated, marked xk   (clustering tolerance %.1e)', repeated, tol);
    end
    s = {first, second};
end
