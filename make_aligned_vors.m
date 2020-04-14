function [nodes_old, nodes, fibers_old, fibers] = make_aligned_vors()
% make many aligned vors

%CHECK
%that saving networks to the right directory if you want to save them to a directory
%if saving images, check that they're not erasing other important images

% Updated 7-20-17 to include global points_seed parameter to adjust volume
% fraction, LMB

global points_seed N lambdax lambday lambdaz boundaries rotation_angle rotation_axis 

xmin = boundaries(1);
xmax = boundaries(2);
ymin = boundaries(3);
ymax = boundaries(4);
zmin = boundaries(5);
zmax = boundaries(6);

pts_xyz =(2.0 .* rand(points_seed, 3) - 1.0); % N random pts from -1 to +1

[nodes_old, fibers_old] = make_vor(pts_xyz); % fnxn in netmat

% geometrically stretch fibers in x/y/z
nodes_old(:,1)=nodes_old(:,1)*lambdax; %nodes is N x 3 for N nodes
nodes_old(:,2)=nodes_old(:,2)*lambday;
nodes_old(:,3)=nodes_old(:,3)*lambdaz;

% Rotate networks as needed - Added 8-9-17 LMB 
if rotation_angle ~= 0 % If need to rotate angles
    if strcmp(rotation_axis, 'X')
        nodes_old = rotate_nodes(nodes_old, [rotation_angle 0 0]);
    elseif strcmp(rotation_axis, 'Y')
        nodes_old = rotate_nodes(nodes_old, [0 rotation_angle 0]);
    elseif strcmp(rotation_axis, 'Z')
        nodes_old = rotate_nodes(nodes_old, [0 0 rotation_angle]);
    end
end

clipbox = [xmin, xmax, ymin, ymax, zmin, zmax]; % xmin xmax ymin ymax zmin zmax
[nodes, fibers] = clip_net(nodes_old, fibers_old, clipbox); % fnxn in netmat

% get giant network
[nodes, fibers] = get_giant(nodes, fibers);


end