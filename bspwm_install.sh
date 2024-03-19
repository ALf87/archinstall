# Установка пакетов
sudo pacman -S lightdm bspwm sxhkd polybar dmenu picom alacritty

# Копирование конфигурационных файлов в домашнюю директорию
mkdir -p ~/.config/bspwm
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc

mkdir -p ~/.config/sxhkd
cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc

mkdir -p ~/.config/polybar
cp /usr/share/doc/polybar/config ~/.config/polybar/config

# Настройка LightDM
sudo systemctl enable lightdm.service

# Настройка переключения раскладки через Alt+Shift
echo "setxkbmap -layout us,ru -option 'grp:alt_shift_toggle'" >> ~/.xprofile

# Настройка Alacritty в качестве терминала по умолчанию в sxhkd
echo "super + Return" >> ~/.config/sxhkd/sxhkdrc
echo "alacritty" >> ~/.config/sxhkd/sxhkdrc

# Запуск Polybar
echo "exec --no-startup-id polybar example" >> ~/.config/bspwm/bspwmrc

# Установка пакетов
sudo pacman -S libreoffice-fresh libreoffice-fresh-ru qbittorrent vlc vivaldi
