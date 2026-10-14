% Script for clacium imaging
% image_stacks{1} - red channel
% image_stacks{2} - green channel
% image_stacks{3} - green channel-background
% image_stacks{4} - red channel warped to match green
clear
close all
%% Read flie and display info and temperature
cd('E:\OneDrive - Harvard University\Programming\Calcium-Imaging-Guangwei')

% If warp = 1, correct geometrically red to match green
warp_image = 1;
% What z-slices to use
% z_start=1;

%%
[FileName, PathName] = uigetfile('*.*' , 'Select h5 file','E:\OneDrive - Harvard University\TRPA1_PROJECT\Imaging\Temperature_spin_disk','MultiSelect','off');
filename = fullfile(PathName, FileName);
% info=h5info(filename);
%% Plot temperature from hdf5 file
temperature1=h5read(char(filename),'/temperature1_real');
temperature1(temperature1<10)=NaN;
temperature2=h5read(char(filename),'/temperature2_real');
temperature2(temperature1<8)=NaN;
time=h5read(char(filename),'/time');
time = time-time(1);
figure(998)
hold on
% plot([time-time(1)],temperature);
plot(temperature1)
hold on
plot(temperature2)
set(gca,'FontSize',16)
endout = regexp(filename,filesep,'split');
% details = info.Attributes(6).Value;
details = h5readatt(filename,'/','description');
title(details, endout(end),'interpreter', 'none');
xlabel('frame number')
ylabel('Temperature (^oC)')
%% Display one frame
z_start=1;
z_end =20; 
channel=[1,2]; % 1 for red, 2 for green
% h5_frame=h5read(filename,['/' int2str(i) '/frame']);
h5_frame=h5read(filename,'/1/frame');
max_intensity_stack_frame(:,:,1) = max(h5_frame(z_start:z_end,:,:,channel(2)),[],1);
max_intensity_stack_frame_RED(:,:,1) = max(h5_frame(z_start:z_end,:,:,channel(1)),[],1);
figure(1010)

hold on
% imshow(max_intensity_stack_frame*3)
imshowpair(max_intensity_stack_frame*3,max_intensity_stack_frame_RED*3, 'montage');
%% Convert h5 into max intensity stack
tic;
frames_num=double(h5readatt(filename,'/','T'));
channels_num = double(h5readatt(filename,'/','C'));
frames_width = double(h5readatt(filename,'/','W'));
frames_hight = double(h5readatt(filename,'/','H'));
frames_depth = z_end-z_start+1;
%frames_depth = double(h5readatt(filename,'/','D'))-z_start+1;



image_stacks=[];
% max_intensity_stack = uint8(zeros([info.Groups(1).Datasets.Dataspace.Size([2 3]),length(info.Groups)]));
max_intensity_stack = uint8(zeros([frames_hight,frames_width,frames_num]));
% max_intensity_stack_X = uint8(zeros([info.Groups(1).Datasets.Dataspace.Size([1 2]),length(info.Groups)]));
max_intensity_stack_X = uint8(zeros([frames_depth,frames_hight,frames_num]));
% max_intensity_stack_Y = uint8(zeros([info.Groups(1).Datasets.Dataspace.Size([1 3]),length(info.Groups)]));
max_intensity_stack_Y = uint8(zeros([frames_depth,frames_width,frames_num]));
image_stacks{1,1}=max_intensity_stack;
image_stacks{1,channels_num}=max_intensity_stack;
% for i = 0:frames_num-1
%     h5=h5read(filename,['/' int2str(i) '/frame']);
%     for n=1:channels_num
%         max_intensity_stack(:,:,i+1) = max(h5(z_start:z_end,:,:,n),[],1);
%         max_intensity_stack_X(:,:,i+1,n) = max(h5(z_start:z_end,:,:,n),[],3);
%         max_intensity_stack_Y(:,:,i+1,n) = max(h5(z_start:z_end,:,:,n),[],2);
% %         image_stacks{n} = cat(3,image_stacks{n},max_intensity_stack(:,:,i+1));
%         image_stacks{n}(:,:,i+1) = max_intensity_stack(:,:,i+1);
%     end
% end

parfor i = 1:frames_num
    h5=h5read(filename,['/' int2str(i-1) '/frame']);

        % max_intensity_stack_X(:,:,i+1,n) = max(h5(z_start:z_end,:,:,n),[],3);
        % max_intensity_stack_Y(:,:,i+1,n) = max(h5(z_start:z_end,:,:,n),[],2);
        temp_1(:,:,i) = max(h5(z_start:z_end,:,:,1),[],1);
        temp_2(:,:,i) = max(h5(z_start:z_end,:,:,2),[],1);
end
image_stacks{1,1}=temp_1;
image_stacks{1,2}=temp_2;

toc;

%% CHOOSE ONE OF THE THREE METHODS OF BACKGROUND SUBTRACTION
%% Remove background
% Using minimum intensity for each pixel in stack
% total_intensity=permute(sum(image_stacks{2},[1 2]),[3 2 1]);
% [~,I]=min(total_intensity);
% image_stacks{3} = image_stacks{2}-image_stacks{2}(:,:,I);
min_frame = zeros(frames_hight,frames_width);
for i=1:frames_hight
    for j=1:frames_width
        min_frame(i,j) = min(image_stacks{2}(i,j,:));
    end
