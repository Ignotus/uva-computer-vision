#include <iostream>
#include <boost/format.hpp>
#include "Frame3D/Frame3D.h"


int main(int argc, char *argv[]) {
    if (argc != 2)
        return 0;

    for (int i = 0; i < 8; ++i) {
        Frame3D frame;
        frame.load(boost::str((boost::format("%s/%05d.3df") % argv[1] % i)));
    }

    return 0;
}
