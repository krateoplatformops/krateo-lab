echo "Preparing frontend..."

cd

git clone --branch develop --depth 1 https://github.com/krateoplatformops/krateo-frontend

cd krateo-frontend

apt install --yes npm

npm install
