% Aligns network. Run after remove_free_fibers
% Find fibers in center layer


clear n_nodes n_fibers i j count new_fibers fib_reg;

coll_frac = 0.386;
elas_frac = 0.614;

cth = 0.93;
cz = 0.07;
% Put in check for max orientation
t = 2;

eth = 0.5;
ez = 0.5;

[n_nodes, ~] = size(nodes);
[n_fibers, ~] = size(fibers);

is_midfiber = zeros(n_fibers,1);
count = 0;
alignment = zeros(n_fibers,3);

for i = 1:n_fibers
   
    node1 = fibers(i,1);
    node2 = fibers(i,2);
    
    z1 = nodes(node1,3);
    z2 = nodes(node2,3);
    
    del_x = nodes(node1,1) - nodes(node2,1);
    del_y = nodes(node1,2) - nodes(node2,2);
    del_z = nodes(node1,3) - nodes(node2,3);
    
    total_len = sqrt(del_x*del_x + del_y*del_y + del_z*del_z);
    
    % Calculate alignment of every fiber. cos^2(a) values
    
    alignment(i,1) = (del_x/total_len)^2;
    alignment(i,2) = (del_y/total_len)^2;
    alignment(i,3) = (del_z/total_len)^2;
    
    if (z1 == 0 && z2 == 0)
         
        is_midfiber(i,1) = 1;
        count = count + 1;
        center_fibs(count,1) = i;
        
    end
    
end

Ncoll = floor(coll_frac * count);
% Nelas = floor(elas_frac * count);
% Define fiber type matrix
% 1 for collagen
% 2 for elastin
% 3 for fibrillin
% 0 fibers to be removed (?)


fib_type = zeros(n_fibers,1);
range = 1;

[m,~] = find(alignment(center_fibs,t) > range*cth, Ncoll);

while (length(m) ~= Ncoll)
    
    range = 9*(range/10);
    
    [m,~] = find(alignment(center_fibs,t) > range*cth, Ncoll);
    
end

fib_type(m) = 1;

for i = 1:n_fibers
    
    if (is_midfiber(i) == 1 && fib_type(i) ~= 1)
        
            
            fib_type(i,1) = 2;
            

    end
    
    if is_midfiber(i,1) == 0
        
        if alignment(i,t) >= 0.6
            
            prob = 0.9;
            
        else
            
            prob = 0.2;
        end
        
        outcome = rand();
        
        if outcome < prob
            
            fib_type(i,1) = 3;
            
        else
            fib_type(i,1) = 0;
        end

    end
    
    
end

% [m,~] = find(fib_type > 0);
% 
% fib_reg = zeros(length(m),1);
% new_fibers = zeros(length(m),2);
j = 1;

for i = 1:n_fibers
   
    if ~(fib_type(i) == 0)
        
        fib_reg(j) = fib_type(i);
        new_fibers(j,:) = fibers(i,:);
        j = j + 1;
    end
      
end

% Measure alignment of network
if 1 == 1
    avgc = [0,0,0];
    avge = [0,0,0];
    avgf = [0,0,0];
    
    E = 0;
    F = 0;
    C = 0;
    
    for i = 1:n_fibers
        if fib_type(i) == 1
            avgc = avgc + alignment(i,:);
            C = C + 1;
        elseif fib_type(i) == 2
            avge = avge + alignment(i,:);
            E = E + 1;
        elseif fib_type(i) == 3
            avgf = avgf + alignment(i,:);
            F = F + 1;
        end
    end
    
    avgc = avgc./C;
    avge = avge./E;
    avgf = avgf./F;
end

clear elas_frac coll_frac m range Ncoll prob outcome;
