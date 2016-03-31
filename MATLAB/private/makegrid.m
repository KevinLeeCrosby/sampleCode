function h = makegrid(zone_ind, grid_arg)

switch zone_ind
  case {1, 2}
    panels = grid_arg;
    no_panels = length(panels);
    
    h = zeros(5, no_panels);  % matrix of handles

    n = 12; % width of squares

    for panel_ind = 1:no_panels
      i = (panel_ind-1) * n;
      [max_row, m] = getmaxrow(panel_ind);
      for row_ind = 1:max_row;
        j = -(row_ind-1) * m;
        [x, y] = makeface(i, j, m, n);
        u = [row_ind, panel_ind];
        h(row_ind, panel_ind) = patch(x, y, 'w', 'ButtonDownFcn', ...
          {@buttondownfcn, u});
      end % for row_ind
      if panel_ind < 10
        k = 4; % Port
      else
        k = 2; % Port
      end
      if zone_ind == 2 % Starboard side
        k = n - k; % Stbd
      end
      string = num2str(panel_ind);
      text(i+k, 5, string);
    end % for panel_ind

    switch zone_ind
      case 1 % Port side
        set(gca, 'XDir', 'normal');
      case 2 % Starboard side
        set(gca, 'XDir', 'reverse'); % flip x-axis
    end
  case 3
    nose_suffixes = grid_arg;
    radius = 1;
    inc = 30;

    %thetas = 0:inc:360-inc;
    thetas = [90-inc:-inc:0 360-inc:-inc:90]; % to match clock face
    no_thetas = length(thetas);

    h = zeros(1, 2*no_thetas+1); % thetas plus center

    [xc, yc] = deal(zeros(1, 2*no_thetas));
    for theta_ind = 1:no_thetas
      theta = thetas(theta_ind);
      ccw = theta + inc/2;
      cw  = theta - inc/2;
      xo = [5*radius*cosd(ccw:-1:cw) 3*radius*cosd(cw:ccw)];
      yo = [5*radius*sind(ccw:-1:cw) 3*radius*sind(cw:ccw)];
      xi = [3*radius*cosd(ccw:-1:cw) radius*cosd(cw:ccw)];
      yi = [3*radius*sind(ccw:-1:cw) radius*sind(cw:ccw)];
      xc(2*theta_ind - 1:2*theta_ind) = [xi(end) xi(end - 1)];
      yc(2*theta_ind - 1:2*theta_ind) = [yi(end) yi(end - 1)];
      u = theta_ind;
      h(theta_ind) = patch(xo, yo, 'w', 'ButtonDownFcn',  ...
        {@buttondownfcn, u});
      if isempty(nose_suffixes{theta_ind})
        text(radius*4*cosd(theta), radius*4*sind(theta), '×', ...
          'HorizontalAlignment', 'center', 'FontSize', 18);
      end % if isempty(nose_suffixes{theta_ind})
      u = theta_ind + no_thetas;
      h(theta_ind+no_thetas) = patch(xi, yi, 'w', 'ButtonDownFcn',  ...
        {@buttondownfcn, u});
      if isempty(nose_suffixes{theta_ind+no_thetas})
        text(radius*2*cosd(theta), radius*2*sind(theta), '×', ...
          'HorizontalAlignment', 'center', 'FontSize', 14);
      end % if isempty(nose_suffixes{theta_ind+no_thetas})
    end
    u = 2*no_thetas + 1;
    h(end) = patch(xc, yc, 'w', 'ButtonDownFcn', {@buttondownfcn, u});
    if isempty(nose_suffixes{end})
      text(0, 0, '×', 'HorizontalAlignment', 'center', 'FontSize', 18);
    end % if isempty(nose_suffixes{end})

    set(gca, 'XDir', 'normal'); % ensure axis flipped correctly
end % switch zone_ind
axis equal % no image here
axis off
