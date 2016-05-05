function [] = draw_line(p1, p2, img)
figure
imshow(img)
hold on

xp1 = p1(1,:);
xp2 = p2(1,:);
yp1 = p1(2,:);
yp2 = p2(2,:);

for i=1:size(p1, 2)
    plot([xp1(i); xp2(i)], [yp1(i); yp2(i)])

end

plot(xp1, yp1,'*');
plot(xp2, yp2, 'o');