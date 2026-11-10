function save_eps(fig, file, method)
%SAVE_EPS Write a figure as a colour EPS, with the chosen exporter.
%
%   SAVE_EPS(fig, file, method) writes fig to file. method selects how:
%
%       'vector'   exportgraphics(fig, file, 'ContentType', 'vector')
%                  with a fallback to print -depsc -vector on older releases
%       'print'    print(fig, file, '-depsc')
%
%   The figure is NOT closed.
%
%   WHY TWO METHODS
%       The two exporters do not produce the same file: on one and the same
%       figure they differ in size and content, not only in the %% header
%       lines. The figures of Section 2.2 of the report were produced with
%       'vector' and those of Section 3.2 with 'print', so each live script
%       keeps its own exporter and the delivered .eps stay exactly the files
%       the report includes. Do not unify them.
%
%   method defaults to 'vector'.
%
%   See also REPORT_FIGURE.

    if nargin < 3, method = 'vector'; end

    switch method
        case 'vector'
            if exist('exportgraphics', 'file') == 2
                exportgraphics(fig, file, 'ContentType', 'vector');
            else
                print(fig, file, '-depsc', '-vector');
            end
        case 'print'
            print(fig, file, '-depsc');
        otherwise
            error('NDS:save_eps:badMethod', ...
                'method must be ''vector'' or ''print'', not ''%s''.', method);
    end
end
