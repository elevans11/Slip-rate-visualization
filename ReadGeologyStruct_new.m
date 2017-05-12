%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    1/22/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 1/22/2016 , 11:15:34 am ) 
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

function G = ReadGeologyStruct_new(filename)

infile = fopen(filename,'r');
T = textscan(infile,'%s \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f','delimiter','\t');
fclose(infile);
% keyboard
% names(row,:), Lon(row), Lat(row), Strike(row), strikeslip0(row), ssmin(row), ssmax(row), tensileslip0(row), tsmin(row), tsmax(row), Dxx(row), Dxxmin(row), Dxxmax(row), Dxy(row), Dxymin(row), Dxymax(row), Dyx(row), Dyxmin(row), Dyxmax(row), Dyy(row), Dyymin(row), Dyymax(row));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Make structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

G.name                  = char(T{1});
G.lon                   = T{2};
G.lat                   = T{3};
G.strike                = T{4};
G.strikeslip            = T{5};
G.strikeslipmin         = T{6};
G.strikeslipmax         = T{7};
G.tensileslip           = T{8};
G.tensileslipmin        = T{9};
G.tensileslipmax        = T{10};

G.Dxx                   = T{11};
G.Dxxmin                = T{12};
G.Dxxmax                = T{13};
G.Dxy                   = T{14};
G.Dxymin                = T{15};
G.Dxymax                = T{16};
G.Dyx                   = T{17};
G.Dyxmin                = T{18};
G.Dyxmax                = T{19};
G.Dyy                   = T{20};
G.Dyymin                = T{21};
G.Dyymax                = T{22};


end