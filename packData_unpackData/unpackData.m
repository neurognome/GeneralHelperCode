function unpackData(input,varargin)
%-------------------------------------------------------------------------%
% To be used with packData. Unpacks your data and puts em out in the
% workspace which were packed by packData. You can specify which specific
% packed variables you want out, or else it'll unpack them all.
% 
% Usage: unpackData(struct_to_unpack,'specific_variable');
% 
% Written 26Jul2019 KS
% Updated
%-------------------------------------------------------------------------%


if nargin == 0
    fprintf('You need to specify which packed-data you want to open up. \n')
    return
elseif nargin < 2
    fprintf('No data specified, unpacking the whole thing... \n')
    
    field = fieldnames(input);
    
    for ii = 1:length(field)
        
        assignin('caller',field{ii}, getfield(input,field{ii}))
    end
else
    field = fieldnames(input);
    fields_to_extract = find(ismember(field,varargin));
    
    for ii = 1:length(fields_to_extract)
        e = fields_to_extract(ii);
        assignin('caller',field{e}, getfield(input,field{e}))
    end
end

end

