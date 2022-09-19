function [currComp]=editCompPopupWindow(src,currComp,compName,plotName,letter)

%% PURPOSE: EDIT THE PROPERTIES OF THE CURRENTLY SELECTED COMPONENT
fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

Q=uifigure('Visible','on','Name','Edit Comp Props');
% props=get(currComp);
propNames=fieldnames(currComp);
[~,idx]=sort(upper(propNames));
propNames=propNames(idx);
Qhandles.propsList=uilistbox(Q,'Position',[10 10 200 450],'Items',propNames,'Value',propNames{1},'MultiSelect','off','ValueChangedFcn',@(Q,event) propsValueChanged(Q,fig));

% Manage the various property types to convert them to characters
var=currComp.(propNames{1});
varText=convertVarToChar(var);

Qhandles.propTextArea=uitextarea(Q,'Position',[250 10 250 450],'Value',varText,'Editable','on','Visible','on','ValueChangedFcn',@(Q,event) propTextAreaValueChanged(Q,fig));
Qhandles.applyButton=uibutton(Q,'Position',[510 250 80 40],'Text','Apply','Visible','on','ButtonPushedFcn',@(Q,event) applyButtonPushedFcn(Q,fig));

setappdata(Q,'props',currComp);
setappdata(Q,'propNamesChanged',{})
% Qhandles.props=props;
% 
% Qhandles.propNamesChanged={}; % Initialize that no properties have been changed.

setappdata(Q,'handles',Qhandles);
setappdata(Q,'compName',compName);
setappdata(Q,'plotName',plotName);
setappdata(Q,'letter',letter);

% uiwait(Q);