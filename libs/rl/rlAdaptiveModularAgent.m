function Agent = rlAdaptiveModularAgent(varargin)
    % rlAdaptiveModularAgent: Create a Adaptive Modular Agent.
    %
    % agent = rlAdaptiveModularAgent(AGENTCELLS) creates a Adaptive Modular
    % Agent with default options
    % AGENT = RLADAPTIVEMODULARAGENT(CREATEMODULEFCNHANDULLE, AGENTOPTIONS)
    % AGENT = RLADAPTIVEMODULARAGENT(CREATEMODULEFCNHANDULLE, AGENTOPTIONS, "INITIALMODULEAGENT", VALUE)
    
    % 
    % ver1.0.0 2020-09-08 T.Iwata Test create.
    %
    % Copyright(C) 2020 - T.Iwata All right reserved.
    
    Agent = rl.agent.rlAdaptiveModularAgent(varargin{:});
end