%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    2/1/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% close all; clc;
% tic
function SlipRateGUI
% if nargin ~= 0;
% 	direc = varargin{1};
% else
if isdeployed
    fprintf(sprintf('%s\n',ctfroot));
    direc = fullfile(ctfroot);
else
    direc = '.';
end
% end

% Color variables
white           = [1 1 1];
lightGrey       = 0.85 * [1 1 1];
fn              = 'Helvetica';
fs              = 12;

% I/O options
global GLOBAL ul cul st fSize pSize;
GLOBAL.filestream = 1;
ul  = 10; % number of navigation undo levels
cul = ul - 1; % current undo level
st  = 2; % where to start counting the undo levels

load('dirNames.mat')
nDirs           = numel(dirNames);
[S, ix]         = sort(upper(dirNames));
dirNames        = dirNames(ix);
dirList         = dirNames;
for dd = 1:numel(dirNames);
    label       = sprintf('(%i)',dd);
%     fprintf(sprintf('%s\n',fullfile(direc,dirNames{dd},'Reference.txt')));
    fid         = fopen(fullfile(direc,dirNames{dd},'Reference.txt'));
    Reference   = fgetl(fid);
    fclose(fid);
    dirList{dd} = sprintf('%-6s%s', label, Reference);
end
dirList         = [{'< none >'}, dirList];
Row.listNames   = [{'< none >'}, dirNames];


% Sort List
sortList       = {'Author Name (alphabetical)','Publication Year (oldest-newest)', 'Study Area (north-south)', 'Study Area (west-east)'};

% Value List
% valueList       = {'< none >', 'potency', 'east slip', 'north slip', 'PA/NA-parallel slip', 'PA/NA-perpendicular slip', 'strike slip', 'tensile slip'};
% valueList       = {'< none >', 'potency', 'east-west opening', 'north-south opening', 'east-west shear', 'north-south shear', 'PA/NA-parallel shear', 'PA/NA-perpendicular shear', 'PA/NA-parallel opening', 'PA/NA-perpendicular opening'};
valueList       = {'< none >', 'potency', 'vxx', 'vxy', 'vyx', 'vyy','shear strain','rotation','PA/NA-parallel shear', 'PA/NA-perpendicular shear', 'PA/NA-parallel opening', 'PA/NA-perpendicular opening'};

% Metric List
% metricList      = {'< none >', 'mean', 'median', 'st. dev.', 'st. err.', 'coef. of var.','number of studies'};
metricList      = {'< none >', 'mean', 'median', 'st. dev.', 'number of studies'};

%%% PA/NAM orientation
Row.pbstrike = deg2rad(145);

% Open figure
screensize = get(0, 'screensize');
figloc = screensize(3:4)./2 - screensize(3:4)./4;
% figpos = [figloc screensize(3)/2 screensize(4)/1.5];
figpos = [figloc 1000 720];
fSize = [figpos(3) figpos(4) figpos(3) figpos(4)];
hFig = figure('Position', figpos, 'Color', lightGrey, 'menubar', 'figure', 'toolbar', 'figure');
set(hFig, 'MenuBar', 'none', 'ToolBar', 'none');

