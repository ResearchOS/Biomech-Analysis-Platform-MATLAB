function []=specifyTrialsDropDownAddButtonPushed(src, event)

%% PURPOSE: ADD A SPECIFY TRIALS VERSION FOR THE CURRENT PROJECT.

% Check if the file exists at all, and also check if the current project exists in the file.

pguiFig=evalin('base','gui;');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectName=getappdata(pguiFig,'projectName');

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

specifyTrialsPath=getappdata(fig,'allProjectsSpecifyTrialsPath');
guiLocation=getappdata(fig,'guiLocation');

a=0;
while a==0
    vName=inputdlg('Enter Specify Trials Version Name');
    if isempty(vName)
        return;
    end
    vName=vName{1};
    if isvarname(vName)
        a=1;
    else
        disp('Invalid name. Must be valid MATLAB variable name!')
    end
end


if exist(specifyTrialsPath,'file')~=2
    % Text file does not exist at all. Create it and add this to file.

    text{1}=['Project Name: ' projectName];
    mName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash vName '_' projectName '_specifyTrials.m'];
    text{2}=[guiLocation ': ' mName];

    if exist([getappdata(pguiFig,'codePath') 'SpecifyTrials'],'dir')~=7
        mkdir([getappdata(pguiFig,'codePath') 'SpecifyTrials']);
    end

    fcnText{1}=['function [inclStruct]=' vName '_' projectName '_specifyTrials()'];

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s',fcnText{1});
    fclose(fid);

    return;

end

% Here, the .txt file exists. Check if the current project exists.
text=readSpecifyTrials(getappdata(pguiFig,'everythingPath'));
projectList=getAllProjectNames(text);
numLines=length(text);

if ~ismember(projectName,projectList)
    % New project

    
    text{numLines+2}=['Project Name: ' getappdata(pguiFig,'projectName')];
    mName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash vName '_' projectName '_specifyTrials.m'];
    text{numLines+3}=[guiLocation ': ' mName];

    if exist([getappdata(pguiFig,'codePath') 'SpecifyTrials'],'dir')~=7
        mkdir([getappdata(pguiFig,'codePath') 'SpecifyTrials']);
    end

    fcnText{1}=['function [inclStruct]=' vName '_' projectName '_specifyTrials()'];

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s',fcnText{1});
    fclose(fid);

    return;

else
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

        if isempty(text{i}) || i==numLines
            currLine=i;
            if i==numLines
                currLine=currLine+1;
            end
            break; % Done with the current project.
        end

    end

    newText=text(1:currLine-1);
    % Search through newText to remove the guiLocation label from the previous path.
    for i=1:length(newText)

        if isequal(newText{i}(1:length(guiLocation)),guiLocation)
            charStartIdx=strfind(newText{i},':')+2;
            newText{i}=newText{i}(charStartIdx(1):end);
            break;
        end

    end

    if exist([getappdata(pguiFig,'codePath') 'SpecifyTrials'],'dir')~=7
        mkdir([getappdata(pguiFig,'codePath') 'SpecifyTrials']);
    end

    mName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash vName '_' projectName '_specifyTrials.m'];
    newText{currLine}=[guiLocation ': ' mName];
    newText=[newText; text(currLine:end)];

    fcnText{1}=['function [inclStruct]=' vName '_' projectName '_specifyTrials()'];

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',newText{1:end-1});
    fprintf(fid,'%s',newText{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s',fcnText{1});
    fclose(fid);

end

handles.Top.specifyTrialsDropDown.Items=[handles.Top.specifyTrialsDropDown.Items {vName}];
handles.Top.specifyTrialsDropDown.Value=vName;

specifyTrialsVersionDropDownValueChanged(handles.Top.specifyTrialsDropDown);