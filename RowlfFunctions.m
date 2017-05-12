%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    2/1/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function RowlfFunctions(option)
% RowlfFunctions - functions called by Rowlf (GUI)

%tic

% Declare variables
global ul cul st
% cul st Segment plotsegs Obs Mod Res Rot Def Str Tri cSegment cplotsegs cObs cMod cRes cRot cDef cStr cTri 
translateScale = 0.2;
% Color variables
white           = [1 1 1];
lightGrey       = 0.85 * [1 1 1];
fn              = 'Helvetica';
fs              = 12;
% Get the struct holding the uicontrols' direct handles (avoiding runtime findobj() calls)
ud = get(gcf,'UserData');
Row = ud.Row;



if isdeployed
    fprintf(sprintf('%s\n',ctfroot));
    direc = fullfile(ctfroot);
    geologyfile = fullfile(direc,'SlipRateComp','Geology_strike.txt');
else
    direc = '.';
    geologyfile = fullfile(direc,'Geology_strike.txt');
end

% Parse callbacks
switch(option)
     
    case 'DrawClean'
        deginfo = Row.togPanel.SelectedObject.String;
        switch(deginfo)
            case 'Large'
                degval = 0.6;
            case 'Medium'
                degval = 0.4;
            case 'Small'
                degval = 0.2;
        end
        GridName = sprintf('GridData_%02.2f_deg_CA.mat',degval);
        dirNames = Row.listNames(2:end);
        nDirs           = numel(dirNames);
        %%% Generate Master Structure
        %%% THIS COULD PROBABLY BE DONE FASTER
        if isdeployed
            thisGridName    = fullfile(direc,dirNames{2},GridName);
            %     fprintf('deployed')
        else
            thisGridName    = sprintf('./%s/%s',dirNames{2},GridName);
            %     thisGridName    = fullfile(dirNames{2},'GridData_0.4_deg.mat');
        end
        
        thisGrid        = load(thisGridName);
        MasterGrid(nDirs,:) = thisGrid.GG;
        for ff = 1:nDirs;
            if isdeployed
                thisGridName    = fullfile(direc,dirNames{ff},GridName);
            else
                thisGridName    = sprintf('./%s/%s',dirNames{ff},GridName);
                %         fprintf('%s\n',thisGridName)
            end
            thisGrid        = load(thisGridName);
            MasterGrid(ff,:)  = thisGrid.GG;
            
        end
        Row.MasterGrid = MasterGrid;
        % Get Grid
        load(sprintf('C_%02.2f_deg_CA.mat',degval));
        %%% make field for drawing quickly
        qdx = [C.lon1'; C.lon2'; C.lon3'; C.lon4'; C.lon1'; NaN(size(C.lon1'))];
        qdy = [C.lat1'; C.lat2'; C.lat3'; C.lat4'; C.lat1'; NaN(size(C.lat1'))];
        C.quickdraw = [qdx(:) qdy(:)];
        Row.C = C;
        
        
        delete(Row.mapAx);
%         fPos = get(gcf,'Position', 'pixels');
        fPos = getpixelposition(gcf);
        fSize = [fPos(3:4) fPos(3:4)];
        Row.mapAx               = axes('parent',      gcf, 'units', 'pixels', 'position', fSize.*[0.046 0.241 0.44 0.678], 'visible', 'on', 'Tag', 'Row.mapAx', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'nextplot', 'add');
        
        range                   = [233 247 32 42.5];
%         states                  = shaperead('usastatehi', 'UseGeoCoords', true, 'BoundingBox', [range(1:2)'-360, range(3:4)']); % plot statelines
        states                  = load('states.mat');
        states                  = states.states;
        FC                      = 0.7*[1 1 1];
        EC                      = 0.5*[1 1 1];
        PlotStates(states,FC,EC);
        hold on;
        for gg = 1:numel(Row.C.lon1);
            gcell               = [Row.C.c(Row.C.v(gg,:),1),Row.C.c(Row.C.v(gg,:),2)];
            patch(gcell(:,1),gcell(:,2),0,'FaceColor','none','EdgeColor',0.8*[1 1 1],'LineWidth',1);
        end
        Range.lon                    = [235 247];
        Range.lat                    = [32 42.5];
        Range.lonOld            = repmat(Range.lon, ul, 1);
        Range.latOld            = repmat(Range.lat, ul, 1);
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        Handles.Row = Row;
        % Make all figure components normalized so that they auto-resize on figure resize
        set(findall(gcf,'-property','Units'),'Units','norm');
        set(gcf, 'userdata', Handles);
        
    case 'Row.SwitchGrid'
%         keyboard
        if Row.togPanel.SelectedObject ~= Row.OldGrid; 
        htemp = questdlg('Changing the grid size will refresh the application. Are you sure you want to change?','Change Grid Size','Nevermind','Change','Nevermind');
        switch htemp
            case 'Nevermind'
%                 keyboard
                Row.togPanel.SelectedObject = Row.OldGrid;
            case 'Change'
%                 set(findall(gcf,'-property','Units'),'Units','norm');
                RowlfFunctions('DrawClean');
        end
        end
        Row.OldGrid = Row.togPanel.SelectedObject;
        Handles.Row = Row;
        set(gcf, 'userdata', Handles);
        RowlfFunctions('DrawClean');
        
    case 'Row.sortMenu';
        ClearMap
        ClearSub
        menuList                = get(Row.sortMenu,'String');
        menuVal                 = get(Row.sortMenu,'Value');
        ListVal                 = menuList{menuVal};
        contents                = cellstr(get(Row.modelList,'String'));
        dirNames                = contents(2:end);
        dirNames                = cellfun(@(x) x(7:end),dirNames,'UniformOutput',false);
        dirYear                 = cellfun(@(x) x(end-3:end),dirNames,'UniformOutput',false);
        switch(ListVal)
            case 'Author Name (alphabetical)'
                [S, ix]         = sort(upper(dirNames));
                dirNames        = dirNames(ix);
                for dd          = 1:numel(dirNames);
                    label       = sprintf('(%i)',dd);
                    dirList{dd} = sprintf('%-6s%s', label, dirNames{dd});
                end
                dirList         = [{'< none >'}, dirList];
                listNames       = Row.listNames(2:end);
                listNames       = listNames(ix);
                Row.listNames(2:end) = listNames;
                set(Row.modelList,'string',dirList);
            case 'Publication Year (oldest-newest)'
                [S, ix]         = sort(dirYear);
                dirNames        = dirNames(ix);
                for dd          = 1:numel(dirNames);
                    label       = sprintf('(%i)',dd);
                    dirList{dd} = sprintf('%-6s%s', label, dirNames{dd});
                end
                dirList         = [{'< none >'}, dirList];
                listNames       = Row.listNames(2:end);
                listNames       = listNames(ix);
                Row.listNames(2:end) = listNames;
                set(Row.modelList,'string',dirList);
            case 'Study Area (north-south)'
%                 [S, ix]         = sort(dirYear);
%                 dirNames        = dirNames(ix);
                modRange        = GetModelRange(contents);
                [S, ix]         = sort(modRange(:,2),'descend');
                dirNames        = dirNames(ix);
                for dd          = 1:numel(dirNames);
                    label       = sprintf('(%i)',dd);
                    dirList{dd} = sprintf('%-6s%s', label, dirNames{dd});
                end
                dirList         = [{'< none >'}, dirList];
                listNames       = Row.listNames(2:end);
                listNames       = listNames(ix);
                Row.listNames(2:end) = listNames;
                set(Row.modelList,'string',dirList);
            case 'Study Area (west-east)'
                modRange        = GetModelRange(contents);
                [S, ix]         = sort(modRange(:,1),'ascend');
                dirNames        = dirNames(ix);
                for dd          = 1:numel(dirNames);
                    label       = sprintf('(%i)',dd);
                    dirList{dd} = sprintf('%-6s%s', label, dirNames{dd});
                end
                dirList         = [{'< none >'}, dirList];
                listNames       = Row.listNames(2:end);
                listNames       = listNames(ix);
                Row.listNames(2:end) = listNames;
                set(Row.modelList,'string',dirList);
        end
        Row.MasterGrid = Row.MasterGrid(ix,:);
        Handles.Row = Row;
        set(gcf, 'userdata', Handles);
        
    case 'Row.selModList'
%         keyboard
        P = findobj(gcf,'Tag','dataplot');
        delete(P);
%         contents                = cellstr(get(Row.modelList,'String'));
%         theseModels             = contents(get(Row.modelList,'Value'));
        ModelIdx                = get(Row.modelList,'Value');
%         keyboard
%         PlotTheseSegments(theseModels);
        PlotTheseSegments(ModelIdx);
        

        
    case 'Row.allPush'
        P = findobj(gcf,'Tag','dataplot');
        delete(P);
        contents                = cellstr(get(Row.modelList,'String'));
        set(Row.modelList,'Value',2:numel(contents));
