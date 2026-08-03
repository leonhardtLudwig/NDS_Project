function net = load_krackhardt(varargin)
%LOAD_KRACKHARDT Krackhardt's advice network among 21 managers.
%
%   net = LOAD_KRACKHARDT() reads the Locally Aggregated Structure (LAS)
%   matrix recovered from Krackhardt (1987), "Cognitive Social Structures",
%   Social Networks 9(2):109-134, Appendix A, p. 129.
%
%   Name-value options
%       'File'      path to the data file (default data/krackhardt_advice_LAS.txt)
%       'Validate'  check the degree sequence against the published values
%                   (default true); set false only if you deliberately
%                   supply a different aggregation
%
%   DIRECTION
%       M(i,j) = 1 means MANAGER i SEEKS ADVICE FROM MANAGER j, i.e. agent i
%       accords weight to agent j. This already matches the project
%       convention, so NO TRANSPOSE is applied.
%
%   VALIDATION
%       The transcription is cross-checked against Table 4 of Sims & Gilles
%       (2014), "Critical Nodes in Directed Networks", which reports the
%       in- and out-degree of every manager for this exact matrix. All 42
%       degree constraints must match, or the load fails.
%
%   KNOWN STRUCTURE (verified, see docs/02_literature_review.md)
%       * 129 arcs, zero diagonal, no empty rows (so row-normalisation is
%         clean and creates no artificial stubborn agents)
%       * 5 strong components: {6}, {13}, {16}, {17} and one giant component
%         of 17 nodes
%       * exactly one CLOSED strong component, which is APERIODIC, so the
%         graph is rooted and French-DeGroot reaches consensus
%       * W is reducible but has a simple, strictly dominant eigenvalue 1
%       * managers 6, 13, 16 and 17 have social power EXACTLY ZERO -- nobody
%         seeks their advice, so their initial opinions are forgotten
%
%   NOTE ON AGGREGATION
%       "The Krackhardt advice network" is not a single object. The raw data
%       is a 21x21x21 cognitive social structure (every manager reported the
%       whole network). The LAS reduction keeps only the perceptions of the
%       two people involved in each tie; Appendix A also prints a Consensus
%       structure and three individual slices. This choice is recorded in
%       net.meta.aggregation.
%
%   See also NET_FROM_MATRIX, SOCIAL_POWER, LOAD_SAMPSON.

    opts = parse_options(struct( ...
        'File',     '', ...
        'Validate', true), varargin, mfilename);

    if isempty(opts.File)
        file = fullfile(project_root(), 'data', 'krackhardt_advice_LAS.txt');
    else
        file = char(opts.File);
    end

    if ~isfile(file)
        error('NDS:loadKrackhardt:fileNotFound', ...
            ['Krackhardt data file not found:\n  %s\n' ...
             'It should have been created during the literature phase; see data/README.md.'], ...
            file);
    end

    raw = fileread(file);
    values = sscanf(raw, '%f');

    n = 21;
    if numel(values) ~= n * n
        error('NDS:loadKrackhardt:badSize', ...
            'Expected %d numeric entries in %s, found %d.', ...
            n * n, file, numel(values));
    end

    % sscanf reads in file order (row by row); reshape fills column-major,
    % so transpose to recover the row-major layout of the file.
    A = reshape(values, n, n).';

    if ~all(ismember(A(:), [0, 1]))
        error('NDS:loadKrackhardt:notBinary', ...
            'The Krackhardt LAS matrix must be binary.');
    end
    if any(diag(A) ~= 0)
        error('NDS:loadKrackhardt:nonZeroDiagonal', ...
            'The Krackhardt LAS matrix must have a zero diagonal.');
    end

    if opts.Validate
        validate_published_degrees(A);
    end

    labels = arrayfun(@(k) sprintf('M%d', k), (1:n).', 'UniformOutput', false);

    net = net_from_matrix(A, ...
        'Name', 'krackhardt-advice', ...
        'Labels', labels, ...
        'Coords', layout_polygon(n), ...
        'ZeroRowPolicy', 'error', ...   % must not be needed; fail loudly if it is
        'Meta', struct( ...
            'source',      'Krackhardt (1987), Social Networks 9(2):109-134, Appendix A, p. 129', ...
            'relation',    'advice seeking', ...
            'aggregation', 'LAS (Locally Aggregated Structure)', ...
            'validation',  'degree sequence matches Sims & Gilles (2014) Table 4', ...
            'notes',       ['Binary data: row-normalisation assumes each manager ' ...
                            'splits trust equally among the advisors named.']));
end

% -------------------------------------------------------------------------
function validate_published_degrees(A)
%VALIDATE_PUBLISHED_DEGREES Cross-check against Sims & Gilles (2014) Table 4.

    publishedOut = [4 2 9 7 10 1 6 7 9 5 3 1 6 4 9 4 5 12 10 7 8];
    publishedIn  = [12 18 3 6 3 0 11 1 4 8 9 3 0 10 3 0 0 15 2 6 15];

    actualOut = sum(A, 2).';
    actualIn  = sum(A, 1);

    if ~isequal(actualOut, publishedOut)
        bad = find(actualOut ~= publishedOut);
        error('NDS:loadKrackhardt:outDegreeMismatch', ...
            ['Out-degrees disagree with Sims & Gilles (2014) Table 4 at manager(s) %s. ' ...
             'The data file may be corrupted.'], mat2str(bad));
    end
    if ~isequal(actualIn, publishedIn)
        bad = find(actualIn ~= publishedIn);
        error('NDS:loadKrackhardt:inDegreeMismatch', ...
            ['In-degrees disagree with Sims & Gilles (2014) Table 4 at manager(s) %s. ' ...
             'The data file may be corrupted.'], mat2str(bad));
    end
end
