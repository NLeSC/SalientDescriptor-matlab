% test_scale_moment_invariant.m- script for testing scale moment invariant computation
%**************************************************************************
% author: Elena Ranguelova, NLeSc
% date created: 2-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modification date: 4-08-2016
% modification details: using pure scaling transformation for testing
%                       visualizing the moments for all regions
%                       interactive input of the moment orders
% last modification date: 3-08-2016
% modification details: tetsing scale invariants on a scaled image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTE:
%**************************************************************************

%% define some parameters
% execution parameters
verbose = 0;
vis = 1;

% CCes and properties
conn = 8;
list_properties = {'Centroid', 'Area', 'PixelList'};

% moments
u = input('Enter the first moment order [1 2 3]: ');
v = input('Enter the second moment order [0 1 2]: ');

%% load a simple binary test image
if verbose
    disp('Loading a binary test image and transform it...');
end

bw = imread('Binary_islands.png');
bw = logical(bw);
% define scaline matrix 
H = [2 0 0; 0 2 0; 0 0 1];
%  obtain a transformed image
bwtr = applyAffineTransform(bw, H', 0);
bwtr = logical(bwtr);

% visualise
if vis
    f = figure; subplot(221);imshow(bw); title('Binary'); axis on, grid on;
    subplot(222);imshow(bwtr); title('Binary (scaled)'); axis on, grid on;
end


% obtain connected components
if verbose
    disp('Obtain the connected components...');
end
[regions_properties, conn_comp] = compute_region_props(bw, conn, list_properties);
[regions_properties_tr, conn_comp_tr] = compute_region_props(bwtr, conn, list_properties);

% visualise
if vis
    cc = bwconncomp(bw);
    labeled = labelmatrix(cc);
    RGB_label = label2rgb(labeled);
    figure(f); subplot(223);imshow(RGB_label); title('Connected Components'); axis on, grid on;
    cc_tr = bwconncomp(bwtr);
    labeled = labelmatrix(cc_tr);
    RGB_label = label2rgb(labeled);
    subplot(224);imshow(RGB_label); title('Connected Components - scaled'); axis on, grid on;
end

%% compute scale moments invariants of all CCs

num_regions = length(cat(1,regions_properties.Area));
moment_invariant = zeros(1, num_regions);

for region_idx = 1: num_regions
   
    
    if verbose
        disp('Processing region #: '); disp(region_idx);
    end
    pixel_list = regions_properties(region_idx).PixelList;
    centroid = regions_properties(region_idx).Centroid;
    area = regions_properties(region_idx).Area;
    
    if verbose
        disp('Compute the scale moment...');
    end
    
    [moment_invariant(region_idx)] = scale_moment_invariant(u, v, pixel_list, ...
        centroid, area);
    if verbose
        disp('Scale moment invariant: '); disp(moment_invariant);
    end
end

num_regions_tr = length(cat(1,regions_properties_tr.Area));
moment_invariant_tr = zeros(1, num_regions_tr);

for region_idx_tr = 1: num_regions_tr
    
    if verbose
        disp('Processing region #: '); disp(region_idx_tr);
    end
    pixel_list = regions_properties_tr(region_idx_tr).PixelList;
    centroid = regions_properties_tr(region_idx_tr).Centroid;
    area = regions_properties_tr(region_idx_tr).Area;
    
    if verbose
        disp('Compute the scale moment...');
    end
    
    [moment_invariant_tr(region_idx_tr)] = scale_moment_invariant(u, v, pixel_list, ...
        centroid, area);
    if verbose
        disp('Scale moment invariant (transf.): '); disp(moment_invariant_tr);
    end
    
end

%% visualize the moments as features
if vis
     figure; plot(1:num_regions, moment_invariant, 'r-', 1:num_regions_tr, moment_invariant_tr, 'b-');
     legend('original', 'scaled');
     title(['Moment invariants for the 2D binary shape of order: (',num2str(u), ',',num2str(v),')']);
     axis on; grid on;
end
