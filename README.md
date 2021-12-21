# todolist

A Godot-based GUI application for keeping a todo list. You can either download one of the releases or use Godot to export the project.

## Building From Source

This project was built using Godot 3.4.1 stable; as such, use that to export this project. Here is a [link to the download page](https://godotengine.org/download).

The syntax for the commandline will be `godot --export PRESET PATH`, where "godot" is a path to the Godot binary or the name of a command. "PRESET" is an export preset: "Linux/X11" for Linux platforms and "Windows Desktop" for Windows platforms. You can also use "pck" to get the PCK file.

With that said, download the zip and extract it, then change to the directory where `project.godot` resides.

### Linux

```shell
/path/to/godot3.4 --export Linux/X11 binfile
```

## Windows
```shell
/path/to/godot3.4 --export "Windows Desktop" binfile
```
