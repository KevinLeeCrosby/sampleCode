function [ns, np, index] = makemajorchange(matrix, os, op, ds, dp)

if ds < 0 || dp < 0
  firstorlast = 'last';
else % if ds >= 0 && dp >= 0
  firstorlast = 'first';
end % if ds < 0 || dp < 0

% get next scan
us = unique(matrix(:, 1));
oss = os;
if all(us ~= oss)
  switch ds
    case -1
      oss = us(find(us < oss, 1, firstorlast));
      if isempty(oss)
        oss = us(end);
      end % if isempty(oss)
    case 0
      switch dp
        case -1
          oss = us(find(us < oss, 1, firstorlast));
          if isempty(oss)
            oss = us(end);
          end % if isempty(oss)
        otherwise
          oss = us(find(us > oss, 1, firstorlast));
          if isempty(oss)
            oss = us(1);
          end % if isempty(oss)
      end % switch dp
    case 1
      oss = us(find(us > oss, 1, firstorlast));
      if isempty(oss)
        oss = us(1);
      end % if isempty(oss)
  end % switch ds
  ns = oss;
else % if any(us == oss)
  ns = us(mod(find(us == oss) + ds - 1, length(us)) + 1);
end % if all(us ~= oss)

% get next panel
up = unique(matrix(matrix(:, 1) == ns, 2));
opp = op;
if all(up ~= opp)
  switch dp
    case -1
      opp = up(find(up < opp, 1, firstorlast));
    otherwise
      opp = up(find(up > opp, 1, firstorlast));
  end % switch dp
  if isempty(opp)
    dss = dp;
    switch dss
      case -1
        opp = up(end);
      otherwise
        opp = up(1);
    end % switch dss
  else % isempty(opp)
    dss = 0;
  end % isempty(opp)
else % if any(up == opp)
  dss = div(find(up == opp) + dp - 1, length(up));
end % if all(up ~= opp)

if dss
  ns = us(mod(find(us == oss) + dss - 1, length(us)) + 1);
  up = unique(matrix(matrix(:, 1) == ns, 2));
  switch dss
    case -1
      np = up(end);
    case 1
      np = up(1);
  end % switch dss
else % if ~dss
  dpp = dp*(op == opp);
  np = up(mod(find(up == opp) + dpp - 1, length(up)) + 1);
end % if dss

% get index
index = find(matrix(:, 1) == ns);
sub_index = find(matrix(index, 2) == np, 1, firstorlast);
index = index(sub_index);
