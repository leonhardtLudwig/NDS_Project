function T = krackhardt_benchmarks()
%KRACKHARDT_BENCHMARKS Published node measures for Krackhardt's advice network.
%
%   T = KRACKHARDT_BENCHMARKS() returns a 21-row table of the node measures
%   published in Table 4 of
%
%       Sims, O. and Gilles, R. P. (2014), "Critical Nodes in Directed
%       Networks", arXiv:1401.0655v2,
%
%   computed on exactly the matrix returned by LOAD_KRACKHARDT (their
%   footnote 6 states that they use "the LAS matrix from p. 129" of
%   Krackhardt 1987).
%
%   Columns
%       manager        1..21
%       inDegree       d^-  how many managers seek advice FROM this one
%       outDegree      d^+  how many advisors this manager consults
%       bonacich       Bonacich centrality
%       betweenness    betweenness centrality
%       middleman      middleman (brokerage) power nu
%       middlemanDist  distance-weighted middleman power nu*
%       isMiddleman    'weak' | 'strong' | ''  (managers 4, 15 weak; 21 strong)
%
%   WHY THESE ARE HERE
%       They serve two purposes. First, the degree columns validate the
%       transcription of the data file (LOAD_KRACKHARDT checks them on every
%       load). Second, they are the published benchmark for the comparative
%       analysis: they let French-DeGroot social power be set against
%       structural centrality and against brokerage power on the same
%       network, without recomputing anyone else's measures.
%
%   THE POINT OF THE COMPARISON
%       The three notions disagree sharply. Manager 15 is the strongest
%       broker yet ranks 13th of 21 in social power; manager 18 dominates the
%       classical centralities but is not a middleman at all; manager 21 is
%       the only node strong on both. Sims & Gilles prove that centrality
%       does not capture brokerage; adding social power shows that neither
%       captures influence over opinions.
%
%   See also LOAD_KRACKHARDT, SOCIAL_POWER, PLOT_INFLUENCE_BARS.

    manager     = (1:21).';
    inDegree    = [12 18  3  6  3  0 11  1  4  8  9  3  0 10  3  0  0 15  2  6 15].';
    outDegree   = [ 4  2  9  7 10  1  6  7  9  5  3  1  6  4  9  4  5 12 10  7  8].';
    bonacich    = [0.068 0.306 1.271 1.001 1.463 0.172 0.776 1.013 1.171 0.820 ...
                   0.344 0.172 0.938 0.625 1.265 0.580 0.673 1.745 1.493 1.028 1.348].';
    betweenness = [0.035 0.011 0.018 0.071 0.009 0.000 0.048 0.001 0.011 0.018 ...
                   0.004 0.000 0.000 0.002 0.092 0.000 0.000 0.231 0.002 0.028 0.176].';
    middleman   = [0.000 0.000 0.000 0.090 0.000 0.000 0.000 0.000 0.000 0.000 ...
                   0.000 0.000 0.000 0.000 0.161 0.000 0.000 0.000 0.000 0.000 0.147].';
    middlemanDist = [0.000 0.000 0.000 0.034 0.000 0.000 0.000 0.000 0.000 0.000 ...
                     0.000 0.000 0.000 0.000 0.064 0.000 0.000 0.000 0.000 0.000 0.051].';

    isMiddleman = repmat({''}, 21, 1);
    isMiddleman([4 15]) = {'weak'};
    isMiddleman{21}     = 'strong';

    T = table(manager, inDegree, outDegree, bonacich, betweenness, ...
        middleman, middlemanDist, isMiddleman);

    T.Properties.Description = ...
        'Sims & Gilles (2014), Critical Nodes in Directed Networks, Table 4';
    T.Properties.VariableDescriptions = { ...
        'manager index', ...
        'in-degree: managers who seek advice from this one', ...
        'out-degree: advisors this manager consults', ...
        'Bonacich centrality', ...
        'betweenness centrality', ...
        'middleman (brokerage) power nu', ...
        'distance-weighted middleman power nu*', ...
        'middleman classification'};
end
