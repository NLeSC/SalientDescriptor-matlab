%[ exec_flags, exec_params, moments_params, cc_params, ...
%                       match_params, vis_params, paths] = ...
%                                               config(scripts_name, dataset)
% config - sets up all configurations for the experiments
% **************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 9 May 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 18.05.2017
% modification details: added parameters or the performance evaluaiton scripts
%**************************************************************************
% INPUTS:
% scripts_name  the mfilename of the calling script
% dataset       string for the experimental dataset, 'Oxford'|'OxFrei'
%**************************************************************************
% OUTPUTS:
% exec_flags    the execution flags (extra to execution parameters)
%               publish - whether to run in publish mode
%               visualize_dataset - whether to visuzalize the dataset
%               visualize_test- whether to visualize the test image pair
%               binarized- if true pre-binarized images are used
%               visualize_final - whether to visualize the final result 
%               visualize_matching_cost - whether to visualize the matching cost matrix
%               visualize_transf_similarity - whether to visualize the cost matrix   
%               vis_eval - whether to visualize the evaluation matrix
% exec_params   the execution parameters structure with fields:
%               verbose- flag for verbose mode
%               visualize- flag for vizualizing the matching
%               area_filtering - flag for region (cc) area filtering 
%               matches_filtering - flag for matches filtering
%               data_size - the number of images in the dataset
%               scene_size - the number of (original + transformed) images in a scene
%               tick_step - the step  between ticksin images
%               lab_step - the step between axis labels
% moments_params struct with the moment invariants parameters:
%                order- moments order, {4}
%                coeff_file- coefficients file filename, {'afinvs4_19.txt'}
%                max_num_moments- maximun number of moments, {16}
%
% cc_params      struct with the connected components parameters:
%                conn - CC computaiton connectivity, {8}
%                list_props list of CC properties to be computed:
%                   {'Area','Centroid','MinorAxisLength','MajorAxisLength',
%                                               'Eccentricity','Solidity'};
%                area_factor - factor what is considered large CC in an
%                   image, {0.00005}
%
% match_params   the matching parameters struct with fields:
%                match_metric- feature matching metric, see 'Metric' of
%                   matchFeatures. {'ssd'} = Sum of Sqared Differences
%                match_thresh - matching threshold, see 'MatchThreshold'
%                   of matchFeatures. {1}
%                max_ratio - ratio threshold, see 'MaxRatio' of
%                   matchFeatures. {0.75}
%                max_dist - max distance from point to projection for
%                   estimating the geometric trandorm between matches. See
%                   "help estimateGeometricTransfrom". Default is {10}.
%                conf - confidence of finding maximum number ofinliers. See
%                   "help estimateGeometricTransfrom". Default is {90}.
%                max_num_trials - maximum random trials. See
%                   "help estimateGeometricTransfrom". Default is {100}.
%                cost_thresh - matching cost threshold. The match is
%                   considered good it its matching cost is above this
%                   threhsold. Default value is {0.025}
%                transf_sim_thresh- Transformation similarity (1-distance) threshold.
%                   For a good match between images the distance between
%                   an image and transformed with estimated transformation
%                   image should be small (similarity should be positive).
%                   Default is {+.25}.
%                num_sim_runs - number of similarity runs, the final transf_sim 
%                   is the average of number of runs. Default is 10.
%
% vis_params     struct with the visualization parameters:
%                sbp1/2 - subplot location for CC visualization
%                sbp1/2_f - subplot location for filtered CC visualization
%                sbp1/2_m - subplot location for matches visualization
%                sbp1/2_fm - subplot location for filtered matches visual.
%
% paths         the data and result paths and extensions
%               
%**************************************************************************
% NOTES: 
%**************************************************************************
% EXAMPLES USAGE:
%
% see any 'IsSameScence' testing script in this folder
%**************************************************************************

function [ exec_flags, exec_params, moments_params, cc_params, ...
    match_params, vis_params, paths] = config(scripts_name, dataset)

%% execution flags
publish = true;
visualize_dataset = false;
visualize_test = false;
visualize_final = true;
visualize_matching_cost = true;
visualize_transf_similarity = true;
vis_eval = true;
binarized = false;
sav = false;

