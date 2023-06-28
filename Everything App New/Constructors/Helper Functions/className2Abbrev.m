function abbrev = className2Abbrev(class, reverse)

if nargin==1
    reverse=false;
end

if ~reverse
    switch class
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
        otherwise
            abbrev = '';
    end
end

if reverse
    switch class
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
        otherwise
            abbrev='';
    end


end