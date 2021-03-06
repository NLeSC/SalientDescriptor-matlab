% perfEval_IsSameScene_OxFrei- performance evaluation of the same  scene
%                   tests for the OxFrei dataset
% **************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 7 April 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 18.05.2017
% modification details: adding BIN + SURF; using config
%**************************************************************************

%% parameters
[ exec_flags, exec_params, ~, ~, ...
    ~, ~, paths] = config(mfilename, 'oxfrei');

v2struct(exec_flags);
v2struct(exec_params);
v2struct(paths);

publish = true;
visualize = true;
area_filtering = true;  % if true, perform area filterring on regions

if publish
  %  det_descr = 'BIN_SMI_all';
    det_descr = 'BIN_SMI_filt';
  %  det_descr = 'BIN_SURF';
  %  det_descr = 'MSER_SMI';
  %  det_descr = 'MSER_SURF';
else   
    det_descr = input('Enter  detector + descriptor combination ([BIN_SURF|BIN_SMI_all|BIN_SMI_filt|MSER_SURF|MSER_SMI]): ','s');
end

%% load the predicted matrix
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','LargeScaleImaging');
sav_path = fullfile(project_path , 'Results', 'OxFrei','Comparision');

if publish
    switch upper(det_descr)
        case 'BIN_SURF'
            sav_fullfname =  fullfile(sav_path, 'test_IsSameScene_BIN_SURF_OxFrei_16-05-2017_15-27.mat');
        case 'BIN_SMI_ALL'
            sav_fullfname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_all_OxFrei_25-05-2017_17-43.mat');
        case 'BIN_SMI_FILT'
            sav_fullfname = fullfile(sav_path, 'test_IsSameScene_BIN_SMI_filt_OxFrei_30-05-2017_20-07.mat');
        case 'MSER_SURF'
            sav_fullfname = fullfile(sav_path, 'test_IsSameScene_MSER_SURF_OxFrei_10-05-2017_22-30.mat');
        case 'MSER_SMI'
            sav_fullfname =fullfile(sav_path, 'test_IsSameScene_MSER_SMI_OxFrei_20-05-2017_11-23.mat');
        otherwise
            error('Unknown detector + descriptor combination!');
    end
else
    sav_fullfname = input('Enter the OxFrei is same scene experiment results filename: ', 's');
    sav_fullfname = fullfile(sav_path, sav_fullfname);
end

%% load the saved results
load(sav_fullfname,'is_same_all','YLabels');
predicted = is_same_all;


%% compute performance measures
[eval_metrics] = perfEval_IsSameScene(predicted, scene_size, vis_eval, YLabels, lab_step, verbose);

