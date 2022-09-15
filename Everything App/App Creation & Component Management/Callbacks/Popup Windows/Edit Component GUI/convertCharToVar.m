function [var]=convertCharToVar(fig,pgui,propName,varText)

%% PURPOSE: CONVERT THE CHAR VERSION OF THE VARIABLE BACK TO ITS ORIGINAL DATA FORMAT

Plotting=getappdata(pgui,'Plotting');

compName=getappdata(fig,'compName');
idx=ismember(Plotting.Components.Names,compName);

defProps=Plotting.Components.DefaultProperties{idx};

defClass=class(defProps.(propName)); % Get the class for this variable from the default settings.

varText=varText{1};

if isequal(varText,'Cannot be displayed')
    var='Cannot be displayed';
    return;
end

switch defClass
    case 'double'
        var=cast(varText,'double');
    case {'matlab.graphics.primitive.Text','matlab.lang.OnOffSwitchState'} % Types that MATLAB can implicitly convert from char
        var=varText;
    otherwise % Character vector already
        var=varText;

end