PbLen                     = 75;
PbWid                     = 25;
% List of Studies
Row.studyPanel          = uipanel('Position',  [0.516 0.622 .456 .355], 'visible', 'on', 'tag',  'Row.stPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Slip Rate Studies:','fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
P                       = get(Row.studyPanel,'Position');
% pSize               	= [.456 .355 .456 .355];
pSize                   = [P(3:4) P(3:4)];
pbl                     = PbLen/fSize(1)/pSize(1);
pbw                     = PbWid/fSize(2)/pSize(2);
Row.sorttext            = uicontrol('parent', Row.studyPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.021 0.83 .56 0.085],  'visible', 'on', 'tag', 'Row.sortText',                                                   'string', 'Sort by:',     'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', 14, 'HorizontalAlignment', 'left');
Row.sortMenu            = uicontrol('parent', Row.studyPanel, 'style', 'popupmenu',  'Position', fSize.*pSize.*[0.14 0.83 .500 .085],   'visible', 'on', 'tag', 'Row.sortMenu', 'callback', 'RowlfFunctions(''Row.sortMenu'')',   'string',  sortList,      'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.modelList           = uicontrol('parent', Row.studyPanel, 'style', 'listbox',    'Position', fSize.*pSize.*[0.021 0.14 .953 .683],  'visible', 'on', 'tag', 'Row.modList',  'callback', 'RowlfFunctions(''Row.selModList'')', 'string',  dirList, 'BackgroundColor', white,     'FontName', fn, 'FontSize', fs, 'ForegroundColor', 'k', 'min', 0, 'max', nDirs);
% Row.allPush             = uicontrol('parent', Row.studyPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.021 0.025 .148 .085], 'visible', 'on', 'tag', 'Row.allPush',  'callback', 'RowlfFunctions(''Row.allPush'')',    'string', 'Select All',   'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.nonePush            = uicontrol('parent', Row.studyPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.203 0.025 .148 .085], 'visible', 'on', 'tag', 'Row.nonePush', 'callback', 'RowlfFunctions(''Row.nonePush'')',   'string', 'Remove All',   'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.allPush             = uicontrol('parent', Row.studyPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.021 0.020 pbl pbw], 'visible', 'on', 'tag', 'Row.allPush',  'callback', 'RowlfFunctions(''Row.allPush'')',    'string', 'Select All',   'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.nonePush            = uicontrol('parent', Row.studyPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.021+pbl 0.020 pbl pbw], 'visible', 'on', 'tag', 'Row.nonePush', 'callback', 'RowlfFunctions(''Row.nonePush'')',   'string', 'Remove All',   'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.loadtext            = uicontrol('parent', Row.studyPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.37 0.020 .56 0.085],      'visible', 'on', 'tag', 'Row.loadText', 'string', '(command-click to select multiple studies)', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'HorizontalAlignment', 'left');

