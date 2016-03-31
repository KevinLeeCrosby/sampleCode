function [c, OutliersEditCallback, MinMaxEditCallback] = ...
  opencontrast(ax, AdjustContrastPosition, AdjustContrastVisible, ...
  OutliersEditString, MDRRadioButtonValue, EORadioButtonValue)

figure(ancestor(ax, 'figure'));
zoom off, pan off % to avoid IMCONTRAST crashing under these modes
c = imcontrast(ax);

% replace close request function to hide instead
ttl = cellstr(get(get(ax, 'Title'), 'String')); % to handle newlines
ttl = strtrim(sprintf('%s\n', ttl{:}));
name = sprintf('Adjust Contrast "%s"', ttl);
set(c, 'Tag', 'this', 'Visible', 'off', 'Name', name, ...
  'KeyPressFcn', @keypressfcn, ...
  'Units', 'normalized', 'Position', AdjustContrastPosition, ...
  'CloseRequest', 'set(gcbo, ''Visible'', ''off'')');

% hide and disable adjust data button
tagset(c, 'adjust data button', 'Enable', 'off', 'Visible', 'off'); % disable for MATLAB 7.5 and later

% change status text
tagset(c, 'status text', 'String', {'Adjust the histogram above.',  'Be sure to thank Kevin for such a wonderful program.'});

% disable menu items
set(findall(c, 'type', 'uimenu'), 'Enable', 'off');

% implement contrast stretching
OutliersEditCallback = tagget(c, 'outlier percent edit', 'Callback');
MinMaxEditCallback = tagget(c, 'window min edit', 'Callback');
writecontrast(c, 'outlier percent edit', 'String', OutliersEditString, ...
  'match data range radio', 'Value', MDRRadioButtonValue, ...
  'eliminate outliers radio', 'Value', EORadioButtonValue);
OutliersEditCallback(); % same as Apply pushbutton
PTLError = findall(0, 'Name', 'Percentage Too Large');
CEOError = findall(0, 'Name', 'Cannot Eliminate Outliers');
if ishandle(PTLError)
  OutliersEditString = '2';
  writecontrast(c, 'outlier percent edit', 'String', OutliersEditString);
  OutliersEditCallback(); % same as Apply pushbutton
end % if ishandle(PTLError)
delete([PTLError CEOError]);
waitfor([PTLError CEOError]);

% unhide, if necessary
set(c, 'Visible', AdjustContrastVisible);

% put on top, if visible
putontop(c);
