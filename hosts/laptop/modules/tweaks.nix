{ config, pkgs, ... }:

{
    # path fixes
    environment.etc = {
        "color/icc/colord".source = "${pkgs.colord}/share/color/icc/colord";
        "vulkan_loaders/icd.d".source = "${pkgs.mesa}/share/vulkan/icd.d";
        "zsh-syntax-highlighting".source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
    };
    system.activationScripts = {
        "fixSymlinks" = {
            text = ''
                mkdir -p /usr/share/ /usr/share/color/icc/ /usr/share/zsh/ /usr/share/kbd/
                ln -sf /etc/color/icc/colord /usr/share/color/icc/
                ln -sf /etc/vulkan_loaders /usr/share/vulkan
                ln -sf /etc/zsh-syntax-highlighting /usr/share/zsh/
                for b in /run/current-system/sw/bin/{zsh,bash,sh}; do
                    ln -sf "''${b}" /usr/bin/
                done
            '';
        };
    };
    environment.etc."containers/storage.conf".text = ''
        [storage]
        driver = "overlay"
        graphroot = "/shared/containers/podman_containers/storage/"
        runroot = "/run/containers/storage/"
    '';
}

