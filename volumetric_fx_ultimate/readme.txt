================================================================================
                    VOLUMETRIC FX ULTIMATE v1.0.0
              Advanced Volumetric Effects for BeamNG.drive
                      Vulkan API Optimized
================================================================================

INSTALLATION
------------
1. Extract this archive to your BeamNG.drive mods folder:
   - Windows: %LOCALAPPDATA%\BeamNG.drive\0.28\mods\
   - Linux: ~/.local/share/BeamNG.drive/0.28/mods/
   
2. Launch BeamNG.drive with Vulkan API enabled (Settings > Graphics > API)

3. Access the configuration UI from the Apps menu in-game

FEATURES
--------

🌤️ VOLUMETRIC SKYBOX
   - Dynamic atmospheric scattering
   - Realistic sunset/sunrise transitions
   - Configurable night sky with stars
   - Time-of-day integration
   - Customizable sunset colors

☁️ VOLUMETRIC CLOUDS
   - 4 cloud types: Cumulus, Stratus, Cirrus, Storm
   - Animated cloud movement with wind simulation
   - Volumetric lighting and shadows
   - Adjustable density, coverage, and height
   - GPU-accelerated raymarching

🌫️ VOLUMETRIC FOG
   - Height-based fog with falloff
   - Ground fog layer option
   - Light scattering effects
   - Dynamic noise animation
   - Customizable fog color

🔥 BACKFIRE SYSTEM
   - Multi-emitter particle flames
   - Realistic flame physics
   - Screen shake effect
   - Sound effect integration
   - Per-vehicle exhaust detection
   - Configurable intensity and duration

⚙️ QUALITY PRESETS
   - Low: Optimized for performance
   - Medium: Balanced quality/performance
   - High: Recommended for most systems
   - Ultra: Maximum visual fidelity

UI CONTROLS
-----------
The mod includes a professional minimalistic UI accessible from the Apps menu:

- Sky Tab: Control sky intensity, sunset colors, night brightness, stars
- Clouds Tab: Adjust cloud density, coverage, type, animation speed
- Fog Tab: Configure fog density, height falloff, ground fog
- Fire Tab: Tune backfire intensity, particle count, screen shake
- Settings Tab: Quality presets, reset to defaults

CONFIGURATION FILES
-------------------
User settings are saved to:
/settings/volumetric_fx_ultimate.json

Manual editing is possible but not recommended. Use the in-game UI.

VULKAN OPTIMIZATION
-------------------
This mod is specifically designed for Vulkan API:
- SPIR-V shader optimization
- Descriptor set layouts for efficient binding
- Compute shader particle simulation
- Indirect drawing for particles
- Push constants for per-frame updates

DX11 compatibility is maintained as fallback.

PERFORMANCE NOTES
-----------------
- GPU memory usage: ~200-500MB depending on quality setting
- Recommended VRAM: 4GB minimum, 8GB for Ultra
- CPU overhead: Minimal (GPU-driven effects)
- Particle limit scales with quality preset

TROUBLESHOOTING
---------------
Q: Mod doesn't appear in Apps menu
A: Ensure the mod folder is named "volumetric_fx_ultimate" and placed in the correct mods directory

Q: Effects not visible
A: Check that each effect is enabled in the UI. Verify Vulkan API is selected in graphics settings.

Q: Performance issues
A: Lower the quality preset in the Settings tab. Reduce cloud density and particle count.

Q: Crashes on startup
A: Update to latest BeamNG.drive version. Ensure no conflicting graphics mods are active.

CREDITS
-------
Developed by: VFX Studios
Based on research of existing volumetric mods including:
- Volumetric Backfire VBF
- Volumetric Cloud System

LICENSE
-------
For personal use only. Commercial distribution requires explicit permission.

VERSION HISTORY
---------------
1.0.0 (Initial Release)
- Complete volumetric skybox system
- Four cloud types with animation
- Height-based and ground fog
- Multi-emitter backfire system
- Professional UI configuration app
- Vulkan API optimization

SUPPORT
-------
For issues and feature requests, please visit the mod discussion forum.

================================================================================
                         Thank you for using
                    Volumetric FX Ultimate!
================================================================================
