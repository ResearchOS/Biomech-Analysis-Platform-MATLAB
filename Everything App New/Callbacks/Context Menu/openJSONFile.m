function []=openJSONFile(src,event)

%% PURPOSE: OPEN JSON FILE FOR THE SELECTED NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

[name,id,psid]=deText(selNode.Text);

if ~isempty(psid)
    isPS=true;   
    text=[name '_' id '_' psid];    
else
    isPS=false;    
    text=[name '_' id];
end

uiTree=getUITreeFromNode(selNode);

switch uiTree
    case handles.Projects.allProjectsUITree
        classType='Project';
    case handles.Import.allLogsheetsUITree
        classType='Logsheet';
    case handles.Process.allProcessUITree
        classType='Process';
    case handles.Process.groupUITree
        classType='Process';
    case handles.Process.functionUITree
        classType='Variable';
    case handles.Plot.allPlotsUITree
        classType='Plot';
    case handles.Plot.allComponentsUITree
        classType='Component';
    case handles.Process.allGroupsUITree
        classType='ProcessGroup';
    case handles.Process.allVariablesUITree
        classType='Variable';
    case handles.Import.allSpecifyTrialsUITree
        classType='SpecifyTrials';
    case handles.Process.allSpecifyTrialsUITree
        classType='SpecifyTrials';
    case handles.Plot.plotUITree
        classType='Component';    
    case handles.Stats.allStatsUITree
        classType='Stats';
end

fullPath=getClassFilePath(text, classType);

if exist(fullPath,'file')~=2
    a=questdlg('File does not exist. Create it?','Missing file','Yes','No','Cancel','No');    
    if ismember(a,{'No','Cancel'})
        return;
    end

    if isPS        
        piText=getPITextFromPS(selNode.Text);
        piPath=getClassFilePath(piText, classType);
        [name,id,psid]=deText(selNode.Text);
        if exist(piPath,'file')~=2
            piStruct=feval(['create' classType 'Struct'],name,id);
        else
            piStruct=loadJSON(piPath);
        end

        feval(['create' classType 'Struct_PS'],piStruct,psid);
    else    
        [name,id]=deText(selNode.Text);
        piStruct=feval(['create' classType 'Struct'],name,id);
    end    

end

if ispc==1
    winopen(fullPath);
    return;
end

%% For Mac.
spaceSplit=strsplit(fullPath,' ');

newPath='';
for i=1:length(spaceSplit)
    if i>1        
        mid='\ ';
    else
        mid='';
    end
    newPath=[newPath mid spaceSplit{i}];
end

system(['open ' newPath]);