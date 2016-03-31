function blink(varargin)

%BLINK Blink comparator for Orbiter Wing Leading Edge and Nose Cap.
%   BLINK will browse through a sequence of TIFFs in the user specified
%   PhotoDB directory for comparison between early and late inspection.  If
%   no directory is provided, then the user will be prompted.  Menus are
%   included.  See accompanying documentation.
%
%   BLINK(DIR) will start browsing the PhotoDB database in the directory
%   DIR.
%
%   BROWSE(..., '-s') will allow users (typically screeners) to add regions
%   of interest into the PhotoDB directory.
%
%   Example
%   -------
%       blink T:\PhotoDB-RCC
%
%   Notes
%   -----
%       The mouse cursor must be in one of the figures for the program to
%       accept keystrokes.
%
%       BLINK cannot open UNC paths in Photoshop.
%
%   See also BROWSE, BASELINE, WAITFORBUTTONPRESS, GRID.
%
%   Version 5.9 Kevin Crosby

% DATE      VER  NAME          DESCRIPTION
% 02-28-06  1.0  K. Crosby     First Release.
% 02-28-06  1.1  K. Crosby     Added status change textbox.
% 03-01-06  1.2  K. Crosby     Fixed directory access.
% 03-01-06  1.3  K. Crosby     Made whiter, added '1', '2', '3' keys,
%                              added inhibit feature.
% 03-07-06  1.4  K. Crosby     Fixed bug when transitioning from merge to
%                              alternate.  Added edit feature.  Changed
%                              titles and menu.
% 03-09-06  1.5  K. Crosby     Added refresh key.
% 03-23-06  2.0  K. Crosby     Added support for OBSS-Late directory.
%                              Placed edited copies in panel working
%                              directories.
% 03-28-06  2.1  K. Crosby     Added pulldown menu to select zone.
% 03-29-06  2.2  K. Crosby     Swapped arrows and left, right, up, down.
%                              Added - 1, - 2, - 3 to early and late image
%                              titles.  Added 'home' and 'end' keys to
%                              change scan numbers.  Changed error handling
%                              for missing files.
% 04-18-06  2.3  K. Crosby     Added mouse input for moving images.
% 04-28-06  2.4  K. Crosby     Added perspective registration of images.
% 05-04-06  2.5  K. Crosby     Changed perspective registration of images
%                              to call REGISTER instead of CPSELECT, since
%                              CPSELECT won't compile.
% 05-11-06  2.6  K. Crosby     Now ignores '_alt' images, changed '_ua'
%                              file to JPEG, and initiates mouse input with
%                              'x' to avoid conflicts with zooming and
%                              panning.
% 11-28-06  2.7  K. Crosby     Added reference to 'INHOUSE' directory and
%                              'yuck.bmp'.  Made other minor changes.
% 12-04-06  2.8  K. Crosby     Changed default to inhibit = 2.  Changed
%                              some titles to reflect - 1, - 2, and - 3.
%                              Changed default jump to 1.
% 02-12-07  2.9  K. Crosby     Calls PULLDOWN sub-function as separate
%                              file.  Forced 'x' option to work only when
%                              merged.  Fixed bug when using pageup/down
%                              with focus right.  Added change panel
%                              number.  Removed handling of '_alt' files.
% 02-26-07  2.10 K. Crosby     Ignore scan and panel changes for nosecap.
%                              Added 'zigzag' feature for dir listing.
% 05-03-07  3.0  K. Crosby     Fixed bug with initial pulldown menu.  Made
%                              control point merging automatic.  Added
%                              snap.  Automatically position windows.
%                              Removed references to colormap.  Improved
%                              transition between zones, scans, and panels.
% 05-21-07  3.1  K. Crosby     Fixed monitor positions.  Removed 'Scan6'.
% 06-18-07  3.2  K. Crosby     Made scan and panel changes more robust,
%                              so can handle nose cap and missing scans and
%                              panels.  Made title reflect exactly what was
%                              merged.
% 06-20-07  3.3  K. Crosby     Fixed bug with refresh.  Reduced window
%                              sizes for one screen.
% 07-18-07  4.0  K. Crosby     Made dialog boxes always on top.  Renamed
%                              subplots.  Put figure and contrast tools in
%                              functions.  Cleaned up axis and overlap
%                              handling immensely.
% 07-23-07  4.1  K. Crosby     Made titles bold.  Made figure name reflect
%                              mission.  Changed lifespan to 100.  Put
%                              IMCONTRAST tool back on screen.
% 08-01-07  4.2  K. Crosby     Check existence of PhotoDB directory.
%                              Preserve original size of IMCONTRAST, and
%                              center.  Suppress warnings for NaNs.  Fixed
%                              grid. Fixed contrast stretching on 'kontrol
%                              points' and allowed for abort and redos.
% 08-02-07  4.3  K. Crosby     Added timestamp checking for annotated
%                              files.  Added verbose figure
%                              CloseRequestFcn.
% 08-13-07  4.4  K. Crosby     Turned zoom and pan off before new image is
%                              displayed to avoid IMCONTRAST crashing
%                              program.  Added backup annotated images.
% 08-21-07  4.5  K. Crosby     Added base path to directory variable.
%                              Added maximize to Photoshop call.  Changed
%                              'yuck.bmp' to 'yuck.gif'.  Added
%                              initialization for early right index.
% 09-25-07  4.6  K. Crosby     Changed code to handle NaNs in LDRI images.
%                              Made IMCONTRAST routine compatible with
%                              MATLAB 7.5.  Added "snap" to kontrol points
%                              option.
% 10-29-07  4.7  K. Crosby     Changed edit feature to only add ROI files
%                              from 4 workstations.  Added workaround for
%                              IMCONTRAST and IMADJUST failure.
% 11-27-07  5.0  K. Crosby     Fixed left and right brackets for nose cap.
%                              Fixed contrast stretching via 'isstretched'
%                              variable.  Made mouse input ('x') and
%                              kontrol points ('k') more robust.  Introduce
%                              "mono" view for early images.  Decoupled
%                              scan and panel major changes on early image.
%                              Added auto alternate.
% 11-30-07  5.1  K. Crosby     Made nose cap zigzag according to desired
%                              screening order.  Remember input and base
%                              points before calling register.
% 01-16-08  5.2  K. Crosby     Fixed kontrol point method with one point
%                              selected and reregistered.
% 02-05-08  5.3  K. Crosby     Added option for Screeners vs. LESS with
%                              respect to editting, not based on computer.
% 03-17-08  5.4  K. Crosby     Added code for nose cap for late docking
%                              during STS-123.  Added status display for
%                              zigzag.  Turned zigzag on for nose cap by
%                              default.  Removed CD calls.
% 04-01-08  5.5  K. Crosby     Fixed contrast stretching for kontrol
%                              points.  Remember min and max settings for
%                              aborted registration.  Made key presses work
%                              on IMCONTRAST tool.
% 06-16-08  5.6  K. Crosby     Converted common subfunctions into
%                              individual private functions.  Fixed mouse
%                              cursor appearance when key is pressed under
%                              zoom or pan.
% 11-17-08  5.7  K. Crosby     Disabled pan right-clicking.  Fixed LDRI tif
%                              errors occuring on some older missions.
% 11-26-08  5.8  K. Crosby     Fixed zooming and panning problems with
%                              the part of the early left image which
%                              overlaps the hidden early right image. Fixed
%                              zooming and panning under merging and
%                              alternating.  Allowed kontrol points method
%                              to use point picked by mouse input method.
% 01-13-09  5.9  K. Crosby     Allow for Nose Cap segment 89 to exist to
%                              prevent crashing.  Turn off Nose Cap zigzag
%                              by default, unless Orbiter docked during
%                              late inspection.  Fixed axes problems under
%                              reopening figures.  Put IMCONTRAST tool on
%                              same side as image being modified.


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

LateFigureName = sprintf('%s (Late Imagery) -- STS-%s', this, mission);
EarlyFigureName = sprintf('%s (Early Imagery) -- STS-%s', this, mission);

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

% get data
[zone_ind, scan_late_ind, panel_late_ind] = ...
  pulldown('Blink Pulldown Menu', zones, scans, panel_strs);

% define common directories
obss_dir = 'OBSS';
obss_late_dir = 'OBSS-Late';
working_dir = 'Working';
switch mission % for legacy directories
  case {'114', '121', '115', '116'}
    sensor_dir = 'L2_screening_and_mosaicking';
    extension = 'bmp';
  otherwise
    sensor_dir = 'L2_screening';
    extension = 'tif';
end % switch mission
no_columns = 3; % for LDRI
screening_dir = fullfile('Working', sensor_dir);
dirarg = sprintf('*.%s', extension);

% set flag for if orbiter is docked during late inspection
switch mission
  case {'123', '131', '134'}
    islatedocked = true;
  otherwise
    islatedocked = false;
end % switch mission

% define INHOUSE directory
inhouse = getenv('INHOUSE'); % get inhouse directory
matlab = fullfile(inhouse, 'matlab');
rcc = fullfile(matlab, 'RCC');
yuck_file = 'yuck.gif';
yuck_fullfile = fullfile(rcc, yuck_file);
zz_map_fullfile = fullfile(rcc, 'zigzag_mapping.txt');

% turn common warnings off
warning off Images:initSize:adjustingMag % suppress too big image warning
warning off Images:imhistc:inputHasNaNs  % suppress complaints about NaNs

% set up figure
arenewfigures = true; % default
isdualview = false; % default mono view
%isdualview = true; % default dual view
close force all % figures
[f1, f2, s1, s2, s3, n1, keylink, right] = ...
  reopenfigures(EarlyFigureName, LateFigureName, isdualview);

