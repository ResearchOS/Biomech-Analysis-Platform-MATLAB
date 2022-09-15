function []=propTextAreaValueChanged(src,pgui)

%% PURPOSE: MODIFY THE CURRENTLY SELECTED PROPERTY
fig=ancestor(src,'figure','toplevel');
Qhandles=getappdata(fig,'handles');

propName=Qhandles.propsList.Value;

props=Qhandles.props;

% compName=getappdata(fig,'compName');
% handles=getappdata(pgui,'handles');

ta=Qhandles.propTextArea;

text=ta.Value{1};

if isequal(text,props.(propName))
    Qhandles.propNamesChanged=Qhandles.propNamesChanged(~ismember(Qhandles.propNamesChanged,propName));
    return;
end

a=convertCharToVar(fig,pgui,propName,ta.Value);

if isequal(a,'Cannot be displayed')
    return;
end

props.(propName)=a;

Qhandles.propNamesChanged=[Qhandles.propNamesChanged; {propName}]; % Keep track of which properties have been changed
Qhandles.props=props;

setappdata(fig,'handles',Qhandles);