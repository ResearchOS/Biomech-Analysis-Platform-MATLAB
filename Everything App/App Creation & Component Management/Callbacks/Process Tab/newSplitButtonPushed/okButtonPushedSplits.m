function []=okButtonPushedSplits(fig)

    fig=ancestor(fig,'figure','toplevel');
    handles=getappdata(fig,'handles');
    currObj=handles.uitree.SelectedNodes;
    selSplit=getSplitsOrder(currObj);    
    assignin('base','selSplit',selSplit);
    close(fig);

end