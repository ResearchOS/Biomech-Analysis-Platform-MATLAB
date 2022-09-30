function [props,isChanged]=convertCharToVar(fig,pgui,propName,varText,props)

%% PURPOSE: CONVERT THE CHAR VERSION OF THE VARIABLE BACK TO ITS ORIGINAL DATA FORMAT

% Plotting=getappdata(pgui,'Plotting');

% compName=getappdata(fig,'compName');
% idx=ismember(Plotting.Components.Names,compName);

% defProps=Plotting.Components.DefaultProperties{idx};

% props=getappdata(fig,'props');

defClass=class(props.(propName)); % Get the class for this variable from the default settings.

varText=varText{1};

if isequal(varText,'Cannot be displayed')
%     var='Cannot be displayed';
    isChanged=0;
    return;
end

isChanged=1;

switch defClass
    case 'double'        
        var=cast(varText,'double');
        var(var==44)=32;
        bracketIdx=ismember(var,[91 93]); % 91 & 93 are the values for the '[]' chars
        var=cell2mat(textscan(char(var(~bracketIdx)),'%f'))';
        props.(propName)=var;
    case 'matlab.lang.OnOffSwitchState' % Types that MATLAB can implicitly convert from char
        var=varText;
        props.(propName)=var;
    case 'cell'
        var=strrep(varText,',',' ');
        var=strrep(var,'{',' ');
        var=strrep(var,'}',' ');
        var=strsplit(var,' ');
        emptyIdx=cellfun(@isempty,var);
        var=var(~emptyIdx);
        props.(propName)=var;
    case 'matlab.graphics.primitive.Text'
        if isvalid(props.(propName))
            props.(propName).String=varText;
        end
    otherwise % Character vector already
        var=varText;
        props.(propName)=var;
end