function []=specifyTrialsDropDownRemoveButtonPushed(src, event)

%% PURPOSE: REMOVE A SPECIFY TRIALS VERSION FROM THE CURRENT PROJECT.

% Check if the file exists at all, and also check if the current project exists in the file.

pguiFig=evalin('base','gui;');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=getappdata(pguiFig,'projectName');

if length(handles.Top.specifyTrialsDropDown.Items)==1
    disp('Only one specify trials version in list!');
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

specifyTrialsPath=getappdata(fig,'allProjectsSpecifyTrialsPath');
% guiLocation=getappdata(fig,'guiLocation');

if exist(specifyTrialsPath,'file')~=2
    return;
end

% Here, the .txt file exists. Check if the current project exists.
text=readSpecifyTrials(getappdata(pguiFig,'everythingPath'));
projectList=getAllProjectNames(text);
numLines=length(text);

if ~ismember(projectName,projectList)
    return; % Nothing to delete.
end

a=inputdlg(['Confirm that you want to delete the specify trials version by typing its name: ' handles.Top.specifyTrialsDropDown.Value]);

if isempty(a)
    return;
end

if ~isequal(a{1},handles.Top.specifyTrialsDropDown.Value)
    disp(['Mismatched entry, no deletion performed. Specify trials version name: ' handles.Top.specifyTrialsDropDown.Value]);
    disp(['You entered: ' a{1}]);
    return;
end

% Current project exists
currProj=0;

for i=1:numLines
    projLine=['Project Name: ' getappdata(pguiFig,'projectName')];

    if length(text{i})>=length(projLine) && isequal(text{i}(1:length(projLine)),projLine)
        currProj=1;
        continue;
    end

    if currProj~=1
        continue;
    end

    if currProj==1 && isempty(text{i})
        break;
    end

    splitLine=strsplit(text{i},slash);
    vName=strsplit(splitLine{end},['_' projectName]);
    vName=vName{1}; % Isolate the version name.

    if isequal(vName,a{1})
        newText=text(1:i-1);
        if i<numLines
            newText=[newText text(i+1:end)];
        end
        break;
    end

end

mName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash vName '_' projectName '_specifyTrials.m'];

% Save the .txt file.
fid=fopen(specifyTrialsPath,'w');
fprintf(fid,'%s\n',newText{1:end-1});
fprintf(fid,'%s',newText{end});
fclose(fid);

% Delete the .m file.
delete(mName);

handles.Top.specifyTrialsDropDown.Items=handles.Top.specifyTrialsDropDown.Items(~ismember(handles.Top.specifyTrialsDropDown.Items,vName));
handles.Top.specifyTrialsDropDown.Value=handles.Top.specifyTrialsDropDown.Items{1};

specifyTrialsVersionDropDownValueChanged(handles.Top.specifyTrialsDropDown);
