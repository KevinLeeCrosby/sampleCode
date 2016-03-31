function wink(directory)

%WINK Wink comparator for pre- and post-flight Orbiter WLE and Nose Cap.
%   WINK will browse through a sequence of TIFFs in the user specified
%   PhotoDB directory.  If no directory is provided, then the user will be
%   prompted.  Menus are included.  See accompanying documentation.
%
%   WINK(DIR) will start browsing the PhotoDB database in the directory
%   DIR.
%
%   Example
%   -------
%       wink T:\PhotoDB-RCC
%
%   Notes
%   -----
%       The mouse cursor must be in one of the figures for the program to
%       accept keystrokes.
%
%       WINK cannot open UNC paths in Photoshop.
%
%   See also BASELINE, BROWSE, BLINK, FUSION, WAITFORBUTTONPRESS, GRID.
%
%   Version 1.7 Kevin Crosby

% DATE      VER  NAME          DESCRIPTION
% 02-22-08  1.0  K. Crosby     First Release.
% 03-19-08  1.1  K. Crosby     Fixed zoom problem in warped mode.  Moved
%                              zoom keys to F1-F4.  Added 1, 2, 3 keys for
%                              toggling warped images.  Added reg, zoom,
%                              and crop subdirs to archive directory.
%                              Remember zoom settings.  Removed CD calls.
% 03-24-08  1.2  K. Crosby     Added animated gif creation.
% 04-09-08  1.3  K. Crosby     Fixed contrast stretching for kontrol
%                              points.  Remember min and max settings for
%                              aborted registration.  Made key presses work
%                              on IMCONTRAST tool.  Added ability to
%                              register on-orbit images to post-flight
%                              images.  Removed reference to TIIMS
%                              variable.  Fixed memory problem.
% 04-23-08  1.4  K. Crosby     Removed unnecessary zoom options.
% 05-19-08  1.5  K. Crosby     Set STS-124 as default mission and added
%                              baseline imagery.  Now reads missions and
%                              nose cap suffixes from files.  Fixed
%                              MAKEGRID and MAKEDIAL sizing problems by
%                              removing AXIS MANUAL in subfunctions.
% 06-16-08  1.6  K. Crosby     Converted common subfunctions into
%                              individual private functions.  Fixed mouse
%                              cursor appearance when key is pressed under
%                              zoom or pan.
% 11-17-08  1.7  K. Crosby     Disabled pan right-clicking.  Fixed LDRI tif
%                              errors occuring on some older missions.


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
[pre_dir, taildir] = fileparts(directory);
isabsolute = ~isempty(find(pre_dir == ':', 1)) || ~isempty(strfind(pre_dir, '\\'));
isunc = ~isempty(strfind(pre_dir, '\\')) || ...
  (isempty(find(pre_dir == ':', 1)) && ~isempty(strfind(pwd, '\\')));
if isunc
  error('Please pass a mapped drive to %s!', this);
elseif ~isabsolute % && ~isunc % convert into absolute path, if necessary
  directory = fullfile(pwd, taildir);
end % if isunc
post_mission = regexp(taildir, '\w*', 'match');
if length(post_mission) == 2 && strcmp(post_mission{1}, 'PhotoDB') && exist(directory, 'dir')
  post_mission = post_mission{end};
else % if length(post_mission) ~= 2 || ~strcmp(post_mission{1}, 'PhotoDB') || ~exist(directory, 'dir')
  error('Please specify a valid PhotoDB directory!');
end % if length(post_mission) == 2 && strcmp(post_mission{1}, 'PhotoDB') && exist(directory, 'dir')

post_dir = fullfile(directory, 'PostFlight', 'MMOD_Analysis');

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

% determine default mission for pulldown menu
mission_ind = strmatch(post_mission, missions, 'exact');
if isempty(mission_ind)
  mission_ind = 1;
end % if isempty(mission_ind)

% get data
[mission_ind, zone_ind, row_ind, panel_ind] = ...
  pulldown('Wink Pulldown Menu', missions, zones, ...
  row_strs, panel_strs, mission_ind);
mission = missions{mission_ind};
row_ind = min(row_ind, getmaxrow(panel_ind));

% distinguish baseline directory
drive = regexprep(fileparts(directory), '\\$', ''); % strip trailing file sep.
baseline_dir = fullfile(drive, sprintf('PhotoDB-%s', mission));

% define nose cap suffixes
nose_suffixes = nosesuffixread(mission);

% define wildcards
switch mission
  case '122'
    dirarg = 'IMG_*.tif';
  otherwise
    dirarg = 'IMG_*.jpg';
end % switch mission

% define INHOUSE directory
inhouse = getenv('INHOUSE'); % get inhouse directory
matlab = fullfile(inhouse, 'matlab');
rcc = fullfile(matlab, 'RCC');
yuck_file = 'yuck.gif';
yuck_fullfile = fullfile(rcc, yuck_file);

% turn common warnings off
warning off Images:initSize:adjustingMag % suppress too big image warning
warning off Images:imhistc:inputHasNaNs  % suppress complaints about NaNs

% define angles
increment = 90; % degrees
angles = 0:increment:360-increment;
no_angles = length(angles);
angle_ind = 1;
angle = angles(angle_ind);

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
PreFigureName = sprintf('%s (Pre-flight Imagery) -- STS-%s', this, mission);
PostFigureName = sprintf('%s (Post-flight Imagery) -- STS-%s', this, post_mission);
[fpre, fpost, spre1, spre2, spost1, spost2, npost, d, t, h, keylink, right] = ...
  reopenfigures(PreFigureName, PostFigureName, zone_ind, grid_arg, increment);

duo = 1:2;
key = ' ';
isimageclick = false;

isstretched = true(1, 2);
lifespan = 100; % time to live for figure windows
iteration = 0;
timetodie = false; % figures already opened above
visible = 1; % 1 is pre-flight image, 2 is post-flight image
AdjustContrastVisible = {'on', 'off'};
[width, height] = split(get(0, 'ScreenSize'), 2);
p = [(width-649)/2+1 height/40+1 649 300]; % preserves size of IMCONTRAST
AdjustContrastPosition = ...
  [right+(p(1)-1)/width (p(2)-1)/height p(3)/width p(4)/height];
OutliersEditString = {'2', '2'};
MDRRadioButtonValue = ~isstretched;
EORadioButtonValue = isstretched;
OutliersEditCallback = cell(1, 2); % cell array of function handles
MinMaxEditCallback = cell(1, 2); % cell array of function handles
[MinEditString, MaxEditString] = deal(cell(1, 2));
[MinEditValue, MaxEditValue] = deal(zeros(1, 2));
c = zeros(1, 2);

iszonechange = true;
[dr dp dn da] = deal(0); % row, panel, nose, and angle changes
number = 0;
isprechange = true;
ispostchange = true;
isnewpreimg = true;
isnewpostimg = true;
isneworbfile = false;
isorbfile = false;
isnewpostdir = true;
no_post_files = 0;

[ip, bp] = deal([]);
isnewwarp = false;
isrewarp = false;
iswarped = false;
ismerged = false;
issnapped = true;
isnewtoggle = false;
ispreleft = true;

