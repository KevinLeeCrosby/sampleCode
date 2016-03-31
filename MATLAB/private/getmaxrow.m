function [max_row, height] = getmaxrow(panel_ind)

max_rows = [3 3 4 repmat(5, 1, 19)];
max_row = max_rows(panel_ind);
height = 60 / max_row;
