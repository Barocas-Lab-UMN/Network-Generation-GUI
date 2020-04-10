function [entropy] = calc_entropy(nodes)
    % Written by Lauren Bersie-Larson, 12-3-2018
    % Takes the INTERNAL nodes of a network and calculates the entropy (or std dev)
    % of the nodes in order to examine how spatially distributed the
    % network is
    
    boundaries = [-0.5 +0.5 -0.5 +0.5 -0.5 +0.5];
    %% Discretize network into sections
    num = 3; % How many sections per dimension will be created
    side_len = 1/num;
    
    % Create list of x,y,z boundaries of each section of the network ("edges")
    edges = [];
    for i = 1:num
        for j = 1:num
            for k = 1:num
                edges = [edges; ...
                    boundaries(1)+(i-1)*side_len, boundaries(1)+(i)*side_len, ...
                    boundaries(3)+(j-1)*side_len, boundaries(3)+(j)*side_len,...
                    boundaries(5)+(k-1)*side_len, boundaries(5)+(k)*side_len];
            end
        end
    end

    %% Method 1: Create histogram of nodes in each section and then find the std dev
    bins = zeros(size(edges,1), 1);
%     nodes = conv_lin_2_2D(nodes, 3);
    
    for i = 1:length(nodes)
        x_coord = nodes(i,1);
        y_coord = nodes(i,2);
        z_coord = nodes(i,3);
        index = find(edges(:,1) < x_coord & edges(:,2) > x_coord & edges(:,3) < y_coord & edges(:,4) > y_coord & edges(:,5) < z_coord & edges(:,6) > z_coord);
        bins(index) = bins(index) + 1;
    end
    
    entropy = std(bins);
    
    %% Method 2: Find the Shannon entropy
end