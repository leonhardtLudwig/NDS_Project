function projectRoot = setup_paths()
%SETUP_PATHS Put the opinion-dynamics library on the MATLAB path.
%
%   SETUP_PATHS() adds every library folder of this project to the MATLAB
%   search path for the current session. Run it once after opening MATLAB in
%   the project folder, or from any location.
%
%   projectRoot = SETUP_PATHS() also returns the absolute path of the project
%   root, which is useful for locating data files.
%
%   The project root itself is added too, so that SETUP_PATHS remains callable
%   from any working directory once it has been run at least once.
%
%   The path is NOT saved permanently; call SAVEPATH yourself if you want it
%   to persist across sessions.
%
%   See also PROJECT_ROOT.

    projectRoot = fileparts(mfilename('fullpath'));

    folders = { ...
        projectRoot, ...
        fullfile(projectRoot, 'lib', 'util'), ...
        fullfile(projectRoot, 'lib', 'graphs'), ...
        fullfile(projectRoot, 'lib', 'analysis'), ...
        fullfile(projectRoot, 'lib', 'models'), ...
        fullfile(projectRoot, 'lib', 'predict'), ...
        fullfile(projectRoot, 'lib', 'viz'), ...
        fullfile(projectRoot, 'tests'), ...
        fullfile(projectRoot, 'tools')};

    for k = 1:numel(folders)
        if ~isfolder(folders{k})
            error('NDS:setupPaths:missingFolder', ...
                'Expected project folder is missing: %s', folders{k});
        end
        addpath(folders{k});
    end

    if nargout == 0
        fprintf('NDS opinion-dynamics library added to the path.\n');
        fprintf('Project root: %s\n', projectRoot);
        clear projectRoot;
    end
end
