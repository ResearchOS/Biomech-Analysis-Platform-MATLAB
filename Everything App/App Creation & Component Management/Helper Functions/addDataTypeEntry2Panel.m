function []=addDataTypeEntry2Panel(src)

%% PURPOSE: ADD THE ENTRIES FOR EACH DATA TYPE TO THE UIPANEL ON THE IMPORT TAB

fig=ancestor(src,'figure','toplevel');
projectName=getappdata(fig,'projectName');

% Get the list of data types
hDropdown=findobj(fig,'Type','uidropdown','Tag','DataTypeImportSettingsDropDown');
panel=findobj(fig,'Type','uipanel','Tag','SelectDataPanel');
allPos=get(panel,'InnerPosition');
panelHeight=allPos(4);
panelWidth=allPos(3);

dataTypes=hDropdown.Items;
dataTypes=dataTypes(~ismember(dataTypes,{'No Data Types to Import'}));

text=readAllProjects(getappdata(fig,'everythingPath'));
projectNamesInfo=isolateProjectNamesInfo(text,projectName);

%% NOTE: WHEN SWITCHING PROJECTS, NEED TO DELETE THE OLD BOXES AND THEN CREATE/DISPLAY THE NEW.
allEntries=0;
elemNum=0;
while allEntries==0
    
    elemNum=elemNum+1;
    currLabel=findobj(fig,'Type','uilabel','Tag',['ImportTabDataLabel' num2str(elemNum)]);
    currLoadBox=findobj(fig,'Type','uicheckbox','Tag',['ImportTabLoadBox' num2str(elemNum)]);
    currOffloadBox=findobj(fig,'Type','uicheckbox','Tag',['ImportTabOffloadBox' num2str(elemNum)]);
    if ~isempty(currLabel) && ~isempty(currLoadBox) && ~isempty(currOffloadBox)
        delete(currLabel);
        delete(currLoadBox);
        delete(currOffloadBox);
    else
        allEntries=1;
    end
    
end

if isempty(dataTypes)
    return; % Stop processing after deleting all rows if there are no data types.
end

elemNum=0;
for i=1:length(dataTypes)    
    
    elemNum=elemNum+1;
    alphaNumericIdx=isstrprop(dataTypes{i},'alpha') | isstrprop(dataTypes{i},'digit');
    dataTypeField=dataTypes{i}(alphaNumericIdx);
    
    % Check if in the allProjects text file there's a line for the 'offload' & 'load' for each data
    % type
    if isfield(projectNamesInfo,['DataPanel' dataTypeField])
        % If so, set the boxes' values accordingly.
        data=projectNamesInfo.(['DataPanel' dataTypeField]);
        text=addProjInfoToFile(text,projectName,['Data Panel ' dataTypes{i} ':'],data,0);
    else
        % If not, create that line.
        text=addProjInfoToFile(text,projectName,['Data Panel ' dataTypes{i} ':'],'Load',0);
        data='Load';
    end
    
    % Create & position the data type label    
    dataLabels{i}=uilabel(panel,'Text',dataTypes{i},'Tag',['ImportTabDataLabel' num2str(elemNum)],'Position',[round(panelWidth*0.4) round(panelHeight*(0.8-i*0.1)) 100 22]);
    
    % Create & position the 'Load' & 'Offload' checkbox
    if isequal(data,'Load')
        loadVal=1;
        offloadVal=0;                
    elseif isequal(data,'Offload')
        loadVal=0;
        offloadVal=1;        
    elseif isequal(data,'None')
        loadVal=0;
        offloadVal=0;
    end
    loadBox{i}=uicheckbox(panel,'Text','','Tag',['ImportTabLoadBox' num2str(elemNum)],'Position',[round(panelWidth*0.05) round(panelHeight*(0.8-i*0.1)) 22 22],'Value',loadVal);
    offloadBox{i}=uicheckbox(panel,'Text','','Tag',['ImportTabOffloadBox' num2str(elemNum)],'Position',[round(panelWidth*0.2) round(panelHeight*(0.8-i*0.1)) 100 22],'Value',offloadVal,'ValueChangedFcn','');
    currLoad=loadBox{i};
    currOffload=offloadBox{i};
    set(currLoad,'ValueChangedFcn',@(currLoad,event) dataTypeCheckboxValueChanged(currLoad));
    set(currOffload,'ValueChangedFcn',@(currOffload,event) dataTypeCheckboxValueChanged(currOffload));    
    
    panel.UserData.(['ImportTabDataLabel' num2str(elemNum)])=dataLabels{i};
    panel.UserData.(['ImportTabLoadBox' num2str(elemNum)])=loadBox{i};
    panel.UserData.(['ImportTabOffloadBox' num2str(elemNum)])=offloadBox{i};    
    
end

%% Add the checkboxes & labels for all processing groups
% Check that the text file exists

% Read the text file for this project

% Get the list of group names

% Put the checkboxes & labels onto the panel

%% Save the text file
fid=fopen(getappdata(fig,'allProjectsTxtPath'),'w');
fprintf(fid,'%s\n',text{1:end-1});
fprintf(fid,'%s',text{end});
fclose(fid);