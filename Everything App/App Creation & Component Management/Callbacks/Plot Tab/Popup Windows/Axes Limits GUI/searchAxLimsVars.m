function []=searchAxLimsVars(src,event)

%% PURPOSE: SEARCH THROUGH THE VARIABLE NAMES LIST IN THE AXES LIMS GUI
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

if exist('event','var')~=1
    return;
end

searchTerm=event.Value;

VariableNamesList=getappdata(fig,'VariableNamesList');

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

makeVarNodesAxLims(fig,matchIdx,VariableNamesList);