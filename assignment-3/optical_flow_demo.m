function optical_flow_demo()
    [v] = optical_flow('sphere1.ppm', 'sphere2.ppm');
    [v] = optical_flow('synth1.pgm', 'synth2.pgm');
end