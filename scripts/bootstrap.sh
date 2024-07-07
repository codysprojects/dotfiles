
#!/bin/bash

set -o errexit # Exit the script on error
set -o pipefail # give exitcode of most to the right pipeline command
#set -x # print output of each step

# The setup is based on https://www.youtube.com/watch?v=XBU_6OSlgyI&t=516s.  
# Look into his dotfiles for ideas https://github.com/devopsjourney1/dotfiles-public

QUIET_MODE=$1

if sudo -n true 2>/dev/null; then
  echo "user can run passwordless sudo. Moving on" 
else
  echo "User cannot run passwordless sudo."
  echo ""
  echo "This script Will create passwordless sudo file for user"
  echo "and you will have to run this script again."
  echo "Your password will be asked for."
  echo "$USER   ALL=NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER
  exit
fi

# ensure .ssh exists
if ! [ -d ~/.ssh ]; then
   mkdir -m 700 .ssh
fi

# Install systemwide tools
sudo apt update
sudo apt install git unzip bat gcc jq # need to setup alias for bat (alias bat="batcat")  look at creating a 

# Insatll zsh
# current zsh plugins git z aws docker ansible salt kubectl zsh-autosuggestions zsh-syntax-highlighting
if ! [ -x "$(command -v zsh)" ]; then
  sudo apt install zsh
  chsh -s $(which zsh)
else
  [[ $QUIET_MODE != quiet ]] && echo "zsh is installed"
fi

# Install oh-my-zsh
# oh-my-zsh is just a manager for your zsh configurations, themes, and plugins
if ! [ -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  [[ $QUIET_MODE != quiet ]] && echo "oh-my-zsh is installed"
fi

# Install zsh-syntax-highlighting
#sudo apt install zsh-syntax-highlighting
#echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
if ! [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting  ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 
else
  [[ $QUIET_MODE != quiet ]] && echo "zsh-syntax-highlighting is installed"
fi

# Install zsh-autosuggestions
if ! [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting  ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
else
  [[ $QUIET_MODE != quiet ]] && echo "zsh-autosuggestions is installed"

# Install fuzy finder
#sudo apt install fzf
#echo "source <(fzf --zsh)" >> ${ZDOTDIR:-$HOME}/.zshrc
if ! [ -d ~/.fzf  ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  [[ $QUIET_MODE != quiet ]] && echo "fuzy finder is installed"
fi

# install starship for customizable prompt and icons in terninal
# You must install a nerd font in your terminal to see icons
if ! [ -f ~/.config/starship.toml ]; then
  curl -sS https://starship.rs/install.sh | sh
  #echo 'eval "$(starship init zsh)"' >> ${ZDOTDIR:-$HOME}/.zshrc
else
  [[ $QUIET_MODE != quiet ]] && echo "starship is installed"
fi

# I don't think we need nerd fonts here, just on the terminal emulator, but if we do
#git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
#cd nerd-fonts
#./install.sh Hack

# Install byobu
#sudo apt install byobu
#sudo apt install byobu-enable

# Install Homebrew
if ! [ -x "$(command -v brew)" ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  [[ $QUIET_MODE != quiet ]] && echo "homebrew is installed"
fi

# Install Homebrew apps
#brew install yadm #should alredy be installed

# Install kubectl
if ! [ -x "$(command -v kubectl)" ]; then
  echo "kubectl is not installed.  will install"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" #Download binary
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" #Download checksum
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check # Validate the kubectl binary against the checksum file
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl #Install kubectl
else
  [[ $QUIET_MODE != quiet ]] && echo "kubectl is installed"
fi

# Install flux
if ! [ -x "$(command -v flux)" ]; then
  echo "flux is not installed.  will install"
  curl -s https://fluxcd.io/install.sh | sudo bash
else
  [[ $QUIET_MODE != quiet ]] && echo "flux is installed"
fi

# Install awscli
if ! [ -x "$(command -v aws)" ]; then
  echo "aws cli is not installed.  Will install"
  curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
  unzip awscliv2.zip
  sudo $(pwd)/aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
  rm -rf $(pwd)/aws
  rm -f awscliv2.zip
else
  [[ $QUIET_MODE != quiet ]] && echo "aws cli is installed"
fi

# Install eksctl (only used for oidc provider setup)
if ! [ -x "$(command -v eksctl)" ]; then
  echo "eksctl is not installed.  Will install"
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin
  eksctl version
else
  [[ $QUIET_MODE != quiet ]] && echo "eksctl is installed"
fi

# Install clusterawsadm 
if ! [ -x "$(command -v clusterawsadm)" ]; then
  echo "clusterawsadm is not installed.  Will install"
  curl -L https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/download/$CLUSTER_API_PROVIDER_AWS_VERSION/clusterawsadm-linux-amd64 -o clusterawsadm
  chmod +x clusterawsadm
  sudo mv clusterawsadm /usr/local/bin
else
  [[ $QUIET_MODE != quiet ]] && echo "clusterawsadm is installed"
fi

# Install aws-iam-authenticator
if ! [ -x "$(command -v aws-iam-authenticator)" ]; then
  echo "aws-iam-authenticator is not installed.  Will install"
  curl -L https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.5.9/aws-iam-authenticator_0.5.9_linux_amd64 -o aws-iam-authenticator
  chmod +x aws-iam-authenticator
  sudo mv aws-iam-authenticator /usr/local/bin
else
  [[ $QUIET_MODE != quiet ]] && echo "aws-iam-authenticator is installed"
fi

# Install kubectx and kubens
if ! [ -f /usr/local/bin/kubectx ]; then
  sudo git clone https://github.com/ahmetb/kubectx /usr/local/kubectx
  sudo ln -s /usr/local/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s /usr/local/kubectx/kubens /usr/local/bin/kubens
  mkdir -p ~/.oh-my-zsh/completions
  chmod -R 755 ~/.oh-my-zsh/completions
  ln -s /usr/local/kubectx/completion/kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh
  ln -s /usr/local/kubectx/completion/kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh
else
  [[ $QUIET_MODE != quiet ]] && echo "kubectx and kubens are installed"
fi
