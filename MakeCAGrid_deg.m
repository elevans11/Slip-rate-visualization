%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    10/10/2014 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Make Grid of California to compile slip estimates. 
%                ( 10/10/2014 , 15:41:40 pm ) 
% 
%   INPUT 
%       1. nEW: number of grid cells east-west 
%       2. nNS: number of grid cells north-south
% 
%   OUTPUT 
%       1. C: structure containing vertices of each cell
%               C.c: cell vertex coordinates
%               C.v: cell vertex indices
%               C.lon1, C.lon2, C.lon3, C.lon4
%               C.lat1, C.lat2, C.lat3, C.lat4
% 
%   Outline 
%       1.  
%       2.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% close all; clear all; clc;
function C = MakeCAGrid_deg(deg) % make grid cells based on grid size (in LATITUDE degrees -- longitude degrees are scaled 0.82 to be approx. equal area)
% nEW = 45;
% nNS = 54;

% km = 50;
xdeg = deg;
ydeg = deg*0.82;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Get California Geometery
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%% Initialize range to find CA (just has to be bigger than state border)
range = [233 248 32 43];
states = shaperead('usastatehi', 'UseGeoCoords', true, 'BoundingBox', [range(1:2)'-360, range(3:4)']); % plot statelines

%%% find California
for j = 1:numel(states);
    if strcmp(states(j).Name,'California')
        CA = states(j);
    end
end

