# SCR_run.R（两个 feat）

library(spdep)
library(SparseM)
library(MASS)
source("D:/wanghanbin/Linear Regression Tree/code/comparision_paper/SCR/SCR-function.R")   # 确保路径正确

data_file <- "D:/wanghanbin/Linear Regression Tree/code/comparision_paper/Data/dis_con_2_coef.txt"
df <- read.table(data_file, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# 空间权重矩阵 W（4 最近邻二值权重）
coords <- as.matrix(df[, c("x_coord", "y_coord")])
knn4  <- knearneigh(coords, k = 4)
nb4   <- knn2nb(knn4)
Wmat  <- nb2mat(nb4, style = "B", zero.policy = TRUE)  # binary weights
Wsp   <- as(Wmat, "sparseMatrix")

Y  <- df$y
X  <- as.matrix(df[, c("feat1", "feat2")])
Sp <- coords  # 空间坐标

# SCR
res <- SCR(
  Y      = Y,
  X      = X,
  W      = Wsp,
  Sp     = Sp,
  G      = 5,           # 分组数
  Phi    = 1,           # 空间平滑参数
  fuzzy  = FALSE,
  family = "gaussian"
)

# 每个点的 group 与位置系数 sBeta
# 抓取所有 feat 列名
feat_names <- grep("^feat", names(df), value = TRUE)

# res$sBeta 是 n × (p+1) 的矩阵，第一列为截距，其后依次为各特征
beta_df <- as.data.frame(res$sBeta)
colnames(beta_df) <- c("intercept", paste0("beta_", feat_names))

out_df <- cbind(
  df[, c("u", "v", "x_coord", "y_coord")],
  group = res$group,
  beta_df
)

write.table(
  out_df,
  file      = "D:/wanghanbin/Linear Regression Tree/code/comparision_paper/SCR/SCR_dis_con_2_coef.txt",
  sep       = "\t",
  row.names = FALSE,
  quote     = FALSE
)

# 写出各组的全局系数 Beta (optional)
beta_mat <- res$Beta
# 为行命名 Intercept + feat1, feat2
rownames(beta_mat) <- c("Intercept", feat_names)
write.table(
  beta_mat,
  file      = "D:/wanghanbin/Linear Regression Tree/code/comparision_paper/SCR/SCR_dis_con_2_coef_coef.txt",
  sep       = "\t",
  quote     = FALSE
)

message("SCR completed：\n",
        "result in: SCR_circle_diff_err_point.txt\n",
        "group result in: SCR_circle_diff_err_group_coef.txt")
