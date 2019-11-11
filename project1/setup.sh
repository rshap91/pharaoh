sudo apt-get update;
sudo apt install -y python3;
sudo apt-get install -y python3-pip;
if [ -d test_project ]; then
  rm -rf test_project
fi
git clone https://github.com/rshap91/test_project.git;

pip3 install ./test_project/
