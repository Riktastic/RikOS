# Server/Desktop Mode Configuration

This document explains the server/desktop mode functionality in your NixOS configuration.

## Overview

Your NixOS configuration now supports two distinct modes:
- **Desktop Mode**: Full desktop environment with both CLI and GUI applications
- **Server Mode**: CLI-only environment with server-appropriate tools

## How It Works

### Device Configuration

Each device configuration now includes a `device` section that specifies the mode:

```nix
device = {
  mode = "desktop";  # or "server"
  name = "your-device-name";
  description = "Optional description";
};
```

### Module Behavior

The desktop environment (KDE) is only enabled in desktop mode. Other modules work as follows:

- **Desktop Mode**: Installs both CLI and GUI tools
- **Server Mode**: Installs only CLI tools (no desktop environment)

## Device Configurations

### Desktop Devices (Hercules)
- **Mode**: `desktop`
- **Features**: Full KDE Plasma desktop, GUI applications, gaming support
- **Template**: `devices/template.nix`

### Server Devices (Lira)
- **Mode**: `server`
- **Features**: CLI-only, no desktop environment, server monitoring tools
- **Template**: `devices/server-template.nix`

## Module Updates

### Desktop Environment
- **KDE Module**: Only enabled in desktop mode using `lib.mkIf (cfg.mode == "desktop")`

### Software Suites
The following modules work in both modes but install appropriate tools:
- **Development**: CLI tools in both modes, GUI tools only in desktop
- **Data Science**: CLI tools in both modes, GUI tools only in desktop
- **Mathematics**: CLI tools in both modes, GUI tools only in desktop

### Unchanged Modules
The following modules don't need changes (as you specified):
- **Proton**: Works in both modes
- **Office**: Works in both modes
- **Gaming**: Works in both modes
- **Internet**: Works in both modes
- **Media**: Works in both modes

## Usage Examples

### Desktop Configuration

```nix
# devices/my-desktop.nix
device = {
  mode = "desktop";
  name = "My Desktop";
  description = "Main development and gaming machine";
};
```

### Server Configuration

```nix
# devices/my-server.nix
device = {
  mode = "server";
  name = "My Server";
  description = "Production web server";
};
```

## Benefits

### Desktop Mode
- Full desktop environment with KDE Plasma
- Both CLI and GUI applications available
- Gaming support with Steam and Proton
- Visual development tools

### Server Mode
- No desktop environment (saves resources)
- CLI tools optimized for server use
- Additional server monitoring utilities
- Reduced attack surface
- Better performance for server workloads

## Migration Guide

### Converting Existing Devices

1. **Add device configuration** to your existing device files:
   ```nix
   device = {
     mode = "desktop";  # or "server"
     name = "Your Device Name";
   };
   ```

2. **Rebuild your system**:
   ```bash
   sudo nixos-rebuild switch
   ```

### Creating New Server Devices

1. **Copy the server template**:
   ```bash
   cp devices/server-template.nix devices/my-server.nix
   ```

2. **Update the configuration**:
   - Set hostname and device name
   - Configure hardware modules
   - Set up network and filesystem settings

3. **Add to your flake.nix**:
   ```nix
   my-server = mkHost {
     system = "x86_64-linux";
     hostname = "my-server";
     modules = [
       # Device-specific modules
     ];
   };
   ```

## Environment Variables

The system automatically sets these environment variables:
- `NIXOS_DEVICE_MODE`: "desktop" or "server"
- `NIXOS_DEVICE_NAME`: Your device name
- `NIXOS_DEVICE_DESCRIPTION`: Your device description (if set)

## Troubleshooting

### Desktop Environment Not Starting
- Check that `device.mode = "desktop"` is set
- Verify KDE module is imported in configuration.nix
- Check X server and graphics driver configuration

### Missing GUI Applications
- Ensure you're in desktop mode
- Check that the appropriate software modules are imported
- Verify package availability in nixpkgs

### Server Tools Not Available
- Check that `device.mode = "server"` is set
- Verify server-specific modules are imported
- Check package availability in nixpkgs

## File Structure

```
nixos/
├── configuration.nix          # Main config (imports device.nix)
├── modules/
│   └── system/
│       └── device.nix         # Device mode configuration
├── devices/
│   ├── template.nix           # Desktop template with mode setting
│   ├── server-template.nix    # Server template with mode setting
│   ├── hercules.nix           # Desktop example
│   └── lira.nix               # Server example
└── modules/desktop/
    └── kde.nix                # Conditional desktop environment
```

## Building and Deploying

### Build a specific device:
```bash
nix build .#nixosConfigurations.hercules.config.system.build.toplevel
nix build .#nixosConfigurations.lira.config.system.build.toplevel
```

### Deploy a specific device:
```bash
nixos-rebuild switch --flake .#hercules
nixos-rebuild switch --flake .#lira
```

This configuration provides a clean, maintainable way to support both desktop and server deployments from the same codebase. 