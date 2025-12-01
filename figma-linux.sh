#!/bin/bash

echo "=== Установка Figma Linux через yay ==="
yay -S --noconfirm figma-linux || { echo "Ошибка установки Figma"; exit 1; }

echo "=== Создание локальной копии ярлыка ==="
mkdir -p ~/.local/share/applications

if [ -f /usr/share/applications/figma-linux.desktop ]; then
    cp /usr/share/applications/figma-linux.desktop ~/.local/share/applications/
else
    echo "Не найден /usr/share/applications/figma-linux.desktop"
    echo "Проверяю другое имя..."
    if [ -f /usr/share/applications/figma.desktop ]; then
        cp /usr/share/applications/figma.desktop ~/.local/share/applications/
    else
        echo "Файл ярлыка Figma не найден. Прерываю."
        exit 1
    fi
fi

DESKTOP_FILE=~/.local/share/applications/figma-linux.desktop

echo "=== Проверка окружения: Wayland или X11 ==="

if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    echo "Обнаружен Wayland — включаю серверные декорации и нативный режим."
    EXEC_OPTS="--enable-features=WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime"
else
    echo "Обнаружен X11 — включаю XWayland параметры."
    EXEC_OPTS="--no-sandbox --ozone-platform=x11 --ozone-platform-hint=x11 --disable-gpu-memory-buffer-video-frames"
fi

echo "=== Поиск бинарника Figma ==="

if [ -f /opt/figma-linux/figma-linux ]; then
    BINARY="/opt/figma-linux/figma-linux"
else
    BINARY=$(which figma-linux)
fi

if [ -z "$BINARY" ]; then
    echo "Ошибка: бинарник figma-linux не найден."
    exit 1
fi

echo "=== Применяю Exec строку ==="
sed -i "s|^Exec=.*|Exec=$BINARY $EXEC_OPTS %U|" "$DESKTOP_FILE"

echo "=== Обновление кэша KDE ==="
kbuildsycoca6 --noincremental

echo "=== Готово! ==="
echo "Figma теперь запускается оптимально под вашу сессию ($XDG_SESSION_TYPE)."
