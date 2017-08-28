function lin = linearity_tsr(C)
% LINEARITY_TSR  Estimate linearity of a curve by Triangle Sides Ratio
%    method.
%    LIN = LINEARITY_TSR(C) Computes the linearity of the given line C
%       C is a P-by-1 cell array whose elements are Q-by-2 matrices of line
%       points in the same format as returned by BWBOUNDARIES.
% 
%       For further reference of HZ methods refer to paper: "Measuring
%       Linearity of Ordered Point Sets", M. Stojmenovic and A. Nayak
% 
%    See also LINEARITY



  len = zeros(length(C),1);
  for i=1:length(C),
    line = C{i};
    for j=1:size(line,1)-1
      len(i) = len(i) + sqrt( (line(j+1,1)-line(j,1))^2 + (line(j+1,2)-line(j,2))^2 );
    end
  end
  tot_len = sum(len);

  x = zeros(length(C),1);
  for i=1:length(C)
    x(i) = linearity_tsr_segment(C{i}) * len(i)/tot_len;
  end

  lin = sum(x);

function linearity = linearity_tsr_segment(line)
  if(size(line,1)<=2)
     linearity = 1;
     return
  end

  k = 20;  % number of triplets to be taken
  lin = zeros(k,1);

  % K ordered pairs
  for i=1:k
    idx_a = 1 + floor((size(line,1)-2)*rand);
    idx_b = (1 + idx_a) + floor((size(line,1)-(1+idx_a))*rand);
    idx_c = (1 + idx_b) + floor((size(line,1)-(idx_b))*rand);

    a = [ line(idx_a,2), line(idx_a,1) ];
    b = [ line(idx_b,2), line(idx_b,1) ];
    c = [ line(idx_c,2), line(idx_c,1) ];

    ab = sqrt(sum((b-a).^2));
    bc = sqrt(sum((c-b).^2));
    ac = sqrt(sum((c-a).^2));

    lin(i) = ac / (ab + bc);
  end

  if(size(line,1)-2==0)
    linearity = 0;
  else
    linearity = mean(lin);
  end
