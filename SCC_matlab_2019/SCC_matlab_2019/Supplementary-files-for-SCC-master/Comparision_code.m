%% SCC 代码路径
addpath(genpath('D:\wanghanbin\Linear Regression Tree\code\comparision_paper\SCC_matlab_2019\SCC_matlab_2019\Supplementary-files-for-SCC-master'));

infile = 'D:\wanghanbin\Linear Regression Tree\code\comparision_paper\Data\voronoi_data.txt';
T = readtable(infile, 'FileType','text','Delimiter','\t');
%T.orig_region = T.region;       % 保留原来的真值区域标签
n = height(T);

%% 提取坐标、特征和响应
lon   = T.x_coord;
lat   = T.y_coord;
feat1 = T.feat1;
feat2 = T.feat2;
y     = T.y;

X2d       = [feat1, feat2, ones(n,1)];     % 最后一列是截距
p         = size(X2d,2);                   % p = 3
x3d       = reshape(X2d, [1, n, p]);       % [sim_num=1, n, p] 储存多次模拟实验结果（如果一次sim_num = 1)
y2d       = reshape(y,     [1, n]);        % [sim_num=1, n]
beta_true = [T.coef1, T.coef2, T.coef0];    % [n × p]
sim_num   = 1;

%% 4. 设置选项并跑 SCC_spatial_regression
opts.intercept_type = 1;   % X 的最后一列是空间变化截距
% 其它 opts（lambda、BIC）都用默认值
[beta_hat_3d, ~] = SCC_spatial_regression( ...
    x3d, y2d, lon, lat, beta_true, sim_num, opts);
beta_hat = squeeze(beta_hat_3d);  % → [n × p]，列依次是 [feat1_coef, feat2_coef, intercept]

%% 5. 基于 MST 上“系数相等”做连通分量标号
D       = squareform(pdist([lon, lat]));    % 空间距离
Gfull   = graph(D);
Tmst    = minspantree(Gfull);               % 最小生成树
edges   = Tmst.Edges.EndNodes;               % 每行：一条边的两个顶点
tol     = 1e-6;
isFused = arrayfun(@(k) ...
    norm(beta_hat(edges(k,1),:) - beta_hat(edges(k,2),:)) < tol, ...
    (1:size(edges,1))')';
H       = graph(edges(isFused,1), edges(isFused,2), [], n);
group   = conncomp(H)';                      % 得到 1×n，再转成 n×1


T.group      = group;
T.intercept  = beta_hat(:,3);
T.beta_feat1 = beta_hat(:,1);
T.beta_feat2 = beta_hat(:,2);

Tout = T(:, {'u','v','x_coord','y_coord', ...
             'group', ...
             'intercept','beta_feat1','beta_feat2'});

outfile = 'D:\wanghanbin\Linear Regression Tree\code\comparision_paper\SCC_matlab_2019\voronoi_data_SCC.txt';
writetable(Tout, outfile, 'Delimiter','\t');
