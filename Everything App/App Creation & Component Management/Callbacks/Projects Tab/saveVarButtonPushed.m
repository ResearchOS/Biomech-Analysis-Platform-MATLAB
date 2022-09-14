function []=saveVarButtonPushed(src,varName)

%% PURPOSE: SAVE THE VARIABLE SELECTED IN THE DROP-DOWN LIST.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');

if exist('varName','var')~=1
    runLog=true;
    varName=handles.Projects.showVarDropDown.Value;
else
    runLog=false;
    handles.Projects.showVarDropDown.Value=varName;
end

try
    var=evalin('base',[varName ';']);
catch
    beep;
    disp(['Missing variable ' varName ' from the base workspace, cannot save!']);
    return;
end

switch varName
    case 'NonFcnSettingsStruct'
        eval([varName '=var;']);
        save(projectSettingsMATPath,varName,'-append');
        setappdata(fig,'NonFcnSettingsStruct',varName);
    case 'VariableNamesList'
        % Convert table back to structure
        names=var.Properties.VariableNames;
        for i=1:length(names)
            structVar.(names{i})=var.(names{i});
        end
        eval([varName '=structVar;']);
        save(projectSettingsMATPath,varName,'-append');
        setappdata(fig,'VariableNamesList',varName);
    case 'Digraph'
        % Modify the tables to make Nx2 columns        
        Digraph=digraph(var.Edges,var.Nodes);
        save(projectSettingsMATPath,'Digraph','-append');
        setappdata(fig,'Digraph',Digraph);
    case 'Plotting'
        eval([varName '=var;']);
        save(projectSettingsMATPath,varName,'-append');
        setappdata(fig,'Plotting',varName);
end

evalin('base',['clear ' varName ';']);

if ~runLog
    pgui(true);
elseif runLog
    desc='Saved settings variable';
    updateLog(fig,desc,varName);
    pgui;
end

close(fig);