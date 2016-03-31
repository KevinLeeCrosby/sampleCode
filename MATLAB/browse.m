function browse(varargin)

%BROWSE Browse TIFFs or BMPs for Orbiter Wing Leading Edge and Nose Cap.
%   BROWSE will browse through a sequence of TIFFs or BMPs in the user
%   specified PhotoDB directory for early or late inspection.  If no
%   directory is provided, then the user will be prompted.  Menus are
%   included.  See accompanying documentation.
%
%   BROWSE(DIR) will start browsing the PhotoDB database in the directory
%   DIR.
%
%   BLINK(..., '-s') will allow users (typically screeners) to add regions 
%   of interest into the PhotoDB directory.
%
%   Example
%   -------
%       browse T:\PhotoDB-RCC
%
%   Notes
%   -----
%       The mouse cursor must be in one of the figures for the program to
%       accept keystrokes.
%
%       BROWSE cannot open UNC paths in Photoshop.
%
%   See also BLINK, BASELINE, WAITFORBUTTONPRESS, GRID.
%
%   Version 7.5 Kevin Crosby

% DATE      VER  NAME          DESCRIPTION
% 10-11-05  1.0  K. Crosby     First Release.
% 12-09-05  2.0  K. Crosby     Added grid overlay capabilities.
% 12-09-05  2.1  K. Crosby     Added ability to translate grid.
% 12-12-05  2.2  K. Crosby     Allowed toggle between actual and edited
%                              images.
% 12-13-05  2.3  M. Rollins    Changed tempdir to pwd prior to image
%                              editing.
% 12-14-05  2.4  K. Crosby     Put menu on figure.
% 12-18-05  2.5  K. Crosby     Ignored existing '_alt' files from directory
%                              listing; prompt for overwriting existing
%                              '_alt' files.
% 02-08-06  2.6  K. Crosby     Added ability to store and manipulate axes,
%                              for 'blink' comparison.  Fixed # of files.
% 02-15-06  2.7  K. Crosby     Added ability to average and move images.
% 03-16-06  3.0  K. Crosby     Renamed to BROWSE.  Added BMP browsing.
%                              Added refresh key.
% 03-29-06  3.1  K. Crosby     Swapped arrows and left, right, up, down.
% 06-08-06  3.2  K. Crosby     Moved edited file to temp directory.
% 06-16-06  3.3  K. Crosby     Gave user control over when to contrast
%                              stretch image.
% 11-07-06  3.4  K. Crosby     Parse directory for 'Late', and put in
%                              title.
% 11-09-06  3.5  K. Crosby     Removed legacy code.  Prompt for directory.
%                              Made grid size adjustable.
% 02-26-07  4.0  K. Crosby     Endowed with knowledge of directory
%                              structure if provided a PhotoDB directory.
%                              Removed alternate feature.  Expanded menu
%                              choices.  Removed handling of '_alt' files.
%                              Temporary amnesia toward handling
%                              non-PhotoDB directories to be fixed later.
%                              Added 'zigzag' feature for dir listing.
% 05-03-07  5.0  K. Crosby     Fixed bug with initial pulldown menu.
%                              Automatically position window.  Added
%                              different sensors.  Added ability to 'diff'
%                              for LDRI sensor.  Removed references to
%                              colormap.  Improved transition between
%                              zones, scans, and panels.
% 05-21-07  5.1  K. Crosby     Added warning for close request function.
%                              Added file renaming for non-LDRI sensors.
%                              Fixed monitor positions.  Removed 'Scan6'.
% 06-07-07  5.2  K. Crosby     Tried to fix memory leak by deleting
%                              IMCONTRAST handle properly.
% 06-18-07  5.3  K. Crosby     Remember 'isvisible' property.  Made scan
%                              and panel changes more robust, so can handle
%                              nose cap and missing scans and panels.
% 06-20-07  5.4  K. Crosby     Fixed bug with refresh.
% 07-18-07  5.5  K. Crosby     Made dialog boxes always on top.  Changed
%                              'isvisible' to 'AdjustContrastVisible'.
%                              Put figure and contrast tools in functions.
% 07-23-07  5.6  K. Crosby     Made titles bold.  Made figure name reflect
%                              mission.  Changed lifespan to 100.
% 08-01-07  5.7  K. Crosby     Check existence of PhotoDB directory.
%                              Preserve original size of IMCONTRAST, and
%                              center.  Suppress warnings for NaNs.
% 08-02-07  5.8  K. Crosby     Added timestamp checking for annotated
%                              files.  Added verbose figure
%                              CloseRequestFcn.
% 08-13-07  5.9  K. Crosby     Turned zoom and pan off before new image is
%                              displayed to avoid IMCONTRAST crashing
%                              program.  Added backup annotated images.
% 08-21-07  5.10 K. Crosby     Added base path to directory variable.
%                              Added maximize to Photoshop call.  Changed
%                              'yuck.bmp' to 'yuck.gif'.
% 09-05-07  6.0  K. Crosby     Made image file parsing more robust.
% 09-25-07  6.1  K. Crosby     Changed code to handle NaNs in LDRI images.
%                              Made IMCONTRAST routine compatible with
%                              MATLAB 7.5.
% 10-29-07  6.2  K. Crosby     Changed edit feature to only add ROI files
%                              from 4 workstations.  Added workaround for
%                              IMCONTRAST and IMADJUST failure.
% 11-01-07  6.3  K. Crosby     Added CTVC capabilities, and changed Level 1
%                              handling for all sensors.  Level 2 handling
%                              made same for all sensors.
% 11-23-07  6.4  K. Crosby     Fixed left and right brackets for nose cap.
% 11-30-07  6.5  K. Crosby     Made nose cap zigzag according to desired
%                              screening order.
% 02-05-08  6.6  K. Crosby     Added option for Screeners vs. LESS with
%                              respect to editting, not based on computer.
%                              removed CD calls.
% 04-01-08  6.7  K. Crosby     Made key presses work on IMCONTRAST tool.
% 04-28-08  6.8  K. Crosby     Fixed editting bug with L1 imagery to allow
%                              the user to provide the associated panel if
%                              not specified.
% 05-01-08  6.9  K. Crosby     Added Level 1 RPM capability.
% 05-02-08  7.0  K. Crosby     Keep color bands, and temporarily convert to
%                              grayscale to contrast stretch.  Remember
%                              axes settings.
% 05-06-08  7.1  K. Crosby     Added "PanelXX" to annotated L1 images.
%                              Allow left and right brackets to jump 30
%                              images for L1.  Added 'home' to zoom out.
% 05-30-08  7.2  K. Crosby     Fixed leading zero and sorting problem with
%                              L1 imagery.
% 06-16-08  7.3  K. Crosby     Converted common subfunctions into
%                              individual private functions.  Fixed mouse
%                              cursor appearance when key is pressed under
%                              zoom or pan.
% 11-17-08  7.4  K. Crosby     Disabled pan right-clicking.  Fixed LDRI tif
%                              errors occuring on some older missions.
% 12-01-08  7.5  K. Crosby     Allow for Nose Cap segment 89 to exist to
%                              prevent crashing.


