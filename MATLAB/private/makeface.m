function [x, y] = makeface(i, j, m, n)
% i, j is upper left corner
% m, n is height and width
x = [i i i+n i+n i]';
y = [j j-m j-m j j]';
