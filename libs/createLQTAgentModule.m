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
        K0 = -getPolicyParams(moduleAgents{idx})';
        agent = rl.agent.rlLQTAgentModule(observationInfo, actionInfo, agentOpts, K0);
        agent.MaxSteps = moduleAgents{1}.MaxSteps;
        reset(agent);
    end
end