delay = 1; % for auto alternate
isautoalternate = false;

while ~strcmp(key, 'q')
  % read old contrast stretching, if available
  if all(c) && (ismerged || iswarped || isprechange || ispostchange || logical(da))
    AdjustContrastPosition = get(c(visible), 'Position');
    for i = duo
      [AdjustContrastVisible{i}, OutliersEditString{i}, ...
        MDRRadioButtonValue(i), EORadioButtonValue(i), ...
        MinEditString{i}, MaxEditString{i}] = ...
        readcontrast(c(i), 'this', 'Visible', 'outlier percent edit', 'String', ...
        'match data range radio', 'Value', 'eliminate outliers radio', 'Value', ...
        'window min edit', 'String', 'window max edit', 'String');
      [MinEditValue(i), MaxEditValue(i)] = ...
        split(str2double({MinEditString{i}, MaxEditString{i}}));
    end % for i
    if ismerged
      delete(c(~~c));
      c = zeros(1, 2);
    end % if ismerged
  end % if all(c) && (ismerged || iswarped || isprechange || ispostchange || logical(da))

  if timetodie
    [fpre, fpost, spre1, spre2, spost1, spost2, npost, d, t, h, keylink] = ...
      reopenfigures(PreFigureName, PostFigureName, zone_ind, grid_arg, increment);
    timetodie = false;

    isnewpreimg = true;
    isnewpostimg = true;
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
      figure(fpre);
      set(spre2, 'HandleVisibility', 'on');
      subplot(spre2); cla;
      h = makegrid(zone_ind, grid_arg);
      set(spre2, 'HandleVisibility', 'off');
    end % if ~timetodie

    isprechange = true;
  end % iszonechange

  if logical(dp) || logical(dr) || logical(dn) || iszonechange
    isorbfile = false; % back to baselines
  end % if logical(dp) || logical(dr) || logical(dn) || iszonechange
  
  if isneworbfile % for fresh onorbit-flight directory listing
    % get on-orbit directory
    [orb_file, orb_dir] = ...
      uigetfile({'*.tif' 'TIFF Files (*.tif)'; '*.*' 'All Files (*.*)'}, ...
      'Choose on-orbit image file', directory);
    if orb_file
      [pre_dir, pre_file] = deal(orb_dir, orb_file);
      isorbfile = true;
      isprechange = true;
    end % if orb_file
  end % if isneworbfile

  if isnewpostdir % for fresh post-flight directory listing
    post_index = 1;

    % get post-flight directory
    old_post_dir = post_dir;
    post_dir = ...
      uigetdir(fullfile(directory, 'PostFlight'), ...
      'Choose post-flight MMOD sub-directory');
    if ~post_dir
      post_dir = old_post_dir;
    else % if post_dir
      % get post_dir
      post_files = dir2cell(fullfile(post_dir, dirarg));
      no_post_files = size(post_files, 1);

      ispostchange = true;
    end % if ~post_dir
  end % if isnewpostdir

  if isprechange
    set([fpre fpost], 'Pointer', 'watch'); % show hourglass
    drawnow;

    if ~isorbfile
      % update update row and panel, or nose, pre directory and file
      switch zone_ind
        case {1, 2}
          row_ind = row_ind + dr;
          panel_ind = panel_ind + dp; % already updated by MAKEMAJORCHANGE

          panel = panels{panel_ind};
          pre_file = ...
            sprintf('%s-%s-%d.tif', mission, panel, row_ind);
        case 3
          nose_suffix_ind = nose_suffix_ind + dn; % changed by clicking only

          panel = panels{1};
          nose_suffix = nose_suffixes{nose_suffix_ind};
          pre_file = sprintf('%s-%s%s.tif', mission, panel, nose_suffix);
      end % switch zone_ind
      pre_dir =  ...
        sprintf('%s\\Baseline\\%s\\%s\\TIFs\\', baseline_dir, zone, panel);
    end % if ~isorbfile

    pre_fullfile = fullfile(pre_dir, pre_file); % pre dir not refreshed
    if ~exist(pre_fullfile, 'file')
      msg = sprintf('Cannot find image file!\nZone %s, %s', zone, pre_file);
      warn_handle = warndlg(msg, 'Can''t find image file!', 'modal');
      putonsame(warn_handle, fpre);
      %putonleft(warn_handle);
      waitfor(warn_handle);
      pre_fullfile = yuck_fullfile;
    end % if ~exist(pre_fullfile, 'file')

    % load image from file
    pre_gimg = imread(pre_fullfile);

    % convert to grayscale
    if ndims(pre_gimg) == 3 % i.e. if pre-flight image
      pre_gimg = rgb2gray(pre_gimg); % grayscale image
    else % if ndims(pre_gimg) ~= 3 % i.e. if on-orbit image
      switch class(pre_gimg)
        case 'single' % from 32-bit tif
          pre_aimg = imadjust(pre_gimg/255, []);
          pre_aimg(isnan(pre_gimg)) = NaN;
          pre_gimg = pre_aimg;
        otherwise
          pre_gimg = im2single(pre_gimg);
      end % switch class(pre_gimg)
    end % if ndims(pre_gimg) == 3
    [pre_m, pre_n] = size(pre_gimg); % get dimensions

    if isinteger(pre_gimg) % i.e. if pre-flight image
      pre_divisor = double(intmax(class(pre_gimg)));
    else % if ~isinteger(pre_gimg)
      pre_divisor = 1; % i.e. if on-orbit image
    end % if isinteger(pre_gimg)

    % update grid
    figure(fpre);
    subplot(spre2);
    switch zone_ind
      case {1, 2}
        set(h(row_ind - dr, panel_ind - dp), 'FaceColor', 'w');
        set(h(row_ind, panel_ind), 'FaceColor', 'r');
      case 3
        set(h(nose_suffix_ind - dn), 'FaceColor', 'w');
        set(h(nose_suffix_ind), 'FaceColor', 'r');
    end % switch zone_ind

    set([fpre fpost], 'Pointer', 'arrow');
    drawnow;

    pre_keepaxes = false;

    [ip, bp] = deal([]);
    isnewpreimg = true;
    if ~isnewpostimg && ~ispreleft && ismerged
      isnewpostimg = true;
    end % if ~isnewpostimg && ~ispreleft && ismerged
    ismerged = false;
    isnewwarp = false;
    isrewarp = false;
    iswarped = false;
  end % if isprechange

  if ispostchange
    set([fpre fpost], 'Pointer', 'watch'); % show hourglass
    drawnow;

    if no_post_files == 0
      post_dir = matlab; % post dir will be refreshed
      post_file = yuck_file;
    else % if no_post_files ~= 0
      post_file = post_files{post_index};
    end % no_post_files == 0
    post_fullfile = fullfile(post_dir, post_file);

    % load image from file
    post_gimg = imread(post_fullfile);

    % convert to grayscale
    if ndims(post_gimg) == 3
      post_gimg = rgb2gray(post_gimg); % grayscale image
    end % if ndims(post_gimg) == 3

    if isinteger(post_gimg)
      post_divisor = single(intmax(class(post_gimg)));
    else % if ~isinteger(post_gimg)
      post_divisor = 1;
    end % if isinteger(post_gimg)

    switch angle_ind - 1
      case 0
        post_rimg = post_gimg; % do nothing
      otherwise
        post_rimg = rot90(post_gimg, angle_ind - 1);
    end % switch angle_ind - 1
    [post_m, post_n] = size(post_rimg); % get final dimensions

    set([fpre fpost], 'Pointer', 'arrow');
    drawnow;

    post_keepaxes = false;

    [ip, bp] = deal([]);
    isnewpostimg = true;
    if ~isnewpreimg && ispreleft && ismerged
      isnewpreimg = true; % true only if not just an angle change
    end % if ~isnewpreimg && ispreleft && ismerged
    ismerged = false;
    isnewwarp = false;
    isrewarp = false;
    iswarped = false;
  end % if ispostchange

  if ~isimageclick
    set([fpre fpost], 'Pointer', 'watch'); % show hourglass
    drawnow;

    if ismerged || iswarped
      % new image always, especially to get IMCONTRAST back if aborted registration
      if ispreleft
        isnewpreimg = true;
      else % if ~ispreleft
        isnewpostimg = true;
      end % if ispreleft
      
      % apply contrast stretching
      if isstretched(1)
        pre_cimg = ...
          imadjust(pre_gimg, [MinEditValue(1) MaxEditValue(1)]/pre_divisor);
        if ~isinteger(pre_gimg)
          pre_cimg(isnan(pre_gimg)) = NaN;
        end % if ~isinteger(pre_gimg)
      else % if ~isstretched(1)
        pre_cimg = pre_gimg;
      end % if isstretched(1)

      if isstretched(2)
        post_cimg = ...
          imadjust(post_rimg, [MinEditValue(2) MaxEditValue(2)]/post_divisor);
      else % if ~isstretched(2)
        post_cimg = post_rimg;
      end % if isstretched(2)

      if isnewwarp
        isnewwarp = false; % don't do it a second time

        if ~isrewarp
          [ip, bp] = deal([]); % fresh start
        end % if ~isrewarp

        if ~da && ~isnewtoggle
          if ispreleft % bp with pre, ip with post
            [bp, ip] = register(pre_cimg, post_cimg, bp, ip);
          else % if ~ispreleft
            [ip, bp] = register(post_cimg, pre_cimg, ip, bp);
          end % if ispreleft
        end % if ~da && ~isnewtoggle
        no_pairs = size(ip, 1);
        drawnow;

        % get input and pre points
        if no_pairs > 1
          figure(fpre); % where to display xlabel
          subplot(spre1);
          xlabel('Warping image...', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
          drawnow;

          isrewarp = true;
          iswarped = true;

          switch no_pairs
            case 2
              tform_type = 'nonreflective similarity';
            case 3
              tform_type = 'affine';
            otherwise % >= 4
              tform_type = 'projective';
          end % switch no_pairs
          
          % tweak points, if necessary
          if issnapped
            % snap higher resolution to lower resolution
            if pre_m*pre_n > post_m*post_n
              transformation = cp2tform(bp, ip, tform_type);
              pre_wimg = imtransform(im2single(pre_cimg), transformation, 'nearest', ...
                'XData', [1 post_n], 'YData', [1 post_m], 'FillValues', NaN);
              bpi = tformfwd(transformation, bp); % put into input coordinate system
              ip = cpcorr(ip, bpi, post_cimg, pre_wimg); % tweak input points
            else % if pre_m*pre_n <= post_m*post_n
              transformation = cp2tform(ip, bp, tform_type);
              post_wimg = imtransform(im2single(post_cimg), transformation, 'nearest', ...
                'XData', [1 pre_n], 'YData', [1 pre_m], 'FillValues', NaN);
              ipb = tformfwd(transformation, ip); % put into base coordinate system
              bp = cpcorr(bp, ipb, pre_cimg, post_wimg); % tweak base points
            end % if pre_m*pre_n > post_m*post_n
          end % if issnapped

          % determine transformation
          if ispreleft
            transformation = cp2tform(ip, bp, tform_type);
            post_wimg = imtransform(im2single(post_cimg), transformation, ...
              'XData', [1 pre_n], 'YData', [1 pre_m], 'FillValues', NaN);
          else % if ~ispreleft
            transformation = cp2tform(bp, ip, tform_type);
            pre_wimg = imtransform(im2single(pre_cimg), transformation, ...
              'XData', [1 post_n], 'YData', [1 post_m], 'FillValues', NaN);
          end % if ispreleft
          xlabel('', 'Visible', 'off');
        else % if no_pairs <= 1
          ismerged = false;
          iswarped = false;
          isrewarp = logical(no_pairs);

          msg = 'Need at least 2 points to transform!';
          warn_handle = warndlg(msg, msg, 'modal');
          putonsame(warn_handle, fpre);
          %putonleft(warn_handle);
          waitfor(warn_handle);
        end % if no_pairs > 1
      end % if isnewwarp

      % what goes on left if merged?
      if iswarped && ismerged
        if ispreleft
          pre_img = cat(3, im2single(pre_cimg), im2single(post_wimg));
          pre_img = im2uint8(nanmean(pre_img, 3));
        else % if ~ispreleft
          post_img = cat(3, im2single(post_cimg), im2single(pre_wimg));
          post_img = im2uint8(nanmean(post_img, 3));
        end % if ispreleft
      end % if iswarped && ismerged
    end % if ismerged || iswarped

    % what goes on left if not merged?
    if ~ismerged
      if ispreleft
        pre_img = pre_gimg;
      else % if ~ispreleft
        post_img = post_rimg;
      end % if ispreleft
    end % if ~ismerged

    % what goes on right
    if ispreleft
      post_img = post_rimg;
    else % if ~ispreleft
      pre_img = pre_gimg;
    end % if ispreleft

    set([fpre fpost], 'Pointer', 'arrow');
    drawnow;
  end % if ~isimageclick

  if isnewpreimg
    set([fpre fpost], 'Pointer', 'watch'); % show hourglass
    drawnow;

    figure(fpre);
    subplot(spre1);
    if ~number
      if pre_keepaxes
        ax = axis;
      end % if pre_keepaxes
      zoom off, pan off % to allow image change under these modes
      imshow(pre_img);
      if pre_keepaxes
        axis(ax);
      else % if ~pre_keepaxes
        pre_keepaxes = true;
      end % if pre_keepaxes
      axis equal
      axis manual % to keep out of automatic mode
    end % if ~number

    if isorbfile
      pre_title = sprintf('%s (on-orbit - 1)', pre_file);
    else % if ~isorbfile
      switch zone_ind
        case {1, 2}
          pre_title = sprintf('%s, Panel %d, Row %d', ...
            zone, panel_ind, row_ind);
        case 3
          switch nose_suffix_ind
            case length(nose_suffixes)
              pre_title = sprintf('%s, center', zone);
            otherwise
              pre_title = sprintf('%s, about %d O''clock', zone, ...
                mod(nose_suffix_ind-1, 12) + 1);
          end % switch nose_suffix_ind
      end % switch zone_ind
      pre_title = sprintf('%s (pre-flight - 1)', pre_title);
    end % if isorbfile

    if ispreleft && ismerged
      if angle
        post_title = sprintf('%s (ROTATED %d°)', post_file, angle);
      else
        post_title = post_file;
      end % if angle
      post_title = sprintf('%s (post-flight - 2)', post_title);
      pre_title = sprintf('%s, merged with %s', pre_title, post_title);
    end % if ispreleft && ismerged
    title(pre_title, 'Interpreter', 'none', 'FontWeight', 'bold');

    if ~ismerged
      if iswarped
        if number
          isautoalternate = alternate(isautoalternate, ispreleft, number, delay, ...
            fpre, fpost, spre1, spost1, pre_title, post_title, ...
            im2uint8(pre_cimg), im2uint8(post_wimg));
        end % if number
      else % if ~iswarped
        % invoke contrast function
        s = [spre1 spost1];
        v = ~[isempty(imhandles(spre1)) isempty(imhandles(spost1))];
        mask = v & ~(c & ishandle(c)); % using Karnaugh map
        for i = duo(mask)
          [c(i), OutliersEditCallback{i}, MinMaxEditCallback{i}] = ...
            opencontrast(s(i), AdjustContrastPosition, AdjustContrastVisible{i}, ...
            OutliersEditString{i}, MDRRadioButtonValue(i), EORadioButtonValue(i));
          addtarget(keylink, c(i));
          switch i
            case 1
              if ~isprechange
                writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                  'window max edit', 'String', MaxEditString{i});
                MinMaxEditCallback{i}(); % same as typing in textbox
              end % if ~isprechange
            case 2
              if ~ispostchange || logical(da)
                writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                  'window max edit', 'String', MaxEditString{i});
                MinMaxEditCallback{i}(); % same as typing in textbox
              end % if ~ispostchange || logical(da)
          end % switch i
          timetodie = timetodie | div(iteration + 1, lifespan);
          iteration = mod(iteration + 1, lifespan);
          % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);
        end % for i
      end % if iswarped
    end % if ~ismerged

    set([fpre fpost], 'Pointer', 'arrow');
    drawnow;
  end % if isnewpreimg

  if isnewpostimg
    set([fpre fpost], 'Pointer', 'watch'); % show hourglass
    drawnow;

    switch da
      case 0
        % do nothing
      otherwise
        post_rimg = rot90(post_rimg, da);
        post_img = rot90(post_img, da); % should work properly if merged
        if ~ispreleft && ismerged
          post_cimg = rot90(post_cimg, da);
          pre_wimg = rot90(pre_wimg, da);
        end % if ~ispreleft && ismerged
        [post_m, post_n] = size(post_img); % get final dimensions
    end % switch da

    switch da
      case 0 % no change
        [tx, ty] = deal(0);
      case 1 % 90°
        [tx, ty] = deal(0, post_m);
      case 2 % 180°
        [tx, ty] = deal(post_n, post_m);
      case 3 % 270°
        [tx, ty] = deal(post_n, 0);
    end % switch da
    H = [
      +cosd(da*increment) +sind(da*increment) 0 tx
      -sind(da*increment) +cosd(da*increment) 0 ty
      0                   0                   1  0
      0                   0                   0  1
      ];

    if iswarped
      r = [ip zeros(size(ip, 1), 1)];
      p = transform(H, r);
      ip = p(:, 1:2);
    end % if iswarped

    figure(fpost);

    % update angle
    if da
      subplot(spost2);
      set(d(angle_ind), 'FaceColor', 'w');
      set(t(angle_ind), 'Color', 'k', 'FontWeight', 'normal');
      angle_ind = mod(angle_ind + da - 1, no_angles) + 1; % changed by clicking only
      angle = angles(angle_ind); % CCW
      set(d(angle_ind), 'FaceColor', 'r');
      set(t(angle_ind), 'Color', 'r', 'FontWeight', 'bold');
    end % if da

    subplot(spost1);
    if post_keepaxes
      ax = axis;
      r = [reshape(ax-.5, 2, 2) zeros(2, 1)];
      p = sort(transform(H, r));
      ax = reshape(p(:, 1:2), 1, 4)+.5;
    end % if post_keepaxes
    if ~number
      zoom off, pan off % to allow image change under these modes
      imshow(post_img);
      if post_keepaxes
        axis(ax);
      else % if ~post_keepaxes
        post_keepaxes = true;
      end % if post_keepaxes
      axis equal
      axis manual % to keep out of automatic mode
    end % if ~number

    if angle
      post_title = sprintf('%s (ROTATED %d°)', post_file, angle);
    else
      post_title = post_file;
    end % if angle
    post_title = sprintf('%s (post-flight - 2)', post_title);

    if ~ispreleft && ismerged
      if isorbfile
        pre_title = sprintf('%s (on-orbit - 1)', pre_file);
      else % if ~isorbfile
        switch zone_ind
          case {1, 2}
            pre_title = sprintf('%s, Panel %d, Row %d', ...
              zone, panel_ind, row_ind);
          case 3
            switch nose_suffix_ind
              case length(nose_suffixes)
                pre_title = sprintf('%s, center', zone);
              otherwise
                pre_title = sprintf('%s, about %d O''clock', zone, ...
                  mod(nose_suffix_ind-1, 12) + 1);
            end % switch nose_suffix_ind
        end % switch zone_ind
        pre_title = sprintf('%s (pre-flight - 1)', pre_title);
      end % if isorbfile
      post_title = sprintf('%s, merged with %s', post_title, pre_title);
    end % if ~ispreleft && ismerged
    title(post_title, 'Interpreter', 'none', 'FontWeight', 'bold');

    if ~ismerged
      if iswarped
        if number
          isautoalternate = alternate(isautoalternate, ispreleft, number, delay, ...
            fpre, fpost, spre1, spost1, pre_title, post_title, ...
            im2uint8(pre_wimg), im2uint8(post_cimg));
        end % if number
      else % if ~iswarped
        % invoke contrast function
        s = [spre1 spost1];
        v = ~[isempty(imhandles(spre1)) isempty(imhandles(spost1))];
        mask = v & ~(c & ishandle(c)); % using Karnaugh map
        for i = duo(mask)
          [c(i), OutliersEditCallback{i}, MinMaxEditCallback{i}] = ...
            opencontrast(s(i), AdjustContrastPosition, AdjustContrastVisible{i}, ...
            OutliersEditString{i}, MDRRadioButtonValue(i), EORadioButtonValue(i));
          addtarget(keylink, c(i));
          switch i
            case 1
              if ~isprechange
                writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                  'window max edit', 'String', MaxEditString{i});
                MinMaxEditCallback{i}(); % same as typing in textbox
              end % if ~isprechange
            case 2
              if ~ispostchange || logical(da)
                writecontrast(c(i), 'window min edit', 'String', MinEditString{i}, ...
                  'window max edit', 'String', MaxEditString{i});
                MinMaxEditCallback{i}(); % same as typing in textbox
              end % if ~ispostchange || logical(da)
          end % switch i
          timetodie = timetodie | div(iteration + 1, lifespan);
          iteration = mod(iteration + 1, lifespan);
          % fprintf('iteration = %d\ttimetodie = %d\n', iteration, timetodie);
        end % for i
      end % if iswarped
    end % if ~ismerged

    set([fpre fpost], 'Pointer', 'arrow');
    drawnow;
  end % if isnewpostimg

  switch zone_ind
    case 1
      status(1, :) = sprintf('      Zone: \t Port   ');
    case 2
      status(1, :) = sprintf('      Zone: \t Stbd   ');
    case 3
      status(1, :) = sprintf('      Zone: \t Nose   ');
  end % switch zone_ind

  if ismerged
    status(2, :) = sprintf('    Merged: \t on     ');
  else % if ~ismerged
    status(2, :) = sprintf('    Merged: \t off    ');
  end % if ismerged

  if iswarped
    status(3, :) = sprintf('    Warped: \t on     ');
  else % if ~iswarped
    status(3, :) = sprintf('    Warped: \t off    ');
  end % if iswarped

  if ispreleft
    if isorbfile
      status(4, :) = sprintf(' Orb-image: \t left   ');
    else % if ~isorbfile
      status(4, :) = sprintf(' Pre-image: \t left   ');
    end % if isorbfile
    status(5, :) = sprintf('Post-image: \t right  ');
  else % if ~ispreleft
    if isorbfile
      status(4, :) = sprintf(' Orb-image: \t right  ');
    else % if ~isorbfile
      status(4, :) = sprintf(' Pre-image: \t right  ');
    end % if isorbfile
    status(5, :) = sprintf('Post-image: \t left   ');
  end % if ispreleft

  set(npost, 'String', status);

  isimageclick = false;
  iszonechange = false;
  [dr dp dn da] = deal(0); % row, panel, nose, and angle changes
  number = 0;
  isprechange = false;
  ispostchange = false;
  isneworbfile = false;
  isnewpostdir = false;
  isnewpreimg = false;
  isnewpostimg = false;
  isnewtoggle = false;
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
      case 'o'
        switch gcf
          case fpre
            isneworbfile = true;
          case fpost
            isnewpostdir = true;
        end % switch gcf
      case 'p'
        if zone_ind == 1
          warn_handle = ...
            warndlg('Already viewing Port!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, fpre);
          %putonleft(warn_handle);
          waitfor(warn_handle);
        else % if zone_ind ~= 1
          zone_ind = 1;
          iszonechange = true;
        end % if zone_ind == 1
      case 's'
        if zone_ind == 2
          warn_handle = ...
            warndlg('Already viewing Starboard!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, fpre);
          %putonleft(warn_handle);
          waitfor(warn_handle);
        else % if zone_ind ~= 2
          zone_ind = 2;
          iszonechange = true;
        end % if zone_ind == 2
      case 'n'
        if zone_ind == 3
          warn_handle = ...
            warndlg('Already viewing Nose Cap!', 'Been there, done that!', 'modal');
          putonsame(warn_handle, fpre);
          %putonleft(warn_handle);
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
        isprechange = logical(dr);
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
            switch gcf
              case fpre
                dp = 0;
              case fpost
                dp = -1;
            end % switch gcf
        end % switch zone_ind
        isprechange = logical(dp);
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
            switch gcf
              case fpre
                dp = 0;
              case fpost
                dp = +1;
            end % switch gcf
        end % switch zone_ind
        isprechange = logical(dp);
      case 'pageup'
        switch gcf
          case fpost
            post_index = post_index - 1;
            if post_index < 1
              post_index = no_post_files;
            end
            ispostchange = true;
        end % switch gcf
      case 'pagedown'
        switch gcf
          case fpost
            post_index = post_index + 1;
            if post_index > no_post_files
              post_index = 1;
            end
            ispostchange = true;
        end % switch gcf
      case 'home'
        zoom(gcf, 'out')
      case 'm'
        figure(fpre); % where to display xlabel
        subplot(spre1);
        if iswarped
          ismerged = ~ismerged;
          isnewpreimg = ispreleft;
          isnewpostimg = ~ispreleft;
          xlabel('', 'Visible', 'off');
        else % if ~iswarped
          xlabel('No merging available before warping with kontrol points.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
        end % if iswarped
      case 't'
        isnewtoggle = true;
        ispreleft = ~ispreleft;
        [isnewwarp, isrewarp] = deal(iswarped);
        [isnewpreimg, isnewpostimg] = deal(ismerged);
        if ispreleft
          putonleft(fpre);
          putonright([fpost c]);
        else % if ~ispreleft
          putonright(fpre);
          putonleft([fpost c]);
        end % if ispreleft
      case 'period'
        issnapped = ~issnapped;
      case 'k'
        isnewwarp = true;
        ismerged = true;
      case {'1', '2'}
        if iswarped
          ismerged = false;
          if ispreleft
            isnewpreimg = true;
          else % if ~ispreleft
            isnewpostimg = true;
          end % if ispreleft

          number = str2double(key);
        end % if iswarped
      case '3' % auto alternate
        if iswarped
          ismerged = false;
          if ispreleft
            isnewpreimg = true;
          else % if ~ispreleft
            isnewpostimg = true;
          end % if ispreleft
          isautoalternate = ~isautoalternate;

          number = 2 - ispreleft; % default to left image
        end % if iswarped
      case 'c'
        figure(fpre); % where to display xlabel
        subplot(spre1);
        if ~ismerged && ~iswarped
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
          end % if_ ishandle(PTLError)
          delete([PTLError CEOError]);
          xlabel('', 'Visible', 'off');
        else % if ismerged || iswarped
          xlabel('No contrast stretching available while warped.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
        end % if ~ismerged && ~iswarped
      case 'v'
        figure(fpre); % where to display xlabel
        subplot(spre1);
        if ~ismerged && ~iswarped
          AdjustContrastPosition = get(c(visible), 'Position');
          AdjustContrastVisible{visible} = 'off';
          set(c(visible), 'Visible', 'off');
          visible = 3 - visible;
          AdjustContrastVisible{visible} = 'on';
          set(c(visible), 'Position', AdjustContrastPosition, 'Visible', 'on');
          putontop(c(visible));
          xlabel('', 'Visible', 'off');
        else % if ismerged || iswarped
          xlabel('No contrast stretching available while warped.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
        end % if ~ismerged && ~iswarped
      case 'a'
        if iswarped
          figure(fpre); % where to display xlabel
          subplot(spre1);
          xlabel('Preparing archive folder and images.', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');

          pre_fullfile = fullfile(pre_dir, pre_file);
          post_fullfile = fullfile(post_dir, post_file);
          [ignore, pre_filename] = fileparts(pre_fullfile);
          [ignore, post_filename] = fileparts(post_fullfile);

          if ispreleft
            dest_dir = ...
              fullfile(post_dir, sprintf('%s__reg-to__%s', post_filename, pre_filename));
          else % if ~ispreleft
            dest_dir = ...
              fullfile(post_dir, sprintf('%s__reg-to__%s', pre_filename, post_filename));
          end % if ispreleft

          if ~exist(dest_dir, 'dir')
            [success, message] = mkdir(dest_dir);
            if ~success
              error(message);
            end %if ~success
          end % if ~exist(dest_dir, 'dir')

          reg_dir = fullfile(dest_dir, 'reg');
          if ~exist(reg_dir, 'dir')
            [success, message] = mkdir(reg_dir);
            if ~success
              error(message);
            end %if ~success
          end % if ~exist(reg_dir, 'dir')

          zoom_dir = fullfile(dest_dir, 'zoom');
          if ~exist(zoom_dir, 'dir')
            [success, message] = mkdir(zoom_dir);
            if ~success
              error(message);
            end %if ~success
          end % if ~exist(zoom_dir, 'dir')

          crop_dir = fullfile(dest_dir, 'crop');
          if ~exist(crop_dir, 'dir')
            [success, message] = mkdir(crop_dir);
            if ~success
              error(message);
            end %if ~success
          end % if ~exist(crop_dir, 'dir')

          pre_gray_fullfile = fullfile(reg_dir, [pre_filename '_gray.tif']);
          pre_reg_fullfile = fullfile(reg_dir, [pre_filename '_reg.tif']);
          pre_zoom_fullfile = fullfile(zoom_dir, [pre_filename '_zoom.tif']);
          pre_reg_zoom_fullfile = fullfile(zoom_dir, [pre_filename '_reg_zoom.tif']);
          pre_crop_fullfile = fullfile(crop_dir, [pre_filename '_crop.tif']);
          pre_reg_crop_fullfile = fullfile(crop_dir, [pre_filename '_reg_crop.tif']);

          post_gray_fullfile = fullfile(reg_dir, [post_filename '_gray.tif']);
          post_reg_fullfile = fullfile(reg_dir, [post_filename '_reg.tif']);
          post_zoom_fullfile = fullfile(zoom_dir, [post_filename '_zoom.tif']);
          post_reg_zoom_fullfile = fullfile(zoom_dir, [post_filename '_reg_zoom.tif']);
          post_crop_fullfile = fullfile(crop_dir, [post_filename '_crop.tif']);
          post_reg_crop_fullfile = fullfile(crop_dir, [post_filename '_reg_crop.tif']);

          prefix = genprefix(pre_fullfile, post_fullfile);
          reg_anim_fullfile = fullfile(post_dir, [prefix '.gif']);
          zoom_anim_fullfile = fullfile(post_dir, [prefix 'zoom.gif']);
          crop_anim_fullfile = fullfile(post_dir, [prefix 'crop.gif']);

          p = 2 - ispreleft;
          if isstretched(p)
            if c(p)
              [MinEditString{p}, MaxEditString{p}] = ...
                readcontrast(c(p), 'window min edit', 'String', ...
                'window max edit', 'String');
              [MinEditValue(p), MaxEditValue(p)] = ...
                split(str2double({MinEditString{p}, MaxEditString{p}}));
            end % if c(p)
            if ispreleft
              pre_cimg = ...
                imadjust(pre_gimg, [MinEditValue(p) MaxEditValue(p)]/pre_divisor);
            else % if ~ispreleft
              post_cimg = ...
                imadjust(post_rimg, [MinEditValue(p) MaxEditValue(p)]/post_divisor);
            end % if ispreleft
          else % if ~isstretched(p)
            if ispreleft
              pre_cimg = pre_gimg;
            else % if ~ispreleft
              post_cimg = post_rimg;
            end % if ispreleft
          end % if isstretched(p)

          % copy original pre-flight, and write modified images
          [success, message] = copyfile(pre_fullfile, dest_dir); % orig
          if ~success
            err_handle = errordlg(message, ...
              'Cannot copy original pre-flight image!', 'modal');
            putonleft(err_handle);
            waitfor(err_handle);
          else % if success
            if ispreleft
              pre_gray_img = pre_cimg;
              post_reg_img = post_wimg;

              ax = axis(spre1);
              pre_zoom_img = imcrop(pre_gray_img, getzoom(ax));
              post_reg_zoom_img = imcrop(post_reg_img, getzoom(ax));
              pre_crop_img = imcrop(pre_gray_img, getbounds(bp));
              post_reg_crop_img = imcrop(post_reg_img, getbounds(bp));

              imwrite(pre_gray_img, pre_gray_fullfile); % reg
              imwrite(post_reg_img, post_reg_fullfile);
              imwrite(im2uint8(pre_gray_img), reg_anim_fullfile, 'DelayTime', delay); % reg anim
              imwrite(im2uint8(post_reg_img), reg_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(pre_gray_img), im2uint8(post_reg_img)), ...
              %  reg_anim_fullfile, 'DelayTime', delay);

              imwrite(pre_zoom_img, pre_zoom_fullfile); % zoom
              imwrite(post_reg_zoom_img, post_reg_zoom_fullfile);
              imwrite(im2uint8(pre_zoom_img), zoom_anim_fullfile, 'DelayTime', delay); % zoom anim
              imwrite(im2uint8(post_reg_zoom_img), zoom_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(pre_zoom_img), im2uint8(post_zoom_reg_img)), ...
              %  zoom_anim_fullfile, 'DelayTime', delay);

              imwrite(pre_crop_img, pre_crop_fullfile); % crop
              imwrite(post_reg_crop_img, post_reg_crop_fullfile);
              imwrite(im2uint8(pre_crop_img), crop_anim_fullfile, 'DelayTime', delay); % crop anim
              imwrite(im2uint8(post_reg_crop_img), crop_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(pre_crop_img), im2uint8(post_crop_reg_img)), ...
              %  crop_anim_fullfile, 'DelayTime', delay);
            else % if ~ispreleft
              pre_reg_img = pre_wimg;
              post_gray_img = post_cimg;

              ax = axis(spost1);
              pre_reg_zoom_img = imcrop(pre_reg_img, getzoom(ax));
              post_zoom_img = imcrop(post_gray_img, getzoom(ax));
              pre_reg_crop_img = imcrop(pre_reg_img, getbounds(ip));
              post_crop_img = imcrop(post_gray_img, getbounds(ip));

              imwrite(post_gray_img, post_gray_fullfile); % reg
              imwrite(pre_reg_img, pre_reg_fullfile);
              imwrite(im2uint8(post_gray_img), reg_anim_fullfile, 'DelayTime', delay); % reg anim
              imwrite(im2uint8(pre_reg_img), reg_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(post_gray_img), im2uint8(pre_reg_img)), ...
              %  reg_anim_fullfile, 'DelayTime', delay);

              imwrite(post_zoom_img, post_zoom_fullfile); % zoom
              imwrite(pre_reg_zoom_img, pre_reg_zoom_fullfile);
              imwrite(im2uint8(post_zoom_img), zoom_anim_fullfile, 'DelayTime', delay); % zoom anim
              imwrite(im2uint8(pre_reg_zoom_img), zoom_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(post_zoom_img), im2uint8(pre_zoom_reg_img)), ...
              %  zoom_anim_fullfile, 'DelayTime', delay);

              imwrite(post_crop_img, post_crop_fullfile); % crop
              imwrite(pre_reg_crop_img, pre_reg_crop_fullfile);
              imwrite(im2uint8(post_crop_img), crop_anim_fullfile, 'DelayTime', delay); % crop anim
              imwrite(im2uint8(pre_reg_crop_img), crop_anim_fullfile, 'DelayTime', delay, 'WriteMode', 'append');
              %imwrite(cat(3, im2uint8(post_crop_img), im2uint8(pre_crop_reg_img)), ...
              %  crop_anim_fullfile, 'DelayTime', delay);
            end % if ispreleft
            figure(fpre); % where to display xlabel
            subplot(spre1);
            xlabel('Registered, cropped, and zoom images saved in post-flight directory.', ...
              'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
          end % if ~success
        else % ~if iswarped
          figure(fpre); % where to display xlabel
          subplot(spre1);
          xlabel('Cannot archive if images are not warped!', ...
            'Visible', 'on', 'FontWeight', 'bold', 'Interpreter', 'none');
        end % if iswarped
      case 'z'
        switch character % disambiguate
          case 'Z'
            figure(fpre);
            sparkle(h);
          otherwise
            msg = sprintf('I don''t understand "%s"!', key);
            warn_handle = warndlg(msg, 'I don''t understand!', 'modal');
            putonsame(warn_handle, fpre);
            %putonleft(warn_handle);
            waitfor(warn_handle);
        end % switch character
      case 'q'
        disp('QUIT!');
        close force all
      otherwise
        msg = sprintf('I don''t understand "%s"!', key);
        warn_handle = warndlg(msg, 'I don''t understand!', 'modal');
        putonsame(warn_handle, fpre);
        %putonleft(warn_handle);
        waitfor(warn_handle);
    end % switch key
  else % if ~iskey (i.e. is mouse button)
    set([spre2 spost2], 'HandleVisibility', 'on');
    switch gca
      case imgca
        isimageclick = true;
      case spre2
        u = getappdata(fpre, 'GridData');
        if ~isempty(u)
          switch zone_ind
            case {1, 2}
              [dr, dp] = split(u - [row_ind, panel_ind]);
              isprechange = logical(dp) | logical(dr);
            case 3
              dn = u - nose_suffix_ind;
              isprechange = logical(dn);
          end % switch zone_ind
          setappdata(fpre, 'GridData', []);
        end % ~isempty(u)
      case spost2
        u = getappdata(fpost, 'DialData'); % always an angle index
        da = mod(u - angle_ind, no_angles);
        isnewpostimg = logical(da);
    end % switch gca
    set([spre2 spost2], 'HandleVisibility', 'off');
  end % if iskey
end % while ~strcmp(key, 'q')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REOPENFIGURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fpre, fpost, spre1, spre2, spost1, spost2, npost, d, t, h, keylink, right] = ...
  reopenfigures(PreFigureName, PostFigureName, zone_ind, grid_arg, increment)

screen_size = get(0, 'ScreenSize');
if isempty(get(0, 'CurrentFigure')) % if first time
  monitor_positions = get(0, 'MonitorPositions');
  column = div(monitor_positions(:, 1), screen_size(3));
  left = min(column);
  right = max(column);
  switch length(column)
    case 1
      left_monitor = [left 0 1/2 1];
      right_monitor = [left+1/2 0 1/2 1];
    otherwise
      left_monitor = [left 0 1 1];
      right_monitor = [right 0 1 1];
  end % switch length(column)
  griddata = []; % row_ind panel_ind, or nose_suffix_ind
  dialdata = 1; % angle_ind
else % if ~isempty(get(0, 'CurrentFigure'))
  figs = sort(get(0, 'Children')); % ignores IMCONTRAST
  left_monitor = get(figs(1), 'OuterPosition'); % save for later
  right_monitor = get(figs(2), 'OuterPosition'); % save for later
  griddata = getappdata(figs(1), 'GridData'); % save for later
  dialdata = getappdata(figs(2), 'DialData'); % save for later
  close force all % figures
end % if isempty(get(0, 'CurrentFigure'))
if screen_size(4) < 1200
  font_size = 7;
else % if screen_size(4) >= 1200
  font_size = 8;
end % if screen_size(4) < 1200

% define pre menus
pre_left_menu(1, :) = sprintf('      p s n       \t port/stbd/nose');
pre_left_menu(2, :) = sprintf(' hyphen underscore\t  change row # ');
pre_left_menu(3, :) = sprintf('       [ ]        \t change panel #');
pre_left_menu(4, :) = sprintf('        o         \t on-orbit image');
pre_left_menu(5, :) = sprintf('       Home       \t  full zoom out');
pre_left_menu(6, :) = sprintf('        m         \t  toggle merge ');
pre_left_menu(7, :) = sprintf('       1 2        \t    alternate  ');
pre_left_menu(8, :) = sprintf('        3         \t auto alternate');

pre_right_menu(1, :) = sprintf('        k         \t kontrol points');
pre_right_menu(2, :) = sprintf('        t         \t toggle screens');
pre_right_menu(3, :) = sprintf('        a         \t  archive reg. ');
pre_right_menu(4, :) = sprintf('        c         \t cont. stretch ');
pre_right_menu(5, :) = sprintf('        v         \t cont. visible ');
pre_right_menu(6, :) = sprintf('        q         \t      quit     ');

% define post menu
post_left_menu(1, :) = sprintf('        o         \t  open post-dir');
post_left_menu(2, :) = sprintf(' PageUp PageDown  \t    new image  ');
post_left_menu(3, :) = sprintf('       Home       \t    zoom out   ');
post_left_menu(4, :) = sprintf('        m         \t  toggle merge ');
post_left_menu(5, :) = sprintf('       1 2        \t    alternate  ');
post_left_menu(6, :) = sprintf('        3         \t auto alternate');

post_right_menu(1, :) = sprintf('        k         \t kontrol points');
post_right_menu(2, :) = sprintf('        t         \t toggle screens');
post_right_menu(3, :) = sprintf('        a         \t  archive reg. ');
post_right_menu(4, :) = sprintf('        c         \t cont. stretch ');
post_right_menu(5, :) = sprintf('        v         \t cont. visible ');
post_right_menu(6, :) = sprintf('        q         \t      quit     ');

% position pre plots
fpre = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', PreFigureName, ...
  'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'left'}, 'Units', 'normalized', 'OuterPosition', left_monitor);
setappdata(fpre, 'GridData', griddata);
spre1 = subplot('Position', [0 .2 1 .75]); % main pre image
spre2 = subplot('Position', [.25 .025 .5 .1]); % grid
uicontrol('Parent', fpre, 'Style', 'text', 'String', pre_left_menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .1], ...
  'FontName', 'Courier', 'FontSize', font_size);
