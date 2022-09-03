function []=removeSplitButtonPushed(src,splitCode,splitName)

%% PURPOSE: DELETE A PROCESSING SPLIT FROM THE LIST IN THE SPLITSUITREE. MUST NOT BE USED ANYWHERE IN THE MAP, OR HAVE ANY CHILDREN SPLITS.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=handles.Process.splitsUITree.SelectedNodes;
splitText=selNode.Text;
spaceIdx=strfind(splitText,' ');
if exist('splitCode','var')~=1
    splitCode=splitText(spaceIdx+2:end-1);
    splitName=splitText(1:spaceIdx-1);
    runLog=true;
else
    handles.Process.splitsUITree.SelectedNodes=findobj(handles.Process.splitsUITree,'Text',[splitCode '_' splitName]);
    selNode=handles.Process.splitsUITree.SelectedNodes;
    runLog=false;
end

if ~isempty(selNode.Children)
    disp('Cannot delete a split that has children!');
    return;
end

projectSettingsMATPath=getappdata(fig,'projectSettingsMATPath');
load(projectSettingsMATPath,'Digraph','NonFcnSettingsStruct');

if ~isempty(Digraph.Edges) && ismember({splitCode},Digraph.Edges.SplitCode)
    disp('Cannot delete a split that still has existing edges!');
    return;
end

splitList=getSplitsOrder(selNode,handles.Process.splitsUITree.Tag);
structPath='NonFcnSettingsStruct.Process.Splits';
for i=1:length(splitList)-1
    structPath=[structPath '.SubSplitNames.' splitList{i}];
end

structPath=[structPath '.SubSplitNames'];

eval([structPath '=rmfield(' structPath ',''' splitList{end} ''');']);

delete(selNode);

save(projectSettingsMATPath,'NonFcnSettingsStruct','-append');

if runLog
    desc='Removed split';
    updateLog(fig,desc,splitCode,splitName);
end