function s = graph_summary(A)
%GRAPH_SUMMARY Structural facts that decide convergence and consensus.
%
%   s = GRAPH_SUMMARY(A) analyses the digraph of A and returns
%
%       s.components   cell array of the strong components
%       s.closed       indices of the CLOSED components (those receiving no
%                      influence from outside)
%       s.periods      period of each component
%       s.rooted       true when exactly one closed component exists
%       s.roots        the nodes that influence everybody (empty if none)
%       s.convergent   all closed components aperiodic
%       s.consensus    rooted AND the unique closed component aperiodic
%
%   GRAPH_SUMMARY(A) with no output prints a readable report.
%
%   THEOREM (Proskurnikov & Tempo, Part I, Theorem 1.1)
%       x(k+1) = W x(k) is CONVERGENT iff every closed strong component is
%       aperiodic, and reaches CONSENSUS iff the graph is additionally rooted.
%       Rootedness alone is not enough -- the directed ring is strongly
%       connected yet periodic, and its opinions rotate forever.
%
%   CONVENTION
%       With A(i,j) > 0 meaning "i listens to j", influence flows against the
%       arrows, so a CLOSED component -- one receiving nothing from outside --
%       is a component none of whose members listens to anybody outside it.
%       When exactly one exists, all of its members are roots.
%
%   Example
%       graph_summary(ring_graph(6))        % periodic, does not converge
%       graph_summary(ring_graph(6, 0.2))   % consensus
%
%   See also STRONG_COMPONENTS, GRAPH_PERIOD, SOCIAL_POWER.

    n = check_square(A, 'A');
    [comp, members] = strong_components(A);
    adjacency = A > 0;

    nComp   = numel(members);
    closed  = false(nComp, 1);
    periods = zeros(nComp, 1);

    for c = 1:nComp
        outside = true(n, 1);
        outside(members{c}) = false;
        closed(c)  = ~any(any(adjacency(members{c}, outside)));
        periods(c) = graph_period(A, members{c});
    end

    closedIdx = find(closed).';

    s.components = members;
    s.comp       = comp;
    s.closed     = closedIdx;
    s.periods    = periods;
    s.rooted     = isscalar(closedIdx);
    s.convergent = all(periods(closedIdx) <= 1);
    if s.rooted
        s.roots = members{closedIdx};
    else
        s.roots = [];
    end
    s.consensus = s.rooted && s.convergent;

    if nargout == 0
        fprintf('Graph on %d nodes: %d strong component(s)\n', n, nComp);
        for c = 1:nComp
            mark = '';
            if closed(c), mark = ' [CLOSED]'; end
            fprintf('  #%d%s  period %d : %s\n', c, mark, periods(c), mat2str(members{c}));
        end
        fprintf('  rooted     : %d\n', s.rooted);
        fprintf('  convergent : %d\n', s.convergent);
        fprintf('  consensus  : %d\n', s.consensus);
        clear s;
    end
end
