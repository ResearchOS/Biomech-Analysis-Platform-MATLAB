function []=fcnsArgsSearchFieldValueChanged(src,event)

%% PURPOSE: FILTER THE VARIABLES LIST BOX BY THE SEARCH TERM.
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'VariableNamesList');

searchTerm=handles.Process.fcnsArgsSearchField.Value;

% if isempty(searchTerm)
%     return;
% end

count=0;
matchIdx=[];
[~,sortedIdx]=sort(upper(VariableNamesList.GUINames));
for i=1:length(sortedIdx)
    idx=sortedIdx(i);

    if contains(upper(VariableNamesList.GUINames{idx}),upper(searchTerm))
        count=count+1;
        matchIdx(count)=idx;
    end

end

% matchIdx=find(ismember(sort(upper(VariableNamesList.GUINames)),upper(searchTerm))==1);

% headers=fieldnames(VariableNamesList);
% for i=1:length(headers)
%     newList.(headers{i})=VariableNamesList.(headers{i})(matchIdx);
% end

makeVarNodes(fig,matchIdx,VariableNamesList);