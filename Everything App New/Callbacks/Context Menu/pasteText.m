function []=pasteText(src,event)

%% PURPOSE: PASTE A NODE'S COPIED TEXT INTO ANOTHER NODE.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

selUITree=getUITreeFromNode(selNode);

if isequal(selNode.Parent,selUITree) % Not project-specific
    disp('Must paste to project-specific node!');
    return;
end

parentText=selNode.Text; % The parent object to paste into
parentClass=getClassFromUITree(selUITree);

if isequal(parentClass,'Variable')
    parentClass='Process';
end

% parentPath=getClassFilePath(parentText,parentClass);
% parentStruct=loadJSON(parentPath);

copiedText=clipboard('paste');

texts=strsplit(copiedText,newline);

for i=1:length(texts)

    fullText=texts{i};
    splitText=strsplit(fullText,':');
    spaceIdxClass=strfind(splitText{2},' ');
    class=splitText{2}(spaceIdxClass(1)+1:spaceIdxClass(2)-1);
    text=splitText{3}(2:end);

    switch parentClass
        case 'Process'
            openParenIdx=strfind(text,'(');
            text=text(openParenIdx+1:end-1);
            assert(ismember(class,{'Variable'}));
            varUITree=handles.Process.allVariablesUITree;
            selectNode(varUITree,text);
            assignVariableButtonPushed(fig,text,parentText);
        case 'ProcessGroup'
            assert(ismember(class,{'Process','ProcessGroup'}));
            if isequal(class,'Process')
                assignFunctionButtonPushed(fig,text,parentText);
            else
                assignGroupButtonPushed(fig,text,parentText);
            end
        case 'Component'
            assert(ismember(class,{'Variable'}));
        case 'Plot'
            assert(ismember(class,{'Component'}))
        otherwise
            error('What happened?');
    end

end