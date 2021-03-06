% display_oxford_dataset_structured.m - function to display the affine dataset

%                                       (structured images subset)
%**************************************************************************
% [] = display_oxford_dataset_structured(path, ext)
%
% author: Elena Ranguelova, NLeSc
% date created: 20 Oct 2016
% last modification date: 21 October 2016
% modification details: added parameter extension
%**************************************************************************
% INPUTS:
% data_path        where the dataset is located
% [ext]            optional image filenames extension, {.png}
%**************************************************************************
% OUTPUTS:
%**************************************************************************
% NOTE:  
%**************************************************************************
% EXAMPLES USAGE:
% data_path = 'C:\Projects\eStep\LargeScaleImaging\Data\AffineRegions';
% display_oxford_dataset_structured(data_path);
%% OR
% data_path = 'C:\Projects\eStep\LargeScaleImaging\Results\AffineRegions\';
% ext = '_bin.png';
% display_oxford_dataset_structured(data_path, ext);
%**************************************************************************
% REFERENCES: 
%**************************************************************************
function [] = display_oxford_dataset_structured(path, ext)

%% input control
if nargin < 2
    ext = '.png';
end
if nargin < 1
    error(' display_oxford_dataset_structured: the function expects minimum 1 input argument- the path of the dataset!');
end

%% parameters
test_cases = {'graffiti', 'boat','leuven','bikes'};

%% make the figure
fig_scrnsz = get(0, 'Screensize');
offset = 0.25 * fig_scrnsz(4);
fig_scrnsz(2) = fig_scrnsz(2) + offset;
fig_scrnsz(4) = fig_scrnsz(4) - offset;
f = figure; set(gcf, 'Position', fig_scrnsz);

%% load and display
for i = 1: numel(test_cases)
    test_case = char(test_cases{i});
    test_path = fullfile(path,test_case);
    for j = 1:6
        test_image = fullfile(test_path,[test_case num2str(j) ext]);
        im = imread(test_image);
        figure(f); hold on;
        ind = (i-1)*6 + j;
        subplot(4,6,ind);
        imshow(im);
        title_str = [test_case num2str(j)];
        title(title_str);
    end
end
hold off;


