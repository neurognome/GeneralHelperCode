% You can either give the data in preprocessed format, which is a N X 3 cell array, where N is the links in the format
% {'source', 'target', amount}. Or you can supply the standardized CSV or JSON formats too (these might be buggy)

% There's some test data in the Example_Data folder

%data = SankeyPlot.readJSON(); % OR
%data = SankeyPlot.readCSV(); % OR
load('sankey.mat'); % Already in the proper format


% The sankey plot works simply, all you need to do is 
skp = SankeyPlot(data);
skp.preprocessData();
skp.calculateConnectionPoints;
skp.createLinks();
skp.createNodes();
skp.createLabels();



% Things you can do after: nothing for now, IGNORE
%{
skp.changeLinkColor([0.4, 0.4, 0.4]); % Set all links to one color, a little buggy
skp.changeNodeColor([0.5, 0.5, 0.5], false);...
 % Set all nodes to one color, or you can supply a N x 3 matrix, where N is the # of nodes for different colors. The second
 % argument is whether or not to update the link colors to the new node colors 
%}