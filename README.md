# RADUSELF custom LibVLC sources - 305-plugin review snapshot

This repository documents native source materials for the custom Windows x64 LibVLC engine used in RADUSELF Player. It is an independent project, not an official VideoLAN distribution.

## Status

Review snapshot. A fresh source/build tree on the existing Ubuntu host produced 305 retained plugins and 308 DLL files. The files were checked against the installation output, copied to Windows and functionally tested. This is not a bit-for-bit reproducibility claim or a build on a freshly installed operating system.

Player MSIX 1.0.17.0 was tested with WACK: 22 PASS, one optional FAIL (Blocked executables), one nonoptional WARNING (DPIAwarenessValidation), overall WARNING. The later About/licenses integration is being tested separately as application version 1.0.18. No claim of final Microsoft Store or licensing clearance is made.

## Native build

VLC source commit: `6de05adcbaf2e8b85fe86aad4169393098628119` (3.0.24-rc1).

The custom build is distinct from the upstream VideoLAN.LibVLC.Windows NuGet package. The recorded toolchain uses GCC 13 / MinGW win32. A local build.sh patch disables dvdread and caca. Contrib is configured with `--disable-gpl --disable-gnuv3 --enable-ad-clauses`; VLC additionally disables live555. The explicit exclusion list removes 35 of the original 340 plugin DLLs.

The source collection contains code for components and platforms which are not selected into the shipped native candidate. Each source component keeps its own license. Presence of GPL text or unused GPL source in an archive is not presented as the licensing status of the whole application.

## Source downloads

Two review ZIPs are prepared as release attachments:

- `RADUSELF-LibVLC-305-sources-core-review.zip`: VLC, exact GCC/MinGW runtime source archives, patch, build evidence, exclusions, notices and instructions.
- `RADUSELF-LibVLC-305-sources-contrib-review.zip`: original contrib source archives, recipes and patches.

Both are required. Extract them into the same new directory, then run `sha256sum -c SHA256SUMS`. Attachments are not available until the release is actually uploaded; do not substitute GitHub's automatically generated repository ZIP for the complete source attachments.

## Rebuilding and replacement

See `BUILDING.md` and the documents included under `audit/` in the combined source bundle. The rebuilt DLLs can be tested in a separate unpackaged player copy before installation. The workflow does not overwrite the original tested player. Rebuilding and loading the replaced native set was demonstrated; a full dependency-by-dependency modification/relinking test remains open.

RADUSELF does not restrict modification or reverse engineering for debugging modifications to the LGPL libraries. This statement does not relicense RADUSELF itself.

## Notices

Native notices and original texts are included under `notices/` in the source bundle. Goom attribution: Jean-Christophe Hoelt (Jeko), iOS-software. FreeType attribution: Portions of this software are copyright (c) 1996-2026 The FreeType Project (https://freetype.org). All rights reserved.

This native-source repository does not contain the player application's private source, API credentials, signing certificate/private key or signed MSIX packages.
