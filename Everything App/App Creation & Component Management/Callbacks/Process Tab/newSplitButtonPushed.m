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
okbox=uibutton(Q,'push','Text','OK','Position',[450 200 100 50],'ButtonPushedFcn',@(Q,event) okButtonPushedSplits(Q,0));
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

splitCode=genSplitCode(projectSettingsMATPath,selSplit,name); % Need to alter genSplitCode to be recursive
if isempty(splitCode)
    return;
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

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append'); % Save the struct back to file.