# Adopted from:
# https://github.com/igorpecovnik/lib/blob/master/config/bootscripts/boot-pine64-default.cmd
# https://github.com/longsleep/u-boot-pine64/blob/55c9c8c8ac005b1c00ac948386c60c4a741ebaa9/include/configs/sun50iw1p1.h#L339

# load dtb, kernel and initrd
run load_dtb load_kernel load_initrd

# set_cmdline
setenv bootargs "console=${console} ${optargs} androidboot.serialno=${sunxi_serial} androidboot.hardware=${hardware} androidboot.selinux=${selinux} earlyprintk=sunxi-uart,0x01c28000 loglevel=8 root=${root} eth0_speed=${eth0_speed}"

# set display resolution from uEnv.txt or other environment file
# default to 1080p30
if test "${disp_mode}" = "480i"; then setenv fdt_disp_mode "<0x00000000>"
elif test "${disp_mode}" = "576i"; then setenv fdt_disp_mode "<0x00000001>"
elif test "${disp_mode}" = "480p"; then setenv fdt_disp_mode "<0x00000002>"
elif test "${disp_mode}" = "576p"; then setenv fdt_disp_mode "<0x00000003>"
elif test "${disp_mode}" = "720p50"; then setenv fdt_disp_mode "<0x00000004>"
elif test "${disp_mode}" = "720p60"; then setenv fdt_disp_mode "<0x00000005>"
elif test "${disp_mode}" = "1080i50"; then setenv fdt_disp_mode "<0x00000006>"
elif test "${disp_mode}" = "1080i60"; then setenv fdt_disp_mode "<0x00000007>"
elif test "${disp_mode}" = "1080p24"; then setenv fdt_disp_mode "<0x00000008>"
elif test "${disp_mode}" = "1080p50"; then setenv fdt_disp_mode "<0x00000009>"
elif test "${disp_mode}" = "1080p60"; then setenv fdt_disp_mode "<0x0000000a>"
elif test "${disp_mode}" = "2160p30"; then setenv fdt_disp_mode "<0x0000001c>"
elif test "${disp_mode}" = "2160p25"; then setenv fdt_disp_mode "<0x0000001d>"
elif test "${disp_mode}" = "2160p24"; then setenv fdt_disp_mode "<0x0000001e>"
else setenv fdt_disp_mode "<0x0000000a>"
fi

if test "${pine64_lcd}" = "on"; then
  echo "Using LCD for main screen"
	fdt set /soc@01c00000/disp@01000000 screen0_output_type "<0x00000001>"
	fdt set /soc@01c00000/disp@01000000 screen0_output_mode "<0x00000004>"
	fdt set /soc@01c00000/disp@01000000 screen1_output_mode ${fdt_disp_mode}

	fdt set /soc@01c00000/lcd0@01c0c000 lcd_used "<0x00000001>"

	fdt set /soc@01c00000/boot_disp output_type "<0x00000001>"
	fdt set /soc@01c00000/boot_disp output_mode "<0x00000004>"

	fdt set /soc@01c00000/ctp status "okay"
	fdt set /soc@01c00000/ctp ctp_used "<0x00000001>"
	fdt set /soc@01c00000/ctp ctp_name "gt911_DB2"
else
  echo "Using HDMI for main screen with Display Mode=${fdt_disp_mode}"
	fdt set /soc@01c00000/disp@01000000 screen0_output_mode ${fdt_disp_mode}
fi

# DVI compatibility
if test "${disp_dvi_compat}" = "on"; then
	fdt set /soc@01c00000/hdmi@01ee0000 hdmi_hdcp_enable "<0x00000000>"
	fdt set /soc@01c00000/hdmi@01ee0000 hdmi_cts_compatibility "<0x00000001>"
fi

# default, only set status
if test "${camera_type}" = "s5k4ec"; then
	fdt set /soc@01c00000/vfe@0/ status "okay"
	fdt set /soc@01c00000/vfe@0/dev@0/ status "okay"
fi

# change name, i2c address and vdd voltage
if test "${camera_type}" = "ov5640"; then
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_mname "ov5640"
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_twi_addr "<0x00000078>"
	fdt set /soc@01c00000/vfe@0/dev@0/ csi0_dev0_iovdd_vol "<0x001b7740>"
	fdt set /soc@01c00000/vfe@0/ status "okay"
	fdt set /soc@01c00000/vfe@0/dev@0/ status "okay"
fi

# start system
run boot_kernel