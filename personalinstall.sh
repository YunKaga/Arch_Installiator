#!/bin/bash

setfont cyr-sun16

# Время
ln -sf /usr/share/zoneinfo/Asia/Tomsk /etc/localtime
hwclock --systohc

# Локали
sed -i "171s/.//" /etc/locale.gen # en_US.UTF-8
sed -i "402s/.//" /etc/locale.gen # ru_RU.UTF-8
locale-gen
echo "LANG=\"ru_RU.UTF-8\"" >> /etc/locale.conf

# Хост
nameofhost=""
echo "Введите имя системы"
read nameofhost
echo "$nameofhost" >> /etc/hostname
echo "127.0.1.1    $nameofhost.localdomain     $nameofhost" >> /etc/hosts

# Пользователь
echo "Введите пароль root"
passwd

username=""
echo "Введите имя пользователя: "
read username
useradd -m $username
usermod -aG wheel,audio,video,storage $username

echo "Введите пароль $username"
passwd $username

# Пакеты
pacman -Sy reflector
reflector -c Russia -l 20 --sort rate --save /etc/pacman.d/mirrorlist

sed -i "s/ParallelDownloads = 5/ParallelDownloads = 15/" /etc/pacman.conf

pockets_base="hyprland waybar hyprpaper hypridle hyprlock hyprpicker grim slurp mako networkmanager blueman bluez brightnessctl pipewire wireplumber zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting kitty cmake telegram-desktop firefox wofi thunar ttf-jetbrains-mono-nerd libreoffice-still-ru bashtop fastfetch curl nodejs yarn sddm grub efibootmgr tree-sitter-cli eza duf wl-clipboard "
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

# Grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EDITOR=nvim visudo
