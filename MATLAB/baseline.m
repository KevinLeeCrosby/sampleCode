function baseline(directory)

%BASELINE Screen baseline RCC panels.
%   BASELINE(DIR) will display an image based on the zone (Port, Starboard,
%   or Nose Cap), RCC panel, and row, provided by the user, in the PhotoDB
%   directory DIR.  If no directory is provided, then the user will be
%   prompted.  Menus are included.  See accompanying documentation. A
%   clickable grid and rotation dial are displayed.
%
%   Examples
%   --------
%       % reference actual baselines
%       baseline T:\PhotoDB-124
%
%   Notes
%   -----
%       The mouse cursor must be in one of the figures for the program to
%       accept keystrokes.
%
%   See also BROWSE, BLINK, WINK, WAITFORBUTTONPRESS, BEEP.
%
%   Version 6.5 Kevin Crosby

% DATE      VER  NAME          DESCRIPTION
% 05-16-05  1.0  K. Crosby     First Release.
% 05-17-05  1.1  K. Crosby     Made grid clickable.
% 05-18-05  1.2  K. Crosby     Inverted grid and removed "hand" function.
% 05-18-05  1.3  K. Crosby     Put baseline image and grid in same figure.
% 05-19-05  1.4  K. Crosby     Changed display from segment to scanline,
%                              and reinverted grid.
% 05-20-05  1.5  K. Crosby     Added menu to figure.
% 05-23-05  1.6  K. Crosby     Added image rotation and angle dial to
%                              figure.
% 05-24-05  1.7  K. Crosby     Combined pulldown menus and closed figure
%                              upon quit.
% 05-25-05  1.8  K. Crosby     Added half zoom capabilities.
% 05-25-05  1.9  K. Crosby     Added "clone" feature and combined baseline
%                              modified and graphical programs.
% 05-25-05  1.10 K. Crosby     Disabled zooming and panning on patches.
% 06-01-05  1.11 K. Crosby     Made rotations faster after preloading.
% 06-03-05  2.0  K. Crosby     Allowed for prerotated image inputs.
% 06-06-05  3.0  K. Crosby     Added wing glove.
% 06-08-05  3.1  K. Crosby     Added local directories.
% 08-15-05  3.2  K. Crosby     Added a call to Photoshop.
% 03-21-06  4.0  K. Crosby     Added Nose Cap.
% 03-22-06  4.1  K. Crosby     Fixed problem with flipped Nose Cap.
% 03-23-06  4.2  K. Crosby     Included path to 'yuck.bmp' for compilation.
%                              Added more placeholders to Nose Cap grid.
% 06-13-06  4.3  K. Crosby     Fixed transition from Nose Cap to panel.
%                              Fixed clicking center of Nose Cap.  Put
%                              STS-121 as default mission.  Added STS-121
%                              baseline imagery.
% 08-21-06  4.4  K. Crosby     Set STS-115 as default mission and added
%                              baseline imagery.  Changed 'Scanline' to
%                              'Row'.
% 11-28-06  4.5  K. Crosby     Set STS-116 as default mission and added
%                              baseline imagery.  Made directory structure
%                              modification to Nose Cap for consistency.
%                              Added reference to 'INHOUSE' directory and
%                              'yuck.bmp'.  Made other minor changes.
% 03-05-07  4.6  K. Crosby     Set STS-117 as default mission and added
%                              baseline imagery.  Calls PULLDOWN
%                              sub-function as separate file.  Changed text
%                              references from 'scanline' to 'row'.
%                              Automatically position window(s).
% 05-03-07  4.7  K. Crosby     Removed references to colormap.
% 06-06-07  5.0  K. Crosby     Fixed monitor positions.  Added auxiliary
%                              imagery.  Renamed from 'screenrcc' to
%                              'baseline'.  Cleaned up file I/O code.
% 06-07-07  5.1  K. Crosby     Allowed for prerotated auxiliary imagery.
% 07-11-07  5.2  K. Crosby     Made dialog boxes always on top.  Changed
%                              randomness call to Easter Egg.  Added
%                              initializations to pulldown menu call.
% 07-26-07  5.3  K. Crosby     Set STS-118 as default mission and added
%                              baseline imagery.  Added reference to
%                              'TIIMS' directory.  Made titles bold.  Made
%                              figure name reflect mission.
% 08-02-07  5.4  K. Crosby     Added verbose figure CloseRequestFcn.  Added
%                              headers for subfunctions.  Fixed clone
%                              window.  Suppress warning for large images.
% 08-13-07  5.5  K. Crosby     Turned zoom and pan off before new image is
%                              displayed.
% 08-21-07  5.6  K. Crosby     Added maximize to Photoshop call.  Changed
%                              'yuck.bmp' to 'yuck.gif'.
% 10-10-07  5.7  K. Crosby     Set STS-120 as default mission and added
%                              baseline imagery.
% 11-23-07  5.8  K. Crosby     Set STS-122 as default mission and added
%                              baseline imagery.  Removed BEEP calls,
%                              except on zoom and pan tools.
% 03-07-08  5.9  K. Crosby     Set STS-123 as default mission and added
%                              baseline imagery.  Removed half zoom and
%                              moved zoom keys to F1-F4.  Changed arrow
%                              keys to brackets, hyphen, and underscore to
%                              make compatible with other programs.
% 04-08-08  5.10 K. Crosby     Removed reference to TIIMS variable.
% 04-23-08  6.0  K. Crosby     Major rewrite.  Added contrast stretching.
%                              Made key presses work on IMCONTRAST tool.
%                              Removed reference to TIIMS variable.  Added
%                              axes control. Removed unnecessary zoom
%                              options.
% 04-29-08  6.1  K. Crosby     Fixed axes control.
% 05-06-08  6.2  K. Crosby     Added editting of color image.  Allow for
%                              original baselines to be grayscale by
%                              default.  Fixed menu position.
% 05-19-08  6.3  K. Crosby     Set STS-124 as default mission and added
%                              baseline imagery.  Now reads missions and
%                              nose cap suffixes from files.  Fixed
%                              MAKEGRID and MAKEDIAL sizing problems by
%                              removing AXIS MANUAL in subfunctions.
% 06-30-08  6.4  K. Crosby     Converted common subfunctions into
%                              individual private functions.  Fixed mouse
%                              cursor appearance when key is pressed under
%                              zoom or pan.  Fixed axes for original
%                              portrait baselines (i.e. nose cap).
% 11-17-08  6.5  K. Crosby     Disabled pan right-clicking.


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

