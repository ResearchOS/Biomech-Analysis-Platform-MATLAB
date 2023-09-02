function abbrev = className2Abbrev(class)

isChar = false;
if ischar(class)
    class = {class};
    isChar = true;
end

abbrevs = cell(size(class));
for i=1:length(class)
    currClass = class{i};

    if length(currClass)==2
        reverse = true;
    else
        reverse = false;
    end

    if ~reverse
        switch currClass
            case 'Project'
                abbrev = 'PJ';
            case 'Process'
                abbrev = 'PR';
            case 'ProcessGroup'
                abbrev = 'PG';
            case 'SpecifyTrials'
                abbrev = 'ST';
            case 'Logsheet'
                abbrev = 'LG';
            case 'Analysis'
                abbrev = 'AN';
            case 'Variable'
                abbrev = 'VR';
            case 'Component'
                abbrev = 'CP';
            case 'Plot'
                abbrev = 'PL';
            case 'View'
                abbrev = 'VW';
            otherwise
                abbrev = '';
        end
    end

    if reverse
        switch currClass
            case 'PR'
                abbrev = 'Process';
            case 'PJ'
                abbrev = 'Project';
            case 'PG'
                abbrev = 'ProcessGroup';
            case 'ST'
                abbrev = 'SpecifyTrials';
            case 'LG'
                abbrev = 'Logsheet';
            case 'AN'
                abbrev = 'Analysis';
            case 'VR'
                abbrev = 'Variable';
            case 'CP'
                abbrev = 'Component';
            case 'PL'
                abbrev = 'Plot';
            case 'VW'
                abbrev = 'View';
            otherwise
                abbrev='';
        end
    end

    abbrevs{i} = abbrev;

end

if isChar
    abbrevs = abbrevs{1};
end

abbrev = abbrevs;