% Define metrics
Row.displayPanel        = uipanel('Position',  [0.516 0.427 .456 .180], 'visible', 'on', 'tag',  'Row.dispPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Display','fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
P                       = get(Row.displayPanel,'Position');
% pSize                   = [.457 .164 .456 .180];
pSize                   = [P(3:4) P(3:4)];
pbl                     = PbLen/fSize(1)/pSize(1);
pbw                     = PbWid/fSize(2)/pSize(2);
Row.valueText           = uicontrol('parent', Row.displayPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.021 0.60 0.200 0.231], 'visible', 'on', 'tag', 'Row.valueText',  'string', 'Value',               'HorizontalAlignment', 'left', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.valueMenu           = uicontrol('parent', Row.displayPanel, 'style', 'popupmenu',  'Position', fSize.*pSize.*[0.10 0.60 0.464 0.231],  'visible', 'on', 'tag', 'Row.valueMenu',  'callback', 'RowlfFunctions(''Row.valueMenu'')','string', valueList,             'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.metricText          = uicontrol('parent', Row.displayPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.021 0.40 0.200 0.231],  'visible', 'on', 'tag', 'Row.metricText', 'string', 'Metric',              'HorizontalAlignment', 'left', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.metricMenu          = uicontrol('parent', Row.displayPanel, 'style', 'popupmenu',  'Position', fSize.*pSize.*[0.10 0.40 0.464 0.231],   'visible', 'on', 'tag', 'Row.metricMenu', 'callback', 'RowlfFunctions(''Row.metricMenu'')','string', metricList,             'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.geoCheck            = uicontrol('parent', Row.displayPanel, 'style', 'checkbox',   'Position', fSize.*pSize.*[0.021 0.25 0.5 0.231],    'visible', 'on', 'tag', 'Row.geoCheck',   'callback', 'RowlfFunctions(''Row.geoCheck'')', 'string', 'Show Geologic Rates', 'HorizontalAlignment', 'left','BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs, 'Enable', 'off');
Row.plotPush            = uicontrol('parent', Row.displayPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.021 0.06 pbl pbw],  'visible', 'on', 'tag', 'Row.plotPush',   'callback', 'RowlfFunctions(''Row.plotPush'')', 'string', 'Plot',                'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.plotPush            = uicontrol('parent', Row.displayPanel, 'style', 'pushbutton', 'Position', [fSize.*pSize.*[0.021 0.06] pbl pbw],  'visible', 'on', 'tag', 'Row.plotPush',   'callback', 'RowlfFunctions(''Row.plotPush'')', 'string', 'Plot',                'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

Row.clearPush           = uicontrol('parent', Row.displayPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.021+pbl 0.06 pbl pbw],  'visible', 'on', 'tag', 'Row.clearPush',  'callback', 'RowlfFunctions(''Row.clearAll'')', 'string', 'Clear All', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.savePush            = uicontrol('parent', Row.displayPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[1-pbl-0.021 0.06 pbl pbw],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.saveOut'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% Small Axis
Row.smallPanel          = uipanel('Position', [0.516 0.02 0.456 0.39], 'visible', 'on', 'tag',  'Row.smPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Summary Info','fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
% pSize                   = [0.457 0.164 0.456 0.36];
P                       = get(Row.smallPanel,'Position');
pSize                   = [P(3:4) P(3:4)];
Row.smallAxis           = axes('parent',      Row.smallPanel, 'units', 'pixels',     'position', fSize.*pSize.*[0.410 0.289 0.551 0.642], 'visible', 'on', 'Tag', 'Row.smallAxis', 'Layer', 'top', 'xlim', [0 nDirs], 'ylim', [0 100], 'FontName', fn);

% Sub Panel
Row.subPanel            = uibuttongroup('parent',   Row.smallPanel, 'Position', [0.010 0.5 0.28 0.48], 'visible', 'on', 'tag',  'Row.subPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
% pSize2                  = [0.148 0.3 0.148 0.3];
P                       = get(Row.subPanel,'Position');
pSize2                  = [P(3:4) P(3:4)];
Row.barButton           = uicontrol('parent', Row.subPanel,     'style', 'radiobutton', 'Position', fSize.*pSize.*pSize2.*[0.048 0.28 0.873 0.2], 'visible', 'on', 'tag', 'Row.barButton', 'callback', 'RowlfFunctions(''Row.barButton'')', 'BackgroundColor', lightGrey, 'string', 'Plot', 'FontName', fn, 'FontSize', fs);
Row.histButton          = uicontrol('parent', Row.subPanel,     'style', 'radiobutton', 'Position', fSize.*pSize.*pSize2.*[0.048 0.11 2 0.2],     'visible', 'on', 'tag', 'Row.histButton', 'callback', 'RowlfFunctions(''Row.histButton'')', 'BackgroundColor', lightGrey, 'string', 'Histogram', 'FontName', fn, 'FontSize', fs);
% Row.profButton          = uicontrol('parent', Row.subPanel,     'style', 'radiobutton', 'Position', fSize.*pSize.*pSize2.*[0.048 0.1 2 0.4],     'visible', 'on', 'tag', 'Row.profButton', 'BackgroundColor', lightGrey, 'string', 'Profile', 'FontName', fn, 'FontSize', fs);

pbl                     = PbLen/fSize(1)/pSize(1);
pbw                     = PbWid/fSize(2)/pSize(2);
Row.selectText          = uicontrol('parent', Row.smallPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.030 0.72 0.25 0.18],    'visible', 'on', 'tag', 'Row.selectText', 'string', 'Compare within:',              'HorizontalAlignment', 'left', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.gridPush            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030 0.74 pbl pbw],    'visible', 'on', 'tag', 'Row.gridPush',  'callback', 'RowlfFunctions(''Row.gridPush'')', 'string', 'Grid Cell', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.rectPush            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030+pbl 0.74 pbl pbw],    'visible', 'on', 'tag', 'Row.rectPush',  'callback', 'RowlfFunctions(''Row.rectPush'')', 'string', 'Range', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.profPush0           = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030 0.74-pbw pbl pbw],    'visible', 'on', 'tag', 'Row.profPush0',  'callback', 'RowlfFunctions(''Row.profPush0'')', 'string', 'Profile', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);


Row.subPanel2           = uipanel('parent',   Row.smallPanel, 'Position', [0.010 0.02 0.28 0.46], 'visible', 'on', 'tag',  'Row.smPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k','fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
Row.profText            = uicontrol('parent', Row.smallPanel, 'style', 'text',       'Position', fSize.*pSize.*[0.030 0.25 0.25 0.18],    'visible', 'on', 'tag', 'Row.selectText', 'string', 'Select a Profile:',              'HorizontalAlignment', 'left', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.profPush            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030 0.25 pbl pbw],    'visible', 'on', 'tag', 'Row.profPush',  'callback', 'RowlfFunctions(''Row.profPush'')', 'string', 'Draw', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.enterPush            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030+pbl 0.25 pbl pbw],    'visible', 'on', 'tag', 'Row.enterPush',  'callback', 'RowlfFunctions(''Row.enterPush'')', 'string', 'Enter', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.enterPush            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.030 0.25-pbw pbl pbw],    'visible', 'on', 'tag', 'Row.enterPush',  'callback', 'RowlfFunctions(''Row.enterPush'')', 'string', 'Enter', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.savePush2            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[1-pbl-0.021 0.02 pbl pbw],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.saveOutSmall'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% Row.savePlot2            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[1-pbl-0.021 0.02+pbw pbl pbw],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.savePlotSmall'')', 'string', 'Save Plot', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.savePush2            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.31 0.02 pbl pbw],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.saveOutSmall'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.plotSave2            = uicontrol('parent', Row.smallPanel, 'style', 'pushbutton', 'Position', fSize.*pSize.*[0.31 0.02+pbw pbl pbw],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.savePlotSmall'')', 'string', 'Save Plot', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
% keyboard
% bw                      = 25/fSize(2)/pSize(2);
% bl                      = 80/fSize(1)/pSize(1);
% tl                      = 30/fSize(1)/pSize(1);
% tw                      = 18/fSize(2)/pSize(2);
% el                      = (bl-tl);
% Row.profEditLon1       = uicontrol('parent', Row.smallPanel, 'style', 'edit',       'position', fSize.*pSize.*[0.030   0.15 el bw],  'visible', 'on', 'tag', 'Row.profEditLon1', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% Row.profTextLon1       = uicontrol('parent', Row.smallPanel, 'style', 'text',       'position', fSize.*pSize.*[0.030+el 0.15 tl tw],  'visible', 'on', 'tag', 'Row.profTextLon1', 'string', 'Lon1', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% Row.profEditLon2       = uicontrol('parent', Row.smallPanel, 'style', 'edit',       'position', fSize.*pSize.*[0.030   0.15-bw el bw],  'visible', 'on', 'tag', 'Row.profEditLon2', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% Row.profTextLon2       = uicontrol('parent', Row.smallPanel, 'style', 'text',       'position', fSize.*pSize.*[0.030+el 0.15-bw tl tw],  'visible', 'on', 'tag', 'Row.profTextLon2', 'string', 'Lon2', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% Row.profEditLat1       = uicontrol('parent', Row.smallPanel, 'style', 'edit',       'position', fSize.*pSize.*[0.030+el+tl 0.15 el bw],  'visible', 'on', 'tag', 'Row.profEditLat1', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% Row.profTextLat1       = uicontrol('parent', Row.smallPanel, 'style', 'text',       'position', fSize.*pSize.*[0.030+2*el+tl 0.15 tl tw],  'visible', 'on', 'tag', 'Row.profTextLat1', 'string', 'Lat1', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
% Row.profEditLon2       = uicontrol('parent', Row.smallPanel, 'style', 'edit',       'position', fSize.*pSize.*[0.030+el+tl   0.15-bw el bw],  'visible', 'on', 'tag', 'Row.profEditLon2', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
% Row.profTextLon2       = uicontrol('parent', Row.smallPanel, 'style', 'text',       'position', fSize.*pSize.*[0.030+2*el+tl 0.15-bw tl tw],  'visible', 'on', 'tag', 'Row.profTextLon2', 'string', 'Lat1', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);

% keyboard
P = get(Row.savePush2,'Position');
yb = P(2);
% Map Axis
Row.mapAx               = axes('parent',      hFig, 'units', 'pixels', 'position', fSize.*[0.046 0.251 0.44 0.678], 'visible', 'on', 'Tag', 'Row.mapAx', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);
Row.cAxis               = axes('parent',      hFig, 'units', 'pixels', 'Position', fSize.*[0.046 0.200 0.44 0.018], 'visible', 'off', 'tag', 'Row.cAxis', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'FontName', fn);
Row.ch                  = colorbar('horizontal','Position',[0.046 0.200 0.44 0.018],'FontName',fn,'FontSize',fs,'visible','off','AxisLocation','in');

% Navigation controls
nav                     = uipanel('Position', [0.046 0.02 0.44 0.134], 'visible', 'on', 'tag', 'Row.navPanel', 'BackgroundColor', lightGrey, 'ShadowColor',lightGrey,'HighlightColor',lightGrey,'ForegroundColor','k', 'Title', 'Navigation','FontName',fn,'fontsize',14);
bw                      = 25;
xr                      = 250;
Row.navSW               = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb    bw bw],  'visible', 'on', 'tag', 'Row.navSW',   'callback', 'RowlfFunctions(''Row.navSW'')', 'string', 'SW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navS                = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb    bw bw],  'visible', 'on', 'tag', 'Row.navS',    'callback', 'RowlfFunctions(''Row.navS'')',  'string', 'S', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navSE               = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb    bw bw],  'visible', 'on', 'tag', 'Row.navSE',   'callback', 'RowlfFunctions(''Row.navSE'')', 'string', 'SE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navW                = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+bw   bw bw],  'visible', 'on', 'tag', 'Row.navW',    'callback', 'RowlfFunctions(''Row.navW'')',  'string', 'E', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navE                = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+bw   bw bw],  'visible', 'on', 'tag', 'Row.navE',    'callback', 'RowlfFunctions(''Row.navE'')',  'string', 'W', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navNW               = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr      yb+2*bw bw bw],  'visible', 'on', 'tag', 'Row.navNW',   'callback', 'RowlfFunctions(''Row.navNW'')', 'string', 'NW', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navN                = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+bw   yb+2*bw bw bw],  'visible', 'on', 'tag', 'Row.navN',    'callback', 'RowlfFunctions(''Row.navN'')',  'string', 'N', 'BackgroundColor',  lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navNE               = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [xr+2*bw yb+2*bw bw bw],  'visible', 'on', 'tag', 'Row.navNE',   'callback', 'RowlfFunctions(''Row.navNE'')', 'string', 'NE', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

Row.savePush            = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [360   yb PbLen PbWid],  'visible', 'on', 'tag', 'Row.savePush',  'callback', 'RowlfFunctions(''Row.saveOut'')', 'string', 'Save Output', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);
Row.plotSave            = uicontrol('parent', nav, 'style', 'pushbutton', 'Position', [360 yb+bw PbLen PbWid],  'visible', 'on', 'tag', 'Row.savePlot',  'callback', 'RowlfFunctions(''Row.savePlot'')', 'string', 'Save Plot', 'BackgroundColor', lightGrey, 'FontName', fn, 'FontSize', fs);

% longitude and latitude ranges
bl                      = 80;
tl                      = 30;
tw                      = 18;
el                      = bl-tl;
Row.navEditLonMax       = uicontrol('parent', nav, 'style', 'edit',       'position', [0       yb+2*bw el bw],  'visible', 'on', 'tag', 'Row.navEditLonMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Row.navTextLonMax       = uicontrol('parent', nav, 'style', 'text',       'position', [el      yb+2*bw tl tw],  'visible', 'on', 'tag', 'Row.navTextLonMax', 'string', 'Lon+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Row.navEditLonMin       = uicontrol('parent', nav, 'style', 'edit',       'position', [ 0      yb+bw   el bw],  'visible', 'on', 'tag', 'Row.navEditLonMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Row.navTextLonMin       = uicontrol('parent', nav, 'style', 'text',       'position', [el      yb+bw   tl tw],  'visible', 'on', 'tag', 'Row.navTextLonMin', 'string', 'Lon-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Row.navEditLatMax       = uicontrol('parent', nav, 'style', 'edit',       'position', [bl      yb+2*bw el bw],  'visible', 'on', 'tag', 'Row.navEditLatMax', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Row.navTextLatMax       = uicontrol('parent', nav, 'style', 'text',       'position', [bl+el   yb+2*bw tl tw], 'visible', 'on', 'tag', 'Row.navTextLatMax', 'string', 'Lat+', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Row.navEditLatMin       = uicontrol('parent', nav, 'style', 'edit',       'position', [bl      yb+bw   el bw],  'visible', 'on', 'tag', 'Row.navEditLatMin', 'BackgroundColor', white, 'HorizontalAlignment', 'right', 'FontName', fn, 'FontSize', fs);
Row.navTextLatMin       = uicontrol('parent', nav, 'style', 'text',       'position', [bl+el   yb+bw   tl tw], 'visible', 'on', 'tag', 'Row.navTextLatMin', 'string', 'Lat-', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'left', 'FontName', fn, 'FontSize', fs);
Row.navUpdate           = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [2*bl    yb+2*bw bl bw], 'visible', 'on', 'tag', 'Row.navUpdate', 'callback', 'RowlfFunctions(''Row.navUpdate'')','string', 'Update', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navBack             = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [2*bl    yb+bw   bl bw], 'visible', 'on', 'tag', 'Row.navBack',   'callback', 'RowlfFunctions(''Row.navBack'')','string', 'Back',   'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Zoom options
Row.navZoomIn           = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [0    yb bl bw],    'visible', 'on', 'tag', 'Row.navZoomIn', 'callback', 'RowlfFunctions(''Row.navZoomIn'')','string', 'Zoom In', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navZoomOut          = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [bl   yb bl bw],    'visible', 'on', 'tag', 'Row.navZoomOut', 'callback', 'RowlfFunctions(''Row.navZoomOut'')','string', 'Zoom Out', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
Row.navZoomRange        = uicontrol('parent', nav, 'style', 'pushbutton', 'position', [2*bl yb bl bw],    'visible', 'on', 'tag', 'Row.navZoomRange', 'callback', 'RowlfFunctions(''Row.navZoomRange'')', 'string', 'Zoom Range', 'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);

% Toggle grid size
% [0.516 0.622 .456 .355]
Row.togPanel            = uibuttongroup('Position',  [0.046 0.92 0.44 0.0570], 'visible', 'on', 'tag',  'Row.stPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'Title', 'Grid Size:','fontsize',14,'ShadowColor',lightGrey,'HighlightColor','w');
P                       = get(Row.togPanel,'Position');
pSize2                  = [P(3:4) P(3:4)];
Row.togMed              = uicontrol('parent', Row.togPanel,     'style', 'radiobutton', 'Position', fSize.*pSize2.*[0.41 -0.1 0.3 1],     'visible', 'on', 'tag', 'Row.medButton',   'callback', 'RowlfFunctions(''Row.SwitchGrid'')', 'BackgroundColor', lightGrey, 'string', 'Medium', 'FontName', fn, 'FontSize', fs);
Row.togLarge            = uicontrol('parent', Row.togPanel,     'style', 'radiobutton', 'Position', fSize.*pSize2.*[0.01 -0.1 0.3 1],     'visible', 'on', 'tag', 'Row.largeButton', 'callback', 'RowlfFunctions(''Row.SwitchGrid'')', 'BackgroundColor', lightGrey, 'string', 'Large', 'FontName', fn, 'FontSize', fs);
Row.togSmall            = uicontrol('parent', Row.togPanel,     'style', 'radiobutton', 'Position', fSize.*pSize2.*[0.81 -0.1 0.3 1],     'visible', 'on', 'tag', 'Row.smallButton', 'callback', 'RowlfFunctions(''Row.SwitchGrid'')', 'BackgroundColor', lightGrey, 'string', 'Small', 'FontName', fn, 'FontSize', fs);

% Toggle grid size
Row.OldGrid = Row.togPanel.SelectedObject;
% keyboard



if isdeployed
    set([Row.savePush, Row.savePush2, Row.plotSave, Row.plotSave2],'visible','off');
end 

% Create handles structure for easy use in the callback later
Handles.Row = Row;
set(hFig, 'userdata', Handles);

RowlfFunctions('DrawClean');
set(gca, 'Fontname', fn, 'FontSize', fs)


% Make all figure components normalized so that they auto-resize on figure resize
set(findall(hFig,'-property','Units'),'Units','norm');

% Making the GUI visible and give it a name
set(hFig, 'visible', 'on', 'name', 'Slip Rate GUI','HandleVisibility','on');
set(hFig, 'DoubleBuffer', 'on');



%%% Darlings:

% Row.mapPanel            = uipanel('Position', [0.046 0.291 0.424 0.678], 'visible', 'on', 'tag',  'Row.mapPanel', 'BackgroundColor', lightGrey, 'ForegroundColor','k', 'ShadowColor',lightGrey,'HighlightColor','w');
% pSize                   = [0.424 0.678 0.424 0.678];
% Seg.modSegList          = uicontrol('style','popupmenu',      'position', [ 10 645+20+segmentYOffset 205 20], 'visible','on', 'tag','Seg.modSegList',    'callback','SegmentManagerFunctions(''Seg.modSegList'')', 'string', {''},    'BackgroundColor',lightGrey, 'FontName',fn, 'FontSize',fs, 'Tooltip','List of segment names');
% Row.allPush             = uicontrol('style', 'pushbutton', 'Position', [10 10 60 20], 'visible', 'on', 'tag', 'Row.allPush', 'string', 'Select All',  'BackgroundColor', 'k', 'FontName', fn, 'FontSize', fs);
% Rst.loadPush            = uicontrol('style', 'pushbutton', 'position', [10 fileYOffset+5  60 20],  'visible', 'on', 'tag', 'Rst.loadPush',  'callback', 'ResultManagerFunctions(''Rst.loadPush'')',  'string', 'Load',  'BackgroundColor', lightGrey, 'HorizontalAlignment', 'center', 'FontName', fn, 'FontSize', fs);
% Rst.loadCommandFrame = uicontrol('style', 'frame',      'position', [5 fileYOffset     290 64], 'visible', 'on', 'tag', 'Rst.navFrame', 'BackgroundColor', lightGrey);




% toc
% end