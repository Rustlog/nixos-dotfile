{ config, pkgs, ... }:

{
    # environment variables for WM sessions
    environment.sessionVariables = {
        GTK_THEME = "Breeze:dark";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        WLR_RENDERER = "vulkan";
        GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    };
}