uicontrol('Parent', fpre, 'Style', 'text', 'String', pre_right_menu, ...
  'Units', 'normalized', 'Position', [.775 .025 .2 .1], ...
  'FontName', 'Courier', 'FontSize', font_size);

% position on-postit plots
fpost = figure('MenuBar', 'none', 'ToolBar', 'figure', 'NumberTitle', 'off', ...
  'Pointer', 'arrow', 'Name', PostFigureName, 'KeyPressFcn', @keypressfcn, ...
  'CloseRequest', {@quitit, 'left'}, 'Units', 'normalized', ...
  'OuterPosition', right_monitor);
setappdata(fpost, 'DialData', dialdata);
spost1 = subplot('Position', [0 .2 1 .75]); % main on-postit image
spost2 = subplot('Position', [.5 .05 .275 .1]); % rotation dial
npost = uicontrol('Parent', fpost, 'Style', 'text', 'Units', 'normalized', ...
  'Position', [.275 .025 .2 .1], ...
  'FontName', 'Courier', 'FontSize', font_size); % status
uicontrol('Parent', fpost, 'Style', 'text', 'String', post_left_menu, ...
  'Units', 'normalized', 'Position', [.025 .025 .2 .1], ...
  'FontName', 'Courier', 'FontSize', font_size);