% display note
disp(' ');
disp('Note');
disp('----');
disp('  The mouse cursor must be in one of the figures for the program to');
disp('  accept keystrokes.');
disp(' ');

% capitalize this filename
this = mfilename;
this(1) = upper(this(1));

% parse command line
switch nargin
  case 0
    directory = '';
    isscreener = false;
  case 1
    if strcmp(varargin{1}, '-s')
      isscreener = true;
      directory = '';
    else % if ~strcmp(varargin{1}, '-s')
      isscreener = false;
      directory = varargin{1};
    end % if strcmp(varargin{1}, '-s')
  case 2
    m = strmatch('-s', varargin, 'exact');
    if ~isempty(m)
      isscreener = true;
      directory = varargin{3 - m};
    else % if isempty(m)
      error('Too many directories specified!');
    end % if ~isempty(m)
  otherwise
    error('Too many arguments to "%s" passed!', mfilename);
end % switch nargin

% parse input directory
if ~exist('directory', 'var') || isempty(directory)
  directory = uigetdir(pwd, 'Choose PhotoDB directory');
end % if ~exist('directory', 'var') || isempty(directory)

% check for good PhotoDB directory
if ~directory, directory = ''; end % cause to fail
directory = regexprep(directory, '\\$', ''); % strip trailing file sep.
[basedir, taildir] = fileparts(directory);
isabsolute = ~isempty(find(basedir == ':', 1)) || ~isempty(strfind(basedir, '\\'));
isunc = ~isempty(strfind(basedir, '\\')) || ...
  (isempty(find(basedir == ':', 1)) && ~isempty(strfind(pwd, '\\')));
if isunc
  error('Please pass a mapped drive to %s!', this);
elseif ~isabsolute % && ~isunc % convert into absolute path, if necessary
  directory = fullfile(pwd, taildir);
end % if isunc
mission = regexp(taildir, '\w*', 'match');
if length(mission) == 2 && strcmp(mission{1}, 'PhotoDB') && exist(directory, 'dir')
  mission = mission{end};
else % if length(mission) ~= 2 || ~strcmp(mission{1}, 'PhotoDB') || ~exist(directory, 'dir')
  error('Please specify a valid PhotoDB directory!');
end % if length(mission) == 2 && strcmp(mission{1}, 'PhotoDB') && exist(directory, 'dir')

FigureName = sprintf('%s -- STS-%s', this, mission);

flight_days = {'FD2', 'FD11'};
sensors = {'L2', 'IDC L1', 'ITVC L1', 'CTVC L1', 'RPM L1', 'LCS L1'};
zones = {'WLE-Port', 'WLE-Stbd', 'Nose Cap'};
scans = {'Scan1', 'Scan2', 'Scan3', 'Scan4', 'Scan5'};
panel_strs = ...
  {'Panel01', 'Panel02', 'Panel03', 'Panel04', 'Panel05', ...
  'Panel06', 'Panel07', 'Panel08', 'Panel09', 'Panel10', ...
  'Panel11', 'Panel12', 'Panel13', 'Panel14', 'Panel15', ...
  'Panel16', 'Panel17', 'Panel18', 'Panel19', 'Panel20', ...
  'Panel21', 'Panel22'};
port_panels = {'711L01', '711L02', '711L03', '711L04', '711L05', ...
  '711L06', '721L07', '721L08', '721L09', '721L10', '721L11', ...
  '721L12', '721L13', '721L14', '741L15', '741L16', '741L17', ...
  '741L18', '741L19', '741L20', '741L21', '741L22'};
stbd_panels = {'611R01', '611R02', '611R03', '611R04', '611R05', ...
  '611R06', '621R07', '621R08', '621R09', '621R10', '621R11', ...
  '621R12', '621R13', '621R14', '641R15', '641R16', '641R17', ...
  '641R18', '641R19', '641R20', '641R21', '641R22'};
scribble = [72 58 63 83 71 62 82 59 61 60, ...
  70 69 80 73 64 66 65 67 88 89, 68 81 79 74 84 75 76 86 77 87, 78 85];
