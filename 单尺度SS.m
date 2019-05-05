clc;
clear;
I=imread('E:\DELL\matlab_code\code\1.png');%读取图像文件
%R通道
R=I(:,:,1);
[N1,M1]=size(R);%取得图像的行列数
R0 = double(R);%将图像的数据类型转换为double类型
Rlog = log(R0);%logS(x,y)
Rfft2 = fft2(R0);%经过低通滤波 S(x,y)
%F(x,y)高斯滤波器
sigma =500;%选取50时，亮度大，但远处有残雾，且曝光严重；在200以上之后，效果改变不明显；
F = fspecial('gaussian', [N1,M1], sigma);
Efft=fft2(double(F));
DR0 = Rfft2.* Efft;%D（x,y）=S(x,y)*F(x,y);
DR = ifft2(DR0);%反傅里叶变换,因为得到的是复数
DRlog = log(DR);%logD(x,y)
Rr = Rlog - DRlog;%G(x,y)=logS(x,y)-logD(x,y)
EXPRr = exp(Rr);%R(x,y)=expG(x,y),得到的即为放射特性
%为了使得图像特征明显，在这里进行了对比度增强
MIN = min(min(EXPRr));%原始图像中的最小灰度值
MAX = max(max(EXPRr));%原始图像中的最大灰度值
EXPRr = (EXPRr - MIN)/(MAX - MIN);%灰度拉伸公式
EXPRr = adapthisteq(EXPRr);
%G通道
G = I(:, :, 2);
G0 = double(G);
Glog = log(G0);
Gfft2 = fft2(G0);
DG0 = Gfft2.* Efft;
DG = ifft2(DG0);
DGlog = log(DG);
Gg = Glog - DGlog;
EXPGg = exp(Gg);
MIN = min(min(EXPGg));
MAX = max(max(EXPGg));
EXPGg = (EXPGg - MIN)/(MAX - MIN);
EXPGg = adapthisteq(EXPGg);
%B通道
B = I(:, :, 3);
B0 = double(B);
Blog = log(B0);
Bfft2 = fft2(B0);
DB0 = Bfft2.* Efft;
DB = ifft2(DB0);
DBlog = log(DB);
Bb = Blog - DBlog;
EXPBb = exp(Bb);
MIN = min(min(EXPBb));
MAX = max(max(EXPBb));
EXPBb = (EXPBb - MIN)/(MAX - MIN);
EXPBb = adapthisteq(EXPBb);
result = cat(3, EXPRr, EXPGg, EXPBb);
figure;
imshow(I);
figure;
imshow(result);
imwrite(result,'C:\Users\DELL\Desktop\chengxu\单尺度SSR\1.png');
%%%%%%%为何要先傅里叶变换，再求反傅里叶变换：
%数字图像处理第二版 冈萨雷斯 里面有关于频域滤波和空间域滤波的详细解释
