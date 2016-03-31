function buttondownfcn(p, eventdata, u) % src, eventdata, varargin ...

if isempty(eventdata) || ~isstruct(eventdata)
  eventdata.Key = '';
end % isempty(eventdata) || ~isstruct(eventdata)

% disambiguate
if ~iscell(u)
  setappdata(ancestor(p, 'figure'), 'GridData', u);
else % if iscell(u)
  setappdata(ancestor(p, 'figure'), 'DialData', u{:});
end % if ~iscell(u)
