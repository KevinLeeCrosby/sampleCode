function writecontrast(c, varargin)

for i = 1:3:nargin-1
  tagset(c, varargin{i:i+2});
end % for i
