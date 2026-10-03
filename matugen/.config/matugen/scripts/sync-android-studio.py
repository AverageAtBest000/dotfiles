#!/usr/bin/env python3
"""Build a data-only Android Studio theme plugin from the Matugen palette.

The IDE loads theme resources on startup; restart after palette changes.
No IDE options are rewritten, so running Studio cannot overwrite selections.
"""

import argparse
import json
import os
from pathlib import Path
import re
import tempfile
import xml.etree.ElementTree as ET
from zipfile import ZipFile, ZIP_DEFLATED


def build(palette):
    def color(key):
        value = palette[key]
        if not re.fullmatch(r"#[0-9a-fA-F]{6}", value):
            raise ValueError(f"Invalid palette color: {key}={value!r}")
        return value

    rgb = bytes.fromhex(color("background")[1:])
    dark = sum(c * w for c, w in zip(rgb, (0.2126, 0.7152, 0.0722))) < 128
    ui = {}
    mappings = {
        "surface_low": ["*.background", "Panel.background", "MainToolbar.background",
                        "StatusBar.background", "ToolWindow.Stripe.background"],
        "surface_high": ["MainWindow.background", "*.disabledBackground"],
        "foreground": ["*.foreground", "Label.foreground", "TextField.foreground"],
        "muted": ["*.disabledForeground", "Label.infoForeground"],
        "background": ["ToolWindow.background", "ToolWindow.Header.background",
                       "ToolWindow.Header.inactiveBackground", "Island.borderColor",
                       "EditorTabs.background", "TextField.background", "Tree.background",
                       "List.background", "Table.background"],
        "secondary_container": ["*.selectionBackground", "EditorTabs.underlinedTabBackground",
                                "EditorTabs.inactiveUnderlinedTabBackground"],
        "on_secondary_container": ["*.selectionForeground"],
        "primary": ["Component.focusColor", "Component.focusedBorderColor",
                    "Link.activeForeground", "ProgressBar.progressColor",
                    "EditorTabs.underlinedBorderColor"],
        "outline_variant": ["Component.borderColor", "Separator.foreground",
                            "EditorTabs.inactiveUnderlinedTabBorderColor"],
    }
    for key, names in mappings.items():
        ui.update({name: color(key) for name in names})
    for name in ("StatusBar.borderColor", "ToolWindow.Stripe.borderColor", "MainToolbar.borderColor"):
        ui[name] = "#00000000"
    theme = {
        "name": "Matugen", "dark": dark, "author": "Local Matugen",
        "parentTheme": "Islands Dark" if dark else "Islands Light",
        "editorScheme": "/Matugen.xml", "ui": ui,
    }
    scheme = ET.Element("scheme", name="Matugen", version="142",
                        parent_scheme="Darcula" if dark else "Default")
    colors = ET.SubElement(scheme, "colors")
    for name, key in {
        "CARET_COLOR": "primary", "CARET_ROW_COLOR": "surface_low",
        "GUTTER_BACKGROUND": "background", "LINE_NUMBERS_COLOR": "outline",
        "LINE_NUMBER_ON_CARET_ROW_COLOR": "primary",
        "SELECTION_BACKGROUND": "secondary_container",
        "SELECTION_FOREGROUND": "on_secondary_container",
        "CONSOLE_BACKGROUND_KEY": "background", "INDENT_GUIDE": "outline_variant",
        "SELECTED_INDENT_GUIDE": "primary", "RIGHT_MARGIN_COLOR": "outline_variant",
        "ADDED_LINES_COLOR": "tertiary", "MODIFIED_LINES_COLOR": "primary",
        "DELETED_LINES_COLOR": "error",
    }.items():
        ET.SubElement(colors, "option", name=name, value=color(key)[1:])
    attrs = ET.SubElement(scheme, "attributes")

    def attribute(name, foreground, background=None):
        value = ET.SubElement(ET.SubElement(attrs, "option", name=name), "value")
        ET.SubElement(value, "option", name="FOREGROUND", value=color(foreground)[1:])
        if background:
            ET.SubElement(value, "option", name="BACKGROUND", value=color(background)[1:])

    attribute("TEXT", "foreground", "background")
    for name, key in {
        # Base16 accents extracted from a dark wallpaper can be almost black.
        # Material role colors are designed as foregrounds for this mode.
        "DEFAULT_KEYWORD": "tertiary", "DEFAULT_STRING": "secondary",
        "DEFAULT_NUMBER": "tertiary", "DEFAULT_CONSTANT": "tertiary",
        "DEFAULT_LINE_COMMENT": "muted", "DEFAULT_BLOCK_COMMENT": "muted",
        "DEFAULT_DOC_COMMENT": "muted", "DEFAULT_CLASS_NAME": "secondary",
        "DEFAULT_INTERFACE_NAME": "secondary", "DEFAULT_FUNCTION_DECLARATION": "primary",
        "DEFAULT_FUNCTION_CALL": "primary", "DEFAULT_INSTANCE_METHOD": "primary",
        "DEFAULT_STATIC_METHOD": "primary", "DEFAULT_INSTANCE_FIELD": "secondary",
        "DEFAULT_STATIC_FIELD": "secondary", "DEFAULT_PARAMETER": "foreground",
        "DEFAULT_LOCAL_VARIABLE": "foreground", "DEFAULT_IDENTIFIER": "foreground",
        "DEFAULT_OPERATION_SIGN": "primary", "DEFAULT_METADATA": "tertiary",
        "DEFAULT_VALID_STRING_ESCAPE": "primary", "DEFAULT_INVALID_STRING_ESCAPE": "error",
        "DEFAULT_TAG": "primary", "DEFAULT_ATTRIBUTE": "secondary",
        "CONSOLE_NORMAL_OUTPUT": "foreground", "CONSOLE_ERROR_OUTPUT": "error",
    }.items():
        attribute(name, key)
    # Keep even ANSI black/bright-black readable on the console background.
    ansi = ("muted", "error", "tertiary", "secondary", "primary", "tertiary", "secondary", "foreground")
    for index, name in enumerate(("BLACK", "RED", "GREEN", "YELLOW", "BLUE", "MAGENTA", "CYAN", "GRAY")):
        attribute(f"ANSI_{name}", ansi[index])
    for name, key in zip(("DARKGRAY", "RED_BRIGHT", "GREEN_BRIGHT", "YELLOW_BRIGHT",
                          "BLUE_BRIGHT", "MAGENTA_BRIGHT", "CYAN_BRIGHT", "WHITE"),
                         ("muted", *ansi[1:7], "foreground")):
        attribute(f"ANSI_{name}", key)
    ET.indent(scheme)
    descriptor = '''<idea-plugin>
  <id>local.matugen.android-studio</id>
  <name>Matugen</name>
  <version>1.0</version>
  <vendor>Local Matugen</vendor>
  <description>Generated wallpaper colors for the interface and editor. Restart after Matugen updates.</description>
  <idea-version since-build="253" />
  <depends>com.intellij.modules.platform</depends>
  <extensions defaultExtensionNs="com.intellij">
    <themeProvider id="local.matugen.android-studio" path="/Matugen.theme.json" />
  </extensions>
</idea-plugin>
'''
    return {"META-INF/plugin.xml": descriptor,
            "Matugen.theme.json": json.dumps(theme, indent=2) + "\n",
            "Matugen.xml": ET.tostring(scheme, encoding="unicode") + "\n"}


def main():
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    cache = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--palette", type=Path, default=cache / "matugen/android-studio-colors.json")
    parser.add_argument("--output-dir", type=Path, help="Build here instead of installing in Studio")
    args = parser.parse_args()
    resources = build(json.loads(args.palette.read_text()))
    targets = [args.output_dir] if args.output_dir else [
        data / "Google" / directory.name / "matugen-theme/lib"
        for directory in sorted((config / "Google").glob("AndroidStudio*"))
        if directory.is_dir() and not directory.name.endswith("-backup")
    ]
    for target in targets:
        target.mkdir(parents=True, exist_ok=True)
        # Replace atomically so Studio never reads a partially written JAR.
        with tempfile.NamedTemporaryFile(dir=target, suffix=".tmp", delete=False) as tmp:
            temporary = Path(tmp.name)
        try:
            with ZipFile(temporary, "w", ZIP_DEFLATED) as jar:
                for name, content in resources.items():
                    jar.writestr(name, content)
            temporary.chmod(0o644)
            temporary.replace(target / "matugen-theme.jar")
        finally:
            temporary.unlink(missing_ok=True)
        print(f"Matugen: updated {target / 'matugen-theme.jar'} (restart Studio to load)")


if __name__ == "__main__":
    main()
