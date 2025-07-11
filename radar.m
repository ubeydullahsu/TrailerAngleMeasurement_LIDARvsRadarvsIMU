%% RADAR MODEL %%
%-----------------------------------------------------
% Front point: P_front = [x_f, y_f] = [L*cosθ, L*sinθ]
% Rear point: P_rear = [0, 0]
% Vector: V = P_front - P_rear
% Angle: θ = atan2(Vy, Vx)
%-----------------------------------------------------

angle_radar = zeros(size(t));

for i = 1:length(t)

    % Actual point locations
    angle = hitch_angle_truth(i);
    front_point = [truck_length + trailer_length*cosd(angle), ...
                  trailer_width/2 + trailer_length*sind(angle)];
    rear_point = [truck_length, trailer_width/2];

    % Noisy measurement
    front_meas = front_point + radar_noise*randn(1,2);
    rear_meas = rear_point + radar_noise*randn(1,2);

    % Calculate the vector and angle
    vector = front_meas - rear_meas;
    angle_radar(i) = atan2d(vector(2), vector(1));

end