uicontrol('Parent', fpost, 'Style', 'text', 'String', post_right_menu, ...
  'Units', 'normalized', 'Position', [.775 .025 .2 .1], ...
  'FontName', 'Courier', 'FontSize', font_size);

% turn off superfluous buttons
toggle_handles = [findall([fpre fpost], 'type', 'uipushtool'); ...
  findall([fpre fpost], 'type', 'uitogglesplittool'); ...
  findall([fpre fpost], 'type', 'uitoggletool')];
for toggle_handle = toggle_handles'
  switch get(toggle_handle, 'Tag')
    case {'Exploration.Pan', 'Exploration.ZoomOut', 'Exploration.ZoomIn'}
      set(toggle_handle, 'Separator', 'off', 'OnCallback', 'beep', 'OffCallback', 'beep');
    otherwise
      set(toggle_handle, 'Enable', 'off', 'Visible', 'off'); % disable and hide
  end % switch get(toggle_handle, 'Tag')
end % for toggle_handle = toggle_handles'

% alter zoom and pan functions to allow buttondownfcn to execute
z = zoom(fpre); p = pan(fpre);
[z.ButtonDownFilter, p.ButtonDownFilter] = deal(@buttondownfilter);
puc = uicontextmenu; % disable pan right clicking, for Frank
uimenu('Parent', puc, 'Enable', 'off', 'Visible', 'off');
set(p, 'UIContextMenu', puc);