counts = cellstr(num2str((1:20)', '%02d'))';

% get data
[flight_day_ind, sensor_ind, zone_ind, scan_ind, panel_ind] = ...
  pulldown('Browse Pulldown Menu', flight_days, sensors, zones, scans, panel_strs);
sensor = sensors{sensor_ind};

% define common directories
obss_dir = 'OBSS';
obss_late_dir = 'OBSS-Late';
working_dir = 'Working';
unenhanced_dir = '';
switch sensor
  case 'L2'
    isstretched = true;
    no_columns = 3;
    unenhanced_dir = fullfile('Working', 'L2_unenhanced');
    switch mission % for legacy directories
      case {'114', '121', '115', '116'}
        sensor_dir = sprintf('%s_screening_and_mosaicking', sensor);
        extension = 'bmp';
      otherwise
        sensor_dir = sprintf('%s_screening', sensor);
        extension = 'tif';
    end % switch mission
  case 'IDC L1'
    isstretched = false;
    no_columns = 4;
    sensor_dir = sprintf('%s_screening', strrep(sensor, ' L1', ''));
    extension = 'tif';
  case {'ITVC L1', 'CTVC L1'}
    isstretched = true;
    no_columns = 4;
    sensor_dir = sprintf('%s_screening', strrep(sensor, ' L1', ''));
    extension = 'tif';
  case 'RPM L1'
    isstretched = false;
    no_columns = 4;
    sensor_dir = sprintf('%s_screening', strrep(sensor, ' L1', ''));
    extension = 'tif';
  case 'LCS L1'
    isstretched = false;
    no_columns = 4;
    sensor_dir = sprintf('%s_screening', strrep(sensor, ' L1', ''));
    extension = 'bmp';
end % switch sensor
screening_dir = fullfile('Working', sensor_dir);
dirarg = sprintf('*.%s', extension);

% define INHOUSE directory
inhouse = getenv('INHOUSE'); % get inhouse directory
matlab = fullfile(inhouse, 'matlab');
rcc = fullfile(matlab, 'RCC');
yuck_file = 'yuck.gif';
yuck_fullfile = fullfile(rcc, yuck_file);

% turn common warnings off
warning off Images:initSize:adjustingMag % suppress too big image warning
warning off Images:imhistc:inputHasNaNs  % suppress complaints about NaNs

% set up figure
close force all % figures
[f1, s1, n1, p1, spinner_handles, pushbutton_handle, message_handle, keylink, left] = ...
  reopenfigure(sensor, scans, panel_strs, counts, FigureName);

index = 1;

lifespan = 100; % time to live for figure windows
iteration = 0;
timetodie = false; % figure already opened above
AdjustContrastVisible = 'off';
[width, height] = split(get(0, 'ScreenSize'), 2);
p = [(width-649)/2+1 height/40+1 649 300]; % preserves size of IMCONTRAST
AdjustContrastPosition = ...
  [left+(p(1)-1)/width (p(2)-1)/height p(3)/width p(4)/height];
OutliersEditString = '2';
MDRRadioButtonValue = ~isstretched;
EORadioButtonValue = isstretched;
c = 0;

isrefresh = true;
ismajorchange = true;
[ds dp] = deal(0);
grid_on = false;
zigzag_on = false;
isdiffed = false;

key = '';
while ~strcmp(key, 'q')
  if isrefresh
    switch flight_day_ind
      case 1 % early
        obss_gen_dir = obss_dir;
      case 2 % late
        obss_gen_dir = obss_late_dir;
    end % switch flight_day_ind

    % define panels
    switch zone_ind
      case 1 % Port
        panels = port_panels;
      case 2 % Stbd
        panels = stbd_panels;
      case 3 % Nose
        panels = {''};
    end % switch zone_ind
    zone = zones{zone_ind};

    full_dir = fullfile(directory, obss_gen_dir, zone, screening_dir);

    % create directory, if doesn't exist
    if ~exist(full_dir, 'dir')
      [success, message] = mkdir(full_dir);
      if ~success
        error(message);
      end %if ~success
    end % if ~exist(full_dir, 'dir')

    % keep track of current filename, if necessary
    if ~ismajorchange && no_files ~= 0
      file = files{index}; % get filename in old list
    end % if ~ismajorchange && no_files ~= 0

    % get dir
    files = dir2cell(fullfile(full_dir, dirarg));
    no_files = size(files, 1);
    
    if ~strcmp(sensor, 'L2')
      % check if leading zeros are missing in base filename
      f = regexprep(files, '\W*|\s*|_', ' ');
      r = regexp(f, '\w*', 'match');
      [max_length, min_length] = deal(-Inf, Inf);
      for i = 1:no_files
        max_length = max(max_length, length(r{i}{end - 1}));
        min_length = min(min_length, length(r{i}{end - 1}));
      end % for i
      if max_length > min_length
        new_str_fmt = sprintf(' %%0%dd ', max_length);
        for i = 1:no_files
          old_str = sprintf(' %s ', r{i}{end - 1});
          new_str = sprintf(new_str_fmt, str2double(r{i}{end - 1}));
          f(i) = regexprep(f(i), old_str, new_str);
        end % for i
        [f, i] = sortrows(f);
        files = files(i);
      end % if max_length > min_length
    end % if ~strcmp(sensor, 'L2')
    
    matrix = zeros(no_files, no_columns);
    if no_files == 0
      msg = sprintf('No image files to process for "%s"!', zone);
      warn_handle = warndlg(msg, 'No image files to process!', 'modal');
      putonsame(warn_handle, f1);
      %putonleft(warn_handle);
      waitfor(warn_handle);
    else % if no_files ~= 0
      for i = 1:no_files
        f = regexprep(files{i}, '\W*|\s*|_', ' ');
        r = regexp(f, '\w*', 'match');
        s = regexprep(r, '\D+', '');
        switch sensor
          case 'L2'
            if length(s) ~= 4
              s = cellstr(repmat('-1', no_columns + 1, 1))';
            end % if length(s)
          otherwise
            switch length(s)
              case 3 % NOSE/WLE originals
                s = {s{1} '0' '0' s{2:end}}; % add panel and count slots
              case 5 % WLE renamed
                % do nothing, correct size already
              otherwise
                s = cellstr(repmat('-1', no_columns + 1, 1))';
            end % switch length(s)
        end % switch sensor
        s(no_columns+1:end) = []; % get rid of extra information, if any
        matrix(i, :) = str2double(s);
      end % for i
      matrix(isnan(matrix)) = 0; % convert NaNs to zeros
      files(matrix(:, 1) == -1) = [];
      matrix(matrix(:, 1) == -1, :) = [];
      no_files = size(files, 1);

      switch sensor
        case 'L2'
          if zigzag_on
            switch zone_ind
              case {1, 2} % port, stbd
                i = 1:no_files; % vector of new indices
                for s = unique(matrix(:, 1))'
                  for p = unique(matrix(matrix(:, 1) == s, 2))'
                    j = find(matrix(:, 1) == s);
                    j = j(matrix(j, 2) == p);
                    i(j) = flipud(j);
                  end % for p = unique(matrix(matrix(:, 1) == s, 2))'
                end % for s = unique(matrix(:, 1))'
                files = files(i);
                matrix = matrix(i, :);
              case 3 % nose_cap
                j = zeros(1, no_files);
                for i = 1:no_files
                  j(i) = find(matrix(i, 2) == scribble);
                end % for i
                [ignore, i] = sort(j);
                files = files(i);
                matrix = matrix(i, :);
            end % switch zone_ind
          end % if zigzag_on
          % otherwise
          %   [matrix, i] = sortrows(matrix, no_columns);
          %   files = files(i);
          %
          %   % flip images for even numbered scans
          %   i = 1:no_files; % vector of new indices
          %   us = setdiff(unique(matrix(:, 1)), 0)';
          %   for s = us(~mod(us, 2))
          %     j = find(matrix(:, 1) == s);
          %     i(j) = flipud(j);
          %   end % for s = us(~mod(us, 2))
          %   files = files(i);
          %   matrix = matrix(i, :);
        otherwise
          % do nothing
      end % switch sensor
      if ~ismajorchange
        index = strmatch(file, files, 'exact'); % get new index from file
        if isempty(index), index = 1; end
      end % ~ismajorchange
    end % if no_files == 0

    ischange = true;
  end % if isrefresh

  % read old contrast stretching, if available
  if c && (isdiffed || ismajorchange || ischange || ndims(oimg) == 3)
    [AdjustContrastPosition, AdjustContrastVisible, OutliersEditString, ...
      MDRRadioButtonValue, EORadioButtonValue] = ...
      readcontrast(c, 'this', 'Position', 'this', 'Visible', ...
      'outlier percent edit', 'String', ...
      'match data range radio', 'Value', 'eliminate outliers radio', 'Value');
    if isdiffed || (ndims(oimg) == 3 && ~isstretched)
      delete(c);
      c = 0;
    end % if isdiffed || (ndims(oimg) == 3 && ~isstretched)
  end % if c && (isdiffed || ismajorchange || ischange || ndims(oimg) == 3)

  if timetodie && ~isdiffed
    [f1, s1, n1, p1, spinner_handles, pushbutton_handle, message_handle, keylink] = ...
      reopenfigure(sensor, scans, panel_strs, counts, FigureName);
    timetodie = false;

    isnewimg = true;
  end % if timetodie && ~isdiffed

  if ismajorchange && no_files ~= 0
    [scan_ind, panel_ind, index] = ...
      makemajorchange(matrix, scan_ind, panel_ind, ds, dp);

    ischange = true;
  end % if ismajorchange && no_files ~= 0

  if ischange
    if no_files == 0
      info = imfinfo(yuck_fullfile);
    else % if no_files ~= 0
      try
        info = imfinfo(fullfile(full_dir, files{index})); % errors for some
      catch it
        switch it.identifier
          case 'MATLAB:tifftagsread:repackageTag:unrecognizedTagFormat'
            [info.Height info.Width] = size(imread(fullfile(full_dir, files{index})));
          otherwise
            rethrow(it)
        end % switch
      end % try
    end % if no_files == 0

    % reset grid
    xinc = 5;
    xbegin = 0;
    xend = info.Width;
    xtick = xbegin:xinc:xend;

    yinc = 5;
    ybegin = 0;
    yend = info.Height;
    ytick = ybegin:yinc:yend;

    if no_files == 0
      full_dir = matlab;
      file = yuck_file;
    else % if no_files ~= 0
      file = files{index};
      switch sensor
        case 'L2'
          [scan_ind, panel_ind] = split(matrix(index, 1:no_columns-1));
        case 'IDC L1'
          set(p1, 'UserData', {full_dir, file, ''}); % dir, original, proposed
          determinefilenames(spinner_handles, pushbutton_handle, message_handle);
          [scan_ind, panel_ind, count_ind] = split(matrix(index, 1:no_columns-1));
          if panel_ind && count_ind
            writespinners(spinner_handles, [scan_ind; panel_ind; count_ind]);
          else % if ~panel_ind || count_ind
            u = readspinners(spinner_handles);
            panel_ind = u(2);
          end % if panel_ind && count_ind
        otherwise
          [scan_ind, panel_ind] = split(matrix(index, 1:no_columns-1));
      end % switch sensor
    end % if no_files == 0
    try
      info = imfinfo(fullfile(full_dir, file)); % errors for some
    catch it
      switch it.identifier
        case 'MATLAB:tifftagsread:repackageTag:unrecognizedTagFormat'
          [info.Height info.Width] = size(imread(fullfile(full_dir, file)));
        otherwise
          rethrow(it)
      end % switch
    end % try
    if isfield(info, 'ImageDescription')
      note = info.ImageDescription;
    else
      note = 'No Description';
    end
    oimg = imread(fullfile(full_dir, file));
    switch class(oimg)
      case 'single' % from 32-bit tif
        aimg = imadjust(double(oimg)/255, []);
        aimg(isnan(oimg)) = NaN;
        oimg = aimg;
      otherwise
        if ndims(oimg) == 3
          gimg = rgb2gray(oimg);
        else
          oimg = im2double(oimg);
        end % if ndims(oimg) == 3
    end % switch class(oimg)
    [m, n] = split(size(oimg));
    clear bimg % if it exists

    if isinteger(oimg) % i.e. if pre-flight image
      divisor = double(intmax(class(oimg)));
    else % if ~isinteger(oimg)
      divisor = 1;
    end % if isinteger(oimg)

    keepaxes = false;
    isdiffed = false;
    isnewimg = true;
  end % if ischange

  if isdiffed
    isnewimg = true;
    if ~exist('bimg', 'var')
      [ignore, filename] = fileparts(fullfile(full_dir, file));
      bmp_dir = fullfile(directory, obss_gen_dir, zone, unenhanced_dir);
      bmp_file = [filename '.bmp'];
      bimg = im2double(imread(fullfile(bmp_dir, bmp_file)));
    end % if ~exist('bimg', 'var')
    img = 1023*(oimg - bimg); % original image minus bmp image
  else % if ~isdiffed
    img = oimg;
  end % if isdiffed

  if isnewimg
    if ndims(oimg) == 3 % i.e. if color
      if isstretched
        img = gimg;
      else % if ~isstretched
        img = oimg;
      end % if isstretched
    end % if ndims(oimg) == 3
    
    figure(f1);
    subplot(s1);
    if keepaxes % i.e. if color
      ax = axis;
    end % if keepaxes
    imshow(img);
    if keepaxes
      axis(ax);
    else % if ~keepaxes
      keepaxes = true;
    end % if keepaxes
    
    set(n1, 'String', note);
    set(s1, 'XTick', xtick, 'YTick', ytick);
    if grid_on
      grid on
      axis on
    else % if ~grid_on
      grid off
      axis off
    end % if grid_on
    if isdiffed
      ttl = sprintf('%s (%s)', file, '10-bit TIFF minus 8-bit BMP');
    else % if ~isdiffed
      switch flight_day_ind
        case 1
          ttl = file;
        case 2
          ttl = sprintf('(LATE) %s (LATE)', file);
      end % switch flight_day_ind
    end % if isdiffed
    title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
    axis equal
    axis manual % to keep out of automatic mode

    % invoke contrast function
    if ~isdiffed && (ndims(oimg) ~= 3 || isstretched)
      [c, OutliersEditCallback] = opencontrast(s1, ...
        AdjustContrastPosition, AdjustContrastVisible, ...
        OutliersEditString, MDRRadioButtonValue, EORadioButtonValue);
      addtarget(keylink, c);
      iteration = mod(iteration + 1, lifespan);
      timetodie = timetodie | ~iteration;
      % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);
    end % if ~isdiffed && (ndims(oimg) ~= 3 || isstretched)
  end % if isnewimg

  isrefresh = false;
  ismajorchange = false;
  [ds dp] = deal(0);
  ischange = false;
  isnewimg = false;
  set(gcf, 'UserData', {'', '', ''});
  iskey = waitforbuttonpress;
  if iskey
    if isempty(split(get(gcf, 'UserData')))
      zoom off, pan off
      set(gcf, 'Pointer', 'arrow'); % change cursor to NOT look like zoom or pan
      keypressfcn(gcf);
    end % if isempty(split(get(gcf, 'UserData')))
    [key, character] = split(get(gcf, 'UserData'));
    switch key
      case 'f5'
        isrefresh = true;
      case 'z'
        switch sensor
          case 'L2'
            zigzag_on = ~zigzag_on;
            isrefresh = true;
          otherwise
            % do nothing
        end % switch sensor
      case 'f2'
        if flight_day_ind ~= 1
          flight_day_ind = 1;
          isrefresh = true;
          ismajorchange = true;
          zigzag_on = false;
        end % if flight_day_ind ~= 1
      case 'f11' % f10 invokes hidden menu and thus looses focus!
        if flight_day_ind ~= 2
          flight_day_ind = 2;
          isrefresh = true;
          ismajorchange = true;
          zigzag_on = false;
        end % if flight_day_ind ~= 2
      case 'p'
        if zone_ind ~= 1
          zone_ind = 1;
          isrefresh = true;
          ismajorchange = true;
          zigzag_on = false;
        end % if zone_ind ~= 1
      case 's'
        if zone_ind ~= 2
          zone_ind = 2;
          isrefresh = true;
          ismajorchange = true;
          zigzag_on = false;
        end % if zone_ind ~= 2
      case 'n'
        if zone_ind ~= 3
          zone_ind = 3;
          isrefresh = true;
          ismajorchange = true;
          zigzag_on = false;
        end % if zone_ind ~= 3
      case 'hyphen'
        switch character % disambiguate
          case '-'
            switch zone_ind
              case {1, 2} % port, stbd
                ds = -1;
              case 3 % nose
                ds = 0;
            end % switch zone_ind
          case '_'
            switch zone_ind
              case {1, 2} % port, stbd
                ds = +1;
              case 3 % nose
                ds = 0;
            end % switch zone_ind
        end % switch character
        ismajorchange = logical(ds);
      case 'leftbracket'
        if panel_ind
          switch zone_ind
            case 1 % port
              dp = -1;
            case 2 % starboard
              dp = +1;
            case 3 % nose
              dp = -1;
          end % switch zone_ind
          ismajorchange = logical(dp);
        else % if ~panel_ind % e.g. if no panel defined as for L1 imagery
          index = mod(index - 1 - 30, no_files) + 1; % jump 30
          ischange = true;
        end % if panel_ind
      case 'rightbracket'
        if panel_ind
          switch zone_ind
            case 1 % port
              dp = +1;
            case 2 % starboard
              dp = -1;
            case 3 % nose
              dp = +1;
          end % switch zone_ind
          ismajorchange = logical(dp);
        else % if ~panel_ind % e.g. if no panel defined as for L1 imagery
          index = mod(index - 1 + 30, no_files) + 1; % jump 30
          ischange = true;
        end % if panel_ind
      case 'pageup'
        index = mod(index - 1 - 1, no_files) + 1;
        ischange = true;
      case 'pagedown'
        index = mod(index - 1 + 1, no_files) + 1;
        ischange = true;
      case 'return'
        switch sensor
          case 'IDC L1'
            switch get(p1, 'Visible')
              case 'on' % then turn off
                set(p1, 'Visible', 'off');
                set(n1, 'Visible', 'on');
              case 'off' % then turn on
                set(n1, 'Visible', 'off');
                set(p1, 'Visible', 'on');
            end % switch get(p1, 'Visible');
          otherwise
            % do nothing
        end % switch sensor
      case 'l'
        figure(f1);
        subplot(s1);
        xbegin = xbegin - 1;
        xend = xend - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'r'
        figure(f1);
        subplot(s1);
        xbegin = xbegin + 1;
        xend = xend + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'u'
        figure(f1);
        subplot(s1);
        ybegin = ybegin - 1;
        yend = yend - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'd'
        figure(f1);
        subplot(s1);
        ybegin = ybegin + 1;
        yend = yend + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'multiply' % keypad *
        figure(f1);
        subplot(s1);
        xinc = xinc * 2;
        yinc = yinc * 2;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'divide' % keypad /
        figure(f1);
        subplot(s1);
        xinc = xinc / 2;
        yinc = yinc / 2;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'add' % keypad +
        figure(f1);
        subplot(s1);
        xinc = xinc + 1;
        yinc = yinc + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'subtract' % keypad -
        figure(f1);
        subplot(s1);
        xinc = xinc - 1;
        yinc = yinc - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s1, 'XTick', xtick, 'YTick', ytick);
      case 'g'
        grid_on = ~grid_on;
        figure(f1);
        subplot(s1);
        if grid_on
          grid on
          axis on
        else % if ~grid_on
          grid off
          axis off
        end % if grid_on
      case 'e'
        if isscreener
          [ignore, filename] = fileparts(fullfile(full_dir, file));
          ua_file = [filename '_ua.jpg'];
          an_file = [filename '_an.jpg'];
          if zone_ind == 3 % i.e. if Nose Cap
            ua_fullfile = fullfile(directory, obss_gen_dir, zone, working_dir, ua_file);
            an_fullfile = fullfile(directory, obss_gen_dir, zone, working_dir, an_file);
          else % if zone_ind ~= 3
            if ~panel_ind % e.g. if no panel defined as for L1 imagery
              choice = pulldown('Please Select Panel', panels); % don't change panel_ind!!!
              f = regexprep(filename, '\W*|\s*|_', ' ');
              r = regexp(f, '\w*', 'match');
              scan_str = r{1};
              panel_str = panel_strs{choice};
              basename = r{end};
              newfilename = sprintf('%s_%s_%s', scan_str, panel_str, basename);
              ua_file = [newfilename '_ua.jpg'];
              an_file = [newfilename '_an.jpg'];
              panel = panels{choice};
            else % if panel_ind
              panel = panels{panel_ind};
            end % if ~panel_ind
            ua_fullfile = fullfile(directory, obss_gen_dir, zone, panel, working_dir, ua_file);
            an_fullfile = fullfile(directory, obss_gen_dir, zone, panel, working_dir, an_file);
          end % if zone_ind == 3
          if exist(an_fullfile, 'file')
            info = imfinfo(an_fullfile);
            if etime(clock, datevec(info.FileModDate))/86400 > 4
              msg = sprintf('"%s" already edited over 4 days ago!', an_file);
              warn_handle = warndlg(msg, [this, ' -- Will not comply!'], 'modal');
              putonsame(warn_handle, f1);
              %putonleft(warn_handle);
              waitfor(warn_handle);
              [modify, backup] = deal(false);
            else % etime(clock, datevec(info.FileModDate))/86400 <= 4
              msg = sprintf('"%s" already edited!  Replace?', an_file);
              choice = questdlg(msg, [this, ' -- Replace?'], 'Yes', 'No', 'No');
              switch choice
                case 'Yes'
                  [modify, backup] = deal(true);
                otherwise
                  [modify, backup] = deal(false);
              end % switch choice
            end % if etime(clock, datevec(info.FileModDate))/86400 > 4
          else % if ~exist(an_fullfile, 'file')
            [modify, backup] = deal(true, false);
          end % if exist(an_fullfile, 'file')
          if modify
            an_dir = fileparts(an_fullfile);
            if backup
              i = 1;
              bk_an_file = sprintf('%s_an.bk%d', filename, i);
              bk_an_fullfile = fullfile(an_dir, bk_an_file);
              while exist(bk_an_fullfile, 'file')
                i = i + 1;
                bk_an_file = sprintf('%s_an.bk%d', filename, i);
                bk_an_fullfile = fullfile(an_dir, bk_an_file);
              end % while exist(bk_an_fullfile, 'file')
              [success, message] = movefile(an_fullfile, bk_an_fullfile);
            else
              success = true;
            end % if backup
            if ~success
              warn_handle = warndlg(message, [this, ' -- Unable to backup!'], 'modal');
              putonsame(warn_handle, f1);
              %putonleft(warn_handle);
              waitfor(warn_handle);
            else % if success
              command = sprintf('explorer "%s"', an_dir);
              system(command);
              if isstretched
                if c
                  [MinEditString, MaxEditString] = ...
                    readcontrast(c, 'window min edit', 'String', ...
                    'window max edit', 'String');
                  [MinEditValue, MaxEditValue] = ...
                    split(str2double({MinEditString, MaxEditString}));
                end % if c
                if ndims(oimg) == 3 % i.e. if color
                  cimg = zeros(size(oimg), class(oimg));
                  for i = 1:3
                    cimg(:, :, i) = ...
                      imadjust(oimg(:, :, i), [MinEditValue MaxEditValue]/divisor);
                  end % for i
                  % DECORRSTRETCH gives bizarre
                  %cimg = decorrstretch(oimg, 'tol', [MinEditValue MaxEditValue]/divisor);
                else % if ndims(oimg) ~= 3 % i.e. if grayscale
                  cimg = imadjust(oimg, [MinEditValue MaxEditValue]/divisor);
                  cimg(isnan(oimg)) = NaN;
                end % if ndims(oimg) == 3
              else % if ~isstretched
                cimg = oimg;
              end % if isstretched
              imwrite(cimg, ua_fullfile, 'Quality', 100);
              imwrite(cimg, an_fullfile, 'Quality', 100);
              command = sprintf('start /max photoshop %s', an_fullfile);
              system(command);
            end % if ~success
          end % if modify
        else % if ~isscreener
          destination = fullfile(tempdir, file); % generate temporary filename
          imwrite(img, destination, 'Compression', 'none');
          command = sprintf('start /max photoshop %s', destination);
          system(command);
        end % if isscreener
      case 'home'
        zoom out
        ax = [0 n 0 m] + .5;
        axis(ax);
      case 'c'
        if ~isdiffed
          if ndims(oimg) == 3 % if color
            isstretched = ~isstretched;
            MDRRadioButtonValue = ~isstretched;
            EORadioButtonValue = isstretched;
            isnewimg = true;
          else % if ndims(oimg) ~= 3 % if grayscale
            isstretched = tagget(c, 'match data range radio', 'Value'); % flip it
            writecontrast(c, 'match data range radio', 'Value', ~isstretched, ...
              'eliminate outliers radio', 'Value', isstretched);
            OutliersEditCallback(); % same as Apply pushbutton
            PTLError = findall(0, 'Name', 'Percentage Too Large');
            CEOError = findall(0, 'Name', 'Cannot Eliminate Outliers');
            if ishandle(PTLError)
              OutliersEditString = '2';
              writecontrast(c, 'outlier percent edit', 'String', OutliersEditString);
              OutliersEditCallback(); % same as Apply pushbutton
            end % if ishandle(PTLError)
            delete([PTLError CEOError]);
          end % if ndims(oimg) == 3
        end % if ~isdiffed
      case 'v'
        if ~isdiffed
          if c
            switch get(c, 'Visible')
              case 'on' % then turn off
                AdjustContrastVisible = 'off';
              case 'off' % then turn on
                AdjustContrastVisible = 'on';
            end % switch get(c, 'Visible');
            set(c, 'Visible', AdjustContrastVisible);
            putontop(c);
          elseif ndims(oimg) == 3 % i.e. turn on contrast stretch for color
            AdjustContrastVisible = 'on';
            isstretched = ~isstretched;
            MDRRadioButtonValue = ~isstretched;
            EORadioButtonValue = isstretched;
            isnewimg = true;
          end % if c
        end % if ~isdiffed
      case 'f12'
        switch sensor
          case 'L2'
            isdiffed = ~isdiffed;
            if ~isdiffed
              ischange = true;
            end % if ~isdiffed
          otherwise
            % do nothing
        end % switch sensor
      case 'q'
        disp('QUIT!');
        close force all
      otherwise
        msg = sprintf('I don''t understand "%s"!', key);
        warn_handle = warndlg(msg, 'I don''t understand!', 'modal');
        putonsame(warn_handle, f1);
        %putonleft(warn_handle);
        waitfor(warn_handle);
    end % switch key
  else % if ~iskey (i.e. is mouse button)
    switch sensor
      case 'IDC L1'
        data = get(p1, 'UserData');
        [file, files{index}] = deal(data{end - 1});
        f = regexprep(files{index}, '\W*|\s*|_', ' ');
        r = regexp(f, '\w*', 'match');
        s = regexprep(r, '\D+', '');
        switch length(s)
          case 3 % NOSE/WLE originals
            s = {s{1} '0' '0' s{2:end}}; % add panel and count slots
          case 4 % NOSE/WLE Level 2
            % do nothing, correct size already
          case 5 % WLE renamed
            % do nothing, correct size already
        end % switch length(s)
        s(no_columns+1:end) = []; % get rid of extra information, if any
        matrix(index, :) = str2double(s);
        data = {data{1}, file, ''}; % get rid of extra file names
        set(p1, 'UserData', data);
      otherwise
        % do nothing
    end % switch sensor
  end % if iskey
