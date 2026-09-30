function s = matrix_report(A, name)
%MATRIX_REPORT Print the structural facts of a network matrix.
%
%   MATRIX_REPORT(A) prints, in a fixed layout, the quantities needed to read
%   a weight matrix: its size, the out- and in-degrees, whether it is
%   row-stochastic and whether it is weight-balanced, and the structure that
%   decides the asymptotic behaviour (strong components, closed components,
%   periods, rootedness).
%
%   MATRIX_REPORT(A, name) labels the report with a name.
%
%   s = MATRIX_REPORT(...) also returns the GRAPH_SUMMARY structure, so the
%   caller can branch on s.consensus, s.rooted and the rest without repeating
%   the analysis.
%
%   Every example in every chapter prints this same block, so two topologies
%   can be compared line by line. Pass whichever matrix the model actually
%   uses: the raw weights A for the continuous-time models, the row-stochastic
%   W for the discrete-time ones. Row-stochasticity is reported as a fact
%   rather than required, so the raw matrix is equally welcome.
%
%   THE THREE LINES THAT MATTER
%       row-stochastic     the discrete-time models need it; a zero
%                          out-degree is what makes it impossible
%       weight-balanced    d_out = d_in for every node; it is what makes the
%                          consensus value the plain average
%       closed / periods   convergence holds iff every closed component is
%                          aperiodic
%       rooted             consensus needs exactly one closed component
%
%   Example
%       W = row_stochastic(common_topology('two-blocks'));
%       s = matrix_report(W, 'W');
%
%   See also GRAPH_SUMMARY, IS_ROW_STOCHASTIC, COMMON_TOPOLOGY.

    if nargin < 2 || isempty(name)
        name = inputname(1);
        if isempty(name), name = 'matrix'; end
    end

    n = check_square(A, 'A');
    s = graph_summary(A);

    dout = sum(A, 2).';
    din  = sum(A, 1);
    closed = numel(s.closed);

    fprintf('%s   (%d agents)\n', name, n);
    fprintf('  out-degrees (row sums): %s   row-stochastic : %s\n', ...
        mat2str(round(dout, 4)), yesno(is_row_stochastic(A)));
    fprintf('  in-degrees  (col sums): %s   weight-balanced: %s\n', ...
        mat2str(round(din, 4)), yesno(max(abs(dout - din)) < 1e-12));
    fprintf('  strong components  : %d   closed: %d   periods: %s\n', ...
        numel(s.components), closed, mat2str(s.periods.'));
    fprintf('  rooted: %-4s  convergent: %-4s  consensus: %s\n', ...
        yesno(s.rooted), yesno(s.convergent), yesno(s.consensus));

    if any(dout == 0)
        fprintf('  NOTE: agents %s have out-degree 0, so D_out is singular and\n', ...
            mat2str(find(dout == 0)));
        fprintf('        W = D_out^{-1} A does not exist. Use P = I - eps*L.\n');
    end

    if nargout == 0
        clear s;
    end
end

% -------------------------------------------------------------------------
function t = yesno(tf)
    if tf, t = 'yes'; else, t = 'no'; end
end