z = zoom(fpost); p = pan(fpost);
[z.ButtonDownFilter, p.ButtonDownFilter] = deal(@buttondownfilter);
puc = uicontextmenu; % disable pan right clicking, for Frank
uimenu('Parent', puc, 'Enable', 'off', 'Visible', 'off');
set(p, 'UIContextMenu', puc);

figure(fpre);
set(spre2, 'HandleVisibility', 'on');
subplot(spre2); cla;
h = makegrid(zone_ind, grid_arg);
set(spre2, 'HandleVisibility', 'off');
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

figure(fpost);
set(spost2, 'HandleVisibility', 'on');
subplot(spost2);
[d, t] = makedial(increment);
set(spost2, 'HandleVisibility', 'off');
angle_ind = dialdata;
set(d(angle_ind), 'FaceColor', 'r');
set(t(angle_ind), 'Color', 'r', 'FontWeight', 'bold');

keylink = linkprop([fpre fpost], 'UserData');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GENFILENAME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function prefix = genprefix(pre_fullfile, post_fullfile)

[pre_dir, pre_filename] = fileparts(pre_fullfile);
try
  info = imfinfo(pre_fullfile);
catch it
  switch it.identifier
    case 'MATLAB:tifftagsread:repackageTag:unrecognizedTagFormat'
      [info.Height info.Width] = size(imread(fullfile(late_dir, late_file)));
      info.BitDepth = 32; % assume LDRI
    otherwise
      rethrow(it)
  end % switch
