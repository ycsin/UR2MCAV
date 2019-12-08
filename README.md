
# UR2MCAV
This script is meant to automate the conversion of the [Ubiquity Robotics Pi image](https://downloads.ubiquityrobotics.com/pi.html) to MonashCAV steering node Pi image. However, it has not been tested.

Ubiquity Robotics Pi image is based on Ubuntu 16.04 and has ROS kinetic **preinstalled** and is therefore highly recommended.

To run this script, simply execute it with root.

## Configuration
The script can be configured by editing the configuration part of the script. Simply edit the .sh file with any editor.

**Current configurations:**

    # Config
    DEBLOAT_SYSTEM=1             # Debloat the system by removing various useless pre-installed packages. Default: 1
    ENABLE_SPI=1                 # Enable the SPI hardware interface on the system, alternatively you can use raspi-config no. Default: 1
    CONFIGURE_CAN=1              # Enable and configure CAN interface. Default: 1
    INSTALL_CAN_UTILS=1          # Install Can-Utils. Default: 1
    INSTALL_ROSKILL=1            # Install a script to kill roscore. Default: 1
    INSTALL_SETIP=1              # Install a script to set ip. Default: 1
    CLEANUP_UBIQUITYROBOTICS=1   # Clean-up ubiquity robotics folders and files. Default: 1
    SET_ENVIRONMENT=1            # Set up ROS environment. Default: 1
    INSTALL_MCAV=1               # Install MonashCAV steering node. Default: 1
    INSTALL_VSCODE=0             # Install Visual Studio Code. **Very very slow, not recommended Default: 0
    INSTALL_GEDIT=1              # Install Gedit. Default: 1
    INSTALL_REALVNC=0            # Install RealVNC server. Default: 0    
    REALVNC_VER=6.4.1            # RealVNC server version.
