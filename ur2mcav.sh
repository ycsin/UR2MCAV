#!/bin/sh
# Autoconfig script to transform ubiquityrobotics pi image to MonashCAV pi image
# AUTHOR:		Yong Cong Sin - ycsin3@student.monash.edu | yongcong.sin@gmail.com
# LAST UPDATE:	120718072019

HOME=/home/ubuntu
CATKIN=/home/ubuntu/catkin_ws
CONFIG=/boot/config.txt

# Config
DEBLOAT_SYSTEM=1				# Debloat the system by removing various useless pre-installed packages. 						Default: 1
ENABLE_SPI=1					# Enable the SPI hardware interface on the system, alternatively you can use raspi-config no. 	Default: 1
CONFIGURE_CAN=1					# Enable and configure CAN interface. 															Default: 1
INSTALL_CAN_UTILS=1				# Install Can-Utils. 																			Default: 1
INSTALL_ROSKILL=1				# Install a script to kill roscore. 															Default: 1
INSTALL_SETIP=1					# Install a script to set ip. 																	Default: 1
CLEANUP_UBIQUITYROBOTICS=1		# Clean-up ubiquity robotics folders and files. 												Default: 1
SET_ENVIRONMENT=1				# Set up ROS environment. 																		Default: 1
INSTALL_KACO=1					# Install KACanOpen. 																			Default: 1
INSTALL_VSCODE=0				# Install Visual Studio Code. **Very very slow, not recommended 								Default: 0
INSTALL_GEDIT=1					# Install Gedit. 																				Default: 1
INSTALL_REALVNC=0				# Install RealVNC server. 																		Default: 0
REALVNC_VER=6.4.1				# RealVNC server version. 																		Default: 6.4.1

# Check root access
if [ $(id -u) -ne 0 ]; then
  echo ""
  echo ""
  echo ""
  echo "This script requires root access to execute"
  echo "Type:"
  echo ""
  echo "    sudo sh ${0##*/}"
  echo ""
  sleep 2
  echo -n "Press EnterKey to continue."
  read enterKey
  echo ""
  echo ""
  echo ""
  exit 0
fi

# Remove useless ubuntu preinstalled packages
if [ $DEBLOAT_SYSTEM -eq 1 ]; then
  sudo apt-get -y remove pidgin*
  sudo apt-get -y purge pidgin*
  sudo apt-get -y remove mtpaint*
  sudo apt-get -y purge mtpaint*
  sudo apt-get -y remove evince*
  sudo apt-get -y purge evince*
  sudo apt-get -y remove simple-scan
  sudo apt-get -y purge simple-scan
  sudo apt-get -y remove galculator*
  sudo apt-get -y purge galculator*
  sudo apt-get -y remove abiword*
  sudo apt-get -y purge abiword*
  sudo apt-get -y remove gnumeric*
  sudo apt-get -y purge gnumeric*
  sudo apt-get -y remove mplayer*
  sudo apt-get -y purge mplayer*
  sudo apt-get -y remove audacious*
  sudo apt-get -y purge audacious*
  sudo apt-get -y remove alsamixergui*
  sudo apt-get -y purge alsamixergui*
  sudo apt-get -y remove guvcview*
  sudo apt-get -y purge guvcview*
  sudo apt-get -y remove xfburn*
  sudo apt-get -y purge xfburn*
  sudo apt-get -y remove pulseaudio*
  sudo apt-get -y purge pulseaudio*
  sudo apt-get -y remove sylpheed*
  sudo apt-get -y purge sylpheed*
  sudo apt-get -y remove transmission*
  sudo apt-get -y purge transmission*
  sudo apt-get -y remove imagemagick*
  sudo apt-get -y purge imagemagick*
  sudo apt-get -y remove printer-driver*
  sudo apt-get -y purge printer-driver*
  sudo apt-get -y remove gpicview
  sudo apt-get -y purge gpicview
  sudo apt-get -y remove lubuntu-software-center
  sudo apt-get -y purge lubuntu-software-center
  sudo apt-get -y remove system-config-printer-genome
  sudo apt-get -y purge system-config-printer-genome
  sudo apt-get -y remove pavucontrol
  sudo apt-get -y purge pavucontrol
  sudo apt-get -y remove update-manager
  sudo apt-get -y purge update-manager
  sudo apt-get -y remove synaptic
  sudo apt-get -y purge synaptic
  sudo apt-get -y remove gnome-screenshot
  sudo apt-get -y purge gnome-screenshot
  sudo apt-get -y remove xterm
  sudo apt-get -y purge xterm
fi

# Enable SPI
# Ref: https://github.com/asb/raspi-config
if [ $ENABLE_SPI -eq 1 ]; then
  sed $CONFIG -i -r -e "s/^((device_tree_param|dtparam)=([^,]*,)*spi)(=[^,]*)?/\1=on/"
    if ! grep -q -E "^(device_tree_param|dtparam)=([^,]*,)*spi=[^,]*" $CONFIG; then
	  sudo sh -c "echo 'dtparam=spi=on' >> $CONFIG"
    fi
fi

# Enable CAN
if [ $CONFIGURE_CAN -eq 1 ]; then
  sudo apt-get -y install libsocketcan2 libsocketcan-dev
  sudo sh -c "echo 'dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25' >> /boot/config.txt"
  sudo sh -c "echo 'dtoverlay=spi0-hw-cs' >> /boot/config.txt"
  sudo sh -c "echo '' >> /etc/network/interfaces"
  sudo sh -c "echo 'auto can0' >> /etc/network/interfaces"
  sudo sh -c "echo 'iface can0 inet manual' >> /etc/network/interfaces"
  sudo sh -c "echo '   pre-up ip link set can0 type can bitrate 1000000 listen-only off' >> /etc/network/interfaces"
  sudo sh -c "echo '   up /sbin/ifconfig can0 up' >> /etc/network/interfaces"
  sudo sh -c "echo '   down /sbin/ifconfig can0 down' >> /etc/network/interfaces"
  
