function abbrev = className2Abbrev(class)

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