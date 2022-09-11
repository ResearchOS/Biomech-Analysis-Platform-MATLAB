function []=newSplitButtonPushed(src,splitName,splitColorName,splitCode,parentSplitName,parentSplitCode)

%% PURPOSE: CREATE A NEW SPLIT, WHETHER FOR EXISTING OR NEW FUNCTIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% 1. Prompt the user for the name of the new split.
while true

    if exist('splitName','var')~=1
        name=inputdlg('Enter Split Name','New Split Name');
        runLog=true;
    else
        name={splitName};
        runLog=false;
    end

    if isempty(name)
        return;
    end

    name=name{1};

    if isvarname(name)
        break;
    end

    disp('Split name must be valid MATLAB variable name!');

end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

%% 2. Select the edge color for this split
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'NonFcnSettingsStruct','Digraph');
NonFcnSettingsStruct=getappdata(fig,'NonFcnSettingsStruct');
Digraph=getappdata(fig,'Digraph');
load([getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'RGB XKCD - Custom' slash 'xkcd_rgb_data.mat'],'rgblist','colorlist');
if runLog
    Q=uifigure('Name',['Select Color for Split: ' name]);
    colorlist=colorlist(2:end); % Remove license row
    rgblist=rgblist(2:end,:);
    [~,idx]=sort(colorlist);
    colorlist=colorlist(idx); % Sort alphabetically
    rgblist=rgblist(idx,:);
    % Remove all previously used colors. STILL ONLY HALFWAY DONE
    if ~isempty(Digraph.Edges)
        usedColorsIdx=ismember(round(rgblist,3),round(Digraph.Edges.Color,3),'rows');
    else
        usedColorsIdx=false(size(rgblist,1),1);
    end
    rgblist=rgblist(~usedColorsIdx,:);
    colorlist=colorlist(~usedColorsIdx,:);
    lb=uilistbox(Q,'Items',colorlist,'Position',[10 10 150 350],'ValueChangedFcn',@(Q,event) lbValChanged(Q,rgblist));
    lb.Value=colorlist{1};
    ax=uiaxes(Q,'XLim',[0 1],'YLim',[0 1],'Position',[200 10 200 350]);
    patchObj=patch(ax,[0 0 1 1],[0 1 1 0],[1 1 1]);
    ax.XTickLabel={};
    ax.YTickLabel={};
    ax.XTick=[];
    ax.YTick=[];
    ax.LineWidth=0.01;

    okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushed(Q));
    Qhandles.lb=lb;
    Qhandles.ax=ax;
    Qhandles.okbox=okbox;
    Qhandles.patch=patchObj;
    setappdata(Q,'handles',Qhandles);
    lbValChanged(Q,rgblist);
    uiwait(Q);
    try
        splitColor=evalin('base','splitColor;');
    catch
        return; % The process was aborted.
    end
    evalin('base','clear splitColor;');
    colorIdx=ismember(round(rgblist,3),round(splitColor,3));
    splitColorName=colorlist{colorIdx};
else
    colorIdx=ismember(colorlist,splitColorName);
    splitColor=rgblist(colorIdx,:);
end

%% 3. Explicitly ask the user which split this is branching from
splits=NonFcnSettingsStruct.Process.Splits;

if runLog
    Q=uifigure('Name',['Select Prior Split for ' name]);
    Qhandles.uitree=uitree(Q,'checkbox','Tag','Tree');
    okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushedSplits(Q));
    Qhandles.okbox=okbox;
    setappdata(Q,'handles',Qhandles);

    rootTag='Stop';
    rootNode=uitreenode(Qhandles.uitree,'Text','Root (Not a Split)','Tag',rootTag);

    getSplitNames(splits,[],rootNode);
    uiwait(Q);
    try
        selSplit=evalin('base','selSplit;'); % 1st entry is the root split, last entry is the split to branch off of.
    catch
        return; % The process was aborted.
    end
    evalin('base','clear selSplit;');
    selSplit=selSplit(~ismember(selSplit,'Root'));
    if ~isempty(selSplit)
        parentSplitName=selSplit{end}; % There is a parent split
    else
        parentSplitName='Root'; % Top-level split
    end

    splitCode=genSplitCode(fig,projectSettingsMATPath,selSplit,name); % Need to alter genSplitCode to be recursive
    if isempty(splitCode)
        return;
    end
else
    tree=handles.Process.splitsUITree;   
    if isequal(parentSplitName,'Root')
        parentNode=tree;
    else
        parentNode=findobj(handles.Process.splitsUITree,'Text',parentSplitName);
    end    
    uitreenode(parentNode,'Text',[splitName ' (' splitCode ')']);       
    selSplit={[splitName '_' splitCode]};
    while ~ismember(class(parentNode),{'matlab.ui.container.CheckboxTree','matlab.ui.container.Tab'})
        parentNode=parentNode.Parent;
        if ismember(class(parentNode),{'matlab.ui.container.CheckboxTree','matlab.ui.container.Tab'})
            break;
        end
        selSplit=[{parentNode.Text}; selSplit];
    end
    selSplit=selSplit(~ismember(selSplit,'Root'));
    selSplit=selSplit(~ismember(selSplit,selSplit{end}));
end

% Add the new split to the struct, using eval.
structPath='NonFcnSettingsStruct.Process.Splits';
for i=1:length(selSplit)
    structPath=[structPath '.SubSplitNames.' selSplit{i} ''];
end

eval([structPath '.SubSplitNames.' name '.Color=[' num2str(splitColor(1)) ' ' num2str(splitColor(2)) ' ' num2str(splitColor(3)) '];']);
eval([structPath '.SubSplitNames.' name '.Code=''' splitCode ''';']);
eval([structPath '.SubSplitNames.' name '.Name=''' name ''';']);

splits=NonFcnSettingsStruct.Process.Splits;

delete(handles.Process.splitsUITree.Children);
getSplitNames(splits,[],handles.Process.splitsUITree);

% save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.
setappdata(fig,'NonFcnSettingsStruct',NonFcnSettingsStruct);

if runLog
    desc='Created a new split';
    splitName=name;
%     updateLog(fig,desc,splitName,splitColorName,splitCode,parentSplitName,parentSplitCode);
end