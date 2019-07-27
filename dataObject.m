classdef dataObject < dynamicprops
% -------------------------------------------------------------------------%
% Special object used to store data and pass it around. It first takes 
% whatever data you want to pass in as an input, but you can also add or
% remove data as you'd like. All data are public, so you can access 
% individual data stored just by calling your object.dataYouWant
% 
% Written 26Jul2019 KS 
% Updated
% -------------------------------------------------------------------------%

    properties (Access = private)
        dynamicproperties
    end
    
    methods
        function obj = dataObject(varargin)
            
            for ii = 1:nargin % Loops through the input arguments
                p(ii) = obj.addprop(inputname(ii)); % adds them as dynamic properties
                obj.(inputname(ii)) = varargin{ii}; % Fills in those properties with the values
            end
            
            obj.dynamicproperties = p; % here we assign the private dynamicproperties property, mainly for controlling these data
        end
        
        function addData(obj,varargin) % In order to add more data to our object
            for ii = 1:nargin-1 % because there will always be "obj" there
                try
                    p(ii) = obj.addprop(inputname(ii+1));
                    obj.(inputname(ii+1)) = varargin{ii};  
                    obj.dynamicproperties = [obj.dynamicproperties p]; % extending the thing
                catch
                    fprintf('%s is already a property, skipped...\n',inputname(ii+1))
                end
            end
        end
        
        function deleteData(obj,varargin) % Getting rid of individual fields of data
            if ~ischar(varargin{1}) % So that you can put data values in as "variables" instead of changing to strings yourself
                for ii = 1:nargin-1
                    varargin{ii} = inputname(ii+1);
                end
            end
            
            try 
                dynamic_property_list = {obj.dynamicproperties.Name}; % Find the properties you want to get rid of
                isDeleteProperty = ismember(dynamic_property_list,varargin);
                delete(obj.dynamicproperties(isDeleteProperty)) % Get rid of thew
                obj.dynamicproperties = obj.dynamicproperties(~isDeleteProperty); % Update reference list
            catch
                fprintf('Something went wrong, properties not deleted \n')
            end
        end
        
        function clearAllData(obj) % For clearing your entire data object, starting from scratch
            delete(obj.dynamicproperties);
            obj.dynamicproperties = [];
        end
        
    end
end




