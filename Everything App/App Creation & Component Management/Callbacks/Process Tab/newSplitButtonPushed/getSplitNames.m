function [splitNames]=getSplitNames(splitsStruct,splitName,uitreeParent)
% When calling this function non-recursively, leave splitName empty (i.e. [])    

    if ~exist('splitNames','var') && isempty(uitreeParent.Children)
        splitNames=struct;
    end
    
    if ~isfield(splitsStruct,'SubSplitNames') || isempty(fieldnames(splitsStruct.SubSplitNames))
        splitNames.(splitName)=struct();        
        return;
    end        

    currSplitNames=fieldnames(splitsStruct.SubSplitNames);
    
    for i=1:length(currSplitNames)
        splitName=currSplitNames{i};   
        uitreeParent=uitreenode(uitreeParent,'Text',splitName);
        splitNames.(splitName)=getSplitNames(splitsStruct.SubSplitNames.(splitName),splitName,uitreeParent);                
        uitreeParent=uitreeParent.Parent;
    end        

end