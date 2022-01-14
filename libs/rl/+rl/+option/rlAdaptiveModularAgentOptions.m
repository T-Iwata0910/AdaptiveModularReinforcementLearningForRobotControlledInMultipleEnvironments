classdef rlAdaptiveModularAgentOptions < rl.option.AgentGeneric
% rlAdaptiveModularAgentOptions: Create options for Adaptive modular Agent.
%
%   OPT = rlAdaptiveModularAgentOptions  returns the default options for. 
%
%   OPT = rlLQTAgentOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options are:
%
% %   Vigilance                         警戒パラメータ
% %   See also: rlAdaptiveModularAgent

% ver1.0.0 2020-09-10 T.Iwata Test create

    properties
        % Number for estimator update
        Vigilance
        LearningPeriod
        SaveExperiences (1, 1) logical = false
    end
    
    methods
        function this = rlAdaptiveModularAgentOptions(varargin)
      
            this = this@rl.option.AgentGeneric(varargin{:});
            
            parser = this.Parser;
            addParameter(parser, 'Vigilance', Inf);
            addParameter(parser, 'LearningPeriod', 20);
            addParameter(parser, 'SaveExperiences', false);
            
            parse(parser, varargin{:});
            this.Parser = parser;
            this.Vigilance = parser.Results.Vigilance;
            this.LearningPeriod = parser.Results.LearningPeriod;
            this.SaveExperiences = parser.Results.SaveExperiences;
        end
        
        function this = set.Vigilance(this,Value)
            validateattributes(Value,{'numeric'},{'scalar', 'real'},'','Vigilance');
            this.Vigilance = Value;
        end
        function this = set.LearningPeriod(this,Value)
            validateattributes(Value,{'numeric'},{'scalar', 'integer', 'positive'},'','LearningPeriod');
            this.LearningPeriod = Value;
        end
        function this = set.SaveExperiences(this,Value)
            validateattributes(Value,{'logical'},{},'','SaveExperiences');
            this.SaveExperiences = Value;
        end
        
    end    
end