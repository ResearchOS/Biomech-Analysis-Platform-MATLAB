function []=newSplitButtonPushed(src,event)

%% PURPOSE: CREATE A NEW SPLIT, WHETHER FOR EXISTING OR NEW FUNCTIONS

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% 1. Prompt the user for the name of the new split.
while true

    name=inputdlg('Enter Split Name','New Split Name');
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
load([getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'RGB XKCD - Custom' slash 'xkcd_rgb_data.mat'],'rgblist','colorlist');
Q=uifigure('Name',['Select Color for Split: ' name]);
colorlist=colorlist(2:end); % Remove license row
rgblist=rgblist(2:end,:);
[~,idx]=sort(colorlist);
colorlist=colorlist(idx); % Sort alphabetically
rgblist=rgblist(idx,:);
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

%% 3. Explicitly ask the user which split this is branching from
projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'NonFcnSettingsStruct','Digraph');
splits=NonFcnSettingsStruct.Process.Splits;
% splits.SubSplitNames.test1.SubSplitNames.test2.SubSplitNames=struct; % Testing
% splits.SubSplitColors.test1.Color=[1 0 0];
% splits.SubSplitNames.test1.SubSplitColors.test2.Color=[0 1 0];
% splits.SubSplitNames.test1.SubSplitNames.test3.SubSplitNames=struct;
% splits.SubSplitNames.test1.SubSplitColors.test3.Color=[0 0 1];
% splits.SubSplitNames.test4.SubSplitNames.test5.SubSplitNames=struct;
% splits.SubSplitColors.test4.Color=[0 0 0];
% splits.SubSplitNames.test4.SubSplitNames.test6.SubSplitNames=struct;
% splits.SubSplitNames.test4.SubSplitColors.test5.Color=[0 0.8 0.4];
% splits.SubSplitNames.test4.SubSplitColors.test6.Color=[0.1 0.5 0.3];

Q=uifigure('Name',['Select Prior Split for ' name]);
Qhandles.uitree=uitree(Q,'checkbox','Tag','Tree');
okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushedSplits(Q));
Qhandles.okbox=okbox;
setappdata(Q,'handles',Qhandles);

getSplitNames(splits,[],Qhandles.uitree);
uiwait(Q);
try
    selSplit=evalin('base','selSplit;'); % 1st entry is the root split, last entry is the split to branch off of.
catch
    return; % The process was aborted.
end
evalin('base','clear selSplit;');

% splitCode=genSplitCode(projectSettingsMATPath,name); % Need to alter genSplitCode to be recursive
splitCode='002';
NonFcnSettingsStruct.Process.Splits=addToStruct(NonFcnSettingsStruct.Process.Splits,selSplit,name,splitColor,splitCode);

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.


%% 4. Ask the user which function on that branch this is branching from
% nodeNums=0;
% nodeCount=0;
% fcnNames={''};
% for i=1:length(Digraph.Nodes.FunctionNames)
%     currSplitNames=Digraph.Nodes.SplitNames{i};
% 
%     if all(ismember(selSplit,currSplitNames))
%         nodeCount=nodeCount+1;
%         nodeNums(nodeCount)=Digraph.Nodes.NodeNumber(i);
%         fcnNames{nodeCount}=Digraph.Nodes.FunctionNames{i};
%     end
% 
% end
% 
% [sel,ok]=listdlg('PromptString','Select Fcn to Split From','ListString',fcnNames,'SelectionMode','single');
% nodeNum=nodeNums(sel);

%% 5. Select whether the branch is one of the following:
% a. A duplicate arrow between the same functions (i.e. only inputs are changing, all function nodes are the same)
% b. Place one new function to start the new split
% c. Copy one or more functions (and their inputs & outputs) to a new location to start the new split


%% 6. Create the new node(s), and initialize them with the split name and dependent splits names.

% 
% NonFcnSettingsStruct.Process.Splits.(name).Code=genSplitCode(projectSettingsMATPath,name);