#!/bin/bash

# Время
ln -sf /usr/share/zoneinfo/Asia/Tomsk /etc/localtime
hwclock --systohc

# Локали
sed -i "s/#ru_RU.UTF-8/ru_RU.UTF-8" /etc/locale.gen
sed -i "s/#en_US.UTF-8/en_US.UTF-8" /etc/locale.gen
locale-gen
echo "LANG=\"ru_RU.UTF-8\"" >> /etc/locale.conf

# Хост
echo "IT-Pechka" >> /etc/hostname
echo "127.0.1.1    IT-Pechka.localdomain     IT-Pechka" >> /etc/hosts

# Пользователь
username=""
echo "Введите имя пользователя: "
read username
useradd -m $username
usermod -aG wheel,audio,video,storage $username
userDir="/home/$username"

# passwd
echo "Введите пароль root"
passwd
echo "Введите пароль $username"
passwd $username

# Пакеты
pockets_base="hyprland waybar hyprpaper hypridle hyprlock hyprpicker grim slurp mako networkmanager blueman bluez brightnessctl alsa pipewire wireplumber zsh kitty cmake telegram-desktop firefox wofi thunar ttf-jetbrains-mono-nerd libreoffice-still-ru bashtop fastfetch curl nodejs yarn sddm grub efibootmgr "
pockets_btrfs="grub-btrfs btrfs-progs timeshift"

usebtrfs=""
echo "btrfs юзаешь?(yes/no{все полными словами})"
get_btr() {
  read usebtrfs
  if [[ "$usebtrfs" == "yes" ]]; then
    pacman -S $pockets_base $pockets_btrfs
  elif [[ "$usebtrfs" == "no" ]]; then
    pacman -S $pockets_base
  else
    echo "Не понял, еще раз вводи"
    get_btr
  fi
}
get_btr

chsh -s /bin/zsh $username

systemctl enable NetworkManager
systemctl enable sddm

# Конфиги
mkdir $userDir/gitclone
cd $userDir/gitclone
git clone https://github.com/YunKaga/YunKagaConfigHypr
cd ./YunKagaConfigHypr
mkdir /home/$username/.config
rm -r ./README.md ./pockets.txt ./preview
mv ./* /home/$username/.config/
cd /

# Grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
