%%% Script to create networks with a certain volume fraction 
%%% Written by Lauren Bersie, 7-19-17
%%% Updated 3-1-2020 to have equations for quickly finding seed point numbers, 
%%% GUI control, and network rotations

% DEPENDENCIES: make_aligned_dels_LB, calc_lens, plot_net
function create_volfract(net_name, net_type, num_nets, rve_len, target_vol_fract, align_dir, net_align, net_rot, rot_axis, save_path, fiber_rad, write_convert, save_image, netfile_type, net_stats)
global prog_box points_seed dim N lambdax lambday lambdaz boundaries rotation_angle rotation_axis fpath ftype x fiber_radius net_fname

% Set parameters for network generation
if ~isempty(save_path)
    fpath = save_path;
else
    fpath = pwd;
end

% Initialize variables and determine scaling parameters for seed points
ftype= netfile_type;
net_fname = net_name;
dim = 3; % 3D networks
boundaries = [-0.5 0.5 -0.5 0.5 -0.5 0.5]; % RVE boundaries in computational units
vf_tol = 1e-3; % Tolerance for final volume fraction. This ~ volume of one fiber
x = rve_len * 1e-6; % Dimensionalize to be in m- currently um (Change later)
fiber_radius = fiber_rad * 1e-9; % Dimensionalize to be in m- currently nm
rad_incr = fiber_radius/100e-9; % Equations for seed points based on r=100 nm. Will need to scale accordingly
x_incr = x/20e-6; % Equations for seed points based on dim of 20e-6. Will need to scale accordingly
vf_incr = target_vol_fract/0.04; %Equations for seed points based on vf of 0.04. Will need to scale accordingly
rotation_angle = net_rot;
rotation_axis = rot_axis;
fib_type = []; % Only one fiber type currently supported

% Calculate network stretch needed for desired alignment
if strcmp(align_dir, 'X')
        lambdax = 0.3716*exp(3*net_align);
        lambday = 1;
        lambdaz = 1;

elseif strcmp(align_dir, 'Y')
        lambdax = 1;
        lambday = 0.3716*exp(3*net_align);
        lambdaz = 1;

elseif strcmp(align_dir, 'Z')
        lambdax = 1;
        lambday = 1;
        lambdaz = 0.3716*exp(3*net_align);
end

if strcmp(net_type, 'Delaunay')  
    % Calculate number of seed points needed for given volume fraction
    if strcmp(align_dir, 'X')
            points_seed = ((2691*log(lambdax)) + 3063) * vf_incr * (x_incr^3) * rad_incr;
            
    elseif strcmp(align_dir, 'Y')
            points_seed = ((2691*log(lambday)) + 3063) * vf_incr * (x_incr^3) * rad_incr;

    elseif strcmp(align_dir, 'Z')
            points_seed = ((2691*log(lambdaz)) + 3063) * vf_incr * (x_incr^3) * rad_incr;
    end
    
elseif strcmp(net_type, 'Voronoi')
    % Calculate number of seed points needed for given volume fraction
    if strcmp(align_dir, 'X')
            points_seed = ((6051*log(lambdax)) + 6606) * vf_incr * (x_incr^3) * rad_incr;

    elseif strcmp(align_dir, 'Y')
            points_seed = ((6051*log(lambday)) + 6606) * vf_incr * (x_incr^3) * rad_incr;

    elseif strcmp(align_dir, 'Z')
            points_seed = ((6051*log(lambdaz)) + 6606) * vf_incr * (x_incr^3) * rad_incr;
    end
    
end

points_seed = round(points_seed); % Adjust initial guess to make faster

% Make networks
length_vect = zeros(1,num_nets);

