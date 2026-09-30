function [A, names] = load_krackhardt()
%LOAD_KRACKHARDT Krackhardt's advice network among 21 managers.
%
%   [A, names] = LOAD_KRACKHARDT() returns the 21-by-21 binary adjacency
%   matrix and the manager labels.
%
%       A(i,j) = 1  means MANAGER i SEEKS ADVICE FROM MANAGER j,
%
%   i.e. i accords weight to j -- already the project convention, so NO
%   TRANSPOSE is needed. Use W = row_stochastic(A) for the influence matrix.
%
%   SOURCE
%       Krackhardt, D. (1987), "Cognitive Social Structures", Social Networks
%       9(2):109-134, Appendix A, p. 129 -- the matrix labelled LAS (Locally
%       Aggregated Structure).
%
%   VALIDATION
%       Cross-checked on every load against the in- and out-degrees published
%       in Table 4 of Sims & Gilles (2014), "Critical Nodes in Directed
%       Networks". All 42 degree constraints must match.
%
%   KNOWN STRUCTURE
%       129 arcs, zero diagonal, no empty rows. Five strong components:
%       {6}, {13}, {16}, {17} and one of 17 nodes, which is the unique CLOSED
%       one and is aperiodic -- so the graph is rooted and French-DeGroot
%       reaches consensus, with W reducible but with a simple dominant
%       eigenvalue 1. Managers 6, 13, 16 and 17 have social power EXACTLY
%       ZERO: nobody seeks their advice.
%
%   NOTE ON AGGREGATION
%       "The Krackhardt advice network" is not a single object. The raw data
%       is a 21x21x21 cognitive social structure -- every manager reported the
%       whole network. LAS keeps only the perceptions of the two people
%       involved in each tie; Appendix A also prints a Consensus structure and
%       three individual slices.
%
%   Example
%       [A, names] = load_krackhardt();
%       W = row_stochastic(A);
%       p = social_power(W);
%
%   See also LOAD_SAMPSON, KRACKHARDT_BENCHMARKS, ROW_STOCHASTIC.

    file = fullfile(project_root(), 'data', 'krackhardt_advice_LAS.txt');
    if ~isfile(file)
        error('NDS:load_krackhardt:missing', 'Data file not found: %s', file);
    end

    A = reshape(sscanf(fileread(file), '%f'), 21, 21).';

    publishedOut = [4 2 9 7 10 1 6 7 9 5 3 1 6 4 9 4 5 12 10 7 8];
    publishedIn  = [12 18 3 6 3 0 11 1 4 8 9 3 0 10 3 0 0 15 2 6 15];
    if ~isequal(sum(A, 2).', publishedOut) || ~isequal(sum(A, 1), publishedIn)
        error('NDS:load_krackhardt:checksum', ...
            'Degrees disagree with Sims & Gilles (2014) Table 4; the file may be corrupted.');
    end

    names = arrayfun(@(k) sprintf('M%d', k), (1:21).', 'UniformOutput', false);
end
