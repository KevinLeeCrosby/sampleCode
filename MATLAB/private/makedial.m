function [d, t] = makedial(increment)

radius = 1;

angles = 0:increment:360-increment;
no_angles = length(angles);

[d, t] = deal(zeros(1, no_angles));

for angle_ind = 1:no_angles
  angle = angles(angle_ind);
  [x, y] = makeslice(radius, angle, increment);
  d(angle_ind) = patch(x, y, 'w', 'ButtonDownFcn', {@buttondownfcn, {angle_ind}});
  t(angle_ind) = text(radius*1.3*cosd(angle), radius*1.3*sind(angle), ...
    [num2str(angle), '°'], 'HorizontalAlignment', 'center');
end
axis equal % no image here
axis off