%         theseModels             = contents(get(Row.modelList,'Value'));
        ModelIdx                = get(Row.modelList,'Value');
        PlotTheseSegments(ModelIdx);

    case 'Row.nonePush'
        P = findobj(gcf,'Tag','dataplot');
        delete(P);
        contents                = cellstr(get(Row.modelList,'String'));
        set(Row.modelList,'Value',1);
%         theseModels             = contents(get(Row.modelList,'Value'));
        ModelIdx                = get(Row.modelList,'Value');
        PlotTheseSegments(ModelIdx);
        
    case 'Row.valueMenu'
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        metricList              = get(Row.metricMenu,'String');
        metricVal               = get(Row.metricMenu,'Value');
        PlotMet                 = metricList{metricVal};
        EnableGeo(PlotVal,PlotMet);
        
    case 'Row.metricMenu'
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        metricList              = get(Row.metricMenu,'String');
        metricVal               = get(Row.metricMenu,'Value');
        PlotMet                 = metricList{metricVal};
        EnableGeo(PlotVal,PlotMet);
        
    case 'Row.geoCheck'
        G = ReadGeologyStruct_new(geologyfile);
        gVal = NaN(numel(G.lon),1);
        if get(Row.geoCheck,'Value');
            metricList              = get(Row.metricMenu,'String');
            metricVal               = get(Row.metricMenu,'Value');
            PlotMet                 = metricList{metricVal};
            if strcmp(PlotMet,'mean') ||  strcmp(PlotMet,'median')
            axes(Row.mapAx);
            valueList               = get(Row.valueMenu,'String');
            valueVal                = get(Row.valueMenu,'Value');
            PlotVal                 = valueList{valueVal};
            switch(PlotVal)
                case 'east-west opening'
                    gVal = -G.Dxx*1e3;
                case 'north-south opening'
                    gVal = -G.Dyy*1e3;
                case 'east-west shear'
                    gVal = -G.Dxy*1e3;
                case 'north-south shear'
                    gVal = -G.Dyx*1e3;
                case 'strike slip'
                    gVal = G.strikeslip*1e3;
                case 'tensile slip'
                    gVal = G.tensileslip*1e3;
                case 'PA/NA-perpendicular opening'
                    for gg = 1:numel(G.lon)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
                        D       = -[G.Dxx(gg) G.Dxy(gg); G.Dyx(gg) G.Dyy(gg)]*1e3;
                        pbrotated = rotmat2*D*rotmat2';
                        gVal(gg) = -pbrotated(1,1);
                    end
                case 'PA/NA-perpendicular shear'
                    for gg = 1:numel(G.lon)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
                        D       = -[G.Dxx(gg) G.Dxy(gg); G.Dyx(gg) G.Dyy(gg)]*1e3;
                        pbrotated = rotmat2*D*rotmat2';
                        gVal(gg) = -pbrotated(1,2);
                    end
                case 'PA/NA-parallel shear'
                    for gg = 1:numel(G.lon)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
                        D       = -[G.Dxx(gg) G.Dxy(gg); G.Dyx(gg) G.Dyy(gg)]*1e3;
                        pbrotated = rotmat2*D*rotmat2';
                        gVal(gg) = -pbrotated(2,1);
                    end
                case 'PA/NA-parallel opening'
                    for gg = 1:numel(G.lon)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
                        D       = -[G.Dxx(gg) G.Dxy(gg); G.Dyx(gg) G.Dyy(gg)]*1e3;
                        pbrotated = rotmat2*D*rotmat2';
                        gVal(gg) = -pbrotated(2,2);
                    end  
            end
            if ~isnan(gVal) 
                scatter(G.lon+360, G.lat, 150, gVal, 'filled','MarkerEdgeColor','w');
            end
            end
%             

        else
            Sc = findobj(gca,'Type','Scatter');
            delete(Sc)
        end
        
    case 'Row.plotPush'
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        metricList              = get(Row.metricMenu,'String');
        metricVal               = get(Row.metricMenu,'Value');
        PlotMet                 = metricList{metricVal};
        PlotThisGrid(PlotVal,PlotMet);
        
    case 'Row.saveOut'
        if isfield(Row,'plotvalue')
            prompt = {'Enter output file name:'};
            dlg_title = 'Save Output';
            outfilename = char(inputdlg(prompt,dlg_title));
            WriteGridCells(outfilename, Row.C.c, Row.C.v, Row.plotvalue);		
        else
            htemp = msgbox('Make sure you have something plotted first!');
        end
        
    case 'Row.saveOutSmall'
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        contents                = cellstr(get(Row.modelList,'String'));
        ModelIX                 = get(Row.modelList,'Value');
        if isfield(Row,'subplotvalue')
            prompt = {'Enter output file name:'};
            dlg_title = 'Save Output';
            outfilename = char(inputdlg(prompt,dlg_title));
            fid = fopen(outfilename, 'w');
            if size(Row.subplotvalue,2) == 1;
                fprintf(fid,'Subplot Type: Bar/Histogram\n');
                fprintf(fid,'GridCell: %d\n\n', Row.subInfo);
                fprintf(fid,'Study \t Value\n');
                for sp = 1:numel(Row.subplotvalue(:,1));
                    fprintf(fid,'%s\t%3.3f\n',char(contents(ModelIX(sp),:)),Row.subplotvalue(sp));
                end
            elseif size(Row.subplotvalue,2) == 2;
                fprintf(fid,'Subplot Type: Profile\n');
                fprintf(fid,'EndPoint1: %3.3f %3.3f\n', Row.subInfo(1,1), Row.subInfo(1,2));
                fprintf(fid,'EndPoint2: %3.3f %3.3f\n\n', Row.subInfo(2,1), Row.subInfo(2,2));
                fprintf(fid,'Distance (km) \t Value\n');
                for sp = 1:numel(Row.subplotvalue(:,1));
                    fprintf(fid,'%3.3f\t%3.3f\n',Row.subplotvalue(sp,1),Row.subplotvalue(sp,1));
                end
            end
            fclose(fid);
        else
            htemp = msgbox('Make sure you have something plotted here first!');
        end
        
    case 'Row.savePlot'
%         if isfield(Row,'plotvalue')
            prompt = {'Enter plot file name:'};
            dlg_title = 'Save Plot';
            outfilename = char(inputdlg(prompt,dlg_title));
            p = strfind(outfilename,'.');
            if ~isempty(p)
                fex = outfilename(p+1:end);
            else
                fex = 'pdf'; 
                outfilename = [outfilename '.pdf'];
            end
            if strcmp(fex(end-1:end),'ps');
                fex = [fex 'c2'];
            end
            tempfig = figure;
            temp_new = copyobj(Row.mapAx,tempfig);
            set(temp_new, 'Position', get(0, 'DefaultAxesPosition'));
            if strcmp(fex,'fig');
                save(tempfig,outfilename);
            else
                print(tempfig,outfilename,['-d' fex])
            end
            close(tempfig); clear tempfig;
%         else
%             htemp = msgbox('Make sure you have something plotted first!');
%         end
        
    case 'Row.savePlotSmall'
        if isfield(Row,'subplotvalue')
            prompt = {'Enter plot file name:'};
            dlg_title = 'Save Plot';
            outfilename = char(inputdlg(prompt,dlg_title));
            p = strfind(outfilename,'.');
            if ~isempty(p)
                fex = outfilename(p+1:end);
            else
                fex = 'pdf'; 
                outfilename = [outfilename '.pdf'];
            end
            if strcmp(fex(end-1:end),'ps');
                fex = [fex 'c2'];
            end
            tempfig = figure;
            temp_new = copyobj(Row.smallAxis,tempfig);
            set(temp_new, 'Position', get(0, 'DefaultAxesPosition'));
            drawnow
            if strcmp(fex,'fig');
                save(tempfig,outfilename);
            else
                print(tempfig,outfilename,['-d' fex])
            end
            close(tempfig); clear tempfig;
        else
            htemp = msgbox('Make sure you have something plotted first!');
        end
        
    case 'Row.gridPush'
        set(get(Row.subPanel,'Children'),'Enable','on');
        lonMid                  = ((Row.C.lon1 + Row.C.lon2 + Row.C.lon3 + Row.C.lon4) / 4) + 360;
        latMid                  = (Row.C.lat1 + Row.C.lat2 + Row.C.lat3 + Row.C.lat4) / 4;