end % while ~strcmp(key, 'q')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READSPINNERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function u = readspinners(h)

u = cell2mat(get(h, 'Value'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITESPINNERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function writespinners(h, u)

% ensure within bounds
u = round(u); % ensure integers
m = cell2mat(get(h, 'Max'));
u(u < 1) = 1; % force minimum to be 1
u(u > m) = m(u > m); % force maximum to be m

for p = 1:length(u)
  set(h(p), 'Value', u(p));
  SpinnerCallbackCell = get(h(p), 'Callback');
  SpinnerCallback = SpinnerCallbackCell{1};
  SpinnerCallback(h(p), '', SpinnerCallbackCell{2:end}); % implement changes
end % for u = values'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINEFILENAMES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function determinefilenames(h, p, m)

parent = get(h(1), 'Parent');

data = get(parent, 'UserData');
oldfile = data{end - 1};

f = regexprep(oldfile, '\W*|\s*|_', ' ');
r = regexp(f, '\w*', 'match');

u = readspinners(h);
panel_strs = get(h(2), 'String');
counts = get(h(3), 'String');

scan_str = regexprep(r{1}, '\d+', int2str(u(1)));
panel_str = panel_strs{u(2)};
count = counts{u(3)};
basename = r{end - 1};
extension = r{end};

newfile = sprintf('%s_%s_%s_%s.%s', scan_str, panel_str, count, basename, extension);
data{end} = newfile;
set(parent, 'UserData', data);

set(m, 'String', {'', sprintf('Old file:  \t%s', oldfile), ...
  '', sprintf('New file:  \t%s', newfile), ''});

if strcmp(oldfile, newfile)
  set(p, 'Enable', 'off');
else % if ~strcmp(oldfile, newfile)
  set(p, 'Enable', 'on');
end % if strcmp(oldfile, newfile)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKESPINNERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sliders, pushbutton, message] = makespinners(varargin)

m = zeros(1, nargin-1); % maximums
n = 0; % number of spinners
while n < nargin-1 && iscellstr(varargin{n+2})
  arg = n + 2;
  n = n + 1;
  m(n) = length(varargin{arg});
end % while n
m(n+1:end) = [];

[textboxes, sliders] = deal(zeros(1, n));
parent = varargin{1};

u = ones(1, n); % defaults

h = 1 / (n+1);

message = uicontrol('Parent', parent, 'Style', 'text', 'String', '', ...
  'Units', 'normalized', 'Position', [.50 0 .50 1]);
pushbutton = uicontrol('Parent', parent, 'Style', 'pushbutton', ...
  'Units', 'normalized', 'Position', [0 0 1 h], ...
  'String', 'Rename', 'Callback', {@renamecallbackfcn, message});
for p = 1:n
  strings = varargin{p+1};
  textboxes(p) = uicontrol('Parent', parent, 'Style', 'text', ...
    'Units', 'normalized', 'Position', [0 (n+1-p)*h .25 h], ...
    'String', strings{u(p)});
  sliders(p) = uicontrol('Parent', parent, 'Style', 'slider', ...
    'Units', 'normalized', 'Position', [.25 (n+1-p)*h .25 h], ...
    'Max', m(p), 'Min', 1, 'Value', u(p), 'String', strings, ...
    'SliderStep', [1/(m(p)-1) 1/(m(p)-1)], 'UserData', m(p));
end % for p
for p = 1:n
  set(sliders(p), ...
    'KeyPressFcn', {@spinnercallbackfcn, sliders, textboxes(p), pushbutton, message}, ...
    'Callback', {@spinnercallbackfcn, sliders, textboxes(p), pushbutton, message}, ...
    'ButtonDownFcn', {@spinnercallbackfcn, sliders, textboxes(p), pushbutton, message});
end % for p


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPINNERCALLBACKFCN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spinnercallbackfcn(s, eventdata, h, t, p, m) % src, eventdata, varargin ...

if isempty(eventdata) || ~isstruct(eventdata)
  eventdata.Key = '';
end % isempty(eventdata) || ~isstruct(eventdata)
mn = get(s, 'Min');
mx = get(s, 'Max');
v = round(get(s, 'Value'));
% oldv = get(s, 'UserData'); % see how value changed
switch eventdata.Key
  case 'comma'
    v = mn;
  case 'period'
    v = mx;
  case {'pageup', 'pagedown'}
    %v = oldv
  otherwise
    %     if oldv == v % logic to rotate
    %       switch v
    %         case mn
    %           v = mod(v - mn - 1, mx - mn + 1) + mn;
    %         case mx
    %           v = mod(v - mn + 1, mx - mn + 1) + mn;
    %         otherwise
    %           beep;
    %       end % switch v
    %     end % if oldv == v
end % switch eventdata.Key
set(s, 'Value', v, 'UserData', v);
str = get(s, 'String');
set(t, 'String', str{v});

determinefilenames(h, p, m);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RENAMECALLBACKFCN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function renamecallbackfcn(p, eventdata, m) % src, eventdata, varargin ...

if isempty(eventdata) || ~isstruct(eventdata)
  eventdata.Key = '';
end % isempty(eventdata) || ~isstruct(eventdata)

parent = get(p, 'Parent');

data = get(parent, 'UserData');
full_dir = data{1};
oldfile = data{end - 1}; % original or last renamed file
newfile = data{end}; % proposed name to be used now

if ~strcmp(oldfile, newfile) % check if same filename
  [success, message] = ...
    movefile(fullfile(full_dir, oldfile), fullfile(full_dir, newfile));
  if ~success
    warn_handle = warndlg(message, 'Unable to rename!', 'modal');
    putonsame(warn_handle, f1);
    %putonleft(warn_handle);
    waitfor(warn_handle);
  else % if success
    data{end + 1} = ''; % grow it for new proposed name
    message = {'Renamed', 'from', oldfile, 'to', newfile};
    set(parent, 'UserData', data); % flag file renaming
    set(p, 'Enable', 'off');
    set(m, 'String', message);
    ttl = strtrim(sprintf('%s ', message{:}));
    title(imgca, ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
  end %if ~success
else % if strcmp(oldfile, newfile)
  set(p, 'Enable', 'off');
end % if ~strcmp(oldfile, newfile)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REOPENFIGURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f1, s1, n1, p1, spinner_handles, pushbutton_handle, message_handle, keylink, left] = ...
  reopenfigure(sensor, scans, panel_strs, counts, FigureName)

screen_size = get(0, 'ScreenSize');
if isempty(get(0, 'CurrentFigure'))
  monitor_positions = get(0, 'MonitorPositions');
  column = div(monitor_positions(:, 1), screen_size(3));
  left = min(column);
  % right = max(column);
  monitor = [left 0 1 1];
else % if ~isempty(get(0, 'CurrentFigure'))
  monitor = get(gcf, 'OuterPosition'); % save for later
  close force all % figures
end % if isempty(get(0, 'CurrentFigure'))
if screen_size(4) < 1200
  font_size = 7;
else % if screen_size(4) >= 1200
  font_size = 8;
end % if screen_size(4) < 1200

% define menus
left_menu(1, :) = sprintf('        F5        \t   refresh dir ');
left_menu(2, :) = sprintf('        z         \t  toggle zigzag');
left_menu(3, :) = sprintf('      F2 F11      \t    FD2/FD11   ');
left_menu(4, :) = sprintf('      p s n       \t port/stbd/nose');
left_menu(5, :) = sprintf(' hyphen underscore\t  change scan #');
left_menu(6, :) = sprintf('       [ ]        \t change panel #');
left_menu(7, :) = sprintf(' PageUp PageDown  \t    new image  ');
switch sensor
  case 'IDC L1'
    left_menu(8, :) = sprintf('      enter       \ttoggle renaming');
  case 'L2'
    left_menu(8, :) = sprintf('       F12        \t   difference  ');
end % switch sensor

right_menu(1, :) = sprintf('       Home       \t  full zoom out');
right_menu(2, :) = sprintf('        e         \t      edit     ');
right_menu(3, :) = sprintf('        g         \t   toggle grid ');
right_menu(4, :) = sprintf('     l r u d      \t    move grid  ');
right_menu(5, :) = sprintf('       * /        \t   resize grid ');
right_menu(6, :) = sprintf('       + -        \t   inc/dec grid');
right_menu(7, :) = sprintf('        c         \t  cont. stretch');
right_menu(8, :) = sprintf('        v         \t  cont. visible');
right_menu(9, :) = sprintf('        q         \t      quit     ');

f1 = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', FigureName, 'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'left'}, 'Units', 'normalized', ...
  'OuterPosition', monitor);
