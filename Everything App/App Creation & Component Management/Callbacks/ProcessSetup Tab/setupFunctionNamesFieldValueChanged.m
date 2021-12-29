function []=setupFunctionNamesFieldValueChanged(src,event)

%% PURPOSE: STORE THE FUNCTION NAMES, AND CHECK THEM TO MAKE SURE THERE'S A SPACE IN EACH ONE

fig=ancestor(src,'figure','toplevel');

currNames=src.Value;

for i=1:length(currNames)
    
    a=strsplit(currNames{i},' ');
    if length(a)==1
        disp(['Missing a space between function name and method number/letter: ' currNames{i}]);
        return;
    end
    
end

setappdata(fig,'functionNames',currNames);

disp(['Functions Staged:']);
for i=1:length(currNames)
    
    disp(currNames{i});
    
end