%         Dp                       = pdist([lonMid, latMid]);
        D                       = sqdistance([lonMid, latMid]');
%         keyboard
%         mindist                 = ceil(min(nonzeros(D)));
        mindist                 = ceil(min(D(D>1e-5)));
        axes(Row.mapAx);
        L = findobj(gca,'Type','line','Color','r');
        PO = findobj(gca,'Type','line','marker','o','markerfacecolor','w');
        P1 = findobj(gca,'Type','line','marker','o','markerfacecolor',0.5*[1 1 1]);

        delete(L)
        delete(PO)
        delete(P1)
        [gridIdx]               = GetGridSingle_mindist(Row.C, mindist);
        whichplot               = get(Row.subPanel.SelectedObject,'Tag');
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        metricList              = get(Row.metricMenu,'String');
        metricVal               = get(Row.metricMenu,'Value');
        PlotMet                 = metricList{metricVal};
        DrawSub(gridIdx,PlotVal,PlotMet,whichplot);

    case 'Row.barButton'
        axes(Row.smallAxis);
        xl = get(gca,'xlabel');
        xl = xl.String;
        if ~strcmp(xl,'distance along profile (km)')
        P = findobj(gca,'Type','patch'); 
        if ~isempty(P)
            data = Row.subplotvalue;
            valueList               = get(Row.valueMenu,'String');
            valueVal                = get(Row.valueMenu,'Value');
            PlotVal                 = valueList{valueVal};
            whichplot               = 'Row.barButton';
%             GeoGrid                 = [];
            ClearSub
            MakeBars(data,PlotVal,whichplot,Row.GeoGrid);
        end
        end
        
    case 'Row.histButton'
        axes(Row.smallAxis);
        xl = get(gca,'xlabel');
        xl = xl.String;
        if ~strcmp(xl,'distance along profile (km)')
        B = findobj(gca,'Type','bar');
        if ~isempty(B)
            data = get(B,'YData');
            valueList               = get(Row.valueMenu,'String');
            valueVal                = get(Row.valueMenu,'Value');
            PlotVal                 = valueList{valueVal};
            whichplot               = 'Row.histButton';
            ClearSub
            MakeBars(data,PlotVal,whichplot,Row.GeoGrid);
        end
        end
        
    case 'Row.profPush'
        set(get(Row.subPanel,'Children'),'Enable','off')
        axes(Row.mapAx)
        L = findobj(gca,'Type','line','Color','r');
        PO = findobj(gca,'Type','line','marker','o','markerfacecolor','w');
        P1 = findobj(gca,'Type','line','marker','o','markerfacecolor',0.5*[1 1 1]);

        delete(L)
        delete(PO)
        delete(P1)
% delete M2
%         delete([L,M1,M2]);
%         delete(M1,M2);
%         delete(
        
        set(gcf, 'WindowButtonDownFcn', @ButtonDown);
        set(gcf, 'WindowButtonUpFcn', @ButtonUp);  
        k = waitforbuttonpress;
        point1 = get(gca, 'CurrentPoint');
        done                     = 0;
        setappdata(gcf, 'doneClick', done);
        while ~done
            done                  = getappdata(gcf, 'doneClick');
            L = findobj(gca,'Type','line','LineStyle','--');
            delete(L); 
            [x, y]                = GetCurrentAxesPosition;
            plot([point1(1,1) x], [point1(1,2) y],'--r','LineWidth',3);
            
            
            drawnow
        end
        set(gcf, 'WindowButtonDownFcn', '');
        set(gcf, 'WindowButtonUpFcn', '');
        plot(point1(1,1), point1(1,2),'ok','MarkerFaceColor','w','MarkerSize',10);
        plot(x, y,'ok','MarkerFaceColor',0.5*[1 1 1],'MarkerSize',10);
        %%% Move to separate function
        PlotProfile(point1, [x y]);
%         keyboard
                
    case 'Row.enterPush'
        set(get(Row.subPanel,'Children'),'Enable','off')
        prompt = {'longitude of start point','latitude of start point','longitude of end point','latitude of end point'};
        dlg_title = 'Enter profile coordinates';
        answer = inputdlg(prompt,dlg_title);
        answer = cellfun(@(x) str2double(x),answer);
        axes(Row.mapAx)
        L = findobj(gca,'Type','line','Color','r');
        PO = findobj(gca,'Type','line','marker','o','markerfacecolor','w');
        P1 = findobj(gca,'Type','line','marker','o','markerfacecolor',0.5*[1 1 1]);

        delete(L)
        delete(PO)
        delete(P1)
        if ~isempty(answer)
        plot([answer(1) answer(3)], [answer(2) answer(4)],'--r','LineWidth',3);
%         [px, py, ii] = polyxpoly([answer(1) answer(3)], [answer(2) answer(4)],Row.C.quickdraw(:,1)+360,Row.C.quickdraw(:,2));
%         gridIdx = (ceil(ii(:,2)/6));  
        PlotProfile([answer(1) answer(2)], [answer(3) answer(4)]);

        end
           
    %%% Start Navigation Callbacks    
    case 'Row.navUpdate'
        axes(Row.mapAx)
        lonMax = str2double(get(Row.navEditLonMax, 'string'));
        lonMin = str2double(get(Row.navEditLonMin, 'string'));
        latMax = str2double(get(Row.navEditLatMax, 'string'));
        latMin = str2double(get(Row.navEditLatMin, 'string'));
        Range = getappdata(gcf, 'Range');
        Range.lon = [lonMin lonMax];
        Range.lat = [latMin latMax];
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navBack'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        RangeLev = max([1 cul]);
        Range.lon = Range.lonOld(RangeLev, :);
        Range.lat = Range.latOld(RangeLev, :);
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        cul = max([1 RangeLev - 1]);
        SetAxes(Range);
        
    case 'Row.navZoomRange'
        axes(Row.mapAx)
        Range = GetRangeRbbox(getappdata(gcf, 'Range'));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        Range = getappdata(gcf, 'Range');
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        
    case 'Row.navZoomIn'
        axes(Row.mapAx)
        zoomFactor = 0.5;
        Range = getappdata(gcf, 'Range');
        deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
        deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
        centerLon = mean(Range.lon);
        centerLat = mean(Range.lat);
        Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
        Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navZoomOut'
        axes(Row.mapAx)
        zoomFactor = 2.0;
        Range = getappdata(gcf, 'Range');
        deltaLon = (max(Range.lon) - min(Range.lon)) / 2;
        deltaLat = (max(Range.lat) - min(Range.lat)) / 2;
        centerLon = mean(Range.lon);
        centerLat = mean(Range.lat);
        Range.lon = [centerLon - zoomFactor * deltaLon, centerLon + zoomFactor * deltaLon];
        Range.lat = [centerLat - zoomFactor * deltaLat, centerLat + zoomFactor * deltaLat];
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navSW'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon - translateScale * deltaLon;
        Range.lat = Range.lat - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navS'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon;
        Range.lat = Range.lat - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navSE'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon + translateScale * deltaLon;
        Range.lat = Range.lat - translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navW'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon - translateScale * deltaLon;
        Range.lat = Range.lat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navE'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon + translateScale * deltaLon;
        Range.lat = Range.lat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navNW'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon - translateScale * deltaLon;
        Range.lat = Range.lat + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navN'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon;
        Range.lat = Range.lat + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.navNE'
        axes(Row.mapAx)
        Range = getappdata(gcf, 'Range');
        deltaLon = max(Range.lon) - min(Range.lon);
        deltaLat = max(Range.lat) - min(Range.lat);
        Range.lon = Range.lon + translateScale * deltaLon;
        Range.lat = Range.lat + translateScale * deltaLat;
        Range = CheckRange(Range);
        Range.lonOld = [Range.lonOld(st:cul+1, 1:2) ; Range.lon];
        Range.latOld = [Range.latOld(st:cul+1, 1:2) ; Range.lat];
        cul = min([size(Range.lonOld, 1)-1 cul+1]);
        st = 1 + (cul==(ul-1));
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        
    case 'Row.clearAll'
        set(Row.modelList,'Value',1);
        set(Row.valueMenu,'Value',1);
        set(Row.metricMenu,'Value',1);
        set(Row.geoCheck,'Value',0,'Enable','off');
        nDirs = numel(get(Row.modelList,'String')) - 1;
        ClearMap
        ClearSub
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  OTHER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Get range from drawn rubberband box %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Range = GetRangeRbbox(Range)
    %%%  GetRangeRbbox
    k = waitforbuttonpress;
    point1 = get(gca, 'CurrentPoint');
    finalRect = rbbox;
    point2 = get(gca, 'CurrentPoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    Range.lon = sort([point1(1) point2(1)]);
    Range.lat = sort([point1(2) point2(2)]);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%% Get gridcells from drawn rubberband box 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% function GridIdx = GetGridRbbox(C);
%     %%%  GetRangeRbbox
%     k = waitforbuttonpress;
%     point1 = get(gca, 'CurrentPoint');
%     finalRect = rbbox;
%     point2 = get(gca, 'CurrentPoint');
%     point1 = point1(1,1:2);
%     point2 = point2(1,1:2);
%     keyboard
% %     IN = inpolygon(C.c(C.v), C.c(C.v), finalRect)
% %     Range.lon = sort([point1(1) point2(1)]);
% %     Range.lat = sort([point1(2) point2(2)]);
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Set axis limits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function SetAxes(Range)
    %%  SetAxes
    axis equal % disables 'stretch to fill'
    set(gca,'DataAspectRatio',[1 0.82 1]);
    axis([min(Range.lon) max(Range.lon) min(Range.lat) max(Range.lat)]);
    set(findobj(gcf, 'Tag', 'Row.navEditLonMin'), 'string', sprintf('%7.3f', min(Range.lon)));
    set(findobj(gcf, 'Tag', 'Row.navEditLonMax'), 'string', sprintf('%7.3f', max(Range.lon)));
    set(findobj(gcf, 'Tag', 'Row.navEditLatMin'), 'string', sprintf('%7.3f', min(Range.lat)));
    set(findobj(gcf, 'Tag', 'Row.navEditLatMax'), 'string', sprintf('%7.3f', max(Range.lat)));

    if max(Range.lon) == 360
        set(gca, 'XTick', [0 60 120 180 240 300 360]);
        set(gca, 'YTick', [-90 -45 0 45 90]);
    else
        set(gca, 'XTickMode', 'auto');
        set(gca, 'YTickMode', 'auto');
    end
end

%%%%%%%%%%%%%%%%%%%%%%
% Check window range %
%%%%%%%%%%%%%%%%%%%%%%
function Range = CheckRange(Range)
    % CheckRange
    Range.lon = sort(Range.lon);
    Range.lat = sort(Range.lat);
    Range.lon(Range.lon > 360) = 360;
    Range.lon(Range.lon < 0) = 0;
    Range.lat(Range.lat > 90) = 90;
    Range.lat(Range.lat < -90) = -90;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Plot States
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function PlotStates(states,FC,EC) 

hold on;

for j = 1:numel(states); 
%     keyboard
    thislon = states(j).Lon+360;
    thislat = states(j).Lat;
    inx = find(isnan(thislon));
    cell_lon = thislon(1:inx(1)-1);
    cell_lat = thislat(1:inx(1)-1);
    patch(cell_lon, cell_lat, FC, 'EdgeColor', EC,'linewidth', 1);
    line(cell_lon, cell_lat, 'Color', EC,'linewidth',2);
    for kk = 1:numel(inx) - 1;
        cell_lon = thislon(inx(kk)+1:inx(kk+1)-1);
        cell_lat = thislat(inx(kk)+1:inx(kk+1)-1);    
        patch(cell_lon, cell_lat, FC, 'EdgeColor', EC,'linewidth', 1);
        line(cell_lon, cell_lat, 'Color', EC,'linewidth',2);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Plot These Segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function PlotTheseSegments(ModelIdx)
%     keyboard
    theseModels = Row.listNames(ModelIdx);
    axes(Row.mapAx);
    L = findobj(gca,'Type','line','Color','k');


        delete(L)

    for ff = 1:numel(theseModels);
        if ~strcmp(theseModels{ff},'< none >');
%             keyboard
%             thisFaultFile           = sprintf('./%s/Segments.mod',theseModels{ff}(7:end));
%             thisFaultFile           = sprintf('./%s/Segments.mod',theseModels{ff});
            thisFaultFile           = fullfile(direc,theseModels{ff},'Segments.mod');
            S                       = load(thisFaultFile);
            hold on;
            plot(S(:,1),S(:,2),'-k','LineWidth',1);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Get Model Area Range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function modRange = GetModelRange(contents)
%     keyboard
    modRange = repmat([mean([235 247]) mean([32 43])],numel(contents)-1,1);
    for ff = 2:numel(Row.listNames);
%         thisFaultFile               = sprintf('./%s/Segments.mod',contents{ff}(7:end));
%         thisFaultFile               = sprintf('./%s/Segments.mod',Row.listNames{ff});
        thisFaultFile           = fullfile(direc,Row.listNames{ff},'Segments.mod');
        S                           = load(thisFaultFile);
        modRange(ff-1,:)            = [mean([min(S(:,1)) max(S(:,1))]) mean([min(S(:,2)) max(S(:,2))])];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Plot Summary Grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [plottemp, plotvalue] = GetPlotValue(PlotVal,PlotMet);
    ModelIX                 = get(Row.modelList,'Value') - 1;
    plottemp                = zeros(numel(Row.C.lon1),numel(ModelIX));
    plotvalue               = NaN(numel(Row.C.lon1),1);
    if ModelIX(1) ~= 0;
        switch(PlotVal)
            case '< none >'
                htemp = msgbox('Select a plot value before plotting!');
            case 'potency'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = Row.MasterGrid(ModelIX(jj),ii).potency;
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'vxx'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = Row.MasterGrid(ModelIX(jj),ii).Dxx;
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'vyy'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = Row.MasterGrid(ModelIX(jj),ii).Dyy;
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'vxy'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = Row.MasterGrid(ModelIX(jj),ii).Dxy;
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'vyx'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = Row.MasterGrid(ModelIX(jj),ii).Dyx;
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'shear strain'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = (1/2)* (Row.MasterGrid(ModelIX(jj),ii).Dyx + Row.MasterGrid(ModelIX(jj),ii).Dxy);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'rotation'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = (1/2)* (Row.MasterGrid(ModelIX(jj),ii).Dxy - Row.MasterGrid(ModelIX(jj),ii).Dyx);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'PA/NA-parallel shear'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
                        torotate = [Row.MasterGrid(ModelIX(jj),ii).eastopen Row.MasterGrid(ModelIX(jj),ii).eastshear; ...
                                    Row.MasterGrid(ModelIX(jj),ii).northshear Row.MasterGrid(ModelIX(jj),ii).northopen];
%                         pbrotated = rotmat2*[Row.MasterGrid(ModelIX(jj),ii).eastslip; Row.MasterGrid(ModelIX(jj),ii).northslip];
%                         thisvalue = -pbrotated(2);                        
                        pbrotated = rotmat2*torotate*rotmat2';
                        thisvalue = pbrotated(2,1);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisvalue*1e3;
                        end
                    end
                end
            case 'PA/NA-perpendicular shear'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                            sin(Row.pbstrike)  cos(Row.pbstrike)];
%                         pbrotated = rotmat2*[Row.MasterGrid(ModelIX(jj),ii).eastslip; Row.MasterGrid(ModelIX(jj),ii).northslip];
%                         thisvalue = pbrotated(1);
                        torotate = [Row.MasterGrid(ModelIX(jj),ii).eastopen Row.MasterGrid(ModelIX(jj),ii).eastshear; ...
                                    Row.MasterGrid(ModelIX(jj),ii).northshear Row.MasterGrid(ModelIX(jj),ii).northopen];
                        pbrotated = rotmat2*torotate*rotmat2';
                        thisvalue = pbrotated(1,2);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisvalue*1e3;
                        end
                    end
                end
            case 'PA/NA-parallel opening'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                            sin(Row.pbstrike)  cos(Row.pbstrike)];
%                         pbrotated = rotmat2*[Row.MasterGrid(ModelIX(jj),ii).eastslip; Row.MasterGrid(ModelIX(jj),ii).northslip];
%                         thisvalue = pbrotated(1);
                        torotate = [Row.MasterGrid(ModelIX(jj),ii).eastopen Row.MasterGrid(ModelIX(jj),ii).eastshear; ...
                                    Row.MasterGrid(ModelIX(jj),ii).northshear Row.MasterGrid(ModelIX(jj),ii).northopen];
                        pbrotated = rotmat2*torotate*rotmat2';
                        thisvalue = pbrotated(2,2);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisvalue*1e3;
                        end
                    end
                end
            case 'PA/NA-perpendicular opening'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        rotmat2 = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                                   sin(Row.pbstrike)  cos(Row.pbstrike)];
