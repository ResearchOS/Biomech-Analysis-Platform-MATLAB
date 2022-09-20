function [varText]=convertVarToChar(var)

%% PURPOSE: CONVERT THE GRAPHICS OBJECT PROPERTY TO CHARACTER SO IT CAN BE DISPLAYED IN THE TEXT AREA.

switch class(var)
    case 'double'
        if length(var)>1
            varText='[';
            for i=1:length(var)
                varText=[varText num2str(var(i)) ' '];
            end
            varText=[varText(1:end-1) ']'];
        else
            varText=num2str(var);
        end

    case 'matlab.graphics.primitive.Text'
        if isvalid(var)
            varText=var.String;
        else
            varText='';
        end
    case 'matlab.lang.OnOffSwitchState'
        if isequal(var,'off')
            varText='off';
        else
            varText='on';
        end
    case 'char'
        varText=var;
    case 'cell'        
        if iscellstr(var) % This variable is a cell array of character vectors
            varText=['{' var{1}];
            for i=2:length(var)
                varText=[varText ', ' var{i}];
            end
            varText=[varText '}'];            
        else

        end
    otherwise
        varText='Cannot be displayed';

end