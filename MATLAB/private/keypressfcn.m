function keypressfcn(src, eventdata) % src, eventdata, varargin

if exist('eventdata', 'var') % suppress editor warnings
  eventdata.key = '';
end % if exist('eventdata', 'var')

set(src, 'UserData', get(src, {'CurrentKey', 'CurrentCharacter', 'CurrentModifier'}));

% had trouble getting the following to work as KeyReleaseFcn:
%set(src, 'UserData', {eventdata.Key, eventdata.Character, eventdata.Modifier});
