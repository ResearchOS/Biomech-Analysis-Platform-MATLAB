function [copyDone]=copyFileFromLib(fig,type,currFcnFileName)

%% PURPOSE: CHECK IF A FILE ALREADY EXISTS IN THE GITHUB REPO LIBRARY. IF SO, RETURNS 1. IF NOT, RETURNS 0
% Inputs:
% fig: The handle to the whole figure. Necessary for accessing the app's data (handle)
% type: Specifies if this function is 'Import', 'Process', or 'Plot' (char)
% currFcnFileName: The function file name to check (char)

% Outputs:
% copyDone: Returns 1 if the file exists, 0 if not.

slash=filesep;

listing=dir([getappdata(fig,'everythingPath') 'm File Library' slash type slash]); % All elements are folders, where folder names are function names (without number or letter)

copyDone=0; % Initialize that the file has not been found & copied.
for i=1:length(listing) % Search through every folder in the Process folder
    
    currFolder=listing(i).name; % The current folder name
    currFolderListing=dir([getappdata(fig,'everythingPath') 'm File Library' slash type slash currFolder]);
    if isequal(currFolder,'.') || isequal(currFolder,'..') % Ignore the weird empty results that dir() returns
        continue;
    end
    for j=1:length(currFolderListing) % Search through every file in the current file's folder
        
        currMethodFcnName=currFolderListing(j).name;
        if isequal(currMethodFcnName,'.') || isequal(currMethodFcnName,'..') % Ignore the weird empty results that dir() returns
            continue;
        end
        if isequal(currMethodFcnName,currFcnFileName) % If the function number was found in the folder, copy it to the code path.
            if ~isfolder([getappdata(fig,'codePath') type '_' getappdata(fig,'projectName') slash 'Existing Functions'])
                mkdir([getappdata(fig,'codePath') type '_' getappdata(fig,'projectName') slash 'Existing Functions']);
            end
            copyfile([getappdata(fig,'everythingPath') 'm File Library' slash type slash currFolder slash currMethodFcnName],...
                [getappdata(fig,'codePath') type '_' getappdata(fig,'projectName') slash 'Existing Functions' slash currFcnFileName]);
            copyDone=1; % The file has been found and copied.
            break;
        end
        
    end
    
    if copyDone==1
        break;
    end
    
end