function T = stability_summary(Ms, labels, domain)
%STABILITY_SUMMARY Compact table of the stability of several systems.
%
%   T = STABILITY_SUMMARY(Ms, labels) returns a table with one row per matrix
%   in the cell array Ms and the columns
%
%       system    abscissa   margin   asymptotically_stable      ('continuous')
%       system    radius     margin   asymptotically_stable      ('discrete')
%
%   STABILITY_SUMMARY(Ms, labels, domain) chooses the reading; 'discrete' is
%   the default, matching PLOT_EIGENVALUES.
%
%       'continuous'   abscissa = max Re(lambda), the RIGHTMOST real part.
%                      The flow is asymptotically stable iff it is negative,
%                      and margin = -abscissa is the distance from the
%                      imaginary axis, which is the decay rate of the slowest
%                      mode: transients die like exp(-margin * t).
%
%       'discrete'     radius = max |lambda|. The iteration is asymptotically
%                      stable iff it is below 1, and margin = 1 - radius.
%
%   WHY A TABLE AND NOT A PLOT
%       These are two or three scalars per system. A plot of a handful of
%       scalars spends a whole figure on numbers the reader then has to read
%       off an axis; the table states them, and puts the verdict beside them.
%       Keep the figures for quantities that vary with a parameter.
%
%   Values within a rounding tolerance of the stability boundary are snapped
%   to it, so a marginally stable system reports exactly 0 rather than 3e-17,
%   which would otherwise read as a genuine (and wrongly signed) margin.
%
%   Example
%       A  = ring_graph(6) + ring_graph(6)';
%       Ms = {-(laplacian(A) + diag([1 0 0 0 0 0])), -laplacian(A)};
%       stability_summary(Ms, {'anchored','Abelson'}, 'continuous')
%
%   See also PLOT_EIGENVALUES, PLOT_SPECTRUM_FAMILY, SIM_TAYLOR.

    if nargin < 3 || isempty(domain)
        domain = 'discrete';
    end
    domain = validatestring(domain, {'discrete','continuous'}, mfilename, 'domain', 3);

    if ~iscell(Ms)
        error('NDS:stability_summary:notCell', ...
            'Ms must be a cell array of matrices, one per system.');
    end
    s = numel(Ms);

    if nargin < 2 || isempty(labels)
        labels = compose('system %d', (1:s).');
    end
    labels = cellstr(labels);
    if numel(labels) ~= s
        error('NDS:stability_summary:sizeMismatch', ...
            '%d labels for %d systems.', numel(labels), s);
    end

    switch domain
        case 'continuous', boundary = 0; name = 'abscissa';
        case 'discrete',   boundary = 1; name = 'radius';
    end

    value = zeros(s, 1);
    for k = 1:s
        ev = eig(Ms{k});
        switch domain
            case 'continuous', value(k) = max(real(ev));
            case 'discrete',   value(k) = max(abs(ev));
        end
        tol = 1e-9 * max(1, norm(Ms{k}, Inf));
        if abs(value(k) - boundary) <= tol
            value(k) = boundary;                 % exactly on the boundary
        end
    end

    margin = boundary - value;
    T = table(string(labels(:)), value, margin, margin > 0, ...
        'VariableNames', {'system', name, 'margin', 'asymptotically_stable'});
end
