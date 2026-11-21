# Build and modification notes

Use both source review ZIPs together. Extract into a new directory, verify SHA256SUMS, then read audit/REPRODUCTION.md and the recorded host package inventory. Exact archive files are preserved under sources/. Full offline bootstrap and availability of old host packages are not guaranteed.

Run `bash build-native.sh` from the combined bundle. The script uses a new directory named ~/raduself-libvlc-source-rebuild, refuses an existing destination, verifies the two main archive hashes, extracts using Python's data filter, writes the exact source commit to src/revision.txt, applies the local patch, builds and selects 305 plugins. It needs Python with tarfile.data_filter, the recorded GCC 13 win32 cross-toolchain and the other documented build dependencies. The 0-3 CPU affinity assumes those logical CPUs are available; adjust it on other machines.

Recorded Makefiles/config.log contain original absolute paths. They are evidence, not portable configuration files to copy over a fresh configuration. The source archive has no .git directory: git status/diff diagnostics from the v2 collector are not a patch. The actual local patch is audit/build-evidence/vlc-local-changes.patch.

To modify a dependency, preserve the original archive and hash record. Work in an independently extracted copy and document changes. Use that dependency's preserved contrib recipe and patches as the starting point. Rebuild/install its static archive into the same cross prefix and relink dependent VLC plugin DLLs. For Goom, the preserved build uses contrib/contrib-win64/goom/vlc_build; its configured Makefile builds libgoom2.a. The consuming VLC module uses GOOM_LIBS=-L<contrib-prefix>/lib -lgoom2. Rebuilding a static library alone is insufficient: its consuming plugin must also be relinked. The corresponding sources, configure inputs and link flags are recorded in the bundle.

After rebuilding VLC, run the selector as documented in audit/REPRODUCTION.md, with a new destination. It requires the expected original 340-plugin installation and exact exclusion paths, refuses empty/truncated DLL inputs, verifies copy hashes and creates the 305-plugin candidate. Do not ship or load the excluded GPL-declaring plugins merely because they were built in an intermediate directory.

Test a complete replacement native set in a new copy of the player. Keep the architecture x64 and the LibVLC 3 API compatible. The demonstrated Windows layout is Player/libvlc/win-x64 containing the three root DLLs and plugins/. Native sources and notices do not include the proprietary player application or permit arbitrary relicensing of it.

Open validation: dependency-by-dependency edit/relink procedure, full file-level notice applicability review and a build on a newly provisioned operating system. These notes do not assert all such checks have passed.
