#!/bin/bash

# Установка раскладки клавиатуры и шрифта
loadkeys ru
setfont cyr-sun16 

# Вывод приветственного сообщения на экран
echo "*******************************************************"
echo "Добро пожаловать в базовый скрипт установки Arch Linux!"
echo "*******************************************************"

# Обновление системных часов
timedatectl set-ntp true

# Вывод инструкций для пользователя
echo "Пожалуйста, создайте разделы:"
echo "UEFI" 
echo "root"
echo "swap"
echo "home" 
echo "Сейчас будет запущена программа cfdisk для создания разделов. У вас есть 7 секунд для начала. Удачи!"

# Ожидание 7 секунд и запуск cfdisk
sleep 7
cfdisk -z

# Запрос пользователю ввести разделы
read -p "Пожалуйста, введите раздел для UEFI (например /dev/sda1): " uefi_partition
read -p "Пожалуйста, введите раздел для root (например /dev/sda2): " root_partition
read -p "Пожалуйста, введите раздел для swap (например /dev/sda3): " swap_partition
read -p "Пожалуйста, введите раздел для home (например /dev/sda4): " home_partition

# Форматирование раздела UEFI
mkfs.fat -F32 "$uefi_partition"

# Форматирование root раздела
mkfs.ext4 -L "root" "$root_partition"

# Форматирование swap раздела
mkswap "$swap_partition"
swapon "$swap_partition"

# Форматирование home раздела
mkfs.ext4 -L "home" "$home_partition"

# Создание точки монтирования
mount_dir="/mnt"

# Монтирование раздела root
mount "$root_partition" "$mount_dir"

# Создание директории для раздела UEFI, если ее еще нет
mkdir -p "$mount_dir/boot"

# Монтирование раздела UEFI
mount "$uefi_partition" "$mount_dir/boot"

# Монтирование раздела home
mkdir -p "$mount_dir/home"
mount "$home_partition" "$mount_dir/home"

# Установка базовой системы и звука с использованием Pipewire
pacstrap /mnt base linux linux-firmware base-devel nano dhcpcd networkmanager xorg xorg-drivers pipewire pipewire-alsa pipewire-pulse pavucontrol intel-ucode

# Генерация файла /etc/fstab на основе меток разделов
genfstab -L /mnt >> /mnt/etc/fstab

# Настройка часового пояса для Омска
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Omsk /etc/localtime

# Синхронизация системного времени с аппаратным
arch-chroot /mnt hwclock --systohc

# Установка локали ru_UTF-8
arch-chroot /mnt sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
arch-chroot /mnt locale-gen

# Установка переменной окружения LANG для русской локали
arch-chroot /mnt bash -c 'echo "LANG=ru_RU.UTF-8" > /etc/locale.conf'

# Установка раскладки клавиатуры в файле vconsole.conf
arch-chroot /mnt bash -c 'echo "KEYMAP=ru" > /etc/vconsole.conf'
arch-chroot /mnt bash -c 'echo "FONT=cyr-sun16" >> /etc/vconsole.conf'

# Запрос пользователю ввести имя хоста
read -p "Пожалуйста, введите имя хоста: " hostname_input

# Установка введенного пользователем имени хоста в файле /etc/hostname
arch-chroot /mnt bash -c "echo '$hostname_input' > /etc/hostname"

# Обновление образа initramfs
arch-chroot /mnt mkinitcpio -P

# Ввод пароля суперпользователя
echo "Пожалуйста, введите пароль для суперпользователя и нажмите Enter..."
sleep 3
arch-chroot /mnt passwd

# Запрос имени пользователя
read -p "Пожалуйста, введите имя пользователя: " username_input

# Создание учетной записи и добавление пользователя в группу wheel
arch-chroot /mnt useradd -m -G wheel $username_input

# Установка пароля для нового пользователя
arch-chroot /mnt passwd $username_input

# Разрешение пользователям в группе wheel использовать sudo
arch-chroot /mnt sed -i "/%wheel/s/^# //g" /etc/sudoers

# Уведомление пользователю о установке загрузчика systemd-boot
echo "Установка загрузчика systemd-boot..."
sleep 2

# Установка загрузчика systemd-boot
arch-chroot /mnt bootctl install

# Создание файла загрузчика loader.conf
echo "default arch" > /mnt/boot/loader/loader.conf
echo "timeout 4" >> /mnt/boot/loader/loader.conf
echo "console-mode max" >> /mnt/boot/loader/loader.conf
echo "editor no" >> /mnt/boot/loader/loader.conf

# Создание файла конфигурации для загрузчика с использованием лейбла корневого раздела и добавлением поддержки intel-ucode
arch-chroot /mnt bash -c 'echo "title Arch Linux" > /boot/loader/entries/arch.conf'
arch-chroot /mnt bash -c 'echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf'
arch-chroot /mnt bash -c 'echo "initrd /intel-ucode.img" >> /boot/loader/entries/arch.conf'
arch-chroot /mnt bash -c 'echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf'
arch-chroot /mnt bash -c 'echo "options root=LABEL=root rw" >> /boot/loader/entries/arch.conf'

# Информирование пользователя о завершении установки
echo "Базовая система успешно установлена! Вы можете перезагрузить систему."

