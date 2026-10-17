sudo apt install plymouth plymouth-themes make -y

sudo make install   

sudo plymouth-set-default-theme -R deb10
   
sudo nano /etc/default/grub

"quiet splash"

sudo  update-grub2

sudo reboot



