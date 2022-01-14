classdef rlLQTAgentOptions < rl.option.AgentGeneric
% rlLQTAgentOptions: Create options for LQT control Agent.
%
%   OPT = rlLQTAgentOptions returns the default options for rlLQTAgent. 
%
%   OPT = rlLQTAgentOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported options are:
%
% %   DiscountFactor                      Discount factor to apply to future rewards during training
% %   StepNumPreIteration                 1�C�e���[�V����������̃X�e�b�v��
% %   StopExplorationValue                �w�K���I��������l
% %   SaveExperiences                     Experience��Agent�ɕۑ�����I�v�V����
% %   NoiseOptions                        Parameters for Ornstein Uhlenbeck noise
% %       InitialAction                       Initial state of the noise model
% %       Mean                                Mean of the noise model
% %       MeanAttractionConstant              Constant used to attract the process toward the mean
% %       Variance                            Variance of the random process
% %       VarianceDecayRate                   Rate of noise variance decay with each step of the noise model 
% %
% %   See also: rlLQTAgent

% ver1.0.0 2020-02-11 T.Iwata Test create
% ver1.1.0 2020-04-30 ��������ǉ�
% ver1.1.0 2020-05-02 Experience��Agent�ɕۑ�����I�v�V������ǉ�
% ver1.2.0 2020-05-25 �m�C�Y�̃��f����I���ł���悤�ɕύX
% ver1.3.0 2020-12-31 �T���m�C�Y�̏I��������ǉ�
    
    
    properties
        % Number for estimator update
        StepNumPerIteration
        StopExplorationValue
        SaveExperiences
        NoiseOptions
    end
    
    methods
        function obj = rlLQTAgentOptions(varargin)
            obj = obj@rl.option.AgentGeneric(varargin{:});
            
            parser = obj.Parser;
            addParameter(parser, 'StepNumPerIteration', 10);
            addParameter(parser, 'StopExplorationValue', 0);
            addParameter(parser, 'SaveExperiences', false);
            addParameter(parser, 'NoiseOptions', rl.option.UniformActionNoise);
            
            
            parse(parser, varargin{:});
            obj.Parser = parser;
            obj.StepNumPerIteration = parser.Results.StepNumPerIteration;
            obj.StopExplorationValue = parser.Results.StopExplorationValue;
            obj.SaveExperiences = parser.Results.SaveExperiences;
            obj.DiscountFactor =  parser.Results.DiscountFactor;
            obj.NoiseOptions = parser.Results.NoiseOptions;
        end

        % Varidate functions
        function obj = set.StepNumPerIteration(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'integer', 'positive', 'finite'}, '', 'StepNumPerIteration');
            obj.StepNumPerIteration = value;
        end
        
        function obj = set.StopExplorationValue(obj, value)
            validateattributes(value, {'numeric'}, {'scalar', 'real', 'nonnegative', 'finite'}, '', 'StopExplorationValue');
            obj.StopExplorationValue = value;
        end
        
        function obj = set.SaveExperiences(obj, value)
            validateattributes(value, {'logical'}, {'scalar'}, '', 'SaveExperiences');
            obj.SaveExperiences = value;
        end
        
        function obj = set.NoiseOptions(obj,Value)
            validateattributes(Value,{'rl.option.OrnsteinUhlenbeckActionNoise','rl.option.GaussianActionNoise','rl.option.UniformActionNoise'},{'scalar'},'','NoiseOptions');
            obj.NoiseOptions = Value;
        end    
        
    end
end
