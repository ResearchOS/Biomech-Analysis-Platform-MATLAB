function []=okButtonPushedSplits(fig)

    fig=ancestor(fig,'figure','toplevel');
    handles=getappdata(fig,'handles');
    currObj=handles.uitree.SelectedNodes;
    rootTag=handles.uitree.Children.Tag;
    selSplit=getSplitsOrder(currObj,rootTag);    
    assignin('base','selSplit',selSplit);
    close(fig);

end