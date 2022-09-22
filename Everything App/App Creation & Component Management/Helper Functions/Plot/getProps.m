function [defVals,props]=getProps(type)

%% PURPOSE: GET THE PROPERTIES FOR THE SPECIFIED TYPE OF GRAPHICS OBJECT

Q=figure('Visible','off');
switch type
    case 'axes'
        h=axes(Q);
    case 'line'
        h=line;   
    case 'xyzline'
        h=xline(0);
    case 'scatter3'
        h=scatter3(0,0,0);
    case 'scatter'
        h=scatter(0,0);
    case 'plot'
        h=plot(1,1);
    case 'plot3'
        h=plot3(1,1,1);
    case 'image (Image Processing Toolbox needed)'
        h=[];
end

props=properties(h);

for i=1:length(props)
    defVals.(props{i})=h.(props{i});
end

close(Q);