function []=specifyTrialsDropDownAddButtonPushed(src, event)

%% PURPOSE: ADD A SPECIFY TRIALS VERSION FOR THE CURRENT PROJECT.

% Check if the file exists at all, and also check if the current project exists in the file.

pguiFig=evalin('base','gui;');

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

% projectName=getappdata(pguiFig,'projectName');

while true
    verName=inputdlg('Enter Specify Trials Version Name');
    if isempty(verName) || isempty(verName{1})
        return;
    end

    verName=verName{1};

    if isvarname(verName)
        break;
    end

    disp('Invalid name. Must be valid MATLAB variable name!');

end

slash=filesep;

%% If the name entered already exists, just update the GUI but don't create any files.
verFileName=[getappdata(pguiFig,'codePath') 'SpecifyTrials' slash verName '.m'];

if exist([getappdata(pguiFig,'codePath') 'SpecifyTrials'],'dir')~=7
    mkdir([getappdata(pguiFig,'codePath') 'SpecifyTrials']);
end

if isequal('Add Specify Trials Version',handles.Top.specifyTrialsDropDown.Items{1})
    handles.Top.specifyTrialsDropDown.Items={verName};
else
    handles.Top.specifyTrialsDropDown.Items=[handles.Top.specifyTrialsDropDown.Items {verName}];
end
handles.Top.specifyTrialsDropDown.Value=verName;

handles.Include.conditionDropDown.Items={'Add Condition Name'};
handles.Exclude.conditionDropDown.Items={'Add Condition Name'};

if exist(verFileName,'file')~=2
    firstLine{1}=['function [inclStruct]=' verName '()'];
    firstLine{2}='inclStruct=0;';

    fid=fopen(verFileName,'w');
    fprintf(fid,'%s\n',firstLine{1:end-1});
    fprintf(fid,'%s',firstLine{end});
    fclose(fid);

end

specifyTrialsVersionDropDownValueChanged(handles.Top.specifyTrialsDropDown);

end % End function