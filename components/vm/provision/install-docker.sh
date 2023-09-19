if ! command -v docker &>/dev/null; then
  echo "Installing Docker & Docker Compose"
  apt update
  apt install -y apt-transport-https ca-certificates curl software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

  apt update
  apt install -y docker-ce
fi

DOCKER_PLUGINS_DIR="/usr/local/lib/docker/cli-plugins"

if [ ! -d "$DOCKER_PLUGINS_DIR" ]; then
  mkdir -p "$DOCKER_PLUGINS_DIR"
  if [ ! -f "$DOCKER_PLUGINS_DIR/docker-compose" ]; then
    curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  fi
fi
