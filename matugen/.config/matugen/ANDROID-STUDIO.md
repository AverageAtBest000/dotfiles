# Android Studio

Matugen generates `~/.cache/matugen/android-studio-colors.json`. Its post-hook
builds a local, data-only theme plugin for each Android Studio version found in
`~/.config/Google/AndroidStudio*`, respecting XDG directory overrides.
Python 3 is the only additional dependency.

After the first generation, restart Android Studio and choose **Matugen** under
**Settings → Appearance & Behavior → Appearance → Theme**. The theme includes
the editor scheme, syntax colors, console colors, and Islands interface colors.
If an editor scheme was manually pinned, select **Matugen** under
**Settings → Editor → Color Scheme** too.

Subsequent Matugen runs rebuild the plugin automatically. **Restart Android
Studio to load new colors**; this integration does not implement live reload.
It does not change IDE preferences or restart Studio itself.

The plugin is installed at
`~/.local/share/Google/AndroidStudio<version>/matugen-theme/lib/matugen-theme.jar`.
Run Matugen again after installing a new Studio version to install its theme.
To rebuild from the last generated palette manually:

```sh
python3 ~/.config/matugen/scripts/sync-android-studio.py
```

To revert, choose another theme and disable/uninstall the local **Matugen**
plugin. Remove the `[templates.android-studio]` entry in `config.toml` to stop
reinstalling it during future palette generation.
