#!/bin/bash

REAL_USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)


echo "📩 Installing tools..."

# install curl
sudo apt-get update && sudo apt-get install curl || { echo "❌ Failed to install curl. Exiting..."; exit 1; }
echo "✅ curl installed."

#install wget
sudo apt-get update && sudo apt-get install wget || { echo "❌ Failed to install wget. Exiting..."; exit 1; }
echo "✅ wget installed."

# install git
sudo apt-get update && sudo apt-get install git || { echo "❌ Failed to install git. Exiting..."; exit 1; }
echo "✅ git installed."

# install gh (GitHub CLI)
sudo apt-get update && sudo apt-get install gh || { echo "❌ Failed to install gh. Exiting..."; exit 1; }
echo "✅ gh installed."



echo "📩 Installing applications..."

# install Spotify
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client || { echo "❌ Failed to install Spotify. Exiting..."; exit 1; }
echo "✅ Spotify installed."

# install Discord
DISCORD_PATH="/usr/share/discord/resources/build_info.json"
DISCORD_DOWNLOAD_URL="https://discord.com/api/download/stable?platform=linux&format=deb"
if [ -f "$DISCORD_PATH" ]; then
    installed_version=$(jq -r ".version" < "$DISCORD_PATH")
else
    installed_version=""
fi
deb_url=$(curl -s -I "$DISCORD_DOWNLOAD_URL" | grep -i "location:" | awk -F': ' '{print $2}' | tr -d '\r\n')
current_version=$(basename "$deb_url" | sed 's/^discord-\(.*\).deb/\1/')
if [[ "$installed_version" != "$current_version" ]]; then
    echo "Installed Discord version ($installed_version) differs from the current version ($current_version)."
    echo "Downloading and updating to version $current_version..."
    file_name="$TEMP_DIR/discord-$current_version.deb"
    if curl -s "$deb_url" -o "$file_name"; then
        echo "Installing Discord..."
        if dpkg -i "$file_name"; then
            echo "✅ Discord updated."
        else
            echo "❌ Discord installation failed. Attempting to fix broken dependencies..."
            apt-get -f install -y
        fi
        rm -f "$file_name"
    else
        echo "❌ Failed to download Discord package."
    fi
else
    echo "✅ Discord is already up-to-date (version $installed_version)."
fi

# install VSCode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft-archive-keyring.gpg
sudo apt-get update && sudo apt-get install code || { echo "❌ Failed to install VSCode. Exiting..."; exit 1; }
rm microsoft.gpg
echo "✅ VSCode installed."

# install Firefox ESR
sudo apt-get update && sudo apt-get install firefox-esr || { echo "❌ Failed to install Firefox ESR. Exiting..."; exit 1; }
echo "✅ Firefox ESR installed."

# install inkscape
sudo apt-get update && sudo apt-get install inkscape || { echo "❌ Failed to install Inkscape. Exiting..."; exit 1; }
echo "✅ Inkscape installed."



echo "📩 Installing dotfiles..."

# install widgets
mkdir -p "$REAL_USER_HOME/.local/share/plasma/plasmoids" || { echo "❌ Failed to create plasmoids directory. Exiting..."; exit 1;
cp .local/share/plasma/plasmoids/* "$REAL_USER_HOME/.local/share/plasma/plasmoids/" || { echo "❌ Failed to copy plasmoids. Exiting..."; exit 1; }
# TODO: set widget locations?
echo "✅ Widgets installed."

# configure Firefox ESR
mkdir -p "$REAL_USER_HOME/.mozilla/firefox/4cjgmrsp.default-esr" || { echo "❌ Failed to create Firefox directories. Exiting..."; exit 1; }
cp FirefoxESR/profiles.ini "$REAL_USER_HOME/.mozilla/firefox/profiles.ini" || { echo "❌ Failed to copy profiles.ini. Exiting..."; exit 1; }
cp FirefoxESR/user.js "$REAL_USER_HOME/.mozilla/firefox/4cjgmrsp.default-esr/user.js" || { echo "❌ Failed to copy user.js. Exiting..."; exit 1; }
cp FirefoxESR/extensions "$REAL_USER_HOME/.mozilla/firefox/4cjgmrsp.default-esr/" || { echo "❌ Failed to copy extensions folder. Exiting..."; exit 1; }
chown -R "$SUDO_USER:$SUDO_USER" "$REAL_USER_HOME/.mozilla/firefox" || { echo "❌ Failed to set permissions. Exiting..."; exit 1; }
echo "✅ Firefox ESR configured."

# desktop background
cp background.png "$REAL_USER_HOME/Pictures/background.png" || { echo "❌ Failed to copy background image. Exiting..."; exit 1; }
sed "s|/home/charlie|$REAL_USER_HOME|g" .config/plasmarc > "$REAL_USER_HOME/.config/plasmarc" || { echo "❌ Failed to copy plasmarc. Exiting..."; exit 1; }
chown "$SUDO_USER:$SUDO_USER" "$REAL_USER_HOME/.config/plasmarc"
echo "✅ Background set."

# Spicetify
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh
sudo chmod a+wr /usr/share/spotify
sudo chmod a+wr /usr/share/spotify/Apps -R
spicetify
cp .config/Spicetify/Themes/sleek "$REAL_USER_HOME/.config/spicetify/Themes/" || { echo "❌ Failed to copy Spicetify theme. Exiting..."; exit 1; }
spicetify config current_theme sleek
spicetify config color_scheme Psycho
spicetify backup apply || { echo "❌ Failed to apply Spicetify configuration. Exiting..."; exit 1; }
echo "✅ Spicetify configured."

# font 
# (font selection in kdeglobals)
mkdir -p /usr/local/share/fonts/j || { echo "❌ Failed to create font directory. Exiting..."; exit 1; }
cp fonts/*.ttf /usr/local/share/fonts/j/ || { echo "❌ Failed to copy font files. Exiting..."; exit 1; }
fc-cache -fv
echo "✅ Fonts installed."

cp .config/kdeglobals "$REAL_USER_HOME/.config/kdeglobals" || { echo "❌ Failed to copy kdeglobals. Exiting..."; exit 1; }
chown "$SUDO_USER:$SUDO_USER" "$REAL_USER_HOME/.config/kdeglobals"


# panels
# ~/.config/plasma-org.kde.plasma.desktop-appletsrc This has your panel and widget setup.


echo "🎉 Installation completed successfully!"