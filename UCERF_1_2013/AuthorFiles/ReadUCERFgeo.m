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
filename                        = 'UCERF_faults.txt';
filestream                      = 1;
infile                          = fopen(filename, 'r');
C                               = textscan(infile, '%s','delimiter', '\n','headerLines',1);

snames_1                                = [];
faultid_1                               = [];
seg_data_1                              = [];
seg_lon_1                               = [];
seg_lat_1                               = [];
bDeps_1                                 = [];
lDeps_1                                 = [];
numsegments_1                           = [];
collect_1                               = [];
lon1_1                                  = [];
lon2_1                                  = [];
lat1_1                                  = [];
lat2_1                                  = [];
segdip_1                                = [];

snames_2                                = [];
faultid_2                               = [];
seg_data_2                              = [];
seg_lon_2                               = [];
seg_lat_2                               = [];
bDeps_2                                 = [];
lDeps_2                                 = [];
numsegments_2                           = [];
collect_2                               = [];
lon1_2                                  = [];
lon2_2                                  = [];
lat1_2                                  = [];
lat2_2                                  = [];
segdip_2                                = [];


for ii = 1:numel(C{1});
    thisline                    = char(C{1}(ii,:));
    formatSpec                  = '%s\t%d\t%s\t%s\t%f\t%f\t%f\t%f\n';
    [T, pos]                    = textscan(thisline,formatSpec);
    locs                        = thisline(pos+1:end);
    LL                          = str2num(locs);
    
    if strcmp(T{3},'TRUE');
        lats                        = LL(1:2:end);
        lons                        = LL(2:2:end);
