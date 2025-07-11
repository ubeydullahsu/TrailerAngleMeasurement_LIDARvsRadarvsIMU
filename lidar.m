%% LIDAR MODEL %%
%-----------------------------------------------------------
% Point Cloud: P = [x1,y1; x2,y2; ...; xn,yn]
% Covariance Matrix: C = cov(P)
% Eigenvectors: [V,D] = eig(C)
% Major axis: v1 (vector corresponding to the largest eigenvalue)
% Angle: θ = atan2(v1y, v1x)
%-----------------------------------------------------------

angle_lidar = zeros(size(t));

for i = 1:length(t)

    % Calculate trailer corner points
    angle = hitch_angle_truth(i);
    rot_mat = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];

    % Create a basic rectangle and calculate it
    trailer_base = [0, 0;
                   trailer_length, 0;
                   trailer_length, trailer_width;
                   0, trailer_width];

    % Rotate and shift
    trailer_corners = (rot_mat * trailer_base')';
    trailer_corners = trailer_corners + [truck_length, trailer_width/2];

    % Generate point cloud (and add noise)
    num_points = 100;
    points = zeros(num_points, 2);
    for j = 1:num_points
        % Select random point
        edge_idx = randi(4);
        p1 = trailer_corners(edge_idx, :);
        p2 = trailer_corners(mod(edge_idx,4)+1, :);

        % Random location on the edge
        alpha = rand;
        point = p1 + alpha*(p2 - p1);

        % Add noise
        points(j, :) = point + lidar_noise*randn(1,2);
    end

    % Calculate angle using PCA
    coeff = pca(points);
    angle_lidar(i) = atan2d(coeff(2,1), coeff(1,1));

end