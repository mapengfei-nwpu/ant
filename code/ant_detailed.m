C=[1,2;70,90;80,60;10,100;800,200;800,100;90,80;200,600;230,4;500,90];
NC_max=100;
m=18;
Alpha=1;
Beta=5;
Rho=0.5;
Q=1;
%%-------------------------------------------------------------------------
%% 主要符号说明
%% C n个城市的坐标，n×2的矩阵
%% NC_max 最大迭代次数
%% m 蚂蚁个数
%% Alpha 表征信息素重要程度的参数
%% Beta 表征启发式因子重要程度的参数
%% Rho 信息素蒸发系数
%% Q 信息素增加强度系数
%% R_best 各代最佳路线
%% L_best 各代最佳路线的长度
%%=========================================================================
 
%%第一步：变量初始化
n=size(C,1);%n表示问题的规模（城市个数）
D=zeros(n,n);%D表示完全图的赋权邻接矩阵
for i=1:n
    for j=1:n
        if i~=j
            D(i,j)=((C(i,1)-C(j,1))^2+(C(i,2)-C(j,2))^2)^0.5;
        else
            D(i,j)=eps;      %i=j时不计算，应该为0，但后面的启发因子要取倒数，用eps（浮点相对精度）表示
        end
        D(j,i)=D(i,j);   %对称矩阵
    end
end

%{

1.C就是城市坐标

             x         y

城市1    0     120     


城市2   120     0      
  

城市n   100    230 


2.运行后这里D变成了一个n*n的矩阵，每个元素代表两个城市之间的距离，比如当城市数目为3时：

D=      城市1    城市2    城市3
 
城市1   0        120      100


城市2  120       0        230 
 
城市3  100    230         0


这里D是个对角线为0的对称矩阵，因为城市1,2间距离等于城市2,1的距离，城市n与n距离设置为0


%}

Eta=1./D;          %Eta为启发因子矩阵，这里设为距离的倒数
Tau=ones(n,n);     %Tau为信息素矩阵
Tabu=zeros(m,n);   %存储并记录路径的生成，禁忌表
NC=1;               %迭代计数器，记录迭代次数
R_best=zeros(NC_max,n);       %各代最佳路线
L_best=inf.*ones(NC_max,1);   %各代最佳路线的长度

L_ave=zeros(NC_max,1);        %各代路线的平均长度

while NC<=NC_max        %停止条件之一：达到最大迭代次数，停止
%%第二步：将m只蚂蚁放到n个城市上
Randpos=[];   %随机存取
for i=1:(ceil(m/n))
Randpos=[Randpos,randperm(n)];
end

Tabu(:,1)=(Randpos(1,1:m))';    %此句不太理解？

%{

1.ceil(m/n)

假如有 10只蚂蚁，3个城市，ceil(m/n)=ceil（10/3）=4，需要安排四次，才能把这十只蚂蚁全部放到到三个城市，

每次都在行向量Randpos加入如新的元素，randperm(3)表示就是1 3 2，或者3 1 2这种随机组合，4次循环之后，

那么Randpos =


     2     3     1     1     2     3     3     1     2     3     2     1


2.Tabu(:,1)=(Randpos(1,1:m))'

总共m蚂蚁，只这里m为10，Tabu(:,1)表示Tabu第一行就是初始10只蚂蚁被随机分到所三个城市中的一个

Tabu =

     2
     3
     1
     1
     2
     3
     3
     1
     2
     3

这里只取m=10个数，因为Tabu第一列表示m只蚂蚁初始的时候随机被分在的城市，比如第一个2代表，第一只蚂蚁

最开始放在了城市2，以此类推


%}

 
%%第三步：m只蚂蚁按概率函数选择下一座城市，完成各自的周游
for j=2:n     %所在城市不计算
for i=1:m    
visited=Tabu(i,1:(j-1)); %记录已访问的城市，避免重复访问
J=zeros(1,(n-j+1));       %待访问的城市
P=J;                      %待访问城市的选择概率分布
Jc=1;                       %访问的城市个数
for k=1:n
if length(find(visited==k))==0   %开始时置0
J(Jc)=k;                           %这时记录没有访问的城市到J中
Jc=Jc+1;                         %访问的城市个数自加1
end

end


%{

1.visited=Tabu(i,1:(j-1));    向量visited记录已访问的城市，比如第一次Tabu中第一行第一个的城市2

2.J=zeros(1,(n-j+1))           向量J记录待访问的城市，已结访问城市2，还没访问1和3城市放入J向量中

3.if length(find(visited==k))==0  
判断语句，find()语句找到visited中等于k的元素在数组visited中的位置，例如数组a=[1 2 3 4 5 2],

find(a==2)=[2,6]，find(a==6)=[],则
length(find(a==6))=0
length()==0判断length()是否为零
如果为零就是visited中没有k元素，即没有访问过k城市。
这时记录没有访问的城市到J中。

%}