% define some pulldown parameters
missions = missionread; % in reverse historical order
zones = {'WLE-Port', 'WLE-Stbd', 'Nose Cap'};
row_strs = {'Row 1', 'Row 2', 'Row 3', 'Row 4', 'Row 5'};
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
nose_panels = {'810'};

% get data
if isnan(str2double(mission)) % e.g. if PhotoDB-RCC
  [mission_ind, zone_ind, row_ind, panel_ind] = ...
    pulldown('Baseline Pulldown Menu', missions, zones, row_strs, panel_strs);
  directory = strrep(directory, mission, missions{mission_ind});
  mission = missions{mission_ind};
else % if ~isnan(str2double(mission)) % e.g. if normal mission
  [zone_ind, row_ind, panel_ind] = ...
    pulldown('Baseline Pulldown Menu', zones, row_strs, panel_strs);
end % if isnan(str2double(mission))
row_ind = min(row_ind, getmaxrow(panel_ind));

% define nose cap suffixes
nose_suffixes = nosesuffixread(mission);

% define INHOUSE directory
inhouse = getenv('INHOUSE'); % get inhouse directory
matlab = fullfile(inhouse, 'matlab');
rcc = fullfile(matlab, 'RCC');
yuck_file = 'yuck.gif';
yuck_fullfile = fullfile(rcc, yuck_file);

% turn common warnings off
warning off Images:initSize:adjustingMag % suppress too big image warning
%warning off Images:imhistc:inputHasNaNs  % suppress complaints about NaNs

% define angles
increment = 45; % degrees
angles = 0:increment:360-increment;
no_angles = length(angles);
angle_ind = 1;
angle = angles(angle_ind);

% define colors
colors = prism(6); % red, orange, yellow, green, blue, violet

% determine grid_arg for MAKEGRID
switch zone_ind
  case 1
    grid_arg = port_panels;
  case 2
    grid_arg = stbd_panels;
  case 3
    grid_arg = nose_suffixes;
end % switch zone_ind

% set up figures
close force all % figures
FigureName = sprintf('%s -- STS-%s', this, mission);
[f1, s1, s2, s3, d, t, h, keylink, right] = ...
  reopenfigure(FigureName, zone_ind, grid_arg, increment);

