%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    6/3/2015 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 6/3/2015 , 15:39:03 pm ) 
% 
%   INPUT 
%       1. Input one here 
%       2. Input two here 
% 
%   OUTPUT 
%       1. Output one here 
% 
%   Outline 
%       1.  
%       2.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% function out=ReadUCERFgeo(input) 
close all; clear all; clc;
zone                            = '11S';
[ellipsoid,estr]                = utmgeoid(zone);
utmstruct                       = defaultm('utm'); 
utmstruct.zone                  = zone; 
utmstruct.geoid                 = ellipsoid; 
utmstruct.flatlimit             = []; 
utmstruct.maplatlimit           = []; 
utmstruct                       = defaultm(utmstruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Read UCERF fault geometry file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
filename                        = 'Coords3.2.txt';
% filestream                      = 1;
infile                          = fopen(filename, 'r');
% format: FID minisection Name ELon1 NLat1 ELon2 NLat2 CREEPS? ABM-slip-rate ABM-rake NeoKinema-slip-rate NeoKinema-rake NeoKinema-dip Zeng-slip-rate Zeng-rake Geologic-rate(mm/yr) Geologic-lower-bound(mm/yr) Geologic-upper-bound(mm/yr) Geo-rake Geo-dip Geo-dip-dir	
 
C = textscan(infile, '%d %f %s %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter', '\t','headerLines',2);
fclose(infile);

figure; hold on;
for ii = 1:numel(C{4});
    plot([C{4}(ii) C{6}(ii)],[C{5}(ii) C{7}(ii)],'-k')
end
% keyboard

snames_1                                = char(C{3});
faultid_1                               = C{1};
seg_data_1                              = C{2};
% seg_lon_1                               = C{4};
% seg_lat_1                               = C{6};
bDeps_1                                 = zeros(size(faultid_1));
lDeps_1                                 = 15*ones(size(faultid_1));
% numsegments_1                           = [];
% collect_1                               = [];
lon1_1                                  = C{4}+360;
lon2_1                                  = C{6}+360;
lat1_1                                  = C{5};
lat2_1                                  = C{7};
segdip_1                                = C{13};

%%% dip  = 90 and rake = 180: purely right lateral
%%% dip  = 90 and rake = 0: purely left lateral

ABMrate                                 = C{9};
ABMrake                                 = C{10};

NKrate                                  = C{11};
NKrake                                  = C{12};
NKdip                                   = C{13};

ZErate                                  = C{14};
ZErake                                  = C{15};

Geodip                                  = C{20};

ABMssRate = zeros(numel(lon1_1));
ABMdsRate = zeros(numel(lon1_1));
ABMtsRate = zeros(numel(lon1_1));

ZEssRate = zeros(numel(lon1_1));
ZEdsRate = zeros(numel(lon1_1));
ABMtsRate = zeros(numel(lon1_1));

NKssRate = zeros(numel(lon1_1));
NKdsRate = zeros(numel(lon1_1));
NKtsRate = zeros(numel(lon1_1));

for ii = 1:numel(lon1_1);
    rake = ABMrake(ii)*pi/180;
    ABMssRate(ii) = ABMrate(ii)*cos(rake);
    ABMdsRate(ii) = ABMrate(ii)*sin(rake);
    ABMtsRate(ii) = 0;
    
    ZEssRate(ii) = ZErate(ii)*cos(rake);
    ZEdsRate(ii) = ZErate(ii)*sin(rake);
    ABMtsRate(ii) = 0;
    
    rake = NKrake(ii)*pi/180;
    NKssRate(ii) = NKrate(ii)*cos(rake);
    NKdsRate(ii) = NKrate(ii)*sin(rake);
    NKtsRate(ii) = 0;
    
    
    
end

% ZEdip                                   = C{16};


% snames_2                                = [];
% faultid_2                               = [];
% seg_data_2                              = [];
% seg_lon_2                               = [];
% seg_lat_2                               = [];
% bDeps_2                                 = [];
% lDeps_2                                 = [];
% numsegments_2                           = [];
% collect_2                               = [];
% lon1_2                                  = [];
% lon2_2                                  = [];
% lat1_2                                  = [];
% lat2_2                                  = [];
% segdip_2                                = [];
% 
% 
% for ii = 1:numel(C{1});
%     thisline                    = char(C{1}(ii,:));
%     formatSpec                  = '%s\t%d\t%s\t%s\t%f\t%f\t%f\t%f\n';
%     [T, pos]                    = textscan(thisline,formatSpec);
%     locs                        = thisline(pos+1:end);
%     LL                          = str2num(locs);
%     
%     if strcmp(T{3},'TRUE');
%         lats                        = LL(1:2:end);
%         lons                        = LL(2:2:end);
% %         [xs, ys]                    = mfwdtran(utmstruct,lats,lons);
%         nsegs                       = numel(lats)-1;
%         snames_1                      = [snames_1; repmat(T{1},nsegs,1)];
%         faultid_1                     = [faultid_1; repmat(T{2},nsegs,1)];
%         %     seg_lon                     = [seg_lon; lons];
%         %     seg_lat                     = [seg_lat; lats];
%         bDeps_1                       = [bDeps_1; repmat(T{6},nsegs,1)];
%         lDeps_1                       = [lDeps_1; repmat(T{7},nsegs,1)];
%         lon1_1                        = [lon1_1; lons(1:end-1)'];
%         lon2_1                        = [lon2_1; lons(2:end)'];
%         lat1_1                        = [lat1_1; lats(1:end-1)'];
%         lat2_1                        = [lat2_1; lats(2:end)'];
%         segdip_1                      = [segdip_1; repmat(T{5},nsegs,1)];
%     end
%     
%     if strcmp(T{4},'TRUE');
%         lats                        = LL(1:2:end);
%         lons                        = LL(2:2:end);
% %         [xs, ys]                    = mfwdtran(utmstruct,lats,lons);
%         nsegs                       = numel(lats)-1;
%         snames_2                      = [snames_2; repmat(T{1},nsegs,1)];
%         faultid_2                     = [faultid_2; repmat(T{2},nsegs,1)];
%         %     seg_lon                     = [seg_lon; lons];
%         %     seg_lat                     = [seg_lat; lats];
%         bDeps_2                       = [bDeps_2; repmat(T{6},nsegs,1)];
%         lDeps_2                     = [lDeps_2; repmat(T{7},nsegs,1)];
%         lon1_2                        = [lon1_2; lons(1:end-1)'];
%         lon2_2                        = [lon2_2; lons(2:end)'];
%         lat1_2                        = [lat1_2; lats(1:end-1)'];
%         lat2_2                        = [lat2_2; lats(2:end)'];
%         segdip_2                      = [segdip_2; repmat(T{5},nsegs,1)];
%     end
% end
% % trash                                   = fgetl(infile);
% fclose(infile);
% 
S.name                             = snames_1;
S.lon1                             = lon2_1;
S.lat1                             = lat2_1;
S.lon2                             = lon1_1;
S.lat2                             = lat1_1;
S.lDep                             = lDeps_1;
S.lDepSig                          = zeros(size(lDeps_1));
S.lDepTog                          = zeros(size(lDeps_1));
S.dip                              = segdip_1;
S.dipSig                           = zeros(size(segdip_1));
S.dipTog                           = zeros(size(segdip_1));
S.ssRate                           = ABMssRate;
S.ssRateSig                        = ones(size(S.lon1));
S.ssRateTog                        = zeros(size(S.lon1));
S.dsRate                           = ABMdsRate;
S.dsRateSig                        = ones(size(S.lon1));
S.dsRateTog                        = zeros(size(S.lon1));
S.tsRate                           = ABMtsRate;
S.tsRateSig                        = ones(size(S.lon1));
S.tsRateTog                        = zeros(size(S.lon1));
S.bDep                             = bDeps_1;
S.bDepSig                          = zeros(size(segdip_1));
S.bDepTog                          = zeros(size(segdip_1));
S.res                              = zeros(size(segdip_1));
S.resOver                          = zeros(size(segdip_1));
S.resOther                         = zeros(size(segdip_1));
S.other1                           = zeros(size(segdip_1));
S.other2                           = zeros(size(segdip_1));
S.other3                           = zeros(size(segdip_1));
S.other4                           = zeros(size(segdip_1));
S.other5                           = zeros(size(segdip_1));
S.other6                           = zeros(size(segdip_1));
S.other7                           = zeros(size(segdip_1));
S.other8                           = zeros(size(segdip_1));
S.other9                           = zeros(size(segdip_1));
S.other10                          = zeros(size(segdip_1));
S.other11                          = zeros(size(segdip_1));
S.other12                          = zeros(size(segdip_1));

ABM = S;
ZE = S;
ZE.ssRate                           = ZEssRate;
ZE.dsRate                           = ZEdsRate;
NK = S;
NK.ssRate                           = NKssRate;
NK.dsRate                           = NKdsRate;

% keyboard
ABM = OrderEndpoints(ABM);

ZE = OrderEndpoints(ABM);
NK = OrderEndpoints(ABM);


WriteSegmentStruct('UCERF3.2_ABM.segment',ABM);
WriteSegmentStruct('UCERF3.2_ZE.segment',ABM);
WriteSegmentStruct('UCERF3.2_NK.segment',ABM);
