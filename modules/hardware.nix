{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

    # bootloader config
    boot.loader = {
        systemd-boot.enable = false;
        grub = {
            enable = true;
            efiSupport = false;
            device = "nodev";
            enableCryptodisk = true;
            # extraConfig
            extraEntries = ''
                if [ -f  ''${config_directory}/custom.cfg ]; then
                    source ''${config_directory}/custom.cfg
                elif [ -z "''${config_directory}" -a -f  $prefix/custom.cfg ]; then
                    source $prefix/custom.cfg
                fi
            '';
        };
        efi.canTouchEfiVariables = true;
    };

    # initramfs and kernel parameters
    boot = {
        plymouth = {
            enable = true;
            theme = "bgrt";
        };

        kernelParams = [ "quiet" "splash" ];
        consoleLogLevel = 3;

        initrd = {
            systemd.enable = true;
            services.lvm.enable = true;
            kernelModules = [ "dm_mod" ];
            availableKernelModules = [
                "nvme" "xhci_pci" "usb_storage"
                "sd_mod" "rtsx_pci_sdmmc"
            ];
            luks.devices = {
                "cryptpart" = { # Encrypted luks partition
                    device = "/dev/disk/by-label/cryptpool-lvm";
                };
            };
        };

        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
    };

    # partition/logical-volume mounts ( for /etc/fstab )
    fileSystems = {
        "/" = {
            device = "/dev/vg0/nixos";
            fsType = "ext4";
        };
        "/boot" = {
            device = "/dev/vg_boot/nixos";
            fsType = "ext4";
        };
        "/boot/efi" = {
           device = "/dev/disk/by-uuid/082D-5792";
           fsType = "vfat";
        };
        "/dt" = {
            device = "/dev/vg0/shared_dt";
            fsType = "ext4";
        };
    };

    # swap devices
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
        swapDevices = 1;
    };
    swapDevices = [
        { device = "/dev/vg0/swap"; priority = 10; }
    ];

    # define architecture & add cpu microcode
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