end
image_stacks{3} = image_stacks{2}-uint8(min_frame);
%% Remove background
% Using minimum intensity frame from the stack
total_intensity=permute(sum(image_stacks{2},[1 2]),[3 2 1]);
[~,I]=min(total_intensity);
image_stacks{3} = image_stacks{2}-image_stacks{2}(:,:,I);
%% Remove background (MAIN)
% Using premade background 
background=importdata('E:\OneDrive - Harvard University\TRPA1_PROJECT\Imaging\Temperature_spin_disk\background_100Hz.mat');
x=sum(background(1:frames_depth,234:254),"all");
x2=sum(image_stacks{2}(1:frames_depth,234:254,1),"all");
background = background*(x2/x);
image_stacks{3} = image_stacks{2}-background;
%% Run proof reading
% image_stacks{1} - red channel
% image_stacks{2} - green channel
% image_stacks{3} - green channel-background
% image_stacks{4} - red channel warped to match green
if warp_image==1
    tform=importdata('E:\OneDrive - Harvard University\TRPA1_PROJECT\Imaging\Temperature_spin_disk\warp.mat');
    image_stacks{4} = imwarp(image_stacks{1},tform,"OutputView",imref2d(size(max_intensity_stack_frame)));

    Calcium_Stan_Single_Neuron(filename,{image_stacks{4},image_stacks{3}},[],details,1,frames_num,1:frames_num,1);
else
    Calcium_Stan_Single_Neuron(filename,{image_stacks{2},image_stacks{3}},[],details,1,frames_num,1:frames_num,1);
end
%%
T=table(time,temperature1,temperature2,Reference,signals);

%% Secondary Save plot
[~,name,~]=fileparts(FileName);
% name = [name,'_cell_bodies']; 
saveas(figure(1000),[PathName,name,'_Total_secondary'],'fig');
saveas(figure(1001),[PathName,name,'_Ratio_secondary'],'fig');
saveas(figure(1002),[PathName,name,'_temperature_secondary'],'fig');

% saveas(figure(1003),[PathName,name,'_std'],'fig');
saveas(figure(1010),[PathName,name,'_neurons_secondary'],'fig');
writetable(T,[PathName,name,'_data_secondary.csv']);
%% Using reference signal (non-responding neurons)
figure;
plot(T.Reference)
[x,y] = ginput(10);
f=[];
f = fit(x,y,'exp2');
hold on
plot(f)
x=1:length(T.time);
y=f.a*exp(f.b*x)+f.c*exp(f.d*x);
%%
figure;
hold on
for n=1:size(T.signals,2)

F_norm = T.signals(:,n) ./y';

plot(time,(F_norm-F_norm(1))/F_norm(1)-(n-1)*0.5);
end
%% Save plot
[~,name,~]=fileparts(FileName);
saveas(figure(1000),[PathName,name,'_Total'],'fig');
saveas(figure(1001),[PathName,name,'_Ratio'],'fig');
saveas(figure(1002),[PathName,name,'_temperature'],'fig');
% figure(1003);
% hold on
% color = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330;0.6350 0.0780 0.1840];
% color = varycolor(10);
% for n=1:size(signals,2)
%     circle = drawcircle;
%     rectangle('Curvature',[1,1],'Position',[circle.Center(1)-circle.Radius, circle.Center(2)-circle.Radius,2*circle.Radius, 2*circle.Radius],'EdgeColor',color(n,:));
%     delete(circle)
% end
saveas(figure(1010),[PathName,name,'_neurons'],'fig');
saveas(figure(1003),[PathName,name,'_std'],'fig');
writetable(T,[PathName,name,'_data.csv']);






%% Load csv file
[FileName, PathName] = uigetfile('*.*' , 'Select csv file','E:\OneDrive - Harvard University\TRPA1_PROJECT\Imaging\Temperature_spin_disk','MultiSelect','off');
filename = fullfile(PathName, FileName);
T = readtable(filename);
%%
figure;
plot(T.Reference)
hold on
if size(T,2)>5
    plot(T.signals_1)
end
[x,y] = ginput(5);
f=[];
f = fit(x,y,'exp2');
hold on
plot(f)
x=1:length(T.time);
y=f.a*exp(f.b*x)+f.c*exp(f.d*x);
%%
figure;
hold on
for n=5:size(T,2)

F_norm = T(:,n)./y';

plot(T.time,(table2array(F_norm)-table2array(F_norm(1,1)))/table2array(F_norm(1,1))-(n-5)*0.5);

end

%% to view a Y slice

for n=5:size(T,2)

    T(:,n) = T(:,n)-y';
end

[~,name,~]=fileparts(FileName);
writetable(T,[PathName,name,'_unbleached'],"FileType","spreadsheet");



%% Another way

figure;
plot(T.Reference)
hold on
for i = 5:size(T,2)
    plot(table2array(T(:,i)))
    [x1,y1] = ginput(5);
    % f=[];
    f = fit(x1,y1,'exp2');
    plot(f)
    x=1:length(T.time);
    y(i-4,:)=f.a*exp(f.b*x)+f.c*exp(f.d*x);
end

for n=5:size(T,2)

    T(:,n) = T(:,n)-y(n-4,:)';
end
%%
%%
figure;
hold on
for n=5:size(T,2)

F_norm = T(:,n)./y';

plot(T.time,(table2array(F_norm)-table2array(F_norm(1,1)))/table2array(F_norm(1,1))-(n-5)*0.5);

end


%%
[FileName, PathName] = uigetfile('*.*' , 'Select csv file','E:\OneDrive - Harvard University\TRPA1_PROJECT\Imaging\Temperature_spin_disk','MultiSelect','off');
filename = fullfile(PathName, FileName);
T = readtable(filename);
[FileName, PathName] = uigetfile('*.*' , 'Select csv file',PathName,'MultiSelect','off');
filename = fullfile(PathName, FileName);
T2 = readtable(filename);
T2(:,5:end) = T2(:,5:end)-T2(1,5:end)+T(1,5:end);
[~,name,~]=fileparts(FileName);
writetable(T2,[PathName,name],"FileType","spreadsheet");