end % try
if info.BitDepth == 32 % LDRI
  pre_suffix = regexp(pre_filename, '\d[RL]\w*', 'match'); % cell
  pre_suffix = regexprep(pre_suffix{1}, '_Panel', ''); % string
else % if info.BitDepth ~=32
  pre_suffix = regexp(pre_filename, '[RL]\d*-\d', 'match'); % cell
  if isempty(pre_suffix) % must not be pre-flight image
    pre_suffix = pre_filename; % literal string of filename
  else % ~isempty(pre_suffix)
    pre_suffix = pre_suffix{1}; % string
  end % if isempty(pre_suffix)
end % if info.BitDepth == 32
if ~isempty(strfind(pre_dir, '-Late'))
  pre_suffix = sprintf('LATE_%s', pre_suffix);
end % if ~isempty(strfind(pre_dir, '-Late'))
    
[post_dir, post_filename] = fileparts(post_fullfile);
[ignore, post_index_str] = fileparts(post_dir);
post_index = str2double(post_index_str);
post_img_no = sscanf(post_filename, 'IMG_%d'); % with no leading zeros
prefix = sprintf('Index%d_%s+%03d', post_index, pre_suffix, post_img_no);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALTERNATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function isautoalternate = alternate(isautoalternate, ispreleft, number, delay, ...
  fpre, fpost, spre1, spost1, pre_title, post_title, pre_img, post_img)

