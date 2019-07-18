function prettyPlot(h)
% Written 18Jul2019 KS

% A quick function just to make plots the way I like them for publications. Saves some work in illustrator
% You can either supply an axes for it to work on, or it'll just take the current one 


if nargin == 0
    h = gca;
end

set(h,'box','off');
set(h,'TickDir','out');
set(h,'LineWidth',2);
set(h,'FontName','Arial');