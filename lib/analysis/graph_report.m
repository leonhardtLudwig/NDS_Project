function report = graph_report(input, varargin)
%GRAPH_REPORT Structural analysis governing convergence of every model.
%
%   report = GRAPH_REPORT(W) analyses the digraph of the matrix W and returns
%   the structural facts that decide whether the opinion dynamics converge,
%   reach consensus, or oscillate.
%
%   report = GRAPH_REPORT(net) analyses net.W (the matrix the discrete-time
%   models actually run on, including any self-loops added during row
%   normalisation). Pass net.A explicitly to analyse the raw weights instead.
%
%   GRAPH_REPORT(...) with no output argument prints a readable summary.
%
%   Fields
%       n                 number of agents
%       comp              n-by-1 strong-component labels
%       nComponents       number of strong components
%       members           cell array of component memberships
%       isClosed          nComponents-by-1 logical, true for CLOSED components
%       closedComponents  indices of the closed components
%       periods           nComponents-by-1 periods (1 = aperiodic, 0 = acyclic)
%       isIrreducible     true when the graph is strongly connected
%       isRooted          true when exactly one closed component exists
%       roots             node indices that influence everyone (empty if none)
%       isConvergent      all closed components aperiodic
%       reachesConsensus  isRooted AND the unique closed component aperiodic
%
%   THEORY (Proskurnikov & Tempo, Part I, Theorem 12)
%       The French-DeGroot model x(k+1) = W x(k) is
%         * CONVERGENT  iff every closed strong component is aperiodic;
%         * CONSENSUAL  iff the graph is rooted AND its unique closed strong
%           component is aperiodic.
%       Rootedness alone is NOT enough: the directed cycle is strongly
%       connected yet periodic, and its opinions rotate forever.
%
%   IMPLEMENTATION NOTE
%       With the project convention W(i,j) > 0 = "i listens to j", influence
%       flows against the arrows. A CLOSED strong component (one receiving no
%       influence from outside) is therefore exactly a SINK of the
%       condensation of the listening graph: a component none of whose
%       members listens to anybody outside it. When a unique closed component
%       exists, every one of its members is a root, because in a DAG every
%       node reaches some sink and that sink is unique.
%
%   See also STRONGLY_CONNECTED_COMPONENTS, GRAPH_PERIOD, SOCIAL_POWER.

    W = extract_matrix(input);
    n = validate_square_matrix(W, 'W', true);

    parse_options(struct(), varargin, mfilename);   % reject stray arguments

    [comp, nComp, members] = strongly_connected_components(W);

    mask = W > 0;

    % A component is closed when no member has an edge leaving it.
    isClosed = false(nComp, 1);
    for c = 1:nComp
        rows = members{c};
        outside = true(n, 1);
        outside(rows) = false;
        isClosed(c) = ~any(any(mask(rows, outside)));
    end

    periods = zeros(nComp, 1);
    for c = 1:nComp
        periods(c) = graph_period(W, members{c});
    end

    closedIdx = find(isClosed).';
    isRooted = isscalar(closedIdx);

    if isRooted
        roots = members{closedIdx};
    else
        roots = zeros(1, 0);
    end

    % Period 0 means "no cycles", which is aperiodic for our purposes.
    closedAperiodic = all(periods(closedIdx) <= 1);

    report = struct();
    report.n                = n;
    report.comp             = comp;
    report.nComponents      = nComp;
    report.members          = members;
    report.isClosed         = isClosed;
    report.closedComponents = closedIdx;
    report.periods          = periods;
    report.isIrreducible    = (nComp == 1);
    report.isRooted         = isRooted;
    report.roots            = roots;
    report.isConvergent     = closedAperiodic;
    report.reachesConsensus = isRooted && closedAperiodic;

    if nargout == 0
        print_report(report);
        clear report;
    end
end

% -------------------------------------------------------------------------
function W = extract_matrix(input)
    if isstruct(input)
        if ~isfield(input, 'W')
            error('NDS:graphReport:badStruct', ...
                ['A struct input must be a network built by NET_FROM_MATRIX ' ...
                 '(field ''W'' is missing).']);
        end
        W = input.W;
    else
        W = input;
    end
end

% -------------------------------------------------------------------------
function print_report(r)
    fprintf('Graph report (%d agents)\n', r.n);
    fprintf('  strong components : %d%s\n', r.nComponents, ...
        ternary(r.isIrreducible, '  (strongly connected)', ''));
    for c = 1:r.nComponents
        tag = '';
        if r.isClosed(c)
            tag = ' [CLOSED]';
        end
        fprintf('    #%d%s period=%d : %s\n', c, tag, r.periods(c), ...
            mat2str(r.members{c}));
    end
    fprintf('  rooted            : %s\n', ternary(r.isRooted, 'yes', 'no'));
    if r.isRooted
        fprintf('  roots             : %s\n', mat2str(r.roots));
    end
    fprintf('  convergent        : %s\n', ternary(r.isConvergent, 'yes', 'no'));
    fprintf('  reaches consensus : %s\n', ternary(r.reachesConsensus, 'yes', 'no'));
    if ~r.isConvergent
        fprintf('  -> a closed component is PERIODIC: opinions oscillate.\n');
    elseif ~r.isRooted
        fprintf('  -> several closed components: opinions settle into BLOCKS.\n');
    end
end

% -------------------------------------------------------------------------
function s = ternary(condition, ifTrue, ifFalse)
    if condition
        s = ifTrue;
    else
        s = ifFalse;
    end
end