%下面计算待选城市的概率分布
for k=1:length(J)

P(k)=(Tau(visited(end),J(k))^Alpha)*(Eta(visited(end),J(k))^Beta);        
end
P=P/(sum(P));
%按概率原则选取下一个城市
Pcum=cumsum(P);     %cumsum，元素累加即求和
Select=find(Pcum>=rand); %若计算的概率大于原来的就选择这条路线%要选择其中总概率大于等于某一个随机数，找到大于等于这个随机数的城市的在J中的位置
to_visit=J(Select(1));  %提取这些城市的编号到to_visit中
Tabu(i,j)=to_visit;
end

end

%{

1. %visited(end)表示蚂蚁现在所在城市编号，J(k)表示下一步要访问的城市编号

2.P=P/(sum(P));把各个路径概率统一到和为1

3.Pcum=cumsum(P);   cumsum，元素累加即求和，比如P=[0.1 0.5 0.4]，cumsum(P)=  [0.1000    0.6000    1.0000]

有一点要特别说明，用到cumsum(P)，蚂蚁要选择的下一个城市不是按最大概率，就是要用到轮盘法则，不然影响全局收缩能力，

所以用到累积函数，Pcum=cumsum(P)

4.Select=find(Pcum>=rand); to_visit=J(Select(1))

轮盘法则，Select(1)，1保证可以选到最大概率的城市，具体自己可以用matlab试一下：

 p=[0.1 0.6 0.3]    中间那个城市概率最大

此时Pcum=[0.1  0.7  1],   Select =[2   3];  Select(1)=2,中间那个城市概率最大

%}

if NC>=2
Tabu(1,:)=R_best(NC-1,:);
end

 
%%第四步：记录本次迭代最佳路线
L=zeros(m,1);     %开始距离为0，m*1的列向量
for i=1:m
R=Tabu(i,:);
for j=1:(n-1)
L(i)=L(i)+D(R(j),R(j+1));    %原距离加上第j个城市到第j+1个城市的距离
end
L(i)=L(i)+D(R(1),R(n));      %一轮下来后走过的距离，加上第一个和最后一个城市的距离
end

%{

1.L=zeros(m,1)   记录本次迭代最佳路线的长度，每个蚂蚁都有自己走过的长度记录在向量L中

%}


L_best(NC)=min(L);           %最佳距离取最小
pos=find(L==L_best(NC));   %找到路径最短的那条蚂蚁所在的行编号
R_best(NC,:)=Tabu(pos(1),:); %此轮迭代后的最佳路线
L_ave(NC)=mean(L);           %此轮迭代后的平均距离
NC=NC+1                      %迭代继续
 

%{

1.R_best(NC,:)=Tabu(pos(1),:)：找到路径最短的那条蚂蚁所在的城市先后顺序，pos(1)中1表示万一有长度一样的两条蚂蚁，那就选第一个

%}

 
%%第五步：更新信息素
Delta_Tau=zeros(n,n);        %开始时信息素为n*n的0矩阵
for i=1:m
for j=1:(n-1)
Delta_Tau(Tabu(i,j),Tabu(i,j+1))=Delta_Tau(Tabu(i,j),Tabu(i,j+1))+Q/L(i);          
%此次循环在路径（i，j）上的信息素增量
end
Delta_Tau(Tabu(i,n),Tabu(i,1))=Delta_Tau(Tabu(i,n),Tabu(i,1))+Q/L(i);    %加上第一个到最后一个城市的信息素增量
%此次循环在整个路径上的信息素增量
end
Tau=(1-Rho).*Tau+Delta_Tau; %考虑信息素挥发，更新后的信息素
%%第六步：禁忌表清零
Tabu=zeros(m,n);             %%直到最大迭代次数
end

%{

1.R_best(NC,:)=Tabu(pos(1),:)：找到路径最短的那条蚂蚁所在的城市先后顺序，pos(1)中1表示万一有长度一样的两条蚂蚁，那就选第一个

%}




%%第七步：输出结果
Pos=find(L_best==min(L_best)); %找到最佳路径（非0为真）
Shortest_Route=R_best(Pos(1),:) %最大迭代次数后最佳路径
Shortest_Length=L_best(Pos(1)) %最大迭代次数后最短距离
subplot(1,2,1)                  %绘制第一个子图形


N=length(R);
scatter(C(:,1),C(:,2));
hold on
plot([C(R(1),1),C(R(N),1)],[C(R(1),2),C(R(N),2)],'r')
hold on
for ii=2:N
    plot([C(R(ii-1),1),C(R(ii),1)],[C(R(ii-1),2),C(R(ii),2)],'r')
    hold on
end

title('旅行商问题优化结果 ')

subplot(1,2,2)                  %绘制第二个子图形
plot(L_best)
hold on                         %保持图形
plot(L_ave,'r')

title('平均距离和最短距离')     %标题

%{

这部分没什么太大问题，多看几遍就好

%}