function varargout = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult)

% Process Inputs and Initialize Defaults
nargs = 6;
for k = nargin:nargs-1
    switch k
        case 0
            xy = 10*rand(50,2);
        case 1
            N = size(xy,1);
            a = meshgrid(1:N);
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),N,N);%����ά���任
        case 2
            popSize = 100;
        case 3
            numIter = 1e4;
        case 4
            showProg = 1;
        case 5
            showResult = 1;
        otherwise
    end
end

% Verify Inputs
[N,dims] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N;

% Sanity Checks
popSize = 4*ceil(popSize/4);
numIter = max(1,round(real(numIter(1))));
showProg = logical(showProg(1));
showResult = logical(showResult(1));

% Initialize the Population ��ʼ����Ⱥ
pop = zeros(popSize,n);
pop(1,:) = (1:n);
for k = 2:popSize
    pop(k,:) = randperm(n);
end

% Run the GA
globalMin = Inf;
totalDist = zeros(1,popSize);
distHistory = zeros(1,numIter);
tmpPop = zeros(4,n);
newPop = zeros(popSize,n);
if showProg
    pfig = figure('Name','TSP_GA | Current Best Solution','Numbertitle','off');
end
for iter = 1:numIter %��������
    % Evaluate Each Population Member (Calculate Total Distance)
    for p = 1:popSize
        d = dmat(pop(p,n),pop(p,1)); % Closed Path ѡ������
        for k = 2:n
            d = d + dmat(pop(p,k-1),pop(p,k));  %�������ӡ���������
        end
        totalDist(p) = d;  % ������Ӧ�� 
    end
    
    %�ҵ���С�������Ӧ�ȵ�Ⱦɫ�弰��������Ⱥ�е�λ��
    % Find the Best Route in the Population
    [minDist,index] = min(totalDist);
    distHistory(iter) = minDist;
    shiyingdu(iter)=1.0/distHistory(iter);
     % ������һ�ν�������õ�Ⱦɫ��
    if minDist < globalMin
        maxiter=iter;
        globalMin = minDist;
        optRoute = pop(index,:);
        if showProg
            % Plot the Best Route
            figure(pfig);
            rte = optRoute([1:n 1]);
            if dims > 2, 
                plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
            else
                plot(xy(rte,1),xy(rte,2),'r.-');
            end
            title(sprintf('Total Distance = %1.4f, Iteration = %d',minDist,iter));
        end
    end

    % Genetic Algorithm Operators
    randomOrder = randperm(popSize);
    for p = 4:4:popSize
        rtes = pop(randomOrder(p-3:p),:);
        dists = totalDist(randomOrder(p-3:p));
        [ignore,idx] = min(dists); %#ok
        bestOf4Route = rtes(idx,:);
        routeInsertionPoints = sort(ceil(n*rand(1,2)));
        I = routeInsertionPoints(1);
        J = routeInsertionPoints(2);
        for k = 1:4 % Mutate the Best to get Three New Routes
            tmpPop(k,:) = bestOf4Route;
            switch k
                case 2 % Flip
                    tmpPop(k,I:J) = tmpPop(k,J:-1:I);
                case 3 % Swap
                    tmpPop(k,[I J]) = tmpPop(k,[J I]);
                case 4 % Slide
                    tmpPop(k,I:J) = tmpPop(k,[I+1:J I]);
                otherwise % Do Nothing
            end
        end
        newPop(p-3:p,:) = tmpPop;
    end
    pop = newPop;
end
% ��ͼ
if showResult
    % Plots the GA Results
    figure('Name','TSP_GA | Results','Numbertitle','off');
    % subplot(2,2,1);
    figure(1),
    pclr = ~get(0,'DefaultAxesColor');
    if dims > 2, 
        plot3(xy(:,1),xy(:,2),xy(:,3),'.','Color',pclr);
    else
        plot(xy(:,1),xy(:,2),'.','Color',pclr);
    end
    title('����λ��');
    grid on
%     subplot(2,2,2);
    figure(2),
    imagesc(dmat(optRoute,optRoute));
    title('�������-imagesc');
%     subplot(2,2,3);
    figure(3),
    
    for i=1:n
  hold on
  plot(xy(:,1),xy(:,2),'k.');
  text(xy(i,1),xy(i,2)+0.08,num2str(i));
end
for i=1:n-1
 plot([xy(optRoute(1,i),1),xy(optRoute(1,i+1),1)],[xy(optRoute(1,i),2),xy(optRoute(1,i+1),2)])
 hold on
end
for i=n
    plot([xy(optRoute(1,i),1),xy(optRoute(1,1),1)],[xy(optRoute(1,i),2),xy(optRoute(1,1),2)])
    hold on
end
    
    
    
    
    rte = optRoute([1:n 1]);
    if dims > 2, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-')
        ;
    else
        plot(xy(rte,1),xy(rte,2),'r.-');
    end
    xlabel('x');ylabel('y');
    title(sprintf('��̾��� = %1.4f,��������=%d',minDist,maxiter));
    grid on
%     subplot(2,2,4);
    figure(4),
 
    plot(shiyingdu,'b','LineWidth',2);
    %axis([xmin xmax ymin ymax]) %xmin��x��С��xmax��x���ymin��ymax����
  
   % axis([0 10000 0 0.01]);
    title('�����Ӧ������');
    xlabel('��������');
    grid on
    set(gca,'XLim',[0 numIter+1],'YLim',[0 1.1*max([0.001 shiyingdu])]);
end

% Return Outputs
if nargout
    varargout{1} = optRoute;
    varargout{2} = minDist;
end
