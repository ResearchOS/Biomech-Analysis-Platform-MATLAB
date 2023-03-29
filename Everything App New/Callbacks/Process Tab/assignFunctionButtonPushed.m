function []=assignFunctionButtonPushed(src,text,parentText)

%% PURPOSE: ASSIGN PROCESSING FUNCTION TO THE CURRENT PROCESSING GROUP

% text: A Process class object
% parentText: A ProcessGroup class object

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('text','var')~=1 % Selecting a node
    selNode=handles.Process.allProcessUITree.SelectedNodes;

    if isempty(selNode)
        return;
    end

    processName=selNode.Text;

    % Create a new project-specific process version
    if (isequal(selNode.Parent,handles.Process.allProcessUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
        isNew=true;
    else
        isNew=false;
    end

    % PI node selected
    if isequal(selNode.Parent,handles.Process.allProcessUITree)
        if length(selNode.Children)==1
            selNode=selNode.Children(1);
        elseif length(selNode.Children)>1
            disp('Multiple options, please select a project-specific option!');
            expand(selNode);
            return;
        end
    end
else

    % Create a new project-specific process version
    [name,id,psid]=deText(text);

    % Create a new project-specific process version
    piText=[name '_' id];
    slash=filesep;
    fileNames=getClassFilenames('Process',[getCommonPath slash 'Process' slash 'Implementations']);
    psNames=fileNames(contains(fileNames,piText));
    if isempty(psid) && isempty(psNames)
        isNew=true;
    else
        isNew=false;
    end

    % PI node selected
    if isempty(psid)
        if length(psNames)==1
            processName=psNames{1}; % Without project-specific ID.
        elseif length(psNames)>1
            disp('Multiple options, please select a project-specific option!');
            return;
        end
    else
        processName=text;
    end
end

if exist('parentText','var')~=1
    projectSettingsFile=getProjectSettingsFile();
    projectSettings=loadJSON(projectSettingsFile);
    Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
else
    Current_ProcessGroup_Name=parentText;
end

% Get the currently selected group struct.
fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
groupStruct=loadJSON(fullPath);

% List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% column is the name
names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
types=groupStruct.ExecutionListTypes;

switch isNew
    case true
        processPath=getClassFilePath(processName, 'Process');
        piStruct=loadJSON(processPath);
        processStruct=createProcessStruct_PS(piStruct);
    case false
        processPath=getClassFilePath_PS(processName, 'Process');
        processStruct=loadJSON(processPath);
end

names=[names; {processStruct.Text}];
types=[types; {'Process'}];

groupStruct.ExecutionListNames=names;
groupStruct.ExecutionListTypes=types;

linkClasses(processStruct, groupStruct); % Also saves the structs



 









% fig=ancestor(src,'figure','toplevel');
% handles=getappdata(fig,'handles');
% 
% selNode=handles.Process.allProcessUITree.SelectedNodes;
% 
% if isempty(selNode)
%     return;
% end
% 
% % Create a new project-specific process version
% if (isequal(selNode.Parent,handles.Process.allProcessUITree) && isempty(selNode.Children)) % Special case where there are no existing PS versions.
%     isNew=true;
% else
%     isNew=false;
% end
% 
% % PI node selected
% if isequal(selNode.Parent,handles.Process.allProcessUITree)
%     if length(selNode.Children)==1
%         selNode=selNode.Children(1);
%     elseif length(selNode.Children)>1
%         disp('Multiple options, please select a project-specific option!');
%         expand(selNode);
%         return;
%     end
% end
% 
% projectSettingsFile=getProjectSettingsFile();
% projectSettings=loadJSON(projectSettingsFile);
% Current_ProcessGroup_Name=projectSettings.Current_ProcessGroup_Name;
% 
% % Get the currently selected group struct.
% fullPath=getClassFilePath_PS(Current_ProcessGroup_Name,'ProcessGroup');
% groupStruct=loadJSON(fullPath);
% 
% % List is a Nx2, with the first column being "Process" or "ProcessGroup", 2nd
% % column is the name
% names=groupStruct.ExecutionListNames; % Execute these functions/groups in this order.
% types=groupStruct.ExecutionListTypes;
% 
% processName=selNode.Text; % Without project-specific ID.
% 
% switch isNew
%     case true
%         processPath=getClassFilePath(processName, 'Process');
%         piStruct=loadJSON(processPath);
%         processStruct=createProcessStruct_PS(piStruct);
%     case false
%         processPath=getClassFilePath_PS(selNode.Text, 'Process');
%         processStruct=loadJSON(processPath);
% end
% 
% names=[names; {processStruct.Text}];
% types=[types; {'Process'}];
% 
% groupStruct.ExecutionListNames=names;
% groupStruct.ExecutionListTypes=types;
% 
% linkClasses(processStruct, groupStruct); % Also saves the structs

if ~isequal(groupStruct.Text,handles.Process.currentGroupLabel.Text)
    return;
end

newNode=uitreenode(handles.Process.groupUITree,'Text',processStruct.Text);
newNode.ContextMenu=handles.Process.psContextMenu;
newNode.NodeData.Class='Process';

if isNew
    uitreenode(selNode,'Text',processStruct.Text,'ContextMenu',handles.Process.psContextMenu);
end