%                         pbrotated = rotmat2*[Row.MasterGrid(ModelIX(jj),ii).eastslip; Row.MasterGrid(ModelIX(jj),ii).northslip];
%                         thisvalue = pbrotated(1);
                        torotate = [Row.MasterGrid(ModelIX(jj),ii).eastopen Row.MasterGrid(ModelIX(jj),ii).eastshear; ...
                                    Row.MasterGrid(ModelIX(jj),ii).northshear Row.MasterGrid(ModelIX(jj),ii).northopen];
                        pbrotated = rotmat2*torotate*rotmat2';
                        thisvalue = pbrotated(1,1);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisvalue*1e3;
                        end
                    end
                end
            case 'strike slip'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = mean(Row.MasterGrid(ModelIX(jj),ii).ssRates);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
            case 'tensile slip'
                for ii = 1:numel(Row.C.lon1)
                    for jj = 1:numel(ModelIX)
                        thisValue = mean(Row.MasterGrid(ModelIX(jj),ii).tsRates);
                        if Row.MasterGrid(ModelIX(jj),ii).nmods == 0;
                            plottemp(ii,jj) = NaN;
                        else
                            plottemp(ii,jj) = thisValue;
                        end
                    end
                end
        end
    end
    
    switch(PlotMet)
            case '< none >'
                if ~strcmp(PlotVal,'< none >');
                    htemp = msgbox('Select a plot metric before plotting!');
                end
            case 'mean'
                plotvalue = mean(plottemp,2,'omitnan');
            case 'median'
                plotvalue = median(plottemp,2,'omitnan');
            case 'st. dev.'
                plotvalue = zeros(numel(plottemp(:,1)),1);
                IF = isfinite(plottemp);
                ss = sum(IF,2);
                for ii = 1:numel(ss)
                    if ss(ii) > 1;
                        plotvalue(ii) = std(plottemp(ii,:),'omitnan');
                    elseif ss(ii)<=1;
                        plotvalue(ii) = NaN;
                    end
                end
            case 'st. err.'
                plotvalue = zeros(numel(plottemp(:,1)),1);
                IF = isfinite(plottemp);
                ss = sum(IF,2);
                for ii = 1:numel(ss)
                    if ss(ii) > 1;
                        plotvalue(ii) = std(plottemp(ii,:),'omitnan')/sqrt(ss(ii));
                    elseif ss(ii)<=1;
                        plotvalue(ii) = NaN;
                    end
                end
            case 'coef. of var.'
                plotvalue = zeros(numel(plottemp(:,1)),1);
                IF = isfinite(plottemp);
                ss = sum(IF,2);
                for ii = 1:numel(ss)
                    if ss(ii) > 1;
                        plotvalue(ii) = std(plottemp(ii,:),'omitnan')./mean(plottemp(ii,:),'omitnan');
                    elseif ss(ii)<=1;
                        plotvalue(ii) = NaN;
                    end
                end
            case 'number of studies'
