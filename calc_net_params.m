function [stats] = calc_net_params()
% Written by Lauren Bersie-Larson, 11/20/2018
% Updated 4/8/2020 for network generation GUI
% Updated 10/24/2021 for fiber percolation and segment counting
    global N fpath ftype x fiber_radius net_fname 

    addpath(fpath) % Add directory to where network files are located
    if strcmp(ftype, '.mat File')
        file_format = '.mat';
    elseif strcmp(ftype, 'Text File')
        file_format = '.txt';
    end
    
    stats = [];
    
    for i = 1:N
        filename = sprintf('%s%s%i%s', net_fname, '_', i, file_format);
        
        if strcmp(ftype, '.mat File')
            load(filename, 'fibers', 'nodes')
            
        elseif strcmp(ftype, 'Text File')
            data = dlmread(filename);
            data = data(2:length(data),:); % Eliminate first row from fiber data
            header_info = data(1,:); 
            numfibs = header_info(3);

            fibers = data(:,2:3);

            M = data(:,4:6);
            O = data(:,7:9);
            
            nodes = zeros(max(max(fibers)),3);

            for j = 1:numfibs
                nodes(fibers(j,1),:) = M(j,:);
                nodes(fibers(j,2),:) = O(j,:);
            end
            
        end
        
        nodes = round(nodes, 6);
        tot_num_nodes = length(nodes);
        boundaries = [-0.5 0.5 -0.5 0.5 -0.5 0.5];

        num_fibs = length(fibers);
        omega = calc_orient(nodes, fibers);
        omega_xx = omega(1,1);
        omega_yy = omega(2,2);
        omega_zz = omega(3,3);
        
        % Calculate volume fraction
        nodes = conv_2D_2_lin(nodes);
        fibers = conv_2D_2_lin(fibers);
        avg_len = mean(calc_lens(nodes, fibers));
        total_len = sum(calc_lens(nodes, fibers));
        vol_fract = (total_len*pi*(fiber_radius^2))/(x^2);
        
        % Calculate connectivity
        [bnd_nodes, x_pos_nums, x_neg_nums, y_pos_nums, y_neg_nums, ...
    z_pos_nums, z_neg_nums] = find_boundary_nodes_verbose(nodes,boundaries);
        int_nodes = find_int_nodes(nodes, boundaries); 
        num_bnd_nodes = length(bnd_nodes);
        num_int_nodes = length(int_nodes);

        fibers = conv_lin_2_2D(fibers, 2);
        connectivity = zeros(length(nodes),1);
        for k = 1:length(int_nodes)
            l = int_nodes(k);
            connectivity(l) = nnz(fibers(:) == l);
        end
        connectivity(~any(connectivity,2),:) = [];
        conn = mean(connectivity);

        % Calculate entropy of network
        nodes = conv_lin_2_2D(nodes, 3);
        ent = calc_entropy(nodes(int_nodes, :));
        
        % Calculate average amount of fiber segments percolating from
        % boundary to boundary of the network 
        fibers = conv_lin_2_2D(fibers, 2);
        [path_stats] = calcPercolation(fibers, x_pos_nums, x_neg_nums, y_pos_nums, y_neg_nums, z_pos_nums, z_neg_nums);

        stats = [stats; omega_xx, omega_yy, omega_zz, vol_fract, ... 
            tot_num_nodes, num_bnd_nodes, num_int_nodes, num_fibs, ...
            conn, avg_len, ent, ... 
            path_stats(1), path_stats(2), path_stats(3), ...
            path_stats(4), path_stats(5), path_stats(6), ...
            path_stats(7), path_stats(8), path_stats(9)];
        
        clear nodes fibers omega connectivity conn num_int_nodes avg_len ent
    end
    
    % Write text file with stats
     fnm = 'Network_stats.txt';
     fileid2 = fopen(fnm, 'w'); % writes over any existing file

     fprintf(fileid2, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s \n',  'Omega_xx', 'Omega_yy', ...
         'Omega_zz', 'Volume Fraction', 'Total number of nodes', ...
         'Number of boundary nodes', 'Number of interior nodes', ...
         'Number of fibers', 'Connectivity', 'Average fiber length', ...
         'Entropy', 'avg_nSegments_x', 'min_nSegments_x', ... 
            'max_nSegments_x', 'avg_nSegments_y', 'min_nSegments_y', ... 
            'max_nSegments_y', 'avg_nSegments_z', 'min_nSegments_z', ...
            'max_nSegments_z');
        
      for i = 1:N
            fprintf(fileid2,'%f %f %f %f %i %i %i %i %f %f %f %f %f %f %f %f %f %f %f %f \n', ...  
            stats(i, 1), ...                  
            stats(i, 2), ...                 
            stats(i, 3), ...                
            stats(i, 4), ...    
            stats(i, 5), ...    
            stats(i, 6), ...    
            stats(i, 7), ...    
            stats(i, 8), ...   
            stats(i, 9), ...   
            stats(i, 10), ...
            stats(i, 11), ...
            stats(i, 12), ...
            stats(i,13), ...
            stats(i,14), ...
            stats(i,15), ...
            stats(i,16), ...
            stats(i,17), ...
            stats(i,18), ...
            stats(i,19), ...
            stats(i,20));                 
       end    
    fclose(fileid2);
end
