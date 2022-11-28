# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
	hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
	sw ta te th tr uk vi zh-CN zh-TW
"

inherit chromium-2 desktop rpm xdg

DESCRIPTION="Unofficial Microsoft 365 Web Desktop Wrapper made with Electron "
HOMEPAGE="https://github.com/agam778/MS-365-Electron"
SRC_URI="https://github.com/agam778/MS-365-Electron/releases/download/v${PV}/MS-365-Electron-v${PV}-linux-x86_64.rpm"
S="${WORKDIR}"

KEYWORDS="-* ~amd64"
LICENSE="MIT"
SLOT="0"
RESTRICT="bindist mirror"

RDEPEND="
	|| (
		>=app-accessibility/at-spi2-core-2.46.0:2
		( app-accessibility/at-spi2-atk dev-libs/atk )
	)
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-libs/glibc
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
"

QA_PREBUILT="opt/MS-365-Electron/*"

pkg_pretend() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default
	sed -i -e '/MimeType=MS-365-Electron/d' usr/share/applications/ms-365-electron.desktop || die
	pushd "opt/MS-365-Electron/locales" || die
	chromium_remove_language_paks
	popd || die
}

src_configure() {
	chromium_suid_sandbox_check_kernel_config
	default
}

src_install() {
	for size in {64,128,512}; do
		doicon -s ${size} "usr/share/icons/hicolor/${size}x${size}/apps/ms-365-electron.png"
	done

	domenu usr/share/applications/ms-365-electron.desktop

	local DESTDIR="/opt/MS-365-Electron"
	pushd "opt/MS-365-Electron" || die

	exeinto "${DESTDIR}"
	doexe chrome-sandbox ms-365-electron *.so*

	insinto "${DESTDIR}"
	doins *.pak *.bin *.json *.dat
	insopts -m0755
	doins -r locales resources

	# see https://github.com/electron/electron/issues/17972
	fperms 4755 "${DESTDIR}"/chrome-sandbox

	dosym "${DESTDIR}"/ms-365-electron /opt/bin/ms-365-electron
	popd || die
}
