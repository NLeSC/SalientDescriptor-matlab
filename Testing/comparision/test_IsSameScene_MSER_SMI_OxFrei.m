% test_IsSameScene_MSER_SMI_OxFrei- testing IsSameScene_MSER_SMI for comparision if 2
%                   images are of the same scene for the OxFrei dataset
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 21-04-2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 
% modification details: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************
% REFERENCES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parameters

[ exec_flags, exec_params, moments_params, cc_params, ...
    match_params, vis_params, paths] = config(mfilename, 'oxfrei');

v2struct(exec_flags)
v2struct(paths)
v2struct(exec_params)

tic

%% initializations
is_same_all = zeros(data_size, data_size);
mean_costs = zeros(data_size, data_size);
transf_sims = zeros(data_size, data_size);
%% header
disp('*******************************************************************************************');
disp('  Demo: are all pairs of OxFrei images of the same scene (MSER detector + SMI descriptor)? ');
disp('*******************************************************************************************');


%% visualize the test dataset
if visualize_dataset
    if verbose
        disp('Displaying the test dataset...');
    end
    display_oxfrei_dataset(data_path_or);
    pause(5);
end

%% loop over all test data
test_cases = {'01_graffiti','02_freiburg_center', '03_freiburg_from_munster_crop',...
    '04_freiburg_innenstadt','05_cool_car', '06_freiburg_munster',...
    '07_graffiti','08_hall', '09_small_palace'};
%test_cases = {'01_graffiti'};
r = 0;
for i = 1: numel(test_cases)
    test_case1 = char(test_cases{i});
    test_path1 = fullfile(data_path_or, test_case1, 'PNG');
    image_fnames1 = dir(fullfile(test_path1,'*.png'));
    
    for ind1 = 1: numel(image_fnames1)
        r  = r + 1;
        disp('*****************************************************************');
        test_image1 = image_fnames1(ind1).name;
        [~,name1,~] = fileparts(test_image1);
        YLabels{r} = strcat(test_case1, num2str(ind1), ': ', name1, ': ', num2str(r));
        disp(YLabels{r});
        
        im1 = imread(fullfile(test_path1, test_image1));
       
        c = 0;
        for j = 1: numel(test_cases)
            test_case2 = char(test_cases{j});
            test_path2 = fullfile(data_path_or, test_case2, 'PNG');
            image_fnames2 = dir(fullfile(test_path2,'*.png'));
            
            for ind2 = 1:numel(image_fnames2)
                c  = c+1;
                %disp('----------------------------------------------------------------');
                test_image2 = image_fnames2(ind2).name;
                im2 = imread(fullfile(test_path2, test_image2));
                
                %% compare if the 2 images show the same scene
                if r >= c
                    [is_same, num_matches, mean_cost, transf_sim] = IsSameScene_MSER_SMI(im1, im2,...
                        moments_params, cc_params, match_params, vis_params, exec_params);
                    is_same_all(r,c) = is_same;
                    mean_costs(r,c) = mean_cost;
                    transf_sims(r,c) = transf_sim;                
                end
                
            end
        end
    end
end

%% fill up the remaning elements of the matricies
for r = 1: data_size
    for c =1: data_size
        if r < c            
            is_same_all(r,c) = is_same_all(c,r);
            mean_costs(r,c) = mean_costs(c,r);
            transf_sims(r,c) = transf_sims(c,r);
        end
    end
end
%% visualize
if visualize_final
    gcmap = colormap(gray(256)); close;
    hcmap = colormap(hot); close;
    jcmap = colormap(jet); close;
    f1 = format_figure(is_same_all, 21, gcmap, ...
        [0 1], {'False','True'}, ...
        'Is the same scene? All pairs of OxFrei dataset.',...
        YLabels, tick_step);
    f2 = format_figure(mean_costs, 21,jcmap, ...
        [], [], ...
        'Mean matching cost of all matches. All pairs of OxFrei dataset.',...
        YLabels, tick_step);
    f3 = format_figure(transf_sims, 21, hcmap, ...
        [], [], ...
        'Transformation between matches similarity. All pairs of OxFrei dataset.',...
        YLabels, tick_step );
end

toc

%% save
if sav
   save(sav_fname, 'is_same_all', 'mean_costs', ...
       'transf_sims','YLabels', 'match_params', 'exec_params'); 
end
%% footer
if verbose
    disp('************************   DONE.  ********************************');
end