% IsSameScene_BIN_SMI-  comparing if 2 images are of the same scene
%               (with smart binarization + SMI descriptor)
% **************************************************************************
% [is_same, num_matches, mean_cost, mean_transf_sim] = IsSameScene_BIN_SMI(im1o, im2o, ...
%                      bw1, bw2, ...
%                      moments_params, cc_params, match_params, ...
%                      vis_params, exec_params)
%
% author: Elena Ranguelova, NLeSc
% date created: 19 October 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 10 April 2017
% modification details: the CC version of SMIdescriptor is used now 
% last modification date: 21 March 2017
% modification details: similarity distance using corr2 (same as the
%                       standard method; different visualization transformation)
% last modification date: 14 November 2016
% modification details: outcome depends on the transformaiton distance only
%                       removed matches_ratio_thresh in/out parameter
% last modification date: 4 November 2016
% modification details: transformation distance replaced with similarity
% last modification date: 29 October 2016
% modification details: added more output parameters
% last modification date: 21 October 2016
% modification details: added visualizations, swaped parameter order
%**************************************************************************
% INPUTS:
% im1/2o          the input gray/color images to be compared
% [bw1/bw2]       binarized images. [Optional]. If missing, images are
%                 binarized inside the function.
% [moments_params] optional struct with the moment invariants parameters:
%                order- moments order, {4}
%                coeff_file- coefficients file filename, {'afinvs4_19.txt'}
%                max_num_moments- maximun number of moments, {16}
% [cc_params]    optional struct with the connected components parameters:
%                conn - CC computaiton connectivity, {8}
%                list_props list of CC properties to be computed:
%                   {'Area','Centroid','MinorAxisLength','MajorAxisLength',
%                                               'Eccentricity','Solidity'};
%                area_factor - factor what is considered large CC in an
%                   image, {0.0005}
% [match_params]   the matching parameters struct [optional] with fields:
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
%                   Default is {+.3}.
%                num_sim_runs - number of similarity runs, the final transf_sim 
%                   is the average of number of runs. Default is 20.
% [vis_params]   optional struct with the visualization parameters:
%                sbp1/2 - subplot location for CC visualization
%                sbp1/2_f - subplot location for filtered CC visualization
%                sbp1/2_m - subplot location for matches visualization
%                sbp1/2_fm - subplot location for filtered matches visual.
% [exec_params]  the execution parameters structure [optional] with fields:
%                verbose- flag for verbose mode, default value {false}
%                visualize- flag for vizualizing the matching, {false}
%                area_filtering - flag for performing region (cc) area
%                   filtering, {true}
%                matches_filtering - flag for performing matches filtering,
%                {true}
%**************************************************************************
% OUTPUTS:
% is_same        binary flag, true if images are showing (partially)
%                the same scene and false otherwise
% num_matches    number of matches
% mean_cost      mean cost of matching
% mean_transf_sim  mean transformation similarity between the 2 images
%**************************************************************************
% NOTES: The data-driven binarization is performed with default parameters.
%**************************************************************************
% EXAMPLES USAGE:
%
% see test_IsSameScene_BIN_SMI.m
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [is_same, num_matches, mean_cost, mean_transf_sim] = IsSameScene_BIN_SMI(im1o,...
    im2o, bw1, bw2, moments_params, cc_params, match_params, vis_params, exec_params)

%% input control
if nargin < 9 || isempty(exec_params)
    exec_params.verbose = false;
    exec_params.visualize = false;
    exec_params.area_filtering = true;
    exec_params.matches_filtering = true;
end
if (nargin < 8 || isempty(vis_params)) && (exec_params.visualize)
%     if exec_params.matches_filtering
%         vis_params.sbp1 = (241);
%         vis_params.sbp1_f = (242);
%         vis_params.sbp1_m = (243);
%         vis_params.sbp1_fm = (244);
%         vis_params.sbp2 = (245);
%         vis_params.sbp_f = (246);
%         vis_params.sbp2_m = (247);
%         vis_params.sbp2_fm = (248);
%     else
%         vis_params.sbp1 = (231);
%         vis_params.sbp1_f = (232);
%         vis_params.sbp1_m = (233);
%         vis_params.sbp1_fm = [];
%         vis_params.sbp2 = (234);
%         vis_params.sbp2_f = (235);
%         vis_params.sbp2_m = (236);
%         vis_params.sbp2_fm = [];
%     end
    vis_params.sbp1 = (221);
    vis_params.sbp1_m = (222);
    vis_params.sbp2 = (223);
    vis_params.sbp2_m = (224);