trio = 1:3;
key = ' ';
late_index = 1;
early_left_index = 1;
early_right_index = 1;

isstretched = true(1, 3);
lifespan = 100; % time to live for figure windows
iteration = 0;
timetodie = false; % figures already opened above
visible = 3; % 1 is early_left, 2 is early_right, 3 is late
AdjustContrastVisible = {'off', 'off', 'on'};
[width, height] = split(get(0, 'ScreenSize'), 2);
p = [(width-649)/2+1 height/40+1 649 300]; % preserves size of IMCONTRAST
AdjustContrastPosition = ...
  [right+(p(1)-1)/width (p(2)-1)/height p(3)/width p(4)/height];
OutliersEditString = {'2', '2', '2'};
MDRRadioButtonValue = ~isstretched;
EORadioButtonValue = isstretched;
OutliersEditCallback = cell(1, 3); % cell array of function handles
MinMaxEditCallback = cell(1, 3); % cell array of function handles
[MinEditString, MaxEditString] = deal(cell(1, 3));
[MinEditValue, MaxEditValue] = deal(zeros(1, 3));
c = zeros(1, 3);

% mask info for dead pixel NaNs
mithresh = 0.03; % mask intensity thresh 7/255 < x < 8/255
xy = [3 125;  89 3; 657 3; 711 65; 711 430; 676 478; 70 478; 3 372]; % oct

isrefresh = true;
ismajorchange = true;
ismajorearlyonlychange = false;
issubtlechange = false;
[ds dp] = deal(0);
number = 0;
iskey = true; % for default, assume key pressed & not mouse button
isshifted = false;
isnewwarp = false;
isrewarp = false;
iswarpedleft = false;
iswarpedright = false;
ismerged = false;
iswhitened = false;
issnapped = true;
grid_on = false;
isfocusleft = true; % to ensure that focus and inhibit are not both "right"
alternate = 3; % 1 is early_left, 2 is early_right, 3 is late
inhibit = 2;   % 1 is early_left, 2 is early_right, 3 is neither
jump = 1;

delay = 1; % for auto alternate
isautoalternate = false;

switch zone_ind
  case {1, 2} % port, stbd
    late_zigzag_on = false;
    early_zigzag_on = false;
  case 3 % nose
    if islatedocked
      late_zigzag_on = false;
      early_zigzag_on = true;
    else % if ~islatedocked
      late_zigzag_on = false;
      early_zigzag_on = false;
    end % if islatedocked
end % switch zone_ind

