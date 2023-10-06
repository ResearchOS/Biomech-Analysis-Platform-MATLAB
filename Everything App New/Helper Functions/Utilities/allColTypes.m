function [colTypes] = allColTypes()

%% PURPOSE: RETURN THE COLUMN TYPES

colTypes.numericCols = {'OutOfDate','IsHardCoded','Num_Header_Rows','UsesConds'};
colTypes.jsonCols = {'Data_Path','Project_Path','Process_Queue','Tags','LogsheetVar_Params','Logsheet_Path',...
    'Logsheet_Parameters','Data_Parameters','HardCodedValue','InputVariablesNamesInCode','OutputVariablesNamesInCode','SpecifyTrials',...
    'Current_View','InclNodes','Current_Logsheet','Current_Analysis'};
colTypes.dateCols = {'Date_Created','Date_Modified','Date_Last_Ran'};

colTypes.linkageCols = {'EndNodes'};