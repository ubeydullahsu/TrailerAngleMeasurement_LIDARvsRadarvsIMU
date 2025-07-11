
%% MAIN SIMULATION FILE %%
% Trailer Angle Measurement: LIDAR, Radar and IMU Comparison
% run this file

clear all; clc; close all;

% load simulation parameters
parameters;

% LIDAR model
lidar;

% Radar model
radar;

% IMU model
imu;

%------------------------------------------------------------------------------------

% SIMULATION
% figure for animation
f = figure('Position', [100, 100, 1400, 800], 'Color', 'w');
movegui(f, 'center');

% Main animation
subplot(2,3,[1,2,4,5]);
hold on; grid on; axis equal;
xlabel('X (m)'); ylabel('Y (m)');
title('Trailer Angle Measurement Simulation');
xlim([-2, 20]); ylim([-5, 10]);

% Graphs
subplot(2,3,3);
hold on; grid on;
title('Angle Comparison');
xlabel('Time (s)'); ylabel('Angle (degree)');

subplot(2,3,6);
hold on; grid on;
title('Absolute Error');
xlabel('Time (s)'); ylabel('Error (degree)');

% Animation loop
for i = 1:length(t)
    % Current angle
    angle = hitch_angle_truth(i);

    %% Calculate vehicle geometry
    % Truck (red)
    truck_pos = [0, 0;
                 truck_length, 0;
                 truck_length, trailer_width;
                 0, trailer_width];

    % Hitch point
    hitch_point = [truck_length, trailer_width/2];

    % Trailer (blue)
    rot_mat = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];
    trailer_base = [0, -trailer_width/2;
                   trailer_length, -trailer_width/2;
                   trailer_length, trailer_width/2;
                   0, trailer_width/2];
    trailer_pos = (rot_mat * trailer_base')' + hitch_point;

    %% Draw main animation
    subplot(2,3,[1,2,4,5]); cla; hold on; grid on;

    % Truck and tyrailer
    fill(truck_pos(:,1), truck_pos(:,2), 'r', 'FaceAlpha', 0.7);
    fill(trailer_pos(:,1), trailer_pos(:,2), 'b', 'FaceAlpha', 0.7);

    % Hitch point
    plot(hitch_point(1), hitch_point(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');

    % LIDAR points
    angle_lidar_current = angle_lidar(i);
    rot_mat_lidar = [cosd(angle_lidar_current) -sind(angle_lidar_current);
                     sind(angle_lidar_current) cosd(angle_lidar_current)];
    trailer_base_lidar = [0, -trailer_width/2;
                          trailer_length, -trailer_width/2;
                          trailer_length, trailer_width/2;
                          0, trailer_width/2];
    trailer_lidar = (rot_mat_lidar * trailer_base_lidar')' + hitch_point;

    % Radar vector
    front_radar = [hitch_point(1) + trailer_length*cosd(angle_radar(i)),
                   hitch_point(2) + trailer_length*sind(angle_radar(i))];

    % Sensor visualization
    plot(trailer_lidar(:,1), trailer_lidar(:,2), 'm--', 'LineWidth', 1.5);
    quiver(hitch_point(1), hitch_point(2), ...
           trailer_length*cosd(angle_radar(i)), trailer_length*sind(angle_radar(i)), ...
           'g', 'LineWidth', 2, 'MaxHeadSize', 1);

    % Angle infos
    text(0, -3, sprintf('Actual Angle: %.1f°', angle), 'FontSize', 12);
    text(0, -4, sprintf('LIDAR: %.1f° (Error: %.1f°)', angle_lidar(i), abs(angle_lidar(i)-angle)), 'Color', 'm');
    text(0, -5, sprintf('Radar: %.1f° (Error: %.1f°)', angle_radar(i), abs(angle_radar(i)-angle)), 'Color', 'g');
    text(0, -6, sprintf('IMU: %.1f° (Error: %.1f°)', angle_imu(i), abs(angle_imu(i)-angle)), 'Color', 'b');

    % Axis and title
    xlim([-2, 20]); ylim([-7, 10]);
    title(sprintf('Trailer Angle Measurement (t = %.1f s)', t(i)));
    legend('Truck', 'Trailer', 'Hitch', 'LIDAR Predict', 'Radar Predict', 'Location', 'northeast');

    %% Update grtaphs
    % Comparison graph
    subplot(2,3,3);
    if i == 1
        p_truth = plot(t(i), hitch_angle_truth(i), 'k', 'LineWidth', 2);
        p_lidar = plot(t(i), angle_lidar(i), 'm--');
        p_radar = plot(t(i), angle_radar(i), 'g-.');
        p_imu = plot(t(i), angle_imu(i), 'b:');
        legend([p_truth, p_lidar, p_radar, p_imu], ...
               {'Actual', 'LIDAR', 'Radar', 'IMU'}, 'Location', 'best', 'AutoUpdate','off');
    else
        plot(t(1:i), hitch_angle_truth(1:i), 'k', 'LineWidth', 2);
        plot(t(1:i), angle_lidar(1:i), 'm--');
        plot(t(1:i), angle_radar(1:i), 'g-.');
        plot(t(1:i), angle_imu(1:i), 'b:');
    end
    xlim([0, t_sim]);

    % Error Graph
    subplot(2,3,6);
    if i == 1
        p_lidar_err = plot(t(i), abs(angle_lidar(i)-angle), 'm');
        p_radar_err = plot(t(i), abs(angle_radar(i)-angle), 'g');
        p_imu_err = plot(t(i), abs(angle_imu(i)-angle), 'b');
        legend([p_lidar_err, p_radar_err, p_imu_err], ...
               {'LIDAR Error', 'Radar Error', 'IMU Error'}, 'Location', 'best', 'AutoUpdate','off');
    else
        plot(t(1:i), abs(angle_lidar(1:i)-hitch_angle_truth(1:i)), 'm');
        plot(t(1:i), abs(angle_radar(1:i)-hitch_angle_truth(1:i)), 'g');
        plot(t(1:i), abs(angle_imu(1:i)-hitch_angle_truth(1:i)), 'b');
        
    end
    xlim([0, t_sim]);

    % Animation speed control
    pause(dt/animation_speed);
end

%% PERFORMANCE ANALYSIS
% Error calculations
rmse_lidar = sqrt(mean((angle_lidar - hitch_angle_truth).^2));
rmse_radar = sqrt(mean((angle_radar - hitch_angle_truth).^2));
rmse_imu = sqrt(mean((angle_imu - hitch_angle_truth).^2));

% Show results
fprintf('### PERFORMANCE COMPARISON ###\n');
fprintf('LIDAR: RMSE = %.3f°\n', rmse_lidar);
fprintf('Radar: RMSE = %.3f°\n', rmse_radar);
fprintf('IMU  : RMSE = %.3f°\n', rmse_imu);