%         [xs, ys]                    = mfwdtran(utmstruct,lats,lons);
        nsegs                       = numel(lats)-1;
        snames_1                      = [snames_1; repmat(T{1},nsegs,1)];
        faultid_1                     = [faultid_1; repmat(T{2},nsegs,1)];
        %     seg_lon                     = [seg_lon; lons];
        %     seg_lat                     = [seg_lat; lats];
        bDeps_1                       = [bDeps_1; repmat(T{6},nsegs,1)];
        lDeps_1                       = [lDeps_1; repmat(T{7},nsegs,1)];
        lon1_1                        = [lon1_1; lons(1:end-1)'];
        lon2_1                        = [lon2_1; lons(2:end)'];
        lat1_1                        = [lat1_1; lats(1:end-1)'];
        lat2_1                        = [lat2_1; lats(2:end)'];
        segdip_1                      = [segdip_1; repmat(T{5},nsegs,1)];
    end
    
    if strcmp(T{4},'TRUE');
        lats                        = LL(1:2:end);
        lons                        = LL(2:2:end);
%         [xs, ys]                    = mfwdtran(utmstruct,lats,lons);
        nsegs                       = numel(lats)-1;
        snames_2                      = [snames_2; repmat(T{1},nsegs,1)];
        faultid_2                     = [faultid_2; repmat(T{2},nsegs,1)];
        %     seg_lon                     = [seg_lon; lons];
        %     seg_lat                     = [seg_lat; lats];
        bDeps_2                       = [bDeps_2; repmat(T{6},nsegs,1)];
        lDeps_2                     = [lDeps_2; repmat(T{7},nsegs,1)];
        lon1_2                        = [lon1_2; lons(1:end-1)'];
        lon2_2                        = [lon2_2; lons(2:end)'];
        lat1_2                        = [lat1_2; lats(1:end-1)'];
        lat2_2                        = [lat2_2; lats(2:end)'];
        segdip_2                      = [segdip_2; repmat(T{5},nsegs,1)];
    end
end
% trash                                   = fgetl(infile);
fclose(infile);

S1.lon1                             = lon1_1;
S1.lat1                             = lat1_1;
S1.lon2                             = lon2_1;
S1.lat2                             = lat2_1;
S1.lDep                             = lDeps_1;
S1.lDepSig                          = zeros(size(lDeps_1));
S1.lDepTog                          = zeros(size(lDeps_1));
S1.dip                              = segdip_1;
S1.dipSig                           = zeros(size(segdip_1));
S1.dipTog                           = zeros(size(segdip_1));
S1.ssRate                           = zeros(size(S1.lon1));
S1.ssRateSig                        = zeros(size(S1.lon1));
S1.ssRateTog                        = zeros(size(S1.lon1));
S1.dsRate                           = zeros(size(S1.lon1));
S1.dsRateSig                        = zeros(size(S1.lon1));
S1.dsRateTog                        = zeros(size(S1.lon1));
S1.tsRate                           = zeros(size(S1.lon1));
S1.tsRateSig                        = zeros(size(S1.lon1));
S1.tsRateTog                        = zeros(size(S1.lon1));
S1.bDep                             = bDeps_1;
S1.bDepSig                          = zeros(size(segdip_1));
S1.bDepTog                          = zeros(size(segdip_1));
S1.res                              = zeros(size(segdip_1));
S1.resOver                          = zeros(size(segdip_1));
S1.resOther                         = zeros(size(segdip_1));
S1.other1                           = zeros(size(segdip_1));
S1.other2                           = zeros(size(segdip_1));
S1.other3                           = zeros(size(segdip_1));
S1.other4                           = zeros(size(segdip_1));
S1.other5                           = zeros(size(segdip_1));
S1.other6                           = zeros(size(segdip_1));
S1.other7                           = zeros(size(segdip_1));
S1.other8                           = zeros(size(segdip_1));
S1.other9                           = zeros(size(segdip_1));
S1.other10                          = zeros(size(segdip_1));
S1.other11                          = zeros(size(segdip_1));
S1.other12                          = zeros(size(segdip_1));

S2.lon1                             = lon1_2;
S2.lat1                             = lat1_2;
S2.lon2                             = lon2_2;
S2.lat2                             = lat2_2;
S2.lDep                             = lDeps_2;
S2.lDepSig                          = zeros(size(lDeps_2));
S2.lDepTog                          = zeros(size(lDeps_2));
S2.dip                              = segdip_2;
S2.dipSig                           = zeros(size(segdip_2));
S2.dipTog                           = zeros(size(segdip_2));
S2.ssRate                           = zeros(size(S2.lon1));
S2.ssRateSig                        = zeros(size(S2.lon1));
S2.ssRateTog                        = zeros(size(S2.lon1));
S2.dsRate                           = zeros(size(S2.lon1));
S2.dsRateSig                        = zeros(size(S2.lon1));
S2.dsRateTog                        = zeros(size(S2.lon1));
S2.tsRate                           = zeros(size(S2.lon1));
S2.tsRateSig                        = zeros(size(S2.lon1));
S2.tsRateTog                        = zeros(size(S2.lon1));
S2.bDep                             = bDeps_2;
S2.bDepSig                          = zeros(size(segdip_2));
S2.bDepTog                          = zeros(size(segdip_2));
S2.res                              = zeros(size(segdip_2));
S2.resOver                          = zeros(size(segdip_2));
S2.resOther                         = zeros(size(segdip_2));
S2.other1                           = zeros(size(segdip_2));
S2.other2                           = zeros(size(segdip_2));
S2.other3                           = zeros(size(segdip_2));
S2.other4                           = zeros(size(segdip_2));
S2.other5                           = zeros(size(segdip_2));
S2.other6                           = zeros(size(segdip_2));
S2.other7                           = zeros(size(segdip_2));
S2.other8                           = zeros(size(segdip_2));
S2.other9                           = zeros(size(segdip_2));
S2.other10                          = zeros(size(segdip_2));
S2.other11                          = zeros(size(segdip_2));
S2.other12                          = zeros(size(segdip_2));

figure; 
for ii = 1:numel(S1.lon1); 
    hold on; plot([S1.lon1(ii) S1.lon2(ii)],[S1.lat1(ii) S1.lat2(ii)],'.-k'); 
end
for ii = 1:numel(S2.lon1); 
    hold on; plot([S2.lon1(ii) S2.lon2(ii)],[S2.lat1(ii) S2.lat2(ii)],'o-r'); 
end

keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Load Slip Rate Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
S1_Zeng                         = S1;
S1_NeoKinema                    = S1;
S1_ABM                          = S1;

S2_Zeng                         = S2;
S2_NeoKinema                    = S2;
S2_ABM                          = S2;

slipfilename                    = 'OrigSlipRatesEtc.txt';
filestream                      = 1;
slipinfile                      = fopen(slipfilename, 'r');
R                               = textscan(slipinfile, '%s','delimiter', '\n','headerLines',2);



for ii = 1:numel(R{1});
    thisline                    = char(R{1}(ii,:));
    formatSpec                  = '%*s \t %d \t %*f \t %*f \t %f \t %f \t %*f \t %f \t %f \t %f \t %*f \t %f %*[^\n]';
    [T, pos]                    = textscan(thisline,formatSpec);
    
    % But actually, how to find fault orientations and slip rakes?
    S1_Zeng.ssRate(faultid_1 == T{1})       = T{2};
    S1_NeoKinema.ssRate(faultid_1 == T{1})  = T{3};
    S1_ABM.ssRate(faultid_1 == T{1})        = T{4};
    
    S2_Zeng.ssRate(faultid_2 == T{1})       = T{5};
    S2_NeoKinema.ssRate(faultid_2 == T{1})  = T{6};
    S2_ABM.ssRate(faultid_2 == T{1})        = T{7};

end
fclose(slipinfile);


fclose(infile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 




% end