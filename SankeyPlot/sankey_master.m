% 90% working. Needs some changes on updating plots after making them
% Next up to work on is the spacing issue, to make it look a little better

% 
% 
% data = [{'all neurons', 'responsive', 510};...
%     {'all neurons', 'non-responsive', 200};...
%     {'non-responsive', 'tuned', 100};...
%     {'responsive', 'tuned', 200};...
%     {'responsive', 'untuned', 300};...
%     {'responsive', 'what', 10};...
%     {'untuned', 'what', 100};...
%     {'non-responsive', 'untuned', 50}];
% 

% or you can read the optional one
data = SankeyPlot.processCSV();
% The sankey plot works simply, all you need to do is 
skp = SankeyPlot(data);
skp.preprocessData();
skp.calculateConnectionPoints;
skp.createLinks();
skp.createNodes();
skp.createLabels();



% Things you can do after: nothing for now, IGNORE
%{
skp.setNodeWidth(0.5); % change the width of the nodes
skp.setLinkColor([0.4, 0.4, 0.4]); % Set all links to one color, a little buggy
skp.setNodeColor([0.5, 0.5, 0.5]); % Set all nodes to one color, or you can supply a N x 3 matrix, where N is the # of nodes for different colors
% currently a little buggy, the link color will update automaticalyl to the node color
%}