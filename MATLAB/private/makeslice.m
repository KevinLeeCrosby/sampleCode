function [x, y] = makeslice(r, t, increment)

ccw = t + increment/2;
cw  = t - increment/2;

x = [0 r*cosd(cw:ccw) 0];
y = [0 r*sind(cw:ccw) 0];
