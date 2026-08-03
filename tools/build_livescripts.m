function built = build_livescripts(varargin)
%BUILD_LIVESCRIPTS Generate .mlx Live Scripts from their .m sources.
%
%   built = BUILD_LIVESCRIPTS() converts every livescripts/*.m file into the
%   corresponding .mlx Live Script and returns the list of files written.
%
%   Name-value options
%       'Filter'  substring; only sources whose name contains it are built
%       'Force'   rebuild even when the .mlx is newer than its source
%                 (default false)
%
%   WHY THE SOURCES ARE .m FILES
%       A .mlx file is a binary package. It cannot be diffed, reviewed or
%       merged, which makes it a poor artefact to keep under version control
%       as the source of truth. The .m files in livescripts/ are written in
%       Live Editor cell format (%% section headings and % prose), so they
%       are readable and diffable, run directly as ordinary scripts, AND
%       convert cleanly to .mlx.
%
%       The .mlx files are therefore GENERATED OUTPUT: edit the .m file and
%       rebuild, rather than editing the .mlx and losing the change.
%
%       Sources live in livescripts/src/ and the generated .mlx files one
%       level up, in livescripts/. They MUST NOT share a folder: MATLAB gives
%       a .mlx precedence over a same-named .m, which makes the .m
%       unrunnable ("... .mlx shadows it").
%
%   If the conversion API is unavailable in your MATLAB installation, open
%   the .m file in the Live Editor and use Save As -> MATLAB Live Code File.
%
%   See also RUN_LIVESCRIPTS, SETUP_PATHS.

    opts = parse_options(struct( ...
        'Filter', '', ...
        'Force',  false), varargin, mfilename);

    sourceDir = fullfile(project_root(), 'livescripts', 'src');
    targetDir = fullfile(project_root(), 'livescripts');
    sources = dir(fullfile(sourceDir, '*.m'));
    if ~isempty(opts.Filter)
        sources = sources(contains({sources.name}, opts.Filter));
    end

    built = {};
    for k = 1:numel(sources)
        [~, stem] = fileparts(sources(k).name);
        inFile  = fullfile(sourceDir, sources(k).name);
        outFile = fullfile(targetDir, [stem '.mlx']);

        if ~opts.Force && isfile(outFile)
            outInfo = dir(outFile);
            if outInfo.datenum >= sources(k).datenum
                fprintf('  up to date : %s.mlx\n', stem);
                continue;
            end
        end

        try
            matlab.internal.liveeditor.openAndSave(inFile, outFile);
            built{end+1} = outFile; %#ok<AGROW>
            fprintf('  built      : %s.mlx\n', stem);
        catch err
            warning('NDS:buildLivescripts:conversionFailed', ...
                ['Could not convert %s (%s).\n' ...
                 'Open it in the Live Editor and use Save As -> ' ...
                 'MATLAB Live Code File instead.'], sources(k).name, err.message);
        end
    end

    fprintf('%d Live Script(s) written to %s\n', numel(built), targetDir);

    if nargout == 0
        clear built;
    end
end
