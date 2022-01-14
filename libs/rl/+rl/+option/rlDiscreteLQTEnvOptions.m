classdef rlDiscreteLQTEnvOptions
% rlDiscreteLQTEnvOptions: Create options for DiscreteLQT Environment.
%
%   OPT = rlDiscreteLQTEnvOptions returns the default options for rlLQTAgent. 
%
%   OPT = rlDiscreteLQTEnvOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options are:
%
% %   tol                                 目標値との許容誤差
% %   TimesInARow                         連続何回許容誤差以内に入ったらエピソードを終了するか
% %
% %   See also: rlDiscreteLQTEnvt

% ver1.0.0 2020-06-14 T.Iwata Test create    
    
    properties
        % Number for estimator update
        tol
        TimesInARow
    end
    
    properties(Access=protected)
        Parser
    end
    
    methods
        function obj = rlDiscreteLQTEnvOptions(varargin)
            parser = rl.util.createInputParser;

            addParameter(parser, 'tol', 1e-5);
            addParameter(parser, 'TimesInARow', uint64(Inf));
            
            parse(parser, varargin{:});
            obj.Parser = parser;
            obj.tol = parser.Results.tol;
            obj.TimesInARow = parser.Results.TimesInARow;
            
        end

        % Varidate functions
        function obj = set.tol(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'positive', 'finite'}, '', 'tol');
            obj.tol = value;
        end
        
        function obj = set.TimesInARow(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'integer', 'positive'}, '', 'TimesInARow');
            obj.TimesInARow = value;
        end
    end
end
