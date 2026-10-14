function movie_fullname = stack2movie(image_stacks,framerate,movie_name,crop,multiply)
%This function makes video from the image_stacks cell or single image stack.
%Example: image2movie(image_stacks,200,'TrpA1_2021_08_20_t101');
%specify framerate. Default is 4.
if nargin<2; framerate = 4; end
%specify the name of the movie
if nargin<3; movie_name = 'movie'; end

% choose the images
[path]=uigetdir;
% frames_address = fullfile(path,name);
% frames_address = cellstr(frames_address);
% parentDirectory = fileparts(fileparts(path));

% check that image_stacks is a cell
if iscell(image_stacks)==0
    stack{1}=uint8(image_stacks);
    image_stacks=stack;
end

%crop video
if nargin<4
    dim = size(image_stacks{1});
    
    crop = [1 dim(1) 1 dim(2)]; 
end

if nargin<5; multiply = 1; end

% write the frames to the video
for j=1:length(image_stacks)
    % create the video writer with specified fps
    movie_fullname = [path,'\',movie_name,'_',int2str(j)];
    % writerObj = VideoWriter(movie_fullname,'Uncompressed AVI');
    writerObj = VideoWriter(movie_fullname,"MPEG-4");
    writerObj.FrameRate = framerate;
    open(writerObj);
    for i=1:size(image_stacks{j},3)
        image = image_stacks{j}(crop(1):crop(2),crop(3):crop(4),i);
        writeVideo(writerObj, image*multiply);
        %display progress
        if i==floor(size(image_stacks{j},3)/10)
            disp('progress 10%')
        elseif i==floor(2*size(image_stacks{j},3)/10)
            disp('progress 20%')
        elseif i==floor(3*size(image_stacks{j},3)/10)
            disp('progress 30%')
        elseif i==floor(4*size(image_stacks{j},3)/10)
            disp('progress 40%')
        elseif i==floor(5*size(image_stacks{j},3)/10)
            disp('progress 50%')
        elseif i==floor(6*size(image_stacks{j},3)/10)
            disp('progress 60%')
        elseif i==floor(7*size(image_stacks{j},3)/10)
            disp('progress 70%')
        elseif i==floor(8*size(image_stacks{j},3)/10)
            disp('progress 80%')
        elseif i==floor(9*size(image_stacks{j},3)/10)
            disp('progress 90%')
        end
    end
    close(writerObj);
end
% close the writer object
   
%    implay(append(movie_fullname,'.avi'));
end

