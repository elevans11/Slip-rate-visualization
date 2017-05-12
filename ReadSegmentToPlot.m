function [Segment] = ReadSegmentStruct(varargin)
%%  ReadSegmentStruct.m
%%
%%  This function reads in and returns the
%%  segment information in fileName.
%%
%%  Arguments:
%%    fileName     :  file name (required)
%%    showText     :  1 to print info (optional)
%%                     default is 0 (no print)
%%
%%  Returned variables:
%%    Segment       :  a struct with everything

%% Declare variables
nHeaderLines                                                         = 13;
nFieldLines                                                          = 13;

%%  Process varargin
if (nargin == 0)
   disp('No arguments found!  Exiting.  Please supply a file name.');
   return;
end

fileName                                                             = varargin{1};
showText                                                             = 0;
if (nargin > 1)
   showText                                                          = varargin{2};
end

if (showText)
   %%  Announce intentions
   disp(' ');
   disp(sprintf('--> Reading %s ', fileName));
end

%%  Read in the whole segment file as a cell
contentsSegmentFile                                                  = textread(fileName, '%s', 'delimiter', '\n', 'whitespace', '');

%%  Get rid of the descriptive header
contentsSegmentFile(1 : nHeaderLines)                                = [];

%%  Assign the remaining data to structs
Segment.name                                                         = char(deal(contentsSegmentFile(1 : nFieldLines : end)));

endPointCoordinates                                                  = str2num(char(contentsSegmentFile(2 : nFieldLines :end)));
[Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2]             = deal(endPointCoordinates(:, 1), endPointCoordinates(:, 2), ...
                                                                            endPointCoordinates(:, 3), endPointCoordinates(:, 4));

end
