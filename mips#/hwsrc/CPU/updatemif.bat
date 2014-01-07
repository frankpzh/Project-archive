@echo off
quartus_cdb CPU -c CPU --update_mif
quartus_asm --read_settings_files=on --write_settings_files=off CPU -c CPU
