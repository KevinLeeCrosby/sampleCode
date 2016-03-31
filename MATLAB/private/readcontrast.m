function varargout = readcontrast(c, varargin)

varargout = cell(1, (nargin-1)/2);

for i = 1:2:nargin-1
  j = (i + 1) /2;
  varargout{j} = tagget(c, varargin{i:i+1});
end % for i
