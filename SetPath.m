
% run this at the very beginning to add paths

path.local_base = fullfile('~', 'Documents'); 
path.local_project = fullfile(path.local_base, 'code', 'aud_motion_revcorr', 'personal');
path.local_tool = fullfile(path.local_base, 'toolbox');
path.remote_base = fullfile('~', 'Dropbox', 'WoonJuPark', 'Projects'); 
path.remote_project = fullfile(path.remote_base, 'AuditoryMotionRF');

path.UWtool = fullfile(path.local_tool, 'UWToolbox', 'UWToolbox', 'optimization');
path.func = fullfile(path.local_project, 'func');
path.exp = fullfile(path.local_project, 'experiment'); 
path.filter = fullfile(path.remote_project, 'filter');
path.data = fullfile(path.remote_project, 'data');
path.psignifit = fullfile(path.local_tool, 'psignifit');

addpath(path.UWtool)
addpath(path.func);
addpath(path.exp);
addpath(path.filter);
addpath(path.data);
addpath(path.psignifit);



