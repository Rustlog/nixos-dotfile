{ config, pkgs, ... }:

{
    # environment variables for WM sessions
    environment.sessionVariables = {
        WLR_RENDERER = "vulkan";
        GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    };
}


