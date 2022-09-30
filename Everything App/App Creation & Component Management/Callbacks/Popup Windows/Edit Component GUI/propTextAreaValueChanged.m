function []=propTextAreaValueChanged(src,pgui)

%% PURPOSE: MODIFY THE CURRENTLY SELECTED PROPERTY
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

propName=Qhandles.propsList.Value;

props=getappdata(fig,'props');

% compName=getappdata(fig,'compName');
% handles=getappdata(pgui,'handles');

ta=Qhandles.propTextArea;

text=ta.Value{1};

propNamesChanged=getappdata(fig,'propNamesChanged');

if isequal(text,props.(propName))
    propNamesChanged=propNamesChanged(~ismember(propNamesChanged,propName));
    setappdata(fig,'propNamesChanged',propNamesChanged);
    return;
end

[props,isChanged]=convertCharToVar(fig,pgui,propName,ta.Value,props);

if isChanged==0
    return;
end

% if isequal(a,'Cannot be displayed')
%     return;
% end
% 
% props.(propName)=a;



propNamesChanged=[propNamesChanged; {propName}]; % Keep track of which properties have been changed
propNamesChanged=unique(propNamesChanged);

setappdata(fig,'propNamesChanged',propNamesChanged);
setappdata(fig,'props',props);

setappdata(fig,'handles',Qhandles);