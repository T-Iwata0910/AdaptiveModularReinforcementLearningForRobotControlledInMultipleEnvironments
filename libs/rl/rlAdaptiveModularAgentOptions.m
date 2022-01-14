function Options = rlAdaptiveModularAgentOptions(varargin)
% rlAdaptiveModularAgentOptions: Create options for AdaptiveModularAgent
%
%   OPT = rlAdaptiveModularAgentOptions returns the default options for
%   AdaptiveModularAgent.
%
%   OPT = rlAdaptiveModularAgentOptions('Option1',Value1,'Option2',Value2,...) uses name/value
%   pairs to override the default values for 'Option1','Option2',...
%
%   Supported Options are:
%
%   Vigilance           This value is vigilance value.
%   LearningPeriod      Update frequency of policy and value function
%   SaveExperiences     Save experiences when this option is set to true. 
%
%   See also: rlAdaptiveModularAgent, rlLQTAgent, rlLQTAgentOptions

Options = rl.option.rlAdaptiveModularAgentOptions(varargin{:});
end