while ~strcmp(key, 'q')
  if isrefresh
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

    early_dir = ...
      fullfile(directory, obss_dir, zone, screening_dir);      % FD 2 directory
    late_dir = ...
      fullfile(directory, obss_late_dir, zone, screening_dir); % FD 10 directory

    % create directories, if don't exist
    if ~exist(late_dir, 'dir')
      [success, message] = mkdir(late_dir);
      if ~success
        error(message);
      end %if ~success
    end % if ~exist(late_dir, 'dir')
    if ~exist(early_dir, 'dir')
      [success, message] = mkdir(early_dir);
      if ~success
        error(message);
      end %if ~success
    end % if ~exist(early_dir, 'dir')

    % keep track of current filenames, if necessary
    if ~ismajorchange && no_late_files ~= 0 && no_early_files ~= 0
      late_file = late_files{late_index}; % get filename in old list
      if ~ismajorearlyonlychange && ~issubtlechange
        early_left_file = early_files{early_left_index}; % get filename in old list
      end % if ~ismajorearlyonlychange && ~issubtlechange
    end % if ~ismajorchange && no_late_files ~= 0 && no_early_files ~= 0

    % get late dir
    late_files = dir2cell(fullfile(late_dir, dirarg));
    no_late_files = size(late_files, 1);

    % get early_dir
    early_files = dir2cell(fullfile(early_dir, dirarg));
    no_early_files = size(early_files, 1);

    late_matrix = zeros(no_late_files, no_columns);
    early_matrix = zeros(no_early_files, no_columns);
    if no_late_files == 0 || no_early_files == 0
      msg = sprintf('No image files to process for "%s"!', zone);
      warn_handle = warndlg(msg, 'No image files to process!', 'modal');
      putonsame(warn_handle, f1);
      %putonleft(warn_handle);
      waitfor(warn_handle);
    else % if no_late_files ~= 0 && no_early_files ~= 0
      for i = 1:no_late_files
        f = regexprep(late_files{i}, '\W*|\s*|_', ' ');
        r = regexp(f, '\w*', 'match');
        s = regexprep(r, '\D+', '');
        if length(s) ~= 4
          s = cellstr(repmat('-1', no_columns + 1, 1))';
        end % if length(s)
        s(no_columns+1:end) = []; % get rid of extra information, if any
        late_matrix(i, :) = str2double(s);
      end % for i
      late_matrix(isnan(late_matrix)) = 0; % convert NaNs to zeros
      late_files(late_matrix(:, 1) == -1) = [];
      late_matrix(late_matrix(:, 1) == -1, :) = [];
      no_late_files = size(late_files, 1);

      for i = 1:no_early_files
        f = regexprep(early_files{i}, '\W*|\s*|_', ' ');
        r = regexp(f, '\w*', 'match');
        s = regexprep(r, '\D+', '');
        if length(s) ~= 4
          s = cellstr(repmat('-1', no_columns + 1, 1))';
        end % if length(s)
        s(no_columns+1:end) = []; % get rid of extra information, if any
        early_matrix(i, :) = str2double(s);
      end % for i
      early_matrix(isnan(early_matrix)) = 0; % convert NaNs to zeros
      early_files(early_matrix(:, 1) == -1) = [];
      early_matrix(early_matrix(:, 1) == -1, :) = [];
      no_early_files = size(early_files, 1);

      if zone_ind == 3 && islatedocked && early_zigzag_on
        zz_segs = textread(zz_map_fullfile, '%[^\n]', 'commentstyle', 'matlab');
      end % zone_ind == 3 && islatedocked && early_zigzag_on

      if late_zigzag_on
        switch zone_ind
          case {1, 2} % port, stbd
            i = 1:no_late_files; % vector of new indices
            for s = unique(late_matrix(:, 1))'
              for p = unique(late_matrix(late_matrix(:, 1) == s, 2))'
                j = find(late_matrix(:, 1) == s);
                j = j(late_matrix(j, 2) == p);
                i(j) = flipud(j);
              end % for p = unique(late_matrix(late_matrix(:, 1) == s, 2))'
            end % for s = unique(late_matrix(:, 1))'
            late_files = late_files(i);
            late_matrix = late_matrix(i, :);
          case 3 % nose_cap
            if ~islatedocked
              j = zeros(1, no_late_files);
              for i = 1:no_late_files
                j(i) = find(late_matrix(i, 2) == scribble);
              end % for i
              [ignore, i] = sort(j);
              late_files = late_files(i);
              late_matrix = late_matrix(i, :);
            end % if ~islatedocked
        end % switch zone_ind
      end % if late_zigzag_on

      if early_zigzag_on
        switch zone_ind
          case {1, 2} % port, stbd
            i = 1:no_early_files; % vector of new indices
            for s = unique(early_matrix(:, 1))'
              for p = unique(early_matrix(early_matrix(:, 1) == s, 2))'
                j = find(early_matrix(:, 1) == s);
                j = j(early_matrix(j, 2) == p);
                i(j) = flipud(j);
              end % for p = unique(early_matrix(early_matrix(:, 1) == s, 2))'
            end % for s = unique(early_matrix(:, 1))'
            early_files = early_files(i);
            early_matrix = early_matrix(i, :);
          case 3 % nose_cap
            if islatedocked
              if ~ismajorchange % i.e. don't waste time, since redone below
                scribble = zigzag(late_matrix(late_index, 2), zz_segs); % dynamic
                no_early_segs = length(scribble);
                i = [];
                for j = 1:no_early_segs
                  i = cat(2, i, find(early_matrix(:, 2)' == scribble(j)));
                end % for j
                early_files = early_files(i);
                early_matrix = early_matrix(i, :);
                no_early_files = size(early_files, 1);
                early_left_index = 1;
                early_right_index = mod(early_left_index, no_early_files) + 1;
              end % if ~ismajorchange
            else % if ~islatedocked
              j = zeros(1, no_early_files);
              for i = 1:no_early_files
                j(i) = find(early_matrix(i, 2) == scribble);
              end % for i
              [ignore, i] = sort(j);
              early_files = early_files(i);
              early_matrix = early_matrix(i, :);
            end % if islatedocked
        end % switch zone_ind
      end % if early_zigzag_on

      if ~ismajorchange
        late_index = strmatch(late_file, late_files, 'exact'); % get new index from file
        if isempty(late_index), late_index = 1; end
        if ~ismajorearlyonlychange && ~issubtlechange
          early_left_index = strmatch(early_left_file, early_files, 'exact'); % get new index from file
          if isempty(early_left_index), early_left_index = 1; end
          early_right_index = mod(early_left_index, no_early_files) + 1;
        end % if ~ismajorearlyonlychange && ~issubtlechange
      end % if ~ismajorchange
    end % if no_late_files == 0 || no_early_files == 0

    islatechange = true; % overkill, but don't know how to make conditional
    isearlychange = true;
  end % if isrefresh

  % read old contrast stretching, if available
  if all(c) && (isshifted || ismajorchange || islatechange || isearlychange)
    AdjustContrastPosition = get(c(visible), 'Position');
    for i = trio
      [AdjustContrastVisible{i}, OutliersEditString{i}, ...
        MDRRadioButtonValue(i), EORadioButtonValue(i), ...
        MinEditString{i}, MaxEditString{i}] = ...
        readcontrast(c(i), 'this', 'Visible', 'outlier percent edit', 'String', ...
        'match data range radio', 'Value', 'eliminate outliers radio', 'Value', ...
        'window min edit', 'String', 'window max edit', 'String');
      [MinEditValue(i), MaxEditValue(i)] = ...
        split(str2double({MinEditString{i}, MaxEditString{i}}));
    end % for i
    if isshifted
      delete(c(~~c));
      c = zeros(1, 3);
    end % if isshifted
  end % if all(c) && (isshifted || ismajorchange || islatechange || isearlychange)

  if timetodie && ~isshifted
    figure(f1);
    subplot(s1);

    old_zoom_ax = axis; % grab old zoomed axis for calcs
    [f1, f2, s1, s2, s3, n1, keylink] = ...
      reopenfigures(EarlyFigureName, LateFigureName, isdualview);
    arenewfigures = true;
    timetodie = false;

    isnewlateimg = true;
    isnewearlyimg = true;
  end % if timetodie && ~isshifted

  if ismajorchange && no_late_files ~= 0 && no_early_files ~= 0
    [scan_late_ind, panel_late_ind, late_index] = ...
      makemajorchange(late_matrix, scan_late_ind, panel_late_ind, ds, dp);

    if zone_ind ~= 3 || ~islatedocked
      [scan_early_ind, panel_early_ind, early_left_index] = ...
        makemajorchange(early_matrix, scan_late_ind - ds, panel_late_ind - dp, ds, dp);
      early_right_index = mod(early_left_index, no_early_files) + 1;
    elseif early_zigzag_on % && zone_ind == 3 && islatedocked
      scribble = zigzag(late_matrix(late_index, 2), zz_segs); % dynamic
      no_early_segs = length(scribble);
      i = [];
      for j = 1:no_early_segs
        i = cat(2, i, find(early_matrix(:, 2)' == scribble(j)));
      end % for j
      early_files = early_files(i);
      early_matrix = early_matrix(i, :);
      no_early_files = size(early_files, 1);
      early_left_index = 1;
      early_right_index = mod(early_left_index, no_early_files) + 1;
    end % if zone_ind ~= 3 || ~islatedocked

    islatechange = true;
    isearlychange = zone_ind ~= 3 | ~islatedocked | early_zigzag_on;
  end % if ismajorchange && no_late_files ~= 0 && no_early_files ~= 0

  if ismajorearlyonlychange && no_early_files ~= 0
    [scan_early_ind, panel_early_ind, early_left_index] = ...
      makemajorchange(early_matrix, scan_early_ind, panel_early_ind, ds, dp);
    early_right_index = mod(early_left_index, no_early_files) + 1;

    isearlychange = true;
  end % if ismajorearlyonlychange && no_early_files ~= 0

  if islatechange
    if no_late_files == 0 || no_early_files == 0
      late_dir = matlab;
      late_file = yuck_file;
      info = imfinfo(yuck_fullfile);
    else % if no_late_files ~= 0 && no_early_files ~= 0
      late_file = late_files{late_index};
      try
        info = imfinfo(fullfile(late_dir, late_file));
      catch it
        switch it.identifier
          case 'MATLAB:tifftagsread:repackageTag:unrecognizedTagFormat'
            [info.Height info.Width] = size(imread(fullfile(late_dir, late_file)));
          otherwise
            rethrow(it)
        end % switch
      end % try
      [scan_late_ind, panel_late_ind] = ...
        split(late_matrix(late_index, 1:no_columns-1));
    end % if no_late_files == 0 || no_early_files == 0

    % reset grid
    xinc = 5;
    xbegin = 0;
    xend = info.Width;
    xtick = xbegin:xinc:xend;

    yinc = 5;
    ybegin = 0;
    yend = info.Height;
    ytick = ybegin:yinc:yend;

    m = info.Height;
    n = info.Width;
    orig_ax = [0 n 0 m] + .5;
    old_zoom_ax = orig_ax;

    % load image from file
    late_oimg = imread(fullfile(late_dir, late_file));

    % normalize image between 0 and 1
    switch class(late_oimg)
      case 'single' % from 32-bit tif
        late_aimg = imadjust(double(late_oimg)/255, []);
        late_aimg(isnan(late_oimg)) = NaN;
        late_oimg = late_aimg;
      otherwise
        late_oimg = im2double(late_oimg);
    end % switch class(late_oimg)

    % add dead pixel NaNs if not present
    if no_late_files ~= 0 && no_early_files ~= 0
      if ~any(any(isnan(late_oimg))) % i.e. if no NaNs, put them in
        mask = roicolor(late_oimg, 0, mithresh) & ...
          ~poly2mask(xy(:,1), xy(:,2), m, n); % near zero and outside octagon
        late_oimg(mask) = NaN;
      end % if ~any(any(isnan(late_oimg)))
    end % if no_late_files ~= 0 && no_early_files ~= 0

    isresetaxes = true;
    isshifted = false;
    isnewwarp = false;
    isrewarp = false;
    iswarpedleft = false;
    iswarpedright = false;
    ismerged = false;
    isnewlateimg = true;
    isfocusleft = true; % to ensure that focus and inhibit are not both "right"
    alternate = 3; % 1 is early_left, 2 is early_right, 3 is late
    inhibit = 2;   % 1 is early_left, 2 is early_right, 3 is neither
  end % if islatechange

  if isearlychange
    if no_late_files == 0 || no_early_files == 0
      early_dir = matlab;
      early_left_file = yuck_file;
      early_right_file = yuck_file;
    else % if no_late_files ~= 0 && no_early_files ~= 0
      early_left_file = early_files{early_left_index};
      early_right_file = early_files{early_right_index};
      [scan_early_ind, panel_early_ind] = ...
        split(early_matrix(early_left_index, 1:no_columns-1));
    end % if no_late_files == 0 || no_early_files == 0

    % load images from file
    early_left_oimg = imread(fullfile(early_dir, early_left_file));
    early_right_oimg = imread(fullfile(early_dir, early_right_file));

    % normalize images between 0 and 1
    switch class(early_left_oimg)
      case 'single' % from 32-bit tif
        early_left_aimg = imadjust(double(early_left_oimg)/255, []);
        early_right_aimg = imadjust(double(early_right_oimg)/255, []);
        early_left_aimg(isnan(early_left_oimg)) = NaN;
        early_right_aimg(isnan(early_right_oimg)) = NaN;
        early_left_oimg = early_left_aimg;
        early_right_oimg = early_right_aimg;
      otherwise
        early_left_oimg = im2double(early_left_oimg);
        early_right_oimg = im2double(early_right_oimg);
    end % switch class(early_left_oimg)

    % add dead pixel NaNs if not present
    if no_late_files ~= 0 && no_early_files ~= 0
      if ~any(any(isnan(early_left_oimg))) % i.e. if no NaNs, put them in
        mask = roicolor(early_left_oimg, 0, mithresh) & ~poly2mask(xy(:,1), xy(:,2), m, n);
        early_left_oimg(mask) = NaN;
      end % if ~any(any(isnan(early_left_oimg)))
      if ~any(any(isnan(early_right_oimg))) % i.e. if no NaNs, put them in
        mask = roicolor(early_right_oimg, 0, mithresh) & ~poly2mask(xy(:,1), xy(:,2), m, n);
        early_right_oimg(mask) = NaN;
      end % if ~any(any(isnan(early_right_oimg)))
    end % if no_late_files ~= 0 && no_early_files ~= 0

    isresetaxes = true;
    isshifted = false;
    isnewwarp = false;
    isrewarp = false;
    iswarpedleft = false;
    iswarpedright = false;
    ismerged = false;
    isnewearlyimg = true;
    isfocusleft = true; % to ensure that focus and inhibit are not both "right"
    alternate = 3; % 1 is early_left, 2 is early_right, 3 is late
    inhibit = 2;   % 1 is early_left, 2 is early_right, 3 is neither
  end % if isearlychange

  if isresetaxes
    [dx_left dy_left dx_right dy_right] = deal(0);
    [late_ax early_left_ax early_right_ax new_ax] = deal(orig_ax); % reset axes

    isresetaxes = false;
  end % if isresetaxes

  if isshifted
    % new image always, especially to get IMCONTRAST back if aborted registration
    isnewlateimg = true;
    isresetaxes = false;

    % apply contrast stretching, if possible, put back NaNs, if necessary
    if isstretched(1)
      early_left_cimg = ...
        imadjust(early_left_oimg, [MinEditValue(1) MaxEditValue(1)]);
      early_left_cimg(isnan(early_left_oimg)) = NaN;
    else % if ~isstretched(1)
      early_left_cimg = early_left_oimg;
    end % if isstretched(1)

    if isstretched(2)
      early_right_cimg = ...
        imadjust(early_right_oimg, [MinEditValue(2) MaxEditValue(2)]);
      early_right_cimg(isnan(early_right_oimg)) = NaN;
    else % if ~isstretched(2)
      early_right_cimg = early_right_oimg;
    end % if isstretched(2)

    if isstretched(3)
      late_cimg = ...
        imadjust(late_oimg, [MinEditValue(3) MaxEditValue(3)]);
      late_cimg(isnan(late_oimg)) = NaN;
    else % if ~isstretched(3)
      late_cimg = late_oimg;
    end % if isstretched(3)

    if isnewwarp
      isnewwarp = false; % don't do it a second time

      if ~isrewarp
        [ip, bp] = deal([]); % fresh start
      end % if ~isrewarp

      % get input and base points
      if isfocusleft
        [bp, ip] = register(late_cimg, early_left_cimg, bp, ip);
      else % if ~isfocusleft % i.e. right
        [bp, ip] = register(late_cimg, early_right_cimg, bp, ip);
      end % if isfocusleft

      if ~isempty(ip) && ~isempty(bp)
        isrewarp = true;
        ismerged = true;

        no_pairs = size(bp, 1);

        switch no_pairs
          case 1
            % transform only
          case 2
            tform_type = 'nonreflective similarity';
          case 3
            tform_type = 'affine';
          otherwise % >= 4
            tform_type = 'projective';
        end % switch no_pairs

        % tweak input points, if necessary
        if issnapped
          if isfocusleft
            ip = cpcorr(ip, bp, early_left_cimg, late_cimg);
          else % if ~isfocusleft % i.e. right
            ip = cpcorr(ip, bp, early_right_cimg, late_cimg);
          end % if isfocusleft
        end % if issnapped

        if no_pairs == 1 % translation only
          [dx dy] = split(round(diff([bp; ip]))); % force integers
          if isfocusleft
            dx_left = dx;
            dy_left = dy;
            early_left_wimg = early_left_cimg;
          else % if ~isfocusleft
            dx_right = dx;
            dy_right = dy;
            early_right_wimg = early_right_cimg;
          end % if isfocusleft
        else % if no_pairs ~= 1
          % determine transformation
          transformation = cp2tform(ip, bp, tform_type);
          if isfocusleft
            early_left_wimg = imtransform(early_left_cimg, transformation, ...
              'XData', [1 n], 'YData', [1 m], 'FillValues', NaN);
          else % if ~isfocusleft % i.e. right
            early_right_wimg = imtransform(early_right_cimg, transformation, ...
              'XData', [1 n], 'YData', [1 m], 'FillValues', NaN);
          end % if isfocusleft

          % reset appropriate axis and differences
          if isfocusleft
            [dx_left dy_left] = deal(0);
            early_left_ax = late_ax;
            iswarpedleft = true;
          else % if ~isfocusleft % i.e. right
            [dx_right dy_right] = deal(0);
            early_right_ax = late_ax;
            iswarpedright = true;
          end % if isfocusleft
        end % if no_pairs == 1
      else % if isempty(ip) || isempty(bp)
        isshifted = iswarpedleft | iswarpedright;
        if isfocusleft
          early_left_wimg = early_left_cimg;
        else % if ~isfocusleft % i.e. right
          early_right_wimg = early_right_cimg;
        end % if isfocusleft
      end % if ~isempty(ip) && ~isempty(bp)
    else % if ~isnewwarp
      if ~iswarpedleft
        early_left_wimg = early_left_cimg;
      end % if ~iswarpedleft
      if ~iswarpedright
        early_right_wimg = early_right_cimg;
      end % if ~iswarpedright
    end % if isnewwarp
  end % if isshifted

  if isshifted % could have changed from above condition
    if ismerged
      dx_middle = dx_right - dx_left;
      dy_middle = dy_right - dy_left;
      late_ax = orig_ax; % reset alt axes
      early_left_ax = [dx_left dx_left+n dy_left dy_left+m] +.5;
      early_right_ax = [dx_right dx_right+n dy_right dy_right+m] + .5;
    else % if ~ismerged
      dx_left = early_left_ax(1) - late_ax(1);
      dy_left = early_left_ax(3) - late_ax(3);
      dx_right = early_right_ax(1) - late_ax(1);
      dy_right = early_right_ax(3) - late_ax(3);
      dx_middle = early_right_ax(1) - early_left_ax(1);
      dy_middle = early_right_ax(3) - early_left_ax(3);
    end % if ismerged

    % intersect early_left and late
    if dx_left > 0
      early_left_xmax = n;
      late_left_xmin = 1;
      early_left_xmin = late_left_xmin + dx_left;
      late_left_xmax = early_left_xmax - dx_left;
    else % if dx_left <= 0
      early_left_xmin = 1;
      late_left_xmax = n;
      early_left_xmax = late_left_xmax + dx_left;
      late_left_xmin = early_left_xmin - dx_left;
    end % if dx_left > 0
    if dy_left > 0
      early_left_ymax = m;
      late_left_ymin = 1;
      early_left_ymin = late_left_ymin + dy_left;
      late_left_ymax = early_left_ymax - dy_left;
    else % if dy_left <= 0
      early_left_ymin = 1;
      late_left_ymax = m;
      early_left_ymax = late_left_ymax + dy_left;
      late_left_ymin = early_left_ymin - dy_left;
    end % if dy_left > 0

    % intersect early_right and late
    if dx_right > 0
      early_right_xmax = n;
      late_right_xmin = 1;
      early_right_xmin = late_right_xmin + dx_right;
      late_right_xmax = early_right_xmax - dx_right;
    else % if dx_right <= 0
      early_right_xmin = 1;
      late_right_xmax = n;
      early_right_xmax = late_right_xmax + dx_right;
      late_right_xmin = early_right_xmin - dx_right;
    end % if dx_right > 0
    if dy_right > 0
      early_right_ymax = m;
      late_right_ymin = 1;
      early_right_ymin = late_right_ymin + dy_right;
      late_right_ymax = early_right_ymax - dy_right;
    else % if dy_right <= 0
      early_right_ymin = 1;
      late_right_ymax = m;
      early_right_ymax = late_right_ymax + dy_right;
      late_right_ymin = early_right_ymin - dy_right;
    end % if dy_right > 0

    % intersect early_left and early_right
    if dx_middle > 0
      early_right_middle_xmax = n;
      early_left_middle_xmin = 1;
      early_right_middle_xmin = early_left_middle_xmin + dx_middle;
      early_left_middle_xmax = early_right_middle_xmax - dx_middle;
    else % if dx_middle <= 0
      early_right_middle_xmin = 1;
      early_left_middle_xmax = n;
      early_right_middle_xmax = early_left_middle_xmax + dx_middle;
      early_left_middle_xmin = early_right_middle_xmin - dx_middle;
    end % if dx_middle > 0
    if dy_middle > 0
      early_right_middle_ymax = m;
      early_left_middle_ymin = 1;
      early_right_middle_ymin = early_left_middle_ymin + dy_middle;
      early_left_middle_ymax = early_right_middle_ymax - dy_middle;
    else % if dy_middle <= 0
      early_right_middle_ymin = 1;
      early_left_middle_ymax = m;
      early_right_middle_ymax = early_left_middle_ymax + dy_middle;
      early_left_middle_ymin = early_right_middle_ymin - dy_middle;
    end % if dy_middle > 0

    if ismerged
      % intersect early_left and early_right and late
      [early_left_mask early_right_mask ...
        early_left_middle_mask early_right_middle_mask ...
        late_left_mask late_right_mask] = deal(false(m, n));
      early_left_mask(early_left_ymin:early_left_ymax, ...
        early_left_xmin:early_left_xmax) = ...
        true(early_left_ymax - early_left_ymin + 1, ...
        early_left_xmax - early_left_xmin + 1);
      early_right_mask(early_right_ymin:early_right_ymax, ...
        early_right_xmin:early_right_xmax) = ...
        true(early_right_ymax - early_right_ymin + 1, ...
        early_right_xmax - early_right_xmin + 1);
      early_left_middle_mask(early_left_middle_ymin:early_left_middle_ymax, ...
        early_left_middle_xmin:early_left_middle_xmax) = ...
        true(early_left_middle_ymax - early_left_middle_ymin + 1, ...
        early_left_middle_xmax - early_left_middle_xmin + 1);
      early_right_middle_mask(early_right_middle_ymin:early_right_middle_ymax, ...
        early_right_middle_xmin:early_right_middle_xmax) = ...
        true(early_right_middle_ymax - early_right_middle_ymin + 1, ...
        early_right_middle_xmax - early_right_middle_xmin + 1);
      late_left_mask(late_left_ymin:late_left_ymax, ...
        late_left_xmin:late_left_xmax) = ...
        true(late_left_ymax - late_left_ymin + 1, ...
        late_left_xmax - late_left_xmin + 1);
      late_right_mask(late_right_ymin:late_right_ymax, ...
        late_right_xmin:late_right_xmax) = ...
        true(late_right_ymax - late_right_ymin + 1, ...
        late_right_xmax - late_right_xmin + 1);

      early_left_triple_mask = early_left_mask & early_left_middle_mask;
      early_right_triple_mask = early_right_mask & early_right_middle_mask;
      late_triple_mask = late_left_mask & late_right_mask;

      [i, j] = find(early_left_triple_mask);
      [early_left_triple_ymin early_left_triple_ymax ...
        early_left_triple_xmin early_left_triple_xmax] = ...
        deal(min(i), max(i), min(j), max(j));
      [i, j] = find(early_right_triple_mask);
      [early_right_triple_ymin early_right_triple_ymax ...
        early_right_triple_xmin early_right_triple_xmax] = ...
        deal(min(i), max(i), min(j), max(j));
      [i, j] = find(late_triple_mask);
      [late_triple_ymin late_triple_ymax ...
        late_triple_xmin late_triple_xmax] = ...
        deal(min(i), max(i), min(j), max(j));

      % process the intersections
      intersection_left = ...
        zeros(late_left_ymax - late_left_ymin + 1, ...
        late_left_xmax - late_left_xmin + 1, ...
        (inhibit ~= 1) + 2*(~isfocusleft && iswhitened));
      layer = 1;
      if inhibit ~= 1
        intersection_left(:, :, layer) = ...
          early_left_wimg(early_left_ymin:early_left_ymax, ...
          early_left_xmin:early_left_xmax);
        layer = layer + 1;
      end % if inhibit ~= 1
      intersection_left(:, :, layer) = ...
        late_cimg(late_left_ymin:late_left_ymax, ...
        late_left_xmin:late_left_xmax);
      if ~isfocusleft && iswhitened
        layer = layer + 1;
        intersection_left(:, :, layer) = ...
          ones(late_left_ymax - late_left_ymin + 1, ...
          late_left_xmax - late_left_xmin + 1);
        layer = layer + 1;
        intersection_left(:, :, layer) = ...
          ones(late_left_ymax - late_left_ymin + 1, ...
          late_left_xmax - late_left_xmin + 1);
      end % if ~isfocusleft && iswhitened

      intersection_right = ...
        zeros(late_right_ymax - late_right_ymin + 1, ...
        late_right_xmax - late_right_xmin + 1, ...
        (inhibit ~= 2) + 2*(isfocusleft && iswhitened));
      layer = 1;
      if inhibit ~= 2
        intersection_right(:, :, layer) = ...
          early_right_wimg(early_right_ymin:early_right_ymax, ...
          early_right_xmin:early_right_xmax);
        layer = layer + 1;
      end % if inhibit ~= 2
      intersection_right(:, :, layer) = ...
        late_cimg(late_right_ymin:late_right_ymax, ...
        late_right_xmin:late_right_xmax);

      % iswhitened
      if isfocusleft && iswhitened
        layer = layer + 1;
        intersection_right(:, :, layer) = ...
          ones(late_right_ymax - late_right_ymin + 1, ...
          late_right_xmax - late_right_xmin + 1);
        layer = layer + 1;
        intersection_right(:, :, layer) = ...
          ones(late_right_ymax - late_right_ymin + 1, ...
          late_right_xmax - late_right_xmin + 1);
      end % if isfocusleft && iswhitened

      intersection_triple = ...
        zeros(late_triple_ymax - late_triple_ymin + 1, ...
        late_triple_xmax - late_triple_xmin + 1, ...
        (inhibit ~= 1) + (inhibit ~= 2) + 2*iswhitened);
      layer = 1;
      if inhibit ~= 1
        intersection_triple(:, :, layer) = ...
          early_left_wimg(early_left_triple_ymin:early_left_triple_ymax, ...
          early_left_triple_xmin:early_left_triple_xmax);
        layer = layer + 1;
      end % if inhibit ~= 1
      if inhibit ~= 2
        intersection_triple(:, :, layer) = ...
          early_right_wimg(early_right_triple_ymin:early_right_triple_ymax, ...
          early_right_triple_xmin:early_right_triple_xmax);
        layer = layer + 1;
      end % if inhibit ~= 2
      intersection_triple(:, :, layer) = ...
        late_cimg(late_triple_ymin:late_triple_ymax, ...
        late_triple_xmin:late_triple_xmax);
      if iswhitened
        layer = layer + 1;
        intersection_triple(:, :, layer) = ...
          ones(late_triple_ymax - late_triple_ymin + 1, ...
          late_triple_xmax - late_triple_xmin + 1);
        layer = layer + 1;
        intersection_triple(:, :, layer) = ...
          ones(late_triple_ymax - late_triple_ymin + 1, ...
          late_triple_xmax - late_triple_xmin + 1);
      end % if iswhitened

      intersection_left = nanmean(intersection_left, 3);
      intersection_right = nanmean(intersection_right, 3);
      intersection_triple = nanmean(intersection_triple, 3);

      late_img = late_cimg;
      late_img(late_left_ymin:late_left_ymax, ...
        late_left_xmin:late_left_xmax) = intersection_left;
      late_img(late_right_ymin:late_right_ymax, ...
        late_right_xmin:late_right_xmax) = intersection_right;
      late_img(late_triple_ymin:late_triple_ymax, ...
        late_triple_xmin:late_triple_xmax) = intersection_triple;
    else % if ~ismerged
      switch alternate
        case 1
          late_img = early_left_wimg;
        case 2
          late_img = early_right_wimg;
        case 3
          late_img = late_cimg;
      end % switch alternate
    end % if ismerged
  else % if ~isshifted
    early_left_img = early_left_oimg;
    early_right_img = early_right_oimg;
    late_img = late_oimg;
  end % if isshifted

  if isnewlateimg
    figure(f1);
    subplot(s3);

    if iskey && ~number
      old_ax = new_ax; % grab old axis for calcs
      if ~arenewfigures
        if islatechange
          old_zoom_ax = old_ax;
        else % if ~islatechange
          old_zoom_ax = axis; % grab old zoomed axis for calcs
        end % if islatechange
      end % if ~arenewfigures
      imshow(late_img); % uses original axes by default
      new_ax = orig_ax;
      new_zoom_ax = new_ax - old_ax + old_zoom_ax;
      axis(new_zoom_ax);
    end % if iskey && ~number

    if isshifted
      if ismerged
        switch inhibit
          case 1 % left
            ttl = ...
              sprintf('%s (early - 2) merged with %s (late - 3)', ...
              early_right_file, late_file);
          case 2 % right
            ttl = ...
              sprintf('%s (early - 1) merged with %s (late - 3)', ...
              early_left_file, late_file);
          case 3 % neither
            ttl = ...
              sprintf('%s (early - 1) and %s (early - 2) merged with %s (late - 3)', ...
              early_left_file, early_right_file, late_file);
        end % switch inhibit
      else % if ~ismerged
        key = '';
        set(gcf, 'UserData', ''); % clear old keys
        while isempty(key)
          if isautoalternate
            tic; % restart timer
            alternate = number - alternate; % toggle
          else % if ~isautoalternate
            number = 0;
          end % if isautoalternate
          while (~isautoalternate || toc < delay) && isempty(key)
            key = split(get(gcf, 'UserData'));
            if isautoalternate
              switch key
                case {'4', '5'}
                  isautoalternate = false;
                  alternate = 3;
                  number = 0;
                otherwise
                  key = ''; % stay in inner while loop
              end % switch key
            end % if isautoalternate
            if ~isautoalternate
              key = ' '; % force exit of inner while loop
            end % if ~isautoalternate
          end % while (~isautoalternate || toc < delay) && isempty(key)
          figure(f1); % force display to late image
          old_ax = new_ax; % grab old axis for calcs
          old_zoom_ax = axis; % grab old zoomed axis for calcs
          switch alternate
            case 1
              imshow(early_left_wimg);
              ttl = sprintf('%s (early - 1)', early_left_file);
              new_ax = early_left_ax;
            case 2
              imshow(early_right_wimg);
              ttl = sprintf('%s (early - 2)', early_right_file);
              new_ax = early_right_ax;
            case 3
              imshow(late_cimg);
              ttl = sprintf('%s (late - 3)', late_file);
              new_ax = late_ax;
          end % switch alternate
          new_zoom_ax = new_ax - old_ax + old_zoom_ax;
          axis(new_zoom_ax);
          if isautoalternate
            title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
            axis equal % do NOT set to axis image -- screws up moved axes
            axis manual % to keep out of automatic mode
            drawnow;
          end % if isautoalternate
        end % while isempty(key)
      end % if ismerged
    else % if ~isshifted
      ttl = sprintf('%s (late - 3)', late_file);
    end % if isshifted

    if ~ismerged
      set(s3, 'XTick', xtick, 'YTick', ytick);
      if grid_on
        grid on
        axis on
      else % if ~grid_on
        grid off
        axis off
      end % if grid_on
    end % if ~ismerged
    title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
    axis equal % do NOT set to axis image -- screws up moved axes
    axis manual % to keep out of automatic mode

    % invoke contrast function
    if ~isshifted
      s = [s1 s2 s3];
      v = ~[isempty(imhandles(s1)) isempty(imhandles(s2)) isempty(imhandles(s3))];
      mask = v & ~(c & ishandle(c)); % using Karnaugh map
      for i = trio(mask)
        [c(i), OutliersEditCallback{i}, MinMaxEditCallback{i}] = ...
          opencontrast(s(i), AdjustContrastPosition, AdjustContrastVisible{i}, ...
          OutliersEditString{i}, MDRRadioButtonValue(i), EORadioButtonValue(i));
        addtarget(keylink, c(i));
        switch i
          case {1, 2}
            if ~isearlychange
              writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                'window max edit', 'String', MaxEditString{i});
              MinMaxEditCallback{i}(); % same as typing in textbox
            end % if ~isearlychange
            putonsame(c(i), f2);
          case 3
            if ~islatechange
              writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                'window max edit', 'String', MaxEditString{i});
              MinMaxEditCallback{i}(); % same as typing in textbox
            end % if ~islatechange
            putonsame(c(i), f1);
        end % switch i
        timetodie = timetodie | div(iteration + 1, lifespan);
        iteration = mod(iteration + 1, lifespan);
        % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);
      end % for i
    end % if ~isshifted
  end % if isnewlateimg

  if isnewearlyimg
    figure(f2);
    subplot(s1);
    imshow(early_left_img);

    ttl = sprintf('%s (early - 1)', early_left_file);
    title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
    axis equal % do NOT set to axis image -- screws up moved axes
    axis manual % to keep out of automatic mode

    subplot(s2);
    h = imshow(early_right_img);
    ttl = sprintf('%s (early - 2)', early_right_file);
    t = title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
    if ~isdualview
      set([h t], 'Visible', 'off'); % disable & hide
    end % if ~isdualview
    axis equal % do NOT set to axis image -- screws up moved axes
    axis manual % to keep out of automatic mode

    % invoke contrast function
    if ~isshifted
      s = [s1 s2 s3];
      v = ~[isempty(imhandles(s1)) isempty(imhandles(s2)) isempty(imhandles(s3))];
      mask = v & ~(c & ishandle(c)); % using Karnaugh map
      for i = trio(mask)
        [c(i), OutliersEditCallback{i}, MinMaxEditCallback{i}] = ...
          opencontrast(s(i), AdjustContrastPosition, AdjustContrastVisible{i}, ...
          OutliersEditString{i}, MDRRadioButtonValue(i), EORadioButtonValue(i));
        addtarget(keylink, c(i));
        switch i
          case {1, 2}
            if ~isearlychange
              writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                'window max edit', 'String', MaxEditString{i});
              MinMaxEditCallback{i}(); % same as typing in textbox
            end % if ~isearlychange
            putonsame(c(i), f2);
          case 3
            if ~islatechange
              writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                'window max edit', 'String', MaxEditString{i});
              MinMaxEditCallback{i}(); % same as typing in textbox
            end % if ~islatechange
            putonsame(c(i), f1);
        end % switch i
        timetodie = timetodie | div(iteration + 1, lifespan);
        iteration = mod(iteration + 1, lifespan);
        % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);
      end % for i
    end % if ~isshifted
  end % if isnewearlyimg

  if ismajorchange
    figure(f1); % put mouse focus back on late image
  end % if ismajorchange

  switch zone_ind
    case 1
      status(1, :) = sprintf('   Zone: \t Port   ');
    case 2
      status(1, :) = sprintf('   Zone: \t Stbd   ');
    case 3
      status(1, :) = sprintf('   Zone: \t Nose   ');
  end % switch zone_ind

  switch 2*early_zigzag_on + late_zigzag_on
    case 0
      status(2, :) = sprintf(' Zigzag: \t none   ');
    case 1
      status(2, :) = sprintf(' Zigzag: \t late   ');
    case 2
      status(2, :) = sprintf(' Zigzag: \t early  ');
    case 3
      status(2, :) = sprintf(' Zigzag: \t both   ');
  end % switch 2*early_zigzag_on + late_zigzag_on

  if isdualview
    status(3, :) = sprintf('  Early: \t dual   ');
  else % if ~isdualview
    status(3, :) = sprintf('  Early: \t mono   ');
  end % if isdualview

  if ismerged
    status(4, :) = sprintf(' Merged: \t on     ');
  else % if ~ismerged
    status(4, :) = sprintf(' Merged: \t off    ');
  end % if ismerged

  switch 2*isfocusleft + isdualview
    case {0, 2}
      status(5, :) = sprintf('  Focus: \t N/A    ');
    case 1
      status(5, :) = sprintf('  Focus: \t right  ');
    case 3
      status(5, :) = sprintf('  Focus: \t left   ');
  end % if isfocusleft + 2*isdualview

  switch inhibit * isdualview
    case 0
      status(6, :) = sprintf('Inhibit: \t N/A    ');
    case 1
      status(6, :) = sprintf('Inhibit: \t left   ');
    case 2
      status(6, :) = sprintf('Inhibit: \t right  ');
    case 3
      status(6, :) = sprintf('Inhibit: \t neither');
  end % switch inhibit * isdualview

  if issnapped
    status(7, :) = sprintf('Snapped: \t on     ');
  else % if ~issnapped
    status(7, :) = sprintf('Snapped: \t off    ');
  end % if issnapped

  if iswhitened
    status(8, :) = sprintf(' Whiten: \t on     ');
  else % if ~iswhitened
    status(8, :) = sprintf(' Whiten: \t off    ');
  end % if iswhitened

  if grid_on
    status(9, :) = sprintf('   Grid: \t on     ');
  else % if ~grid_on
    status(9, :) = sprintf('   Grid: \t off    ');
  end % if grid_on

  status(10, :) = sprintf('   Jump: \t %-3d    ', jump);

  set(n1, 'String', status);

  arenewfigures = false;
  isrefresh = false;
  ismajorchange = false;
  ismajorearlyonlychange = false;
  issubtlechange = false;
  [ds dp] = deal(0);
  islatechange = false;
  isearlychange = false;
  isnewlateimg = false;
  isnewearlyimg = false;
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
        switch gcf
          case f1
            if zone_ind ~= 3 && ~islatedocked
              late_zigzag_on = ~late_zigzag_on;
              isrefresh = true;
            end % if zone_ind ~= 3 && ~islatedocked
          case f2
            early_zigzag_on = ~early_zigzag_on;
            isrefresh = true;
        end
      case 'p'
        if zone_ind ~= 1
          zone_ind = 1;
          isrefresh = true;
          ismajorchange = true;
          late_zigzag_on = false;
          early_zigzag_on = false;
        end % if zone_ind ~= 1
      case 's'
        if zone_ind ~= 2
          zone_ind = 2;
          isrefresh = true;
          ismajorchange = true;
          late_zigzag_on = false;
          early_zigzag_on = false;
        end % if zone_ind ~= 2
      case 'n'
        if zone_ind ~= 3
          zone_ind = 3;
          isrefresh = true;
          ismajorchange = true;
          if islatedocked
            late_zigzag_on = false;
            early_zigzag_on = true;
          else % if ~islatedocked
            late_zigzag_on = false;
            early_zigzag_on = false;
          end % if islatedocked
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
        switch gcf
          case f1
            ismajorchange = logical(ds);
          case f2
            ismajorearlyonlychange = logical(ds);
        end % switch gcf
      case 'leftbracket'
        switch zone_ind
          case 1 % port
            dp = -1;
          case 2 % starboard
            dp = +1;
          case 3 % nose
            dp = -1;
        end % switch zone_ind
        switch gcf
          case f1
            ismajorchange = logical(dp);
            isrefresh = zone_ind == 3 & islatedocked & early_zigzag_on;
          case f2
            ismajorearlyonlychange = logical(dp);
        end % switch gcf
      case 'rightbracket'
        switch zone_ind
          case 1 % port
            dp = +1;
          case 2 % starboard
            dp = -1;
          case 3 % nose
            dp = +1;
        end % switch zone_ind
        switch gcf
          case f1
            ismajorchange = logical(dp);
            isrefresh = zone_ind == 3 & islatedocked & early_zigzag_on;
          case f2
            ismajorearlyonlychange = logical(dp);
        end % switch gcf
      case 'pageup'
        switch gcf
          case f1
            if zone_ind == 3 && islatedocked && early_zigzag_on
              p = late_matrix(late_index, 2);
            end % if zone_ind == 3 && islatedocked && early_zigzag_on
            late_index = mod(late_index - 1 - 1, no_late_files) + 1;
            islatechange = true;
            if zone_ind == 3 && islatedocked && early_zigzag_on
              issubtlechange = late_matrix(late_index, 2) ~= p;
              isrefresh = issubtlechange;
            end % if zone_ind == 3 && islatedocked && early_zigzag_on
          case f2
            early_left_index = mod(early_left_index - 1 - 1, no_early_files) + 1;
            early_right_index = mod(early_right_index - 1 - 1, no_early_files) + 1;
            isearlychange = true;
            if isshifted
              islatechange = true;
            end % if isshifted
        end % switch gcf
      case 'pagedown'
        switch gcf
          case f1
            if zone_ind == 3 && islatedocked && early_zigzag_on
              p = late_matrix(late_index, 2);
            end % if zone_ind == 3 && islatedocked && early_zigzag_on
            late_index = mod(late_index - 1 + 1, no_late_files) + 1;
            islatechange = true;
            if zone_ind == 3 && islatedocked && early_zigzag_on
              issubtlechange = late_matrix(late_index, 2) ~= p;
              isrefresh = issubtlechange;
            end % if zone_ind == 3 && islatedocked && early_zigzag_on
          case f2
            early_left_index = mod(early_left_index - 1 + 1, no_early_files) + 1;
            early_right_index = mod(early_right_index - 1 + 1, no_early_files) + 1;
            isearlychange = true;
            if isshifted
              islatechange = true;
            end % if isshifted
        end % switch gcf
      case 'space'
        isdualview = ~isdualview;
        h = imhandles(s2);
        t = get(s2, 'Title');
        if isdualview
          pos = get(s2, 'Position'); pos(1) = pos(1) - .5;
          set(s1, 'Position', pos);  % shrink
          set([h t], 'Visible', 'on');  % enable & show
        else % if ~isdualview
          pos = get(s3, 'Position');
          set(s1, 'Position', pos);  % grow
          set([h t], 'Visible', 'off'); % disable & hide
          isfocusleft = true;
          inhibit = 2;
          alternate = 3;
          if visible == 2 % swap contrast tool, if necessary
            if ~isshifted
              AdjustContrastPosition = get(c(visible), 'Position');
              AdjustContrastVisible{visible} = 'off';
              set(c(visible), 'Visible', 'off');
            end % if ~isshifted
            visible = 1;
            if ~isshifted
              AdjustContrastVisible{visible} = 'on';
              set(c(visible), 'Position', AdjustContrastPosition, 'Visible', 'on');
              putontop(c(visible));
            end % if ~isshifted
          end % if visible
        end % if isdualview
      case 'l'
        figure(f1);
        subplot(s3);
        xbegin = xbegin - 1;
        xend = xend - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'r'
        figure(f1);
        subplot(s3);
        xbegin = xbegin + 1;
        xend = xend + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'u'
        figure(f1);
        subplot(s3);
        ybegin = ybegin - 1;
        yend = yend - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'd'
        figure(f1);
        subplot(s3);
        ybegin = ybegin + 1;
        yend = yend + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'multiply' % keypad *
        figure(f1);
        subplot(s3);
        xinc = xinc * 2;
        yinc = yinc * 2;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'divide' % keypad /
        figure(f1);
        subplot(s3);
        xinc = xinc / 2;
        yinc = yinc / 2;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'add' % keypad +
        figure(f1);
        subplot(s3);
        xinc = xinc + 1;
        yinc = yinc + 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'subtract' % keypad -
        figure(f1);
        subplot(s3);
        xinc = xinc - 1;
        yinc = yinc - 1;
        xtick = xbegin:xinc:xend;
        ytick = ybegin:yinc:yend;
        set(s3, 'XTick', xtick, 'YTick', ytick);
      case 'g'
        grid_on = ~grid_on;
        figure(f1);
        subplot(s3);
        if grid_on
          grid on
          axis on
        else % if ~grid_on
          grid off
          axis off
        end % if grid_on
      case 'period'
        issnapped = ~issnapped;
      case 'e'
        if isscreener
          [ignore, filename] = fileparts(fullfile(late_dir, late_file));
          ua_file = [filename '_ua.jpg'];
          an_file = [filename '_an.jpg'];
          if zone_ind == 3 % i.e. if Nose Cap
            ua_fullfile = fullfile(directory, obss_late_dir, zone, working_dir, ua_file);
            an_fullfile = fullfile(directory, obss_late_dir, zone, working_dir, an_file);
          else % if zone_ind ~= 3
            panel = panels{panel_late_ind};
            ua_fullfile = fullfile(directory, obss_late_dir, zone, panel, working_dir, ua_file);
            an_fullfile = fullfile(directory, obss_late_dir, zone, panel, working_dir, an_file);
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
            an_dir = fileparts(ua_fullfile);
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
              if isstretched(3)
                if c(3)
                  [MinEditString{3}, MaxEditString{3}] = ...
                    readcontrast(c(3), 'window min edit', 'String', ...
                    'window max edit', 'String');
                  [MinEditValue(3), MaxEditValue(3)] = ...
                    split(str2double({MinEditString{3}, MaxEditString{3}}));
                end % if c(3)
                late_cimg = ...
                  imadjust(late_oimg, [MinEditValue(3) MaxEditValue(3)]);
                late_cimg(isnan(late_oimg)) = NaN;
              else % if ~isstretched(3)
                late_cimg = late_oimg;
              end % if isstretched(3)
              imwrite(late_cimg, ua_fullfile, 'Quality', 100);
              imwrite(late_cimg, an_fullfile, 'Quality', 100);
              command = sprintf('start /max photoshop %s', an_fullfile);
              system(command);
            end % if ~success
          end % if modify
        else % if ~isscreener
          destination = fullfile(tempdir, late_file); % generate temporary filename
          imwrite(late_img, destination, 'Compression', 'none');
          command = sprintf('start /max photoshop %s', destination);
          system(command);
        end % if isscreener
      case 'home'
        isresetaxes = true;
      case 'j'
        switch character % disambiguate
          case 'J'
            jump = min(jump * 2, 512);
          case 'j'
            jump = max(jump / 2, 1);
        end % switch character
      case {'leftarrow', 'rightarrow', 'uparrow', 'downarrow'}
        isshifted = true;
        switch key
          case 'leftarrow'
            dj = [jump 0];
          case 'rightarrow'
            dj = [-jump 0];
          case 'uparrow'
            dj = [0 jump];
          case 'downarrow'
            dj = [0 -jump];
        end % switch key
        if ismerged
          if isfocusleft
            dx_left = dx_left + dj(1);
            dy_left = dy_left + dj(2);
          else % if ~isfocusleft
            dx_right = dx_right + dj(1);
            dy_right = dy_right + dj(2);
          end % if isfocusleft
        else % if ~ismerged
          dax = dj([1 1 2 2]);
          %dax = reshape(repmat(dj, 2, 1), 1, 4);
          switch alternate
            case 1
              early_left_ax = early_left_ax + dax;
            case 2
              early_right_ax = early_right_ax + dax;
            case 3
              late_ax = late_ax + dax;
          end
        end % if ismerged
      case 'x'
        figure(f1);
        subplot(s3);
        if ismerged
          isrewarp = true;
          isshifted = true;
          xlabel('Click early image first, then click late image last (will try to auto correct).', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
          [x, y] = ginput(2);
          xlabel('', 'Visible', 'off');

          % snap to grid
          if isfocusleft
            [x1, y1, r1] = snap(x, y, late_cimg, early_left_cimg);
            [x2, y2, r2] = snap(x, y, early_left_cimg, late_cimg);
          else % if ~isfocusleft
            [x1, y1, r1] = snap(x, y, late_cimg, early_right_cimg);
            [x2, y2, r2] = snap(x, y, early_right_cimg, late_cimg);
          end % if isfocusleft

          if r1 > .85 || (r2 <= .85 && r1 > r2)
            if issnapped
              [x, y] = deal(flipud(x1), flipud(y1));
            else % if ~issnapped
              [x, y] = deal(flipud(x), flipud(y));
            end % if issnapped
          else % if r1 <= .85 && (r2 > .85 || r1 <= r2)
            if issnapped
              [x, y] = deal(x2, y2);
            else % if ~issnapped
              % already correct
            end % if issnapped
          end % if r1 > .85 || (r2 <= .85 && r1 > r2)

          bp = [x(1) y(1)]; % remember for rewarping
          ip = [x(2) y(2)];

          % continue
          dx = diff(round(x));
          dy = diff(round(y));
          if isfocusleft
            dx_left = dx_left + dx;
            dy_left = dy_left + dy;
          else % if ~isfocusleft
            dx_right = dx_right + dx;
            dy_right = dy_right + dy;
          end % if isfocusleft
        else % if ~ismerged
          xlabel('Mouse input only available in merged mode.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
        end % if ismerged
      case 'k'
        isnewwarp = true;
        isshifted = true;
      case 'm'
        ismerged = ~ismerged;
        isshifted = ismerged;
        isnewlateimg = true;
      case 'w'
        isshifted = true;
        iswhitened = ~iswhitened;
      case 'f'
        if isdualview
          isrewarp = false; % don't save control points for wrong image
          if iswhitened
            isshifted = true;
          end
          isfocusleft = ~isfocusleft;
          switch inhibit
            case 3
              % do nothing
            otherwise
              inhibit = isfocusleft + 1;
          end % switch inhibit
        end % if isdualview
      case 'i'
        if isdualview
          iswhitened = false;
          if ismerged
            isshifted = true;
          end % if ismerged
          switch character % disambiguate
            case 'i'
              inhibit = mod(inhibit - 1 + 1, 3) + 1;
            case 'I'
              inhibit = mod(inhibit - 1 - 1, 3) + 1;
          end % switch character
          switch inhibit
            case 3
              % do nothing
            otherwise
              isfocusleft = logical(inhibit - 1);
          end % switch inhibit
        end % if isdualview
      case {'1', '2', '3'}
        if ismerged
          ismerged = false;
          isfocusleft = true; % to ensure that focus and inhibit are not both "right"
          inhibit = 2;   % 1 is early_left, 2 is early_right, 3 is neither
        end % if ismerged
        isshifted = true;

        number = str2double(key);
        if ~isdualview && number == 2
          number = 1;
        end % if ~isdualview && number == 2
        alternate = number;
      case {'4', '5'} % auto alternate
        if ismerged
          ismerged = false;
          isfocusleft = true; % to ensure that focus and inhibit are not both "right"
          inhibit = 2;   % 1 is early_left, 2 is early_right, 3 is neither
        end % if ismerged
        isshifted = true;
        isautoalternate = ~isautoalternate;

        if isautoalternate
          number = str2double(key);
          if ~isdualview && number == 5
            number = 4;
          end % if ~isdualview && number == 5
          alternate = 3; % initialize
        end % if isautoalternate
      case 'c'
        figure(f1); % where to display xlabel
        subplot(s3);
        if ~isshifted
          isstretched(visible) = tagget(c(visible), 'match data range radio', 'Value'); % flip it
          %OutliersEditCallback{visible} = tagget(c, 'outlier percent edit', 'Callback');
          writecontrast(c(visible), ...
            'match data range radio', 'Value', ~isstretched(visible), ...
            'eliminate outliers radio', 'Value', isstretched(visible));
          OutliersEditCallback{visible}(); % same as Apply pushbutton
          PTLError = findall(0, 'Name', 'Percentage Too Large');
          CEOError = findall(0, 'Name', 'Cannot Eliminate Outliers');
          if ishandle(PTLError)
            OutliersEditString{visible} = '2';
            writecontrast(c(visible), ...
              'outlier percent edit', 'String', OutliersEditString{visible});
            OutliersEditCallback{visible}(); % same as Apply pushbutton
          end % if ishandle(PTLError)
          delete([PTLError CEOError]);
          xlabel('', 'Visible', 'off');
        else % if isshifted
          xlabel('No contrast stretching available in "blink" mode.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
          pause(3);
        end % if ~isshifted
      case 'v'
        figure(f1); % where to display xlabel
        subplot(s3);
        if ~isshifted
          AdjustContrastPosition = get(c(visible), 'Position');
          AdjustContrastVisible{visible} = 'off';
          set(c(visible), 'Visible', 'off');
          if isdualview
            switch character % disambiguate
              case 'v'
                visible = mod(visible - 1 + 1, 3) + 1;
              case 'V'
                visible = mod(visible - 1 - 1, 3) + 1;
            end % switch character
          else % if ~isdualview
            visible = 4 - visible;
          end % if isdualview
          AdjustContrastVisible{visible} = 'on';
          set(c(visible), 'Position', AdjustContrastPosition, 'Visible', 'on');
          switch visible
            case {1, 2}
              putonsame(c(visible), f2);
            case 3
              putonsame(c(visible), f1);
          end % switch visible
          putontop(c(visible));
          xlabel('', 'Visible', 'off');
        else % if isshifted
          xlabel('No contrast stretching available in "blink" mode.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
          pause(3);
        end % if ~isshifted
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
  end % if iskey
end % while ~strcmp(key, 'q')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SNAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xnc, ync, maxr] = snap(xc, yc, a, b)  % snap to grid using correlation

ds = 11; % search window delta (window size = 2*ds + 1)
dk = 5; % kernel delta (window size = 2*dk + 1)
threshold = .85; % threshold for correlation

[ma, na] = size(a);
[mb, nb] = size(b);

xc = round(xc);
yc = round(yc);

[kxc, sxc] = split(xc);
[kyc, syc] = split(yc);

% get bounds of search window and kernel
sx = [sxc - ds; sxc + ds]; % search window indices
sy = [syc - ds; syc + ds]; % search window indices
kx = [kxc - dk; kxc + dk]; % kernel indices
ky = [kyc - dk; kyc + dk]; % kernel indices

% force to be in bounds
sx(1) = max(1, sx(1));
sx(2) = min(na, sx(2));
sy(1) = max(1, sy(1));
sy(2) = min(ma, sy(2));
kx(1) = max(1, kx(1));
kx(2) = min(nb, kx(2));
ky(1) = max(1, ky(1));
ky(2) = min(mb, ky(2));

% find original center of search window and kernel in pixels
%  w.r.t. upper left corner
sic = 1 + syc - sy(1);
sjc = 1 + sxc - sx(1);
kic = 1 + kyc - ky(1);
kjc = 1 + kxc - kx(1);

% extract search window and kernel
s = a(sy(1):sy(2), sx(1):sx(2));
k = b(ky(1):ky(2), kx(1):kx(2));

% correlate
r = gencorr2(s, k);
[maxr, si, sj] = max2(r); % w.r.t. search window upper left corner

if maxr > threshold
  % compute corrected kernel center based on registration
  kinc = sic - si + 1;
  kjnc = sjc - sj + 1;
  kxnc = kjnc - kjc + kxc;
  kync = kinc - kic + kyc;
else % if maxr <= threshold
  kxnc = kxc; % no change
  kync = kyc;
end % if maxr > threshold

% return new coordinate
xnc = [kxnc; sxc];
ync = [kync; syc];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZIGZAG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function early_set = zigzag(n, segs)

no_segs = length(segs);
early_segs = cell(no_segs, 1);
late_segs = zeros(no_segs, 1);
for i = 1:no_segs
  v = sscanf(segs{i}, '%d', [1 Inf]);
  late_segs(i) = v(1);
  early_segs{i} = v(2:end);
end % for i

seg_ind = find(late_segs == n);
if isempty(seg_ind)
  early_set = [];
else % if ~isempty(seg_ind)
  early_set = early_segs{seg_ind};
end % if isempty(seg_ind)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REOPENFIGURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f1, f2, s1, s2, s3, n1, keylink, right] = ...
  reopenfigures(EarlyFigureName, LateFigureName, isdualview)

screen_size = get(0, 'ScreenSize');
if isempty(get(0, 'CurrentFigure'))
  monitor_positions = get(0, 'MonitorPositions');
  column = div(monitor_positions(:, 1), screen_size(3));
  left = min(column);
  right = max(column);
  switch length(column)
    case 1
      if isdualview
        left_monitor = [left 0 1/3 1];
        right_monitor = [left+1/3 0 2/3 1];
      else % if ~isdualview
        left_monitor = [left 0 1/2 1];
        right_monitor = [left+1/2 0 1/2 1];
      end % if isdualview
    otherwise
      left_monitor = [left 0 1 1];
      right_monitor = [right 0 1 1];
  end % switch length(column)
else % if ~isempty(get(0, 'CurrentFigure'))
  figs = sort(get(0, 'Children')); % ignores IMCONTRAST
  left_monitor = get(figs(1), 'OuterPosition'); % save for later
  right_monitor = get(figs(2), 'OuterPosition'); % save for later
  close force all % figures
end % if isempty(get(0, 'CurrentFigure'))
if screen_size(4) < 1200
  font_size = 7;
else % if screen_size(4) >= 1200
  font_size = 8;
end % if screen_size(4) < 1200

% define late menus
late_left_menu(1, :)  = sprintf('        F5        \t   refresh dir ');
late_left_menu(2, :)  = sprintf('        z         \t  toggle zigzag');
late_left_menu(3, :)  = sprintf('      p s n       \t port/stbd/nose');
late_left_menu(4, :)  = sprintf(' hyphen underscore\t  change scan #');
late_left_menu(5, :)  = sprintf('       [ ]        \t change panel #');
late_left_menu(6, :)  = sprintf(' PageUp PageDown  \t    new image  ');
late_left_menu(7, :)  = sprintf('        m         \t  toggle merge ');
late_left_menu(8, :)  = sprintf('        f         \t  toggle focus ');
late_left_menu(9, :)  = sprintf('       i I        \t     inhibit   ');
late_left_menu(10, :) = sprintf('      1 2 3       \t    alternate  ');
late_left_menu(11, :) = sprintf('       4 5        \t auto alternate');
late_left_menu(12, :) = sprintf('      arrows      \t    move image ');
late_left_menu(13, :) = sprintf('       j J        \t    axis jump  ');

late_right_menu(1, :)  = sprintf('        .         \t  snap register');
late_right_menu(2, :)  = sprintf('        x         \t   mouse input ');
late_right_menu(3, :)  = sprintf('        k         \t kontrol points');
late_right_menu(4, :)  = sprintf('       Home       \t    home axes  ');
late_right_menu(5, :)  = sprintf('        w         \t     whiten    ');
late_right_menu(6, :)  = sprintf('        e         \t      edit     ');
late_right_menu(7, :)  = sprintf('        g         \t   toggle grid ');
late_right_menu(8, :)  = sprintf('     l r u d      \t    move grid  ');
late_right_menu(9, :)  = sprintf('       * /        \t   resize grid ');
late_right_menu(10, :) = sprintf('       + -        \t   inc/dec grid');
late_right_menu(11, :) = sprintf('        c         \t  cont. stretch');
late_right_menu(12, :) = sprintf('       v V        \t  cont. visible');
late_right_menu(13, :) = sprintf('        q         \t      quit     ');

% define early menu
early_menu(1, :)  = sprintf('        F5        \t   refresh dir ');
early_menu(2, :)  = sprintf('        z         \t  toggle zigzag');
early_menu(3, :)  = sprintf('      p s n       \t port/stbd/nose');
early_menu(4, :)  = sprintf(' hyphen underscore\t  change scan #');
early_menu(5, :)  = sprintf('       [ ]        \t change panel #');
early_menu(6, :)  = sprintf(' PageUp PageDown  \t    new image  ');
early_menu(7, :)  = sprintf('      space       \t mono/dual view');
early_menu(8, :)  = sprintf('        c         \t  cont. stretch');
early_menu(9, :)  = sprintf('       v V        \t  cont. visible');
early_menu(10, :) = sprintf('        q         \t       quit    ');

% position late plots
f1 = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', LateFigureName, 'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'left'}, 'Units', 'normalized', ...
  'OuterPosition', left_monitor);
