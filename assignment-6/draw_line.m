function [] = draw_line(p1, epipolar_lines, img)
figure;
imshow(img);

% ax +by + c = 0
% setting x = 0, y = -c / b
p2 = zeros(size(p1));
p2(2,:) = -epipolar_lines(3,:) ./ epipolar_lines(2,:);
direction = p2 - p1;

hold on;
plot(p1(1,:), p1(2,:), '*');

xp1 = p1(1,:) - 10000 * direction(1,:);
xp2 = p1(1,:) + 10000 * direction(1,:);
yp1 = p1(2,:) - 10000 * direction(2,:);
yp2 = p1(2,:) + 10000 * direction(2,:);

hold on;
plot([xp1; xp2], [yp1; yp2]);

legend('frame point','Epipolar lines');

hold off;