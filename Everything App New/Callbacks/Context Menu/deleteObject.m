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

versions=piStruct.Versions;

% 1. Remove the specified version from the list in the PI struct.
if isPS && ismember(text,versions)
    versions=versions(~ismember(versions,text));
end

% 2. If the text is PI, then delete the entire PI and all versions.
linksNames=contains(fieldnames(piStruct),'Links_'); % The list of class types being linked to and from.

if isPS
    texts={text};
else
    texts=versions;
end

for i=1:length(texts)

    text=texts{i};

    psPath=getClassFilePath(text,class); % The current PS version.
    psStruct=loadJSON(psPath);

    linksNames=contains(fieldnames(psStruct),'Links_');

    % Remove all of the different kinds of links.
    for j=1:length(linksNames)

        linkName=linksNames{j};
        links=psStruct.(linkName);
        underscoreIdx=strfind(linkName,'_');
        linkedClass=linkName(underscoreIdx:end); % Class name is after the underscore.

        % Remove each link for this link class
        for k=1:length(links)

            link=links{k};

            linkedPath=getClassFilePath(link,linkedClass);
            linkedStruct=loadJSON(linkedPath);

            if isequal(linkName(1:13),'ForwardLinks_')
                unlinkClasses(psStruct,linkedStruct);
            elseif isequal(linkName(1:13),'BackwardLinks_')
                unlinkClasses(linkedStruct,psStruct);
            else
                error('Link field name must start with "ForwardLinks_" or "BackwardLinks_"');
            end

        end


    end



end