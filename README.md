    ██████╗ ██╗██╗  ██╗ ██████╗ ███████╗
    ██╔══██╗██║██║ ██╔╝██╔═══██╗██╔════╝
    ██████╔╝██║█████╔╝ ██║   ██║███████╗
    ██╔══██╗██║██╔═██╗ ██║   ██║╚════██║
    ██║  ██║██║██║  ██╗╚██████╔╝███████║
    ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝

# RikOS NixOS Configuration

Welcome to my personal NixOS configuration system! This setup is designed for both servers and desktops, with a focus on modularity, security, and ease of use. Whether you’re running a headless server or a full-featured desktop, RikOS has you covered.

Please note: These modules were handwritten. I would not recommend extending them with AI.
It will propose a change that might break your system. These files have been properly tested, and are working with version NixOS 25.05.

---

## ⚡️ Facts at a Glance

- **OS:** [NixOS](https://nixos.org/) (flakes-based, modular)
- **Desktop Environment:** KDE Plasma (desktop mode)
- **User Management:** [Home Manager](https://nix-community.github.io/home-manager/), custom scripts
- **Multi-Host Deploy:** [Colmena](https://github.com/zhaofengli/colmena)
- **Security:** Firewall, antivirus, antirootkit, secure boot, auditing, and more
- **Dev Ready:** Rust, Python, Node.js, Go, PHP, VS Code, tmux, git, and more

---

## 📦 Software Highlights

- **KDE Plasma** for a modern desktop experience
- **Fastfetch** for beautiful system info
- **VS Code** with dev extensions
- **Docker, PostgreSQL, MariaDB, Redis, MinIO** for server/dev work
- **Gaming:** Proton, Steam, Lutris (desktop mode)
- **Security:** ClamAV, chkrootkit, fail2ban, AppArmor, auditd
- **Radio:** HackRF, RTL-SDR, GQRX, CubicSDR

---

## 🚀 Quick Tutorial

### 1. Installation

```bash
git clone <your-repo-url> /etc/nixos
cd /etc/nixos
```

- Make sure you have NixOS 25.05+ and flakes enabled.
- Edit `flake.nix` to add your device (see below).

### 2. Add a Device

- **Desktop:**
  - Copy `devices/desktop-template.nix` to `devices/<your-hostname>.nix`
- **Server:**
  - Copy `devices/server-template.nix` to `devices/<your-hostname>.nix`

Edit your new device file:
- Set `device.name` and `networking.hostName`
- Import the right hardware modules (CPU, GPU, motherboard, etc.)
- Adjust boot, filesystem, and network settings

Add your device to `flake.nix` under `hosts`.

### 3. Add a User
You might want to extend the `homes/skel` folder first with a few default files. For example for KDE.

**Option 1: Scripted (recommended)**

```bash
sudo ./scripts/add-nixos-user.sh
```
- Prompts for username, full name, password, and generates SSH keys
- Copies and customizes the home-manager template
- Updates `users.nix` and pre-populates the home directory

**Option 2: Manual**

- Copy `homes/template.nix` to `homes/<your-username>.nix` and edit it
- Add your user to `users.nix` (see template block in that file)
- Add a home-manager config for your user in `users.nix`
- Generate a password hash: `mkpasswd -m sha-512`
- Add your SSH public key

### 4. Build and Switch

```bash
sudo nixos-rebuild switch --flake .#<your-hostname>
```

---

## 🖥️ Directory Structure

```
nixos/
├── devices/         # Device configs (per-machine)
├── homes/           # User configs (per-user)
├── modules/         # Modular system, hardware, and software configs
├── scripts/         # Helper scripts (add users, backup, etc.)
├── configuration.nix  # Main entry point
├── flake.nix          # Flake definition
├── users.nix          # User and home-manager config
└── colmena.nix        # (Optional) Multi-host deploy with Colmena
```

---

## 🤝 Contributing & Credits

This is my personal setup, but feel free to fork, adapt, or suggest improvements!

Thanks to the NixOS, Home-manager, KDE, and open-source communities!

---

*Happy hacking!*
