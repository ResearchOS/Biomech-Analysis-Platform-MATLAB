function []=specifyTrialsButtonPushed(src)

%% PURPOSE: OPEN THE FUNCTION'S SPECIFY TRIALS FILE

fig=ancestor(src,'figure','toplevel');

currTag=src.Tag;

if ~isletter(currTag(end-1)) % 2 digits
    currRow=str2double(currTag(end-1:end));
else % 1 digit
    currRow=str2double(currTag(end));
end

hArgsButton=findobj(fig,'Type','uibutton','Tag',['FcnArgsButton' num2str(currRow)]);

fcnButton=findobj(fig,'Type','uibutton','Tag',['OpenFcnButton' num2str(currRow)]);
fcnName=fcnButton.Text;

% Get the list of function names in this group so that I can most accurately get the number & letter
hRunDropDown=findobj(fig,'Type','uidropdown','Tag','RunGroupNameDropDown');
groupName=hRunDropDown.Value;

% Read the text file
[text]=readFcnNames(getappdata(fig,'fcnNamesFilePath'));
[groupNames,lineNums]=getGroupNames(text);
groupIdx=ismember(groupNames,groupName);
lineNum=lineNums(groupIdx);

% Get the list of function names in the group
fcnCount=0;
for i=lineNum+1:length(text)
    
    if isempty(text{i})
        break; % Finished with this group
    end

    a=strsplit(text{i},':');
    fcnNameCell=strsplit(a{1},' ');
    fcnCount=fcnCount+1;
    if isequal(fcnCount,currRow)
        fcnName=[fcnNameCell{1} '_Process' fcnNameCell{2}(~isletter(fcnNameCell{2}))];
        break;
    end
    
end


specifyTrialsName=[fcnName hArgsButton.Text '_SpecifyTrials.m']; % fcnName_Process#Letter_SpecifyTrials

if ismac==1
    slash='/';
else
    slash='\';
end

if exist([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Function'],'dir')~=7
    mkdir([getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Function']);
end

specifyTrialsPath=[getappdata(fig,'codePath') 'Process_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'Per Function' slash specifyTrialsName];
if exist(specifyTrialsPath,'file')==2
    edit(specifyTrialsPath);
    return;
end

% If the file does not exist yet, create it from the template.
templatePath=[getappdata(fig,'everythingPath') 'App Creation & Component Management' slash 'Project-Independent Templates' slash 'specifyTrials_Template.m'];

firstLine=['function [inclStruct]=' specifyTrialsName(1:end-2) '()'];
createFileFromTemplate(templatePath,specifyTrialsPath,firstLine)