%%%%%%%带彩色恢复的多尺度视网膜增强算法MSRCR%%%%%%%%%
clear;
clc;
I=imread('E:\DELL\matlab_code\code\shl.jpg');
R=I(:,:,1);%R通道
G=I(:,:,2);%G通道
B=I(:,:,3);%B通道
R=im2double(R);
G=im2double(G);
B=im2double(B);

%%%%%%%%%%%%%%%%%%%%%%%%%%%R通道%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[N1,M1]=size(R);%取得图像的行列数
Rlog=log(R+1);%logS(x,y)
Rfft2=fft2(R);%经过低通滤波S(x,y)
%G(x,y)高斯滤波
sigma1=128;%weight1
F1=fspecial('gaussian',[N1 M1],sigma1);
Efft1=fft2(double(F1));
LR=Rfft2.*Efft1;%L(x,y)=S(x,y)*G(x,y)
LR=ifft2(LR);
LRlog=log(LR+1);%log(S(x,y)*G(x,y))
Rr1=Rlog-LRlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

sigma2=256;%weight2
F2=fspecial('gaussian',[N1 M1],sigma2);
Efft2=fft2(double(F2));
LR=Rfft2.*Efft2;%L(x,y)=S(x,y)*G(x,y)
LR=ifft2(LR);
LRlog=log(LR+1);%log(S(x,y)*G(x,y))
Rr2=Rlog-LRlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

sigma3=512;%weight3
F3=fspecial('gaussian',[N1 M1],sigma3);
Efft3=fft2(double(F3));
LR=Rfft2.*Efft3;%L(x,y)=S(x,y)*G(x,y)
LR=ifft2(LR);
LRlog=log(LR+1);%log(S(x,y)*G(x,y))
Rr3=Rlog-LRlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))
%对不同尺度进行加权求和
Rr=(Rr1+Rr2+Rr3)/3;
%进行色彩恢复
%参考https://blog.csdn.net/bluecol/article/details/45675615
a = 50;                %MSRCR算法中的调整参数
II = imadd(R, G);             
II = imadd(II, B);       %将R、G、B三个通道的图叠加在一起
Ir = immultiply(R, a);    %R通道的图像乘以调整参数
Ig = immultiply(G, a);    %G通道的图像乘以调整参数
Ib = immultiply(B, a);    %B通道的图像乘以调整参数
alpha=imdivide(Ir,II);%色彩恢复因子
alpha=log(alpha+1);

Rr=immultiply(alpha,Rr);%Rmsrcr(x,y)=C(x,y)Rmsr(x,y)
EXPRr = exp(Rr);%R(x,y)=expG(x,y),得到的即为放射特性
%为了使得图像特征明显，在这里进行了对比度增强
MIN = min(min(EXPRr));%原始图像中的最小灰度值
MAX = max(max(EXPRr));%原始图像中的最大灰度值
EXPRr = (EXPRr - MIN)/(MAX - MIN);%灰度拉伸公式
EXPRr = adapthisteq(EXPRr);

%%%%%%%%%%%%%%%%%G通道%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
Glog=log(G+1);%logS(x,y)
Gfft2=fft2(G);%经过低通滤波S(x,y)
%G(x,y)高斯滤波
LG=Gfft2.*Efft1;%L(x,y)=S(x,y)*G(x,y)
LG=ifft2(LG);
LGlog=log(LG+1);%log(S(x,y)*G(x,y))
Rg1=Glog-LGlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

LG=Gfft2.*Efft2;%L(x,y)=S(x,y)*G(x,y)
LG=ifft2(LG);
LGlog=log(LG+1);%log(S(x,y)*G(x,y))
Rg2=Glog-LGlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

LG=Rfft2.*Efft3;%L(x,y)=S(x,y)*G(x,y)
LG=ifft2(LG);
LGlog=log(LG+1);%log(S(x,y)*G(x,y))
Rg3=Glog-LGlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))
%对不同尺度进行加权求和
Rg=(Rg1+Rg2+Rg3)/3;
%色彩恢复
alpha=imdivide(Ig,II);%色彩恢复因子
alpha=log(alpha+1);
Rg=immultiply(alpha,Rg);%Rmsrcr(x,y)=C(x,y)Rmsr(x,y)
EXPRg = exp(Rg);%R(x,y)=expG(x,y),得到的即为放射特性
%为了使得图像特征明显，在这里进行了对比度增强
MIN = min(min(EXPRg));%原始图像中的最小灰度值
MAX = max(max(EXPRg));%原始图像中的最大灰度值
EXPRg = (EXPRg - MIN)/(MAX - MIN);%灰度拉伸公式
EXPRg = adapthisteq(EXPRg);

%%%%%%%%%%B通道%%%%%%%%%%%%%%%%%%%%%
Blog=log(B+1);%logS(x,y)
Bfft2=fft2(B);%经过低通滤波S(x,y)
%G(x,y)高斯滤波
LB=Bfft2.*Efft1;%L(x,y)=S(x,y)*G(x,y)
LB=ifft2(LB);
LBlog=log(LB+1);%log(S(x,y)*G(x,y))
Rb1=Blog-LBlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

LB=Bfft2.*Efft2;%L(x,y)=S(x,y)*G(x,y)
LB=ifft2(LB);
LBlog=log(LB+1);%log(S(x,y)*G(x,y))
Rb2=Blog-LBlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))

LB=Rfft2.*Efft3;%L(x,y)=S(x,y)*G(x,y)
LB=ifft2(LB);
LBlog=log(LB+1);%log(S(x,y)*G(x,y))
Rb3=Blog-LBlog;%logRc(x,y)=logSc(x,y)-log(Sc(x,y)*G(x,y))
%对不同尺度进行加权求和
Rb=(Rb1+Rb2+Rb3)/3;
%色彩恢复
alpha=imdivide(Ib,II);%色彩恢复因子
alpha=log(alpha+1);
Rb=immultiply(alpha,Rb);%Rmsrcr(x,y)=C(x,y)Rmsr(x,y)
EXPRb = exp(Rb);%R(x,y)=expG(x,y),得到的即为放射特性
%为了使得图像特征明显，在这里进行了对比度增强
MIN = min(min(EXPRb));%原始图像中的最小灰度值
MAX = max(max(EXPRb));%原始图像中的最大灰度值
EXPRb = (EXPRb - MIN)/(MAX - MIN);%灰度拉伸公式
EXPRb = adapthisteq(EXPRb);

result=cat(3,EXPRr,EXPRg,EXPRb);
imshow(result);
imwrite('C:\Users\DELL\Desktop\chengxu\MSRCR\shl.jpg');













