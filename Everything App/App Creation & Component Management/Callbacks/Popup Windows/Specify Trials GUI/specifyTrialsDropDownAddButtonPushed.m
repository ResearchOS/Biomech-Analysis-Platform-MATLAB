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
if evalin('base','exist(''ignoreInputToAddSpecifyTrials'',''var'')')
    a=1;
    vName=evalin('base','vNameToAddSpecifyTrials;');
end
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
    fcnText{2}='inclStruct=0;';

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s\n',fcnText{1:end-1});
    fprintf(fid,'%s',fcnText{end});
    fclose(fid);

    % Change the drop down items & value
    handles.Top.specifyTrialsDropDown.Items={vName};

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
    fcnText{2}='inclStruct=0;';

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',text{1:end-1});
    fprintf(fid,'%s',text{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s\n',fcnText{1:end-1});
    fprintf(fid,'%s',fcnText{end});
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

    if ~exist('currLine','var')
        currLine=numLines+1;
    end

    newText=text(1:currLine-1);
    % Search through newText to remove the guiLocation label from the previous path.
    currProj=0;
    for i=1:length(newText)

        if length(text{i})>=length(projLine) && isequal(text{i}(1:length(projLine)),projLine)
            currProj=1;
            continue;
        end

        if currProj==0
            continue;
        end

        if length(newText{i})>=length(guiLocation) && isequal(newText{i}(1:length(guiLocation)),guiLocation)
            colonIdx=strfind(newText{i},':');
            beforeColon=newText{i}(1:colonIdx(1)-1);
            % Parse the text to only remove one gui location, if multiple
            beforeColonSplit=strsplit(beforeColon,', ');
            newBeforeColon='';
            newCount=0;
            for j=1:length(beforeColonSplit)

                if isequal(beforeColonSplit{j},guiLocation)
                    continue;
                end

                newCount=newCount+1;

                if newCount>1
                    newBeforeColon=[newBeforeColon ', ' beforeColonSplit{j}];
                else
                    newBeforeColon=beforeColonSplit{j};
                end

            end

            newText{i}=newBeforeColon;
            newText{i}=[newText{i} text{i}(colonIdx(1):end)];
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
    fcnText{2}='inclStruct=0;';

    % Save the .txt file.
    fid=fopen(specifyTrialsPath,'w');
    fprintf(fid,'%s\n',newText{1:end-1});
    fprintf(fid,'%s',newText{end});
    fclose(fid);

    % Save the .m file.
    fid=fopen(mName,'w');
    fprintf(fid,'%s\n',fcnText{1:end-1});
    fprintf(fid,'%s',fcnText{end});
    fclose(fid);

end

handles.Top.specifyTrialsDropDown.Items=[handles.Top.specifyTrialsDropDown.Items {vName}];
handles.Top.specifyTrialsDropDown.Value=vName;

handles.Include.conditionDropDown.Items={'Add Condition Name'};
handles.Exclude.conditionDropDown.Items={'Add Condition Name'};

specifyTrialsVersionDropDownValueChanged(handles.Top.specifyTrialsDropDown);

end % End function