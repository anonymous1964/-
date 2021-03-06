%%%%%RGB转化到HSV，对亮度和饱和度进行直方图均衡，保持原始色彩
clear;
clc;
I=imread('E:\DELL\matlab_code\code\shl.jpg');
I=rgb2hsv(I);
H=I(:,:,1);
S=I(:,:,2);
V=I(:,:,3);
S=histeq(S);%对饱和度直方图均衡
V=histeq(V);%对亮度直方图均衡
Final=hsv2rgb(H,S,V);
imshow(Final);
imwrite(Final,'C:\Users\DELL\Desktop\chengxu\rgb2hsv\sh1.jpg');
