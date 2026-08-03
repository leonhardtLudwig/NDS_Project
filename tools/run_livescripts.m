function summary = run_livescripts(varargin)
%RUN_LIVESCRIPTS Execute every notebook to verify it still runs end to end.
%
%   summary = RUN_LIVESCRIPTS() runs each livescripts/*.m source in a clean
%   workspace with figures suppressed, and reports which ones completed.
%
%   Name-value options
%       'Filter'      substring; only matching notebooks are run
%       'SaveFigures' folder in which to export the figures each notebook
%                     produces; '' (default) discards them
%
%   The notebooks are documentation, but documentation that silently stops
%   working is worse than none. This turns them into an executable
%   integration test of the whole library: if a function signature changes,
%   the notebook that uses it fails here rather than in front of a reader.
%
%   See also BUILD_LIVESCRIPTS, RUN_ALL_TESTS.

    opts = parse_options(struct( ...
        'Filter',      '', ...
        'SaveFigures', ''), varargin, mfilename);

    sourceDir = fullfile(project_root(), 'livescripts', 'src');
    sources = dir(fullfile(sourceDir, '*.m'));
    if ~isempty(opts.Filter)
        sources = sources(contains({sources.name}, opts.Filter));
    end

    saveFigures = ~isempty(opts.SaveFigures);
    if saveFigures && ~isfolder(opts.SaveFigures)
        mkdir(opts.SaveFigures);
    end

    previousVisibility = get(0, 'DefaultFigureVisible');
    set(0, 'DefaultFigureVisible', 'off');
    restore = onCleanup(@() set(0, 'DefaultFigureVisible', previousVisibility));

    summary = struct('name', {}, 'status', {}, 'seconds', {}, 'message', {}, 'figures', {});

    for k = 1:numel(sources)
        [~, stem] = fileparts(sources(k).name);
        close all;
        timer = tic;
        try
            run(fullfile(sourceDir, sources(k).name));
            elapsed = toc(timer);
            figureHandles = findobj('Type', 'figure');
            if saveFigures
                export_figures(figureHandles, opts.SaveFigures, stem);
            end
            summary(end+1) = struct('name', stem, 'status', 'ok', ...
                'seconds', elapsed, 'message', '', ...
                'figures', numel(figureHandles)); %#ok<AGROW>
            fprintf('  [ok  ] %-24s %5.1f s, %d figure(s)\n', ...
                stem, elapsed, numel(figureHandles));
        catch err
            elapsed = toc(timer);
            summary(end+1) = struct('name', stem, 'status', 'failed', ...
                'seconds', elapsed, 'message', err.message, 'figures', 0); %#ok<AGROW>
            fprintf('  [FAIL] %-24s %s\n', stem, err.message);
        end
    end
    close all;

    failed = sum(strcmp({summary.status}, 'failed'));
    fprintf('\n%d notebook(s), %d ok, %d failed\n', ...
        numel(summary), numel(summary) - failed, failed);

    if failed > 0
        error('NDS:runLivescripts:failures', '%d notebook(s) failed.', failed);
    end

    if nargout == 0
        clear summary;
    end
end

% -------------------------------------------------------------------------
function export_figures(handles, targetDir, stem)
%EXPORT_FIGURES Write each figure of a notebook to a numbered PNG.
    handles = flipud(handles(:));           % oldest first
    for f = 1:numel(handles)
        outFile = fullfile(targetDir, sprintf('%s_fig%02d.png', stem, f));
        try
            exportgraphics(handles(f), outFile, 'Resolution', 150);
        catch err
            warning('NDS:runLivescripts:exportFailed', ...
                'Could not export figure %d of %s: %s', f, stem, err.message);
        end
    end
end
