%% SIMULATION PARAMETERS %%

dt = 0.1;               % sampling time (s)
t_sim = 10;             % simulation time (s)
t = 0:dt:t_sim;          % time vector

% Actual trailer angle (time-variant)
A0 = 15;                % average angle (degree)
A1 = 10;                % oscillation (degree)
f = 0.2;                % oscillation frequency
hitch_angle_truth = A0 + A1*sin(2*pi*f*t);

% vehicle size in meters
truck_length = 3.5;   
trailer_length = 8;
trailer_width = 2.6;

% sensor noise parameters
lidar_noise = 0.01;     % lidar measurement noise (m)
radar_noise = 0.2;     % radar measurement noise (m)
gyro_noise = 0.01;      % gyroscope noise (degree/s)
gyro_bias = 0.02;       % gyroscope bias (degree/s)

% visualization configs
animation_speed = 2;    % 1 = real-time

