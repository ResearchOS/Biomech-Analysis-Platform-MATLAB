function []=fcnsArgsSearchFieldValueChanged(src,event)

%% PURPOSE: FILTER THE VARIABLES LIST BOX BY THE SEARCH TERM.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('event','var')~=1
    return;
end

% projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
% load(projectSettingsMATPath,'VariableNamesList');
VariableNamesList=getappdata(fig,'VariableNamesList');

% searchTerm=handles.Process.fcnsArgsSearchField.Value;
searchTerm=event.Value;

count=0;
matchIdx=NaN(length(VariableNamesList.GUINames),1);
[~,sortedIdx]=sort(upper(VariableNamesList.GUINames));
for i=1:length(sortedIdx)
    idx=sortedIdx(i);

    if contains(upper(VariableNamesList.GUINames{idx}),upper(searchTerm))
        count=count+1;
        matchIdx(count)=idx;
    end

end

matchIdx(isnan(matchIdx))=[];

makeVarNodes(fig,matchIdx,VariableNamesList);