#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 移除 openwrt feeds 自带的核心库并拉取最新 passwall 依赖
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本并拉取最新 passwall luci
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# 针对 Aigo AGS21 eMMC 生成传统 Raw Binary 格式固件（适配 bl-mt798x-dhcpd U-Boot）
if grep -q "define Device/aigo_ags21" target/linux/mediatek/image/filogic.mk; then

cat << 'EOF' >> target/linux/mediatek/image/filogic.mk

define Device/aigo_ags21_rawbin
  $(Device/aigo_ags21)
  DEVICE_MODEL := AGS21 (Raw Binary for MTK U-Boot)
  DEVICE_DTS := mt7981b-aigo-ags21
  KERNEL := kernel-bin | gzip
  KERNEL_INITRAMFS := kernel-bin | lzma | pad-to 64k
  KERNEL_INITRAMFS_SUFFIX := -recovery.bin
  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin := append-kernel | pad-to 0x800000 | append-rootfs | pad-rootfs | append-metadata
endef

TARGET_DEVICES += aigo_ags21_rawbin

EOF
fi
