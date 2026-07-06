# my-emulator-launcher
i emulator launcher i have been working on in my free time.
what this emulator dosent come with retroarch, dolpin, switch emulators, roms and cores this need to be added later.

# whats needed to install (all needed to be installed from flathub)
flathub https://flathub.org/en/setup
retroarch: flatpak install flathub org.libretro.RetroArch
dolphin emuloator: flatpak install flathub org.DolphinEmu.dolphin-emu 
switch emulator : flatpak install flathub io.github.ryubing.Ryujinx

# how to add/remove consoles 
rom_dir this is the folder with the ssystem roms.
extensions scans for extenstion files.
flatpak_id the app id for installing/adding flatpak/flathub emulators .
launch_args its an argument to  pass use '{roms}' as an place holder for  a full rom path. 

# how to find retroarch core path (needed to add devices the ones that dont need to be added are below
nes (FCEUmm), 3ds (citra 2018), gb/gbc (DoubleCherryGB), gba (gpSP), n64 (Mupen64Plus-Next), pokemon mini (Pokemini). snes/sfc (Beetle supafaust), pico 8 (retro8-) dreamcast (flycast), psx/ps1 (Beetlepsx hw), ps2 (krps2), tic-80 (just tic 80 for the core),) thats all you still need to download this core from retro arch 
to list the cores its: ls ~/.var/app/org.Libretro.RetroArch/config/retroarch/cores/
pcik the .so that matchs the system like (fceumm_libretro.so) for nes and snes snes9x_libretro.so and put its ful path in launch_args
#dolphin (gamecube/wii)
all you need is -b -e {roms} batch mode run the exit on close its  already setup in the example.

# copying roms 
by defult the exaple uses ~/RetroGames/<system>/ create this folderand drop your roms in it.

# store ill add it to.
 snapstore(not on it rn becuse its down)
 if wanted i can add it to others 
 
 # how to customize background colors 

press o for the options menu/settings 
# what im going to add 
1.box art/metadata
2. new ui/better ui 
3. recently played/favorite tabs 
4. controller buttion icon
# all this is above slot into libary.gd data and main.gd/main.tscn

# bug fixs
1.option menu being off the screen

# bugs 
1. option menu not usable with keybored/not being abled to scroll down
2. add console/roms option not working 


