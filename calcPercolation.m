function [path_stats] = calcPercolation2(fibers, XmaxBndNodes, XminBndNodes, YmaxBndNodes, YminBndNodes, ZmaxBndNodes, ZminBndNodes)
% Construct graph
G = graph(fibers(:,1), fibers(:,2));

all_bound_nodes = [XmaxBndNodes, XminBndNodes, YmaxBndNodes, YminBndNodes, ZmaxBndNodes, ZminBndNodes];

d = distances(G); % get shortest path distances matrix 

% Query for x boundaries
d_xBnds = d(XmaxBndNodes, XminBndNodes); 
avg_segments_x = mean(d_xBnds(:));
max_segments_x = max(d_xBnds(:)); 
min_segments_x = min(d_xBnds(:));

% Query for y boundaries
d_yBnds = d(YmaxBndNodes, YminBndNodes); 
avg_segments_y = mean(d_yBnds(:));
max_segments_y = max(d_yBnds(:)); 
min_segments_y = min(d_yBnds(:));

% Query for z boundaries 
d_zBnds = d(ZmaxBndNodes, ZminBndNodes); 
avg_segments_z = mean(d_zBnds(:));
max_segments_z= max(d_zBnds(:)); 
min_segments_z = min(d_zBnds(:));

path_stats = [avg_segments_x, max_segments_x, min_segments_x, ...
    avg_segments_y, max_segments_y, min_segments_y, ...
    avg_segments_z, max_segments_z, min_segments_z];

end