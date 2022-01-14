function env = rlDiscreteLQTEnv(Ad, Bd, Cd, Fd, Q, R, varargin)

env = rl.env.rlDiscreteLQTEnv(Ad, Bd, Cd, Fd, Q, R, varargin{:});

end