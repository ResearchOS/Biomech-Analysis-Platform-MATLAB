function [] = importCallbacks(src, event, args)

%% PURPOSE: RUN THE IMPORT CALLBACKS.

global globalG;

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');
allHandles = handles;

handles = handles.Import;

if exist('event','var')~=1
    event = '';
end
if exist('args','var')~=1
    args.Type = '';
end
type = args.Type;

uiTree = handles.allLogsheetsUITree;
uuid = uiTree.SelectedNodes.NodeData.UUID;

switch src
    case handles.addLogsheetButton
        createAndShowObject(uiTree, false, 'LG', '', '', '', true);

    case handles.removeLogsheetButton
        node = getNode(uiTree, uuid);
        confirmAndDeleteObject(uuid, node);

    case handles.allLogsheetsUITree
        allLogsheetsUITreeSelectionChanged(fig);
        log = getCurrent('Current_Logsheet');
        handles.logsheetsLabel.Text = [getName(log) ' ' log];

    case handles.logsheetPathField
        logsheetPathFieldValueChanged(fig);

    case handles.logsheetPathButton
        logsheetPathButtonPushed(fig);

    case handles.openLogsheetPathButton
        openLogsheetPathButtonPushed(fig);

    case handles.numHeaderRowsField
        numHeaderRowsFieldValueChanged(fig);

    case handles.subjectCodenameDropDown
        subjectCodenameDropDownValueChanged(fig);

    case handles.targetTrialIDDropDown
        targetTrialIDDropDownValueChanged(fig);

    case handles.headersUITree
        headersUITreeSelectionChanged(fig);

    case handles.levelDropDown
        levelDropDownValueChanged(fig);

    case handles.typeDropDown
        typeDropDownValueChanged(fig);

    case handles.checkAllButton
        checkAllButtonPushed(fig);

    case handles.uncheckAllButton
        uncheckAllButtonPushed(fig);

    case handles.runLogsheetButton
        runLogsheetButtonPushed(fig);

    case handles.addSpecifyTrialsButton
        addSpecifyTrialsButtonPushed(fig);

    case handles.removeSpecifyTrialsButton
        removeSpecifyTrialsButtonPushed(fig);

    case handles.allSpecifyTrialsUITree
        specifyTrialsUITreeCheckedNodesChanged(handles.allSpecifyTrialsUITree);

    case handles.editSpecifyTrialsButton
        editSpecifyTrialsButtonPushed(src);

end