end
if nargin < 7 || isempty(match_params)
    match_params.match_metric = 'ssd';
    match_params.match_thrseh = 1;
    match_params.max_ratio = 1;
    match_params.max_dist = 10;
    match_params.conf = 90;
    match_params.max_num_trials = 100;
    match_params.cost_thresh = 0.025;
    match_params.transf_sim_thresh = 0.3;
    match_params.num_sim_runs = 20;
end
if nargin < 6 || isempty(cc_params)
    cc_params.conn = 8;
    cc_params.list_props = {'Area','Centroid','MinorAxisLength',...
        'MajorAxisLength', 'Eccentricity','Solidity'};
    cc_params.area_factor = 0.0005;
end
if nargin < 4 || isempty(moments_params)
    moments_params.order = 4;
    moments_params.coeff_file = 'afinvs4_19.txt';
    moments_params.max_num_moments = 16;
end
if nargin < 4
    bw1 = [];
end
if nargin < 3
    bw2 = [];
end
if nargin < 2
    error('IsSameScene_BIN_SMI: the function expects minimum 2 input arguments- the images to be compared!');
end

%% unpack parameter structures into variables
v2struct(exec_params);
v2struct(moments_params);
v2struct(cc_params);
v2struct(match_params);
if visualize
    v2struct(vis_params);
end

%% dependant parameters
image_area1 = size(im1o, 1) * size(im1o,2);
image_area2 = size(im2o, 1) * size(im2o,2);
list_props_all = {'Area','Centroid'};
if area_filtering
    prop_types_filter = {'Area'};
    range1 = {[area_factor*image_area1 image_area1]};
    range2 = {[area_factor*image_area2 image_area2]};
end
transf_sim = zeros(1, num_sim_runs);
mean_transf_sim = 0;
%% processing
%**************** Processing *******************************
disp('Processing...');
if verbose
    disp('Comparing whether 2 images depict (partially) the same scene...');
    t0 = clock;
end

%% binarization
% find out the dimensionality
if ndims(im1o) == 3
    im1 = rgb2gray(im1o);
else
    im1= im1o;
end
if ndims(im2o) == 3
    im2 = rgb2gray(im2o);
else
    im2 = im2o;
end
tic

if isempty(bw1)
    if verbose
        disp('Data-driven binarization 1 (inside comparision)...');
    end
    [bw1,~] = data_driven_binarizer(im1);
end
if isempty(bw2)
    if verbose
        disp('Data-driven binarization 2 (inside comparision)...');
    end
    [bw2,~] = data_driven_binarizer(im2);
end
if verbose
    toc
end

%% visualization of the binarization result
if visualize
    fig_scrnsz = get(0, 'Screensize');
    offset = offset_factor * fig_scrnsz(4);
    fig_scrnsz(2) = fig_scrnsz(2) + offset;
    fig_scrnsz(4) = fig_scrnsz(4) - offset;
    f = figure; set(gcf, 'Position', fig_scrnsz);
%     show_binary(bw1, f, subplot(sbp1),'Binarized image1'); 
%     show_binary(bw2, f, subplot(sbp2),'Binarized image2');
%     pause(0.5);
end

%% CC computation and possibly filtering
if verbose
    disp('Computing the connected components...');
end
tic
cc1 = bwconncomp(bw1,conn);
cc2 = bwconncomp(bw2,conn);

stats_cc1 = regionprops(cc1, list_props_all);
stats_cc2 = regionprops(cc2, list_props_all);

if verbose
    toc
