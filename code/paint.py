#参考程序 https://blog.csdn.net/wayjj/article/details/72809344

import matplotlib.pyplot as plt
import numpy as np

# 画布大小
# plt.figure(figuresize = (10,10))

# x, y的坐标
x=[0,0.5,1,0]
y=[0,0.3,1,0]

# matplotlib画折线图
plt.plot(x,y,color='black')

# matplotlib画散点图
plt.scatter(x,y,color='red',s=10)

# 画出来
plt.show()
