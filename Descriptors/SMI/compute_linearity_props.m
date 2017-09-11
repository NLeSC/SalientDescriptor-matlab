% compute_linearity_prop.m- computing linearity property from salient binary masks
%**************************************************************************
% [linearity_props] = compute_linearity_prop(saliency_masks)
%
% author: Elena Ranguelova, NLeSc
% date created: 29 Aug 2017
% last modification date: 
% modification details: 
%**************************************************************************
% INPUTS:
% saliency_masks  the binary masks of the extracted salient regions
%**************************************************************************
% OUTPUTS:
% linearity_prop  structure with all regions linearity property. 
%**************************************************************************
% EXAMPLES USAGE:
% a = rgb2gray(imread('circlesBrightDark.png'));
% bw = a < 100;
% imshow(bw); title('Image with Circles'); axis on, grid on;
% [linearity_properties] = compute_linearity_props(bw)
%**************************************************************************
% REFERENCES:
%**************************************************************************
function [linearity_props] = compute_linearity_props(saliency_masks)

%**************************************************************************
% input control
%--------------------------------------------------------------------------
if nargin < 1
    error('compute_linearity_prop.m requires at least 1 input argument!');
    linearity_props = [];   
    return
end

%**************************************************************************
% input parameters -> variables
%--------------------------------------------------------------------------
% how many types of regions?
if ndims(saliency_masks) == 3
    sal_types = size(saliency_masks,3);
    simple_binary = false;
else
    simple_binary = true;
end

%**************************************************************************
% initialisations
%--------------------------------------------------------------------------
linearity_props =  struct([]);

%**************************************************************************
% computations
%--------------------------------------------------------------------------
j = 0;
if simple_binary
    bw = saliency_masks;
%    B = bwboundaries(bw);
    linearity_props = compute_linearity_many(bw);
%     for k = 1:length(B)
%         b =  {B{k}};
%         linearity_prop.Linearity{k} = linearity(b,'ZM',0.01);
%     end
else    
    if sal_types > 0
        j = j+ 1;
        bw = saliency_masks(:,:,j);
        % add here linearity computation
        linearity_props = compute_linearity_many(bw);
    end
    for s = 1: sal_types - 1
        j = j+ 1;
        bw = saliency_masks(:,:,j);
        % add here linearity computation
        new_props = compute_linearity_many(bw);
        linearity_props = append_props(linearity_props, new_props); 
    end
end

%**************************************************************************
% nested functions
%--------------------------------------------------------------------------
    function lin = compute_linearity_many(bw)
        boundaries = bwboundaries(bw);
        for k = 1:length(boundaries)
            b =  {boundaries{k}};
            lin(k).Linearity = linearity(b,'ZM',0.01);
        end
    end

    function appended_props = append_props(old_props, new_props)
            appended_props = [old_props new_props];            
    end

end


