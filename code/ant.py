
import numpy as np
import matplotlib.pyplot as plt

# 给出城市数据
# x[i],y[i]表示第i个城市的x,y坐标
# C=np.array([[1,2],[70,90],[80,60],[10,100],[800,200],[800,100],[90,80],[200,600],[230,4],[500,90]])
x = [1,70,80,10,800,800,90,200,230,500]
y = [2,90,60,100,200,100,80,600,4,90]

# 参数 城市数量 蚂蚁数量 
# 信息素变化参数
n = len(x)
m = 10
alpha,beta,rou = 1,5,0.5

# 计算 距离矩阵 和 启发矩阵 和 信息浓度矩阵
d,e=[],[]
for i in range(n):
    temp_d,temp_e = [],[]
    for j in range(n):
        distance = np.sqrt((x[i]-x[j])*(x[i]-x[j])+(y[i]-y[j])*(y[i]-y[j]))
        temp_d.append(distance)
        temp_e.append(1.0 / distance)
    d.append(temp_d)
    e.append(temp_e)
    e[i][i] = 1000

d=np.array(d)
e=np.array(e)
t=np.ones((n,n))

# 初始化路径矩阵
# routes[i,j]表示第i只蚂蚁在第j步爬到了第routes[i,j]个城市
routes = np.zeros((m,n))

t = 0
# 100次循环
while t < 100:
    t += 1
    # 第i只蚂蚁
    for i in range(m):
        # 第一个城市是随机选择的
        city = np.random.randint(n)
        routes[i,0] = city
        visited = [city]
        # 第二个城市开始是按信息素选取的
        for j in range(2,n):



    


