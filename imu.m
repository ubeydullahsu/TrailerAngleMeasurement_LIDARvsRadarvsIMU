%% IMU MODEL %%
%---------------------------------------
% θ_imu[k] = θ_imu[k-1] + ω[k] * Δt
% ω[k] = (dθ_truth/dt) + bias + gürültü
%---------------------------------------

angle_imu = zeros(size(t));
gyro_bias_accum = 0;

for i = 2:length(t)

    % Actual angular velocity (derivative)
    true_angular_vel = (hitch_angle_truth(i) - hitch_angle_truth(i-1))/dt;

    % Measurement = Actual + Bias + Noise
    angular_vel_meas = true_angular_vel + gyro_bias + gyro_noise*randn;

    % Angular bias accumulation
    gyro_bias_accum = gyro_bias_accum + gyro_bias*dt;

    % Calculate the angle by integrating the angular velocity over time (θ = ∫ω dt)
    angle_imu(i) = angle_imu(i-1) + angular_vel_meas*dt;

end