isstretched = true;
lifespan = 100; % time to live for figure windows
iteration = 0;
timetodie = false; % figures already opened above
AdjustContrastVisible = 'off';
[width, height] = split(get(0, 'ScreenSize'), 2);
p = [(width-649)/2+1 height/40+1 649 300]; % preserves size of IMCONTRAST
AdjustContrastPosition = ...
  [right+(p(1)-1)/width (p(2)-1)/height p(3)/width p(4)/height];
OutliersEditString = '2';
MDRRadioButtonValue = ~isstretched;
EORadioButtonValue = isstretched;
c = 0;

iszonechange = true;
[dr dp dn da] = deal(0); % row, panel, nose, and angle changes
ischange = true;
isnewimg = true;

key = '';
while ~strcmp(key, 'q')
  % read old contrast stretching, if available
  if c && (ischange || logical(da))
    [AdjustContrastPosition, AdjustContrastVisible, OutliersEditString, ...
      MDRRadioButtonValue, EORadioButtonValue] = ...
      readcontrast(c, 'this', 'Position', 'this', 'Visible', ...
      'outlier percent edit', 'String', ...
      'match data range radio', 'Value', 'eliminate outliers radio', 'Value');
  end % if c && (ischange || logical(da))
  if c && da
    [MinEditString, MaxEditString] = ...
      readcontrast(c, 'window min edit', 'String', ...
      'window max edit', 'String');
  end % if c && da

  if timetodie
    [f1, s1, s2, s3, d, t, h, keylink] = ...
      reopenfigure(FigureName, zone_ind, grid_arg, increment);
    timetodie = false;

    isnewimg = true;
  end % if timetodie

  if iszonechange
    zone = zones{zone_ind};

    % define panels
    switch zone_ind
      case 1 % Port
        [panels, grid_arg] = deal(port_panels);
        panel_ind = min(panel_ind, length(panels));
      case 2 % Stbd
        [panels, grid_arg] = deal(stbd_panels);
        panel_ind = min(panel_ind, length(panels));
      case 3 % Nose
        panels = nose_panels;
        grid_arg = nose_suffixes;
        nose_suffix_ind = length(nose_suffixes);
    end % switch zone_ind
    if ~timetodie
      figure(f1);
      set(s2, 'HandleVisibility', 'on');
      subplot(s2); cla;
      h = makegrid(zone_ind, grid_arg);
      set(s2, 'HandleVisibility', 'off');
    end % if ~timetodie

    ischange = true;
  end % iszonechange

  if ischange
    % update row and panel, or nose
    switch zone_ind
      case {1, 2}
        row_ind = row_ind + dr;
        panel_ind = panel_ind + dp; % already updated by MAKEMAJORCHANGE
      case 3
        nose_suffix_ind = nose_suffix_ind + dn; % changed by clicking only
    end % switch zone_ind

    % update base directory and file
    switch zone_ind
      case {1, 2}
        panel = panels{panel_ind};
        file = sprintf('%s-%s-%d.jpg', mission, panel, row_ind);
        file_45 = sprintf('%s-%s-%d-45.jpg', mission, panel, row_ind);
        tif_file = sprintf('%s-%s-%d.tif', mission, panel, row_ind);
        wildcard = sprintf('%s-*-%s-%02d-*.jpg', mission, panel, row_ind);
        wildcard_45 = sprintf('%s-*-%s-%02d-*-45.jpg', mission, panel, row_ind);
      case 3
        panel = panels{1};
        nose_suffix = nose_suffixes{nose_suffix_ind};
        file = sprintf('%s-%s%s.jpg', mission, panel, nose_suffix);
        file_45 = sprintf('%s-%s%s-45.jpg', mission, panel, nose_suffix);
        tif_file = sprintf('%s-%s%s.tif', mission, panel, nose_suffix);
        wildcard = sprintf('%s-*-%s%s-*.jpg', mission, panel, nose_suffix);
        wildcard_45 = sprintf('%s-*-%s%s-*-45.jpg', mission, panel, nose_suffix);
    end % switch zone_ind

    full_dir =  ...
      sprintf('%s\\Baseline\\%s\\%s\\JPGs\\', directory, zone, panel);
    full_file = fullfile(full_dir, file);
    full_file_45 = fullfile(full_dir, file_45);
    tif_dir =  ...
      sprintf('%s\\Baseline\\%s\\%s\\TIFs\\', directory, zone, panel);
    tif_fullfile = fullfile(tif_dir, tif_file);
    aux_files = dir2cell(fullfile(full_dir, wildcard));
    rot_files = dir2cell(fullfile(full_dir, wildcard_45));
    aux_files = setdiff(aux_files, rot_files);
    no_auxen = max(size(aux_files, 1), 1);
    aux_ind = 1;
    isaux = false;

    if ~exist(full_file, 'file')
      msg = sprintf('Cannot find image file!\nZone %s, %s', zone, file);
      warn_handle = warndlg(msg, 'Can''t find image file!', 'modal');
      putonsame(warn_handle, f1);
      %putonright(warn_handle);
      waitfor(warn_handle);
      full_file = yuck_fullfile;
    end % if ~exist(full_file, 'file')

    % update grid
    figure(f1);
    subplot(s2);
    switch zone_ind
      case {1, 2}
        set(h(row_ind - dr, panel_ind - dp), 'FaceColor', 'w');
        set(h(row_ind, panel_ind), 'FaceColor', colors(no_auxen, :));
      case 3
        set(h(nose_suffix_ind - dn), 'FaceColor', 'w');
        set(h(nose_suffix_ind), 'FaceColor', colors(no_auxen, :));
    end % switch zone_ind

    [gimg, gimg_45] = deal([]);

    info = imfinfo(full_file);
    [m, n] = deal(info.Height, info.Width);
    isportrait = m > n;
    
    if ~isportrait
      ax = [0 n 0 m] + .5;
      ax = xformaxes(ax, 1, angle_ind - 1, increment, m, n);
    else % if isportrait
      ax = [0 m 0 n] + .5;
      ax = xformaxes(ax, 1, angle_ind + 2 - 1, increment, n, m);
    end % if ~isportrait
    
    isnewimg = true;
  end % if ischange

  if isnewimg
    set(f1, 'Pointer', 'watch'); % show hourglass
    drawnow;

    if ~ischange
      subplot(s1);
      %daspect([1 1 1]);
      ax = axis;
    end % if ~ischange

    if isaux
      info = imfinfo(aux_full_file);
      [m, n] = deal(info.Height, info.Width);
      isportrait = false;
      ax = [0 n 0 m] + .5;
      ax = xformaxes(ax, 1, angle_ind - 1, increment, m, n);
    end % if isaux
    
    % update angle and note axis centers
    if da
      subplot(s3);
      set(d(angle_ind), 'FaceColor', 'w');
      set(t(angle_ind), 'Color', 'k', 'FontWeight', 'normal');

      [ax, angle_ind, angle] = xformaxes(ax, angle_ind, da, increment, m, n);

      set(d(angle_ind), 'FaceColor', 'r');
      set(t(angle_ind), 'Color', 'r', 'FontWeight', 'bold');
    end % if da

    if ~mod(angle, 90) % i.e. if not divisible by 90°
      if isaux
        if isempty(aimg)
          aimg = imread(aux_full_file); % expensive I/O operation
          if ndims(aimg) == 3
            aimg = rgb2gray(aimg);
          end % if ndims(aimg) == 3
        end % if isempty(aimg)
        if angle == 0
          img = aimg;
        else % if angle ~= 0
          img = imrotate(aimg, angle);
        end % if angle == 0
      else % if ~isaux
        if isempty(gimg)
          gimg = imread(full_file); % expensive I/O operation
          if ndims(gimg) == 3
            gimg = rgb2gray(gimg);
          end % if ndims(gimg) == 3
        end % if isempty(gimg)
        if angle == 0
          img = gimg;
        else % if angle ~= 0
          img = imrotate(gimg, angle); % rotate angle degrees
        end % if angle == 0
      end % if isaux
    end % if ~mod(angle, 90) % i.e. if not divisible by 90°

    if mod(angle, 90) % i.e. if divisible by 90°
      if isaux
        if isempty(aimg_45)
          if exist(aux_full_file_45, 'file')
            aimg_45 = imread(aux_full_file_45); % expensive I/O operation
            if ndims(aimg_45) == 3
              aimg_45 = rgb2gray(aimg_45);
            end % if ndims(aimg_45) == 3
          else % if ~exist(aux_full_file_45, 'file')
            if isempty(aimg)
              aimg = imread(aux_full_file); % expensive I/O operation
              if ndims(aimg) == 3
                aimg = rgb2gray(aimg);
              end % if ndims(aimg) == 3
            end % if isempty(aimg)
            aimg_45 = imrotate(aimg, 45); % rotate 45°
          end % if exist(aux_full_file_45, 'file')
        end % if isempty(aimg_45)
        if angle == 45
          img = aimg_45;
        else % if angle ~= 45
          img = imrotate(aimg_45, angle - 45);
        end % if angle == 45
      else % if ~isaux
        if isempty(gimg_45)
          if exist(full_file_45, 'file')
            gimg_45 = imread(full_file_45); % expensive I/O operation
            if ndims(gimg_45) == 3
              gimg_45 = rgb2gray(gimg_45);
            end % if ndims(gimg_45) == 3
          else % if ~exist(full_file_45, 'file')
            if isempty(gimg)
              gimg = imread(full_file); % expensive I/O operation
              if ndims(gimg) == 3
                gimg = rgb2gray(gimg);
              end % if ndims(gimg) == 3
            end % if isempty(gimg)
            gimg_45 = imrotate(gimg, 45); % rotate 45°
          end % if exist(full_file_45, 'file')
        end % if isempty(gimg_45)
        if angle == 45
          img = gimg_45;
        else % if angle ~= 45
          img = imrotate(gimg_45, angle - 45);
        end % if angle == 45
      end % if isaux
    end % if mod(angle, 90) % i.e. if divisible by 90°

    subplot(s1);
    zoom off, pan off % to allow image change under these modes
    imshow(img);
    axis(ax);
    daspect([1 1 1]);
    %axis image
    %axis manual % to keep out of automatic mode

    if isaux
      ttl = aux_file;
    else % if ~isaux
      switch zone_ind
        case {1, 2}
          ttl = sprintf('%s, Panel %d, Row %d', ...
            zone, panel_ind, row_ind);
        case 3
          switch nose_suffix_ind
            case length(nose_suffixes)
              ttl = sprintf('%s, center', zone);
            otherwise
              ttl = sprintf('%s, about %d O''clock', zone, ...
                mod(nose_suffix_ind-1, 12) + 1);
          end % switch nose_suffix_ind
      end % switch zone_ind
    end % if isaux
    if angle
      ttl = sprintf('%s (ROTATED %d°)', ttl, angle);
    end % if angle
    title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');

    % invoke contrast function
    [c, OutliersEditCallback, MinMaxEditCallback] = opencontrast(s1, ...
      AdjustContrastPosition, AdjustContrastVisible, ...
      OutliersEditString, MDRRadioButtonValue, EORadioButtonValue);
    addtarget(keylink, c);
    iteration = mod(iteration + 1, lifespan);
    timetodie = timetodie | ~iteration;
    % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);

    % restore stretching settings
    if da
      writecontrast(c, 'window min edit', 'String', MinEditString, ...
        'window max edit', 'String', MaxEditString);
      MinMaxEditCallback(); % same as typing in textbox
    end % if da

    set(f1, 'Pointer', 'arrow');
    drawnow;
  end % if isnewimg

  iszonechange = false;
  [dr dp dn da] = deal(0); % row, panel, nose, and angle changes
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
      case 'p'
        if zone_ind == 1
          warn_handle = ...
            warndlg('Already viewing Port!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, f1);
          %putonright(warn_handle);
          waitfor(warn_handle);
        else % if zone_ind ~= 1
          zone_ind = 1;
          iszonechange = true;
        end % if zone_ind == 1
      case 's'
        if zone_ind == 2
          warn_handle = ...
            warndlg('Already viewing Starboard!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, f1);
          %putonright(warn_handle);
          waitfor(warn_handle);
        else % if zone_ind ~= 2
          zone_ind = 2;
          iszonechange = true;
        end % if zone_ind == 2
      case 'n'
        if zone_ind == 3
          warn_handle = ...
            warndlg('Already viewing Nose Cap!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, f1);
          %putonright(warn_handle);
          waitfor(warn_handle);
        else % if zone_ind ~= 3
          zone_ind = 3;
          iszonechange = true;
        end % if zone_ind == 3
      case 'hyphen'
        switch character % disambiguate
          case '-'
            switch zone_ind
              case {1, 2} % port or starboard
                if row_ind == getmaxrow(panel_ind)
                  dr = 0;
                else % if row_ind ~= getmaxrow(panel_ind)
                  dr = +1;
                end % if row_ind == getmaxrow(panel_ind)
              case 3 % nose
                dr = 0;
            end % switch zone_ind
          case '_'
            switch zone_ind
              case {1, 2} % port or starboard
                if row_ind == 1
                  dr = 0;
                else % if row_ind ~= 1
                  dr = -1;
                end % if row_ind == 1
              case 3 % nose
                dr = 0;
            end % switch zone_ind
        end % switch character
        ischange = logical(dr);
      case 'leftbracket'
        switch zone_ind
          case 1 % port
            if panel_ind == 1
              dp = 0;
            else % if panel_ind ~= 1
              dp = -1;
            end % if panel_ind == 1
          case 2 % starboard
            if panel_ind == length(panels)
              dp = 0;
            else % if panel_ind ~= length(panels)
              dp = +1;
            end % if panel_ind == length(panels)
          case 3 % nose
            dp = 0;
        end % switch zone_ind
        ischange = logical(dp);
      case 'rightbracket'
        switch zone_ind
          case 1 % port
            if panel_ind == length(panels)
              dp = 0;
            else % if panel_ind ~= length(panels)
              dp = +1;
            end % if panel_ind == length(panels)
          case 2 % starboard
            if panel_ind == 1
              dp = 0;
            else % if panel_ind ~= 1
              dp = -1;
            end % if panel_ind == 1
          case 3 % nose
            dp = 0;
        end % switch zone_ind
        ischange = logical(dp);
      case 'h'
        if no_auxen > 1
          aux_ind = mod(aux_ind, no_auxen) + 1;
          aux_file = aux_files{aux_ind};
          aux_file_45 = strrep(aux_file, '.', '-45.');
          aux_full_file = fullfile(full_dir, aux_file);
          aux_full_file_45 = fullfile(full_dir, aux_file_45);

          [aimg, aimg_45] = deal([]);
          isaux = true;
          isnewimg = true;
        end % if no_auxen > 1
      case 'home'
        zoom out
        
        if ~isportrait
          ax = [0 n 0 m] + .5;
          ax = xformaxes(ax, 1, angle_ind - 1, increment, m, n);
        else % if isportrait
          ax = [0 m 0 n] + .5;
          ax = xformaxes(ax, 1, angle_ind + 2 - 1, increment, n, m);
        end % if ~isportrait
    
        axis(ax);
      case 'c'
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
      case 'v'
        switch get(c, 'Visible')
          case 'on' % then turn off
            AdjustContrastVisible = 'off';
          case 'off' % then turn on
            AdjustContrastVisible = 'on';
        end % switch get(c, 'Visible');
        set(c, 'Visible', AdjustContrastVisible);
        putontop(c);
      case 'e'
        if exist(tif_fullfile, 'file')
          destination = fullfile(tempdir, tif_file); % generate temporary filename
          [success, message] = copyfile(tif_fullfile, destination);
        else % if ~exist(tif_fullfile, 'file')
          destination = fullfile(tempdir, file); % generate temporary filename
          [success, message] = copyfile(full_file, destination);
        end % if exist(tif_fullfile, 'file')
        if ~success
          err_handle = errordlg(message, 'No temp directory!', 'modal');
          putonsame(err_handle, f1);
          %putonright(err_handle);
          waitfor(err_handle);
        else % if success
          command = sprintf('start /max photoshop %s', destination);
          system(command);
        end % if ~success
      case 'z'
        switch character % disambiguate
          case 'Z'
            figure(f1);
            sparkle(h);
          otherwise
            msg = sprintf('I don''t understand "%s"!', key);
            warn_handle = warndlg(msg, 'I don''t understand!', 'modal');
            putonsame(warn_handle, f1);
            %putonright(warn_handle);
            waitfor(warn_handle);
        end % switch character
      case 'q'
        disp('QUIT!');
        close force all
      otherwise
        msg = sprintf('I don''t understand "%s"!', key);
        warn_handle = warndlg(msg, 'I don''t understand!', 'modal');
        putonsame(warn_handle, f1);
        %putonright(warn_handle);
        waitfor(warn_handle);
    end % switch key
  else % if ~iskey (i.e. is mouse button)
    set([s2 s3], 'HandleVisibility', 'on');
    switch gca
      case s2
        u = getappdata(f1, 'GridData');
        if ~isempty(u)
          switch zone_ind
            case {1, 2}
              [dr, dp] = split(u - [row_ind, panel_ind]);
              ischange = logical(dp) | logical(dr);
            case 3
              dn = u - nose_suffix_ind;
              ischange = logical(dn);
          end % switch zone_ind
          setappdata(f1, 'GridData', []);
        end % ~isempty(u)
      case s3
        u = getappdata(f1, 'DialData'); % always an angle index
        da = mod(u - angle_ind, no_angles);
        isnewimg = logical(da);
    end % switch gca
    set([s2 s3], 'HandleVisibility', 'off');
  end % if iskey
end % while ~strcmp(key, 'q')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REOPENFIGURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f1, s1, s2, s3, d, t, h, keylink, right] = ...
  reopenfigure(FigureName, zone_ind, grid_arg, increment)

screen_size = get(0, 'ScreenSize');
if isempty(get(0, 'CurrentFigure')) % if first time
  monitor_positions = get(0, 'MonitorPositions');
  column = div(monitor_positions(:, 1), screen_size(3));
  % left = min(column);
  right = max(column);
  monitor = [right 0 1 1];
  griddata = []; % row_ind panel_ind, or nose_suffix_ind
  dialdata = 1; % angle_ind
else % if ~isempty(get(0, 'CurrentFigure'))
  fig = get(0, 'Children'); % ignores IMCONTRAST
  monitor = get(fig, 'OuterPosition'); % save for later
  griddata = getappdata(fig, 'GridData'); % save for later
  dialdata = getappdata(fig, 'DialData'); % save for later
  close force all % figures
end % if isempty(get(0, 'CurrentFigure'))
if screen_size(4) < 1200
  font_size = 7;
else % if screen_size(4) >= 1200
  font_size = 8;
end % if screen_size(4) < 1200

% define menu
menu(1, :) = sprintf('      p s n       \t port/stbd/nose');
menu(2, :) = sprintf(' hyphen underscore\t  change row # ');
menu(3, :) = sprintf('       [ ]        \t change panel #');
menu(4, :) = sprintf('        h         \t historical img');
menu(5, :) = sprintf('       Home       \t  full zoom out');
menu(6, :) = sprintf('        e         \t      edit     ');
menu(7, :) = sprintf('        c         \t  cont. stretch');
menu(8, :) = sprintf('        v         \t  cont. visible');
menu(9, :) = sprintf('        q         \t       quit    ');

% position baseline figure
f1 = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', FigureName, 'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'right'}, 'Units', 'normalized', ...
  'OuterPosition', monitor);