% execution parameters
verbose = true;
visualize = true;
area_filtering = false;  % if true, perform area filterring on regions
matches_filtering = true; % if true, perform filterring on the matches

switch lower(dataset)
    case 'oxford'
        data_size =24;
        tick_step = 1;
        scene_size = 6;
        lab_step = 1;
    case 'oxfrei'
        data_size = 189;
        tick_step = 4;
        scene_size = 21;
        lab_step = 4;
    otherwise
        error('Unsupported dataset!');
end

exec_params = v2struct(verbose,visualize, area_filtering, matches_filtering,...
    data_size, tick_step, scene_size, lab_step);

exec_flags  = v2struct(publish, visualize_dataset, visualize_test, visualize_final,...
    vis_eval, verbose, binarized, sav,...
    visualize_transf_similarity, visualize_matching_cost);
 
%% moments parameters
order = 4;
coeff_file = 'afinvs4_19.txt';
max_num_moments = 16;

moments_params = v2struct(order,coeff_file, max_num_moments);

%% CC parameters
conn = 8;
list_props = {'Area','Centroid','MinorAxisLength','MajorAxisLength',...
    'Eccentricity','Solidity'};
area_factor = 0.0002; 

cc_params = v2struct(conn, list_props, area_factor);

%% matching parameters
match_metric = 'ssd';
match_thresh = 1;
max_ratio = 1;
max_dist = 8;
conf=95;
max_num_trials = 1000;
cost_thresh = 0.025;
transf_sim_thresh = 0.25;
num_sim_runs = 10;

match_params = v2struct(match_metric, match_thresh, max_ratio, max_dist, ...
    conf, max_num_trials, cost_thresh, transf_sim_thresh, num_sim_runs);

%% vis. parameters
if visualize
    if matches_filtering
        sbp1 = (241);
        sbp1_f = (242);
        sbp1_m = (243);
        sbp1_fm = (244);
        sbp2 = (245);
        sbp2_f = (246);
        sbp2_m = (247);
        sbp2_fm = (248);
    else
        sbp1 = (231);
        sbp1_f = (232);
        sbp1_m = (233);
        sbp1_fm = [];
        sbp2 = (234);
        sbp2_f = (235);
        sbp2_m = (236);
        sbp2_fm = [];
    end
    offset_factor = 0.25;
    
    vis_params = v2struct(sbp1, sbp1_f, sbp1_m, sbp1_fm,...
        sbp2, sbp2_f, sbp2_m, sbp2_fm, offset_factor);
else
    vis_params = [];
end

%% paths
if ispc
    starting_path = fullfile('C:','Projects');
else
    starting_path = fullfile(filesep,'home','elena');
end
project_path = fullfile(starting_path, 'eStep','SalientDescriptor-matlab');

switch lower(dataset)
    case 'oxford'
        data_path_or = fullfile(project_path , 'Data', 'AffineRegions');
        if sav
            sav_path = fullfile(project_path, 'Results', 'AffineRegions','Comparision');
        end
        if binarized
            data_path_bin = fullfile(project_path , 'Results', 'AffineRegions');        
        end                
    case 'oxfrei'
        data_path_or = fullfile(project_path , 'Data', 'OxFrei');
        if sav
            sav_path = fullfile(project_path, 'Results', 'OxFrei','Comparision');
        end
        if binarized
            data_path_bin = fullfile(project_path , 'Results', 'OxFrei');        
        end
    otherwise
        error('Unsupported dataset!');
end
ext_or  ='.png';
ext_bin = '_bin.png';

if sav
    %scripts_name = mfilename;
    format_dt = 'dd-mm-yyyy_HH-MM';
    sav_fname = generate_results_fname(sav_path, scripts_name, format_dt);
end

if ( binarized && sav )
%if sav
    paths = v2struct(data_path_or, data_path_bin, ext_or, ext_bin, sav_path, sav_fname);
elseif ( binarized && not(sav) )
    paths = v2struct(data_path_or, data_path_bin, ext_or, ext_bin);
elseif ( not(binarized) && sav)
    paths = v2struct(data_path_or, ext_or, sav_path, sav_fname);    
else
    paths = v2struct(data_path_or, ext_or);
end

