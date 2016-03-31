function sparkle(h)

[m, n] = size(h);
switch m
  case 1
    no_times = 8;
    no_colors = 14;
  otherwise
    no_times = 2;
    no_colors = 10;
end % switch m

% define colors
colors = hsv(no_colors);
white = ones(1, 3);
black = zeros(1, 3);
indices = zeros(1, m*n); % color indices

ok = 0;
while ok < m*n && ~exist('old_color', 'var')
  ok = ok + 1;
  if h(ok) % i.e. if valid handle
    color = get(h(ok), 'FaceColor');
    if ~exist('old_color', 'var') && any(color ~= white)
      old_color = color;
    end % if ~exist('old_color', 'var') && any(color ~= white)
  end % if h(ok)
end % while ok <= m*n && ~exist('old_color', 'var')

set(h(ok), 'FaceColor', black);
drawnow('expose');

for t = 1:no_times
  deck = randperm(m*n);

  for k = deck
    if m == 1 % i.e. nose cap
      switch k
        case num2cell(1:12)
          neighbors = [k mod(k-1-1,12)+1 mod(k-1+1,12)+1 k+12];
        case num2cell(13:24)
          neighbors = [k k-12 mod(k-13-1,12)+13 mod(k-13+1,12)+13 n];
        case n
          neighbors = [k 13:24];
        otherwise
          disp('You stumped me!');
      end % switch k

    else % if m ~= 1 % i.e. wing
      [i, j] = ind2sub([m n], k);
      mneighbors = [i-1 j-1; i-1 j; i-1 j+1; i j-1; i j; i j+1; i+1 j-1; i+1 j; i+1 j+1];
      mneighbors(mneighbors(:, 1) < 1 | mneighbors(:, 1) >  m, :) = [];
      mneighbors(mneighbors(:, 2) < 1 | mneighbors(:, 2) >  n, :) = [];
      no_mneighbors = size(mneighbors, 1);
      neighbors = zeros(1, no_mneighbors);
      for r = 1:no_mneighbors
        neighbors(r) = sub2ind([m n], mneighbors(r, 1), mneighbors(r, 2));
      end % for r
    end % if m == 1

    no_neighbors = length(neighbors);
    old_choices = zeros(1, no_neighbors);

    for r = 1:no_neighbors
      old_choices(r) = indices(neighbors(r));
    end % for r
    choices = setdiff(1:no_colors, old_choices);
    no_choices = length(choices);
    cindex = ceil(no_choices * rand);
    indices(k) = choices(cindex);

    if h(k) && k ~= ok
      set(h(k), 'FaceColor', colors(indices(k), :));
    end % if h(k) && k ~= ok
    drawnow('expose');
  end % for k
end % for t

deck = randperm(m*n);

for k = deck
  if h(k) && k ~= ok
    set(h(k), 'FaceColor', white);
  end % if h(k) && k ~= ok
  drawnow('expose');
end % for k
set(h(ok), 'FaceColor', old_color);