%%% Initialize plotting for debugging
% fs                           = 20;
% sw                           = 2;
% ms                           = 3;
% cbarystart                   = 0.17;
% whl                          = 8; % whisker head length for barbs (Brad's idea)
% mp                           = 'm_proj(''mercator'', ''long'', range(1:2) ,''lat'', range(3:4));';
% mg                           = 'm_grid(''linestyle'', ''none'', ''tickdir'', ''out'', ''yaxislocation'', ''right'', ''xaxislocation'', ''bottom'', ''xlabeldir'', ''end'',''ticklen'', 0.01, ''FontSize'', fs);';
% figure; eval(mp); eval(mg);
% hold on
% load WorldHiVectors; m_patch(lon-360, lat, 0.7*[1 1 1], 'EdgeColor', 'none'); % plot coastlines and country boundaries
% for j = 1:numel(states); m_line(states(j).Lon+360, states(j).Lat, 'color', 1*[1 1 1], 'linewidth', 0.5); end;
% % plot CA alone
% m_line(CA.Lon+360, CA.Lat, 'color', 1*[1 0 0], 'linewidth', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Switch to UTM so that we can make a rectilinear grid. There may be a
%%% better way to do this in spherical coordinates, but we'll start with
%%% this
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
ix = find(isnan(CA.Lon), 1, 'first');
calat = CA.Lat(1:ix);
calon = CA.Lon(1:ix);

% pl                          = [mean(calat) mean(calon)];
zone                        = '11S';
[ellipsoid,estr]            = utmgeoid(zone);
utmstruct                   = defaultm('utm'); 
utmstruct.zone              = zone; 
utmstruct.geoid             = ellipsoid; 
utmstruct.flatlimit         = []; 
utmstruct.maplatlimit       = []; 
utmstruct                   = defaultm(utmstruct);
[cax, cay]                   = mfwdtran(utmstruct,calat,calon);
% keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  get nEW and nNS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% nEW = ceil((max(cax) - min(cax))/(km*1e3));
% nNS = ceil((max(cay) - min(cay))/(km*1e3));
% minEW = max(cax) - (nEW)*(km*1e3);
% maxNS = min(cay) + (nNS)*(km*1e3);

nEW = ceil((max(calon) - min(calon))/(xdeg));
nNS = ceil((max(calat) - min(calat))/(ydeg));
minEW = max(calon) - (nEW)*(xdeg);
maxNS = min(calat) + (nNS)*(ydeg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Make Grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%% make vertices
% xG = linspace(min(cax),max(cax),nEW+1);
% yG = linspace(min(cay),max(cay),nNS+1);

xG = minEW:xdeg:max(calon);
yG = min(calat):ydeg:maxNS;


[XG, YG] = meshgrid(xG,yG);
XG = XG(:);
YG = YG(:);
% hold on; plot(XG,YG,'.');
% [LatG, LonG] = minvtran(utmstruct,XG,YG);
% 
LatG = YG;
LonG = XG;

[xinv, yinv] = minvtran(utmstruct,LatG,LonG);

C.c = [LonG,LatG];

%%% somehow figure out rectanges
v = zeros(nEW*nNS,4);

for nn = 1:nEW*nNS; % for each rectangle
    row = mod(nn-1,nNS) + 1;
    col = ceil(nn/nNS);
    
    
    I1 = (row) + (col-1)*(nNS+1);
    I2 = I1 + 1;
    I3 = I2 + nNS + 1;
    I4 = I1 + nNS + 1;

    v(nn,:) = [I1 I2 I3 I4];
    
%     hold on; plot([C.c(I1,1),C.c(I2,1),C.c(I3,1),C.c(I4,1),C.c(I1,1)],[C.c(I1,2),C.c(I2,2),C.c(I3,2),C.c(I4,2),C.c(I1,2)],'-r')
%     keyboard
end

C.v = v;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Remove gridcells outside of CA while retaining islands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
NEmost = 21;
Emost = 94;

ThisPoly = [[calon(NEmost:Emost)'; calon(Emost) + 10; calon(NEmost)] , [calat(NEmost:Emost)'; calat(NEmost)+10; calat(NEmost)+10]];
% TPlon = [calon(NEmost:Emost)'; calon(NEmost); calon(NEmost)]
IN = inpolygon(C.c(:,1),C.c(:,2),ThisPoly(:,1),ThisPoly(:,2));
nix = zeros(numel(C.v(:,1)),1);
for ii = 1:numel(C.v(:,1));
    if sum(IN(C.v(ii,:))) == 4;
        nix(ii) = 1;
    end
end
% keyboard
C.v(logical(nix),:) = [];
v(logical(nix),:) = [];
% hold on; plot(ThisPoly(:,1),ThisPoly(:,2),'-r');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%  Remove gridcells in Nevada
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% for j = 1:numel(states);
%     if strcmp(states(j).Name,'Nevada')
%         NV = states(j);
%     end
% end
% NVlon = NV.Lon(~isnan(NV.Lon));
% NVlat = NV.Lat(~isnan(NV.Lat));
% 
% IN = inpolygon(C.c(:,1),C.c(:,2),NVlon,NVlat);
% nix = zeros(numel(C.v(:,1)),1);
% for ii = 1:numel(C.v(:,1));
%     if sum(IN(C.v(ii,:))) == 4;
%         nix(ii) = 1;
%     end
% end
% % keyboard
% C.v(logical(nix),:) = [];
% v(logical(nix),:) = [];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%  Remove gridcells in Utah
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% for j = 1:numel(states);
%     if strcmp(states(j).Name,'Utah')
%         UT = states(j);
%     end
% end
% UTlon = UT.Lon(~isnan(UT.Lon));
% UTlat = UT.Lat(~isnan(UT.Lat));
% 
% IN = inpolygon(C.c(:,1),C.c(:,2),UTlon,UTlat);
% % nix = ~IN;
% nix = zeros(numel(C.v(:,1)),1);
% for ii = 1:numel(C.v(:,1));
%     if sum(IN(C.v(ii,:))) >= 1;
%         nix(ii) = 1;
%     end
% end
% keyboard
% C.v(logical(nix),:) = [];
% v(logical(nix),:) = [];
% keyboard
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%  Remove gridcells in Arizona
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% for j = 1:numel(states);
%     if strcmp(states(j).Name,'Arizona')
%         AZ = states(j);
%     end
% end
% AZlon = AZ.Lon(~isnan(AZ.Lon));
% AZlat = AZ.Lat(~isnan(AZ.Lat));
% 
% IN = inpolygon(C.c(:,1),C.c(:,2),AZlon,AZlat);
% % nix = ~IN;
% nix = zeros(numel(C.v(:,1)),1);
% for ii = 1:numel(C.v(:,1));
%     if sum(IN(C.v(ii,:))) == 4;
%         nix(ii) = 1;
%     end
% end
% % keyboard
% C.v(logical(nix),:) = [];
% v(logical(nix),:) = [];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%  Remove gridcells in Oregon
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% for j = 1:numel(states);
%     if strcmp(states(j).Name,'Oregon')
%         OR = states(j);
%     end
% end
% ORlon = OR.Lon(~isnan(OR.Lon));
% ORlat = OR.Lat(~isnan(OR.Lat));
% 
% IN = inpolygon(C.c(:,1),C.c(:,2),ORlon,ORlat);
% % nix = ~IN;
% nix = zeros(numel(C.v(:,1)),1);
% for ii = 1:numel(C.v(:,1));
%     if sum(IN(C.v(ii,:))) == 4;
%         nix(ii) = 1;
%     end
% end
% % keyboard
% C.v(logical(nix),:) = [];
% v(logical(nix),:) = [];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%  Remove gridcells in Idaho
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
% for j = 1:numel(states);
%     if strcmp(states(j).Name,'Idaho')
%         ID = states(j);
%     end
% end
% IDlon = ID.Lon(~isnan(ID.Lon));
% IDlat = ID.Lat(~isnan(ID.Lat));
% 
% IN = inpolygon(C.c(:,1),C.c(:,2),IDlon,IDlat);
% % nix = ~IN;
% nix = zeros(numel(C.v(:,1)),1);
% for ii = 1:numel(C.v(:,1));
%     if sum(IN(C.v(ii,:))) >= 1;
%         nix(ii) = 1;
%     end
% end
% % keyboard
% C.v(logical(nix),:) = [];
% v(logical(nix),:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Finalize structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

C.lon1 = C.c(v(:,1),1);
C.lon2 = C.c(v(:,2),1);
C.lon3 = C.c(v(:,3),1);
C.lon4 = C.c(v(:,4),1);

C.lat1 = C.c(v(:,1),2);
C.lat2 = C.c(v(:,2),2);
C.lat3 = C.c(v(:,3),2);
C.lat4 = C.c(v(:,4),2);

% [C.x1, C.y1] = mfwdtran(utmstruct,C.lat1,C.lon1);
% [C.x2, C.y2] = mfwdtran(utmstruct,C.lat2,C.lon2);
% [C.x3, C.y3] = mfwdtran(utmstruct,C.lat3,C.lon3);
% [C.x4, C.y4] = mfwdtran(utmstruct,C.lat4,C.lon4);
 
% meshview(C.c,C.v);
% hold on;
% plot(calon,calat,'.-','LineWidth',2); axis equal; axis tight;
% hold on; plot(ThisPoly(:,1),ThisPoly(:,2),'-r');
% keyboard
end