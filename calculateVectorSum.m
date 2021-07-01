function out = calculateVectorSum(data, theta)
if nargin < 2 || isempty(theta)
    step = 2*pi/length(data);
    theta = 0:step:2*pi-step;
end
getHorz = @(v, theta) v .* cos(theta);
getVert = @(v, theta) v .* sin(theta);
getAng = @(vert, horz) atan2(vert, horz);
getMag = @(vert, horz) sqrt(horz .^ 2 + vert .^ 2);


h = getHorz(data, theta);
v = getVert(data, theta);

% Changed from sum to mean, shouldn't change anything... more similar to Giocomo
r_h = sum(h);
r_v = sum(v);

m = getMag(r_v, r_h);
ang = getAng(r_v, r_h);
out = [ang, m];
end