end
if area_filtering
    if verbose
        disp('Area filering of the connected components...');
    end
    tic
    [bw1_f, index1, ~] = filter_regions(bw1, stats_cc1, prop_types_filter,...
        {}, range1, cc1);
    [bw2_f, index2, ~] = filter_regions(bw2, stats_cc2, prop_types_filter,...
        {}, range2, cc2);
    if verbose
        toc
    end
    if visualize
        if verbose
            disp('Computing the filtered connected components...');
        end
        cc1_f = bwconncomp(bw1_f,conn);
        cc2_f = bwconncomp(bw2_f,conn);
    end
end
%% visualization of the CCs
if visualize
    if area_filtering
        [~,centr_cc1] = show_cc(cc1_f, true, index1, f, subplot(sbp1),'Filtered BIN CCs1');
        [~,centr_cc2] = show_cc(cc2_f, true, index2, f, subplot(sbp2),'Filtered BIN CCs1');
    else
        [~,centr_cc1] = show_cc(cc1, true, [], f, subplot(sbp1),'BIN CCs1');
        [~,centr_cc2] = show_cc(cc2, true, [], f, subplot(sbp2),'BIN CCs2');
    end
end

%% SMI descriptor computaiton
if verbose
    disp('Shape and Moment Invariants (SMI) descriptors computation...');
end
if area_filtering
    bw1_d = bw1_f; bw2_d = bw2_f;
else
    bw1_d = bw1; bw2_d = bw2;
end
cc1_d = bwconncomp(bw1_d, conn); cc2_d = bwconncomp(bw2_d, conn);

tic
[SMI_descr1,~] = ccSMIdescriptor(cc1_d, image_area1, ...
    list_props, order, ...
    coeff_file, max_num_moments);
[SMI_descr2,~] = ccSMIdescriptor(cc2_d, image_area2, ...
    list_props, order, ...
    coeff_file, max_num_moments);

if verbose
    toc
end

%% Matching the SMI descriptors
if verbose
    disp('SMI descriptors matching...');
end
if area_filtering
    ind1 = index1; ind2 = index2;
else
    ind1 = []; ind2 = [];
end
tic
[matched_pairs, cost, matched_ind, num_matches] =...
    matching( SMI_descr1, SMI_descr2, ...
    match_metric, match_thresh, ...
    max_ratio, true, ...
    area_filtering, ind1, ind2);
if verbose
    toc
end

mean_cost = mean(cost);
%if verbose
disp(['Number of matches: ' , num2str(num_matches)])
disp(['Mean matching cost: ', num2str(mean_cost)]);
%end
% check if enough matches
if num_matches < 1
    if verbose
        disp('Zero matches found!');
    end
    disp('NOT THE SAME SCENE!');
    is_same = false; transf_sim = NaN;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
    end
    return;
end

%% Filtering of the matches
if matches_filtering
    if verbose
        disp('Filtering of the matches...');
    end
    tic
    [filt_matched_pairs, filt_matched_ind, ...
        filt_cost, filt_num_matches] = ...
        filter_matches(matched_pairs, matched_ind, cost, cost_thresh);
    if verbose
        toc
    end
    
    if verbose
        disp(['Filtered number of matches: ' , num2str(filt_num_matches)])
        disp(['Filtered mean matching cost: ', num2str(mean(filt_cost))]);
    end
    % check if enough filtered matches
    if filt_num_matches < 1
        if verbose
            disp('Zero strong matches found!');
        end
        disp('NOT THE SAME SCENE!');
        is_same = false; transf_sim = NaN;
        if verbose
            et = etime(clock,t0);
            disp(['Total elapsed time: ' num2str(et)]);
        end
        return;
    end