%                 plotvalue = zeros(numel(plottemp(:,1)),1);
                IF = isfinite(plottemp);
                ss = sum(IF,2);
                ss(ss==0) = NaN; 
                plotvalue = ss;
        end
end
    

function PlotThisGrid(PlotVal,PlotMet)
    axes(Row.mapAx);
    L = findobj(gca,'Type','line','Color','r');
    delete(L);
    L = findobj(gca,'Type','line','LineStyle','--');
    delete(L);
   
        PO = findobj(gca,'Type','line','marker','o','markerfacecolor','w');
        P1 = findobj(gca,'Type','line','marker','o','markerfacecolor',0.5*[1 1 1]);

        
        delete(PO)
        delete(P1)
    ModelIX                 = get(Row.modelList,'Value') - 1;
    if ModelIX(1) ~= 0;
        
    [plottemp, plotvalue] = GetPlotValue(PlotVal,PlotMet);
%     plotvalue = GetPlotValue(plottemp);    
        
        X = [Row.C.lon1 Row.C.lon2 Row.C.lon3 Row.C.lon4];
        Y = [Row.C.lat1 Row.C.lat2 Row.C.lat3 Row.C.lat4];
        patch(X'+360,Y',plotvalue','EdgeColor',0.8*[1 1 1],'Tag','dataplot');
        hold on;
        patch(X(~isnan(plotvalue),:)'+360,Y(~isnan(plotvalue),:)',1,'EdgeColor',0.8*[1 1 1],'FaceColor','none','LineWidth',2,'Tag','dataplot');
        LS = findobj(gca,'Type','line','Color',0.5*[1 1 1]);
        uistack(LS,'top')
        LF = findobj(gca,'Type','line','Color','k');
        uistack(LF,'top')
        SetColorBar(PlotVal,PlotMet);
        EnableGeo(PlotVal,PlotMet);
        Row.plotvalue = plotvalue;
        Handles.Row = Row;
        set(gcf, 'userdata', Handles);
    else
        htemp = msgbox('Select one or more studies to plot!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Plot Colorbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function SetColorBar(PlotVal,PlotMet)
    switch(PlotVal)
        case 'potency'
            colormap(parula);
            switch(PlotMet)
                case '< none >'
                    ca = [];
                case 'mean'
                    ca = [0 1000];
                    cstring = 'potency rate (m^2/yr)';
                case 'median'
                    ca = [0 1000];
                    cstring = 'potency rate (m^2/yr)';
                case 'st. dev.'
                    ca = [0 100];
                    cstring = 'standard deviation: potency rate (m^2/yr)';
                case 'number of studies'
                    ca = [0 20];
                    cstring = 'number of studies per gridcell';
                    
            end
            cmap = 'parula';
        case {'vxx','vxy','vyx','vyy'}
            switch(PlotMet)
                case '< none >'
                    ca = [];
                case 'mean'
                    ca = [-1 1]*1e-6;
                    cstring = 'velocity gradient (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'median'
                    ca = [-1 1]*1e-6;
                    cstring = 'velocity gradient (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'st. dev.'
                    ca = [0 1]*1e-7;
                    cstring = 'velocity gradient (yr^{-1})';
                    cmap = 'parula';
                case 'number of studies'
                    ca = [0 20];
                    cstring = 'number of studies per gridcell';
                    cmap = 'parula';
            end
         case {'shear strain'}
            switch(PlotMet)
                case '< none >'
                    ca = [];
                case 'mean'
                    ca = [-1 1]*1e-6;
                    cstring = 'shear strain rate (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'median'
                    ca = [-1 1]*1e-6;
                    cstring = 'shear strain rate (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'st. dev.'
                    ca = [0 1]*1e-7;
                    cstring = 'shear strain rate (yr^{-1})';
                    cmap = 'parula';
                case 'number of studies'
                    ca = [0 20];
                    cstring = 'number of studies per gridcell';
                    cmap = 'parula';
            end
        case {'rotation'}
            switch(PlotMet)
                case '< none >'
                    ca = [];
                case 'mean'
                    ca = [-1 1]*1e-6;
                    cstring = 'rotation rate (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'median'
                    ca = [-1 1]*1e-6;
                    cstring = 'rotation rate (yr^{-1})';
                    cmap = 'bluewhitered';
                case 'st. dev.'
                    ca = [0 1]*1e-7;
                    cstring = 'rotation rate (yr^{-1})';
                    cmap = 'parula';
                case 'number of studies'
                    ca = [0 20];
                    cstring = 'number of studies per gridcell';
                    cmap = 'parula';
            end
        otherwise
            switch(PlotMet)
                case '< none >'
                    ca = [];
                case 'mean'
                    ca = [-30 30];
                    cstring = 'slip rate (mm/yr)';
                    cmap = 'bluewhitered';
                case 'median'
                    ca = [-30 30];
                    cstring = 'slip rate (mm/yr)';
                    cmap = 'bluewhitered';
                case 'st. dev.'
                    ca = [0 10];
                    cstring = 'standard deviation: slip rate (mm/yr)';
                    cmap = 'parula';
                case 'st. err.'
                    ca = [0 5];
                    cstring = 'standard error: slip rate (mm/yr)';
                    cmap = 'parula';
                case 'coef. of var.'
                    ca = [0 1];
                    cstring = 'coefficient of variation: slip rate';
                    cmap = 'parula';
                case 'number of studies'
                    ca = [0 20];
                    cstring = 'number of studies per gridcell';
                    cmap = 'parula';
            end
    end
    if ~isempty(ca);
    caxis(ca);
    colormap(cmap);
    axes(Row.cAxis);
    caxis(ca);
    colormap(cmap);
    set(Row.ch,'visible','on');
    set(get(Row.ch,'xlabel'),'String',cstring);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Enable Geologic rate checkbox if appropriate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function EnableGeo(PlotVal,PlotMet)
    switch(PlotVal);
        case '< none >'
            set(Row.geoCheck,'Enable','off');
        case 'potency'
            set(Row.geoCheck,'Enable','off');
        otherwise
            switch(PlotMet);
                case 'mean'
                    set(Row.geoCheck,'Enable','on');
                case 'median'
                    set(Row.geoCheck,'Enable','on');
                otherwise
                    set(Row.geoCheck,'Enable','off');
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Draw Subplot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function DrawSub(gridIdx,PlotVal,PlotMet,whichplot)
    Sc = findobj(Row.mapAx,'Type','scatter');
    axes(Row.smallAxis);
    ClearSub
    gcell = [Row.C.c(Row.C.v(gridIdx,:),1),Row.C.c(Row.C.v(gridIdx,:),2)];
    nStudies = numel(Row.MasterGrid(:,1));
    ModelIx                 = get(Row.modelList,'Value') - 1;  
    barvec = zeros(nStudies,1);
    fs = get(Row.sorttext,'FontSize');
%     G = ReadGeologyStruct('./Geology.txt');
%     G = ReadGeologyStruct(fullfile(direc,'SlipRateComp','Geology.txt'));
    G = ReadGeologyStruct_new(geologyfile);
%     keyboard
    GeoGrid = [];
    for gg = 1:numel(gridIdx)
            gcell = [Row.C.c(Row.C.v(gridIdx(gg),:),1),Row.C.c(Row.C.v(gridIdx(gg),:),2)];
            IN = inpolygon(G.lon+360,G.lat,[gcell(:,1); gcell(1,1)],[gcell(:,2); gcell(1,2)]);
            theseG{gg} = find(IN);
    end
    IN = cell2mat(theseG');
    switch(PlotVal)
        case 'potency'
            M               = {Row.MasterGrid(ModelIx,gridIdx).potency};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)));
            barvec(ModelIx) = sum(M,2);

        case 'vxx'
            M               = {Row.MasterGrid(ModelIx,gridIdx).Dxx};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)));
            barvec(ModelIx) = mean(M,2);
