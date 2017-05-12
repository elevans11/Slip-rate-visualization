%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    1/21/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 1/21/2016 , 15:52:15 pm ) 
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

function m_PlotStates(states,FC,EC) 

hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

for j = 1:numel(states); 
    thislon = states(j).Lon;
    thislat = states(j).Lat;
    
    inx = find(isnan(thislon));
    
    cell_lon = thislon(1:inx(1)-1);
    cell_lat = thislat(1:inx(1)-1);
    
    m_patch(cell_lon, cell_lat, FC, 'EdgeColor', EC,'linewidth', 1);
    
    for kk = 1:numel(inx) - 1;
        cell_lon = thislon(inx(kk)+1:inx(kk+1)-1);
        cell_lat = thislat(inx(kk)+1:inx(kk+1)-1);    
        
        m_patch(cell_lon, cell_lat, FC, 'EdgeColor', EC,'linewidth', 1);
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 




end