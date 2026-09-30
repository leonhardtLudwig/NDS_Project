function [S, names, ids] = load_sampson()
%LOAD_SAMPSON Sampson's monastery network, affective relation at wave T4.
%
%   [S, names, ids] = LOAD_SAMPSON() returns the 18-by-18 SIGNED matrix, the
%   novices' names, and Sampson's original ID numbers.
%
%       S(i,j) in {-3,-2,-1,0,+1,+2,+3}
%
%   Positive values are the first, second and third most LIKED; negative
%   values the first, second and third LEAST liked. S(i,j) is novice i's
%   nomination of novice j, so rows are choosers -- the project convention.
%
%   The signed matrix is returned raw and unsplit, so that both the
%   non-negative models of this project and a later structural-balance
%   analysis can be built from the same object. Extract a pole explicitly:
%
%       A = max(S, 0);            % liking
%       A = -min(S, 0);           % disliking
%       W = row_stochastic(A);
%
%   Writing it out this way keeps the modelling choice visible in the
%   notebook rather than buried in an option.
%
%   SOURCE
%       Sampson, S. F. (1968), "A Novitiate in a Period of Change", PhD
%       thesis, Cornell University -- APPENDIX, Table D13, "Affective Matrix,
%       T4", p. 469. The appendix holds twelve such tables, D5-D16: four
%       relations at three waves, one per page, pp. 461-472.
%
%   VALIDATION
%       Checked on every load against the (+) and (-) column totals printed
%       beneath the table -- 54 constraints, all satisfied.
%
%   CODING AND CAVEATS
%       Values are RANKS, not intensities, so any cardinal use is a modelling
%       assumption. The waves are partly RETROSPECTIVE RECALL. The negative
%       pole is the euphemism "liked least", not "disliked" -- Sampson notes
%       that admitting dislike was tantamount to confessing inadequacy in that
%       community, which is why three novices name nobody at all on it.
%
%   Example
%       [S, names] = load_sampson();
%       W = row_stochastic(max(S, 0));
%       graph_summary(W)
%
%   See also LOAD_KRACKHARDT, ROW_STOCHASTIC.

    file = fullfile(project_root(), 'data', 'sampson_affective_T4_signed.txt');
    if ~isfile(file)
        error('NDS:load_sampson:missing', 'Data file not found: %s', file);
    end

    S = reshape(sscanf(fileread(file), '%f'), 18, 18).';

    publishedPositive = [12 13 7 12 10 3 6 6 5 0 4 9 4 3 3 2 4 8];
    publishedNegative = [3 17 13 18 0 9 5 10 0 3 0 1 4 2 0 1 7 1];
    if ~isequal(sum(max(S, 0), 1), publishedPositive) || ...
       ~isequal(-sum(min(S, 0), 1), publishedNegative)
        error('NDS:load_sampson:checksum', ...
            'Column totals disagree with Table D13; the file may be corrupted.');
    end

    ids = [18 19 20 24 25 26 30 32 33 34 35 36 37 38 39 40 41 42].';

    names = { ...
        'John Bosco'; 'Gregory';  'Basil';    'Peter';   'Bonaventure'; 'Berthold'; ...
        'Mark';       'Victor';   'Ambrose';  'Romuald'; 'Louis';       'Winfrid'; ...
        'Amand';      'Hugh';     'Boniface'; 'Albert';  'Elias';       'Simplicius'};
end
