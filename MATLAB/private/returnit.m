function returnit(src, eventdata, monitor) % src, eventdata, varargin

if ~isempty(src) % suppress editor complaints
  clear src
end % if ~isempty(src)

if ~isempty(eventdata) % suppress editor complaints
  clear eventdata
end % if ~isempty(eventdata)

warn_handle = warndlg('Please return with "enter" or "return"!', 'What''s a matta you!', 'modal');
set(warn_handle, 'Units', 'normalized');
position = get(warn_handle, 'OuterPosition'); position(1) = .41625;
set(warn_handle, 'OuterPosition', position);
switch monitor
  case 'left'
    putonleft(warn_handle);
  case 'right'
    putonright(warn_handle);
  case 'same'
    %putonsame(warn_handle, gcf); % PUTONSAME needs fixing
    putonleft(warn_handle);
end % switch monitor
waitfor(warn_handle);
