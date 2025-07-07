#!/usr/bin/env zsh

set -euo pipefail

NIXOS_USERS="/etc/nixos/users.nix"
HOMES_DIR="/etc/nixos/homes"
TEMPLATE="${HOMES_DIR}/template.nix"
SKEL="${HOMES_DIR}/skel"

echo "=== NixOS User Creation Script ==="

# 1. Prompt for input
echo "[1/7] Collecting user information..."

echo -n "Enter new username: "
read username

echo -n "Enter full name: "
read fullname

# 2. Password and SSH key
echo "[2/7] Generating hashed password..."

echo -n "Enter password for ${username}: "
read -s password

echo
hashed_pw=$(echo "$password" | mkpasswd -m sha-512 -)
echo "Password hashed."

echo "[3/7] Generating SSH keypair..."
ssh_dir="/tmp/${username}-ssh"
mkdir -p "$ssh_dir"
ssh-keygen -t ed25519 -N "" -C "${username}@$(hostname)" -f "${ssh_dir}/id_ed25519" > /dev/null
pubkey=$(cat "${ssh_dir}/id_ed25519.pub")
echo "SSH key generated for ${username}."

# 4. Copy and customize home-manager template
echo "[4/7] Creating home-manager configuration for ${username}..."
user_home_nix="${HOMES_DIR}/${username}.nix"
cp "$TEMPLATE" "$user_home_nix"
sed -i "s/your-username/${username}/g" "$user_home_nix"
sed -i "s|/home/your-username|/home/${username}|g" "$user_home_nix"
echo "Home-manager config created at ${user_home_nix}."

# 5. Insert user into users.nix (users.users and home-manager.users)
echo "[5/7] Updating ${NIXOS_USERS} with new user blocks..."
user_block="
    ${username} = {
      isNormalUser = true;
      extraGroups = [ \"wheel\" \"docker\" \"libvirtd\" \"ssh\" \"plugdev\" ];
      hashedPassword = \"${hashed_pw}\";
      openssh.authorizedKeys.keys = [
        \"${pubkey}\"
      ];
      description = \"${fullname}\";
      shell = pkgs.zsh;
      home = \"/home/${username}\";
    };
"
hm_block="
    ${username} = { ... }: {
      imports = [
        ./homes/${username}.nix
      ];
    };
"

awk -v user_block="$user_block" '
  /# Add More Users Here/ && !x {print; print user_block; x=1; next} 1
' "$NIXOS_USERS" > "${NIXOS_USERS}.tmp1"

awk -v hm_block="$hm_block" '
  /# Add More User Configurations Here/ && !x {print; print hm_block; x=1; next} 1
' "${NIXOS_USERS}.tmp1" > "${NIXOS_USERS}.tmp2"

mv "${NIXOS_USERS}.tmp2" "$NIXOS_USERS"
rm -f "${NIXOS_USERS}.tmp1"
echo "User and home-manager blocks inserted into ${NIXOS_USERS}."

# 6. Pre-populate home directory with skel
user_home="/home/${username}"
echo "[6/7] Populating ${user_home} from skel template..."
if [ -d "$SKEL" ]; then
  mkdir -p "$user_home"
  cp -aT "$SKEL" "$user_home"
  chown -R "${username}:users" "$user_home" 2>/dev/null || \
    echo "  (User not yet created; set ownership after nixos-rebuild.)"
else
  echo "  (No skel directory found at $SKEL, skipping home population.)"
fi

chown ${username}:users /home/${username} -R

# 7. Output
echo "[7/7] Done!"
echo
echo "=== Summary ==="
echo "User '${username}' added to ${NIXOS_USERS}."
echo "Home-manager config: ${user_home_nix}"
echo "Home directory will be pre-populated from ${SKEL}."
echo "SSH private key: ${ssh_dir}/id_ed25519 (move it securely to the user!)"
echo
echo "Next steps:"
echo "  1. Review the changes in ${NIXOS_USERS} and ${user_home_nix}."
echo "  2. Run: sudo nixos-rebuild switch"
echo "  3. After the user is created, fix home directory ownership if needed:"
echo "     sudo chown -R ${username}:users /home/${username}"
echo
echo "All done!"
