%clear
close all
clc

%% load data
%load('/DATA/MAT/datatest.mat')

%% general variables
nEMG = size(data.daq.DAQ_DATA,2);
win = 25;
tDown = data.daq.t(1:win:end);
tDown = tDown(1:size(data.pvd.CTRL,1));

%% plot raw data
figure
hold all
for i = 1:nEMG
    subplot(nEMG,1,i)
    plot(data.daq.t,data.daq.DAQ_DATA(:,i))
end
xlabel('Time (s)')

%% align flags
ind = (data.pvd.MODE ~= -1) & (data.pvd.Y_LABEL ~= -1) & (data.pvd.COLLECT == 1); % get data collection indices
ylabel = -ones(size(data.pvd.MODE));
mode = ylabel;
collect = ylabel;
ylabel(ind) = data.pvd.Y_LABEL(ind);
mode(ind) = data.pvd.MODE(ind);
collect(ind) = data.pvd.COLLECT(ind);

figure
hold all
plot(ylabel)
plot(mode)
plot(collect)

%% plot flags over data
figure
hold all
subplot(9,1,1)
hold all
plot(tDown,ylabel)
plot(tDown,mode)
for i = 1:nEMG
    subplot(nEMG+1,1,i+1)
    plot(data.daq.t,data.daq.DAQ_DATA(:,i))
end
xlabel('Time (s)')

%% get training features
nModes = 4;
for i = 1:nModes
    y = ylabel(mode == i-1);
    temp = data.pvd.FEATURES(mode == i-1,:);
    feat{i} = [temp y];
end
%% pca 
for i = 1:nModes
    coeff{i} = pca(feat{i}(:,1:end-1));
    test = feat{i}(:,1:end-1)*coeff{i};
    %plot3(test(:,1),test(:,2),test(:,3),'o')
    model{i} = fitlm(feat{i}(:,1:end-1),feat{i}(:,end));
    figure
    plot(model{i});
end

%% MAV only - this kinda sucks
for i = 1:nModes
    mavI(i,:) = 5:5:size(feat{i},2);
    coeff{i} = pca(feat{i}(:,mavI(i,:)));
    test = feat{i}(:,mavI(i,:))*coeff{i};
    %plot3(test(:,1),test(:,2),test(:,3),'o')
    model{i} = fitlm(feat{i}(:,mavI(i,:)),feat{i}(:,end));
    figure
    plot(model{i});
end

%% TD only
for i = 1:nModes
    tdI(i,:) = setdiff(1:size(feat{i},2)-1,mavI(i,:));
    coeff{i} = pca(feat{i}(:,tdI(i,:)));
    test = feat{i}(:,tdI(i,:))*coeff{i};
    %plot3(test(:,1),test(:,2),test(:,3),'o')
    model{i} = fitlm(feat{i}(:,tdI(i,:)),feat{i}(:,end));
    figure
    plot(model{i});
end

%% stepwise regression

