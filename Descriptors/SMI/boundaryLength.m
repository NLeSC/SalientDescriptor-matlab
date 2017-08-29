function [ tot_l len ] = boundaryLength(C)
% BOUNDARYLENGTH  Find the total length of the line.
%    TOT_L = BOUNDARYLENGTH(C) Finds the total length TOT_L of boundary C.
%       C is given in the same format as specified by BWBOUNDARIES.
%    [ TOT_L LEN ] = BOUNDARYLENGTH(C) LEN is and M-by-1 array with the
%       lengths of each one of the M elements in C.
% 
%    See also BWBOUNDARIES

len = zeros(length(C),1);
for i=1:length(C),
    line = C{i};
    for j=1:size(line,1)-1
      len(i) = len(i) + sqrt( (line(j+1,1)-line(j,1))^2 + (line(j+1,2)-line(j,2))^2 );
    end
end
tot_l = sum(len);
