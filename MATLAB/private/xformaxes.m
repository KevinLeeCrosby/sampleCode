function [ax, angle_ind, angle] = xformaxes(ax, angle_ind, da, increment, m, n)

angles = 0:increment:360-increment;
no_angles = length(angles);

% ensure in range
angle_ind = mod(angle_ind - 1, no_angles) + 1;
da = mod(da, no_angles);

% get old image center based on image size for transformation
switch angle_ind
  case {1, 5} % 0° or 180°
    [x0, y0] = deal(n/2, m/2);
  case {2, 4, 6, 8} % 45°, 135°, 225°, or 315°
    [x0, y0] = deal((ceil(sqrt(2)*(m+n)/2)+1)/2);
  case {3, 7} % 90° or 270°
    [x0, y0] = deal(m/2, n/2);
end % switch angle_ind

angle_ind = mod(angle_ind + da - 1, no_angles) + 1;
angle = angles(angle_ind); % CCW

% get new image center based on image size for transformation
switch angle_ind
  case {1, 5} % 0° or 180°
    [x1, y1] = deal(n/2, m/2);
  case {2, 4, 6, 8} % 45°, 135°, 225°, or 315°
    [x1, y1] = deal((ceil(sqrt(2)*(m+n)/2)+1)/2);
  case {3, 7} % 90° or 270°
    [x1, y1] = deal(m/2, n/2);
end % switch angle_ind

% get new image center based on axes size
r = reshape(ax-.5, 2, 2);
p = [mean(r) 0]'; % get old image center based on axes
R = hcrotz(deg2rad(da*increment));
T0 = htrans(-[x0 y0 0]');
T1 = htrans(+[x1 y1 0]');
H = T1*R*T0; % homogeneous transformation
p = transform(H, p); % new image center based on axes

[xc, yc] = split(p);
[w2, h2] = split(diff(r)/2);

ax = [xc xc yc yc] + [-w2 w2 -h2 h2] + .5;
