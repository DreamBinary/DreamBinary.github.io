set -ex

if command --v ruby &> /dev/null
  echo "-->> Ruby is installed"
else
  echo "-->> Ruby is not installed"
  sudo apt install ruby-full
fi

gem install jekyll
gem install bundler
gem install github-pages

# if jekyll -v; then
if command -v jekyll &> /dev/null
  echo "-->> Jekyll is installed"
else
  echo "-->> Jekyll is not installed"
fi
