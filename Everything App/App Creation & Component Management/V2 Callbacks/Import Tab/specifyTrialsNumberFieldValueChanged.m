function []=specifyTrialsNumberFieldValueChanged(src,event)

%% PURPOSE: SPECIFY WHICH SET OF TRIALS TO IMPORT THE DATA

fig=ancestor(src,'figure','toplevel');
hSpecifyTrialsNumberField=findobj(fig,'Type','uieditfield','Tag','SpecifyTrialsNumberField');
num=hSpecifyTrialsNumberField.Value;

if isempty(num)
    return;
end

if ~all(isstrprop(num,'digit'))
    disp('Numbers only!');
    return;
end

if ismac==1
    slash='/';
elseif ispc==1
    slash='\';
end

prefix='Specify Trials Number:';
text=readAllProjects(getappdata(fig,'everythingPath'));
[text]=addProjInfoToFile(text,getappdata(fig,'projectName'),prefix,num,0);

% Change the specifyTrials number on the button
hSpecifyTrialsImportButton=findobj(fig,'Type','uibutton','Tag','OpenSpecifyTrialsButton');
% currText=hSpecifyTrialsImportButton.Text;
if exist([getappdata(fig,'codePath') 'Import_' getappdata(fig,'projectName') slash 'Specify Trials' slash 'specifyTrials_Import' num '.m'],'file')==2 % Open
    newText=['Open specifyTrials_Import' num '.m'];
else % Create
    newText=['Create specifyTrials_Import' num '.m'];
end
hSpecifyTrialsImportButton.Text=newText;

% Save the text file
fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);