%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    1/21/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 1/21/2016 , 10:07:32 am ) 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Read slip rate file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

filename    = 'GeologicRates_ELE.txt';
infile      = fopen(filename, 'r');
T           = textscan(infile,'%s \t %d \t %s \t %f \t %f \t %s \t %f \t %f \t %f \t %f \t %s \t %f \t %f \t %s','headerlines',4,'delimiter','\t');
fclose(infile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Organize file output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

names       = char(T{1});
FID         = T{2};
Style       = char(T{3});
Dip         = T{4};
Rake        = T{5}; % Rake = 180: Right Lateral; Rake = 0: Left Lateral; Rake  = 90: Reverse; Rake = 270: Normal
SiteName    = char(T{6});
Lon         = T{7};
Lat         = T{8};
Strike      = T{9};
Rate        = T{10}*1e-3; % slip rate m/yr 
Component   = char(T{11});
Max         = T{12}*1e-3;
Min         = T{13}*1e-3;
Citation    = char(T{14});

in = isnan(Min);
Min(in) = Rate(in) - Rate(in)/2; % keep uncertainty range constant, rather than rotating it
Max(in) = Rate(in) + Rate(in)/2; % keep uncertainty range constant, rather than rotating it

mindiff = Rate - Min;
maxdiff = Max - Rate;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Translate to east-north, etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

eastslip = zeros(numel(Lon),1);
northslip = zeros(numel(Lon),1);
eastmax = zeros(numel(Lon),1);
northmax = zeros(numel(Lon),1);
eastmin = zeros(numel(Lon),1);
northmin = zeros(numel(Lon),1);

strikeslip0                 = Rate .* cos(Rake .* pi/180);
dipslip0                    = Rate .* sin(Rake .* pi/180);
tensileslip0                = dipslip0 .* cos(Dip .* pi/180);

% in = isnan(Min);
% strikeslipMin(in)           = strikeslip0(in) - strikeslip0(in)/2;
% strikeslipMax(in)           = strikeslip0(in) + strikeslip0(in)/2;
% tensileslipMin(in)          = tensileslip0(in) - tensileslip0(in)/2;
% tensileslipMax(in)          = tensileslip0(in) + tensileslip0(in)/2;
% 
% strikeslipMax               = Max .* cos(Rake .* pi/180);
% strikeslipMin               = Min .* cos(Rake .* pi/180);
% dipslipMax                  = Max .* sin(Rake .* pi/180);
% dipslipMin                  = Min .* sin(Rake .* pi/180);
% 
% tensileslipMax              = dipslipMax .* cos(Dip .* pi/180);
% tensileslipMin              = dipslipMin .* cos(Dip .* pi/180);


for ii = 1:numel(Lon);
    
    thisstrike              = Strike(ii)*pi/180;
    
    rotmat                  = [cos(thisstrike) -sin(thisstrike);...
                               sin(thisstrike)  cos(thisstrike)];
    torotate                = [strikeslip0(ii); tensileslip0(ii)];
    xy                      = rotmat*torotate;
    
    northslip(ii)           = xy(1);
    eastslip(ii)            = xy(2);
%     
%     torotateMax             = [strikeslipMax(ii); tensileslipMax(ii)];
%     xyMax                   = rotmat*torotateMax;
%     
%     torotateMin             = [strikeslipMin(ii); tensileslipMin(ii)];
%     xyMin                   = rotmat*torotateMin;
%     
%     northmax(ii)            = xyMax(1);
%     eastmax(ii)             = xyMax(2);
%     
%     northmin(ii)            = xyMin(1);
%     eastmin(ii)             = xyMin(2);
end




% northrange = [northmin northmax];
% northrange = sort(northrange,2);
% eastrange = [eastmin eastmax];
% eastrange = sort(eastrange,2);
% 
% ssrange = [strikeslipMin strikeslipMax];
% ssrange = sort(ssrange,2);
% tsrange = [tensileslipMin tensileslipMax];
% tsrange = sort(tsrange,2);

ssmin = strikeslip0 - mindiff;
ssmax = strikeslip0 + maxdiff;
tsmin = tensileslip0 - mindiff;
tsmax = tensileslip0 + maxdiff;

eastmin = eastslip - mindiff;
eastmax = eastslip + maxdiff;
northmin = northslip - mindiff;
northmax = northslip + maxdiff;


outfilename = 'Geology.txt';
outfile      = fopen(outfilename, 'w');
for row = 1:numel(Lon);
    fprintf(outfile, '%s \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n', names(row,:), Lon(row), Lat(row), Strike(row), strikeslip0(row), ssmin(row), ssmax(row), tensileslip0(row), tsmin(row), tsmax(row), eastslip(row), eastmin(row), eastmax(row), northslip(row), northmin(row), northmax(row));
end

