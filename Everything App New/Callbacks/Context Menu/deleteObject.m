function []=deleteObject(src,event)

%% PURPOSE: DELETE THE SPECIFIED OBJECT. ALSO REMOVES ALL LINKS TO IT.

fig=ancestor(src,'figure','toplevel');
handles=getappdata(fig,'handles');

selNode=get(fig,'CurrentObject'); % Get the node being right-clicked on.

text=selNode.Text;

uiTree=getUITreeFromNode(selNode);
class=getClassFromUITree(uiTree);

[name,id,psid]=deText(text);

if isempty(psid)
    isPS=false;
else
    isPS=true;
end

piText=getPITextFromPS(text);
piPath=getClassFilePath(piText,class);
piStruct=loadJSON(piPath);

versions=getVersions(piStruct);

%% NOTE: STILL NEED TO REMOVE VARIABLE REFERENCES FROM INPUT/OUTPUT VARIABLES FIELDS.
% Removing from Forward/BackwardLinks by itself is not sufficient

% 1. Remove the specified version from the list in the PI struct.
% if isPS && ismember(text,versions)
%     versions=versions(~ismember(versions,text));
% end

% 2. If the text is PI, then delete the entire PI and all versions.
fldNames=fieldnames(piStruct);
linksNames=fldNames(contains(fldNames,'Links_')); % The list of class types being linked to and from.

if isPS
    texts={text};
else
    texts=versions;
end

slash=filesep;

for i=1:length(texts)

    text=texts{i};

    psPath=getClassFilePath(text,class); % The current PS version.
    psStruct=loadJSON(psPath);

    fldNames=fieldnames(psStruct);
    linksNames=fldNames(contains(fldNames,'Links_'));

    % Remove all of the different kinds of links.
    for j=1:length(linksNames)

        linkName=linksNames{j};
        links=psStruct.(linkName);

        if isempty(links)
            continue;
        end

        underscoreIdx=strfind(linkName,'_');
        linkedClass=linkName(underscoreIdx+1:end); % Class name is after the underscore.

        % Remove each link for this link class
        for k=1:length(links)

            link=links{k};

            linkedPath=getClassFilePath(link,linkedClass);
            linkedStruct=loadJSON(linkedPath);

            if isequal(linkName(1:13),'ForwardLinks_')
                unlinkClasses(psStruct,linkedStruct);
            elseif isequal(linkName(1:14),'BackwardLinks_')
                unlinkClasses(linkedStruct,psStruct);
            else
                error('Link field name must start with "ForwardLinks_" or "BackwardLinks_"');
            end

        end

    end

    psStruct.Visible=false;
    psStruct.Checked=false;
    psStruct.Archived=true;
    % Delete the version file too? Or is archiving sufficient?

    % Save the changes
    writeJSON(psPath,psStruct); 

    % Move the file to the archive
    [psFolder,psName]=fileparts(psPath);
    archivePath=[psFolder slash 'Archive' slash psName '.json'];
    movefile(psPath,archivePath);

end

delete(selNode);