key = '';
set(gcf, 'UserData', ''); % clear old keys
while isempty(key)
  if isautoalternate
    tic; % restart timer
    number = 3 - number;
  end % if isautoalternate
  while (~isautoalternate || toc < delay) && isempty(key)
    key = split(get(gcf, 'UserData'));
    if isautoalternate
      switch key
        case '3'
          isautoalternate = false;
          number = 2 - ispreleft;
        otherwise
          key = ''; % stay in inner while loop
      end % switch key
    end % if isautoalternate
    if ~isautoalternate
      key = ' '; % force exit of inner while loop
    end % if ~isautoalternate
  end % while (~isautoalternate || toc < delay) && isempty(key)
  if ispreleft
    figure(fpre);
    subplot(spre1);
  else % if ~ispreleft
    figure(fpost);
    subplot(spost1);
  end % if ispreleft
  ax = axis;
  switch number
    case 1
      imshow(pre_img);
      ttl = pre_title;
    case 2
      imshow(post_img);
      ttl = post_title;
  end % switch number
  title(ttl, 'Interpreter', 'none', 'FontWeight', 'bold');
  axis(ax);
  axis equal % do NOT set to axis image -- screws up moved axes
  axis manual % to keep out of automatic mode  drawnow;
end % while isempty(key)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETZOOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function crop = getzoom(ax)
xmin = floor(ax(1));
ymin = floor(ax(3));
xmax = ceil(ax(2));
ymax = ceil(ax(4));
width = xmax - xmin + 1;
height = ymax - ymin + 1;
crop = [xmin, ymin, width-1, height-1]; % see imcrop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETBOUNDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function crop = getbounds(xy)
x = xy(:, 1);
y = xy(:, 2);
xmin = floor(min(x));
ymin = floor(min(y));
xmax = ceil(max(x));
ymax = ceil(max(y));
width = xmax - xmin + 1;
height = ymax - ymin + 1;
crop = [xmin, ymin, width-1, height-1]; % see imcrop