for j = 1:num_nets % Create j networks
    N = j;
    % Update progress bar 
    %prog_box.Value = j/num_nets; 
    %message = sprintf('Creating network %i of %i. . .', N, num_nets);
    %prog_box.Message = message;

    % Create network based on initial # of seed points     
    if strcmp(net_type, 'Delaunay') 
        [nodes_old, nodes, fibers_old, fibers] = make_aligned_dels();
    elseif strcmp(net_type, 'Voronoi')
        [nodes_old, nodes, fibers_old, fibers] = make_aligned_vors(); 
    end

    % Determine the volume fraction of the network and compare to target
    nodes1D = conv_2D_2_lin(nodes); % Reshape into 1D array
    fibers1D = conv_2D_2_lin(fibers); % Reshape into 1D array
    [lens] = calc_lens(nodes1D, fibers1D); % Returns lengths of every fiber
    total_len = sum(lens);
    % Calculate volume fraction    
    total_vf = (total_len*pi*(fiber_radius^2))/((x^2)) 
    count=0; 

    while abs(target_vol_fract - total_vf) > vf_tol
        if (target_vol_fract - total_vf) > 0 % Need to add fibers.
            clear fibers_old nodes_old
            message = sprintf('Creating network %i of %i. . . Adding fibers', N, num_nets);
            %prog_box.Message = message;
            points_seed = points_seed + 5; % Add 5 seed points to create more fibers
            
            if strcmp(net_type, 'Delaunay') 
                [nodes_old, nodes, fibers_old, fibers] = make_aligned_dels();
            elseif strcmp(net_type, 'Voronoi')
                [nodes_old, nodes, fibers_old, fibers] = make_aligned_vors(); 
            end
            
        elseif (target_vol_fract - total_vf) < 0 % Need to remove fibers.
            clear fibers_old nodes_old
            clear fibers_old nodes_old
            message = sprintf('Creating network %i of %i. . . Removing fibers', N, num_nets);
            points_seed = points_seed - 5; % Remove 3 seed points to get rid of fibers
            
            if strcmp(net_type, 'Delaunay') 
                [nodes_old, nodes, fibers_old, fibers] = make_aligned_dels();
            elseif strcmp(net_type, 'Voronoi')
                [nodes_old, nodes, fibers_old, fibers] = make_aligned_vors(); 
            end
        end

        % Determine the volume fraction of the network and compare to target
        nodes1D = conv_2D_2_lin(nodes); % Reshape into 1D array
        fibers1D = conv_2D_2_lin(fibers); % Reshape into 1D array
        [lens] = calc_lens(nodes1D, fibers1D); % Returns lengths of every fiber
        total_len = sum(lens);
        total_vf = (total_len*pi*(fiber_radius^2))/((x^2)) 

        count=count+1;
    end
    
    length_vect(j) = total_len;
    
    % Plot to confirm
    plot_net(nodes, fibers);
    
    % Save image of network
    if save_image == 1      
        filename_jpg = sprintf('%s_%i.jpg', net_name, j); %save jpg image
    	saveas(gca,fullfile(fpath,filename_jpg));

    %     filename_fig=sprintf('%s%d.jpg', net_name, j); %save fig image
    %     saveas(gca,fullfile(fpath,filename_fig));
    end
    
    close % Close network figure

    % Double check network orientations to see that rotation is working
    %fiber_orient_dist(nodes, fibers); % Creates orientation tensor
    [R] = calc_orient(nodes, fibers)

    % Write network to file
    fprintf('Writing info to new file... \n')
    if strcmp(netfile_type, 'Text File')  % Text file
        fnm = sprintf('%s%s%i%s', net_name, '_', j, '.txt');
        put_net(nodes, fibers, fnm, fib_type);

    elseif strcmp(netfile_type, '.mat File') % Mat file
        fnm = sprintf('%s%s%i%s', net_name, '_', j, '.mat');
        save (fullfile(fpath, fnm), 'nodes', 'fibers');
    end

end

% Run network statistics on networks created
if net_stats == 1
    calc_net_params();  
end

% Write text file with convert and radius values for VF
if write_convert == 1
    convert = mean(length_vect)/(x^2);
    
    fnm3 = sprintf('%s%s%s%s', net_name, '_', 'INFO', '.txt');
    filename3 = fnm3;
    fileid3 = fopen(fullfile(fpath, filename3), 'w'); % writes over any existing file
    fprintf(fileid3,'%s %d \n', 'Convert value:', convert);
    fclose(fileid3);
end


%close(prog_box);

end
