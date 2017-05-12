function [gridIdx] = GetGridSingle_mindist(C, mindist)
%%  Test the line drawing functions
% keyboard
%%  Loop until button is pushed and redraw lines
set(gcf, 'WindowButtonDownFcn', 'ButtonDown');
done                     = 0;
setappdata(gcf, 'doneClick', done);
minDIdxOld               = 0;

while ~done
   done                  = getappdata(gcf, 'doneClick');
   [x, y]                = GetCurrentAxesPosition;
%    fprintf('x = %f, y = %f\n',x,y);
   %%  Find the closest box (midpoint)
   lonMid                = ((C.lon1 + C.lon2 + C.lon3 + C.lon4) / 4) + 360;
   latMid                = (C.lat1 + C.lat2 + C.lat3 + C.lat4) / 4;
   d                     = sqrt((lonMid - x).^2 + (latMid - y).^2);
%    d                     = (lonMid - x).^2 + (latMid - y).^2;
   
   [minDVal, minDIdx]     = min(d);
%    keyboard
   %%  Change color if neccesary
   if minDVal <= mindist;
   if minDIdxOld == 0
%       set(findobj('Patch', strcat('C.', num2str(minDIdx))), 'EdgeColor', 'r');
      gcell = [C.c(C.v(minDIdx,:),1),C.c(C.v(minDIdx,:),2)];
      line([gcell(:,1); gcell(1,1)],[gcell(:,2); gcell(1,2)],'Color','r','LineWidth',2);
   elseif (minDIdxOld ~= minDIdx) && (minDIdxOld ~= 0)
%       set(findobj('Patch', strcat('C.', num2str(minDIdxOld))), 'EdgeColor', 'k');
%       set(findobj('Patch', strcat('C.', num2str(minDIdx))), 'EdgeColor', 'r');
%       gcell = [C.c(C.v(minDIdxOld,:),1),C.c(C.v(minDIdxOld,:),2)];
%       line([gcell(:,1); gcell(1,1)],[gcell(:,2); gcell(1,2)],'Color',0.8*[1 1 1]);
      L = findobj(gca,'Type','line','Color','r');
      delete(L);
      gcell = [C.c(C.v(minDIdx,:),1),C.c(C.v(minDIdx,:),2)];
      line([gcell(:,1); gcell(1,1)],[gcell(:,2); gcell(1,2)],'Color','r','LineWidth',2);
%       keyboard
   end
%    set(findobj(gcf, 'Tag', 'Seg.modSegList'), 'Value', minDIdx + 2);
   minDIdxOld            = minDIdx;
   drawnow;
   else
      L = findobj(gca,'Type','line','Color','r');
      delete(L);
      drawnow
   end
end
set(gcf, 'WindowButtonDownFcn', '');
gridIdx                   = minDIdx;
% fprintf('x = %f, y = %f\n',x,y);
% keyboard

function [x, y] = GetCurrentAxesPosition
%%  GetCurrentAxesPosition
%%  Returns pointer position on current axes in units of pixels
%%  Authors: David Liebowitz, Seeing Machines
%%           Tom Herring, MIT
% gca = axes1;
set(gcf,'Units','pixels')
set(gca,'Units','pixels')

%%  Get dimension information
scnsize             = get(0, 'ScreenSize');
figsize             = get(gcf, 'Position');
axesize             = get(gca, 'Position');  % Could get CurrentAxes from gcf
llsize              = [get(gca, 'Xlim') get(gca, 'Ylim')];
asprat              = get(gca, 'DataAspectRatio');
% asprat2             = asprat(1)/asprat(2);           
% keyboard
%%  Based on the aspect ratio, find the actual coordinates coordinates covered by the axesize.
% ratio               = (llsize(2) - llsize(1)) * asprat(2) / (llsize(4) - llsize(3));
ratio               = ((llsize(2) - llsize(1)) * asprat(2)) / ((llsize(4) - llsize(3)) * asprat(1));
% ratio               = (llsize(2) - llsize(1)) * asprat2 / (llsize(4) - llsize(3));
if ratio > 1,   % Longitude covers the full pixel range
    xoff            = figsize(1) + axesize(1);
    xscl            = (llsize(2) - llsize(1)) / axesize(3); 
    %%  For Latitude, compute height of axes
    dyht            = (axesize(4) - axesize(4) / ratio) / 2;
    yoff            = figsize(2) + axesize(2) + dyht;
    yscl            = (llsize(4) - llsize(3)) / (axesize(4) / ratio);
else
    dxwd            = (axesize(3) - axesize(3) * ratio) / 2;
    xoff            = figsize(1) + axesize(1) + dxwd;
    xscl            = (llsize(2) - llsize(1)) / (axesize(3) * ratio); 
    yoff            = figsize(2) + axesize(2);
    yscl            = (llsize(4) - llsize(3)) / axesize(4);
end
xin                 = llsize(1);
yin                 = llsize(3);

% Construct the mapping array
pix2ll              = [xoff xscl xin ; yoff yscl yin];

%%  Get the pointer's screen position
pix                 = get(0, 'PointerLocation');
x                   = (pix(1) - pix2ll(1, 1)) * pix2ll(1, 2) + pix2ll(1, 3);
y                   = (pix(2) - pix2ll(2, 1)) * pix2ll(2, 2) + pix2ll(2, 3);



function ButtonDown
%%  Set an application data variable to indicate that a button has been clicked
setappdata(gcf, 'doneClick', 1); 