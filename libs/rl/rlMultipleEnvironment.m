function env = rlMultipleEnvironment(subEnv, contextSequence, options)
arguments
    subEnv (1, :) cell
    contextSequence (:, 1) double {mustBePositive, mustBeInteger}
    options.InitialStateDistributionContext = 1;
end
env = rl.env.rlMultipleEnvironment(subEnv, contextSequence, "InitialStateDistributionContext", options.InitialStateDistributionContext);
end