%             if ~isempty(Sc);
%                 GeoGrid         = [G.Dxx(IN), G.Dxxmin(IN), G.Dxxmax(IN)]*1e3;
%             end
        
        case 'vyy'
            M               = {Row.MasterGrid(ModelIx,gridIdx).Dyy};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)));
            barvec(ModelIx) = mean(M,2);
            if ~isempty(Sc);
                GeoGrid         = [G.Dyy(IN), G.Dyymin(IN), G.Dyymax(IN)]*1e3;
            end
            
        case 'vxy'
            M               = {Row.MasterGrid(ModelIx,gridIdx).Dxy};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)));
            barvec(ModelIx) = mean(M,2);
%             if ~isempty(Sc);
%                 GeoGrid         = [G.Dxy(IN), G.Dxymin(IN), G.Dxymax(IN)]*1e3;
%             end
        
        case 'vyx'
            M               = {Row.MasterGrid(ModelIx,gridIdx).Dyx};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)));
            barvec(ModelIx) = mean(M,2);
%             if ~isempty(Sc);
%                 GeoGrid         = [G.Dyx(IN), G.Dyxmin(IN), G.Dyxmax(IN)]*1e3;
%             end
        case 'shear strain'
            
            M1              = {Row.MasterGrid(ModelIx,gridIdx).Dyx};
            M2              = {Row.MasterGrid(ModelIx,gridIdx).Dxy};
            M1              = cell2mat(reshape(M1,numel(ModelIx),numel(gridIdx)));
            M2              = cell2mat(reshape(M2,numel(ModelIx),numel(gridIdx)));
            M               = (1/2) * (M1 + M2);
            barvec(ModelIx) = mean(M,2);
            
        case 'rotation';
            M1              = {Row.MasterGrid(ModelIx,gridIdx).Dyx};
            M2              = {Row.MasterGrid(ModelIx,gridIdx).Dxy};
            M1              = cell2mat(reshape(M1,numel(ModelIx),numel(gridIdx)));
            M2              = cell2mat(reshape(M2,numel(ModelIx),numel(gridIdx)));
            M               = (1/2) * (M2 - M1);
            barvec(ModelIx) = mean(M,2);
            
            
        case 'PA/NA-parallel shear'
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastopen        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northopen        = mean(M,2);
            rotmat2         = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                               sin(Row.pbstrike)  cos(Row.pbstrike)];
            barvec0         = zeros(numel(eastshear),1);
            for kk          = 1:numel(eastshear)
                torotate = [eastopen(kk)    eastshear(kk); ...
                            northshear(kk)  northopen(kk)];
                pbrotated = rotmat2*torotate*rotmat2';
                barvec0(kk)  = pbrotated(2,1);
            end
            barvec(ModelIx)          = barvec0;
            if ~isempty(Sc);
                Gvalue = zeros(numel(G.lon),1);
                Gvaluemin = zeros(numel(G.lon),1);
                Gvaluemax = zeros(numel(G.lon),1);
                
                for ii = 1:numel(G.lon);
                    torotate = [G.Dxx(ii)    G.Dxy(ii); ...
                                G.Dyx(ii)    G.Dyy(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvalue(ii) = pbrotated(2,1);
                    
                    torotate = [G.Dxxmin(ii)    G.Dxymin(ii); ...
                                G.Dyxmin(ii)    G.Dyymin(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemin(ii) = pbrotated(2,1);
%                     Gvaluemin(ii) = (Gvalue(ii) - (G.strikeslip(ii) - G.strikeslipmin(ii))*1e3);
                    
                    torotate = [G.Dxxmax(ii)    G.Dxymax(ii); ...
                                G.Dyxmax(ii)    G.Dyymax(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemax(ii) = pbrotated(2,1);
%                     Gvaluemax(ii) = (Gvalue(ii) + (G.strikeslipmax(ii) - G.strikeslip(ii))*1e3);
                    
                end
                GeoGrid = [Gvalue(IN), Gvaluemin(IN), Gvaluemax(IN)]*1e3;
            end
            
        case 'PA/NA-perpendicular shear'
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastopen        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northopen        = mean(M,2);
            rotmat2         = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                               sin(Row.pbstrike)  cos(Row.pbstrike)];
            barvec0         = zeros(numel(eastshear),1);
            for kk          = 1:numel(eastshear)
                torotate = [eastopen(kk)    eastshear(kk); ...
                            northshear(kk)  northopen(kk)];
                pbrotated = rotmat2*torotate*rotmat2';
                barvec0(kk)  = pbrotated(1,2);
            end
            barvec(ModelIx)          = barvec0;
            if ~isempty(Sc);
                Gvalue = zeros(numel(G.lon),1);
                Gvaluemin = zeros(numel(G.lon),1);
                Gvaluemax = zeros(numel(G.lon),1);
                
                for ii = 1:numel(G.lon);
                    torotate = [G.Dxx(ii)    G.Dxy(ii); ...
                                G.Dyx(ii)    G.Dyy(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvalue(ii) = pbrotated(1,2);
                    
                    torotate = [G.Dxxmin(ii)    G.Dxymin(ii); ...
                                G.Dyxmin(ii)    G.Dyymin(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemin(ii) = pbrotated(1,2);
%                     Gvaluemin(ii) = (Gvalue(ii) - (G.strikeslip(ii) - G.strikeslipmin(ii))*1e3);
                    
                    torotate = [G.Dxxmax(ii)    G.Dxymax(ii); ...
                                G.Dyxmax(ii)    G.Dyymax(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemax(ii) = pbrotated(1,2);
%                     Gvaluemax(ii) = (Gvalue(ii) + (G.strikeslipmax(ii) - G.strikeslip(ii))*1e3);
                    
                end
                GeoGrid = [Gvalue(IN), Gvaluemin(IN), Gvaluemax(IN)]*1e3;
            end
            
        case 'PA/NA-parallel opening'
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastopen        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northopen        = mean(M,2);
            rotmat2         = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                               sin(Row.pbstrike)  cos(Row.pbstrike)];
            barvec0         = zeros(numel(eastshear),1);
            for kk          = 1:numel(eastshear)
                torotate = [eastopen(kk)    eastshear(kk); ...
                            northshear(kk)  northopen(kk)];
                pbrotated = rotmat2*torotate*rotmat2';
                barvec0(kk)  = pbrotated(2,2);
            end
            barvec(ModelIx)          = barvec0;
            
            if ~isempty(Sc);
                Gvalue = zeros(numel(G.lon),1);
                Gvaluemin = zeros(numel(G.lon),1);
                Gvaluemax = zeros(numel(G.lon),1);
                
                for ii = 1:numel(G.lon);
                    torotate = [G.Dxx(ii)    G.Dxy(ii); ...
                                G.Dyx(ii)    G.Dyy(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvalue(ii) = pbrotated(2,2);
                    
                    torotate = [G.Dxxmin(ii)    G.Dxymin(ii); ...
                                G.Dyxmin(ii)    G.Dyymin(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemin(ii) = pbrotated(2,2);
%                     Gvaluemin(ii) = (Gvalue(ii) - (G.strikeslip(ii) - G.strikeslipmin(ii))*1e3);
                    
                    torotate = [G.Dxxmax(ii)    G.Dxymax(ii); ...
                                G.Dyxmax(ii)    G.Dyymax(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemax(ii) = pbrotated(2,2);
%                     Gvaluemax(ii) = (Gvalue(ii) + (G.strikeslipmax(ii) - G.strikeslip(ii))*1e3);
                    
                end
                GeoGrid = [Gvalue(IN), Gvaluemin(IN), Gvaluemax(IN)]*1e3;
            end
           
        case 'PA/NA-perpendicular opening'
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northshear};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northshear        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).eastopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            eastopen        = mean(M,2);
            M               = {Row.MasterGrid(ModelIx,gridIdx).northopen};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            northopen        = mean(M,2);
            rotmat2         = [cos(Row.pbstrike) -sin(Row.pbstrike);...
                               sin(Row.pbstrike)  cos(Row.pbstrike)];
            barvec0         = zeros(numel(eastshear),1);
            for kk          = 1:numel(eastshear)
                torotate = [eastopen(kk)    eastshear(kk); ...
                            northshear(kk)  northopen(kk)];
                pbrotated = rotmat2*torotate*rotmat2';
                barvec0(kk)  = pbrotated(1,1);
            end
            barvec(ModelIx)          = barvec0;

            if ~isempty(Sc);
                Gvalue = zeros(numel(G.lon),1);
                Gvaluemin = zeros(numel(G.lon),1);
                Gvaluemax = zeros(numel(G.lon),1);
                
                for ii = 1:numel(G.lon);
                    torotate = [G.Dxx(ii)    G.Dxy(ii); ...
                                G.Dyx(ii)    G.Dyy(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvalue(ii) = pbrotated(1,1);
                    
                    torotate = [G.Dxxmin(ii)    G.Dxymin(ii); ...
                                G.Dyxmin(ii)    G.Dyymin(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemin(ii) = pbrotated(1,1);
%                     Gvaluemin(ii) = (Gvalue(ii) - (G.strikeslip(ii) - G.strikeslipmin(ii))*1e3);
                    
                    torotate = [G.Dxxmax(ii)    G.Dxymax(ii); ...
                                G.Dyxmax(ii)    G.Dyymax(ii)];
                    pbrotated = rotmat2*torotate*rotmat2';
                    Gvaluemax(ii) = pbrotated(1,1);
%                     Gvaluemax(ii) = (Gvalue(ii) + (G.strikeslipmax(ii) - G.strikeslip(ii))*1e3);
                    
                end
                GeoGrid = [Gvalue(IN), Gvaluemin(IN), Gvaluemax(IN)]*1e3;
            end
        
         
        case 'strike slip'
            M               = {Row.MasterGrid(ModelIx,gridIdx).ssRates};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            barvec(ModelIx) = mean(M,2);
            if ~isempty(Sc);
                GeoGrid = [G.strikeslip(IN), G.strikeslipmin(IN), G.strikeslipmax(IN)]*1e3;
            end
             
        case 'tensile slip'
            M               = {Row.MasterGrid(ModelIx,gridIdx).ssRates};
            M               = cell2mat(reshape(M,numel(ModelIx),numel(gridIdx)))*1e3;
            barvec(ModelIx) = mean(M,2);
            if ~isempty(Sc);
                GeoGrid = [G.tensileslip(IN), G.tensileslipmin(IN), G.tensileslipmax(IN)]*1e3;
            end
    end
    valueList               = get(Row.valueMenu,'String');
    valueVal                = get(Row.valueMenu,'Value');
    PlotVal                 = valueList{valueVal};
    if ~isempty(Sc);
        switch(PlotMet)
            case 'median'
                GeoGrid = [median(GeoGrid(:,1)) median(GeoGrid(:,2)) median(GeoGrid(:,3))];
            otherwise
                GeoGrid = [mean(GeoGrid(:,1)) mean(GeoGrid(:,2)) mean(GeoGrid(:,3))];
        end
    end
%     keyboard
    MakeBars(barvec,PlotVal,whichplot,GeoGrid);
    set(gca,'FontSize',fs);
    Row.subInfo         = gridIdx;
    Handles.Row         = Row;
    set(gcf, 'userdata', Handles);
%     keyboard
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Actual subplot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function MakeBars(barvec,PlotVal,whichplot,GeoGrid)
    axes(Row.smallAxis);
    n = numel(Row.MasterGrid(:,1));
    switch(whichplot)
        case 'Row.barButton'
            hold on;
            hp = [];
            if ~isempty(GeoGrid)
                for ii = 1:numel(GeoGrid(:,1))
                    x(ii,:) = 0:n+1;
                    y(ii,:) = GeoGrid(ii,1)*ones(size(x(ii,:)));
                    patchx = [x(ii,:) fliplr(x(ii,:))];
                    patchy = [GeoGrid(ii,2)*ones(size(x(ii,:))) GeoGrid(ii,3)*ones(size(x(ii,:)))];
                    patch(patchx,patchy,0.8*[1 1 1],'EdgeColor','none');
                    hp(ii) = plot(x(ii,:),y(ii,:),'--k');
                end
            end
            if ~isempty(barvec)
%                 bar(1:numel(barvec),barvec,'FaceColor',0.5*[1 1 1]);
                plot(1:numel(barvec),barvec,'dk','MarkerFaceColor',0.5*[1 1 1],'MarkerSize',8);
            else
%                 bar(1:numel(barvec),NaN);
                plot(1:numel(barvec),NaN);
            end
%             keyboard
            if sum(barvec)~=0
%                 keyboard
                ylimvec = [barvec; GeoGrid'; 0];
                xlim([0 numel(barvec)+1]);
                ymin = (min(ylimvec)-(min(ylimvec)*0.1));
                ymax = (max(ylimvec)+(max(ylimvec)*0.1));
%                 ymin = min([min(barvec) 0]);
%                 ymax = max([0 max(barvec)]);
%                 ylim([0 (max(barvec))])
                ylim([ymin ymax])
            end
            set(Row.smallAxis,'XTick',0:1:numel(barvec)+1);
            XTL0 = get(Row.smallAxis,'XTickLabel');
            XTL = XTL0;
            XTL(:) = {''};
            XTL(1:5:end) = XTL0(1:5:end);
            set(Row.smallAxis,'XTickLabel',XTL);
            xlabel('study');
            ylabel(sprintf('%s',PlotVal));
        case 'Row.histButton'
            hp = [];
            hold on;
            if ~isempty(GeoGrid)
                for ii = 1:numel(GeoGrid(:,1))
                    x(ii,:) = 0:n+1;
                    y(ii,:) = GeoGrid(ii,1)*ones(size(x(ii,:)));
                    
                    patchx = [x(ii,:) fliplr(x(ii,:))];
                    patchy = [GeoGrid(ii,2)*ones(size(x(ii,:))) GeoGrid(ii,3)*ones(size(x(ii,:)))];
                    
                    patch(patchy,patchx,0.8*[1 1 1],'EdgeColor','none');
                    hp(ii) = plot(y(ii,:),x(ii,:),'--k');
                end
            end
            if ~isempty(barvec)
                hist(nonzeros(barvec));
                h = findobj(gca,'Type','patch','FaceColor','flat');
                set(h,'FaceColor',0.5*[1 1 1]);
            else
                hist(NaN);
            end
            xlabel(sprintf('%s',PlotVal));
            ylabel('count');
            xlim('auto');
            ylim([0 n+1]);
    end
    Row.subplotvalue    = barvec;
    Row.GeoGrid         = GeoGrid;
    
    Handles.Row         = Row;
    set(gcf, 'userdata', Handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Plot Profile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function PlotProfile(point1, point2)
%         keyboard
        [px, py, I, J] = intersections([point1(1,1) point2(1,1)], [point1(1,2) point2(1,2)],Row.C.quickdraw(:,1)+360,Row.C.quickdraw(:,2)); % gives unique intersections
        
        startpoints = [Row.C.quickdraw(floor(J),1), Row.C.quickdraw(floor(J),2)];
        endpoints = [Row.C.quickdraw(ceil(J),1), Row.C.quickdraw(ceil(J),2)];
        
        [C, ia, ic]     = unique(Row.C.quickdraw, 'rows');
        gridIdx = [];
%         keyboard
        %%% Find startpoint and endpoint in the same rectangle
        for nn = 1:numel(startpoints(:,1));
            thisstart       = startpoints(nn,:);
            thisend         = endpoints(nn,:); 
            [Lia1,Locb1]    = ismember(thisstart, C, 'rows');
            [Lia2,Locb2]    = ismember(thisend, C, 'rows');
            matchstart = unique(ceil(find(ic==Locb1)/6),'stable');
            matchend   = unique(ceil(find(ic==Locb2)/6),'stable');
            rep             = ismember(matchstart,matchend);
            gridIdx = [gridIdx; matchstart(rep)];
        end
%         keyboard
        gridIdx = unique(gridIdx,'stable');
        
        IN1 = zeros(size(gridIdx));
        IN2 = zeros(size(gridIdx));
        
        for gg = 1:numel(gridIdx)
            gcell   = [Row.C.c(Row.C.v(gridIdx(gg),:),1),Row.C.c(Row.C.v(gridIdx(gg),:),2)];
%             line([gcell(:,1); gcell(1,1)],[gcell(:,2); gcell(1,2)],'Color','r','LineWidth',2);
            IN1(gg)             = inpolygon(point1(1,1),point1(1,2),gcell(:,1),gcell(:,2));
            IN2(gg)             = inpolygon(point2(1,1),point2(1,2),gcell(:,1),gcell(:,2));
            
        end
        
%         keyboard
        %%% Make sure we start and end in the correct order
        firstcell = gridIdx(logical(IN1));
        lastcell = gridIdx(logical(IN1));
        if sum(IN1) > 0;
        
        replacefirstcell = find(gridIdx == gridIdx(logical(IN1)));
        else 
            replacefirstcell = 1;
        end
        if sum(IN2) > 0;
        
        replacelastcell = find(gridIdx == gridIdx(logical(IN2)));
        else 
            replacelastcell = numel(gridIdx);
        end
        
        temp = gridIdx;
%         keyboard
        if isempty(temp);
            return
        end
        temp(1) = firstcell;
        temp(replacefirstcell) = gridIdx(1);
        temp(end) = lastcell;
        temp(replacelastcell) = gridIdx(end);
        
        if IN1(end) % if the first point is in the final gridcell, we are backwards. flip it.
            temp = flipud(temp);
        end
        gridIdx = temp;
        clear temp;
        
        if isfield(Row,'plotvalue')
        valueList               = get(Row.valueMenu,'String');
        valueVal                = get(Row.valueMenu,'Value');
        PlotVal                 = valueList{valueVal};
        metricList              = get(Row.metricMenu,'String');
        metricVal               = get(Row.metricMenu,'Value');
        PlotMet                 = metricList{metricVal};
        
        %%% If we are plotting slip rates or deformation gradients, we should look at uncertainty
        %%% too.
        [plottemp, plotvalue]   = GetPlotValue(PlotVal,PlotMet);
        plotvalue = zeros(numel(plottemp(:,1)),1);
        IF = isfinite(plottemp);
        ss = sum(IF,2);
        for ii = 1:numel(ss)
            if ss(ii) > 1;
                plotvalue(ii) = std(plottemp(ii,:),'omitnan');
            elseif ss(ii)<=1;
                plotvalue(ii) = NaN;
            end
        end
                    
%         px                      = [point1(1,1); px; point2(1,1)];
%         py                      = [point1(1,2); py; point2(1,2)];
        pdist0                  = ll2kmdist(point1(1,1), px, point1(1,2), py);
        pdistend                = ll2kmdist(point1(1,1),point2(1,1),point1(1,2),point2(1,2));
        pdist                   = [0; pdist0; pdistend];
        [gsort,gsix]            = sort([pdist0; pdistend]);
        [pdistsort, psix]       = sort(pdist,'ascend');
%         pdists                  = ll2kmdist(px(1:end-1), px(2:end), py(1:end-1), py(2:end));
%         keyboard
%         profdist = [0; cumsum(ll2kmdist(px(1:end-1), px(2:end), py(1:end-1), py(2:end)))];
%         profdist = [0; cumsum(ll2kmdist(px(1:end-1), px(2:end), py(1:end-1), py(2:end)))];
        profdist = pdistsort;
%         gridIdx = gridIdx(gsix);
% %         keyboard
        
        ClearSub
        axes(Row.smallAxis);
%         keyboard
        xpatch = [profdist(1:end-1) profdist(1:end-1) profdist(2:end) profdist(2:end) profdist(1:end-1)];
        xplot = [profdist(1:end-1) profdist(2:end)]';
        ybuff = zeros(numel(profdist)-1,1);
        yval = ybuff;
        sval = ybuff;
        allval = zeros(numel(ybuff),numel(plottemp(1,:)));
%         keyboard
        yval(1:numel(gridIdx)) = Row.plotvalue(gridIdx);
        if sum(IN1) == 0 && sum(IN2) == 0;
            %%% profile starts left of grid and ends right of grid
            yval(2:end-1) = Row.plotvalue(gridIdx); 
            sval(2:end-1) = plotvalue(gridIdx); 
            allval(2:end-1,:) = plottemp(gridIdx,:);
            
        elseif sum(IN1) == 0;
            %%% profile starts left of grid
            yval(end-numel(gridIdx)+1:end) = Row.plotvalue(gridIdx);
            sval(end-numel(gridIdx)+1:end) = plotvalue(gridIdx);
            allval(end-numel(gridIdx)+1:end,:) = plottemp(gridIdx,:);
            
        else
            %%% profile starts right of grid
            yval(1:numel(gridIdx)) = Row.plotvalue(gridIdx);
            sval(1:numel(gridIdx)) = plotvalue(gridIdx);
            allval(1:numel(gridIdx),:) = plottemp(gridIdx,:);
        end
        
        
        yplot = [yval yval]';
%         ayplot = [allval allval]';
        ypatch = [yval-sval yval+sval yval+sval yval-sval yval-sval];
%         keyboard
%         patch(xpatch',ypatch',1,'FaceColor',0.5*[1 1 1])
        axes(Row.smallAxis); hold on;
        patch(xpatch',ypatch',1,'FaceColor',0.8*[1 1 1],'EdgeColor',0.8*[1 1 1]);
        hold on; 
        
        for ss = 1:numel(plottemp(1,:))
            plot(xplot,[allval(:,ss) allval(:,ss)]','-','LineWidth',1,'Color',0.5*[1 1 1]);
        end
        plot(xplot,yplot,'-k','LineWidth',2);
        plot(xplot(:),yplot(:),':k','LineWidth',1);
        plot(0,0,'ok','MarkerFaceColor','w','MarkerSize',10);
        plot(xplot(end),0,'ok','MarkerFaceColor',0.5*[1 1 1],'MarkerSize',10);
        
%         keyboard
        xlabel('distance along profile (km)');
        ylabel(sprintf('%s',PlotVal));
        xlim([0 max(profdist)])
        ylim([min([min(ypatch) 0]) max([max(ypatch) 0])])
        Row.subplotvalue            = [profdist(2:end) yval];
        Row.subInfo                 = point1(:,1:2);
        Handles.Row = Row;
        set(gcf, 'userdata', Handles);
        set(gca,'SortMethod','childorder')
%         keyboard
        end
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Down Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ButtonDown(src,evnt)
%     setappdata(gcf, 'doneClick', 0); 
%     point1 = get(gca, 'CurrentPoint');
%     fprintf('Mouse click...');
%     keyboard
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Up Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ButtonUp(src,evnt)
   setappdata(gcf, 'doneClick', 1); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Clear and redraw Map axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ClearMap
        set(findall(gcf,'-property','Units'),'Units','norm');
        delete(Row.mapAx);
        set(Row.ch,'visible','off');
        fPos = get(gcf,'Position');
        fSize = [fPos(3:4) fPos(3:4)];
        Row.mapAx               = axes('parent',      gcf, 'units', 'norm', 'position', [0.046 0.291 0.44 0.678], 'visible', 'on', 'Tag', 'Row.mapAx', 'Layer', 'top', 'xlim', [0 360], 'ylim', [-90 90], 'nextplot', 'add');
        range                   = [233 248 32 43];
%         states                  = shaperead('usastatehi', 'UseGeoCoords', true, 'BoundingBox', [range(1:2)'-360, range(3:4)']); % plot statelines
        states                  = load('states.mat');
        states                  = states.states;
        FC                      = 0.7*[1 1 1];
        EC                      = 0.5*[1 1 1];
        PlotStates(states,FC,EC);
        hold on;
        for gg = 1:numel(Row.C.lon1);
            gcell               = [Row.C.c(Row.C.v(gg,:),1),Row.C.c(Row.C.v(gg,:),2)];
            patch(gcell(:,1),gcell(:,2),0,'FaceColor','none','EdgeColor',0.8*[1 1 1],'LineWidth',1);
        end
        Range.lon                    = [235 247];
        Range.lat                    = [32 43];
        Range.lonOld            = repmat(Range.lon, ul, 1);
        Range.latOld            = repmat(Range.lat, ul, 1);
        setappdata(gcf, 'Range', Range);
        SetAxes(Range);
        Handles.Row = Row;
        set(findall(gcf,'-property','Units'),'Units','norm');
        set(gcf, 'userdata', Handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Clear and redraw Small axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ClearSub
        P = get(Row.smallAxis,'Position');
        set(findall(gcf,'-property','Units'),'Units','norm');
        delete(Row.smallAxis);
        fn = get(Row.sorttext,'FontName');
        nDirs = numel(Row.listNames)-1;
        pPos = get(Row.smallPanel,'Position');
        pSize = [pPos(3:4) pPos(3:4)];
        Row.smallAxis           = axes('parent',      Row.smallPanel, 'units', 'norm', 'position', P, 'visible', 'on', 'Tag', 'Row.smallAxis', 'Layer', 'top', 'xlim', [0 nDirs], 'ylim', [0 100], 'FontName', fn);
        Handles.Row = Row;
        set(findall(gcf,'-property','Units'),'Units','norm');
        set(gcf, 'userdata', Handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  From statistics toolbox?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  From mapping toolbox?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% End RowlfFunctions
end