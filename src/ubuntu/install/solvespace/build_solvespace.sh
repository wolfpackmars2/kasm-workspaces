@!/usr/bin/env bash

# Install dependencies for building solvespace
echo "Installing build dependencies using apt..."
sudo apt update
sudo apt install -y git build-essential cmake zlib1g-dev libpng-dev \
    libcairo2-dev libfreetype6-dev libjson-c-dev \
    libfontconfig1-dev libgtkmm-3.0-dev libpangomm-1.4-dev \
    libgl-dev libglu-dev libspnav-dev

# Clone the solvespace repo and build the program
echo "Cloning solvespace source..."
git clone https://github.com/solvespace/solvespace
cd solvespace
git submodule update --init # Prepare submodules
mkdir build
cd build
echo "Building solvespace"
cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENMP=ON -DENABLE_LTO=ON
make

# install to the local OS and create a tgz package
echo "Installing..."
sudo make install
echo "Packaging..."
tar -czvf solvespace.tgz -T install_manifest.txt
if [[ -f "../../solvespace.tgz" ]]; then
    rm ../../solvespace.tgz
fi
cp solvespace.tgz ../../solvespace.tgz # Copy package for docker install

if [[ -f "../../solvespace_version.env" ]]; then
    rm ../../solvespace_version.env
fi
cp version.env ../../solvespace_version.env # might be useful

# Clean up
echo "Cleaning up..."
sudo xargs rm < install_manifest.txt # uninstall from the system
cd ../..
sudo rm -rf solvespace
echo "Done."