s3 = subplot('Position', [0 .2 1 .75]);
n1 = uicontrol('Parent', f1, 'Style', 'text', 'Units', 'normalized', ...
  'Position', [.45 .025 .10 .125], 'FontName', 'Courier', 'FontSize', font_size);
uicontrol('Parent', f1, 'Style', 'text', 'String', late_left_menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .165], ...
  'FontName', 'Courier', 'FontSize', font_size);
uicontrol('Parent', f1, 'Style', 'text', 'String', late_right_menu, ...
  'Units', 'normalized', 'Position', [.775 .025 .2 .165], ...
  'FontName', 'Courier', 'FontSize', font_size);

% position early plots
f2 = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', EarlyFigureName, ...
  'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'left'}, 'Units', 'normalized', ...
  'OuterPosition', right_monitor);
s2 = subplot('Position', [.525 .1 .45 .95]); % cannot overlap initially
s1 = subplot('Position', [.025 .1 .45 .95]); %  put s1 on top of s2
if ~isdualview
  set(s1, 'Position', [0 .2 1 .75]);
end % if ~isdualview
uicontrol('Parent', f2, 'Style', 'text', 'String', early_menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .125], ...
  'FontName', 'Courier', 'FontSize', font_size);

% turn off superfluous buttons
toggle_handles = [findall([f1 f2], 'type', 'uipushtool'); ...
  findall([f1 f2], 'type', 'uitogglesplittool'); ...
  findall([f1 f2], 'type', 'uitoggletool')];
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

z = zoom(f2); p = pan(f2);
[z.ButtonDownFilter, p.ButtonDownFilter] = deal(@buttondownfilter);
puc = uicontextmenu; % disable pan right clicking, for Frank
uimenu('Parent', puc, 'Enable', 'off', 'Visible', 'off');
set(p, 'UIContextMenu', puc);

keylink = linkprop([f1 f2], 'UserData');
