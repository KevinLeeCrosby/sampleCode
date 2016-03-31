function flag = buttondownfilter(obj, event_obj) % obj, event_obj

% allows buttondownfcn to be executed under zoom and pan

if isempty(event_obj) % suppress editor warnings
  clear event_obj
end % if isempty(event_obj)

% only zoom or pan on images, otherwise execute buttondownfcn
flag = ~strcmp(get(obj, 'Type'), 'image');