setappdata(f1, 'GridData', griddata);
setappdata(f1, 'DialData', dialdata);
s1 = subplot('Position', [0 .2 1 .75]); % main baseline image
s2 = subplot('Position', [.25 .05 .5 .1]); % grid
s3 = subplot('Position', [.75 .05 .2 .1]); % dial
uicontrol('Parent', f1, 'Style', 'text', 'String', menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .125], ...
  'FontName', 'Courier', 'FontSize', font_size);

% turn off superfluous buttons
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
%[z.ActionPreCallback, p.ActionPreCallback] = deal(@actionprecallback);
%[z.ActionPostCallback, p.ActionPostCallback] = deal(@actionpostcallback);
puc = uicontextmenu; % disable pan right clicking, for Frank
uimenu('Parent', puc, 'Enable', 'off', 'Visible', 'off');
set(p, 'UIContextMenu', puc);

figure(f1);
set(s2, 'HandleVisibility', 'on');
subplot(s2); cla;
h = makegrid(zone_ind, grid_arg);
set(s2, 'HandleVisibility', 'off');
if ~isempty(griddata)
  switch zone_ind
    case {1, 2}
      [row_ind, panel_ind] = split(griddata);
      set(h(row_ind, panel_ind), 'FaceColor', 'r');
    case 3
      nose_suffix_ind = griddata;
      set(h(nose_suffix_ind), 'FaceColor', 'r');
  end % switch zone_ind
end % if ~isempty(griddata)

set(s3, 'HandleVisibility', 'on');
subplot(s3);
[d, t] = makedial(increment);
set(s3, 'HandleVisibility', 'off');
angle_ind = dialdata;
set(d(angle_ind), 'FaceColor', 'r');
set(t(angle_ind), 'Color', 'r', 'FontWeight', 'bold');

keylink = linkprop(f1, 'UserData');
