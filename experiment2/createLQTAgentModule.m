function agent = createLQTAgentModule(observationInfo, actionInfo, agentOpts, moduleAgents, evaluateValues)
    arguments
        observationInfo (1, 1)
        actionInfo (1, 1)
        agentOpts (1, 1)
        moduleAgents
        evaluateValues
    end
    if isempty(moduleAgents) || isempty(evaluateValues)
        agent = rl.agent.rlLQTAgentModule(observationInfo, actionInfo, agentOpts);
    else
        [~, idx] = max(evaluateValues);
        K0 = moduleAgents{idx}.K;
        agent = rl.agent.rlLQTAgentModule(observationInfo, actionInfo, agentOpts, K0);
    end
end