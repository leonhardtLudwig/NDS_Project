function projectRoot = setup_paths()
%SETUP_PATHS Put the opinion-dynamics library on the MATLAB path.
%
%   SETUP_PATHS() adds every library folder of this project to the MATLAB
%   search path for the current session. Run it once after opening MATLAB.
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
%   LIBRARY LAYOUT
%       lib/matrices   build the matrices the models act on
%       lib/models     the four simulators, one per update equation
%       lib/analysis   social power, limit operators, graph structure
%       lib/data       the empirical networks and published examples
%       lib/viz        plotting
%       lib/internal   small input checks, no mathematics
%
%   See also PROJECT_ROOT.

    projectRoot = fileparts(mfilename('fullpath'));

    folders = { ...
        projectRoot, ...
        fullfile(projectRoot, 'lib', 'internal'), ...
        fullfile(projectRoot, 'lib', 'matrices'), ...
        fullfile(projectRoot, 'lib', 'models'), ...
        fullfile(projectRoot, 'lib', 'analysis'), ...
        fullfile(projectRoot, 'lib', 'data'), ...
        fullfile(projectRoot, 'lib', 'viz'), ...
        fullfile(projectRoot, 'tests')};

    for k = 1:numel(folders)
        if ~isfolder(folders{k})
            error('NDS:setupPaths:missingFolder', ...
                'Expected project folder is missing: %s', folders{k});
        end
        addpath(folders{k});
    end

    if nargout == 0
        clear projectRoot;
    end
end
