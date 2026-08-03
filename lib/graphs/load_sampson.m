function [net, S] = load_sampson(varargin)
%LOAD_SAMPSON Sampson's monastery network (affective relation, wave T4).
%
%   net = LOAD_SAMPSON() loads the liking network among the 18 novices of
%   Sampson's monastery study and returns it as a project network structure.
%
%   [net, S] = LOAD_SAMPSON(...) additionally returns the raw SIGNED matrix.
%
%   Name-value options
%       'File'     path to the data file
%                  (default data/sampson_affective_T4_signed.txt)
%       'Sign'     which pole to extract, since the four models of this
%                  project all require non-negative weights:
%           'positive' (default) liking    -- S(i,j) > 0 kept, rest zeroed
%           'negative'           disliking -- |S(i,j)| for S(i,j) < 0
%       'Weights'  how ranks become weights:
%           'rank'   (default) keep 3/2/1 for first/second/third choice
%           'binary' every nomination counts 1
%       'Validate' check the published column totals (default true)
%
%   THE SIGNED MATRIX IS ALWAYS AVAILABLE
%       Whatever pole is extracted, the full signed matrix is returned as the
%       second output and stored in net.meta.signed. Nothing is discarded.
%       This keeps a later structural-balance / Altafini extension (Part II
%       material, where negative ties are essential) possible without
%       re-acquiring the data, while guaranteeing that net.A and net.W are
%       non-negative and therefore valid for French-DeGroot, Abelson, Taylor
%       and Friedkin-Johnsen.
%
%   SOURCE
%       Sampson, S. F. (1968), "A Novitiate in a Period of Change: An
%       Experimental and Case Study of Social Relationships", PhD thesis,
%       Cornell University -- APPENDIX, Table D13, "Affective Matrix, T4",
%       p. 469. Transcribed from the scan in this repository.
%
%       The appendix holds 12 such tables, D5-D16: four relations (affective,
%       esteem, influence, sanction) at three waves (T2, T3, T4), one per
%       page, pp. 461-472. This loader uses D13, the affective relation at
%       T4 -- the last observation before the community broke up, and the
%       wave on which the faction structure is conventionally defined. It is
%       the same matrix that UCINET distributes, split into its positive and
%       negative parts, as SAMPLK3 and SAMPDLK.
%
%   CODING
%       Values are RANKED CHOICES carrying a sign: +3/+2/+1 for the first,
%       second and third most liked, and -3/-2/-1 for the most, second and
%       third least liked. They are ranks, NOT intensities, so the
%       rank-to-weight mapping is a modelling assumption -- which is why it
%       is exposed as the 'Weights' option rather than hard-coded.
%
%   VALIDATION
%       The transcription was checked against the (+), (-) and (T) column
%       totals printed beneath the table -- 54 constraints, all satisfied --
%       and every row with an irregular choice pattern was re-read at high
%       magnification. The column check is re-run on every load.
%
%   KNOWN IRREGULARITIES (genuine features, not transcription errors)
%       * Basil, Berthold and Romuald give FOUR choices on one pole, with a
%         tie in the ranks. Sampson's instrument allowed a fourth choice in
%         case of ties, and the standard dataset documentation records this.
%       * Bonaventure, Romuald and Winfrid name nobody they liked least, so
%         with 'Sign','negative' those rows are empty and ROW_NORMALIZE gives
%         them a self-loop. Sampson notes (footnote 23, p. 316) that the
%         community's ideology of brotherly love made admitting dislike
%         tantamount to confessing inadequacy, so refusals on the negative
%         pole are substantively meaningful rather than missing data.
%
%   CAVEATS TO STATE IN ANY WRITE-UP
%       * The waves are partly RETROSPECTIVE RECALL: the questionnaire asks
%         respondents to think back and answer as they felt at an earlier
%         time, so T2/T3/T4 are not independent longitudinal measurements.
%       * The negative pole is the euphemism "liked least", not "disliked".
%
%   See also LOAD_KRACKHARDT, NET_FROM_MATRIX, GRAPH_REPORT.

    opts = parse_options(struct( ...
        'File',     '', ...
        'Sign',     'positive', ...
        'Weights',  'rank', ...
        'Validate', true), varargin, mfilename);

    signMode   = validatestring(opts.Sign, {'positive', 'negative'}, ...
        mfilename, 'Sign');
    weightMode = validatestring(opts.Weights, {'rank', 'binary'}, ...
        mfilename, 'Weights');

    if isempty(opts.File)
        file = fullfile(project_root(), 'data', 'sampson_affective_T4_signed.txt');
    else
        file = char(opts.File);
    end

    if ~isfile(file)
        error('NDS:loadSampson:fileNotFound', ...
            ['Sampson data file not found:\n  %s\n' ...
             'It is transcribed from Table D13 (p. 469) of the dissertation; ' ...
             'see data/README.md.'], file);
    end

    n = 18;
    values = sscanf(fileread(file), '%f');
    if numel(values) ~= n * n
        error('NDS:loadSampson:badSize', ...
            'Expected %d numeric entries in %s, found %d.', n * n, file, numel(values));
    end

    % sscanf reads in file order (row by row); reshape fills column-major.
    S = reshape(values, n, n).';

    if any(abs(S(:)) > 3) || any(mod(S(:), 1) ~= 0)
        error('NDS:loadSampson:badValues', ...
            'Entries must be integers in the range -3..3.');
    end
    if any(diag(S) ~= 0)
        error('NDS:loadSampson:nonZeroDiagonal', ...
            'Self-nominations are excluded, so the diagonal must be zero.');
    end

    if opts.Validate
        validate_published_totals(S);
    end

    switch signMode
        case 'positive'
            A = max(S, 0);
            relation = 'affective (liking), positive pole';
        case 'negative'
            A = -min(S, 0);
            relation = 'affective (disliking), negative pole';
    end

    if strcmp(weightMode, 'binary')
        A = double(A > 0);
    end

    [ids, names] = sampson_actors();

    net = net_from_matrix(A, ...
        'Name', sprintf('sampson-affective-T4-%s', signMode), ...
        'Labels', names, ...
        'Coords', layout_polygon(n), ...
        'ZeroRowPolicy', 'selfloop', ...
        'Warn', false, ...   % three novices name nobody they like least
        'Meta', struct( ...
            'source',      ['Sampson (1968) PhD thesis, Cornell University, ' ...
                            'Appendix Table D13 "Affective Matrix, T4", p. 469'], ...
            'relation',    relation, ...
            'timepoint',   'T4', ...
            'aggregation', sprintf('%s pole, %s weights', signMode, weightMode), ...
            'validation',  'column totals match the printed (+), (-) and (T) rows', ...
            'signed',      S, ...
            'ids',         ids, ...
            'notes',       ['Values are RANKS (3/2/1), not intensities. Waves are ' ...
                            'partly retrospective recall. The negative pole is the ' ...
                            'euphemism "liked least". net.meta.signed holds the full ' ...
                            'signed matrix for structural-balance work.']));