# Install python-pip
  sudo apt-get -y install python-pip

# Install python-can
  pip install python-can
fi

# Install can-utils
if [ $INSTALL_CAN_UTILS -eq 1 ]; then
  sudo apt-get -y install can-utils
fi

# Perform update and clean
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove

# Create a script to kill roscore
if [ $INSTALL_ROSKILL -eq 1 ]; then
  FILE=/bin/roskill
  sudo touch $FILE
  sudo chmod 777 $FILE
  sudo chown 0.0 $FILE
  sudo echo '#!/bin/sh' >> $FILE
  sudo echo 'killall -9 roscore' >> $FILE
  sudo echo 'killall -9 rosmaster' >> $FILE
  sudo echo 'echo "Killed roscore and rosmaster"' >> $FILE
fi

# Create a script to set IPs
# IPs need to be edited manually
# To source this file: type 
# . rosip
#
if [ $INSTALL_SETIP -eq 1 ]; then
  FILE=/bin/setip
  if ping -q -c 1 -W 1 8.8.8.8 &>/dev/null; then
	  sudo wget --no-check-certificate -O /bin/setip https://raw.githubusercontent.com/ycsin3/ROS_setip/master/setip
    sudo chmod 777 $FILE
    sudo chown 0.0 $FILE
	else
    echo ""
	  echo "[ERROR] setip can not be installed without internet connection."
    echo ""
	fi
fi

#
# Remove ubiquity robotic files
#
if [ $CLEANUP_UBIQUITYROBOTICS -eq 1 ]; then
# IP source file
  sudo rm -rf /etc/ubiquity
# Disable services
  sudo systemctl disable magni-base
  sudo systemctl stop magni-base
# Disable roscore autostart
  sudo systemctl disable roscore.service
  sudo systemctl stop roscore.service
# Remove systemd files
  sudo rm -rf /etc/systemd/system/magni-base.service
  sudo rm -rf /etc/systemd/system/roscore.service
# Remove ROS demo folder
  sudo rm -rf /home/ubuntu/catkin_ws/src/demos
# Edit SSH login banner
  FILE=/etc/update-motd.d/50-ubiquity
  sudo rm -rf $FILE
  sudo touch $FILE
  sudo chmod 777 $FILE
  sudo chown 0.0 $FILE
  sudo echo '#!/bin/sh' >> $FILE
  sudo echo 'export TERM=xterm-256color' >> $FILE
  sudo echo '' >> $FILE
  sudo echo 'echo ""' >> $FILE
  sudo echo 'echo "$(tput setaf 2)Monash Connected Autonomous Vehicle$(tput sgr0)"' >> $FILE
  sudo echo 'echo ""' >> $FILE
  sudo echo 'echo "Wifi can be managed with pifi (pifi --help for more info)"' >> $FILE
  sudo chmod 755 $FILE
fi

#
# Set up environment
#
if [ $SET_ENVIRONMENT -eq 1 ]; then
  FILE=/etc/bash.bashrc
# Sourcing our own IPs config
  sudo echo 'source /bin/rosip' >> ~/.bashrc
# Configuring environment for ssh client
  sudo echo 'source /opt/ros/kinetic/setup.bash' >> $FILE
  sudo echo 'source /home/ubuntu/catkin_ws/devel/setup.bash' >> $FILE
  sudo echo 'source /bin/rosip' >> $FILE
  sudo echo 'export ROS_PARALLEL_JOBS=-j2 # Limit the number of compile threads due to memory' >> $FILE
fi

# (K)(A)(C)an(O)pen
if [ $INSTALL_KACO -eq 1 ]; then
  cd $CATKIN
  if [ ! -d src ]; then
    sudo mkdir src
  fi
  cd src
  git clone https://github.com/KITmedical/kacanopen.git
  cd ..
  catkin_make -DDRIVER=socket -DBUSNAME=can0 -DBAUDRATE=1M
fi

# Gedit
if [ $INSTALL_GEDIT -eq 1 ]; then
  sudo apt-get install -y gedit
fi

# RealVNC Server
if [ $INSTALL_REALVNC -eq 1 ]; then
  sudo wget https://www.realvnc.com/download/file/vnc.files/VNC-Server-${REALVNC_VER}-Linux-ARM.deb
  sudo dpkg -i VNC-Server-${REALVNC_VER}-Linux-ARM.deb
  sudo systemctl start vncserver-x11-serviced.service
  sudo systemctl enable vncserver-x11-serviced.service
fi

# VSCode
if [ $INSTALL_VSCODE -eq 1 ]; then
  FILE=/bin/vscode
  wget https://packagecloud.io/headmelted/codebuilds/gpgkey -O - | sudo apt-key add -
  curl -L https://code.headmelted.com/installers/apt.sh | sudo bash
  sudo apt-get -y install code-oss=1.29.0-1539702286 --allow-downgrades
  sudo apt-mark hold code-oss
  sudo touch $FILE
  chmod 777 $FILE
  chown 0.0 $FILE
  echo '#!/bin/sh' >> $FILE
  echo 'sudo code-oss &' >> $FILE
  echo "Type:"
  echo "" >>
  echo "    vscode"
  echo ""
  echo "To run Visual Studio Code"
fi

cd $HOME
echo ""
echo ""
echo ""
echo ""
echo "You should perform a reboot here by typing"
echo ""
echo "    sudo reboot"
echo ""