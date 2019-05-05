%%%%暗原色去雾算法是建立在户外自然场景暗通道优先法则的基础上的去雾方法，其实就是解一个方程
%%I(x)=J(x)t(x)+A(1-t(x));其中I(x)是受到雾气污染的图像。J(x)是我们需要求的去雾后的图像
%%t(x)是天空中云层的透射分布率，A是天空的亮度
%暗影去雾算法
% 原始图像
img_name = imread('E:\DELL\matlab_code\code\shl.jpg');
I = double(img_name) / 255;
% 获取图像大小
[h,w,c] = size(I);
%去雾系数
w0 = 0.95;
img_size = w * h;
%初始化结果图像
dehaze = zeros(h,w,c);
%初始化暗影通道图像
win_dark = zeros(h,w);
for i=1:h 
 for j=1:w
 win_dark(i,j)=min(I(i,j,:));%将三个通道中最暗的值赋给dark_I(i,j),显然，三维图变成了二维图
 end
end
win_dark = ordfilt2(win_dark,1,ones(9,9),'symmetric');

%计算大气亮度A，相关原理详见论文“Single Image Haze Removal Using Dark Channel Prior”
dark_channel = win_dark;
A = max(max(dark_channel));
[i,j] = find(dark_channel==A);
i = i(1);
j = j(1);
A = mean(I(i,j,:));
%计算初始的transmission map
transmission = 1 - w0 * win_dark / A;
%用guided filter对trasmission map做soft matting
gray_I = I(:,:,1);%这里gray_I 可以是RGB图像中任何一个通道
p = transmission;
r = 80;
eps = 10^-3;
transmission_filter = guidedfilter(gray_I, p, r, eps);
t0=0.1;
t1 = max(t0,transmission_filter);
for i=1:c
 for j=1:h
 for l=1:w
 dehaze(j,l,i)=(I(j,l,i)-A)/t1(j,l)+A;
 end
end
end
figure,
imshow(I);title('去雾前')
figure,
imshow(dehaze*2);title('去雾后')%图片偏暗，提高亮度
imwrite(dehaze*2,'C:\Users\DELL\Desktop\chengxu\暗通道\shl2.jpg');








function q = guidedfilter(I, p, r, eps)
% ? GUIDEDFILTER ? O(1) time implementation of guided filter.
%
% ? - guidance image: I (should be a gray-scale/single channel image)
% ? - filtering input image: p (should be a gray-scale/single channel image)
% ? - local window radius: r
% ? - regularization parameter: eps


[hei, wid] = size(I);
N = boxfilter(ones(hei, wid), r); % the size of each local patch; N=(2r+1)^2 except for boundary pixels.


mean_I = boxfilter(I, r) ./ N;
mean_p = boxfilter(p, r) ./ N;
mean_Ip = boxfilter(I.*p, r) ./ N;
cov_Ip = mean_Ip - mean_I .* mean_p; % this is the covariance of (I, p) in each local patch.


mean_II = boxfilter(I.*I, r) ./ N;
var_I = mean_II - mean_I .* mean_I;


a = cov_Ip ./ (var_I + eps); % Eqn. (5) in the paper;
b = mean_p - a .* mean_I; % Eqn. (6) in the paper;


mean_a = boxfilter(a, r) ./ N;
mean_b = boxfilter(b, r) ./ N;


q = mean_a .* I + mean_b; % Eqn. (8) in the paper;
end










function imDst = boxfilter(imSrc, r)


% ? BOXFILTER ? O(1) time box filtering using cumulative sum
%
% ? - Definition imDst(x, y)=sum(sum(imSrc(x-r:x+r,y-r:y+r)));
% ? - Running time independent of r;?
% ? - Equivalent to the function: colfilt(imSrc, [2*r+1, 2*r+1], 'sliding', @sum);
% ? - But much faster.


[hei, wid] = size(imSrc);
imDst = zeros(size(imSrc));


%cumulative sum over Y axis
imCum = cumsum(imSrc, 1);
%difference over Y axis
imDst(1:r+1, :) = imCum(1+r:2*r+1, :);
imDst(r+2:hei-r, :) = imCum(2*r+2:hei, :) - imCum(1:hei-2*r-1, :);
imDst(hei-r+1:hei, :) = repmat(imCum(hei, :), [r, 1]) - imCum(hei-2*r:hei-r-1, :);


%cumulative sum over X axis
imCum = cumsum(imDst, 2);
%difference over Y axis
imDst(:, 1:r+1) = imCum(:, 1+r:2*r+1);
imDst(:, r+2:wid-r) = imCum(:, 2*r+2:wid) - imCum(:, 1:wid-2*r-1);
imDst(:, wid-r+1:wid) = repmat(imCum(:, wid), [1, r]) - imCum(:, wid-2*r:wid-r-1);
end