end

% -------------------------------------------------------------------------
function [ids, names] = sampson_actors()
%SAMPSON_ACTORS Sampson's original ID numbers and the novices' names.
%
%   The IDs are not 1..18: Sampson numbered every participant of the wider
%   study, and these are the 18 present at waves T2-T4. They are kept so that
%   rows can be matched against the dissertation tables and against published
%   analyses that cite the original numbering.

    ids = [18 19 20 24 25 26 30 32 33 34 35 36 37 38 39 40 41 42].';

    names = { ...
        'John Bosco'; 'Gregory';  'Basil';    'Peter';  'Bonaventure'; 'Berthold'; ...
        'Mark';       'Victor';   'Ambrose';  'Romuald'; 'Louis';      'Winfrid'; ...
        'Amand';      'Hugh';     'Boniface'; 'Albert';  'Elias';      'Simplicius'};
end

% -------------------------------------------------------------------------
function validate_published_totals(S)
%VALIDATE_PUBLISHED_TOTALS Check against the totals printed under Table D13.
%
%   The dissertation prints, beneath every matrix, the column totals of the
%   positive entries, of the negative entries, and their sum. Those values are
%   transcription checksums, and they play exactly the role that the published
%   degree sequence plays for the Krackhardt network.

    publishedPositive = [12 13  7 12 10  3  6  6  5  0  4  9  4  3  3  2  4  8];
    publishedNegative = [ 3 17 13 18  0  9  5 10  0  3  0  1  4  2  0  1  7  1];

    actualPositive = sum(max(S, 0), 1);
    actualNegative = -sum(min(S, 0), 1);

    if ~isequal(actualPositive, publishedPositive)
        bad = find(actualPositive ~= publishedPositive);
        error('NDS:loadSampson:positiveTotalMismatch', ...
            ['Positive column totals disagree with Table D13 at column(s) %s. ' ...
             'The data file may be corrupted.'], mat2str(bad));
    end
    if ~isequal(actualNegative, publishedNegative)
        bad = find(actualNegative ~= publishedNegative);
        error('NDS:loadSampson:negativeTotalMismatch', ...
            ['Negative column totals disagree with Table D13 at column(s) %s. ' ...
             'The data file may be corrupted.'], mat2str(bad));
    end
end