end
%% visualization of matches
if visualize

    if matches_filtering        
        matchedPoints1 = centr_cc1(filt_matched_ind(:,1));        
        matchedPoints2 = centr_cc2(filt_matched_ind(:,2));
    else
        matchedPoints1 = centr_cc1(matched_ind(:,1));
        matchedPoints2 = centr_cc2(matched_ind(:,2));
    end
    
    % make matched Points a list of centroid locaitons from the struct of
    % centroids
    matchedPoints1 = cat(1,matchedPoints1.Centroid);
    matchedPoints2 = cat(1,matchedPoints2.Centroid);
    
    figure(f); subplot(sbp1_m);
    showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2,...
        'PlotOptions', {'ro','go','y--'});
    legend('points 1','points 2', ...
        'Location', 'best');
    title('Matching 1->2 ');
    figure(f); subplot(sbp2_m);
    showMatchedFeatures(im2,im1,matchedPoints2,matchedPoints1,...
        'PlotOptions', {'ro','go','y--'});
    legend('points 2',' points 1', ...
        'Location', 'best');
    title('Matches 2->1 ');
    
     %figure(f); subplot(sbp1_fm);
    figure;
    showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2, 'montage',...
        'PlotOptions', {'ro','go','y--'});
    legend('points 1','points 2', ...
        'Location', 'best');
    title('Matches 1->2');axis on, grid on;
    %figure(f); subplot(sbp2_fm);
    figure;
    showMatchedFeatures(im2,im1,matchedPoints2,matchedPoints1, 'montage',...
        'PlotOptions', {'ro','go','y--'});
    legend('points 2','points 1', ...
        'Location', 'best');
    title('Matches 2->1');axis on, grid on;
    
end

%% Estimation of affine transformation between the 2 images from the matches
if verbose
    disp('Estimating affine transformation from the matches...');
end

for nsr = 1: num_sim_runs
    
    
    if matches_filtering
        matched_pairs_d = filt_matched_pairs;
    else
        matched_pairs_d = matched_pairs;
    end
    tic
    [tform{nsr},inl1, ~, status] = estimate_affine_tform(matched_pairs_d, ...
        stats_cc1, stats_cc2, max_dist, conf, max_num_trials);
 
    if verbose
        toc
    end
    if verbose
        num_inliers = length(inl1);
        disp(['The transformation has been estimated from ' num2str(num_inliers) ' matches.']);
        
        switch status
            case 0
                disp(['Sucessful transf. estimation!']);
            case 1
                disp('Transformation cannot be estimated due to low number of matches!');
            case 2
                disp('Transformation cannot be estimated!');
        end
    end
    
    %% Compute differences between image and transformed image
    if verbose
        disp('Computing the transformation correlation between the pairs <image, transformed_image>');
    end
    
    % compute the transformaition correlation between the matched regions
    tic
    [correl1, correl2, im1_trans, im2_trans] = transformation_correlation(im1, im2, tform{nsr});
    transf_sim(nsr) = ((correl1 + correl2)/2);
    disp(['Transformation similarity for this run is: ' num2str(transf_sim(nsr))]);
    if verbose
        toc
    end

end

%% final similarity and decision
mean_transf_sim = mean(transf_sim);
disp(['====> Final (mean) transformation similarity  is: ' num2str(mean_transf_sim) ]);

if (mean_transf_sim > transf_sim_thresh)
    disp('THE SAME SCENE!');
    is_same = true;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
    end
else
    disp('NOT THE SAME SCENE!');
    is_same = false;
    if verbose
        et = etime(clock,t0);
        disp(['Total elapsed time: ' num2str(et)]);
    end
end
%% visualization of the transformation distance
if visualize
    ff = figure; set(gcf, 'Position', fig_scrnsz);
    
    figure(ff); subplot(231); imshow(im1o); axis on, grid on, title('Image1');
    figure(ff); subplot(234); imshow(im2o); axis on, grid on, title('Image2');
    
    figure(ff); subplot(232); imshow(im1_trans); axis on, grid on, title('Last Transformed Image1');
    figure(ff); subplot(235); imshow(im2_trans); axis on, grid on, title('Last Transformed Image2');
    
    figure(ff); subplot(233); imshowpair(im1, im2_trans, 'blend'); axis on, grid on, title('Overlay of Image1 and transformed Image2');
    figure(ff); subplot(236); imshowpair(im2, im1_trans, 'blend'); axis on, grid on, title('Overlay of Image2 and transformed Image1');
        
    pause(0.5);
end

end


