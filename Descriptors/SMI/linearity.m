function lin = linearity(C, method, res, mode)
% LINEARITY computes the linearity of a given line.
%    LIN = LINEARITY (C, METHOD) Computes the linearity of the given line C
%       using the specified METHOD. C is a P-by-1 cell array whose elements
%       are Q-by-2 matrices of line points in the same format as returned
%       by BWBOUNDARIES. Available methods are:
% 
%          ZM or ZM_NUMERIC    Zunic-Martinez linearity measure by numeric
%                        approximation.
%          ZM_FORMULA    Zunic-Martinez linearity measure computed by closed
%                        formula.
%          TSR           Triangle Sides Ratio method.
% 
%       For further reference of HZ methods refer to paper: "Linearity
%       Measure for Curve Segments", J. Zunic and C. Martinez-Ortiz. 
%    LIN = LINEARITY (C, METHOD, RES) Computes the linearity using RES as
%       the maximum segment size used to subdivide the boundary. This only
%       applies to ZM methods.
%    LIN = LINEARITY (C, METHOD, RES, MODE) If C is a closed curve segment,
%       then MODE indicates which point should be used to 'open' the curve.
%       Possible options are:
% 
%          MIN           Chooses the point with minimum distance to the
%                        centroid, i.e. closest.
%          MAX           Chooses the point with maximum distance to the
%                        centroid, i.e. furthest away. This is the default.
% 
% See also BWBOUNDARIES, LINEARITY_TSR

if nargin<4
    mode = 'max';
end

if strcmpi('ZM',method) || strcmpi('ZM_NUMERIC',method)
    lin = linearity_zm(C,res,'numeric', mode);
elseif strcmpi('ZM_FORMULA',method)
    lin = linearity_zm(C,res,'formula', mode);
elseif strcmpi('TSR',method)
    lin = linearity_tsr(C);
else
    error(['Unknown linearity method: ' method ]);
end

















function lin = linearity_zm(C, res, method, mode)
  % Find the total length of the line
  [ tot_len len ] = boundaryLength(C);

  x = zeros(length(C),1);
  for i=1:length(C)
    x(i,:) = linearity_zm_segment(C{i}, res, len(i), method, mode) * len(i)/tot_len;
  end

  lin = sum(x);

function linearity = linearity_zm_segment(line, res, len, method, mode)
  % If line start point is same as segment end point, it is a closed curve, so...
  % do other procedure.
  if line(1,1)==line(end,1) && line(1,2)==line(end,2)
    linearity = linearity_zm_closed_curve(line, res, len, method, mode);
    return;
  end

  min_adj = res / 10;
  max_ds = len * res;

  int_s0 = 0; % Sum of distances from each point to (x(0), y(0))
  int_s1 = 0; % Sum of distances from each point to (x(1), y(1))

  start_x = line(1,2);
  start_y = line(1,1);

  end_x = line(size(line,1),2);
  end_y = line(size(line,1),1);

  for j=1:size(line,1)-1
    seg_size = sqrt( (line(j+1,1)-line(j,1))^2 + (line(j+1,2)-line(j,2))^2 );
    ds_steps = floor(seg_size / max_ds);

    dx = (line(j+1,2)-line(j,2)) * max_ds / seg_size;
    dy = (line(j+1,1)-line(j,1)) * max_ds / seg_size;

    x1 = line(j,2);
    y1 = line(j,1);

    for k=1:ds_steps
      x2 = x1 + dx;
      y2 = y1 + dy;

      xm = (x1 + x2) / 2;
      ym = (y1 + y2) / 2;

      s_size = sqrt( (x2-x1)^2 + (y2-y1)^2 ) / len;

      ds0 = ((xm-start_x)^2 + (ym-start_y)^2) * s_size/len^2;
      ds1 = ((xm-end_x  )^2 + (ym-end_y  )^2) * s_size/len^2;

      int_s0 = int_s0 + ds0;
      int_s1 = int_s1 + ds1;

      x1 = x2;
      y1 = y2;
    end

    adj_step = seg_size - ds_steps * max_ds;
    if (adj_step>min_adj)
      x2 = line(j+1,2);
      y2 = line(j+1,1);

      xm = (x1 + x2) / 2;
      ym = (y1 + y2) / 2;

      s_size = sqrt( (x2-x1)^2 + (y2-y1)^2 ) / len;

      ds0 = ((xm-start_x)^2 + (ym-start_y)^2) * s_size/len^2;
      ds1 = ((xm-end_x  )^2 + (ym-end_y  )^2) * s_size/len^2;

      int_s0 = int_s0 + ds0;
      int_s1 = int_s1 + ds1;
    end
  end

  linearity = 3/2 * (int_s0 + int_s1);


function linearity = linearity_zm_closed_curve(line, res, len, method, mode)
  if strcmpi(method, 'numeric')
    linearity = linearity_zm_multi_start_point(line, res, len, mode);
  else
    linearity = linearity_zm_formula(line, len, mode);
  end



function linearity = linearity_zm_multi_start_point(line, res, len, mode)
  if length(line) <= 2
      linearity = 0;
      return
  end
  line(end,:) = [];     % Remove last element (because its same as first)
  lins = zeros(size(line,1),1); % pre alocate results
  
  idxs = [ 2:size(line,1) 1 ];
  for i=1:length(lins)
    lins(i) = linearity_zm_segment(line, res, len);

    line = line(idxs,:);    % Move first point to end of list
  end

  if strcmpi(mode, 'min')
      linearity = min(lins);
  else
      linearity = max(lins);
  end

function linearity = linearity_zm_formula(line, len, mode)
    if length(line) <= 2
      linearity = 0;
      return
    end
  line(end,:) = [];     % Remove last element (because its same as first)

  % Find point centroid
  b{1} = line;
  cx = lineMoment(b, 1, 0)/lineMoment(b, 0, 0);
  cy = lineMoment(b, 0, 1)/lineMoment(b, 0, 0);

  % Re-center line
  line = [ line(:,1)-cx line(:,2)-cy ]/len;
  b{1} = line;

  cx = lineMoment(b, 1, 0)/lineMoment(b, 0, 0);
  cy = lineMoment(b, 0, 1)/lineMoment(b, 0, 0);

  % Find point closest/furthest to centroid (squared distance)
  dists = dist2(line, [ cx cy ]);
  
  % Cut at that point, and compute as open curve
  if strcmpi(mode, 'min')
      val = min(dists);
      fprintf(' # Min: %1.4f\n',val);
  else
      val = max(dists);
      fprintf(' # Max: %1.4f\n',val);
  end

  mu20 = lineMoment(b, 2, 0);
  mu02 = lineMoment(b, 0, 2);
  fprintf(' # Moments (mu20+mu02): %1.4f+%1.4f=%1.4f\n', mu20, mu02, mu20+mu02);

  linearity = 3*(mu20 + mu02 + val);