s1 = subplot('Position', [0 .2 1 .75]);
n1 = uicontrol('Parent', f1, 'Style', 'text', 'Visible', 'on', ...
  'Units', 'normalized', 'Position', [.25 .05 .50 .10]);
p1 = uipanel('Parent', f1, 'Title', 'File Rename Dialog', ...
  'TitlePosition', 'centertop', 'UserData', '', 'Visible', 'off', ...
  'Units', 'normalized', 'Position', [.25 .05 .50 .10]);

% position menus
uicontrol('Parent', f1, 'Style', 'text', 'String', left_menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .125], ...
  'FontName', 'Courier', 'FontSize', font_size);
uicontrol('Parent', f1, 'Style', 'text', 'String', right_menu, ...
  'Units', 'normalized', 'Position', [.775 .025 .2 .125], ...
  'FontName', 'Courier', 'FontSize', font_size);

% turn off unuseful figure controls
toggle_handles = [findall(f1, 'type', 'uipushtool'); ...
  findall(f1, 'type', 'uitogglesplittool'); ...
  findall(f1, 'type', 'uitoggletool')];
for toggle_handle = toggle_handles'
  switch get(toggle_handle, 'Tag')
    case {'Exploration.Pan', 'Exploration.ZoomOut', 'Exploration.ZoomIn'}
      set(toggle_handle, 'Separator', 'off', 'OnCallback', 'beep', 'OffCallback', 'beep');
    otherwise
      set(toggle_handle, 'Enable', 'off', 'Visible', 'off'); % disable and hide
  end % switch get(toggle_handle, 'Tag')
end % for toggle_handle = toggle_handles'

% alter zoom and pan functions to allow buttondownfcn to execute
z = zoom(f1); p = pan(f1);
[z.ButtonDownFilter, p.ButtonDownFilter] = deal(@buttondownfilter);
puc = uicontextmenu; % disable pan right clicking, for Frank
uimenu('Parent', puc, 'Enable', 'off', 'Visible', 'off');
set(p, 'UIContextMenu', puc);

[spinner_handles, pushbutton_handle, message_handle] = ...
  makespinners(p1, scans, panel_strs, counts);

keylink = linkprop(f1, 'UserData');
