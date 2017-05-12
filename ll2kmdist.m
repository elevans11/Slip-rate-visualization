%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    2/17/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 2/17/2016 , 10:30:13 am ) 
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

function kmdist = ll2kmdist(lon1, lon2, lat1, lat2) 

radius                  = 6371;
lon1                    = lon1.*pi/180;
lon2                    = lon2.*pi/180;
lat1                    = lat1.*pi/180;
lat2                    = lat2.*pi/180;
deltaLat                = lat2-lat1;
deltaLon                = lon2-lon1;
a                       = sin((deltaLat)./2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon./2).^2;
c                       = 2*atan2(sqrt(a),sqrt(1-a));
kmdist                  = radius*c; 



end