@echo off
quartus_map --read_settings_files=on --write_settings_files=off CPU -c CPU
quartus_fit --read_settings_files=off --write_settings_files=off CPU -c CPU
quartus_asm --read_settings_files=off --write_settings_files=off CPU -c CPU