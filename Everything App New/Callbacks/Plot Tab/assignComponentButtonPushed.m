function []=assignComponentButtonPushed(src,text,parentText)

%% PURPOSE: ASSIGN A COMPONENT TO A PLOT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

%% Get the name of the current plot.
projectSettingsFile=getProjectSettingsFile();
projectSettings=loadJSON(projectSettingsFile);
Current_Plot_Name=projectSettings.Current_Plot_Name;
[name,id]=deText(Current_Plot_Name);
plotNamePI=[name '_' id];
plotPath=getClassFilePath(plotNamePI,'Plot');
plotStructPI=loadJSON(plotPath);

if exist('text','var')~=1 % Selecting a node
    selNode=handles.Plot.allComponentsUITree.SelectedNodes; % The object being assigned.

    if isempty(selNode)
        return;
    end

    text=selNode.Text; % Object text being assigned

    if isequal(text(1:11),'Axes_000000') % Assign axes to plot
        parentText=Current_Plot_Name;
        parentClass='Plot';
        parentObj=handles.Plot.plotUITree;
    else % Assign component to axes
        selCompNode=handles.Plot.plotUITree.SelectedNodes; % The object being assigned to.

        if isempty(selCompNode)
            return;
        end

        if ~isequal(selCompNode.Text(1:11),'Axes_000000')
            selCompNode=selCompNode.Parent;
        end

        parentText=selCompNode.Text;
        parentClass='Component';
        parentObj=selCompNode;
    end
end

% Create a new project-specific process version
[name,id,psid]=deText(text);

% Create a new project-specific process version
piText=[name '_' id];
slash=filesep;
fileNames=getClassFilenames('Component',[getProjectPath slash 'Project_Settings']);
psNames=fileNames(contains(fileNames,piText));
psTexts=fileNames2Texts(psNames);
if isempty(psid) && isempty(psTexts)
    isNew=true;
else
    isNew=false;
end

% PI node selected
if isempty(psid)
    if length(psTexts)==1
        compText=psTexts{1};
    elseif length(psTexts)>1
        disp('Multiple options, please select a project-specific option!');
        return;
    end
else
    compText=text;
end

piPath=getClassFilePath(piText,'Component');
piComponentStruct=loadJSON(piPath);

switch isNew
    case true
        componentStruct=createComponentStruct_PS(piComponentStruct);
    case false
        componentPath=getClassFilePath(compText,'Component');
        componentStruct=loadJSON(componentPath);
end

parentPath=getClassFilePath(parentText,parentClass);
parentStruct=loadJSON(parentPath);

% Check if applying a movie component to static plot
if plotStructPI.IsMovie==0 && piComponentStruct.IsMovie==1
    beep;
    disp('Cannot assign a dynamic component to a static plot!');
    return;
end

if plotStructPI.IsMovie==1 && piComponentStruct.IsMovie==0
    warning('Assigning static component to movie. This is permissible, just be aware!');
end

linkClasses(componentStruct,parentStruct);

newNode=uitreenode(parentObj,'Text',componentStruct.Text);
assignContextMenu(newNode,handles);
expand(parentObj);
handles.Plot.plotUITree.SelectedNodes=newNode;

if isNew
    newNode=uitreenode(selNode,'Text',componentStruct.Text);
    assignContextMenu(newNode,handles);
end